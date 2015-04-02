Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 49B036B0038
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 03:29:32 -0400 (EDT)
Received: by wgdm6 with SMTP id m6so76273054wgd.2
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 00:29:31 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy14si33893850wic.110.2015.04.02.00.29.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 02 Apr 2015 00:29:30 -0700 (PDT)
Date: Thu, 2 Apr 2015 09:29:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150402072926.GA2247@dhcp22.suse.cz>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
 <20150401213902.GE8465@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150401213902.GE8465@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Thu 02-04-15 08:39:02, Dave Chinner wrote:
> On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> > On Mon 30-03-15 11:32:40, Dave Chinner wrote:
> > > On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> > [...]
> > > > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > > > the allocator, even though many of them seem to have fallback code.
> > > > My reasoning here is that if you *have* an exit strategy for failing
> > > > allocations that is smarter than hanging, we should probably use that.
> > > 
> > > We already do that for allocations where we can handle failure in
> > > GFP_NOFS conditions. It is, however, somewhat useless if we can't
> > > tell the allocator to try really hard if we've already had a failure
> > > and we are already in memory reclaim conditions (e.g. a shrinker
> > > trying to clean dirty objects so they can be reclaimed).
> > > 
> > > From that perspective, I think that this patch set aims force us
> > > away from handling fallbacks ourselves because a) it makes GFP_NOFS
> > > more likely to fail, and b) provides no mechanism to "try harder"
> > > when we really need the allocation to succeed.
> > 
> > You can ask for this "try harder" by __GFP_HIGH flag. Would that help
> > in your fallback case?
> 
> That dips into GFP_ATOMIC reserves, right? What is the impact on the
> GFP_ATOMIC allocations that need it?

Yes the memory reserve is shared but the flag would be used only after
previous GFP_NOFS allocation has failed which means that that the system
is close to the OOM and chances for GFP_ATOMIC allocations (which are
GFP_NOWAIT and cannot perform any reclaim) success are quite low already.

> We typically see network cards fail GFP_ATOMIC allocations before XFS
> starts complaining about allocation failures, so i suspect that this
> might just make things worse rather than better...

My understanding is that GFP_ATOMIC allocation would fallback to
GFP_WAIT type of allocation in the deferred context in the networking
code. There would be some performance hit but again we are talking
about close to OOM conditions here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
