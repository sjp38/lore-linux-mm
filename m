Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 660C2828E1
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 10:26:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so13496844lfe.0
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:26:31 -0700 (PDT)
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com. [209.85.217.174])
        by mx.google.com with ESMTPS id j131si845238lfb.8.2016.06.21.07.26.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jun 2016 07:26:30 -0700 (PDT)
Received: by mail-lb0-f174.google.com with SMTP id oe3so12199481lbb.1
        for <linux-mm@kvack.org>; Tue, 21 Jun 2016 07:26:29 -0700 (PDT)
Date: Tue, 21 Jun 2016 16:26:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160621142628.GG30848@dhcp22.suse.cz>
References: <20160519081146.GS3193@twins.programming.kicks-ass.net>
 <20160520001714.GC26977@dastard>
 <20160601131758.GO26601@dhcp22.suse.cz>
 <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
 <20160602232254.GR12670@dastard>
 <20160606122022.GH11895@dhcp22.suse.cz>
 <20160615072154.GF26977@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160615072154.GF26977@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed 15-06-16 17:21:54, Dave Chinner wrote:
[...]
> Hopefully you can see the complexity of the issue - for an allocation
> in the bmap btree code that could occur outside both inside and
> outside of a transaction context, we've got to work out which of
> those ~60 high level entry points would need to be annotated. And
> then we have to ensure that in future we don't miss adding or
> removing an annotation as we change the code deep inside the btree
> implementation. It's the latter that is the long term maintainence
> problem the hihg-level annotation approach introduces.

Sure I can see the complexity here. I might still see this over
simplified but I originally thought that the annotation would be used at
the highest level which never gets called from the transaction or other
NOFS context. So all the layers down would inherit that automatically. I
guess that such a place can be identified from the lockdep report by a
trained eye.
 
> > > I think such an annotation approach really requires per-alloc site
> > > annotation, the reason for it should be more obvious from the
> > > context. e.g. any function that does memory alloc and takes an
> > > optional transaction context needs annotation. Hence, from an XFS
> > > perspective, I think it makes more sense to add a new KM_ flag to
> > > indicate this call site requirement, then jump through whatever
> > > lockdep hoop is required within the kmem_* allocation wrappers.
> > > e.g, we can ignore the new KM_* flag if we are in a transaction
> > > context and so the flag is only activated in the situations were
> > > we currently enforce an external GFP_NOFS context from the call
> > > site.....
> > 
> > Hmm, I thought we would achive this by using the scope GFP_NOFS usage
> > which would mark those transaction related conctexts and no lockdep
> > specific workarounds would be needed...
> 
> There are allocations outside transaction context which need to be
> GFP_NOFS - this is what KM_NOFS was originally intended for.

Is it feasible to mark those by the scope NOFS api as well and drop
the direct KM_NOFS usage? This should help to identify those that are
lockdep only and use the annotation to prevent from the false positives.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
