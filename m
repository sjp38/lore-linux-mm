Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0056B000A
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 22:23:04 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id y20-v6so2662996otk.19
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 19:23:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i9-v6si918705ote.96.2018.07.03.19.23.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 19:23:02 -0700 (PDT)
Message-Id: <201807040222.w642Mtlr099513@www262.sakura.ne.jp>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
From: penguin-kernel@i-love.sakura.ne.jp
MIME-Version: 1.0
Date: Wed, 04 Jul 2018 11:22:55 +0900
References: <20180703151223.GP16767@dhcp22.suse.cz> <20180703152922.GR16767@dhcp22.suse.cz>
In-Reply-To: <20180703152922.GR16767@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> > On Tue 03-07-18 23:25:01, Tetsuo Handa wrote:
> > > This series provides
> > > 
> > >   (1) Mitigation and a fix for CVE-2016-10723.
> > > 
> > >   (2) A mitigation for needlessly selecting next OOM victim reported
> > >       by David Rientjes and rejected by Michal Hocko.
> > > 
> > >   (3) A preparation for handling many concurrent OOM victims which
> > >       could become real by introducing memcg-aware OOM killer.
> > 
> > It would have been great to describe the overal design in the cover
> > letter. So let me summarize just to be sure I understand the proposal.

You understood the proposal correctly.

> > You are removing the oom_reaper and moving the oom victim tear down to
> > the oom path.

Yes. This is for getting rid of the lie

	/*
	 * Acquire the oom lock.  If that fails, somebody else is
	 * making progress for us.
	 */
	if (!mutex_trylock(&oom_lock)) {
		*did_some_progress = 1;
		schedule_timeout_uninterruptible(1);
		return NULL;
	}

which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
we can eliminate this heuristic.

Of course, we don't have to remove the OOM reaper kernel thread. But the OOM
killer path knows better than the OOM reaper path regarding which domains need
to be reclaimed faster than other domains.

> >               To handle cases where we cannot get mmap_sem to do that
> > work you simply decay oom_badness over time if there are no changes in
> > the victims oom score.

Yes. It is a feedback based approach which handles not only unable to get
mmap_sem case but also already started free_pgtables()/remove_vma() case.

However, you are not understanding [PATCH 3/8] correctly. It IS A FEEDBACK
BASED APPROACH which corresponds to

	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
		schedule_timeout_idle(HZ/10);

in current code (though the timeout is different from current code).

> 
> Correction. You do not decay oom_badness. You simply increase a stall
> counter anytime oom_badness hasn't changed since the last check (if that
> check happend at least HZ/10 ago) and get the victim out of sight if the
> counter is larger than 30. This is where 3s are coming from. So in fact
> this is the low boundary while it might be considerably larger depending
> on how often we examine the victim.

Yes, it can become larger. But if we don't need to examine the OOM victim, it means
that we are not OOM. We need to examine the OOM victim only if we are still OOM.
(If we are no longer OOM, the OOM victim will disappear via exit_oom_mm() before
the counter reaches 30.)

Note that neither current

#define MAX_OOM_REAP_RETRIES 10

	/* Retry the down_read_trylock(mmap_sem) a few times */
	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
		schedule_timeout_idle(HZ/10);

code guarantees that the OOM reaper will give up in 1 second. If oom_reap_task_mm()
for one OOM domain takes e.g. one minute when there are OOM victims in multiple OOM
domains, we will needlessly block another OOM domain where allocating threads are
wasting CPU resources due to the lie mentioned above.

By allowing allocating threads to do direct OOM reaping, we won't needlessly block
allocating threads and we can eliminate the lie mentioned above.

> 
> >                        In order to not block in the oom context for too
> > long because the address space might be quite large, you allow to
> > direct oom reap from multiple contexts.

Yes. Since the thread which acquired the oom_lock can be SCHED_IDLE priority,
this patch is trying to speed up direct OOM reaping by allowing other threads
who acquired the oom_lock with !SCHED_IDLE priority. Thus, [PATCH 7/8] tries to
reduce the duration of holding the oom_lock, by releasing the oom_lock before
doing direct OOM reaping.

We could make oom_lock a spinlock (or "mutex_lock(&oom_lock); preempt_disable();"
and "preempt_enable(); mutex_unlock(&oom_lock);") but there is no perfect answer
for whether we should do so.

> > 
> > You fail to explain why is this approach more appropriate and how you
> > have settled with your current tuning with 3s timeout etc...
> > 
> > Considering how subtle this whole area is I am not overly happy about
> > another rewrite without a really strong reasoning behind. There is none
> > here, unfortunately. Well, except for statements how I reject something
> > without telling the whole story etc...

However, you are not understanding [PATCH 1/8] correctly. You are simply
refusing my patch instead of proving that removing the short sleep _is_ safe.
Since you don't prove it, I won't remove the short sleep until [PATCH 8/8].

In the kernel space, not yielding enough CPU resources for other threads to
make forward progress is a BUG. You learned it with warn_alloc() for allocation
stall reporting, didn't you?
