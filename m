Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDD836B0069
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 07:54:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p87so17081475pfj.4
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 04:54:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b61si10421706plb.207.2017.09.13.04.54.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 04:54:47 -0700 (PDT)
Date: Wed, 13 Sep 2017 13:54:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about
 stalls
Message-ID: <20170913115442.4tpbiwu77y7lrz6g@dhcp22.suse.cz>
References: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com>
 <20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
 <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 11-09-17 19:36:59, Mikulas Patocka wrote:
> 
> 
> On Mon, 11 Sep 2017, Michal Hocko wrote:
> 
> > On Mon 11-09-17 02:52:53, Mikulas Patocka wrote:
> > > I am occasionally getting these warnings in khugepaged. It is an old 
> > > machine with 550MHz CPU and 512 MB RAM.
> > > 
> > > Note that khugepaged has nice value 19, so when the machine is loaded with 
> > > some work, khugepaged is stalled and this stall produces warning in the 
> > > allocator.
> > > 
> > > khugepaged does allocations with __GFP_NOWARN, but the flag __GFP_NOWARN
> > > is masked off when calling warn_alloc. This patch removes the masking of
> > > __GFP_NOWARN, so that the warning is suppressed.
> > > 
> > > khugepaged: page allocation stalls for 10273ms, order:10, mode:0x4340ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
> > > CPU: 0 PID: 3936 Comm: khugepaged Not tainted 4.12.3 #1
> > > Hardware name: System Manufacturer Product Name/VA-503A, BIOS 4.51 PG 08/02/00
> > > Call Trace:
> > >  ? warn_alloc+0xb9/0x140
> > >  ? __alloc_pages_nodemask+0x724/0x880
> > >  ? arch_irq_stat_cpu+0x1/0x40
> > >  ? detach_if_pending+0x80/0x80
> > >  ? khugepaged+0x10a/0x1d40
> > >  ? pick_next_task_fair+0xd2/0x180
> > >  ? wait_woken+0x60/0x60
> > >  ? kthread+0xcf/0x100
> > >  ? release_pte_page+0x40/0x40
> > >  ? kthread_create_on_node+0x40/0x40
> > >  ? ret_from_fork+0x19/0x30
> > > 
> > > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > > Cc: stable@vger.kernel.org
> > > Fixes: 63f53dea0c98 ("mm: warn about allocations which stall for too long")
> > 
> > This patch hasn't introduced this behavior. It deliberately skipped
> > warning on __GFP_NOWARN. This has been introduced later by 822519634142
> > ("mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"). I
> > disagreed [1] but overall consensus was that such a warning won't be
> > harmful. Could you be more specific why do you consider it wrong,
> > please?
> 
> I consider the warning wrong, because it warns when nothing goes wrong. 
> I've got 7 these warnings for 4 weeks of uptime. The warnings typically 
> happen when I run some compilation.
> 
> A process with low priority is expected to be running slowly when there's 
> some high-priority process, so there's no need to warn that the 
> low-priority process runs slowly.

I would tend to agree. It is certainly a noise in the log. And a kind of
thing I was worried about when objecting the patch previously. 
 
> What else can be done to avoid the warning? Skip the warning if the 
> process has lower priority?

No, I wouldn't play with priorities. Either we agree that NOWARN
allocations simply do _not_warn_ or we simply explain users that some of
those warnings might not be that critical and overloaded system might
show them.

Let's see what others think about this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
