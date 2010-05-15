Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1DBCF6B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 21:15:47 -0400 (EDT)
Date: Sat, 15 May 2010 11:15:23 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Defrag in shrinkers (was Re: [PATCH 0/5] Per-superblock
 shrinkers)
Message-ID: <20100515011523.GG8120@dastard>
References: <1273821863-29524-1-git-send-email-david@fromorbit.com>
 <alpine.DEB.2.00.1005141244380.9466@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005141244380.9466@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 12:46:52PM -0500, Christoph Lameter wrote:
> Would it also be possible to add some defragmentation logic when you
> revise the shrinkers? Here is a prototype patch that would allow you to
> determine the other objects sitting in the same page as a given object.
> 
> With that I hope that you have enough information to determine if its
> worth to evict the other objects as well to reclaim the slab page.

I'll have a think about how this might fit in - the real problem is
when the list returns objects that belong to a different superblock.
We can only safely check whether the object belongs to the current
superblock - to check if it belongs to a different sb we a lot of
locks and reference counting to juggle. That would require
re-introducing all the muck (and then some) that this patchset
removes from the shrinkers.

Perhaps just freeing the objects that belong to the current sb would
be sufficient to realise significant improvements (will be fine for
systems that only have one active or dominant filesystem), but i
think some experimentation would be needed.

The that brings us to test cases - we need a good one. I think we
need to re-evaluate where we stand with regard to slab fragmentation
(which probably hasn't changed much), and we need to be able to
quantify the amount of improvement the increase in complexity will
provide.  I don't have anything close to hand to generate such
fragmentation, so it might take a little time to write a test that
does the IO patterns I know will generate problems...

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
