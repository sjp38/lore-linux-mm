Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E9D9C8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 04:00:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2DA353EE0AE
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:12 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F33ED45DE4E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9040D45DE50
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:11 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76D5B1DB804E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 93FD01DB803E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:00:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/3] mm, mem-hotplug: fix section mismatch. setup_per_zone_inactive_ratio() should be __meminit.
In-Reply-To: <20110411165957.0352.A69D9226@jp.fujitsu.com>
References: <20110411165957.0352.A69D9226@jp.fujitsu.com>
Message-Id: <20110411170033.0356.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Apr 2011 17:00:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>

Commit bce7394a3e (page-allocator: reset wmark_min and inactive ratio of
zone when hotplug happens) introduced invalid section references.
Now, setup_per_zone_inactive_ratio() is marked __init and then it can't
be referenced from memory hotplug code.

Then, this patch marks it as __meminit and also marks caller as __ref.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory_hotplug.c |    4 ++--
 mm/page_alloc.c     |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f0651ae..0419c3d 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -400,7 +400,7 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 }
 
 
-int online_pages(unsigned long pfn, unsigned long nr_pages)
+int __ref online_pages(unsigned long pfn, unsigned long nr_pages)
 {
 	unsigned long onlined_pages = 0;
 	struct zone *zone;
@@ -795,7 +795,7 @@ check_pages_isolated(unsigned long start_pfn, unsigned long end_pfn)
 	return offlined;
 }
 
-static int offline_pages(unsigned long start_pfn,
+static int __ref offline_pages(unsigned long start_pfn,
 		  unsigned long end_pfn, unsigned long timeout)
 {
 	unsigned long pfn, nr_pages, expire;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e400779..44fae85 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5072,7 +5072,7 @@ void setup_per_zone_wmarks(void)
  *    1TB     101        10GB
  *   10TB     320        32GB
  */
-void calculate_zone_inactive_ratio(struct zone *zone)
+void __meminit calculate_zone_inactive_ratio(struct zone *zone)
 {
 	unsigned int gb, ratio;
 
@@ -5086,7 +5086,7 @@ void calculate_zone_inactive_ratio(struct zone *zone)
 	zone->inactive_ratio = ratio;
 }
 
-static void __init setup_per_zone_inactive_ratio(void)
+static void __meminit setup_per_zone_inactive_ratio(void)
 {
 	struct zone *zone;
 
-- 
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
