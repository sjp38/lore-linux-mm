Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4686B00E5
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:00:45 -0500 (EST)
Date: Mon, 23 Feb 2009 14:59:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: gfp_to_alloc_flags()
Message-Id: <20090223145936.ba2b51e7.akpm@linux-foundation.org>
In-Reply-To: <1235390103.4645.80.camel@laptop>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	<1235390103.4645.80.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 23 Feb 2009 12:55:03 +0100
Peter Zijlstra <peterz@infradead.org> wrote:

> +static int gfp_to_alloc_flags(gfp_t gfp_mask)
> +{
> +	struct task_struct *p = current;
> +	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> +
> +	/*
> +	 * The caller may dip into page reserves a bit more if the caller
> +	 * cannot run direct reclaim, or if the caller has realtime scheduling
> +	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> +	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> +	 */
> +	if (gfp_mask & __GFP_HIGH)
> +		alloc_flags |= ALLOC_HIGH;

This could be sped up by making ALLOC_HIGH==__GFP_HIGH (hack)

> +	if (!wait) {
> +		alloc_flags |= ALLOC_HARDER;
> +		/*
> +		 * Ignore cpuset if GFP_ATOMIC (!wait) rather than fail alloc.
> +		 * See also cpuset_zone_allowed() comment in kernel/cpuset.c.
> +		 */
> +		alloc_flags &= ~ALLOC_CPUSET;
> +	} else if (unlikely(rt_task(p)) && !in_interrupt())
> +		alloc_flags |= ALLOC_HARDER;
> +
> +	if (likely(!(gfp_mask & __GFP_NOMEMALLOC))) {
> +		if (!in_interrupt() &&
> +		    ((p->flags & PF_MEMALLOC) ||
> +		     unlikely(test_thread_flag(TIF_MEMDIE))))
> +			alloc_flags |= ALLOC_NO_WATERMARKS;
> +	}
> +	return alloc_flags;
> +}


But really, the whole function can be elided on the fastpath.  Try the
allocation with the current flags (and __GFP_NOWARN) and only if it
failed will we try altering the flags to try harder?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
