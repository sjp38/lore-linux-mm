Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 45BBF6B0022
	for <linux-mm@kvack.org>; Mon, 23 May 2011 05:54:06 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Eliminate hangs when using frequent high-order allocations V4
Date: Mon, 23 May 2011 10:53:53 +0100
Message-Id: <1306144435-2516-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>, stable <stable@kernel.org>, Mel Gorman <mgorman@suse.de>

(Resending as the updated patch 2 appears to have gotten lost in a
"twisty maze of threads all similar" while questing towards mmotm)

Changelog since V3
  o cond_resched in shrink_slab when it does nothing rather than
    having kswapd sleep for HZ/10 when it needs to schedule

Changelog since V2
  o Drop all SLUB latency-reducing patches.

Changelog since V1
  o kswapd should sleep if need_resched
  o Remove __GFP_REPEAT from GFP flags when speculatively using high
    orders so direct/compaction exits earlier
  o Remove __GFP_NORETRY for correctness
  o Correct logic in sleeping_prematurely
  o Leave SLUB using the default slub_max_order

There are a few reports of people experiencing hangs when copying
large amounts of data with kswapd using a large amount of CPU which
appear to be due to recent reclaim changes. SLUB using high orders
is the trigger but not the root cause as SLUB has been using high
orders for a while. The root cause was bugs introduced into reclaim
which are addressed by the following two patches.

Patch 1 corrects logic introduced by commit [1741c877: mm:
	kswapd: keep kswapd awake for high-order allocations until
	a percentage of the node is balanced] to allow kswapd to
	go to sleep when balanced for high orders.

Patch 2 notes that it is possible for kswapd to miss every
	cond_resched() and updates shrink_slab() so it'll at least
	reach that scheduling point.

Chris Wood reports that these two patches in isolation are sufficient
to prevent the system hanging. AFAIK, they should also resolve similar
hangs experienced by James Bottomley.

These should be also considered for -stable for both 2.6.38 and 2.6.39.

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
