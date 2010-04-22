Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2056B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 12:57:23 -0400 (EDT)
Date: Fri, 23 Apr 2010 02:57:11 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/2] mm: add context argument to shrinker callback
Message-ID: <20100422165711.GA5683@laptop>
References: <1271118255-21070-2-git-send-email-david@fromorbit.com>
 <20100418001514.GA26575@infradead.org>
 <20100419140039.GQ5683@laptop>
 <20100420004149.GA14744@dastard>
 <20100420083840.GR5683@laptop>
 <20100420103216.GK15130@dastard>
 <20100421084004.GS5683@laptop>
 <20100422163211.GA2478@infradead.org>
 <20100422163801.GZ5683@laptop>
 <20100422164247.GA15882@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100422164247.GA15882@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 12:42:47PM -0400, Christoph Hellwig wrote:
> On Fri, Apr 23, 2010 at 02:38:01AM +1000, Nick Piggin wrote:
> > I don't understand, it should be implemented like just all the other
> > shrinkers AFAIKS. Like the dcache one that has to shrink multiple
> > superblocks. There is absolutely no requirement for this API change
> > to implement it in XFS.
> 
> The dcache shrinker is an example for a complete mess.

I don't know. It's not really caused by not registering multiple
shrinkers. It seems to be caused more by the locking, which is not
going away when you have multiple shrinkers.

The XFS patch seems to be pinning the mount structure when it is
registered, so it would have no such locking/refcounting problems
using a private list AFAIKS.


> > But the shrinker list *is* a global list. The downside of it in the way
> > it was done in the XFS patch is that 1) it is much larger than a simple
> > list head, and 2) not usable by anything other then the shrinker.
> 
> It is an existing global list just made more useful.  Whenever a driver
> has muliple instances of pool that need shrinking this comes in useful,
> it's not related to filesystems at all. 

I would say less useful, because shrinker structure cannot be used
by anything but the shrinker, wheras a private list can be used by
anything, including the applicable shrinker.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
