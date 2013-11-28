Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 567DC6B0035
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 21:18:19 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so3578381bkb.30
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 18:18:18 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qx8si289887bkb.67.2013.11.27.18.18.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 18:18:18 -0800 (PST)
Date: Wed, 27 Nov 2013 21:18:09 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [merged]
 mm-memcg-handle-non-error-oom-situations-more-gracefully.patch removed from
 -mm tree
Message-ID: <20131128021809.GI3556@cmpxchg.org>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org>
 <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com>
 <20131127233353.GH3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 27, 2013 at 04:56:04PM -0800, David Rientjes wrote:
> On Wed, 27 Nov 2013, Johannes Weiner wrote:
> 
> > > The memcg oom killer has incurred a serious regression since the 3.12-rc6 
> > > kernel where this was merged as 4942642080ea ("mm: memcg: handle non-error 
> > > OOM situations more gracefully").  It cc'd stable@kernel.org although it 
> > > doesn't appear to have been picked up yet, and I'm hoping that we can 
> > > avoid having it merged in a stable kernel until we get this fixed.
> > > 
> > > This patch, specifically the above, allows memcgs to bypass their limits 
> > > by charging the root memcg in oom conditions.
> > > 
> > > If I create a memcg, cg1, with memory.limit_in_bytes == 128MB and start a
> > > memory allocator in it to induce oom, the memcg limit is trivially broken:
> > > 
> > > membench invoked oom-killer: gfp_mask=0xd0, order=0, oom_score_adj=0
> > > membench cpuset=/ mems_allowed=0-3
> > > CPU: 9 PID: 11388 Comm: membench Not tainted 3.13-rc1
> > >  ffffc90015ec6000 ffff880671c3dc18 ffffffff8154a1e3 0000000000000007
> > >  ffff880674c215d0 ffff880671c3dc98 ffffffff81548b45 ffff880671c3dc58
> > >  ffffffff81151de7 0000000000000001 0000000000000292 ffff880800000000
> > > Call Trace:
> > >  [<ffffffff8154a1e3>] dump_stack+0x46/0x58
> > >  [<ffffffff81548b45>] dump_header+0x7a/0x1bb
> > >  [<ffffffff81151de7>] ? find_lock_task_mm+0x27/0x70
> > >  [<ffffffff812e8b76>] ? ___ratelimit+0x96/0x110
> > >  [<ffffffff811521c4>] oom_kill_process+0x1c4/0x330
> > >  [<ffffffff81099ee5>] ? has_ns_capability_noaudit+0x15/0x20
> > >  [<ffffffff811a916a>] mem_cgroup_oom_synchronize+0x50a/0x570
> > >  [<ffffffff811a8660>] ? __mem_cgroup_try_charge_swapin+0x70/0x70
> > >  [<ffffffff81152968>] pagefault_out_of_memory+0x18/0x90
> > >  [<ffffffff81547b86>] mm_fault_error+0xb7/0x15a
> > >  [<ffffffff81553efb>] __do_page_fault+0x42b/0x500
> > >  [<ffffffff810c667d>] ? set_next_entity+0xad/0xd0
> > >  [<ffffffff810c670b>] ? pick_next_task_fair+0x6b/0x170
> > >  [<ffffffff8154d08e>] ? __schedule+0x38e/0x780
> > >  [<ffffffff81553fde>] do_page_fault+0xe/0x10
> > >  [<ffffffff815509e2>] page_fault+0x22/0x30
> > > Task in /cg1 killed as a result of limit of /cg1
> > > memory: usage 131072kB, limit 131072kB, failcnt 1053
> > > memory+swap: usage 0kB, limit 18014398509481983kB, failcnt 0
> > > kmem: usage 0kB, limit 18014398509481983kB, failcnt 0
> > > Memory cgroup stats for /cg1: cache:84KB rss:130988KB rss_huge:116736KB mapped_file:72KB writeback:0KB inactive_anon:0KB active_anon:130976KB inactive_file:4KB active_file:0KB unevictable:0KB
> > > [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
> > > [ 7761]     0  7761     1106      483       5        0             0 bash
> > > [11388]    99 11388   270773    33031      83        0             0 membench
> > > Memory cgroup out of memory: Kill process 11388 (membench) score 1010 or sacrifice child
> > > Killed process 11388 (membench) total-vm:1083092kB, anon-rss:130824kB, file-rss:1300kB
> > > 
> > > The score of 1010 shown for pid 11388 (membench) should never happen in 
> > > the oom killer, the maximum value should always be 1000 in any oom 
> > > context.  This indicates that the process has allocated more memory than 
> > > is available to the memcg.  The rss value, 33031 pages, shows that it has 
> > > allocated >129MB of memory in a memcg limited to 128MB.
> > > 
> > > The entire premise of memcg is to prevent processes attached to it to not 
> > > be able to allocate more memory than allowed and this trivially breaks 
> > > that premise in oom conditions.
> > 
> > We already allow a task to allocate beyond the limit if it's selected
> > by the OOM killer, so that it can exit faster.
> > 
> > My patch added that a task can bypass the limit when it decided to
> > trigger the OOM killer, so that it can get to the OOM kill faster.
> > 
> 
> The task that is bypassing the memcg charge to the root memcg may not be 
> the process that is chosen by the oom killer, and it's possible the amount 
> of memory freed by killing the victim is less than the amount of memory 
> bypassed.

That's true, though unlikely.

> > So I don't think my patch has broken "the entire premise of memcgs".
> > At the same time, it also does not really rely on that bypass, we
> > should be able to remove it.
> > 
> > This patch series was not supposed to go into the last merge window, I
> > already told stable to hold off on these until further notice.
> > 
> 
> Were you targeting these to 3.13 instead?  If so, it would have already 
> appeared in 3.13-rc1 anyway.  Is it still a work in progress?

I don't know how to answer this question.

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 13b9d0f..5f9e467 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2675,7 +2675,7 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  		goto bypass;
> >  
> >  	if (unlikely(task_in_memcg_oom(current)))
> > -		goto bypass;
> > +		goto nomem;
> >  
> >  	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> 
> Is there any benefit to doing this over just schedule_timeout_killable() 
> since we need to wait for mem_cgroup_oom_synchronize() to be able to make 
> forward progress at this point?

This does not make any sense, current is the process that will execute
mem_cgroup_oom_synchronize().  current entered OOM, it will kill once
the fault handler returns.  This check is there to quickly end any
subsequent attempts of the fault handler to allocate memory after a
failed allocation and to get quickly to the OOM killer.

> Should we be checking mem_cgroup_margin() here to ensure 
> task_in_memcg_oom() is still accurate and we haven't raced by freeing 
> memory?

We would have invoked the OOM killer long before this point prior to
my patches.  There is a line we draw and from that point on we start
killing things.  I tried to explain multiple times now that there is
no race-free OOM killing and I'm tired of it.  Convince me otherwise
or stop repeating this non-sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
