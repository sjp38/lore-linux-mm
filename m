Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BA22D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 03:39:25 -0400 (EDT)
Received: by pacwz10 with SMTP id wz10so4242090pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 00:39:25 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id bt5si7163736pdb.156.2015.03.26.00.39.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 00:39:24 -0700 (PDT)
Received: by pacwz10 with SMTP id wz10so4241812pac.2
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 00:39:24 -0700 (PDT)
Date: Thu, 26 Mar 2015 16:39:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [withdrawn]
 zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch removed from -mm
 tree
Message-ID: <20150326073916.GB26725@blaptop>
References: <5513199f.t25SPuX5ULuM6JS8%akpm@linux-foundation.org>
 <20150326002717.GA1669@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150326002717.GA1669@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: akpm@linux-foundation.org, sergey.senozhatsky@gmail.com, ngupta@vflare.org, sfr@canb.auug.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello Sergey,

Sorry for slow response.
I am overwhelmed with too much to do. :(

On Thu, Mar 26, 2015 at 09:27:17AM +0900, Sergey Senozhatsky wrote:
> On (03/25/15 13:25), akpm@linux-foundation.org wrote:
> > The patch titled
> >      Subject: zsmalloc: remove extra cond_resched() in __zs_compact
> > has been removed from the -mm tree.  Its filename was
> >      zsmalloc-remove-extra-cond_resched-in-__zs_compact.patch
> > 
> > This patch was dropped because it was withdrawn
> > 
> > ------------------------------------------------------
> > From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Subject: zsmalloc: remove extra cond_resched() in __zs_compact
> > 
> > Do not perform cond_resched() before the busy compaction loop in
> > __zs_compact(), because this loop does it when needed.
> > 
> > Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  mm/zsmalloc.c |    2 --
> >  1 file changed, 2 deletions(-)
> > 
> > diff -puN mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact mm/zsmalloc.c
> > --- a/mm/zsmalloc.c~zsmalloc-remove-extra-cond_resched-in-__zs_compact
> > +++ a/mm/zsmalloc.c
> > @@ -1717,8 +1717,6 @@ static unsigned long __zs_compact(struct
> >  	struct page *dst_page = NULL;
> >  	unsigned long nr_total_migrated = 0;
> >  
> > -	cond_resched();
> > -
> >  	spin_lock(&class->lock);
> >  	while ((src_page = isolate_source_page(class))) {
> >  
> 
> Hello,
> 
> Minchan, did I miss your NACK on this patch? or could you please ACK it?

I saw this patch yesterday night but didn't acked intentionally because
I was not sure and too tired to see the code so I postpone.

If we removed cond_resched out of outer loop(ie, your patch), we lose
the chance to reschedule if alloc_target_page fails(ie, there is no
zspage in ZS_ALMOST_FULL and ZS_ALMOST_EMPTY).
It might be not rare event if we does compation successfully for a
size_class. However, with next coming higher size_class for __zs_compact,
we will encounter cond_resched during compaction.
So, I am happy to ack. :)

Acked-by: Minchan Kim <minchan@kernel.org>

> 
> 	-ss

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
