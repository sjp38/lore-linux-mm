Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 801276B000D
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 01:56:47 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a22-v6so4200801eds.13
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 22:56:47 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z20-v6si5882708edr.56.2018.07.05.22.56.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 22:56:46 -0700 (PDT)
Date: Fri, 6 Jul 2018 07:56:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180706055644.GG32658@dhcp22.suse.cz>
References: <201807050305.w653594Q081552@www262.sakura.ne.jp>
 <20180705071740.GC32658@dhcp22.suse.cz>
 <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, rientjes@google.com

On Fri 06-07-18 11:40:07, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Thu 05-07-18 12:05:09, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > > > > You are removing the oom_reaper and moving the oom victim tear down to
> > > > > > > the oom path.
> > > > > 
> > > > > Yes. This is for getting rid of the lie
> > > > > 
> > > > > 	/*
> > > > > 	 * Acquire the oom lock.  If that fails, somebody else is
> > > > > 	 * making progress for us.
> > > > > 	 */
> > > > > 	if (!mutex_trylock(&oom_lock)) {
> > > > > 		*did_some_progress = 1;
> > > > > 		schedule_timeout_uninterruptible(1);
> > > > > 		return NULL;
> > > > > 	}
> > > > > 
> > > > > which is leading to CVE-2016-10723. By reclaiming from the OOM killer path,
> > > > > we can eliminate this heuristic.
> > > > > 
> > > > > Of course, we don't have to remove the OOM reaper kernel thread.
> > > > 
> > > > The thing is that the current design uses the oom_reaper only as a
> > > > backup to get situation unstuck. Once you move all that heavy lifting
> > > > into the oom path directly then you will have to handle all sorts of
> > > > issues. E.g. how do you handle that a random process hitting OOM path
> > > > has to pay the full price to tear down multi TB process? This is a lot
> > > > of time.
> > > 
> > > We can add a threshold to unmap_page_range() (for direct OOM reaping threads)
> > > which aborts after given number of pages are reclaimed. There is no need to
> > > reclaim all pages at once if the caller is doing memory allocations. 
> > 
> > Yes, there is no need to reclaim all pages. OOM is after freeing _some_
> > memory after all. But that means further complications down the unmap
> > path. I do not really see any reason for that.
> 
> "I do not see reason for that" cannot become a reason direct OOM reaping has to
> reclaim all pages at once.

We are not going to polute deep mm guts for unlikely events like oom.

[...]
> > Yes, and yet those are the only reason why some cases are not handled
> > with the current approach which you are trying to replace completely.
> > So you replace one set of corner cases with another while you do not
> > really solve reapability of the above. This doesn't sounds like an
> > improvement to me.
> 
> "This doesn't sounds like an improvement to me." cannot become a reason we
> keep [PATCH 1/8] away. Even if lockup is a corner case, it is a bug which
> has to be fixed. [PATCH 1/8] is for mitigating user-triggerable lockup.

It seems that any reasonable discussion with you is impossible. If you
are going to insist then you will not move any further with that patch.
CVE or not. I do not really care because that CVE is dubious at best.
There is a really simply way out of this situation. Just drop the sleep
from the the oom path and be done with it. If you are afraid of
regression and do not want to have your name on the patch then fine. I
will post the patch myself and also handle any fallouts.
 
[...]
> > The proper design should focus on the standard case while covering
> > corner cases as much as possible. Doing that other way around risks that
> > you over complicate the design with hard to evaluate side effects.
> 
> Your "proper design" is broken because you completely ignore corner cases.

I am very much interested in corner cases and you haven't given any
relevant argument that would show the current approach is broken. It
doesn't handle certain class of mappings, alright. Mlocked memory is
limited to a small value by default and you really have to trust your
userspace to raise a limit for it. Blockable notifiers are a real pain
as well but there is a patch to reduce the impact posted already [1].
I plan to work on mlock as well. Neither of the two has been handled by
your new rewrite.

> You don't think user-triggerable DoS as a problem.

I do care, of course. I am just saying that you are over exaggerating
the whole thing. Once you trigger a workload where some amount of
tasks can easily make other tasks not runable for a long time just
because it slept for a while then you are screwed anyway. This can be
any other sleep holding any other lock in the kernel.

Yes, it sucks that this is possible and you really have to be careful
when running untrusted code on your system.

[1] http://lkml.kernel.org/r/20180627074421.GF32348@dhcp22.suse.cz
 
> > > Current code is forcing memcg OOM killer waiting at mutex_lock(&oom_lock) to pay
> > > the full price to tear down an OOM victim process (which might be a multi TB process)
> > > because exit_mmap()/oom_reap_task_mm() are calling __oom_reap_task_mm(mm) with
> > > oom_lock held. The OOM victim which exit_mmap()/oom_reap_task_mm() is tearing
> > > down is not always in the same OOM domain mutex_lock(&oom_lock) is waiting for.
> > 
> > You are (yet again) ignoring many details and making incorrect
> > claims. For once, if somebody is reclaiming memory then those other
> > allocation paths can make forward progress and as such they do not
> > really have to wait for the full tear down. See the difference from the
> > sync oom reaping when at least one task will have to pay the full price?
> 
> For __alloc_pages_may_oom() path which is currently using mutex_trylock(), you are
> right except that nobody can reclaim memory due to schedule_timeout_killable(1)
> with oom_lock held.
> 
> For other paths which are currently using mutex_lock(), you are ignoring what
> I'm saying. A memcg-OOM event is paying the full price for tearing down an OOM
> victim which is in a different memcg domain.

Yes, this is possible. And do we have any real life example where that
is a noticeable problem?

Skipping the rest because it is repeating already discussed and
explained points. I am tired of repeating same things over and over for
you just to ignore that.
[...]

-- 
Michal Hocko
SUSE Labs
