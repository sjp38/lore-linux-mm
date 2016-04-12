Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE1B828E8
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:14:17 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id v188so120540480wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:14:17 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id a66si23098932wma.67.2016.04.12.03.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:14:16 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 1E3611C25C7
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:14:16 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/24] mm, page_alloc: Check multiple page fields with a single branch
Date: Tue, 12 Apr 2016 11:12:21 +0100
Message-Id: <1460455945-29644-21-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
References: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Every page allocated or freed is checked for sanity to avoid corruptions
that are difficult to detect later.  A bad page could be due to a number of
fields. Instead of using multiple branches, this patch combines multiple
fields into a single branch. A detailed check is only necessary if that
check fails.

                                           4.6.0-rc2                  4.6.0-rc2
                                      initonce-v1r20            multcheck-v1r20
Min      alloc-odr0-1               359.00 (  0.00%)           348.00 (  3.06%)
Min      alloc-odr0-2               260.00 (  0.00%)           254.00 (  2.31%)
Min      alloc-odr0-4               214.00 (  0.00%)           213.00 (  0.47%)
Min      alloc-odr0-8               186.00 (  0.00%)           186.00 (  0.00%)
Min      alloc-odr0-16              173.00 (  0.00%)           173.00 (  0.00%)
Min      alloc-odr0-32              165.00 (  0.00%)           166.00 ( -0.61%)
Min      alloc-odr0-64              162.00 (  0.00%)           162.00 (  0.00%)
Min      alloc-odr0-128             161.00 (  0.00%)           160.00 (  0.62%)
Min      alloc-odr0-256             170.00 (  0.00%)           169.00 (  0.59%)
Min      alloc-odr0-512             181.00 (  0.00%)           180.00 (  0.55%)
Min      alloc-odr0-1024            190.00 (  0.00%)           188.00 (  1.05%)
Min      alloc-odr0-2048            196.00 (  0.00%)           194.00 (  1.02%)
Min      alloc-odr0-4096            202.00 (  0.00%)           199.00 (  1.49%)
Min      alloc-odr0-8192            205.00 (  0.00%)           202.00 (  1.46%)
Min      alloc-odr0-16384           205.00 (  0.00%)           203.00 (  0.98%)

Again, the benefit is marginal but avoiding excessive branches is
important. Ideally the paths would not have to check these conditions at
all but regrettably abandoning the tests would make use-after-free bugs
much harder to detect.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 55 +++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 43 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4019dfe26b11..0100609f6510 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -784,10 +784,42 @@ static inline void __free_one_page(struct page *page,
 	zone->free_area[order].nr_free++;
 }
 
+/*
+ * A bad page could be due to a number of fields. Instead of multiple branches,
+ * try and check multiple fields with one check. The caller must do a detailed
+ * check if necessary.
+ */
+static inline bool page_expected_state(struct page *page,
+					unsigned long check_flags)
+{
+	if (unlikely(atomic_read(&page->_mapcount) != -1))
+		return false;
+
+	if (unlikely((unsigned long)page->mapping |
+			page_ref_count(page) |
+#ifdef CONFIG_MEMCG
+			(unsigned long)page->mem_cgroup |
+#endif
+			(page->flags & check_flags)))
+		return false;
+
+	return true;
+}
+
 static inline int free_pages_check(struct page *page)
 {
-	const char *bad_reason = NULL;
-	unsigned long bad_flags = 0;
+	const char *bad_reason;
+	unsigned long bad_flags;
+
+	if (page_expected_state(page, PAGE_FLAGS_CHECK_AT_FREE)) {
+		page_cpupid_reset_last(page);
+		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
+		return 0;
+	}
+
+	/* Something has gone sideways, find it */
+	bad_reason = NULL;
+	bad_flags = 0;
 
 	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
@@ -803,14 +835,8 @@ static inline int free_pages_check(struct page *page)
 	if (unlikely(page->mem_cgroup))
 		bad_reason = "page still charged to cgroup";
 #endif
-	if (unlikely(bad_reason)) {
-		bad_page(page, bad_reason, bad_flags);
-		return 1;
-	}
-	page_cpupid_reset_last(page);
-	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
-		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
-	return 0;
+	bad_page(page, bad_reason, bad_flags);
+	return 1;
 }
 
 /*
@@ -1491,9 +1517,14 @@ static inline void expand(struct zone *zone, struct page *page,
  */
 static inline int check_new_page(struct page *page)
 {
-	const char *bad_reason = NULL;
-	unsigned long bad_flags = 0;
+	const char *bad_reason;
+	unsigned long bad_flags;
+
+	if (page_expected_state(page, PAGE_FLAGS_CHECK_AT_PREP|__PG_HWPOISON))
+		return 0;
 
+	bad_reason = NULL;
+	bad_flags = 0;
 	if (unlikely(atomic_read(&page->_mapcount) != -1))
 		bad_reason = "nonzero mapcount";
 	if (unlikely(page->mapping != NULL))
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
