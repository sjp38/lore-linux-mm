Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id CAB396B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 07:31:58 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so9286513lbb.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 04:31:58 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id k10si9813201wjf.224.2016.05.18.04.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 04:31:57 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id g17so5512747wme.2
        for <linux-mm@kvack.org>; Wed, 18 May 2016 04:31:56 -0700 (PDT)
Date: Wed, 18 May 2016 13:31:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160518113155.GG21654@dhcp22.suse.cz>
References: <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160518072005.GA3193@twins.programming.kicks-ass.net>
 <20160518082538.GE21654@dhcp22.suse.cz>
 <20160518094952.GB3193@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518094952.GB3193@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed 18-05-16 11:49:52, Peter Zijlstra wrote:
> On Wed, May 18, 2016 at 10:25:39AM +0200, Michal Hocko wrote:
> > On Wed 18-05-16 09:20:05, Peter Zijlstra wrote:
> > > On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> > > > On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> > [...]
> > > > > In any case; would something like this work for you? Its entirely
> > > > > untested, but the idea is to mark an entire class to skip reclaim
> > > > > validation, instead of marking individual sites.
> > > > 
> > > > Probably would, but it seems like swatting a fly with runaway
> > > > train. I'd much prefer a per-site annotation (e.g. as a GFP_ flag)
> > > > so that we don't turn off something that will tell us we've made a
> > > > mistake while developing new code...
> > > 
> > > Fair enough; if the mm folks don't object to 'wasting' a GFP flag on
> > > this the below ought to do I think.
> > 
> > GFP flag space is quite scarse. 
> 
> There's still 5 or so bits available, and you could always make gfp_t
> u64.

It seems we have some places where we encode further data into the same
word as gfp_mask (radix tree tags and mapping_flags). From a quick
glance they should be OK even with __GFP_BITS_SHIFT increased to 27 but
this tells us that we shouldn't consume them without a good reason.
 
> > Especially when it would be used only
> > for lockdep configurations which are mostly disabled. Why cannot we go
> > with an explicit disable/enable API I have proposed? 
> 
> It has unbounded scope. And in that respect the GFP flag thingy is wider
> than I'd like too, it avoids setting the state for all held locks, even
> though we'd only like to avoid setting it for one class.
>
> So ideally we'd combine the GFP flag with the previously proposed skip
> flag to only avoid marking the one class while keeping everything
> working for all other held locks.

This is definitely your call but I would prefer starting with something
simple and extend it when we find out that the scope/gfp opt-out hides
real bugs or it is insufficient for other reasons. I do not this opt out
to be used much, quite contrary. We do not hear about false positives
reclaim lockdep lockups very often - except for very complex reclaim
implementations which are quite uncommon.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
