Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 73DFD6B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 01:21:24 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so45919835pdr.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:21:24 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id ib8si12038683pbc.44.2015.07.09.22.21.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 22:21:23 -0700 (PDT)
Received: by pactm7 with SMTP id tm7so162349332pac.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:21:23 -0700 (PDT)
Date: Fri, 10 Jul 2015 14:21:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710052113.GA11329@bgram>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
 <20150710015828.GA692@swordfish>
 <20150710022910.GA18266@blaptop>
 <20150710041929.GC692@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710041929.GC692@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 10, 2015 at 01:19:29PM +0900, Sergey Senozhatsky wrote:
> On (07/10/15 11:29), Minchan Kim wrote:
> > Good question.
> > 
> > My worry was failure of order-0 page allocation in zram-swap path
> > when memory presssure is really heavy but I didn't insist to you
> > from sometime. The reason I changed my mind was
> > 
> > 1. It's almost dead system if there is no order-0 page
> > 2. If old might be working well, it's not our design, just luck.
> 
> I mean I find your argument that some level of fragmentation
> can be of use to be valid, to some degree.

The benefit I had in mind was to prevent failure of allocation.

> 
> 
> hm... by the way,
> 
> unsigned long zs_malloc(struct zs_pool *pool, size_t size)
> {
> ...
>    size += ZS_HANDLE_SIZE;
>    class = pool->size_class[get_size_class_index(size)];
> ...
>    if (!first_page) {
> 	   spin_unlock(&class->lock);
> 	   first_page = alloc_zspage(class, pool->flags);
> 	   if (unlikely(!first_page)) {
> 		   free_handle(pool, handle);
> 		   return 0;
> 	   }
>    ...
> 
> I'm thinking now, does it make sense to try harder here? if we
> failed to alloc_zspage(), then may be we can try any of unused
> objects from a 'upper' (larger/next) class?  there might be a
> plenty of them.

I actually thought about that but I didn't have any report from
community and product division of my compamy until now.
But with auto-compaction, the chance would be higher than old
so let's keep an eye on it(I think users can find it easily because
swap layer emits "write write failure").

If it happens(ie, any report from someone), we could try to compact
and then if it fails, we could fall back to upper class as a last
resort.

Thanks.
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
