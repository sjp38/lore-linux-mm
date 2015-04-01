Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id CA7156B0032
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 17:39:08 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so67582533pdb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 14:39:08 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id kv3si4530742pbc.61.2015.04.01.14.39.06
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 14:39:07 -0700 (PDT)
Date: Thu, 2 Apr 2015 08:39:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Message-ID: <20150401213902.GE8465@dastard>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <20150326195822.GB28129@dastard>
 <20150327150509.GA21119@cmpxchg.org>
 <20150330003240.GB28621@dastard>
 <20150401151920.GB23824@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150401151920.GB23824@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Wed, Apr 01, 2015 at 05:19:20PM +0200, Michal Hocko wrote:
> On Mon 30-03-15 11:32:40, Dave Chinner wrote:
> > On Fri, Mar 27, 2015 at 11:05:09AM -0400, Johannes Weiner wrote:
> [...]
> > > GFP_NOFS sites are currently one of the sites that can deadlock inside
> > > the allocator, even though many of them seem to have fallback code.
> > > My reasoning here is that if you *have* an exit strategy for failing
> > > allocations that is smarter than hanging, we should probably use that.
> > 
> > We already do that for allocations where we can handle failure in
> > GFP_NOFS conditions. It is, however, somewhat useless if we can't
> > tell the allocator to try really hard if we've already had a failure
> > and we are already in memory reclaim conditions (e.g. a shrinker
> > trying to clean dirty objects so they can be reclaimed).
> > 
> > From that perspective, I think that this patch set aims force us
> > away from handling fallbacks ourselves because a) it makes GFP_NOFS
> > more likely to fail, and b) provides no mechanism to "try harder"
> > when we really need the allocation to succeed.
> 
> You can ask for this "try harder" by __GFP_HIGH flag. Would that help
> in your fallback case?

That dips into GFP_ATOMIC reserves, right? What is the impact on the
GFP_ATOMIC allocations that need it? We typically see network cards
fail GFP_ATOMIC allocations before XFS starts complaining about
allocation failures, so i suspect that this might just make things
worse rather than better...

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
