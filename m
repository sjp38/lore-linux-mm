Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9E73B6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 18:16:06 -0400 (EDT)
Date: Fri, 30 Jul 2010 15:06:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-Id: <20100730150601.199c5618.akpm@linux-foundation.org>
In-Reply-To: <1280497020-22816-7-git-send-email-mel@csn.ul.ie>
References: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
	<1280497020-22816-7-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010 14:37:00 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> There are a number of cases where pages get cleaned but two of concern
> to this patch are;
>   o When dirtying pages, processes may be throttled to clean pages if
>     dirty_ratio is not met.

Ambiguous.  I assume you meant "if dirty_ratio is exceeded".

>   o Pages belonging to inodes dirtied longer than
>     dirty_writeback_centisecs get cleaned.
> 
> The problem for reclaim is that dirty pages can reach the end of the LRU if
> pages are being dirtied slowly so that neither the throttling or a flusher
> thread waking periodically cleans them.
> 
> Background flush is already cleaning old or expired inodes first but the
> expire time is too far in the future at the time of page reclaim. To mitigate
> future problems, this patch wakes flusher threads to clean 4M of data -
> an amount that should be manageable without causing congestion in many cases.
> 
> Ideally, the background flushers would only be cleaning pages belonging
> to the zone being scanned but it's not clear if this would be of benefit
> (less IO) or not (potentially less efficient IO if an inode is scattered
> across multiple zones).
> 

Sigh.  We have sooo many problems with writeback and latency.  Read
https://bugzilla.kernel.org/show_bug.cgi?id=12309 and weep.  Everyone's
running away from the issue and here we are adding code to solve some
alleged stack-overflow problem which seems to be largely a non-problem,
by making changes which may worsen our real problems.

direct-reclaim wants to write a dirty page because that page is in the
zone which the caller wants to allcoate from!  Telling the flusher
threads to perform generic writeback will sometimes cause them to just
gum the disk up with pages from different zones, making it even
harder/slower to allocate a page from the zones we're interested in,
no?

If/when that happens, the problem will be rare, subtle, will take a
long time to get reported and will take years to understand and fix and
will probably be reported in the monster bug report which everyone's
hiding from anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
