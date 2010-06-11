Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 12F696B0071
	for <linux-mm@kvack.org>; Fri, 11 Jun 2010 01:58:28 -0400 (EDT)
Date: Thu, 10 Jun 2010 22:57:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-Id: <20100610225749.c8cc3bc3.akpm@linux-foundation.org>
In-Reply-To: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 10:02:19 +0100 Mel Gorman <mel@csn.ul.ie> wrote:

> To summarise, there are two big problems with page reclaim right now. The
> first is that page reclaim uses a_op->writepage to write a back back
> under the page lock which is inefficient from an IO perspective due to
> seeky patterns.

No it isn't.  If we have a pile of file-contiguous, disk-contiguous
dirty pages on the tail of the LRU then the single writepage()s will
work just fine due to request merging.



Look.  This is getting very frustrating.  I keep saying the same thing
and keep getting ignored.  Once more:

	WE BROKE IT!

	PLEASE STOP WRITING CODE!

	FIND OUT HOW WE BROKE IT!

Loud enough yet?

It used to be the case that only very small amounts of IO occurred in
page reclaim - the vast majority of writeback happened within
write()->balance_dirty_pages().  Then (and I think it was around 2.6.12)
we broke it, and page reclaim started doing lots of writeout.

So the thing to do is to either find out how we broke it and see if it
can be repaired, or change the VM so that it doesn't do so much
LRU-based writeout.  Rather than fiddling around trying to make the
we-broke-it code run its brokenness faster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
