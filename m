Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5951E6B000C
	for <linux-mm@kvack.org>; Thu, 24 May 2018 06:51:40 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m24-v6so1227070ioh.5
        for <linux-mm@kvack.org>; Thu, 24 May 2018 03:51:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h68-v6si4146292ite.23.2018.05.24.03.51.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 03:51:39 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Don't call schedule_timeout_killable() with oom_lock held.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180522061850.GB20020@dhcp22.suse.cz>
	<201805231924.EED86916.FSQJMtHOLVOFOF@I-love.SAKURA.ne.jp>
	<20180523115726.GP20441@dhcp22.suse.cz>
	<201805232245.IGI00539.HLtMFOQSJFFOOV@I-love.SAKURA.ne.jp>
	<20180523145639.GT20441@dhcp22.suse.cz>
In-Reply-To: <20180523145639.GT20441@dhcp22.suse.cz>
Message-Id: <201805241951.IFF48475.FMOSOJFQHLVtFO@I-love.SAKURA.ne.jp>
Date: Thu, 24 May 2018 19:51:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: guro@fb.com, rientjes@google.com, hannes@cmpxchg.org, vdavydov.dev@gmail.com, tj@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

Michal Hocko wrote:
> Look. I am fed up with this discussion. You are fiddling with the code
> and moving hacks around with a lot of hand waving. Rahter than trying to
> look at the underlying problem. Your patch completely ignores PREEMPT as
> I've mentioned in previous versions.

I'm not ignoring PREEMPT. To fix this OOM lockup problem properly, as much
efforts as fixing Spectre/Meltdown problems will be required. This patch is
a mitigation for regression introduced by fixing CVE-2018-1000200. Nothing
is good with deferring this patch.

> I would be OK with removing the sleep from the out_of_memory path based
> on your argumentation that we have a _proper_ synchronization with the
> exit path now.

Such attempt should be made in a separate patch.

You suggested removing this sleep from my patch without realizing that
we need explicit schedule_timeout_*() for PF_WQ_WORKER threads. My patch
is trying to be as conservative/safe as possible (for easier backport)
while reducing the risk of falling into OOM lockup.

I worry that you are completely overlooking

                char *fmt, ...)
 	 */
 	if (!mutex_trylock(&oom_lock)) {
 		*did_some_progress = 1;
-		schedule_timeout_uninterruptible(1);
 		return NULL;
 	}
 

part in this patch.

Currently, the short sleep is so random/inconsistent that
schedule_timeout_uninterruptible(1) is called when we failed to grab
oom_lock (even if current thread was already marked as an OOM victim),
schedule_timeout_killable(1) is called when we killed a new OOM victim,
and no sleep at all if we found that there are inflight OOM victims.

This patch centralized the location to call
schedule_timeout_uninterruptible(1) to "goto retry;" path so that
current thread surely yields CPU resource to the owner of oom_lock.

You are free to propose removing this centralized sleep after my change
is applied. Of course, you are responsible for convincing that removing
this centralized sleep (unless PF_WQ_WORKER threads) does not negatively
affect the owner of oom_lock (e.g. a SCHED_IDLE thread who is holding
oom_lock gets blocked longer than mine).
