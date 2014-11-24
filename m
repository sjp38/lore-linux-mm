Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 94F436B00B3
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 11:50:36 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id n3so6512988wiv.1
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:50:36 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id cz10si10546975wib.49.2014.11.24.08.50.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Nov 2014 08:50:35 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so6369697wiv.0
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 08:50:35 -0800 (PST)
Date: Mon, 24 Nov 2014 17:50:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] mm: Introduce OOM kill timeout.
Message-ID: <20141124165032.GA11745@curandero.mameluci.net>
References: <201411231349.CAG78628.VFQFOtOSFJMOLH@I-love.SAKURA.ne.jp>
 <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201411231350.DDH78622.LOtOQOFMFSHFJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 23-11-14 13:50:07, Tetsuo Handa wrote:
> >From ca8b3ee4bea5bcc6f8ec5e8496a97fd4cab5a440 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sun, 23 Nov 2014 13:38:53 +0900
> Subject: [PATCH 1/5] mm: Introduce OOM kill timeout.
> 
> Regarding many of Linux kernel versions (from unknown till now), any
> local user can give a certain type of memory pressure which causes
> __alloc_pages_nodemask() to keep trying to reclaim memory for presumably
> forever.

Retrying for ever might be an intention (see GFP_NOFAIL).

> As a consequence, such user can disturb any users' activities
> by keeping the system stalled with 0% or 100% CPU usage.

But the above doesn't make much sense to me. Sure reclaim can cause a
lot of CPU cycles to be burnt but most of direct reclaimers are simply
stuck waiting for something - congestion_wait or others.

> On systems where XFS is used, SysRq-f (forced OOM killer) may become
> unresponsive because kernel worker thread which is supposed to process
> SysRq-f request is blocked by previous request's GFP_WAIT allocation.

How is XFS relevant here? Besides that work queue has a fallback mode -
rescuer thread - which processes work items which cannot be processed by
the worker threads because they cannot be created due to allocation
failures. Using workqueues for sysrq triggered OOM is quite suboptimal
but this should be handled on the sysrq layer.

> The problem described above is one of phenomena which is triggered by
> a vulnerability which exists since (if I didn't miss something)
> Linux 2.0 (18 years ago). However, it is too difficult to backport
> patches which fix the vulnerability.

What is the vulnerability?

> Setting TIF_MEMDIE to SIGKILL'ed and/or PF_EXITING thread disables
> the OOM killer. But the TIF_MEMDIE thread may not be able to terminate
> within reasonable duration for some reason. Therefore, in order to avoid
> keeping the OOM killer disabled forever, this patch introduces 5 seconds
> timeout for TIF_MEMDIE threads which are supposed to terminate shortly.

I really do not like this. The timeout sounds arbitrary random. Besides
how would it solve the problem? We would go after another task which
might be blocked on the very same lock. How long should we go? What
happens when all of them wake up and consume all the memory on the way
out because they have access to the memory reserves now?

Also have you actually seen something like that happening?

We had a kind of similar problem in Memory cgroup controller because the
OOM was handled in the allocation path which might sit on many locks and
had to wait for the victim . So waiting for OOM victim to finish would
simply deadlock if the killed task was stuck on any of the locks held by
memcg OOM killer. But this is not the case anymore (we are processing
memcg OOM from the fault path).

The global OOM killer didn't have this kind of problem because OOM
killer doesn't wait for the victim to finish. If the victim waits for
something else that cannot make any progress because of the short memory
then I would call it a bug and it shouldn't be papered over and rather
fixed properly.

The oom killer code is quite complex and subtle already so I really do
not think that we should be adding ad-hoc heuristics without really good
reasons and when all other options are considered not viable. I do not
see any real life problem stated here and what is worse the changelog is
misleading in several ways. So NAK to this patch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
