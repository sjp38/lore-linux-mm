Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC346B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 21:03:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id s63so78093620ioi.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 18:03:25 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id h129si44165779iof.164.2016.06.21.18.03.23
        for <linux-mm@kvack.org>;
        Tue, 21 Jun 2016 18:03:24 -0700 (PDT)
Date: Wed, 22 Jun 2016 11:03:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160622010320.GR12670@dastard>
References: <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
 <20160602232254.GR12670@dastard>
 <20160606122022.GH11895@dhcp22.suse.cz>
 <20160615072154.GF26977@dastard>
 <20160621142628.GG30848@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160621142628.GG30848@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Tue, Jun 21, 2016 at 04:26:28PM +0200, Michal Hocko wrote:
> On Wed 15-06-16 17:21:54, Dave Chinner wrote:
> [...]
> > Hopefully you can see the complexity of the issue - for an allocation
> > in the bmap btree code that could occur outside both inside and
> > outside of a transaction context, we've got to work out which of
> > those ~60 high level entry points would need to be annotated. And
> > then we have to ensure that in future we don't miss adding or
> > removing an annotation as we change the code deep inside the btree
> > implementation. It's the latter that is the long term maintainence
> > problem the hihg-level annotation approach introduces.
> 
> Sure I can see the complexity here. I might still see this over
> simplified but I originally thought that the annotation would be used at
> the highest level which never gets called from the transaction or other
> NOFS context. So all the layers down would inherit that automatically. I
> guess that such a place can be identified from the lockdep report by a
> trained eye.

Which, as I said before, effectively becomes "turn off lockdep
reclaim context checking at all XFS entry points". Yes, we could do
that, but it's a "big hammer" solution and there are more entry
points than there are memory allocations that need annotations....

> > > > I think such an annotation approach really requires per-alloc site
> > > > annotation, the reason for it should be more obvious from the
> > > > context. e.g. any function that does memory alloc and takes an
> > > > optional transaction context needs annotation. Hence, from an XFS
> > > > perspective, I think it makes more sense to add a new KM_ flag to
> > > > indicate this call site requirement, then jump through whatever
> > > > lockdep hoop is required within the kmem_* allocation wrappers.
> > > > e.g, we can ignore the new KM_* flag if we are in a transaction
> > > > context and so the flag is only activated in the situations were
> > > > we currently enforce an external GFP_NOFS context from the call
> > > > site.....
> > > 
> > > Hmm, I thought we would achive this by using the scope GFP_NOFS usage
> > > which would mark those transaction related conctexts and no lockdep
> > > specific workarounds would be needed...
> > 
> > There are allocations outside transaction context which need to be
> > GFP_NOFS - this is what KM_NOFS was originally intended for.
> 
> Is it feasible to mark those by the scope NOFS api as well and drop
> the direct KM_NOFS usage? This should help to identify those that are
> lockdep only and use the annotation to prevent from the false positives.

I don't understand what you are suggesting here. This all started
because we use GFP_NOFS in a handful of places to shut up lockdep
and you didn't want us to use GFP_NOFS like that. Now it sounds to
me like you are advocating setting unconditional GFP_NOFS allocation
contexts for entire XFS code paths - whether it's necessary or
not - to avoid problems with lockdep false positives.

I'm clearly not understanding something here....

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
