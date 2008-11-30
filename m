Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwnews.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAUAtAGR031761
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 30 Nov 2008 19:55:10 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D7FD12AEA82
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:55:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B60A11EF084
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:55:09 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9988F1DB803E
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:55:09 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 087AD1DB803A
	for <linux-mm@kvack.org>; Sun, 30 Nov 2008 19:55:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 01/09] inactive_anon_is_low() move to vmscan.c
In-Reply-To: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081130193502.8145.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081130195412.8148.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 30 Nov 2008 19:55:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

The inactive_anon_is_low() is called only vmscan.
Then it can move to vmscan.c

This patch doesn't have any functional change.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mm_inline.h |   19 -------------------
 mm/vmscan.c               |   20 ++++++++++++++++++++
 2 files changed, 20 insertions(+), 19 deletions(-)

Index: b/include/linux/mm_inline.h
===================================================================
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -81,23 +81,4 @@ static inline enum lru_list page_lru(str
 	return lru;
 }
 
-/**
- * inactive_anon_is_low - check if anonymous pages need to be deactivated
- * @zone: zone to check
- *
- * Returns true if the zone does not have enough inactive anon pages,
- * meaning some active anon pages need to be deactivated.
- */
-static inline int inactive_anon_is_low(struct zone *zone)
-{
-	unsigned long active, inactive;
-
-	active = zone_page_state(zone, NR_ACTIVE_ANON);
-	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
-
-	if (inactive * zone->inactive_ratio < active)
-		return 1;
-
-	return 0;
-}
 #endif
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1350,6 +1350,26 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
+/**
+ * inactive_anon_is_low - check if anonymous pages need to be deactivated
+ * @zone: zone to check
+ *
+ * Returns true if the zone does not have enough inactive anon pages,
+ * meaning some active anon pages need to be deactivated.
+ */
+static int inactive_anon_is_low(struct zone *zone)
+{
+	unsigned long active, inactive;
+
+	active = zone_page_state(zone, NR_ACTIVE_ANON);
+	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
+
+	if (inactive * zone->inactive_ratio < active)
+		return 1;
+
+	return 0;
+}
+
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
