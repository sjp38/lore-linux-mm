Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0B51F6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 15:55:42 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id z14so22586041igp.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 12:55:42 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id c14si21380850iod.73.2016.01.28.12.55.40
        for <linux-mm@kvack.org>;
        Thu, 28 Jan 2016 12:55:41 -0800 (PST)
Date: Fri, 29 Jan 2016 07:55:25 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [LSF/MM TOPIC] proposals for topics
Message-ID: <20160128205525.GO6033@dastard>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125184559.GE29291@cmpxchg.org>
 <20160126095022.GC27563@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160126095022.GC27563@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Tue, Jan 26, 2016 at 10:50:23AM +0100, Michal Hocko wrote:
> On Mon 25-01-16 13:45:59, Johannes Weiner wrote:
> > Hi Michal,
> > 
> > On Mon, Jan 25, 2016 at 02:33:57PM +0100, Michal Hocko wrote:
> > > - GFP_NOFS is another one which would be good to discuss. Its primary
> > >   use is to prevent from reclaim recursion back into FS. This makes
> > >   such an allocation context weaker and historically we haven't
> > >   triggered OOM killer and rather hopelessly retry the request and
> > >   rely on somebody else to make a progress for us. There are two issues
> > >   here.
> > >   First we shouldn't retry endlessly and rather fail the allocation and
> > >   allow the FS to handle the error. As per my experiments most FS cope
> > >   with that quite reasonably. Btrfs unfortunately handles many of those
> > >   failures by BUG_ON which is really unfortunate.
> > 
> > Are there any new datapoints on how to deal with failing allocations?
> > IIRC the conclusion last time was that some filesystems simply can't
> > support this without a reservation system - which I don't believe
> > anybody is working on. Does it make sense to rehash this when nothing
> > really changed since last time?
> 
> There have been patches posted during the year to fortify those places
> which cannot cope with allocation failures for ext[34] and testing
> has shown that ext* resp. xfs are quite ready to see NOFS allocation
> failures.

The XFS situation is compeletely unchanged from last year, and the
fact that you say it handles NOFS allocation failures just fine
makes me seriously question your testing methodology.

In XFS, *any* memory allocation failure during a transaction will
either cause a panic through null point deference (because we don't
check for allocation failure in most cases) or a filesystem
shutdown (in the cases where we do check). If you haven't seen these
behaviours, then you haven't been failing memory allocations during
filesystem modifications.

We need to fundamentally change error handling in transactions in
XFS to allow arbitrary memory allocation to fail. That is, we need
to implement a full transaction rollback capability so we can back
out changes made during the transaction before the error occurred.
That's a major amount of work, and I'm probably not going to do
anything on this in the next year as it's low priority because what
we have now works.

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
