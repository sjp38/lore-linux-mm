Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 077BF6B000A
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:48:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 11-v6so5000339pgd.1
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:48:47 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id e11-v6si353473plt.223.2018.10.10.18.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 18:48:45 -0700 (PDT)
Subject: [PATCH v4 3/3] mm: Maintain randomization of page free lists
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 10 Oct 2018 18:36:57 -0700
Message-ID: <153922181720.838512.12133416124816480558.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgkeescook@chromium.org

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
 include/linux/mm.h     |   10 ++++++++++
 include/linux/mmzone.h |   10 ++++++++++
 mm/page_alloc.c        |   11 +++++++++--
 mm/shuffle.c           |   16 ++++++++++++++++
 4 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 856b0530c55d..91a1e7fb465a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2045,6 +2045,11 @@ extern void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
 		unsigned long end_pfn);
 extern void shuffle_zone(struct zone *z, unsigned long start_pfn,
 		unsigned long end_pfn);
+
+static inline bool is_shuffle_order(int order)
+{
+	return order >= CONFIG_SHUFFLE_PAGE_ORDER;
+}
 #else
 static inline void shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
 		unsigned long end_pfn)
@@ -2055,6 +2060,11 @@ static inline void shuffle_zone(struct zone *z, unsigned long start_pfn,
 		unsigned long end_pfn)
 {
 }
+
+static inline bool is_shuffle_order(int order)
+{
+	return false;
+}
 #endif
 
 /* Free the reserved page into the buddy system, so it gets managed. */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 0b91ce871895..c7abf21ed9f4 100644
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e1e0b54423f0..eef241ceb2c4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -42,6 +42,7 @@
 #include <linux/mempolicy.h>
 #include <linux/memremap.h>
 #include <linux/stop_machine.h>
+#include <linux/random.h>
 #include <linux/sort.h>
 #include <linux/pfn.h>
 #include <linux/backing-dev.h>
@@ -850,7 +851,8 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
+			&& !is_shuffle_order(order)) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
@@ -864,7 +866,12 @@ static inline void __free_one_page(struct page *page,
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
index 5ed91b5b8441..3937d0bc3670 100644
--- a/mm/shuffle.c
+++ b/mm/shuffle.c
@@ -168,3 +168,19 @@ void __meminit shuffle_free_memory(pg_data_t *pgdat, unsigned long start_pfn,
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
