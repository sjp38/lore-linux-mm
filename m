Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 288B06B0253
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 18:58:22 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id u81so49853302oia.3
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 15:58:22 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 65si2944343iow.43.2016.06.22.15.58.19
        for <linux-mm@kvack.org>;
        Wed, 22 Jun 2016 15:58:20 -0700 (PDT)
Date: Thu, 23 Jun 2016 08:58:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160622225816.GY12670@dastard>
References: <20160601181617.GV3190@twins.programming.kicks-ass.net>
 <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
 <20160602232254.GR12670@dastard>
 <20160606122022.GH11895@dhcp22.suse.cz>
 <20160615072154.GF26977@dastard>
 <20160621142628.GG30848@dhcp22.suse.cz>
 <20160622010320.GR12670@dastard>
 <20160622123822.GG9208@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622123822.GG9208@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, Jun 22, 2016 at 02:38:22PM +0200, Michal Hocko wrote:
> On Wed 22-06-16 11:03:20, Dave Chinner wrote:
> > On Tue, Jun 21, 2016 at 04:26:28PM +0200, Michal Hocko wrote:
> > > On Wed 15-06-16 17:21:54, Dave Chinner wrote:
> [...]
> > > > There are allocations outside transaction context which need to be
> > > > GFP_NOFS - this is what KM_NOFS was originally intended for.
> > > 
> > > Is it feasible to mark those by the scope NOFS api as well and drop
> > > the direct KM_NOFS usage? This should help to identify those that are
> > > lockdep only and use the annotation to prevent from the false positives.
> > 
> > I don't understand what you are suggesting here. This all started
> > because we use GFP_NOFS in a handful of places to shut up lockdep
> > and you didn't want us to use GFP_NOFS like that. Now it sounds to
> > me like you are advocating setting unconditional GFP_NOFS allocation
> > contexts for entire XFS code paths - whether it's necessary or
> > not - to avoid problems with lockdep false positives.
> 
> No, I meant only those paths which need GFP_NOFS for other than lockdep
> purposes would use the scope api.
> 
> Anyway, it seems that we are not getting closer to a desired solution
> here. Or I am not following it at least...
> 
> It seems that we have effectively two possibilities (from the
> MM/lockdep) POV. Either add an explicit API to disable the reclaim
> lockdep machinery for all allocation in a certain scope or a GFP mask
> to to achieve the same for a particular allocation. Which one would work
> better for the xfs usecase?

As I've said - if we annotate the XFS call sites appropriately (e.g.
KM_NOLOCKDEP rather than KM_NOFS), we don't care what lockdep
mechanism is used to turn off warnings as it will be wholly
encapsulated inside kmem_alloc() and friends.  This will end up
similar to how we are currently encapsulate the memalloc_noio_save()
wrappers in kmem_zalloc_large().

IOWs, it doesn't matter to XFS whether it be a GFP flag or a PF flag
here, because it's not going to be exposed to the higher level code.

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
