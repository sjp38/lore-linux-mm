Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 201E86B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 00:38:07 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d203so213869158iof.20
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 21:38:07 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id x30si1076598pgc.223.2017.04.23.21.38.05
        for <linux-mm@kvack.org>;
        Sun, 23 Apr 2017 21:38:06 -0700 (PDT)
Date: Mon, 24 Apr 2017 13:36:56 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v6 05/15] lockdep: Implement crossrelease feature
Message-ID: <20170424043656.GI21430@X58A-UD3R>
References: <1489479542-27030-1-git-send-email-byungchul.park@lge.com>
 <1489479542-27030-6-git-send-email-byungchul.park@lge.com>
 <20170419150835.f2nky5qda5ooqfhy@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
In-Reply-To: <20170419150835.f2nky5qda5ooqfhy@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

On Wed, Apr 19, 2017 at 05:08:35PM +0200, Peter Zijlstra wrote:
> On Tue, Mar 14, 2017 at 05:18:52PM +0900, Byungchul Park wrote:
> > +/*
> > + * Only access local task's data, so irq disable is only required.
> > + */
> > +static int same_context_xhlock(struct hist_lock *xhlock)
> > +{
> > +	struct task_struct *curr = current;
> > +
> > +	/* In the case of hardirq context */
> > +	if (curr->hardirq_context) {
> > +		if (xhlock->hlock.irq_context & 2) /* 2: bitmask for hardirq */
> > +			return 1;
> > +	/* In the case of softriq context */
> > +	} else if (curr->softirq_context) {
> > +		if (xhlock->hlock.irq_context & 1) /* 1: bitmask for softirq */
> > +			return 1;
> > +	/* In the case of process context */
> > +	} else {
> > +		if (xhlock->work_id == curr->work_id)
> > +			return 1;
> > +	}
> > +	return 0;
> > +}
> 
> static bool same_context_xhlock(struct hist_lock *xhlock)
> {
> 	return xhlock->hlock.irq_context == task_irq_context(current) &&
> 	       xhlock->work_id == current->work_id;
> }

D'oh, thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
