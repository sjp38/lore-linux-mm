Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBFA8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 10:07:06 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so6039718edq.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 07:07:06 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b7si4003353edy.138.2019.01.11.07.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 07:07:04 -0800 (PST)
Date: Fri, 11 Jan 2019 16:07:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
Message-ID: <20190111150703.GI14956@dhcp22.suse.cz>
References: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
 <20190109120212.GT31793@dhcp22.suse.cz>
 <201901102359.x0ANxIbn020225@www262.sakura.ne.jp>
 <fbdfdfeb-5664-ddf3-4d65-c64f9851ac26@i-love.sakura.ne.jp>
 <20190111113354.GD14956@dhcp22.suse.cz>
 <0d67b389-91e2-18ab-b596-39361b895c89@i-love.sakura.ne.jp>
 <20190111133401.GA6997@dhcp22.suse.cz>
 <d9f7b139-d51b-93ae-b5ad-856fd9f2c168@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d9f7b139-d51b-93ae-b5ad-856fd9f2c168@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 11-01-19 23:31:18, Tetsuo Handa wrote:
> On 2019/01/11 22:34, Michal Hocko wrote:
> > On Fri 11-01-19 21:40:52, Tetsuo Handa wrote:
> > [...]
> >> Did you notice that there is no
> >>
> >>   "Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n"
> >>
> >> line between
> >>
> >>   [   71.304703][ T9694] Memory cgroup out of memory: Kill process 9692 (a.out) score 904 or sacrifice child
> >>
> >> and
> >>
> >>   [   71.309149][   T54] oom_reaper: reaped process 9750 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:185532kB
> >>
> >> ? Then, you will find that [ T9694] failed to reach for_each_process(p) loop inside
> >> __oom_kill_process() in the first round of out_of_memory() call because
> >> find_lock_task_mm() == NULL at __oom_kill_process() because Ctrl-C made that victim
> >> complete exit_mm() before find_lock_task_mm() is called.
> > 
> > OK, so we haven't killed anything because the victim has exited by the
> > time we wanted to do so. We still have other tasks sharing that mm
> > pending and not killed because nothing has killed them yet, right?
> 
> The OOM killer invoked by [ T9694] called printk() but didn't kill anything.
> Instead, SIGINT from Ctrl-C killed all thread groups sharing current->mm.

I still do not get it. Those other processes are not sharing signals.
Or is it due to injecting the signal too all of them with the proper
timing?
 
> > How come the oom reaper could act on this oom event at all then?
> > 
> > What am I missing?
> > 
> 
> The OOM killer invoked by [ T9750] did not call printk() but hit
> task_will_free_mem(current) in out_of_memory() and invoked the OOM reaper,
> without calling mark_oom_victim() on all thread groups sharing current->mm.
> Did you notice that I wrote that

OK, now it starts making sense to me finally. I got hooked up in
find_lock_task_mm failing in __oom_kill_process because we do see 
"Memory cgroup out of memory" and that happens _after_
task_will_free_mem. So the whole oom_reaper scenario didn't make much
sense to me.

>   Since mm-oom-marks-all-killed-tasks-as-oom-victims.patch does not call mark_oom_victim()
>   when task_will_free_mem() == true,
> 
> ? :-(

No, I got lost in your writeup.

While the task_will_free_mem is fixable but this would get us to even
uglier code so I agree that the approach by my two patches is not
feasible.

I really wanted to have this heuristic based on the oom victim rather
than signal pending because one lesson I've learned over time was that
checks for fatal signals can lead to odd corner cases. Memcg is less
prone to those issues because we can bypass the charge but still.

Anyway, could you update your patch and abstract 
	if (unlikely(tsk_is_oom_victim(current) ||
		     fatal_signal_pending(current) ||
		     current->flags & PF_EXITING))

in try_charge and reuse it in mem_cgroup_out_of_memory under the
oom_lock with an explanation please?

Andrew, please drop my 2 patches please.
                           
-- 
Michal Hocko
SUSE Labs
