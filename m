Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B59EA6B0007
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 16:35:36 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id y16-v6so6593110pgv.23
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 13:35:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u4-v6si2601655pgm.454.2018.07.20.13.35.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Jul 2018 13:35:35 -0700 (PDT)
Date: Fri, 20 Jul 2018 22:35:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180720203524.GD4920@worktop.programming.kicks-ass.net>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712172942.10094-9-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> +static bool psi_update_stats(struct psi_group *group)
> +{

> +	for_each_online_cpu(cpu) {
> +		struct psi_group_cpu *groupc = per_cpu_ptr(group->cpus, cpu);
> +		unsigned long nonidle;
> +
> +		if (!groupc->nonidle_time)
> +			continue;
> +
> +		nonidle = nsecs_to_jiffies(groupc->nonidle_time);
> +		groupc->nonidle_time = 0;
> +		nonidle_total += nonidle;
> +
> +		for (r = 0; r < NR_PSI_RESOURCES; r++) {
> +			struct psi_resource *res = &groupc->res[r];
> +
> +			some[r] += (res->times[0] + res->times[1]) * nonidle;
> +			full[r] += res->times[1] * nonidle;
> +
> +			/* It's racy, but we can tolerate some error */
> +			res->times[0] = 0;
> +			res->times[1] = 0;
> +		}
> +	}

An alternative for this, that also allows that ondemand update, but
without spamming the rq->lock would be something like:

struct psi_group_cpu {
	u32 tasks[3];
	u32 cpu_state : 2;
	u32 mem_state : 2;
	u32 io_state  : 2;
	u32 :0;

	u64 last_update_time;

	u32 nonidle;
	u32 full[2];
	u32 some[3];
} ____cacheline_aligned_in_smp;

/* Allocate _2_ copies */
DEFINE_PER_CPU_ALIGNED_SHARED(struct psi_group_cpu[2], psi_cpus);

struct psi_group global_psi = {
	.cpus = &psi_cpus[0],
};


	u64 sums[6] = { 0, };

	for_each_possible_cpu(cpu) {
		struct psi_group_cpu *pgc = per_cpu_ptr(group->cpus, cpu);
		u32 *active, *shadow;

		active = &pgc[0].nonidle;
		shadow = &pgc[1].nonidle;

		/*
		 * Compare the active count to the shadow count
		 * if different, compute the delta and update the shadow
		 * copy.
		 * This only writes to the shadow copy (separate line)
		 * and leaves the active a read-only access.
		 */
		for (i = 0; i < 6; i++) {
			u32 old = READ_ONCE(shadow[i]);
			u32 new = READ_ONCE(active[i]);

			delta = (new - old);
			if (!delta) {
				if (!i)
					goto next;
				continue;
			}

			WRITE_ONCE(shadow[i], new);

			sums[i] += delta;
		}
next:		;
	}
