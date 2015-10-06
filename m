Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id A8CE36B0268
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 11:41:55 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so173646636wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:41:55 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id r20si38879211wju.181.2015.10.06.08.41.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Oct 2015 08:41:54 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so164987576wic.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 08:41:54 -0700 (PDT)
Date: Tue, 6 Oct 2015 17:41:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Message-ID: <20151006154152.GC20600@dhcp22.suse.cz>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
 <014e01d10004$c45bba30$4d132e90$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <014e01d10004$c45bba30$4d132e90$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Tue 06-10-15 12:29:52, PINTU KUMAR wrote:
[...]
> > OK, that would explain why the second counter is so much larger than
> > oom_stall.
> > And that alone should have been a red flag IMO. Why should be memcg OOM
> > killer events accounted together with the global? How do you distinguish the
> > two?
> > 
> Actually, here, we are just interested in knowing oom_kill. Let it be either
> global, memcg or others.
> Once we know there are oom kill happening, we can easily find it by enabling
> logs.
> Normally in production system, all system logs will be disabled.

This doesn't make much sense to me. So you find out that _an oom killer_
was invoked but you have logs disabled. What now? You can hardly find
out what has happened and why it has happened. What is the point then?
Wait for another one to come? This might be never.

What is even more confusing is the mixing of memcg and global oom
conditions. They are really different things. Memcg API will even give
you notification about the OOM event.

[...]
> > Sorry, I wasn't clear enough here. I was talking about oom_stall counter here
> > not
> > oom_kill_count one.
> > 
> Ok, I got your point.
> Oom_kill_process, is called from 2 places:
> 1) out_of_memory
> 2) mem_cgroup_out_of_memory
> 
> And, out_of_memory is actually called from 3 places:
> 1) alloc_pages_may_oom
> 2) pagefault_out_of_memory
> 3) moom_callback (sysirq.c)
> 
> Thus, in this case, the oom_stall counter can be added in 4 places (in the
> beginning).
> 1) alloc_pages_may_oom
> 2) mem_cgroup_out_of_memory
> 3) pagefault_out_of_memory
> 4) moom_callback (sysirq.c)
> 
> For, case {2,3,4}, we could have actually called at one place in out_of_memory,

Why would you even consider 4 for oom_stall? This is an administrator
order to kill a memory hog. The system might be in a good shape just the
memory hog is misbehaving. I realize this is not a usual usecase but if
oom_stall is supposed to measure a memory pressure of some sort then
binding it to a user action is wrong thing to do.

> But this result into calling it 2 times because alloc_pages_may_oom also call
> out_of_memory.
> If there is any better idea, please let me know.

I think you are focusing too much on the implementation before you are
clear in what should be the desired semantic.

> > > > What is it supposed to tell us? How many times the system had to go
> > > > into emergency OOM steps? How many times the direct reclaim didn't
> > > > make any progress so we can consider the system OOM?
> > > >
> > > Yes, exactly, oom_stall can tell, how many times OOM is invoked in the
> > > system.
> > > Yes, it can also tell how many times direct_reclaim fails completely.
> > > Currently, we don't have any counter for direct_reclaim success/fail.
> > 
> > So why don't we add one? Direct reclaim failure is a clearly defined event and
> > it
> > also can be evaluated reasonably against allocstall.
> > 
> Yes, direct_reclaim success/fail is also planned ahead.
> May be something like:
> direct_reclaim_alloc_success
> direct_reclaim_alloc_fail

We already have alloc_stall so all_stall_noprogress or whatever better
name should be sufficient.

[...]

> > I am still not sure how useful this counter would be, though. Sure the log
> > ringbuffer might overflow (the risk can be reduced by reducing the
> > loglevel) but how much it would help to know that we had additional N OOM
> > victims? From my experience checking the OOM reports which are still in the
> > logbuffer are sufficient to see whether there is a memory leak, pinned memory
> > or a continuous memory pressure. Your experience might be different so it
> > would be nice to mention that in the changelog.
> 
> Ok. 
> As I said earlier, normally all logs will be disabled in production system.
> But, we can access /proc/vmstat. The oom would have happened in the system
> Earlier, but the logs would have over-written.
> The /proc/vmstat is the only counter which can tell, if ever system entered into
> oom cases.
> Once we know for sure that oom happened in the system, then we can enable all
> logs in the system to reproduce the oom scenarios to analyze further.

Why reducing the loglevel is not sufficient here? The output should be
considerably reduced and chances to overflow the ringbuffer reduced as well.

> Also it can help in initial tuning of the system for the memory needs of the
> system.
> In embedded world, we normally try to avoid the system to enter into kernel OOM
> as far as possible.

Which means that you should follow a completely different metric IMO.
oom_stall is way too late. It is at the time when no reclaim progress could
be done and we are OOM already.

> For example, in Android, we have LMK (low memory killer) driver that controls
> the OOM behavior. But most of the time these LMK threshold are statically
> controlled.
>
> Now with this oom counter we can dynamically control the LMK behavior.
> For example, in LMK we can check, if ever oom_stall becomes 1, that means system
> is hitting OOM state. At this stage we can immediately trigger the OOM killing
> from user space or LMK driver.

If you see oom_stall then you are basically OOM and the global OOM
killer will fire. Intervening with other party just sounds like a
terrible idea to me.

> Similar user case and requirement is there for Tizen that controls OOM from user
> space (without LMK).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
