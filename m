Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id F04F26B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:00:54 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id ga2so81722940lbc.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 12:00:54 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id wf4si46070415wjb.218.2016.05.23.12.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 12:00:53 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id f75so11557585wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 12:00:53 -0700 (PDT)
Date: Mon, 23 May 2016 21:00:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: page order 0 allocation fail but free pages are enough
Message-ID: <20160523190051.GF32715@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
 <20160523144711.GV2278@dhcp22.suse.cz>
 <CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Mon 23-05-16 23:31:09, yoma sophian wrote:
> hi Michal
> 
> 2016-05-23 22:47 GMT+08:00, Michal Hocko <mhocko@kernel.org>:
> > On Mon 23-05-16 14:47:51, yoma sophian wrote:
> >> hi all:
> >> I got something wired that
> >> 1. in softirq, there is a page order 0 allocation request
> >> 2. Normal/High zone are free enough for order 0 page.
> >> 3. but somehow kernel return order 0 allocation fail.
> >>
> >> My kernel version is 3.10 and below is kernel log:
> >> from memory info,
> >
> > Can you reproduce it with the current vanlilla tree?
>
> I think it would be quite hard, since this allocation failuer comes
> when a lot of program, such as Youtube, opera, etc. running on ARM
> processor at the same time.
> Or is there any patch in vanlilla tree I can used for checking?

No, but 3.10 is quite old and it is preferable to reproduce your issue
on the clean and up-to-date vanilla kernel to get a better chances to
get your problem resolved.

> > [...]
> >> [   94.586588] ksoftirqd/0: page allocation failure: order:0, mode:0x20
> > [...]
> >> [   94.865776] Normal free:63768kB min:2000kB low:2500kB high:3000kB
> > [...]
> >> [ 8606.701343] CompositorTileW: page allocation failure: order:0,
> >> mode:0x20
> > [...]
> >> [ 8606.703590] Normal free:60684kB min:2000kB low:2500kB high:3000kB
> >
> > This is a lot of free memory to block GFP_ATOMIC. One possible
> > explanation would be that this is a race with somebody releasing a lot
> I will try to add memory free at buffered_rmqueue like below xxx place
> buffered_rmqueue -->
>                if (likely(order == 0)) {
>                 ..................
>                 if (list_empty(list)) {
>                         pcp->count += rmqueue_bulk(zone, 0,
>                                         pcp->batch, list,
>                                         migratetype, cold);
>                         if (unlikely(list_empty(list)))
>                                 goto failed;    xxxxx ==>  to show
> memory free info

I would just mark NR_FREE_PAGES before and after allocation request.
Something like:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8f3bfc435ee..a1337aa7e897 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3565,6 +3565,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum compact_result compact_result;
 	int compaction_retries = 0;
 	int no_progress_loops = 0;
+	unsigned long nr_free_before;
+	
+	nr_free_before = global_page_state(NR_FREE_PAGES);
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3624,6 +3627,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * to fail.
 		 */
 		WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL);
+		pr_info("nr_free_before:%lu nr_free_now:%lu\n", nr_free_before, global_page_state(NR_FREE_PAGES));
 		goto nopage;
 	}
 
You can then compare the numbers before after and the allocation failure
to see whether there is a large gap.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
