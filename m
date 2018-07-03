Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 137D56B0269
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 10:58:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o5-v6so1046905edq.15
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 07:58:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 93-v6si870107edl.219.2018.07.03.07.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 07:58:10 -0700 (PDT)
Date: Tue, 3 Jul 2018 16:58:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/8] mm,oom: Fix unnecessary killing of additional
 processes.
Message-ID: <20180703145808.GN16767@dhcp22.suse.cz>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1530627910-3415-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530627910-3415-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Tue 03-07-18 23:25:04, Tetsuo Handa wrote:
> David Rientjes is complaining that memcg OOM events needlessly select
> more OOM victims when the OOM reaper was unable to reclaim memory. This
> is because exit_mmap() is setting MMF_OOM_SKIP before calling
> free_pgtables(). While David is trying to introduce timeout based hold
> off approach, Michal Hocko is rejecting plain timeout based approaches.
> 
> Therefore, this patch gets rid of the OOM reaper kernel thread and
> introduces OOM-badness-score based hold off approach. The reason for
> getting rid of the OOM reaper kernel thread is explained below.
> 
>     We are about to start getting a lot of OOM victim processes by
>     introducing "mm, oom: cgroup-aware OOM killer" patchset.
> 
>     When there are multiple OOM victims, we should try reclaiming memory
>     in parallel rather than sequentially wait until conditions to be able
>     to reclaim memory are met. Also, we should preferentially reclaim from
>     OOM domains where currently allocating threads belong to. Also, we
>     want to get rid of schedule_timeout_*(1) heuristic which is used for
>     trying to give CPU resource to the owner of oom_lock. Therefire,
>     direct OOM reaping by allocating threads can do the job better than
>     the OOM reaper kernel thread.
> 
> This patch changes the OOM killer to wait until either __mmput()
> completes or OOM badness score did not decrease for 3 seconds.

So this is yet another timeout based thing... I am really getting tired
of this coming back and forth. I will get ignored most probably again,
but let me repeat. Once you make this timeout based you will really have
to make it tunable by userspace because one timeout never fits all
needs. And that would be quite stupid. Because what we have now is a
feedback based approach. So we retry as long as we can make progress and
fail eventually because we cannot retry for ever. How many times we
retry is an implementation detail so we do not have to expose that.

Anyway, You failed to explain whether there is any fundamental problem
that the current approach has and won't be able to handle or this new
approach would handle much better. So what are sound reasons to rewrite
the whole thing?

Why do you think that pulling the memory reaping into the oom context is
any better?

So color me unconvinced
-- 
Michal Hocko
SUSE Labs
