Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EF0206B0055
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 03:59:33 -0500 (EST)
Subject: Re: [PATCH] mm: gfp_to_alloc_flags()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090223145936.ba2b51e7.akpm@linux-foundation.org>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235390103.4645.80.camel@laptop>
	 <20090223145936.ba2b51e7.akpm@linux-foundation.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Tue, 24 Feb 2009 09:59:13 +0100
Message-Id: <1235465953.15790.10.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, linux-mm@kvack.org, penberg@cs.helsinki.fi, riel@redhat.com, kosaki.motohiro@jp.fujitsu.com, cl@linux-foundation.org, hannes@cmpxchg.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-23 at 14:59 -0800, Andrew Morton wrote:
> On Mon, 23 Feb 2009 12:55:03 +0100
> Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > +static int gfp_to_alloc_flags(gfp_t gfp_mask)
> > +{
> > +	struct task_struct *p = current;
> > +	int alloc_flags = ALLOC_WMARK_MIN | ALLOC_CPUSET;
> > +	const gfp_t wait = gfp_mask & __GFP_WAIT;
> > +
> > +	/*
> > +	 * The caller may dip into page reserves a bit more if the caller
> > +	 * cannot run direct reclaim, or if the caller has realtime scheduling
> > +	 * policy or is asking for __GFP_HIGH memory.  GFP_ATOMIC requests will
> > +	 * set both ALLOC_HARDER (!wait) and ALLOC_HIGH (__GFP_HIGH).
> > +	 */
> > +	if (gfp_mask & __GFP_HIGH)
> > +		alloc_flags |= ALLOC_HIGH;
> 
> This could be sped up by making ALLOC_HIGH==__GFP_HIGH (hack)

:-) 

> But really, the whole function can be elided on the fastpath.  Try the
> allocation with the current flags (and __GFP_NOWARN) and only if it
> failed will we try altering the flags to try harder?

It is slowpath only.

After Mel's patches the fast path looks like so:

        page = __get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
                        zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
                        preferred_zone, migratetype);
        if (unlikely(!page))
                page = __alloc_pages_slowpath(gfp_mask, order,
                                zonelist, high_zoneidx, nodemask,
                                preferred_zone, migratetype);


and gfp_to_alloc_flags() is only used in __alloc_pages_slowpath().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
