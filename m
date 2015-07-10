Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A6A486B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 00:18:59 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so162997520pac.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 21:18:59 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ca1si11743494pbb.169.2015.07.09.21.18.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 21:18:58 -0700 (PDT)
Received: by pdbep18 with SMTP id ep18so176894760pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 21:18:58 -0700 (PDT)
Date: Fri, 10 Jul 2015 13:19:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710041929.GC692@swordfish>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
 <20150710015828.GA692@swordfish>
 <20150710022910.GA18266@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710022910.GA18266@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (07/10/15 11:29), Minchan Kim wrote:
> Good question.
> 
> My worry was failure of order-0 page allocation in zram-swap path
> when memory presssure is really heavy but I didn't insist to you
> from sometime. The reason I changed my mind was
> 
> 1. It's almost dead system if there is no order-0 page
> 2. If old might be working well, it's not our design, just luck.

I mean I find your argument that some level of fragmentation
can be of use to be valid, to some degree.


hm... by the way,

unsigned long zs_malloc(struct zs_pool *pool, size_t size)
{
...
   size += ZS_HANDLE_SIZE;
   class = pool->size_class[get_size_class_index(size)];
...
   if (!first_page) {
	   spin_unlock(&class->lock);
	   first_page = alloc_zspage(class, pool->flags);
	   if (unlikely(!first_page)) {
		   free_handle(pool, handle);
		   return 0;
	   }
   ...

I'm thinking now, does it make sense to try harder here? if we
failed to alloc_zspage(), then may be we can try any of unused
objects from a 'upper' (larger/next) class?  there might be a
plenty of them.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
