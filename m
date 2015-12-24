Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C4DA082F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 06:52:05 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id jx14so121269270pad.2
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 03:52:05 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 12si5455172pfm.98.2015.12.24.03.51.59
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 03:51:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/4] thp: add debugfs handle to split all huge pages
Date: Thu, 24 Dec 2015 14:51:20 +0300
Message-Id: <1450957883-96356-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Writing 1 into 'split_huge_pages' will try to find and split all huge
pages in the system. This is useful for debuging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a880f9addba5..99f2a0ecb621 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -27,6 +27,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/swapops.h>
+#include <linux/debugfs.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -3535,3 +3536,61 @@ static struct shrinker deferred_split_shrinker = {
 	.scan_objects = deferred_split_scan,
 	.seeks = DEFAULT_SEEKS,
 };
+
+#ifdef CONFIG_DEBUG_FS
+static int split_huge_pages_set(void *data, u64 val)
+{
+	struct zone *zone;
+	struct page *page;
+	unsigned long pfn, max_zone_pfn;
+	unsigned long total = 0, split = 0;
+
+	if (val != 1)
+		return -EINVAL;
+
+	for_each_populated_zone(zone) {
+		max_zone_pfn = zone_end_pfn(zone);
+		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++) {
+			if (!pfn_valid(pfn))
+				continue;
+
+			page = pfn_to_page(pfn);
+			if (!get_page_unless_zero(page))
+				continue;
+
+			if (zone != page_zone(page))
+				goto next;
+
+			if (!PageHead(page) || !PageAnon(page) ||
+					PageHuge(page))
+				goto next;
+
+			total++;
+			lock_page(page);
+			if (!split_huge_page(page))
+				split++;
+			unlock_page(page);
+next:
+			put_page(page);
+		}
+	}
+
+	pr_info("%lu of %lu THP split", split, total);
+
+	return 0;
+}
+DEFINE_SIMPLE_ATTRIBUTE(split_huge_pages_fops, NULL, split_huge_pages_set,
+		"%llu\n");
+
+static int __init split_huge_pages_debugfs(void)
+{
+	void *ret;
+
+	ret = debugfs_create_file("split_huge_pages", 0644, NULL, NULL,
+			&split_huge_pages_fops);
+	if (!ret)
+		pr_warn("Failed to create fault_around_bytes in debugfs");
+	return 0;
+}
+late_initcall(split_huge_pages_debugfs);
+#endif
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
