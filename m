Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id D038E6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 10:50:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so25384595lfh.2
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:50:51 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id pc5si1134567wjb.182.2016.06.02.07.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 07:50:50 -0700 (PDT)
Received: by mail-wm0-f45.google.com with SMTP id n184so83879155wmn.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 07:50:50 -0700 (PDT)
Date: Thu, 2 Jun 2016 16:50:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160602145048.GS1995@dhcp22.suse.cz>
References: <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160601181617.GV3190@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed 01-06-16 20:16:17, Peter Zijlstra wrote:
> On Wed, Jun 01, 2016 at 03:17:58PM +0200, Michal Hocko wrote:
> > Thanks Dave for your detailed explanation again! Peter do you have any
> > other idea how to deal with these situations other than opt out from
> > lockdep reclaim machinery?
> > 
> > If not I would rather go with an annotation than a gfp flag to be honest
> > but if you absolutely hate that approach then I will try to check wheter
> > a CONFIG_LOCKDEP GFP_FOO doesn't break something else. Otherwise I would
> > steal the description from Dave's email and repost my patch.
> > 
> > I plan to repost my scope gfp patches in few days and it would be good
> > to have some mechanism to drop those GFP_NOFS to paper over lockdep
> > false positives for that.
> 
> Right; sorry I got side-tracked in other things again.
> 
> So my favourite is the dedicated GFP flag, but if that's unpalatable for
> the mm folks then something like the below might work. It should be
> similar in effect to your proposal, except its more limited in scope.
[...]
> @@ -2876,11 +2883,36 @@ static void __lockdep_trace_alloc(gfp_t gfp_mask, unsigned long flags)
>  	if (DEBUG_LOCKS_WARN_ON(irqs_disabled_flags(flags)))
>  		return;
>  
> +	/*
> +	 * Skip _one_ allocation as per the lockdep_skip_alloc() request.
> +	 * Must be done last so that we don't loose the annotation for
> +	 * GFP_ATOMIC like things from IRQ or other nesting contexts.
> +	 */
> +	if (current->lockdep_reclaim_gfp & __GFP_SKIP_ALLOC) {
> +		current->lockdep_reclaim_gfp &= ~__GFP_SKIP_ALLOC;
> +		return;
> +	}
> +
>  	mark_held_locks(curr, RECLAIM_FS);
>  }

I might be missing something but does this work actually? Say you would
want a kmalloc(size), it would call
slab_alloc_node
  slab_pre_alloc_hook
    lockdep_trace_alloc
[...]
  ____cache_alloc_node
    cache_grow_begin
      kmem_getpages
        __alloc_pages_node
	  __alloc_pages_nodemask
	    lockdep_trace_alloc

I understand your concerns about the scope but usually all allocations
have to be __GFP_NOFS or none in the same scope so I would see it as a
huge deal.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
