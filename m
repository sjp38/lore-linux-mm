Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D4E416B01AF
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 06:30:35 -0400 (EDT)
Date: Thu, 17 Jun 2010 11:30:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/12] vmscan: Setup pagevec as late as possible in
	shrink_inactive_list()
Message-ID: <20100617103012.GA25567@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-9-git-send-email-mel@csn.ul.ie> <20100616164309.254b1a0d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100616164309.254b1a0d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 16, 2010 at 04:43:09PM -0700, Andrew Morton wrote:
> On Mon, 14 Jun 2010 12:17:49 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> > uses significant amounts of stack doing this. This patch splits
> > shrink_inactive_list() to take the stack usage out of the main path so
> > that callers to writepage() do not contain an unused pagevec on the
> > stack.
> 
> You can get the entire pagevec off the stack - just make it a
> static-to-shrink_inactive_list() pagevec-per-cpu.
> 

That idea has been floated as well. I didn't pursue it because Dave
said that giving page reclaim a stack diet was never going to be the
full solution so I didn't think the complexity was justified.

I kept some of the stack reduction stuff because a) it was there and b)
it would give kswapd extra headroom when calling writepage.

> Locking just requires pinning to a CPU.  We could trivially co-opt
> shrink_inactive_list()'s spin_lock_irq() for that, but
> pagevec_release() can be relatively expensive so it'd be sad to move
> that inside spin_lock_irq().  It'd be better to slap a
> get_cpu()/put_cpu() around the whole thing.
> 

It'd be something interesting to try out when nothing else was happening but
I'm not going to focus on it for the moment unless I think it will really
help this stack overflow problem.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
