Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5025D6B02A4
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:11:08 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756BF6V011827
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:11:16 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6CA645DE60
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:11:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 63EF445DE4D
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:11:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 079F8E38006
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:11:15 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2118AE38001
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:11:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 0/7] low latency synchrounous lumpy reclaim
Message-Id: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:11:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>


If slow usb storage is connected and run plenty io operation, lumpy
reclaim often stall in shrink_inactive_list(). This patch series try 
to solve this issue.
At least, This works fine on my desktop and usb stick environment :-)

This patch is still RFC. comment, reviewing and testing are welcome!




Wu Fengguang (1):
  vmscan: raise the bar to PAGEOUT_IO_SYNC stalls

KOSAKI Motohiro (6):
  vmscan: synchronous lumpy reclaim don't call congestion_wait()
  vmscan: synchrounous lumpy reclaim use lock_page() instead trylock_page()
  vmscan: narrowing synchrounous lumply reclaim condition
  vmscan: kill dead code in shrink_inactive_list()
  vmscan: remove PF_SWAPWRITE from __zone_reclaim()
  vmscan: isolated_lru_pages() stop neighbor search if neighbor can't be isolated

 mm/vmscan.c |  211 ++++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 138 insertions(+), 73 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
