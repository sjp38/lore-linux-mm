Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07DFB6B03A3
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 10:25:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l11so15618281iod.15
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 07:25:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n9si2884106pll.112.2017.04.19.07.25.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 07:25:08 -0700 (PDT)
Date: Wed, 19 Apr 2017 16:25:03 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170419142503.rqsrgjlc7ump7ijb@hirez.programming.kicks-ass.net>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> +struct hist_lock {
> +	/*
> +	 * Each work of workqueue might run in a different context,
> +	 * thanks to concurrency support of workqueue. So we have to
> +	 * distinguish each work to avoid false positive.
> +	 */
> +	unsigned int		work_id;
>  };

> @@ -1749,6 +1749,14 @@ struct task_struct {
>  	struct held_lock held_locks[MAX_LOCK_DEPTH];
>  	gfp_t lockdep_reclaim_gfp;
>  #endif
> +#ifdef CONFIG_LOCKDEP_CROSSRELEASE
> +#define MAX_XHLOCKS_NR 64UL
> +	struct hist_lock *xhlocks; /* Crossrelease history locks */
> +	unsigned int xhlock_idx;
> +	unsigned int xhlock_idx_soft; /* For backing up at softirq entry */
> +	unsigned int xhlock_idx_hard; /* For backing up at hardirq entry */
> +	unsigned int work_id;
> +#endif
>  #ifdef CONFIG_UBSAN
>  	unsigned int in_ubsan;
>  #endif

> +/*
> + * Crossrelease needs to distinguish each work of workqueues.
> + * Caller is supposed to be a worker.
> + */
> +void crossrelease_work_start(void)
> +{
> +	if (current->xhlocks)
> +		current->work_id++;
> +}

> +/*
> + * Only access local task's data, so irq disable is only required.
> + */
> +static int same_context_xhlock(struct hist_lock *xhlock)
> +{
> +	struct task_struct *curr = current;
> +
> +	/* In the case of hardirq context */
> +	if (curr->hardirq_context) {
> +		if (xhlock->hlock.irq_context & 2) /* 2: bitmask for hardirq */
> +			return 1;
> +	/* In the case of softriq context */
> +	} else if (curr->softirq_context) {
> +		if (xhlock->hlock.irq_context & 1) /* 1: bitmask for softirq */
> +			return 1;
> +	/* In the case of process context */
> +	} else {
> +		if (xhlock->work_id == curr->work_id)
> +			return 1;
> +	}
> +	return 0;
> +}

I still don't like work_id; it doesn't have anything to do with
workqueues per se, other than the fact that they end up using it.

It's a history generation id; touching it completely invalidates our
history. Workqueues need this because they run independent work from the
same context.

But the same is true for other sites. Last time I suggested
lockdep_assert_empty() to denote all suck places (and note we already
have lockdep_sys_exit() that hooks into the return to user path).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
