Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C17DC6B02C3
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 21:52:05 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d193so167143261pgc.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 18:52:05 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id s10si7722046pgc.281.2017.07.24.18.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 18:52:04 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v3 2/6] mm, swap: Add swap readahead hit statistics
Date: Tue, 25 Jul 2017 09:51:47 +0800
Message-Id: <20170725015151.19502-3-ying.huang@intel.com>
In-Reply-To: <20170725015151.19502-1-ying.huang@intel.com>
References: <20170725015151.19502-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The statistics for total readahead pages and total readahead hits are
recorded and exported via the following sysfs interface.

/sys/kernel/mm/swap/ra_hits
/sys/kernel/mm/swap/ra_total

With them, the efficiency of the swap readahead could be measured, so
that the swap readahead algorithm and parameters could be tuned
accordingly.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 mm/swap_state.c | 38 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 36 insertions(+), 2 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index a13bbf504e93..8be7153967ed 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -20,6 +20,7 @@
 #include <linux/vmalloc.h>
 #include <linux/swap_slots.h>
 #include <linux/huge_mm.h>
+#include <linux/percpu_counter.h>
 
 #include <asm/pgtable.h>
 
@@ -74,6 +75,15 @@ unsigned long total_swapcache_pages(void)
 }
 
 static atomic_t swapin_readahead_hits = ATOMIC_INIT(4);
+static struct percpu_counter swapin_readahead_hits_total;
+static struct percpu_counter swapin_readahead_total;
+
+static int __init swap_init(void)
+{
+	percpu_counter_init(&swapin_readahead_hits_total, 0, GFP_KERNEL);
+	percpu_counter_init(&swapin_readahead_total, 0, GFP_KERNEL);
+}
+subsys_initcall(swap_init);
 
 void show_swap_cache_info(void)
 {
@@ -305,8 +315,10 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 
 	if (page && likely(!PageTransCompound(page))) {
 		INC_CACHE_INFO(find_success);
-		if (TestClearPageReadahead(page))
+		if (TestClearPageReadahead(page)) {
 			atomic_inc(&swapin_readahead_hits);
+			percpu_counter_inc(&swapin_readahead_hits_total);
+		}
 	}
 
 	INC_CACHE_INFO(find_total);
@@ -516,8 +528,11 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 						gfp_mask, vma, addr, false);
 		if (!page)
 			continue;
-		if (offset != entry_offset && likely(!PageTransCompound(page)))
+		if (offset != entry_offset &&
+		    likely(!PageTransCompound(page))) {
 			SetPageReadahead(page);
+			percpu_counter_inc(&swapin_readahead_total);
+		}
 		put_page(page);
 	}
 	blk_finish_plug(&plug);
@@ -603,12 +618,31 @@ static ssize_t swap_cache_find_total_show(
 static struct kobj_attribute swap_cache_find_total_attr =
 	__ATTR(cache_find_total, 0444, swap_cache_find_total_show, NULL);
 
+static ssize_t swap_readahead_hits_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lld\n",
+		       percpu_counter_sum(&swapin_readahead_hits_total));
+}
+static struct kobj_attribute swap_readahead_hits_attr =
+	__ATTR(ra_hits, 0444, swap_readahead_hits_show, NULL);
+
+static ssize_t swap_readahead_total_show(
+	struct kobject *kobj, struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%lld\n", percpu_counter_sum(&swapin_readahead_total));
+}
+static struct kobj_attribute swap_readahead_total_attr =
+	__ATTR(ra_total, 0444, swap_readahead_total_show, NULL);
+
 static struct attribute *swap_attrs[] = {
 	&swap_cache_pages_attr.attr,
 	&swap_cache_add_attr.attr,
 	&swap_cache_del_attr.attr,
 	&swap_cache_find_success_attr.attr,
 	&swap_cache_find_total_attr.attr,
+	&swap_readahead_hits_attr.attr,
+	&swap_readahead_total_attr.attr,
 	NULL,
 };
 
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
