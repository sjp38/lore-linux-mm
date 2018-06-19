Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 71E806B0003
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 04:47:44 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d6-v6so8772557plo.15
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 01:47:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l13-v6si14052040pgf.629.2018.06.19.01.47.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jun 2018 01:47:42 -0700 (PDT)
Date: Tue, 19 Jun 2018 10:47:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180619084738.GC13685@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
 <20180618172733.39322643725b196ff4e64703@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180618172733.39322643725b196ff4e64703@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 18-06-18 17:27:33, Andrew Morton wrote:
> On Thu, 14 Jun 2018 13:42:59 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
> > The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> > it cannot reap an mm.  This can happen for a variety of reasons,
> > including:
> > 
> >  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> > 
> >  - when the mm has blockable mmu notifiers that could cause the oom reaper
> >    to stall indefinitely,
> 
> Maybe we should have more than one oom reaper thread?  I assume the
> probability of the oom reaper thread blocking on an mmu notifier is
> small, so perhaps just dive in and hope for the best.  If the oom
> reaper gets stuck then there's another thread ready to take over.  And
> revisit the decision to use a kernel thread instead of workqueues.

Well, I think that having more threads would be wasteful for a rare
event like the oom. Creating one on demand could be tricky because we
are under strong memory pressure at the time and a new thread costs some
resoures.

> > but we can also add a third when the oom reaper can "reap" an mm but doing
> > so is unlikely to free any amount of memory:
> > 
> >  - when the mm's memory is fully mlocked.
> > 
> > When all memory is mlocked, the oom reaper will not be able to free any
> > substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> > unmap and free its memory in exit_mmap() and subsequent oom victims are
> > chosen unnecessarily.  This is trivial to reproduce if all eligible
> > processes on the system have mlocked their memory: the oom killer calls
> > panic() even though forward progress can be made.
> > 
> > This is the same issue where the exit path sets MMF_OOM_SKIP before
> > unmapping memory and additional processes can be chosen unnecessarily
> > because the oom killer is racing with exit_mmap().
> 
> So what's actually happening here.  A process has a large amount of
> mlocked memory, it has been oom-killed and it is in the process of
> releasing its memory and exiting, yes?
> 
> If so, why does this task set MMF_OOM_SKIP on itself?  Why aren't we
> just patiently waiting for its attempt to release meory?

Because the oom victim has no guarantee to proceed to exit and release
its own memory. OOM reaper jumps in and skip over mlocked ranges because
they require lock page and that egain cannot be taken from the oom
reaper path (the lock might be held and doing an allocation). This in
turn means that the oom_reaper doesn't free mlocked memory before it
sets MMF_OOM_SKIP which will allow a new oom victim to be selected.
At the time we merged the oom reaper this hasn't been seen as a major
issue because tasks usually do not consume a lot of mlocked memory and
there is always some other memory to tear down and help to relief the
memory pressure. mlockall oom victim were deemed unlikely because they
need a large rlimit and as such it should be trusted and therefore quite
safe from runaways. But there was definitely a plan to make mlocked
memory reapable. So time to do it finally.

> > We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> > a true oom livelock in progress, it never gets set and no additional
> > killing is possible.
> 
> I guess that's my answer.  What causes this livelock?  Process looping
> in alloc_pages while holding a lock the oom victim wants?

Yes.

> > To fix this, this patch introduces a per-mm reaping timeout, initially set
> > at 10s.  It requires that the oom reaper's list becomes a properly linked
> > list so that other mm's may be reaped while waiting for an mm's timeout to
> > expire.
> > 
> > This replaces the current timeouts in the oom reaper: (1) when trying to
> > grab mm->mmap_sem 10 times in a row with HZ/10 sleeps in between and (2)
> > a HZ sleep if there are blockable mmu notifiers.  It extends it with
> > timeout to allow an oom victim to reach exit_mmap() before choosing
> > additional processes unnecessarily.
> > 
> > The exit path will now set MMF_OOM_SKIP only after all memory has been
> > freed, so additional oom killing is justified,
> 
> That seems sensible, but why set MMF_OOM_SKIP at all?

MMF_OOM_SKIP is a way to say that the task should be skipped from OOM
victims evaluation.

> > and rely on MMF_UNSTABLE to
> > determine when it can race with the oom reaper.
> > 
> > The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> > lapsed because it can no longer guarantee forward progress.
> > 
> > The reaping timeout is intentionally set for a substantial amount of time
> > since oom livelock is a very rare occurrence and it's better to optimize
> > for preventing additional (unnecessary) oom killing than a scenario that
> > is much more unlikely.
> 
> What happened to the old idea of permitting the task which is blocking
> the oom victim to access additional reserves?

How do you find such a task?

> Come to that, what happened to the really really old Andreaidea of not
> looping in the page allocator anyway?  Return NULL instead...

Nacked by Linus because too-small-to-fail is a long term semantic that
cannot change easily. We do not have any way to audit syscall paths to
not return ENOMEM when inappropriate.

> I dunno, I'm thrashing around here.  We seem to be piling mess on top
> of mess and then being surprised that the result is a mess.

Are we? The current oom_reaper certainly has some shortcomings that
are addressable. We have started simple to cover most cases and move
on with more complex heuristics based on real life bug reports. But we
_do_ have a quite straightforward feedback based algorithm to reclaim
oom victims. This is a solid ground for future development. Something we
never had before. So I am really wondering what is all the mess about.

-- 
Michal Hocko
SUSE Labs
