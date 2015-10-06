Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 728CF82FB0
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 03:00:06 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so61199076pad.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 00:00:06 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id jo6si46603013pbc.90.2015.10.06.00.00.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 Oct 2015 00:00:05 -0700 (PDT)
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVS022V2E42F050@mailout4.samsung.com> for linux-mm@kvack.org;
 Tue, 06 Oct 2015 16:00:02 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
In-reply-to: <20151005122258.GA7023@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Tue, 06 Oct 2015 12:29:52 +0530
Message-id: <014e01d10004$c45bba30$4d132e90$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

Hi,

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Monday, October 05, 2015 5:53 PM
> To: PINTU KUMAR
> Cc: akpm@linux-foundation.org; minchan@kernel.org; dave@stgolabs.net;
> koct9i@gmail.com; rientjes@google.com; hannes@cmpxchg.org; penguin-
> kernel@i-love.sakura.ne.jp; bywxiaobai@163.com; mgorman@suse.de;
> vbabka@suse.cz; js1304@gmail.com; kirill.shutemov@linux.intel.com;
> alexander.h.duyck@redhat.com; sasha.levin@oracle.com; cl@linux.com;
> fengguang.wu@intel.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.ping@gmail.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; c.rajkumar@samsung.com;
> sreenathd@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
> 
> On Mon 05-10-15 11:42:49, PINTU KUMAR wrote:
> [...]
> > > > A snapshot of the result of over night test is shown below:
> > > > $ cat /proc/vmstat
> > > > oom_stall 610
> > > > oom_kill_count 1763
> > > >
> > > > Here, oom_stall indicates that there are 610 times, kernel entered
> > > > into OOM cases. However, there were around 1763 oom killing happens.
> > >
> > > This alone looks quite suspicious. Unless you have tasks which share
> > > the address space without being in the same thread group this
> > > shouldn't happen in such a large scale.
> >
> > Yes, this accounts for out_of_memory even from memory cgroups.
> > Please check few snapshots of dmesg outputs captured during over-night
tests.
> 
> OK, that would explain why the second counter is so much larger than
oom_stall.
> And that alone should have been a red flag IMO. Why should be memcg OOM
> killer events accounted together with the global? How do you distinguish the
> two?
> 
Actually, here, we are just interested in knowing oom_kill. Let it be either
global, memcg or others.
Once we know there are oom kill happening, we can easily find it by enabling
logs.
Normally in production system, all system logs will be disabled.

> > ........
> > [49479.078033]  [2:      xxxxxxxx:20874] Memory cgroup out of memory: Kill
> > process 20880 (xxxxxxx) score 112 or sacrifice child
> > [49480.910430]  [2:      xxxxxxxx:20882] Memory cgroup out of memory: Kill
> > process 20888 (xxxxxxxx) score 112 or sacrifice child
> > [49567.046203]  [0:        yyyyyyy:  548] Out of memory: Kill process 20458
> > (zzzzzzzzzz) score 102 or sacrifice child
> > [49567.346588]  [0:        yyyyyyy:  548] Out of memory: Kill process 21102
> > (zzzzzzzzzz) score 104 or sacrifice child .........
> > The _out of memory_ count in dmesg dump output exactly matches the
> > number in /proc/vmstat -> oom_kill_count
> >
> > > </me looks into the patch>
> > > And indeed the patch is incorrect. You are only counting OOMs from
> > > the page allocator slow path. You are missing all the OOM
> > > invocations from the page fault path.
> >
> > Sorry, I am not sure what exactly you mean. Please point me out if I
> > am missing some places.
> > Actually, I tried to add it at generic place that is;
> > oom_kill_process, which is called by out_of_memory(...).
> > Are you talking about: pagefault_out_of_memory(...) ?
> > But, this is already calling: out_of_memory. No?
> 
> Sorry, I wasn't clear enough here. I was talking about oom_stall counter here
not
> oom_kill_count one.
> 
Ok, I got your point.
Oom_kill_process, is called from 2 places:
1) out_of_memory
2) mem_cgroup_out_of_memory

And, out_of_memory is actually called from 3 places:
1) alloc_pages_may_oom
2) pagefault_out_of_memory
3) moom_callback (sysirq.c)

Thus, in this case, the oom_stall counter can be added in 4 places (in the
beginning).
1) alloc_pages_may_oom
2) mem_cgroup_out_of_memory
3) pagefault_out_of_memory
4) moom_callback (sysirq.c)

For, case {2,3,4}, we could have actually called at one place in out_of_memory,
But this result into calling it 2 times because alloc_pages_may_oom also call
out_of_memory.
If there is any better idea, please let me know.

> [...]
> > > What is it supposed to tell us? How many times the system had to go
> > > into emergency OOM steps? How many times the direct reclaim didn't
> > > make any progress so we can consider the system OOM?
> > >
> > Yes, exactly, oom_stall can tell, how many times OOM is invoked in the
system.
> > Yes, it can also tell how many times direct_reclaim fails completely.
> > Currently, we don't have any counter for direct_reclaim success/fail.
> 
> So why don't we add one? Direct reclaim failure is a clearly defined event and
it
> also can be evaluated reasonably against allocstall.
> 
Yes, direct_reclaim success/fail is also planned ahead.
May be something like:
direct_reclaim_alloc_success
direct_reclaim_alloc_fail

But, then I thought oom_kill is more important than this. So I pushed this one
first.

> > Also, oom_kill_process will not be invoked for higher orders
> > (PAGE_ALLOC_COSTLY_ORDER).
> > But, it will enter OOM and results into straight page allocation failure.
> 
> Yes there are other reasons to not invoke OOM killer or to prevent actual
killing
> if chances are high we can go without it. This is the reason I am asking about
the
> exact semantic.
> 
> > > oom_kill_count has a slightly misleading names because it suggests
> > > how many times oom_kill was called but in fact it counts the oom victims.
> > > Not sure whether this information is so much useful but the semantic
> > > is clear at least.
> > >
> > Ok, agree about the semantic of the name: oom_kill_count.
> > If possible please suggest a better name.
> > How about the following names?
> > oom_victim_count ?
> > oom_nr_killed ?
> > oom_nr_victim ?
> 
> nr_oom_victims?
> 
Ok, nr_oom_victims is also nice name. If all agree I can change this name.
Please confirm.

> I am still not sure how useful this counter would be, though. Sure the log
> ringbuffer might overflow (the risk can be reduced by reducing the
> loglevel) but how much it would help to know that we had additional N OOM
> victims? From my experience checking the OOM reports which are still in the
> logbuffer are sufficient to see whether there is a memory leak, pinned memory
> or a continuous memory pressure. Your experience might be different so it
> would be nice to mention that in the changelog.

Ok. 
As I said earlier, normally all logs will be disabled in production system.
But, we can access /proc/vmstat. The oom would have happened in the system
Earlier, but the logs would have over-written.
The /proc/vmstat is the only counter which can tell, if ever system entered into
oom cases.
Once we know for sure that oom happened in the system, then we can enable all
logs in the system to reproduce the oom scenarios to analyze further.
Also it can help in initial tuning of the system for the memory needs of the
system.
In embedded world, we normally try to avoid the system to enter into kernel OOM
as far as possible.
For example, in Android, we have LMK (low memory killer) driver that controls
the OOM behavior. But most of the time these LMK threshold are statically
controlled.
Now with this oom counter we can dynamically control the LMK behavior.
For example, in LMK we can check, if ever oom_stall becomes 1, that means system
is hitting OOM state. At this stage we can immediately trigger the OOM killing
from user space or LMK driver.
Similar user case and requirement is there for Tizen that controls OOM from user
space (without LMK).
It can also trigger the thought for sluggish behavior in the system during long
run.
These are just few use cases. More can be thought of.

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
