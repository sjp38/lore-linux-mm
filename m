Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 848D46B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 22:29:16 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 3-v6so7158943plq.6
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 19:29:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 3-v6si3424926plo.318.2018.10.03.19.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 19:29:15 -0700 (PDT)
Subject: [PATCH v2 3/3] mm: Maintain randomization of page free lists
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Oct 2018 19:15:34 -0700
Message-ID: <153861933441.2863953.2686611248399177664.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 include/linux/mmzone.h |    2 ++
 mm/page_alloc.c        |   27 +++++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index adf9b3a7440d..4a095432843d 100644
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
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b4a1598fcab5..e659119351ad 100644
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
@@ -746,6 +747,22 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
 	return 0;
 }
 
+static void add_to_free_area_random(struct page *page, struct free_area *area,
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
+
 /*
  * Freeing function for a buddy system allocator.
  *
@@ -851,7 +868,8 @@ static inline void __free_one_page(struct page *page,
 	 * so it's less likely to be used soon and more likely to be merged
 	 * as a higher order page
 	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)) {
+	if ((order < MAX_ORDER-2) && pfn_valid_within(buddy_pfn)
+			&& order < shuffle_page_order) {
 		struct page *higher_page, *higher_buddy;
 		combined_pfn = buddy_pfn & pfn;
 		higher_page = page + (combined_pfn - pfn);
@@ -865,7 +883,12 @@ static inline void __free_one_page(struct page *page,
 		}
 	}
 
-	add_to_free_area(page, &zone->free_area[order], migratetype);
+	if (order < shuffle_page_order)
+		add_to_free_area(page, &zone->free_area[order], migratetype);
+	else
+		add_to_free_area_random(page, &zone->free_area[order],
+				migratetype);
+
 }
 
 /*
