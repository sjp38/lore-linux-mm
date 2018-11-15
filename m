Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBE626B000D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:54:32 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id c25-v6so670893ioi.18
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:54:32 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d10si4962619ith.143.2018.11.15.01.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:54:31 -0800 (PST)
Subject: Re: [RFC PATCH v2 0/3] oom: rework oom_reaper vs. exit_mmap handoff
References: <20181025082403.3806-1-mhocko@kernel.org>
 <20181108093224.GS27423@dhcp22.suse.cz>
 <9dfd5c87-ae48-8ffb-fbc6-706d627658ff@i-love.sakura.ne.jp>
 <20181114101604.GM23419@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <0648083a-3112-97ff-edd7-1444c1be529a@i-love.sakura.ne.jp>
Date: Thu, 15 Nov 2018 18:54:15 +0900
MIME-Version: 1.0
In-Reply-To: <20181114101604.GM23419@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 2018/11/14 19:16, Michal Hocko wrote:
> On Wed 14-11-18 18:46:13, Tetsuo Handa wrote:
> [...]
> > There is always an invisible lock called "scheduling priority". You can't
> > leave the MMF_OOM_SKIP to the exit path. Your approach is not ready for
> > handling the worst case.
> 
> And that problem is all over the memory reclaim. You can get starved
> to death and block other resources. And the memory reclaim is not the
> only one.

I think that it is a manner for kernel developers that no thread keeps
consuming CPU resources forever. In the kernel world, doing

  while (1);

is not permitted. Likewise, doing

  for (i = 0; i < very_large_value; i++)
      do_something_which_does_not_yield_CPU_to_others();

has to be avoided, in order to avoid lockup problems. We are required to
yield CPU to others when we are waiting for somebody else to make progress.
It is the page allocator who is refusing to yield CPU to those who need CPU.

Since the OOM reaper kernel thread "has normal priority" and "can run on any
CPU", the possibility of failing to run is lower than an OOM victim thread
which "has idle priority" and "can run on only limited CPU". You are trying
to add a dependency on such thread, and I'm saying that adding a dependency
on such thread increases possibility of lockup.

Yes, even the OOM reaper kernel thread might fail to run if all CPUs were
busy with realtime threads waiting for the OOM reaper kernel thread to make
progress. In that case, we had better stop relying on asynchronous memory
reclaim, and switch to direct OOM reaping by allocating threads.

But what I demonstrated is that

        /*
         * the exit path is guaranteed to finish the memory tear down
         * without any unbound blocking at this stage so make it clear
         * to the oom_reaper
         */

becomes a lie even when only one CPU was busy with realtime threads waiting
for an idle thread to make progress. If the page allocator stops telling a
lie that "an OOM victim is making progress on behalf of me", we can avoid
the lockup.

>           This is a fundamental issue of the locking without priority
> inheritance and other real time techniques.

That is nothing but an evidence that you are refusing to solve the possibility
of lockup, and will keep piling up stupid lockup bugs. OOM handling does not
use locks when waiting for somebody else to make progress. Blaming "the locking
without priority inheritance" is wrong.

Each subsystem is responsible for avoiding the lockup. If one subsystem is
triggering lockup due to printk() flooding, that subsystem avoids the lockup
by stop abusing CPU resources by reducing the printk() messages. That's all
we can do for now. MM is not privileged enough to lockup the system.

> 
> > Nacked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> OK, if your whole point is to block any changes into this area unless
> it is your solution to be merged then I guess I will just push patches
> through with your explicit Nack on them. Your feedback was far fetched
> at many times has distracted the discussion way too often. This is
> especially sad because your testing and review was really helpful at
> times. I do not really have energy to argue the same set of arguments
> over and over again.
> 
> You have expressed unwillingness to understand the overall
> picture several times. You do not care about a long term maintenance
> burden of this code which is quite tricky already and refuse to
> understand the cost/benefit part.
> 
> If this series works for the workload reported by David I will simply
> push it through and let Andrew decide.

I'm skeptic about this approach. Given that exit_mmap() has to do more
things than what the OOM reaper kernel thread can do, how likely the OOM
reaper kernel thread can find that exit_mmap() has completed both
fullset of unmap_vmas() and __unlink_vmas() within (at most) one second
after the OOM reaper completed only subset of unmap_vmas() ? If exit_mmap()
was preempted (due to scheduling priority), the OOM reaper might likely fail
to find it. Anyway, if you insist this approach, I expect that exit_mmap()
asks the OOM reaper kernel thread to call __free_pgtables(), and the OOM
reaper kernel thread sets MMF_OOM_SKIP, and exit_mmap() resumes remove_vma()
etc. , for the OOM reaper kernel thread ("has normal priority" and "can run
on any CPU") is more reliable than a random thread ("has idle priority" and
"can run on only limited CPU").

Given that the OOM reaper likely can find it, there are lack of reviews from
each arch maintainers (regarding whether this approach is really safe, and
whether this approach constrains future improvements).

>                                        If there is a lack of feedback
> I will just keep it around because it seems that most users do not care
> about these corner cases anyway.

No way. We are always failing to get attention regarding OOM handling.  ;-)

Even how to avoid flooding by

    dump_header(oc, NULL);
    pr_warn("Out of memory and no killable processes...\n");

for memcg OOM is failing to make progress.

People make changes without thinking about OOM handling.
If you push this approach, solve the lack of reviews.
