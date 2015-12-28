Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BF6016B029C
	for <linux-mm@kvack.org>; Mon, 28 Dec 2015 09:13:49 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so110696410pac.0
        for <linux-mm@kvack.org>; Mon, 28 Dec 2015 06:13:49 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id qn16si2567430pab.207.2015.12.28.06.13.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Dec 2015 06:13:48 -0800 (PST)
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<201512242141.EAH69761.MOVFQtHSFOJFLO@I-love.SAKURA.ne.jp>
	<201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
In-Reply-To: <201512282108.EDI82328.OHFLtVJOSQFMFO@I-love.SAKURA.ne.jp>
Message-Id: <201512282313.DHE87075.OSLJOFOtMVQHFF@I-love.SAKURA.ne.jp>
Date: Mon, 28 Dec 2015 23:13:31 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, hillf.zj@alibaba-inc.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Tetsuo Handa wrote:
> > I got OOM killers while running heavy disk I/O (extracting kernel source,
> > running lxr's genxref command). (Environ: 4 CPUs / 2048MB RAM / no swap / XFS)
> > Do you think these OOM killers reasonable? Too weak against fragmentation?
>
> Since I cannot establish workload that caused December 24's natural OOM
> killers, I used the following stressor for generating similar situation.
>

I came to feel that I am observing a different problem which is currently
hidden behind the "too small to fail" memory-allocation rule. That is, tasks
requesting order > 0 pages are continuously losing the competition when
tasks requesting order = 0 pages dominate, for reclaimed pages are stolen
by tasks requesting order = 0 pages before reclaimed pages are combined to
order > 0 pages (or maybe order > 0 pages are immediately split into
order = 0 pages due to tasks requesting order = 0 pages).

Currently, order <= PAGE_ALLOC_COSTLY_ORDER allocations implicitly retry
unless chosen by the OOM killer. Therefore, even if tasks requesting
order = 2 pages lost the competition when there are tasks requesting
order = 0 pages, the order = 2 allocation request is implicitly retried
and therefore the OOM killer is not invoked (though there is a problem that
tasks requesting order > 0 allocation will stall as long as tasks requesting
order = 0 pages dominate).

But this patchset introduced a limit of 16 retries. Thus, if tasks requesting
order = 2 pages lost the competition for 16 times due to tasks requesting
order = 0 pages, tasks requesting order = 2 pages invoke the OOM killer.
To avoid the OOM killer, we need to make sure that pages reclaimed for
order > 0 allocations will not be stolen by tasks requesting order = 0
allocations.

Is my feeling plausible?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
