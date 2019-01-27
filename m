Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E15BC8E00FD
	for <linux-mm@kvack.org>; Sun, 27 Jan 2019 06:40:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so5542053ede.19
        for <linux-mm@kvack.org>; Sun, 27 Jan 2019 03:40:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j21-v6si1735565ejt.227.2019.01.27.03.40.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jan 2019 03:40:23 -0800 (PST)
Date: Sun, 27 Jan 2019 12:40:21 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] oom, oom_reaper: do not enqueue same task twice
Message-ID: <20190127114021.GB18811@dhcp22.suse.cz>
References: <a95d004a-4358-7efc-6d21-12aac4411b32@gmail.com>
 <480296c4-ed7a-3265-e84a-298e42a0f1d5@I-love.SAKURA.ne.jp>
 <6da6ca69-5a6e-a9f6-d091-f89a8488982a@gmail.com>
 <72aa8863-a534-b8df-6b9e-f69cf4dd5c4d@i-love.sakura.ne.jp>
 <33a07810-6dbc-36be-5bb6-a279773ccf69@i-love.sakura.ne.jp>
 <34e97b46-0792-cc66-e0f2-d72576cdec59@i-love.sakura.ne.jp>
 <2b0c7d6c-c58a-da7d-6f0a-4900694ec2d3@gmail.com>
 <1d161137-55a5-126f-b47e-b2625bd798ca@i-love.sakura.ne.jp>
 <20190127083724.GA18811@dhcp22.suse.cz>
 <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec0d0580-a2dd-f329-9707-0cb91205a216@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Arkadiusz =?utf-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Aleksa Sarai <asarai@suse.de>, Jay Kamat <jgkamat@fb.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Sun 27-01-19 19:56:06, Tetsuo Handa wrote:
> On 2019/01/27 17:37, Michal Hocko wrote:
> > Thanks for the analysis and the patch. This should work, I believe but
> > I am not really thrilled to overload the meaning of the MMF_UNSTABLE.
> > The flag is meant to signal accessing address space is not stable and it
> > is not aimed to synchronize oom reaper with the oom path.
> > 
> > Can we make use mark_oom_victim directly? I didn't get to think that
> > through right now so I might be missing something but this should
> > prevent repeating queueing as well.
> 
> Yes, TIF_MEMDIE would work. But you are planning to remove TIF_MEMDIE. Also,
> TIF_MEMDIE can't avoid enqueuing many threads sharing mm_struct to the OOM
> reaper. There is no need to enqueue many threads sharing mm_struct because
> the OOM reaper acts on mm_struct rather than task_struct. Thus, enqueuing
> based on per mm_struct flag sounds better, but MMF_OOM_VICTIM cannot be
> set from wake_oom_reaper(victim) because victim's mm might be already inside
> exit_mmap() when wake_oom_reaper(victim) is called after task_unlock(victim).
>
> We could reintroduce MMF_OOM_KILLED in commit 855b018325737f76
> ("oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task")
> if you don't like overloading the meaning of the MMF_UNSTABLE. But since
> MMF_UNSTABLE is available in Linux 4.9+ kernels (which covers all LTS stable
> versions with the OOM reaper support), we can temporarily use MMF_UNSTABLE
> for ease of backporting.

I agree that a per-mm state is more optimal but I would rather fix the
issue in a clear way first and only then think about an optimization on
top. Queueing based on mark_oom_victim (whatever that uses to guarantee
the victim is marked atomically and only once) makes sense from the
conceptual point of view and it makes a lot of sense to start from
there. MMF_UNSTABLE has a completely different purpose. So unless you
see a correctness issue with that then I would rather go that way.
-- 
Michal Hocko
SUSE Labs
