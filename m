Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DCFC06B0005
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 11:13:48 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id b83-v6so1324474itg.1
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 08:13:48 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j188-v6si959762ite.90.2018.07.17.08.13.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Jul 2018 08:13:47 -0700 (PDT)
Date: Tue, 17 Jul 2018 17:13:36 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 10/10] psi: aggregate ongoing stall events when
 somebody reads pressure
Message-ID: <20180717151336.GZ2476@hirez.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-11-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-11-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:42PM -0400, Johannes Weiner wrote:
> @@ -218,10 +216,36 @@ static bool psi_update_stats(struct psi_group *group)
>  	for_each_online_cpu(cpu) {
>  		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
>  		unsigned long nonidle;
> +		struct rq_flags rf;
> +		struct rq *rq;
> +		u64 now;
>  
> -		if (!groupc->nonidle_time)
> +		if (!groupc->nonidle_time && !groupc->nonidle)
>  			continue;
>  
> +		/*
> +		 * We come here for two things: 1) periodic per-cpu
> +		 * bucket flushing and averaging and 2) when the user
> +		 * wants to read a pressure file. For flushing and
> +		 * averaging, which is relatively infrequent, we can
> +		 * be lazy and tolerate some raciness with concurrent
> +		 * updates to the per-cpu counters. However, if a user
> +		 * polls the pressure state, we want to give them the
> +		 * most uptodate information we have, including any
> +		 * currently active state which hasn't been timed yet,
> +		 * because in case of an iowait or a reclaim run, that
> +		 * can be significant.
> +		 */
> +		if (ondemand) {
> +			rq = cpu_rq(cpu);
> +			rq_lock_irq(rq, &rf);

That's a DoS right there..
