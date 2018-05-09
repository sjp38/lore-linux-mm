Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED386B04D6
	for <linux-mm@kvack.org>; Wed,  9 May 2018 06:15:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id c187so1405506pfa.20
        for <linux-mm@kvack.org>; Wed, 09 May 2018 03:15:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z3-v6si15714387plb.246.2018.05.09.03.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 03:15:02 -0700 (PDT)
Date: Wed, 9 May 2018 12:14:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 6/7] psi: pressure stall information for CPU, memory, and
 IO
Message-ID: <20180509101454.GM12217@hirez.programming.kicks-ass.net>
References: <20180507210135.1823-1-hannes@cmpxchg.org>
 <20180507210135.1823-7-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180507210135.1823-7-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, cgroups@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Mon, May 07, 2018 at 05:01:34PM -0400, Johannes Weiner wrote:
> diff --git a/kernel/sched/sched.h b/kernel/sched/sched.h
> index 15750c222ca2..1658477466d5 100644
> --- a/kernel/sched/sched.h
> +++ b/kernel/sched/sched.h

> @@ -919,6 +921,8 @@ DECLARE_PER_CPU_SHARED_ALIGNED(struct rq, runqueues);
>  #define cpu_curr(cpu)		(cpu_rq(cpu)->curr)
>  #define raw_rq()		raw_cpu_ptr(&runqueues)
>  
> +extern void update_rq_clock(struct rq *rq);
> +
>  static inline u64 __rq_clock_broken(struct rq *rq)
>  {
>  	return READ_ONCE(rq->clock);
> @@ -1037,6 +1041,86 @@ static inline void rq_repin_lock(struct rq *rq, struct rq_flags *rf)
>  #endif
>  }
>  
> +struct rq *__task_rq_lock(struct task_struct *p, struct rq_flags *rf)
> +	__acquires(rq->lock);
> +
> +struct rq *task_rq_lock(struct task_struct *p, struct rq_flags *rf)
> +	__acquires(p->pi_lock)
> +	__acquires(rq->lock);
> +
> +static inline void __task_rq_unlock(struct rq *rq, struct rq_flags *rf)
> +	__releases(rq->lock)
> +{
> +	rq_unpin_lock(rq, rf);
> +	raw_spin_unlock(&rq->lock);
> +}
> +
> +static inline void
> +task_rq_unlock(struct rq *rq, struct task_struct *p, struct rq_flags *rf)
> +	__releases(rq->lock)
> +	__releases(p->pi_lock)
> +{
> +	rq_unpin_lock(rq, rf);
> +	raw_spin_unlock(&rq->lock);
> +	raw_spin_unlock_irqrestore(&p->pi_lock, rf->flags);
> +}
> +
> +static inline void
> +rq_lock_irqsave(struct rq *rq, struct rq_flags *rf)
> +	__acquires(rq->lock)
> +{
> +	raw_spin_lock_irqsave(&rq->lock, rf->flags);
> +	rq_pin_lock(rq, rf);
> +}
> +
> +static inline void
> +rq_lock_irq(struct rq *rq, struct rq_flags *rf)
> +	__acquires(rq->lock)
> +{
> +	raw_spin_lock_irq(&rq->lock);
> +	rq_pin_lock(rq, rf);
> +}
> +
> +static inline void
> +rq_lock(struct rq *rq, struct rq_flags *rf)
> +	__acquires(rq->lock)
> +{
> +	raw_spin_lock(&rq->lock);
> +	rq_pin_lock(rq, rf);
> +}
> +
> +static inline void
> +rq_relock(struct rq *rq, struct rq_flags *rf)
> +	__acquires(rq->lock)
> +{
> +	raw_spin_lock(&rq->lock);
> +	rq_repin_lock(rq, rf);
> +}
> +
> +static inline void
> +rq_unlock_irqrestore(struct rq *rq, struct rq_flags *rf)
> +	__releases(rq->lock)
> +{
> +	rq_unpin_lock(rq, rf);
> +	raw_spin_unlock_irqrestore(&rq->lock, rf->flags);
> +}
> +
> +static inline void
> +rq_unlock_irq(struct rq *rq, struct rq_flags *rf)
> +	__releases(rq->lock)
> +{
> +	rq_unpin_lock(rq, rf);
> +	raw_spin_unlock_irq(&rq->lock);
> +}
> +
> +static inline void
> +rq_unlock(struct rq *rq, struct rq_flags *rf)
> +	__releases(rq->lock)
> +{
> +	rq_unpin_lock(rq, rf);
> +	raw_spin_unlock(&rq->lock);
> +}
> +
>  #ifdef CONFIG_NUMA
>  enum numa_topology_type {
>  	NUMA_DIRECT,
> @@ -1670,8 +1754,6 @@ static inline void sub_nr_running(struct rq *rq, unsigned count)
>  	sched_update_tick_dependency(rq);
>  }
>  
> -extern void update_rq_clock(struct rq *rq);
> -
>  extern void activate_task(struct rq *rq, struct task_struct *p, int flags);
>  extern void deactivate_task(struct rq *rq, struct task_struct *p, int flags);
>  
> @@ -1752,86 +1834,6 @@ static inline void sched_rt_avg_update(struct rq *rq, u64 rt_delta) { }
>  static inline void sched_avg_update(struct rq *rq) { }
>  #endif
>  
> -struct rq *__task_rq_lock(struct task_struct *p, struct rq_flags *rf)
> -	__acquires(rq->lock);
> -
> -struct rq *task_rq_lock(struct task_struct *p, struct rq_flags *rf)
> -	__acquires(p->pi_lock)
> -	__acquires(rq->lock);
> -
> -static inline void __task_rq_unlock(struct rq *rq, struct rq_flags *rf)
> -	__releases(rq->lock)
> -{
> -	rq_unpin_lock(rq, rf);
> -	raw_spin_unlock(&rq->lock);
> -}
> -
> -static inline void
> -task_rq_unlock(struct rq *rq, struct task_struct *p, struct rq_flags *rf)
> -	__releases(rq->lock)
> -	__releases(p->pi_lock)
> -{
> -	rq_unpin_lock(rq, rf);
> -	raw_spin_unlock(&rq->lock);
> -	raw_spin_unlock_irqrestore(&p->pi_lock, rf->flags);
> -}
> -
> -static inline void
> -rq_lock_irqsave(struct rq *rq, struct rq_flags *rf)
> -	__acquires(rq->lock)
> -{
> -	raw_spin_lock_irqsave(&rq->lock, rf->flags);
> -	rq_pin_lock(rq, rf);
> -}
> -
> -static inline void
> -rq_lock_irq(struct rq *rq, struct rq_flags *rf)
> -	__acquires(rq->lock)
> -{
> -	raw_spin_lock_irq(&rq->lock);
> -	rq_pin_lock(rq, rf);
> -}
> -
> -static inline void
> -rq_lock(struct rq *rq, struct rq_flags *rf)
> -	__acquires(rq->lock)
> -{
> -	raw_spin_lock(&rq->lock);
> -	rq_pin_lock(rq, rf);
> -}
> -
> -static inline void
> -rq_relock(struct rq *rq, struct rq_flags *rf)
> -	__acquires(rq->lock)
> -{
> -	raw_spin_lock(&rq->lock);
> -	rq_repin_lock(rq, rf);
> -}
> -
> -static inline void
> -rq_unlock_irqrestore(struct rq *rq, struct rq_flags *rf)
> -	__releases(rq->lock)
> -{
> -	rq_unpin_lock(rq, rf);
> -	raw_spin_unlock_irqrestore(&rq->lock, rf->flags);
> -}
> -
> -static inline void
> -rq_unlock_irq(struct rq *rq, struct rq_flags *rf)
> -	__releases(rq->lock)
> -{
> -	rq_unpin_lock(rq, rf);
> -	raw_spin_unlock_irq(&rq->lock);
> -}
> -
> -static inline void
> -rq_unlock(struct rq *rq, struct rq_flags *rf)
> -	__releases(rq->lock)
> -{
> -	rq_unpin_lock(rq, rf);
> -	raw_spin_unlock(&rq->lock);
> -}
> -
>  #ifdef CONFIG_SMP
>  #ifdef CONFIG_PREEMPT
>  


What's all this churn about?
