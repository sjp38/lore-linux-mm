Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 607EE6B0012
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 05:51:06 -0400 (EDT)
Date: Tue, 7 Jun 2011 10:51:02 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] Fix page isolated count mismatch
Message-ID: <20110607095102.GC4372@csn.ul.ie>
References: <1307250516-10756-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1307250516-10756-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Sun, Jun 05, 2011 at 02:08:36PM +0900, Minchan Kim wrote:
> If migration is failed, normally we call putback_lru_pages which
> decreases NR_ISOLATE_[ANON|FILE].
> It means we should increase NR_ISOLATE_[ANON|FILE] before calling
> putback_lru_pages. But soft_offline_page dosn't it.
> 
> It can make NR_ISOLATE_[ANON|FILE] with negative value and in UP build
> , zone_page_state will say huge isolated pages so too_many_isolated
> functions be deceived completely. At last, some process stuck in D state
> as it expect while loop ending with congestion_wait.
> But it's never ending story.
> 
> If it is right, it would be -stable stuff.
> 

The patch is fine but the changelog is tricky to read. How about this?

[PATCH] Fix isolated page count during memory failure

Pages isolated for migration are accounted with the vmstat counters
NR_ISOLATE_[ANON|FILE]. Callers of migrate_pages() are expected to
increment these counters when pages are isolated from the LRU. Once
the pages have been migrated, they are put back on the LRU or freed
and the isolated count is decremented.

Memory failure is not properly accounting for pages it isolates
causing the NR_ISOLATED counters to be negative. On SMP builds,
this goes unnoticed as negative counters are treated as 0 due to
expected per-cpu drift. On UP builds, the counter is treated by
too_many_isolated() as a large value causing processes to enter D
state during page reclaim or compaction. This patch accounts for
pages isolated by memory failure correctly.

Whether you add the changelog or not;

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
