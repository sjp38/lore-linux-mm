Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D27D36B0005
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 02:55:45 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id b12-v6so5468907wrs.10
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 23:55:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y95-v6si4852496ede.17.2018.06.14.23.55.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jun 2018 23:55:44 -0700 (PDT)
Date: Fri, 15 Jun 2018 08:55:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional processes
Message-ID: <20180615065541.GA24039@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 14-06-18 13:42:59, David Rientjes wrote:
> The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> it cannot reap an mm.  This can happen for a variety of reasons,
> including:
> 
>  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> 
>  - when the mm has blockable mmu notifiers that could cause the oom reaper
>    to stall indefinitely,
> 
> but we can also add a third when the oom reaper can "reap" an mm but doing
> so is unlikely to free any amount of memory:
> 
>  - when the mm's memory is fully mlocked.
> 
> When all memory is mlocked, the oom reaper will not be able to free any
> substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> unmap and free its memory in exit_mmap() and subsequent oom victims are
> chosen unnecessarily.  This is trivial to reproduce if all eligible
> processes on the system have mlocked their memory: the oom killer calls
> panic() even though forward progress can be made.
> 
> This is the same issue where the exit path sets MMF_OOM_SKIP before
> unmapping memory and additional processes can be chosen unnecessarily
> because the oom killer is racing with exit_mmap().
> 
> We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> a true oom livelock in progress, it never gets set and no additional
> killing is possible.
> 
> To fix this, this patch introduces a per-mm reaping timeout, initially set
> at 10s.  It requires that the oom reaper's list becomes a properly linked
> list so that other mm's may be reaped while waiting for an mm's timeout to
> expire.
> 
> This replaces the current timeouts in the oom reaper: (1) when trying to
> grab mm->mmap_sem 10 times in a row with HZ/10 sleeps in between and (2)
> a HZ sleep if there are blockable mmu notifiers.  It extends it with
> timeout to allow an oom victim to reach exit_mmap() before choosing
> additional processes unnecessarily.
> 
> The exit path will now set MMF_OOM_SKIP only after all memory has been
> freed, so additional oom killing is justified, and rely on MMF_UNSTABLE to
> determine when it can race with the oom reaper.
> 
> The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> lapsed because it can no longer guarantee forward progress.
> 
> The reaping timeout is intentionally set for a substantial amount of time
> since oom livelock is a very rare occurrence and it's better to optimize
> for preventing additional (unnecessary) oom killing than a scenario that
> is much more unlikely.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Nacked-by: Michal Hocko <mhocko@suse.com>
as already explained elsewhere in this email thread.

> ---
>  Note: I understand there is an objection based on timeout based delays.
>  This is currently the only possible way to avoid oom killing important
>  processes completely unnecessarily.  If the oom reaper can someday free
>  all memory, including mlocked memory and those mm's with blockable mmu
>  notifiers, and is guaranteed to always be able to grab mm->mmap_sem,
>  this can be removed.  I do not believe any such guarantee is possible
>  and consider the massive killing of additional processes unnecessarily
>  to be a regression introduced by the oom reaper and its very quick
>  setting of MMF_OOM_SKIP to allow additional processes to be oom killed.

If you find oom reaper more harmful than useful I would be willing to
ack a comman line option to disable it. Especially when you keep
claiming that the lockups are not really happening in your environment.

Other than that I've already pointed to a more robust solution. If you
are reluctant to try it out I will do, but introducing a timeout is just
papering over the real problem. Maybe we will not reach the state that
_all_ the memory is reapable but we definitely should try to make as
much as possible to be reapable and I do not see any fundamental
problems in that direction.
-- 
Michal Hocko
SUSE Labs
