Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D03A2900225
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 09:43:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/4] Stop kswapd consuming 100% CPU when highest zone is small
Date: Fri, 24 Jun 2011 14:43:14 +0100
Message-Id: <1308922998-15529-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?P=C3=A1draig=20Brady?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

During allocator-intensive workloads, kswapd will be woken frequently
causing free memory to oscillate between the high and min watermark.
This is expected behaviour.  Unfortunately, if the highest zone is
small, a problem occurs.

This seems to happen most with recent sandybridge laptops but it's
probably a co-incidence as some of these laptops just happen to have
a small Normal zone. The reproduction case is almost always during
copying large files that kswapd pegs at 100% CPU until the file is
deleted or cache is dropped.

The problem is mostly down to sleeping_prematurely() keeping kswapd
awake when the highest zone is small and unreclaimable and compounded
by the fact we shrink slabs even when not shrinking zones causing a lot
of time to be spent in shrinkers and a lot of memory to be reclaimed.

Patch 1 corrects sleeping_prematurely to check the zones matching
	the classzone_idx instead of all zones.

Patch 2 avoids shrinking slab when we are not shrinking a zone.

Patch 3 notes that sleeping_prematurely is checking lower zones against
	a high classzone which is not what allocators or balance_pgdat()
	is doing leading to an artifical believe that kswapd should be
	still awake.

Patch 4 notes that when balance_pgdat() gives up on a high zone that the
	decision is not communicated to sleeping_prematurely()

This problem affects 3.0-rc4 and 2.6.38.8 for certain and is expected
to affect 2.6.39 as well. If accepted, they need to go to -stable to
be picked up by distros. This series is against 3.0-rc4. I've cc'd
people that reported similar problems recently to see if they still
suffer from the problem and if this fixes it.

 mm/vmscan.c |   57 ++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 34 insertions(+), 23 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
