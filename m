Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB306B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 22:40:20 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id i4-v6so2572557ite.3
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 19:40:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id o130-v6si5034188itd.15.2018.07.05.19.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 19:40:17 -0700 (PDT)
Message-Id: <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 06 Jul 2018 11:40:07 +0900
References: <201807050305.w653594Q081552@www262.sakura.ne.jp> <20180705071740.GC32658@dhcp22.suse.cz>
In-Reply-To: <20180705071740.GC32658@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, rientjes@google.com

Michal Hocko wrote:
> On Thu 05-07-18 12:05:09, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > > > You are removing the oom_reaper and moving the oom victim tear down to
> > > > > > the oom path.
> > > > 
> > > > Yes. This is for getting rid of the lie
> > > > 
> > > > 	/*
> > > > 	 * Acquire the oom lock.  If that fails, somebody else is
> > > > 	 * making progress for us.
> > > > 	 */
> > > > 	if (!mutex_trylock(&oom_lock)) {
> > > > 		*did_some_progress = 1;
> > > > 		schedule_timeout_uninterruptible(1);
> > > > 		return NULL;
> > > > 	}
> > > > 
> > > > which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
> > > > we can eliminate this heuristic.
> > > > 
> > > > Of course, we don't have to remove the OOM reaper kernel thread.
> > > 
> > > The thing is that the current design uses the oom_reaper only as a
> > > backup to get situation unstuck. Once you move all that heavy lifting
> > > into the oom path directly then you will have to handle all sorts of
> > > issues. E.g. how do you handle that a random process hitting OOM path
> > > has to pay the full price to tear down multi TB process? This is a lot
> > > of time.
> > 
> > We can add a threshold to unmap_page_range() (for direct OOM reaping threads)
> > which aborts after given number of pages are reclaimed. There is no need to
> > reclaim all pages at once if the caller is doing memory allocations. 
> 
> Yes, there is no need to reclaim all pages. OOM is after freeing _some_
> memory after all. But that means further complications down the unmap
> path. I do not really see any reason for that.

"I do not see reason for that" cannot become a reason direct OOM reaping has to
reclaim all pages at once.

> 
> > But isn't "direct reclaim" already paying the full price (including being
> > blocked at unkillable locks inside shrinkers etc.), huh? If "direct reclaim"
> > did not exist, we would not have suffered this problem from the beginning. ;-)
> 
> No, direct reclaim is a way to throttle allocations to the reclaim
> speed. You would have to achive the same by other means.

No. Direct reclaim is a way to lockup the system to unusable level, by not giving
enough CPU resources to memory reclaim activities including the owner of oom_lock.

> 
> > > And one more thing. Your current design doesn't solve any of the current
> > > shortcomings. mlocked pages are still not reclaimable from the direct
> > > oom tear down. Blockable mmu notifiers still prevent the direct tear
> > > down. So the only thing that you achieve with a large and disruptive
> > > patch is that the exit vs. oom locking protocol got simplified and that
> > > you can handle oom domains from tasks belonging to them. This is not bad
> > > but it has its own downsides which either fail to see or reluctant to
> > > describe and explain.
> > 
> > What this patchset is trying to do is "do not sleep (except cond_resched()
> > and PREEMPT) with oom_lock held". In other words, "sleeping with oom_lock
> > held (or at least, holding oom_lock more than needed)" is one of the current
> > shortcomings.
> > 
> > Handling mlocked/shared pages and blockable mmu notifieres are a different
> > story.
> 
> Yes, and yet those are the only reason why some cases are not handled
> with the current approach which you are trying to replace completely.
> So you replace one set of corner cases with another while you do not
> really solve reapability of the above. This doesn't sounds like an
> improvement to me.

"This doesn't sounds like an improvement to me." cannot become a reason we
keep [PATCH 1/8] away. Even if lockup is a corner case, it is a bug which
has to be fixed. [PATCH 1/8] is for mitigating user-triggerable lockup.

> 
> > > > But the OOM
> > > > killer path knows better than the OOM reaper path regarding which domains need
> > > > to be reclaimed faster than other domains.
> > > 
> > > How can it tell any priority?
> > 
> > I didn't catch what your question is.
> > Allowing direct OOM reaping itself reflects the priority.
> 
> I guess I've misunderstood. I thought you were talking about
> prioritization of the task ripping. I guess I see your point now. You
> are pointint to oom_unkillable_task check before tearing down the
> victim. That would indeed help when we have too many memcg ooms
> happening in parallel. But it is something that your design has
> introduced. If you kept the async tear down you do not really care
> because you would rely on victims cleaning up after them selves in the
> vast majority of cases and async is there only to handle potential
> lockups.

Vast majority of OOM victims will tear down themselves (as long as allocating
threads give CPU resources to them). I'm fine with preserving async OOM reaping
(by the OOM reaper kernel thread). But as long as we limit number of pages direct
OOM reaping will reclaim at each attempt, it will not impact allocating threads
so much.

> 
> > > > > >               To handle cases where we cannot get mmap_sem to do that
> > > > > > work you simply decay oom_badness over time if there are no changes in
> > > > > > the victims oom score.
> > > > 
> > > > Yes. It is a feedback based approach which handles not only unable to get
> > > > mmap_sem case but also already started free_pgtables()/remove_vma() case.
> > > > 
> > > > However, you are not understanding [PATCH 3/8] correctly. It IS A FEEDBACK
> > > > BASED APPROACH which corresponds to
> > > > 
> > > > 	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
> > > > 		schedule_timeout_idle(HZ/10);
> > > > 
> > > > in current code (though the timeout is different from current code).
> > > 
> > > Yes the timeout is different. The current solution is based on the retry
> > > loops while you are proposing a fuzzy amount of retries scheme. You can
> > > retry much more times if they happen often and there is _some_ change in
> > > the oom_score. I am not yet convinced that the oom_score based back off
> > > is a good idea. If you wanted to give some comparable results you could
> > > easily implement it on top of the current oom_reaper and argue with some
> > > numbers.
> > 
> > The oom_score based back off is mitigation for giving up too early due to
> > mmap_sem held for write and/or mlocked/shared pages and/or blockable mmu
> > notifiers. When we became possible to reclaim all pages, such back off will
> > be removed.
> 
> So why don't we fix those first and then try to rewrite the whole thing if
> that is not sufficient?

I'm repeating that [PATCH 1/8] needs to be applied now and backported to stable
kernels which got "mm, oom: fix concurrent munlock and oom reaper unmap, v3".

You are maliciously blocking me by demanding me to fix irrelevant things.

> 
> > > > If oom_reap_task_mm()
> > > > for one OOM domain takes e.g. one minute when there are OOM victims in multiple OOM
> > > > domains, we will needlessly block another OOM domain where allocating threads are
> > > > wasting CPU resources due to the lie mentioned above.
> > > 
> > > Not at all. This would only happen when oom victims from other domains
> > > are stuck not able to make forward progress. Is this something to
> > > optimize the behavior for?
> > 
> > Yes, I consider that this is something to optimize the behavior for.
> 
> The proper design should focus on the standard case while covering
> corner cases as much as possible. Doing that other way around risks that
> you over complicate the design with hard to evaluate side effects.

Your "proper design" is broken because you completely ignore corner cases.
You don't think user-triggerable DoS as a problem.

>  
> > Current code is forcing memcg OOM killer waiting at mutex_lock(&oom_lock) to pay
> > the full price to tear down an OOM victim process (which might be a multi TB process)
> > because exit_mmap()/oom_reap_task_mm() are calling __oom_reap_task_mm(mm) with
> > oom_lock held. The OOM victim which exit_mmap()/oom_reap_task_mm() is tearing
> > down is not always in the same OOM domain mutex_lock(&oom_lock) is waiting for.
> 
> You are (yet again) ignoring many details and making incorrect
> claims. For once, if somebody is reclaiming memory then those other
> allocation paths can make forward progress and as such they do not
> really have to wait for the full tear down. See the difference from the
> sync oom reaping when at least one task will have to pay the full price?

For __alloc_pages_may_oom() path which is currently using mutex_trylock(), you are
right except that nobody can reclaim memory due to schedule_timeout_killable(1)
with oom_lock held.

For other paths which are currently using mutex_lock(), you are ignoring what
I'm saying. A memcg-OOM event is paying the full price for tearing down an OOM
victim which is in a different memcg domain.

>  
> [...]
> > > > We could make oom_lock a spinlock (or "mutex_lock(&oom_lock); preempt_disable();"
> > > > and "preempt_enable(); mutex_unlock(&oom_lock);") but there is no perfect answer
> > > > for whether we should do so.
> > > 
> > > But there is a good example, why we shouldn't do that. Crawling over the
> > > task list can take a long time. And you definitely do not want to stall
> > > even more for PREEMPT kernels.
> > 
> > I didn't catch what "do that" is referring to. Did you say
> > 
> >   But there is a good example, why we shouldn't make oom_lock a spinlock (or
> >   "mutex_lock(&oom_lock); preempt_disable();" and "preempt_enable();
> >   mutex_unlock(&oom_lock);").
> > 
> > ? Then, [PATCH 2/8] will avoid needlessly crawling over the task list and
> > [PATCH 7/8] will reduce needlessly blocking other threads waiting for oom_lock,
> > which are appropriate changes for that guideline. And please stop complaining
> > about PREEMPT kernels (i.e. your "It might help with !PREEMPT but still doesn't
> > solve any problem." in response to [PATCH 1/8]). Again, "sleeping with oom_lock
> > held (or at least, holding oom_lock more than needed)" is one of the current
> > shortcomings.
> 
> You are like a broken record. I have said that we do not have to sleep
> while holding the lock several times already. You would still have to
> crawl all tasks in case you have to select a victim and that is a no-no
> for preempt disable.

We know we have to crawl all tasks when we have to select a new OOM victim.
Since that might take a long time, [PATCH 2/8] can reduce number of tasks when
the allocating threads can wait for OOM victims.

But I still cannot catch what you are saying. You are saying that we should not
disable preemption while crawling all tasks in order to select a new OOM victim,
aren't you? Then, why are you complaining that "It might help with !PREEMPT but
still doesn't solve any problem." ? Are you saying that we should disable
preemption while crawling all tasks in order to select a new OOM victim?

(By the way, I think we can crawl all tasks in order to select a new OOM victim
without oom_lock held, provided that we recheck with oom_lock held whether somebody
else selected an OOM victim which current thread can wait for. That will be part of
[PATCH 7/8].)

>  
> > > > > > You fail to explain why is this approach more appropriate and how you
> > > > > > have settled with your current tuning with 3s timeout etc...
> > > > > > 
> > > > > > Considering how subtle this whole area is I am not overly happy about
> > > > > > another rewrite without a really strong reasoning behind. There is none
> > > > > > here, unfortunately. Well, except for statements how I reject something
> > > > > > without telling the whole story etc...
> > > > 
> > > > However, you are not understanding [PATCH 1/8] correctly. You are simply
> > > > refusing my patch instead of proving that removing the short sleep _is_ safe.
> > > > Since you don't prove it, I won't remove the short sleep until [PATCH 8/8].
> > > 
> > > No, you are misunderstanding my point. Do not fiddle with the code you
> > > are not willing to understand. The whole sleeping has been done
> > > optimistically in the oom path. Removing it perfectly reasonable with
> > > the current code. We do have preemption points in the reclaim path. If
> > > they are not sufficient then this is another story. But no sane design
> > > relies on random sleeps in the OOM path which is probably the most cold
> > > path in the kernel.
> > 
> > I split into [PATCH 1/8] and [PATCH 8/8] so that we can revert [PATCH 8/8] part
> > in case it turns out that removing the short sleep affects negatively.
> 
> And again, if you read what I wrote and tried to think about it for a
> while you would understand that reverting that would be a wrong
> approach. I am not going to repeat myself again and again. Go and try to
> reread and ask if something is not clear.

If you believe that schedule_timeout_*() in memory allocating path is wrong,
immediately get rid of all sleeps except should_reclaim_retry(). For example,
msleep(100) in shrink_inactive_list(), congestion_wait(BLK_RW_ASYNC, HZ/50) in
do_writepages(). Unless you do that now, I won't agree with removing the short
sleep for the owner of oom_lock. Current code is not perfect enough to survive
without short sleep.

Again, you are maliciously blocking me without admitting the fact that vast
majority of OOM victims can tear down themselves only if we don't deprive OOM
victims of CPU resources. What I worry is depriving OOM victims of CPU resources
by applying [PATCH 8/8].

> 
> > You are still not proving that combining [PATCH 1/8] and [PATCH 8/8] is safe.
> > Note that "reasonable" and "safe" are different things. We are prone to make
> > failures which sounded "reasonable" but were not "safe" (e.g. commit
> > 212925802454672e "mm: oom: let oom_reap_task and exit_mmap run concurrently").
> 
> We will always fail like that if the design is not clear. And random
> sleeps at random places just because we have been doing that for some
> time is not a design. It's a mess. And we have been piling that mess in
> the oom path for years to tune for very specific workloads. It's time to
> stop that finally! If you have an overloaded page allocator you simply
> do not depend on a random sleep in the oom path. Full stop. If that is
> not clear to you, we have not much to talk about.

You can try that after [PATCH 1/8] is applied.
After all, you explained no valid reason we cannot apply [PATCH 1/8] now.
