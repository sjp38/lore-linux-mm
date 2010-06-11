Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9F96B01CA
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 08:33:42 -0400 (EDT)
Date: Fri, 11 Jun 2010 13:33:20 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
	and use a_ops->writepages() where possible
Message-ID: <20100611123320.GA8798@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie> <20100610225749.c8cc3bc3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100610225749.c8cc3bc3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jun 10, 2010 at 10:57:49PM -0700, Andrew Morton wrote:
> On Tue,  8 Jun 2010 10:02:19 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > To summarise, there are two big problems with page reclaim right now. The
> > first is that page reclaim uses a_op->writepage to write a back back
> > under the page lock which is inefficient from an IO perspective due to
> > seeky patterns.
> 
> No it isn't.  If we have a pile of file-contiguous, disk-contiguous
> dirty pages on the tail of the LRU then the single writepage()s will
> work just fine due to request merging.
> 

Ok, I was under the mistaken impression that filesystems wanted to be
given ranges of pages where possible. Considering that there has been no
reaction to the patch in question from the filesystem people cc'd, I'll
drop the problem for now.

> 
> 
> Look.  This is getting very frustrating.  I keep saying the same thing
> and keep getting ignored.  Once more:
> 
> 	WE BROKE IT!
> 
> 	PLEASE STOP WRITING CODE!
> 
> 	FIND OUT HOW WE BROKE IT!
> 
> Loud enough yet?
> 

Yep. I've started a new series of tests that capture the trace points
during each test to get some data on how many dirty pages are really
being written back. They takes a long time to complete unfortunately.

> It used to be the case that only very small amounts of IO occurred in
> page reclaim - the vast majority of writeback happened within
> write()->balance_dirty_pages().  Then (and I think it was around 2.6.12)
> we broke it, and page reclaim started doing lots of writeout.
> 

Ok, I'll work out exactly how many dirty pages are being  written back
then. The data I have at the moment covers the whole test, so I cannot
be certain if all the writeback happened during one stress test or
whether it's a comment event.

> So the thing to do is to either find out how we broke it and see if it
> can be repaired, or change the VM so that it doesn't do so much
> LRU-based writeout.  Rather than fiddling around trying to make the
> we-broke-it code run its brokenness faster.
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
