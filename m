Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 26EFE6B01F4
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:38:09 -0400 (EDT)
Date: Fri, 23 Apr 2010 02:38:01 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100422163801.GZ5683@laptop>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com>
 <1271118255-21070-2-git-send-email-david@fromorbit.com>
 <20100418001514.GA26575@infradead.org>
 <20100419140039.GQ5683@laptop>
 <20100420004149.GA14744@dastard>
 <20100420083840.GR5683@laptop>
 <20100420103216.GK15130@dastard>
 <20100421084004.GS5683@laptop>
 <20100422163211.GA2478@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100422163211.GA2478@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 12:32:11PM -0400, Christoph Hellwig wrote:
> On Wed, Apr 21, 2010 at 06:40:04PM +1000, Nick Piggin wrote:
> > I'm saying that dynamic registration is no good, if we don't have a
> > way to order the shrinkers.
> 
> We can happily throw in a priority field into the shrinker structure,
> but at this stage in the release process I'd rather have an as simple
> as possible fix for the regression.  And just adding the context pointer
> which is a no-op for all existing shrinkers fits that scheme very well.
> 
> If it makes you happier I can queue up a patch to add the priorities
> for 2.6.35.  I think figuring out any meaningful priorities will be
> much harder than that, though.

I don't understand, it should be implemented like just all the other
shrinkers AFAIKS. Like the dcache one that has to shrink multiple
superblocks. There is absolutely no requirement for this API change
to implement it in XFS.

If you then add a patch to change the API and can show how it improves
the situation, then fine.

> 
> > > If a change of interface means that we end up with shorter call
> > > chains, less global state, more flexibilty, better batching and IO
> > > patterns, less duplication of code and algorithms and it doesn't
> > > cause any regressions, then where's the problem?
> > 
> > Yep that would all be great but I don't see how the interface change
> > enables any of that at all. It seems to me that the advantage goes
> > the other way because it doesn't put as much crap into your mount
> > structure and you end up with an useful traversable list of mounts as
> > a side-effect.
> 
> There really is not need for that.  The Linux VFS is designed to have
> superblocks independent, which actually is a good thing as global
> state gets in the way of scalability or just clean code.  Note that
> a mounts list would be even worse as filesystems basically are not
> concerned with mount points themselves.

But the shrinker list *is* a global list. The downside of it in the way
it was done in the XFS patch is that 1) it is much larger than a simple
list head, and 2) not usable by anything other then the shrinker.

OK, maybe there will never be other uses for it other than shrinker, but
that's not a disadvantage (just one less advantage).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
