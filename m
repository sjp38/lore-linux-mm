Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id BC0036B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:48:29 -0500 (EST)
Received: by bkty12 with SMTP id y12so1805541bkt.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 10:48:27 -0800 (PST)
Subject: [PATCH 1/2] mm: configure lruvec split by boot options
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 23 Feb 2012 22:48:24 +0400
Message-ID: <20120223184824.7184.78353.stgit@zurg>
In-Reply-To: <20120223162111.GA4713@one.firstfloor.org>
References: <20120223162111.GA4713@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>

This patch adds boot options:
lruvec_split=%u by default 1, limited by CONFIG_PAGE_LRU_SPLIT
lruvec_interleaving=%u by default CONFIG_PAGE_LRU_INTERLEAVING

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/mm.h |    5 ++++-
 mm/internal.h      |    2 +-
 mm/page_alloc.c    |   29 +++++++++++++++++++++++++++++
 3 files changed, 34 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d14db10..f042a34 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -737,12 +737,15 @@ static inline int page_lruvec_id(struct page *page)
 
 #else /* CONFIG_PAGE_LRU_SPLIT */
 
+extern unsigned lruvec_split;
+extern unsigned lruvec_interleaving;
+
 static inline int page_lruvec_id(struct page *page)
 {
 
 	unsigned long pfn = page_to_pfn(page);
 
-	return (pfn >> CONFIG_PAGE_LRU_INTERLEAVING) % CONFIG_PAGE_LRU_SPLIT;
+	return (pfn >> lruvec_interleaving) % lruvec_split;
 }
 
 #endif /* CONFIG_PAGE_LRU_SPLIT */
diff --git a/mm/internal.h b/mm/internal.h
index f429911..be7415b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -17,7 +17,7 @@
 	for ( zone_id = 0 ; zone_id < MAX_NR_ZONES ; zone_id++ )
 
 #define for_each_lruvec_id(lruvec_id) \
-	for ( lruvec_id = 0 ; lruvec_id < CONFIG_PAGE_LRU_SPLIT ; lruvec_id++ )
+	for ( lruvec_id = 0 ; lruvec_id < lruvec_split ; lruvec_id++ )
 
 #define for_each_zone_and_lruvec_id(zone_id, lruvec_id) \
 	for_each_zone_id(zone_id) for_each_lruvec_id(lruvec_id)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9b0cc92..1a899fa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4303,6 +4303,35 @@ void init_zone_lruvec(struct zone *zone, struct lruvec *lruvec)
 #endif
 }
 
+#if CONFIG_PAGE_LRU_SPLIT != 1
+
+unsigned lruvec_split = 1;
+unsigned lruvec_interleaving = CONFIG_PAGE_LRU_INTERLEAVING;
+
+static int __init set_lruvec_split(char *arg)
+{
+	if (!kstrtouint(arg, 0, &lruvec_split) &&
+	    lruvec_split >= 1 &&
+	    lruvec_split <= CONFIG_PAGE_LRU_SPLIT)
+		return 0;
+	lruvec_split = 1;
+	return 1;
+}
+early_param("lruvec_split", set_lruvec_split);
+
+static int __init set_lruvec_interleaving(char *arg)
+{
+	if (!kstrtouint(arg, 0, &lruvec_interleaving) &&
+	    lruvec_interleaving >= HPAGE_PMD_ORDER &&
+	    lruvec_interleaving <= BITS_PER_LONG)
+		return 0;
+	lruvec_split = 1;
+	return 1;
+}
+early_param("lruvec_interleaving", set_lruvec_interleaving);
+
+#endif
+
 /*
  * Set up the zone data structures:
  *   - mark all pages reserved

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
