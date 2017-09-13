Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC5B46B0033
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 09:54:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o200so826176itg.2
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 06:54:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o8si1333534ite.126.2017.09.13.06.54.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Sep 2017 06:54:47 -0700 (PDT)
Subject: Re: [PATCH] mm: respect the __GFP_NOWARN flag when warning about stalls
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.LRH.2.02.1709110231010.3666@file01.intranet.prod.int.rdu2.redhat.com>
	<20170911082650.dqfirwc63xy7i33q@dhcp22.suse.cz>
	<alpine.LRH.2.02.1709111926480.31898@file01.intranet.prod.int.rdu2.redhat.com>
	<20170913115442.4tpbiwu77y7lrz6g@dhcp22.suse.cz>
In-Reply-To: <20170913115442.4tpbiwu77y7lrz6g@dhcp22.suse.cz>
Message-Id: <201709132254.DEE34807.LQOtMFOFJSOVHF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Sep 2017 22:54:37 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, mpatocka@redhat.com
Cc: vbabka@suse.cz, hannes@cmpxchg.org, mgorman@suse.de, dave.hansen@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Mon 11-09-17 19:36:59, Mikulas Patocka wrote:
> > 
> > 
> > On Mon, 11 Sep 2017, Michal Hocko wrote:
> > 
> > > On Mon 11-09-17 02:52:53, Mikulas Patocka wrote:
> > > > I am occasionally getting these warnings in khugepaged. It is an old 
> > > > machine with 550MHz CPU and 512 MB RAM.
> > > > 
> > > > Note that khugepaged has nice value 19, so when the machine is loaded with 
> > > > some work, khugepaged is stalled and this stall produces warning in the 
> > > > allocator.
> > > > 
> > > > khugepaged does allocations with __GFP_NOWARN, but the flag __GFP_NOWARN
> > > > is masked off when calling warn_alloc. This patch removes the masking of
> > > > __GFP_NOWARN, so that the warning is suppressed.
> > > > 
> > > > khugepaged: page allocation stalls for 10273ms, order:10, mode:0x4340ca(__GFP_HIGHMEM|__GFP_IO|__GFP_FS|__GFP_COMP|__GFP_NOMEMALLOC|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_DIRECT_RECLAIM), nodemask=(null)
> > > > CPU: 0 PID: 3936 Comm: khugepaged Not tainted 4.12.3 #1
> > > > Hardware name: System Manufacturer Product Name/VA-503A, BIOS 4.51 PG 08/02/00
> > > > Call Trace:
> > > >  ? warn_alloc+0xb9/0x140
> > > >  ? __alloc_pages_nodemask+0x724/0x880
> > > >  ? arch_irq_stat_cpu+0x1/0x40
> > > >  ? detach_if_pending+0x80/0x80
> > > >  ? khugepaged+0x10a/0x1d40
> > > >  ? pick_next_task_fair+0xd2/0x180
> > > >  ? wait_woken+0x60/0x60
> > > >  ? kthread+0xcf/0x100
> > > >  ? release_pte_page+0x40/0x40
> > > >  ? kthread_create_on_node+0x40/0x40
> > > >  ? ret_from_fork+0x19/0x30
> > > > 
> > > > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> > > > Cc: stable@vger.kernel.org
> > > > Fixes: 63f53dea0c98 ("mm: warn about allocations which stall for too long")
> > > 
> > > This patch hasn't introduced this behavior. It deliberately skipped
> > > warning on __GFP_NOWARN. This has been introduced later by 822519634142
> > > ("mm: page_alloc: __GFP_NOWARN shouldn't suppress stall warnings"). I
> > > disagreed [1] but overall consensus was that such a warning won't be
> > > harmful. Could you be more specific why do you consider it wrong,
> > > please?
> > 
> > I consider the warning wrong, because it warns when nothing goes wrong. 
> > I've got 7 these warnings for 4 weeks of uptime. The warnings typically 
> > happen when I run some compilation.
> > 
> > A process with low priority is expected to be running slowly when there's 
> > some high-priority process, so there's no need to warn that the 
> > low-priority process runs slowly.
> 
> I would tend to agree. It is certainly a noise in the log. And a kind of
> thing I was worried about when objecting the patch previously. 
>  
> > What else can be done to avoid the warning? Skip the warning if the 
> > process has lower priority?
> 
> No, I wouldn't play with priorities. Either we agree that NOWARN
> allocations simply do _not_warn_ or we simply explain users that some of
> those warnings might not be that critical and overloaded system might
> show them.
> 
> Let's see what others think about this.

Whether __GFP_NOWARN should warn about stalls is not a topic to discuss.
I consider warn_alloc() for reporting stalls is broken. It fails to provide
backtrace of stalling location. For example, OOM lockup with oom_lock held
cannot be reported by warn_alloc(). It fails to provide readable output when
called concurrently. For example, concurrent calls can cause printk()/
schedule_timeout_killable() lockup with oom_lock held. printk() offloading is
not an option, for there will be situations where printk() offloading cannot
be used (e.g. queuing via printk() is faster than writing to serial consoles
which results in unreadable logs due to log_bug overflow).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
