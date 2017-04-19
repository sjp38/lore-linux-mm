Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3B66B0390
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 11:08:41 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id a103so16788197ioj.8
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 08:08:41 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id w142si3352176iow.197.2017.04.19.08.08.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 08:08:40 -0700 (PDT)
Date: Wed, 19 Apr 2017 17:08:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170419150835.f2nky5qda5ooqfhy@hirez.programming.kicks-ass.net>
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

static bool same_context_xhlock(struct hist_lock *xhlock)
{
	return xhlock->hlock.irq_context == task_irq_context(current) &&
	       xhlock->work_id == current->work_id;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
