Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C90656B7369
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:40:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c25-v6so2501599edb.12
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:40:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2-v6si658470edp.402.2018.09.05.06.40.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:40:40 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:40:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180905134038.GE14951@dhcp22.suse.cz>
References: <cb2d635c-c14d-c2cc-868a-d4c447364f0d@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1808231544001.150774@chino.kir.corp.google.com>
 <201808240031.w7O0V5hT019529@www262.sakura.ne.jp>
 <195a512f-aecc-f8cf-f409-6c42ee924a8c@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <195a512f-aecc-f8cf-f409-6c42ee924a8c@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed 05-09-18 22:20:58, Tetsuo Handa wrote:
> On 2018/08/24 9:31, Tetsuo Handa wrote:
> > For now, I don't think we need to add af5679fbc669f31f to the list for
> > CVE-2016-10723, for af5679fbc669f31f might cause premature next OOM victim
> > selection (especially with CONFIG_PREEMPT=y kernels) due to
> > 
> >    __alloc_pages_may_oom():               oom_reap_task():
> > 
> >      mutex_trylock(&oom_lock) succeeds.
> >      get_page_from_freelist() fails.
> >      Preempted to other process.
> >                                             oom_reap_task_mm() succeeds.
> >                                             Sets MMF_OOM_SKIP.
> >      Returned from preemption.
> >      Finds that MMF_OOM_SKIP was already set.
> >      Selects next OOM victim and kills it.
> >      mutex_unlock(&oom_lock) is called.
> > 
> > race window like described as
> > 
> >     Tetsuo was arguing that at least MMF_OOM_SKIP should be set under the lock
> >     to prevent from races when the page allocator didn't manage to get the
> >     freed (reaped) memory in __alloc_pages_may_oom but it sees the flag later
> >     on and move on to another victim.  Although this is possible in principle
> >     let's wait for it to actually happen in real life before we make the
> >     locking more complex again.
> > 
> > in that commit.
> > 
> 
> Yes, that race window is real. We can needlessly select next OOM victim.
> I think that af5679fbc669f31f was too optimistic.

Changelog said 

"Although this is possible in principle let's wait for it to actually
happen in real life before we make the locking more complex again."

So what is the real life workload that hits it? The log you have pasted
below doesn't tell much.

> [  278.147280] Out of memory: Kill process 9943 (a.out) score 919 or sacrifice child
> [  278.148927] Killed process 9943 (a.out) total-vm:4267252kB, anon-rss:3430056kB, file-rss:0kB, shmem-rss:0kB
> [  278.151586] vmtoolsd invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[...]
> [  278.331527] Out of memory: Kill process 8790 (firewalld) score 5 or sacrifice child
> [  278.333267] Killed process 8790 (firewalld) total-vm:358012kB, anon-rss:21928kB, file-rss:0kB, shmem-rss:0kB
> [  278.336430] oom_reaper: reaped process 8790 (firewalld), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

-- 
Michal Hocko
SUSE Labs
