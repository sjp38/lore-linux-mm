Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1ED6B000C
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 03:24:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f5-v6so1463306plf.18
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 00:24:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u24-v6si5263037pgk.72.2018.07.05.00.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 00:24:11 -0700 (PDT)
Date: Thu, 5 Jul 2018 09:24:09 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180705071740.GC32658@dhcp22.suse.cz>
References: <20180704071632.GB22503@dhcp22.suse.cz>
 <20180704072228.GC22503@dhcp22.suse.cz>
 <201807050305.w653594Q081552@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201807050305.w653594Q081552@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Thu 05-07-18 12:05:09, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > You are removing the oom_reaper and moving the oom victim tear down to
> > > > > the oom path.
> > > 
> > > Yes. This is for getting rid of the lie
> > > 
> > > 	/*
> > > 	 * Acquire the oom lock.  If that fails, somebody else is
> > > 	 * making progress for us.
> > > 	 */
> > > 	if (!mutex_trylock(&oom_lock)) {
> > > 		*did_some_progress = 1;
> > > 		schedule_timeout_uninterruptible(1);
> > > 		return NULL;
> > > 	}
> > > 
> > > which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
> > > we can eliminate this heuristic.
> > > 
> > > Of course, we don't have to remove the OOM reaper kernel thread.
> > 
> > The thing is that the current design uses the oom_reaper only as a
> > backup to get situation unstuck. Once you move all that heavy lifting
> > into the oom path directly then you will have to handle all sorts of
> > issues. E.g. how do you handle that a random process hitting OOM path
> > has to pay the full price to tear down multi TB process? This is a lot
> > of time.
> 
> We can add a threshold to unmap_page_range() (for direct OOM reaping threads)
> which aborts after given number of pages are reclaimed. There is no need to
> reclaim all pages at once if the caller is doing memory allocations. 

Yes, there is no need to reclaim all pages. OOM is after freeing _some_
memory after all. But that means further complications down the unmap
path. I do not really see any reason for that.

> But isn't "direct reclaim" already paying the full price (including being
> blocked at unkillable locks inside shrinkers etc.), huh? If "direct reclaim"
> did not exist, we would not have suffered this problem from the beginning. ;-)

No, direct reclaim is a way to throttle allocations to the reclaim
speed. You would have to achive the same by other means.

> > And one more thing. Your current design doesn't solve any of the current
> > shortcomings. mlocked pages are still not reclaimable from the direct
> > oom tear down. Blockable mmu notifiers still prevent the direct tear
> > down. So the only thing that you achieve with a large and disruptive
> > patch is that the exit vs. oom locking protocol got simplified and that
> > you can handle oom domains from tasks belonging to them. This is not bad
> > but it has its own downsides which either fail to see or reluctant to
> > describe and explain.
> 
> What this patchset is trying to do is "do not sleep (except cond_resched()
> and PREEMPT) with oom_lock held". In other words, "sleeping with oom_lock
> held (or at least, holding oom_lock more than needed)" is one of the current
> shortcomings.
> 
> Handling mlocked/shared pages and blockable mmu notifieres are a different
> story.

Yes, and yet those are the only reason why some cases are not handled
with the current approach which you are trying to replace completely.
So you replace one set of corner cases with another while you do not
really solve reapability of the above. This doesn't sounds like an
improvement to me.

> > > But the OOM
> > > killer path knows better than the OOM reaper path regarding which domains need
> > > to be reclaimed faster than other domains.
> > 
> > How can it tell any priority?
> 
> I didn't catch what your question is.
> Allowing direct OOM reaping itself reflects the priority.

I guess I've misunderstood. I thought you were talking about
prioritization of the task ripping. I guess I see your point now. You
are pointint to oom_unkillable_task check before tearing down the
victim. That would indeed help when we have too many memcg ooms
happening in parallel. But it is something that your design has
introduced. If you kept the async tear down you do not really care
because you would rely on victims cleaning up after them selves in the
vast majority of cases and async is there only to handle potential
lockups.

> > > > >               To handle cases where we cannot get mmap_sem to do that
> > > > > work you simply decay oom_badness over time if there are no changes in
> > > > > the victims oom score.
> > > 
> > > Yes. It is a feedback based approach which handles not only unable to get
> > > mmap_sem case but also already started free_pgtables()/remove_vma() case.
> > > 
> > > However, you are not understanding [PATCH 3/8] correctly. It IS A FEEDBACK
> > > BASED APPROACH which corresponds to
> > > 
> > > 	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
> > > 		schedule_timeout_idle(HZ/10);
> > > 
> > > in current code (though the timeout is different from current code).
> > 
> > Yes the timeout is different. The current solution is based on the retry
> > loops while you are proposing a fuzzy amount of retries scheme. You can
> > retry much more times if they happen often and there is _some_ change in
> > the oom_score. I am not yet convinced that the oom_score based back off
> > is a good idea. If you wanted to give some comparable results you could
> > easily implement it on top of the current oom_reaper and argue with some
> > numbers.
> 
> The oom_score based back off is mitigation for giving up too early due to
> mmap_sem held for write and/or mlocked/shared pages and/or blockable mmu
> notifiers. When we became possible to reclaim all pages, such back off will
> be removed.

So why don't we fix those first and then try to rewrite the whole thing if
that is not sufficient?

> > > If oom_reap_task_mm()
> > > for one OOM domain takes e.g. one minute when there are OOM victims in multiple OOM
> > > domains, we will needlessly block another OOM domain where allocating threads are
> > > wasting CPU resources due to the lie mentioned above.
> > 
> > Not at all. This would only happen when oom victims from other domains
> > are stuck not able to make forward progress. Is this something to
> > optimize the behavior for?
> 
> Yes, I consider that this is something to optimize the behavior for.

The proper design should focus on the standard case while covering
corner cases as much as possible. Doing that other way around risks that
you over complicate the design with hard to evaluate side effects.
 
> Current code is forcing memcg OOM killer waiting at mutex_lock(&oom_lock) to pay
> the full price to tear down an OOM victim process (which might be a multi TB process)
> because exit_mmap()/oom_reap_task_mm() are calling __oom_reap_task_mm(mm) with
> oom_lock held. The OOM victim which exit_mmap()/oom_reap_task_mm() is tearing
> down is not always in the same OOM domain mutex_lock(&oom_lock) is waiting for.

You are (yet again) ignoring many details and making incorrect
claims. For once, if somebody is reclaiming memory then those other
allocation paths can make forward progress and as such they do not
really have to wait for the full tear down. See the difference from the
sync oom reaping when at least one task will have to pay the full price?
 
[...]
> > > We could make oom_lock a spinlock (or "mutex_lock(&oom_lock); preempt_disable();"
> > > and "preempt_enable(); mutex_unlock(&oom_lock);") but there is no perfect answer
> > > for whether we should do so.
> > 
> > But there is a good example, why we shouldn't do that. Crawling over the
> > task list can take a long time. And you definitely do not want to stall
> > even more for PREEMPT kernels.
> 
> I didn't catch what "do that" is referring to. Did you say
> 
>   But there is a good example, why we shouldn't make oom_lock a spinlock (or
>   "mutex_lock(&oom_lock); preempt_disable();" and "preempt_enable();
>   mutex_unlock(&oom_lock);").
> 
> ? Then, [PATCH 2/8] will avoid needlessly crawling over the task list and
> [PATCH 7/8] will reduce needlessly blocking other threads waiting for oom_lock,
> which are appropriate changes for that guideline. And please stop complaining
> about PREEMPT kernels (i.e. your "It might help with !PREEMPT but still doesn't
> solve any problem." in response to [PATCH 1/8]). Again, "sleeping with oom_lock
> held (or at least, holding oom_lock more than needed)" is one of the current
> shortcomings.

You are like a broken record. I have said that we do not have to sleep
while holding the lock several times already. You would still have to
crawl all tasks in case you have to select a victim and that is a no-no
for preempt disable.
 
> > > > > You fail to explain why is this approach more appropriate and how you
> > > > > have settled with your current tuning with 3s timeout etc...
> > > > > 
> > > > > Considering how subtle this whole area is I am not overly happy about
> > > > > another rewrite without a really strong reasoning behind. There is none
> > > > > here, unfortunately. Well, except for statements how I reject something
> > > > > without telling the whole story etc...
> > > 
> > > However, you are not understanding [PATCH 1/8] correctly. You are simply
> > > refusing my patch instead of proving that removing the short sleep _is_ safe.
> > > Since you don't prove it, I won't remove the short sleep until [PATCH 8/8].
> > 
> > No, you are misunderstanding my point. Do not fiddle with the code you
> > are not willing to understand. The whole sleeping has been done
> > optimistically in the oom path. Removing it perfectly reasonable with
> > the current code. We do have preemption points in the reclaim path. If
> > they are not sufficient then this is another story. But no sane design
> > relies on random sleeps in the OOM path which is probably the most cold
> > path in the kernel.
> 
> I split into [PATCH 1/8] and [PATCH 8/8] so that we can revert [PATCH 8/8] part
> in case it turns out that removing the short sleep affects negatively.

And again, if you read what I wrote and tried to think about it for a
while you would understand that reverting that would be a wrong
approach. I am not going to repeat myself again and again. Go and try to
reread and ask if something is not clear.

> You are still not proving that combining [PATCH 1/8] and [PATCH 8/8] is safe.
> Note that "reasonable" and "safe" are different things. We are prone to make
> failures which sounded "reasonable" but were not "safe" (e.g. commit
> 212925802454672e "mm: oom: let oom_reap_task and exit_mmap run concurrently").

We will always fail like that if the design is not clear. And random
sleeps at random places just because we have been doing that for some
time is not a design. It's a mess. And we have been piling that mess in
the oom path for years to tune for very specific workloads. It's time to
stop that finally! If you have an overloaded page allocator you simply
do not depend on a random sleep in the oom path. Full stop. If that is
not clear to you, we have not much to talk about.
-- 
Michal Hocko
SUSE Labs
