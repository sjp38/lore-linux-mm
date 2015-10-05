Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 38BC16B02F5
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 08:23:02 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so117964383wic.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 05:23:01 -0700 (PDT)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com. [209.85.212.175])
        by mx.google.com with ESMTPS id lr4si16075558wic.99.2015.10.05.05.22.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 05:22:59 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so111886403wic.1
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 05:22:59 -0700 (PDT)
Date: Mon, 5 Oct 2015 14:22:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Message-ID: <20151005122258.GA7023@dhcp22.suse.cz>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Mon 05-10-15 11:42:49, PINTU KUMAR wrote:
[...]
> > > A snapshot of the result of over night test is shown below:
> > > $ cat /proc/vmstat
> > > oom_stall 610
> > > oom_kill_count 1763
> > >
> > > Here, oom_stall indicates that there are 610 times, kernel entered
> > > into OOM cases. However, there were around 1763 oom killing happens.
> > 
> > This alone looks quite suspicious. Unless you have tasks which share the
> > address
> > space without being in the same thread group this shouldn't happen in such a
> > large scale.
> 
> Yes, this accounts for out_of_memory even from memory cgroups.
> Please check few snapshots of dmesg outputs captured during over-night tests.

OK, that would explain why the second counter is so much larger than
oom_stall. And that alone should have been a red flag IMO. Why should be
memcg OOM killer events accounted together with the global? How do you
distinguish the two?

> ........
> [49479.078033]  [2:      xxxxxxxx:20874] Memory cgroup out of memory: Kill
> process 20880 (xxxxxxx) score 112 or sacrifice child
> [49480.910430]  [2:      xxxxxxxx:20882] Memory cgroup out of memory: Kill
> process 20888 (xxxxxxxx) score 112 or sacrifice child
> [49567.046203]  [0:        yyyyyyy:  548] Out of memory: Kill process 20458
> (zzzzzzzzzz) score 102 or sacrifice child
> [49567.346588]  [0:        yyyyyyy:  548] Out of memory: Kill process 21102
> (zzzzzzzzzz) score 104 or sacrifice child
> .........
> The _out of memory_ count in dmesg dump output exactly matches the number in
> /proc/vmstat -> oom_kill_count
> 
> > </me looks into the patch>
> > And indeed the patch is incorrect. You are only counting OOMs from the page
> > allocator slow path. You are missing all the OOM invocations from the page
> > fault
> > path.
> 
> Sorry, I am not sure what exactly you mean. Please point me out if I am missing
> some places.
> Actually, I tried to add it at generic place that is; oom_kill_process, which is
> called by out_of_memory(...).
> Are you talking about: pagefault_out_of_memory(...) ?
> But, this is already calling: out_of_memory. No?

Sorry, I wasn't clear enough here. I was talking about oom_stall counter
here not oom_kill_count one.

[...]
> > What is it supposed to tell us? How many times the system had to go into
> > emergency OOM steps? How many times the direct reclaim didn't make any
> > progress so we can consider the system OOM?
> > 
> Yes, exactly, oom_stall can tell, how many times OOM is invoked in the system.
> Yes, it can also tell how many times direct_reclaim fails completely.
> Currently, we don't have any counter for direct_reclaim success/fail.

So why don't we add one? Direct reclaim failure is a clearly defined
event and it also can be evaluated reasonably against allocstall.

> Also, oom_kill_process will not be invoked for higher orders
> (PAGE_ALLOC_COSTLY_ORDER).
> But, it will enter OOM and results into straight page allocation failure.

Yes there are other reasons to not invoke OOM killer or to prevent
actual killing if chances are high we can go without it. This is the
reason I am asking about the exact semantic.

> > oom_kill_count has a slightly misleading names because it suggests how many
> > times oom_kill was called but in fact it counts the oom victims.
> > Not sure whether this information is so much useful but the semantic is clear
> > at least.
> > 
> Ok, agree about the semantic of the name: oom_kill_count.
> If possible please suggest a better name.
> How about the following names?
> oom_victim_count ?
> oom_nr_killed ?
> oom_nr_victim ?

nr_oom_victims?

I am still not sure how useful this counter would be, though. Sure the
log ringbuffer might overflow (the risk can be reduced by reducing the
loglevel) but how much it would help to know that we had additional N
OOM victims? From my experience checking the OOM reports which are still
in the logbuffer are sufficient to see whether there is a memory leak,
pinned memory or a continuous memory pressure. Your experience might be
different so it would be nice to mention that in the changelog.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
