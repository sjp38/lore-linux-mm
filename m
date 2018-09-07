Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54D6F6B7DD3
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 06:22:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n194-v6so20288138itn.0
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 03:22:02 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k189-v6si5564043ith.40.2018.09.07.03.22.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Sep 2018 03:22:01 -0700 (PDT)
Date: Fri, 7 Sep 2018 12:21:46 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 8/9] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180907102146.GI24142@hirez.programming.kicks-ass.net>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180828172258.3185-9-hannes@cmpxchg.org>
 <20180907101634.GO24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907101634.GO24106@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 12:16:34PM +0200, Peter Zijlstra wrote:
> This does the whole seqcount thing 6x, which is a bit of a waste.
> 
> struct snapshot {
> 	u32 times[NR_PSI_STATES];
> };
> 
> static inline struct snapshot get_times_snapshot(struct psi_group *pg, int cpu)
> {
> 	struct pci_group_cpu *pgc = per_cpu_ptr(pg->pcpu, cpu);
> 	struct snapshot s;
> 	unsigned int seq;
> 	u32 delta;
> 	int i;
> 
> 	do {
> 		seq = read_seqcount_begin(&pgc->seq);
> 
> 		delta = cpu_clock(cpu) - pgc->state_start;
> 		for (i = 0; i < NR_PSI_STATES; i++) {
> 			s.times[i] = gpc->times[i];
> 			if (test_state(pgc->tasks, i))
> 				s.times[i] += delta;
> 		}
> 
> 	} while (read_seqcount_retry(&pgc->seq, seq);

Sorry, I forgot the whole times_prev thing:

	for (i = 0; i < NR_PSI_STATES; i++) {
		tmp = s.times[i];
		s.times[i] -= pgc->times_prev[i];
		pgc->times_prev[i] = tmp;
	}

> 	return s;
> }
> 
> 
> 	for_each_possible_cpu(cpu) {
> 		struct snapshot s = get_times_snapshot(pg, cpu);
> 
> 		nonidle = nsecs_to_jiffies(s.times[PSI_NONIDLE]);
> 		nonidle_total += nonidle;
> 
> 		for (i = 0; i < PSI_NONIDLE; i++)
> 			deltas[s] += (u64)s.times[i] * nonidle;
> 
> 		/* ... */
> 
> 	}
> 
> 
> It's a bit cumbersome, but that's because of C.
