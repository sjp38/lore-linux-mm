Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D3A346B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 19:23:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s73so78465145pfs.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 16:23:39 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id se4si1494370pac.61.2016.06.02.16.23.37
        for <linux-mm@kvack.org>;
        Thu, 02 Jun 2016 16:23:38 -0700 (PDT)
Date: Fri, 3 Jun 2016 09:22:54 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160602232254.GR12670@dastard>
References: <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160602154619.GU1995@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Jun 02, 2016 at 05:46:19PM +0200, Michal Hocko wrote:
> On Thu 02-06-16 17:11:16, Peter Zijlstra wrote:
> > With scope I mostly meant the fact that you have two calls that you need
> > to pair up. That's not really nice as you can 'annotate' a _lot_ of code
> > in between. I prefer the narrower annotations where you annotate a
> > single specific site.
> 
> Yes, I can see you point. What I meant to say is that we would most
> probably end up with the following pattern
> 	lockdep_trace_alloc_enable()
> 	some_foo_with_alloc(gfp_mask);
> 	lockdep_trace_alloc_disable()
>
> and some_foo_with_alloc might be a lot of code.

That's the problem I see with this - the only way to make it
maintainable is to precede each enable/disable() pair with a comment
explaining *exactly* what those calls are protecting.  And that, in
itself, becomes a maintenance problem, because then code several
layers deep has no idea what context it is being called from and we
are likely to disable warnings in contexts where we probably
shouldn't be.

I think such an annotation approach really requires per-alloc site
annotation, the reason for it should be more obvious from the
context. e.g. any function that does memory alloc and takes an
optional transaction context needs annotation. Hence, from an XFS
perspective, I think it makes more sense to add a new KM_ flag to
indicate this call site requirement, then jump through whatever
lockdep hoop is required within the kmem_* allocation wrappers.
e.g, we can ignore the new KM_* flag if we are in a transaction
context and so the flag is only activated in the situations were
we currently enforce an external GFP_NOFS context from the call
site.....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
