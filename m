Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 272526B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 20:40:06 -0400 (EDT)
Date: Tue, 20 Apr 2010 10:41:49 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100420004149.GA14744@dastard>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com>
 <1271118255-21070-2-git-send-email-david@fromorbit.com>
 <20100418001514.GA26575@infradead.org>
 <20100419140039.GQ5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100419140039.GQ5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 12:00:39AM +1000, Nick Piggin wrote:
> On Sat, Apr 17, 2010 at 08:15:14PM -0400, Christoph Hellwig wrote:
> > Any chance we can still get this into 2.6.34?  It's really needed to fix
> > a regression in XFS that would be hard to impossible to work around
> > inside the fs.  While it touches quite a few places the changes are
> > trivial and well understood.
> 
> Why do you even need this context argument?  Reclaim is not doing anything
> smart about this, it would just call each call shrinker in turn.

It's not being smart, but it is detemining how many objects to
reclaim in each shrinker call based on memory pressure and the
number of reclimable objects in the cache the shrinker works on.
That's exactly the semantics I want for per-filesystem inode cache
reclaim.

> Do you not have an easily traversable list of mountpoints?

No, XFS does not have one, and I'm actively trying to remove any
global state that crosses mounts that does exist (e.g. the global
dquot caches and freelist).

> Can you just
> make a list of them? It would be cheaper than putting a whole shrinker
> structure into them anyway.

It's not cheaper or simpler. To make it work properly, I'd
need to aggregate counters over all the filesystems in the list,
work out how much to reclaim from each, etc. It is quite messy
compared to deferecing the context to check one variable and either
return or invoke the existing inode reclaim code.

I also don't want to have a situation where i have to implement
fairness heuristics to avoid reclaiming one filesystem too much or
only end up reclaiming one or two inodes per filesystem per shrinker
call because of the number of filesytems is similar to the shrinker
batch size.  The high level shrinker code already does this reclaim
proportioning and does it far better than can be done in the scope
of a shrinker callback. IOWs, adding a context allows XFS to do
inode reclaim far more efficiently than if it was implemented
through global state and a single shrinker.

FWIW, we have this problem in the inode and dentry cache - we've got
all sorts of complexity for being fair about reclaiming across all
superblocks. I don't want to duplicate that complexity - instead I
want to avoid it entirely.

> The main reason I would be against proliferation of dynamic shrinker
> registration would be that it could change reclaim behaviour depending
> on how they get ordered (in the cache the caches are semi-dependent,
> like inode cache and dentry cache).

Adding a context does not change that implicit ordering based on
registration order. Any filesystem based shrinker is going to be
registered after the core infrastructure shrnikers, so they are not
going to perturb the current ordering.

And if this is enough of a problem to disallow context based cache
shrinkers, then lets fix the interface so that we encode the
dependencies explicitly in the registration interface rather than
doing it implicitly.

IOWs, I don't think this is a valid reason for not allowing a
context to be passed with a shrinker because it is easily fixed.

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
