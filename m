Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id B63716B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 05:49:57 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ke5so61785715pad.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 02:49:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c1si11160894pas.37.2016.05.18.02.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 02:49:56 -0700 (PDT)
Date: Wed, 18 May 2016 11:49:52 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160518094952.GB3193@twins.programming.kicks-ass.net>
References: <20160512080321.GA18496@dastard>
 <20160513160341.GW20141@dhcp22.suse.cz>
 <20160516104130.GK3193@twins.programming.kicks-ass.net>
 <20160516130519.GJ23146@dhcp22.suse.cz>
 <20160516132541.GP3193@twins.programming.kicks-ass.net>
 <20160516231056.GE18496@dastard>
 <20160517144912.GZ3193@twins.programming.kicks-ass.net>
 <20160517223549.GV26977@dastard>
 <20160518072005.GA3193@twins.programming.kicks-ass.net>
 <20160518082538.GE21654@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160518082538.GE21654@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Wed, May 18, 2016 at 10:25:39AM +0200, Michal Hocko wrote:
> On Wed 18-05-16 09:20:05, Peter Zijlstra wrote:
> > On Wed, May 18, 2016 at 08:35:49AM +1000, Dave Chinner wrote:
> > > On Tue, May 17, 2016 at 04:49:12PM +0200, Peter Zijlstra wrote:
> [...]
> > > > In any case; would something like this work for you? Its entirely
> > > > untested, but the idea is to mark an entire class to skip reclaim
> > > > validation, instead of marking individual sites.
> > > 
> > > Probably would, but it seems like swatting a fly with runaway
> > > train. I'd much prefer a per-site annotation (e.g. as a GFP_ flag)
> > > so that we don't turn off something that will tell us we've made a
> > > mistake while developing new code...
> > 
> > Fair enough; if the mm folks don't object to 'wasting' a GFP flag on
> > this the below ought to do I think.
> 
> GFP flag space is quite scarse. 

There's still 5 or so bits available, and you could always make gfp_t
u64.

> Especially when it would be used only
> for lockdep configurations which are mostly disabled. Why cannot we go
> with an explicit disable/enable API I have proposed? 

It has unbounded scope. And in that respect the GFP flag thingy is wider
than I'd like too, it avoids setting the state for all held locks, even
though we'd only like to avoid setting it for one class.

So ideally we'd combine the GFP flag with the previously proposed skip
flag to only avoid marking the one class while keeping everything
working for all other held locks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
