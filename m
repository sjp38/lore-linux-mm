Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEDE6B026D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 11:44:29 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id x13-v6so7000932ybl.17
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:44:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9-v6sor2503586ywb.528.2018.07.30.08.44.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 08:44:28 -0700 (PDT)
Date: Mon, 30 Jul 2018 08:44:24 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
 <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
 <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello,

On Tue, Jul 31, 2018 at 12:25:04AM +0900, Tetsuo Handa wrote:
> WQ_MEM_RECLAIM guarantees that "struct task_struct" is preallocated. But
> WQ_MEM_RECLAIM does not guarantee that the pending work is started as soon
> as an item was queued. Same rule applies to both WQ_MEM_RECLAIM workqueues 
> and !WQ_MEM_RECLAIM workqueues regarding when to start a pending work (i.e.
> when schedule_timeout_*() is called).
> 
> Is this correct?

WQ_MEM_RECLAIM guarantees that there's always gonna exist at least one
kworker running the workqueue.  But all per-cpu kworkers are subject
to concurrency limiting execution - ie. if there are any per-cpu
actively running on a cpu, no futher kworkers will be scheduled.

> >              We can add timeout mechanism to workqueue so that it
> > kicks off other kworkers if one of them is in running state for too
> > long, but idk, if there's an indefinite busy loop condition in kernel
> > threads, we really should get rid of them and hung task watchdog is
> > pretty effective at finding these cases (at least with preemption
> > disabled).
> 
> Currently the page allocator has a path which can loop forever with
> only cond_resched().

Yeah, workqueue can choke on things like that and kthread indefinitely
busy looping doesn't do anybody any good.

Thanks.

-- 
tejun
