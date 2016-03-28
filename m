Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2435F6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 07:45:39 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id nk17so50183948igb.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 04:45:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j1si7622999igv.36.2016.03.28.04.45.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 04:45:37 -0700 (PDT)
Subject: Re: memory fragmentation issues on 4.4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <56F8F5DA.6040206@kyup.com>
	<56F90D94.9000604@I-love.SAKURA.ne.jp>
	<56F91229.8050704@kyup.com>
In-Reply-To: <56F91229.8050704@kyup.com>
Message-Id: <201603282045.FJB95376.OVtFJQFSOLHOFM@I-love.SAKURA.ne.jp>
Date: Mon, 28 Mar 2016 20:45:32 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel@kyup.com
Cc: linux-mm@kvack.org, vbabka@suse.cz, mgorman@techsingularity.net

Nikolay Borisov wrote:
> On 03/28/2016 01:55 PM, Tetsuo Handa wrote:
> > On 2016/03/28 18:14, Nikolay Borisov wrote:
> >> Hello,
> >>
> >> On kernel 4.4 I observe that the memory gets really fragmented fairly
> >> quickly. E.g. there are no order  > 4 pages even after 2 days of uptime.
> >> This leads to certain data structures on XFS (in my case order 4/order 5
> >> allocations)  not being allocated and causes the server to stall. When
> >> this happens either someone has to log on the server and manually invoke
> >> the memory compaction or plain reboot the server. Before that the server
> >> was running with the exact same workload but with 3.12.52 kernel and no
> >> such issue were observed. That is - memory was fragmented but allocation
> >> didn't fail, maybe alloc_pages_direct_compact was doing a better job?
> > 
> > I'm not a mm person. But currently the page allocator does not give up
> > unless there is no reclaimable zones. That would be the reason the allocation
> > did not fail but caused the system to stall. It is interesting for mm people
> > if you can try, apart from your fragmentation issue, running linux-next kernel
> > which includes OOM detection rework ( https://lwn.net/Articles/667939/ ).
> 
> I don't think that this would have helped since the machine didn't run
> out of memory rather memory was so fragmented that an order 5 allocation
> could not be satisfied. Which I think means no OOM logic would have been
> triggered.
> 
> Actually the allocation did fail but was infinitely retried by merit of
> the logic in kmem_alloc. So in this case kmalloc was returning a NULL-ptr.

Oops, I missed

	/* The OOM killer will not help higher order allocs */
	if (order > PAGE_ALLOC_COSTLY_ORDER)
		goto out;

in __alloc_pages_may_oom().

> 
> 
> > 
> >>
> >> FYI the allocation is performed with GFP_KERNEL | GFP_NOFS
> > 
> > Excuse me, but GFP_KERNEL is GFP_NOFS | __GFP_FS, and therefore
> > GFP_KERNEL | GFP_NOFS is GFP_KERNEL. What did you mean?
> 
> Right, so it's : (GFP_KERNEL | __GFP_NOWARN) &= ~__GFP_FS
> 

So, !__GFP_FS && !__GFP_NOFAIL && order > 3 allocation from kmem_alloc()
is stalling. Sorry, I'm not familiar with fragmentation.

> > 
> >>
> >>
> >> Manual compaction usually does the job, however I'm wondering why isn't
> >> invoking __alloc_pages_direct_compact from within __alloc_pages_nodemask
> >> satisfying the request if manual compaction would do the job. Is there a
> >> difference in the efficiency of manually invoking memory compaction and
> >> the one invoked from the page allocator path?
> >>
> >>
> >> Another question for my own satisfaction - I created a kernel module
> >> which allocate pages of very high order - 8/9) then later when those
> >> pages are returned I see the number of unmovable pages increase by the
> >> amount of pages returned. So should freed pages go to the unmovable
> >> category?
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >>
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
