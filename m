Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E4436B02FE
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 19:37:09 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id o77so14710498qke.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:37:09 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e190si10182855qkf.364.2017.09.11.16.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 16:37:08 -0700 (PDT)
Date: Mon, 11 Sep 2017 19:36:59 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about
 stalls
In-Reply-To: <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com> <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Mon, 11 Sep 2017, Michal Hocko wrote:

> On Mon 11-09-17 02:52:53, Mikulas Patocka wrote:
> > I am occasionally getting these warnings in khugepaged. It is an old 
> > machine with 550MHz CPU and 512 MB RAM.
> > 
> > Note that khugepaged has nice value 19, so when the machine is loaded with 
> > some work, khugepaged is stalled and this stall produces warning in the 
> > allocator.
> > 
> > khugepaged does allocations with __GFP_NOWARN, but the flag __GFP_NOWARN
> > is masked off when calling warn_alloc. This patch removes the masking of
> > __GFP_NOWARN, so that the warning is suppressed.
> > 
> > khugepaged: page allocation stalls for 10273ms, order:10, mode:0x4340ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
> > CPU: 0 PID: 3936 Comm: khugepaged Not tainted 4.12.3 #1
> > Hardware name: System Manufacturer Product Name/VA-503A, BIOS 4.51 PG 08/02/00
> > Call Trace:
> >  ? warn_alloc+0xb9/0x140
> >  ? __alloc_pages_nodemask+0x724/0x880
> >  ? arch_irq_stat_cpu+0x1/0x40
> >  ? detach_if_pending+0x80/0x80
> >  ? khugepaged+0x10a/0x1d40
> >  ? pick_next_task_fair+0xd2/0x180
> >  ? wait_woken+0x60/0x60
> >  ? kthread+0xcf/0x100
> >  ? release_pte_page+0x40/0x40
> >  ? kthread_create_on_node+0x40/0x40
> >  ? ret_from_fork+0x19/0x30
> > 
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > Cc: stable@vger.kernel.org
> > Fixes: 63f53dea0c98 ("mm: warn about allocations which stall for too long")
> 
> This patch hasn't introduced this behavior. It deliberately skipped
> warning on __GFP_NOWARN. This has been introduced later by 822519634142
> ("mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"). I
> disagreed [1] but overall consensus was that such a warning won't be
> harmful. Could you be more specific why do you consider it wrong,
> please?

I consider the warning wrong, because it warns when nothing goes wrong. 
I've got 7 these warnings for 4 weeks of uptime. The warnings typically 
happen when I run some compilation.

A process with low priority is expected to be running slowly when there's 
some high-priority process, so there's no need to warn that the 
low-priority process runs slowly.

What else can be done to avoid the warning? Skip the warning if the 
process has lower priority?

Mikulas

> [1] http://lkml.kernel.org/r/20170125184548.GB32041@dhcp22.suse.cz
> 
> > 
> > ---
> >  mm/page_alloc.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: linux-2.6/mm/page_alloc.c
> > ===================================================================
> > --- linux-2.6.orig/mm/page_alloc.c
> > +++ linux-2.6/mm/page_alloc.c
> > @@ -3923,7 +3923,7 @@ retry:
> >  
> >  	/* Make sure we know about allocations which stall for too long */
> >  	if (time_after(jiffies, alloc_start + stall_timeout)) {
> > -		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
> > +		warn_alloc(gfp_mask, ac->nodemask,
> >  			"page allocation stalls for %ums, order:%u",
> >  			jiffies_to_msecs(jiffies-alloc_start), order);
> >  		stall_timeout += 10 * HZ;
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
