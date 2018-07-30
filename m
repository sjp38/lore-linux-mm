Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F8CB6B0010
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:54:29 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id 2-v6so7295334ywn.13
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 07:54:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4-v6sor2687468ybn.96.2018.07.30.07.54.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 07:54:28 -0700 (PDT)
Date: Mon, 30 Jul 2018 07:54:25 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
Message-ID: <20180730145425.GE1206094@devbig004.ftw2.facebook.com>
References: <ca3da8b8-1bb5-c302-b190-fa6cebab58ca@I-love.SAKURA.ne.jp>
 <20180726113958.GE28386@dhcp22.suse.cz>
 <55c9da7f-e448-964a-5b50-47f89a24235b@i-love.sakura.ne.jp>
 <20180730093257.GG24267@dhcp22.suse.cz>
 <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp>
 <20180730144647.GX24267@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730144647.GX24267@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hello,

On Mon, Jul 30, 2018 at 04:46:47PM +0200, Michal Hocko wrote:
> On Mon 30-07-18 23:34:23, Tetsuo Handa wrote:
> > On 2018/07/30 18:32, Michal Hocko wrote:
> [...]
> > > This one is waiting for draining and we are in mm_percpu_wq WQ context
> > > which has its rescuer so no other activity can block us for ever. So
> > > this certainly shouldn't deadlock. It can be dead slow but well, this is
> > > what you will get when your shoot your system to death.
> > 
> > We need schedule_timeout_*() to allow such WQ_MEM_RECLAIM workqueues to wake up. (Tejun,
> > is my understanding correct?) Lack of schedule_timeout_*() does block WQ_MEM_RECLAIM
> > workqueues forever.
> 
> Hmm. This doesn't match my understanding of what WQ_MEM_RECLAIM actually
> guarantees. If you are right then the whole thing sounds quite fragile
> to me TBH.

Workqueue doesn't think the cpu is stalled as long as one of the
per-cpu kworkers is running.  The assumption is that kernel threads
are not supposed to be busy-looping indefinitely (and they really
shouldn't).  We can add timeout mechanism to workqueue so that it
kicks off other kworkers if one of them is in running state for too
long, but idk, if there's an indefinite busy loop condition in kernel
threads, we really should get rid of them and hung task watchdog is
pretty effective at finding these cases (at least with preemption
disabled).

Thanks.

-- 
tejun
