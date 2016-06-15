Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 22E0B6B007E
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 03:22:13 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x6so23205426oif.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 00:22:13 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id f123si2176970ith.96.2016.06.15.00.22.10
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 00:22:12 -0700 (PDT)
Date: Wed, 15 Jun 2016 17:21:54 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160615072154.GF26977@dastard>
References: <20160517223549.GV26977@dastard>
 <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
 <20160602232254.GR12670@dastard>
 <20160606122022.GH11895@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606122022.GH11895@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

[sorry for the slow repsonse - been on holidays]

On Mon, Jun 06, 2016 at 02:20:22PM +0200, Michal Hocko wrote:
> On Fri 03-06-16 09:22:54, Dave Chinner wrote:
> > On Thu, Jun 02, 2016 at 05:46:19PM +0200, Michal Hocko wrote:
> > > On Thu 02-06-16 17:11:16, Peter Zijlstra wrote:
> > > > With scope I mostly meant the fact that you have two calls that you need
> > > > to pair up. That's not really nice as you can 'annotate' a _lot_ of code
> > > > in between. I prefer the narrower annotations where you annotate a
> > > > single specific site.
> > > 
> > > Yes, I can see you point. What I meant to say is that we would most
> > > probably end up with the following pattern
> > > 	lockdep_trace_alloc_enable()
> > > 	some_foo_with_alloc(gfp_mask);
> > > 	lockdep_trace_alloc_disable()
> > >
> > > and some_foo_with_alloc might be a lot of code.
> > 
> > That's the problem I see with this - the only way to make it
> > maintainable is to precede each enable/disable() pair with a comment
> > explaining *exactly* what those calls are protecting.  And that, in
> > itself, becomes a maintenance problem, because then code several
> > layers deep has no idea what context it is being called from and we
> > are likely to disable warnings in contexts where we probably
> > shouldn't be.
> 
> I am not sure I understand what you mean here. I thought the problem is
> that:
> 
> func_A (!trans. context)		func_B (trans. context)
>  foo1()					  foo2()
>    bar(inode, GFP_KERNEL)		    bar(inode, GFP_NOFS)
> 
> so bar(inode, gfp) can be called from two different contexts which
> would confuse the lockdep.

Yes, that's the core of the problem. What I think you are missing is
the scale of the problem.

> And the workaround would be annotating bar
> depending on the context it is called from - either pass a special gfp
> flag or do disable/enable thing. In both cases that anotation should be
> global for the whole func_A, no? Or is it possible that something in
> that path would really need a reclaim lockdep detection?

The problem is that there are cases where the call stack that leads
to bar() has many different entry points. See, for example, the
xfs_bmapi*() interfaces.  They all end up in the same low level
btree traversal code (and hence memory allocation points).
xfs_bmapi_read() can be called from both inside and outside
transaction context and there's ~30 callers we'd have to audit and
annotate. Then there's ~10 callers of xfs_bmapi_write which are all
within transaction context.

And then there's xfs_bmapi_delay(), which can end up in the same
low level code outside transaction context. Then there's
10 callers of xfs_bunmapi(), which runs both inside and outside
transaction context, too. Add to that all the miscellenous points
that can read extents off disk, and you get another ~12 entry
points.

Hopefully you can see the complexity of the issue - for an allocation
in the bmap btree code that could occur outside both inside and
outside of a transaction context, we've got to work out which of
those ~60 high level entry points would need to be annotated. And
then we have to ensure that in future we don't miss adding or
removing an annotation as we change the code deep inside the btree
implementation. It's the latter that is the long term maintainence
problem the hihg-level annotation approach introduces.

> > I think such an annotation approach really requires per-alloc site
> > annotation, the reason for it should be more obvious from the
> > context. e.g. any function that does memory alloc and takes an
> > optional transaction context needs annotation. Hence, from an XFS
> > perspective, I think it makes more sense to add a new KM_ flag to
> > indicate this call site requirement, then jump through whatever
> > lockdep hoop is required within the kmem_* allocation wrappers.
> > e.g, we can ignore the new KM_* flag if we are in a transaction
> > context and so the flag is only activated in the situations were
> > we currently enforce an external GFP_NOFS context from the call
> > site.....
> 
> Hmm, I thought we would achive this by using the scope GFP_NOFS usage
> which would mark those transaction related conctexts and no lockdep
> specific workarounds would be needed...

There are allocations outside transaction context which need to be
GFP_NOFS - this is what KM_NOFS was originally intended for. We need to
disambiguate the two cases where we use KM_NOFS to shut up lockdep
vs the cases where it is necessary to prevent reclaim deadlocks.

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
