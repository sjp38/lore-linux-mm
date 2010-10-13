Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 04B6F6B0101
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 03:10:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9D7AjED007110
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 13 Oct 2010 16:10:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 96ABD45DE50
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:10:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3EEC745DE51
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:10:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F3A9E18003
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:10:45 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 818C61DB8045
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 16:10:44 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [experimental][PATCH] mm,vmstat: per cpu stat flush too when per cpu page cache flushed
In-Reply-To: <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
References: <20101013121913.ADB4.A69D9226@jp.fujitsu.com> <20101013151723.ADBD.A69D9226@jp.fujitsu.com>
Message-Id: <20101013160640.ADC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Oct 2010 16:10:43 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cl@linux.com" <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

When memory shortage, we are using drain_pages() for flushing per cpu
page cache. In this case, per cpu stat should be flushed too. because
now we are under memory shortage and we need to know exact free pages.

Otherwise get_page_from_freelist() may fail even though pcp was flushed.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/vmstat.h |    5 +++++
 mm/page_alloc.c        |    1 +
 mm/vmstat.c            |   12 ++++++++++++
 3 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 1997988..df777f4 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -253,6 +253,8 @@ extern void __inc_zone_state(struct zone *, enum zone_stat_item);
 extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
+void __flush_zone_state(struct zone *zone, enum zone_stat_item item);
+
 void refresh_cpu_vm_stats(int);
 void refresh_zone_stat_thresholds(void);
 #else /* CONFIG_SMP */
@@ -299,6 +301,9 @@ static inline void __dec_zone_page_state(struct page *page,
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
 
+static inline void
+__flush_zone_state(struct zone *zone, enum zone_stat_item item) { }
+
 static inline void refresh_cpu_vm_stats(int cpu) { }
 static inline void refresh_zone_stat_thresholds(void) { }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 194bdaa..8b50e52 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1093,6 +1093,7 @@ static void drain_pages(unsigned int cpu)
 		pcp = &pset->pcp;
 		free_pcppages_bulk(zone, pcp->count, pcp);
 		pcp->count = 0;
+		__flush_zone_state(zone, NR_FREE_PAGES);
 		local_irq_restore(flags);
 	}
 }
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 48b0463..1ca04ec 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -233,6 +233,18 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __flush_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	struct per_cpu_pageset *pcp = this_cpu_ptr(zone->pageset);
+	s8 *diff = pcp->vm_stat_diff + item;
+
+	if (!*diff)
+		return;
+
+	zone_page_state_add(*diff, zone, item);
+	*diff = 0;
+}
+
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__inc_zone_state(page_zone(page), item);
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
