Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A40728E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 18:33:59 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so1322520pfk.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 15:33:59 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id x64si8003259pfx.87.2019.01.07.15.33.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 15:33:58 -0800 (PST)
Subject: [PATCH v7 3/3] mm: Maintain randomization of page free lists
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Jan 2019 15:21:21 -0800
Message-ID: <154690328135.676627.5979130839159447106.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>mhocko@suse.com, keith.busch@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de

When freeing a page with an order >= shuffle_page_order randomly select
the front or back of the list for insertion.

While the mm tries to defragment physical pages into huge pages this can
tend to make the page allocator more predictable over time. Inject the
front-back randomness to preserve the initial randomness established by
shuffle_free_memory() when the kernel was booted.

The overhead of this manipulation is constrained by only being applied
for MAX_ORDER sized pages by default.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h  |   10 ++++++++++
 include/linux/shuffle.h |   12 ++++++++++++
 mm/page_alloc.c         |   11 +++++++++--
 mm/shuffle.c            |   16 ++++++++++++++++
 4 files changed, 47 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b78a45e0b11c..c15f7f703be0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -98,6 +98,8 @@ extern int page_group_by_mobility_disabled;
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
 	unsigned long		nr_free;
+	u64			rand;
+	u8			rand_bits;
 };
 
 /* Used for pages not on another list */
@@ -116,6 +118,14 @@ static inline void add_to_free_area_tail(struct page *page, struct free_area *ar
 	area->nr_free++;
 }
 
+#ifdef CONFIG_SHUFFLE_PAGE_ALLOCATOR
+/* Used to preserve page allocation order entropy */
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype);
+#else
+#define add_to_free_area_random add_to_free_area
+#endif
+
 /* Used for pages which are on another list */
 static inline void move_to_free_area(struct page *page, struct free_area *area,
 			     int migratetype)
diff --git a/include/linux/shuffle.h b/include/linux/shuffle.h
index d109161f4a62..85b7f5f32867 100644
--- a/include/linux/shuffle.h
+++ b/include/linux/shuffle.h
@@ -30,6 +30,13 @@ static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
 		return;
 	__shuffle_zone(z, start_pfn, end_pfn);
 }
+
+static inline bool is_shuffle_order(int order)
+{
+	if (!static_branch_unlikely(&page_alloc_shuffle_key))
+                return false;
+	return order >= CONFIG_SHUFFLE_PAGE_ORDER;
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
 		unsigned long end_pfn)
@@ -44,5 +51,10 @@ static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
 static inline void page_alloc_shuffle(enum mm_shuffle_ctl ctl)
 {
 }
+
+static inline bool is_shuffle_order(int order)
+{
+	return false;
+}
 #endif
 #endif /* _MM_SHUFFLE_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0b4791a2dd43..f3a859b66d70 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -43,6 +43,7 @@
 #include <linux/mempolicy.h>
 #include <linux/memremap.h>
 #include <linux/stop_machine.h>
+#include <linux/random.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
@@ -889,7 +890,8 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
+			&& !is_shuffle_order(order)) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
@@ -903,7 +905,12 @@ static inline void __free_one_page(struct page *page,
 		}
 	}
 
-	add_to_free_area(page, &zone->free_area[order], migratetype);
+	if (is_shuffle_order(order))
+		add_to_free_area_random(page, &zone->free_area[order],
+				migratetype);
+	else
+		add_to_free_area(page, &zone->free_area[order], migratetype);
+
 }
 
 /*
diff --git a/mm/shuffle.c b/mm/shuffle.c
index 07961ff41a03..4cadf51c9b40 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -213,3 +213,19 @@ void __meminit __shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
 	for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
 		shuffle_zone(z, start_pfn, end_pfn);
 }
+
+void add_to_free_area_random(struct page *page, struct free_area *area,
+		int migratetype)
+{
+	if (area->rand_bits == 0) {
+		area->rand_bits = 64;
+		area->rand = get_random_u64();
+	}
+
+	if (area->rand & 1)
+		add_to_free_area(page, area, migratetype);
+	else
+		add_to_free_area_tail(page, area, migratetype);
+	area->rand_bits--;
+	area->rand >>= 1;
+}
