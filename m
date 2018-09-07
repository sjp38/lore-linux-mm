Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CC9AB6B7DD8
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 06:25:09 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id w18-v6so6965013plp.3
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 03:25:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id r124-v6si8867995pfc.202.2018.09.07.03.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Sep 2018 03:25:08 -0700 (PDT)
Date: Fri, 7 Sep 2018 12:24:58 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907102458.GP24106@hirez.programming.kicks-ass.net>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180828172258.3185-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Aug 28, 2018 at 01:22:57PM -0400, Johannes Weiner wrote:
> +static void psi_clock(struct work_struct *work)
> +{
> +	struct delayed_work *dwork;
> +	struct psi_group *group;
> +	bool nonidle;
> +
> +	dwork = to_delayed_work(work);
> +	group = container_of(dwork, struct psi_group, clock_work);
> +
> +	/*
> +	 * If there is task activity, periodically fold the per-cpu
> +	 * times and feed samples into the running averages. If things
> +	 * are idle and there is no data to process, stop the clock.
> +	 * Once restarted, we'll catch up the running averages in one
> +	 * go - see calc_avgs() and missed_periods.
> +	 */
> +
> +	nonidle = update_stats(group);
> +
> +	if (nonidle) {
> +		unsigned long delay = 0;
> +		u64 now;
> +
> +		now = sched_clock();
> +		if (group->next_update > now)
> +			delay = nsecs_to_jiffies(group->next_update - now) + 1;
> +		schedule_delayed_work(dwork, delay);
> +	}
> +}

Just a little nit; I would expect a function called *clock() to return a
time.
