Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C47626B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:32:19 -0400 (EDT)
Date: Thu, 22 Apr 2010 12:32:11 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100422163211.GA2478@infradead.org>
References: <1271118255-21070-1-git-send-email-david@fromorbit.com> <1271118255-21070-2-git-send-email-david@fromorbit.com> <20100418001514.GA26575@infradead.org> <20100419140039.GQ5683@laptop> <20100420004149.GA14744@dastard> <20100420083840.GR5683@laptop> <20100420103216.GK15130@dastard> <20100421084004.GS5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100421084004.GS5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 21, 2010 at 06:40:04PM +1000, Nick Piggin wrote:
> I'm saying that dynamic registration is no good, if we don't have a
> way to order the shrinkers.

We can happily throw in a priority field into the shrinker structure,
but at this stage in the release process I'd rather have an as simple
as possible fix for the regression.  And just adding the context pointer
which is a no-op for all existing shrinkers fits that scheme very well.

If it makes you happier I can queue up a patch to add the priorities
for 2.6.35.  I think figuring out any meaningful priorities will be
much harder than that, though.

> > If a change of interface means that we end up with shorter call
> > chains, less global state, more flexibilty, better batching and IO
> > patterns, less duplication of code and algorithms and it doesn't
> > cause any regressions, then where's the problem?
> 
> Yep that would all be great but I don't see how the interface change
> enables any of that at all. It seems to me that the advantage goes
> the other way because it doesn't put as much crap into your mount
> structure and you end up with an useful traversable list of mounts as
> a side-effect.

There really is not need for that.  The Linux VFS is designed to have
superblocks independent, which actually is a good thing as global
state gets in the way of scalability or just clean code.  Note that
a mounts list would be even worse as filesystems basically are not
concerned with mount points themselves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
