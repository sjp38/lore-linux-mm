Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 959286B03B3
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 08:40:30 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d18so16801083pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:40:30 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c21si1816139pgi.128.2017.02.28.05.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 05:40:29 -0800 (PST)
Date: Tue, 28 Feb 2017 14:40:18 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170228134018.GK5680@worktop>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

On Wed, Jan 18, 2017 at 10:17:32PM +0900, Byungchul Park wrote:
> +	/*
> +	 * If the previous in held_locks can create a proper dependency
> +	 * with a target crosslock, then we can skip commiting this,
> +	 * since "the target crosslock -> the previous lock" and
> +	 * "the previous lock -> this lock" can cover the case. So we
> +	 * keep the previous's gen_id to make the decision.
> +	 */
> +	unsigned int		prev_gen_id;

> +static void add_xhlock(struct held_lock *hlock, unsigned int prev_gen_id)
> +{
> +	struct hist_lock *xhlock;
> +
> +	xhlock = alloc_xhlock();
> +
> +	/* Initialize hist_lock's members */
> +	xhlock->hlock = *hlock;
> +	xhlock->nmi = !!(preempt_count() & NMI_MASK);
> +	/*
> +	 * prev_gen_id is used to skip adding dependency at commit step,
> +	 * when the previous lock in held_locks can do that instead.
> +	 */
> +	xhlock->prev_gen_id = prev_gen_id;
> +	xhlock->work_id = current->work_id;
> +
> +	xhlock->trace.nr_entries = 0;
> +	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
> +	xhlock->trace.entries = xhlock->trace_entries;
> +	xhlock->trace.skip = 3;
> +	save_stack_trace(&xhlock->trace);
> +}

> +static void check_add_xhlock(struct held_lock *hlock)
> +{
> +	struct held_lock *prev;
> +	struct held_lock *start;
> +	unsigned int gen_id;
> +	unsigned int gen_id_invalid;
> +
> +	if (!current->xhlocks || !depend_before(hlock))
> +		return;
> +
> +	gen_id = (unsigned int)atomic_read(&cross_gen_id);
> +	/*
> +	 * gen_id_invalid must be too old to be valid. That means
> +	 * current hlock should not be skipped but should be
> +	 * considered at commit step.
> +	 */
> +	gen_id_invalid = gen_id - (UINT_MAX / 4);
> +	start = current->held_locks;
> +
> +	for (prev = hlock - 1; prev >= start &&
> +			!depend_before(prev); prev--);
> +
> +	if (prev < start)
> +		add_xhlock(hlock, gen_id_invalid);
> +	else if (prev->gen_id != gen_id)
> +		add_xhlock(hlock, prev->gen_id);
> +}

> +static int commit_xhlocks(struct cross_lock *xlock)
> +{
> +	struct task_struct *curr = current;
> +	struct hist_lock *xhlock_c = xhlock_curr(curr);
> +	struct hist_lock *xhlock = xhlock_c;
> +
> +	do {
> +		xhlock = xhlock_prev(curr, xhlock);
> +
> +		if (!xhlock_used(xhlock))
> +			break;
> +
> +		if (before(xhlock->hlock.gen_id, xlock->hlock.gen_id))
> +			break;
> +
> +		if (same_context_xhlock(xhlock) &&
> +		    before(xhlock->prev_gen_id, xlock->hlock.gen_id) &&
> +		    !commit_xhlock(xlock, xhlock))
> +			return 0;
> +	} while (xhlock_c != xhlock);
> +
> +	return 1;
> +}

So I'm still struggling with prev_gen_id; is it an optimization or is it
required for correctness?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
