Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B885B6B0005
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:17:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g66so4581396pfj.11
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 06:17:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x3-v6si4921932plb.366.2018.03.22.06.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 06:17:13 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521715916-4153-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180322114554.GD23100@dhcp22.suse.cz>
In-Reply-To: <20180322114554.GD23100@dhcp22.suse.cz>
Message-Id: <201803222216.HED73490.HJFOVFLFQMtOSO@I-love.SAKURA.ne.jp>
Date: Thu, 22 Mar 2018 22:16:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, tj@kernel.org, vdavydov.dev@gmail.com

Michal Hocko wrote:
> On Thu 22-03-18 19:51:56, Tetsuo Handa wrote:
> [...]
> > The whole point of the sleep is to give the OOM victim some time to exit.
> 
> Yes, and that is why we sleep under the lock because that would rule all
> other potential out_of_memory callers from jumping in.

As long as there is !MMF_OOM_SKIP mm, jumping in does not cause problems.

But since this patch did not remove mutex_lock() from the OOM reaper,
nobody can jump in until the OOM reaper completes the first reclaim attempt.
And since it is likely that mutex_trylock() by the OOM reaper succeeds,
somebody unlikely finds !MMF_OOM_SKIP mm when it jumped in.

> 
> > However, the sleep can prevent contending allocating paths from hitting
> > the OOM path again even if the OOM victim was able to exit. We need to
> > make sure that the thread which called out_of_memory() will release
> > oom_lock shortly. Thus, this patch brings the sleep to outside of the OOM
> > path. Since the OOM reaper waits for the oom_lock, this patch unlikely
> > allows contending allocating paths to hit the OOM path earlier than now.
> 
> The sleep outside of the lock doesn't make much sense to me. It is
> basically contradicting its original purpose. If we do want to throttle
> direct reclaimers than OK but this patch is not the way how to do that.
> 
> If you really believe that the sleep is more harmful than useful, then
> fair enough, I would rather see it removed than shuffled all over
> outside the lock. 

Yes, I do believe that the sleep with oom_lock held is more harmful than useful.
Please remove the sleep (but be careful not to lose the guaranteed sleep for
PF_WQ_WORKER).

> 
> So
> Nacked-by: Michal Hocko <mhocko@suse.com>
> -- 
> Michal Hocko
> SUSE Labs
> 
