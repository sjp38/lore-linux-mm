Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 13AE36B0325
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 10:44:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g187so987792wmg.2
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 07:44:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 65sor711524wmf.25.2018.02.07.07.44.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 07:44:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180203082353.17284-1-hannes@cmpxchg.org>
References: <20180203082353.17284-1-hannes@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 7 Feb 2018 07:44:08 -0800
Message-ID: <CALvZod5-35Y+_eot6-6J5HyssnmAW-wfYhuQdxxA9Zj8Ng2e+g@mail.gmail.com>
Subject: Re: [PATCH] mm: memcontrol: fix NR_WRITEBACK leak in memcg and system stats
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Sat, Feb 3, 2018 at 12:23 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> After the ("a983b5ebee57 mm: memcontrol: fix excessive complexity in
> memory.stat reporting"), we observed slowly upward creeping
> NR_WRITEBACK counts over the course of several days, both the
> per-memcg stats as well as the system counter in e.g. /proc/meminfo.
>
> The conversion from full per-cpu stat counts to per-cpu cached atomic
> stat counts introduced an irq-unsafe RMW operation into the updates.
>
> Most stat updates come from process context, but one notable exception
> is the NR_WRITEBACK counter. While writebacks are issued from process
> context, they are retired from (soft)irq context.
>
> When writeback completions interrupt the RMW counter updates of new
> writebacks being issued, the decs from the completions are lost.
>
> Since the global updates are routed through the joint lruvec API, both
> the memcg counters as well as the system counters are affected.
>
> This patch makes the joint stat and event API irq safe.
>
> Fixes: a983b5ebee57 ("mm: memcontrol: fix excessive complexity in memory.stat reporting")
> Debugged-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Should this be considered for stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
