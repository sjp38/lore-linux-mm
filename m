Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB7536B0005
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 23:05:18 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k13-v6so4419832ite.5
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 20:05:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c14-v6si3189685jaf.80.2018.07.04.20.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 20:05:15 -0700 (PDT)
Message-Id: <201807050305.w653594Q081552@www262.sakura.ne.jp>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 05 Jul 2018 12:05:09 +0900
References: <20180704071632.GB22503@dhcp22.suse.cz> <20180704072228.GC22503@dhcp22.suse.cz>
In-Reply-To: <20180704072228.GC22503@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> > > > You are removing the oom_reaper and moving the oom victim tear down to
> > > > the oom path.
> > 
> > Yes. This is for getting rid of the lie
> > 
> > 	/*
> > 	 * Acquire the oom lock.  If that fails, somebody else is
> > 	 * making progress for us.
> > 	 */
> > 	if (!mutex_trylock(&oom_lock)) {
> > 		*did_some_progress = 1;
> > 		schedule_timeout_uninterruptible(1);
> > 		return NULL;
> > 	}
> > 
> > which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
> > we can eliminate this heuristic.
> > 
> > Of course, we don't have to remove the OOM reaper kernel thread.
> 
> The thing is that the current design uses the oom_reaper only as a
> backup to get situation unstuck. Once you move all that heavy lifting
> into the oom path directly then you will have to handle all sorts of
> issues. E.g. how do you handle that a random process hitting OOM path
> has to pay the full price to tear down multi TB process? This is a lot
> of time.

We can add a threshold to unmap_page_range() (for direct OOM reaping threads)
which aborts after given number of pages are reclaimed. There is no need to
reclaim all pages at once if the caller is doing memory allocations.

But isn't "direct reclaim" already paying the full price (including being
blocked at unkillable locks inside shrinkers etc.), huh? If "direct reclaim"
did not exist, we would not have suffered this problem from the beginning. ;-)

> 
> And one more thing. Your current design doesn't solve any of the current
> shortcomings. mlocked pages are still not reclaimable from the direct
> oom tear down. Blockable mmu notifiers still prevent the direct tear
> down. So the only thing that you achieve with a large and disruptive
> patch is that the exit vs. oom locking protocol got simplified and that
> you can handle oom domains from tasks belonging to them. This is not bad
> but it has its own downsides which either fail to see or reluctant to
> describe and explain.

What this patchset is trying to do is "do not sleep (except cond_resched()
and PREEMPT) with oom_lock held". In other words, "sleeping with oom_lock
held (or at least, holding oom_lock more than needed)" is one of the current
shortcomings.

Handling mlocked/shared pages and blockable mmu notifieres are a different
story.

> 
> > But the OOM
> > killer path knows better than the OOM reaper path regarding which domains need
> > to be reclaimed faster than other domains.
> 
> How can it tell any priority?

I didn't catch what your question is.
Allowing direct OOM reaping itself reflects the priority.

> 
> > > >               To handle cases where we cannot get mmap_sem to do that
> > > > work you simply decay oom_badness over time if there are no changes in
> > > > the victims oom score.
> > 
> > Yes. It is a feedback based approach which handles not only unable to get
> > mmap_sem case but also already started free_pgtables()/remove_vma() case.
> > 
> > However, you are not understanding [PATCH 3/8] correctly. It IS A FEEDBACK
> > BASED APPROACH which corresponds to
> > 
> > 	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
> > 		schedule_timeout_idle(HZ/10);
> > 
> > in current code (though the timeout is different from current code).
> 
> Yes the timeout is different. The current solution is based on the retry
> loops while you are proposing a fuzzy amount of retries scheme. You can
> retry much more times if they happen often and there is _some_ change in
> the oom_score. I am not yet convinced that the oom_score based back off
> is a good idea. If you wanted to give some comparable results you could
> easily implement it on top of the current oom_reaper and argue with some
> numbers.

The oom_score based back off is mitigation for giving up too early due to
mmap_sem held for write and/or mlocked/shared pages and/or blockable mmu
notifiers. When we became possible to reclaim all pages, such back off will
be removed.

> > If oom_reap_task_mm()
> > for one OOM domain takes e.g. one minute when there are OOM victims in multiple OOM
> > domains, we will needlessly block another OOM domain where allocating threads are
> > wasting CPU resources due to the lie mentioned above.
> 
> Not at all. This would only happen when oom victims from other domains
> are stuck not able to make forward progress. Is this something to
> optimize the behavior for?

Yes, I consider that this is something to optimize the behavior for.

Current code is forcing memcg OOM killer waiting at mutex_lock(&oom_lock) to pay
the full price to tear down an OOM victim process (which might be a multi TB process)
because exit_mmap()/oom_reap_task_mm() are calling __oom_reap_task_mm(mm) with
oom_lock held. The OOM victim which exit_mmap()/oom_reap_task_mm() is tearing
down is not always in the same OOM domain mutex_lock(&oom_lock) is waiting for.

There is no need to hold oom_lock when calling __oom_reap_task_mm(mm).
Holding oom_lock helps "serializing printk() messages from the OOM killer" and
"avoid selecting new OOM victims when there are already OOM victims which current
thread should wait for". Holding oom_lock does not help when waiting for
unmap_page_range().

> > > 
> > > >                        In order to not block in the oom context for too
> > > > long because the address space might be quite large, you allow to
> > > > direct oom reap from multiple contexts.
> > 
> > Yes. Since the thread which acquired the oom_lock can be SCHED_IDLE priority,
> > this patch is trying to speed up direct OOM reaping by allowing other threads
> > who acquired the oom_lock with !SCHED_IDLE priority. Thus, [PATCH 7/8] tries to
> > reduce the duration of holding the oom_lock, by releasing the oom_lock before
> > doing direct OOM reaping.
> > 
> > We could make oom_lock a spinlock (or "mutex_lock(&oom_lock); preempt_disable();"
> > and "preempt_enable(); mutex_unlock(&oom_lock);") but there is no perfect answer
> > for whether we should do so.
> 
> But there is a good example, why we shouldn't do that. Crawling over the
> task list can take a long time. And you definitely do not want to stall
> even more for PREEMPT kernels.

I didn't catch what "do that" is referring to. Did you say

  But there is a good example, why we shouldn't make oom_lock a spinlock (or
  "mutex_lock(&oom_lock); preempt_disable();" and "preempt_enable();
  mutex_unlock(&oom_lock);").

? Then, [PATCH 2/8] will avoid needlessly crawling over the task list and
[PATCH 7/8] will reduce needlessly blocking other threads waiting for oom_lock,
which are appropriate changes for that guideline. And please stop complaining
about PREEMPT kernels (i.e. your "It might help with !PREEMPT but still doesn't
solve any problem." in response to [PATCH 1/8]). Again, "sleeping with oom_lock
held (or at least, holding oom_lock more than needed)" is one of the current
shortcomings.

>  
> > > > You fail to explain why is this approach more appropriate and how you
> > > > have settled with your current tuning with 3s timeout etc...
> > > > 
> > > > Considering how subtle this whole area is I am not overly happy about
> > > > another rewrite without a really strong reasoning behind. There is none
> > > > here, unfortunately. Well, except for statements how I reject something
> > > > without telling the whole story etc...
> > 
> > However, you are not understanding [PATCH 1/8] correctly. You are simply
> > refusing my patch instead of proving that removing the short sleep _is_ safe.
> > Since you don't prove it, I won't remove the short sleep until [PATCH 8/8].
> 
> No, you are misunderstanding my point. Do not fiddle with the code you
> are not willing to understand. The whole sleeping has been done
> optimistically in the oom path. Removing it perfectly reasonable with
> the current code. We do have preemption points in the reclaim path. If
> they are not sufficient then this is another story. But no sane design
> relies on random sleeps in the OOM path which is probably the most cold
> path in the kernel.

I split into [PATCH 1/8] and [PATCH 8/8] so that we can revert [PATCH 8/8] part
in case it turns out that removing the short sleep affects negatively.
You are still not proving that combining [PATCH 1/8] and [PATCH 8/8] is safe.
Note that "reasonable" and "safe" are different things. We are prone to make
failures which sounded "reasonable" but were not "safe" (e.g. commit
212925802454672e "mm: oom: let oom_reap_task and exit_mmap run concurrently").
