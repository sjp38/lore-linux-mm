Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D5ADA6B01AD
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:44:13 -0400 (EDT)
Date: Wed, 16 Jun 2010 16:43:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 08/12] vmscan: Setup pagevec as late as possible in
 shrink_inactive_list()
Message-Id: <20100616164309.254b1a0d.akpm@linux-foundation.org>
In-Reply-To: <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
	<1276514273-27693-9-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Jun 2010 12:17:49 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> uses significant amounts of stack doing this. This patch splits
> shrink_inactive_list() to take the stack usage out of the main path so
> that callers to writepage() do not contain an unused pagevec on the
> stack.

You can get the entire pagevec off the stack - just make it a
static-to-shrink_inactive_list() pagevec-per-cpu.

Locking just requires pinning to a CPU.  We could trivially co-opt
shrink_inactive_list()'s spin_lock_irq() for that, but
pagevec_release() can be relatively expensive so it'd be sad to move
that inside spin_lock_irq().  It'd be better to slap a
get_cpu()/put_cpu() around the whole thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
