Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 325326B0012
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 04:04:00 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p187so55942325wmp.0
        for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:04:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h2si24125139wjq.96.2015.12.18.01.03.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 Dec 2015 01:03:37 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 10/14] mm, page_owner: convert page_owner_inited to static key
Date: Fri, 18 Dec 2015 10:03:22 +0100
Message-Id: <1450429406-7081-11-git-send-email-vbabka@suse.cz>
In-Reply-To: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
References: <1450429406-7081-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

CONFIG_PAGE_OWNER attempts to impose negligible runtime overhead when enabled
during compilation, but not actually enabled during runtime by boot param
page_owner=on. This overhead can be further reduced using the static key
mechanism, which this patch does.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>
---
 Documentation/vm/page_owner.txt |  9 +++++----
 include/linux/page_owner.h      | 22 ++++++++++------------
 mm/page_owner.c                 |  9 +++++----
 mm/vmstat.c                     |  2 +-
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/Documentation/vm/page_owner.txt b/Documentation/vm/page_owner.txt
index 8f3ce9b3aa11..ffff1439076a 100644
--- a/Documentation/vm/page_owner.txt
+++ b/Documentation/vm/page_owner.txt
@@ -28,10 +28,11 @@ with page owner and page owner is disabled in runtime due to no enabling
 boot option, runtime overhead is marginal. If disabled in runtime, it
 doesn't require memory to store owner information, so there is no runtime
 memory overhead. And, page owner inserts just two unlikely branches into
-the page allocator hotpath and if it returns false then allocation is
-done like as the kernel without page owner. These two unlikely branches
-would not affect to allocation performance. Following is the kernel's
-code size change due to this facility.
+the page allocator hotpath and if not enabled, then allocation is done
+like as the kernel without page owner. These two unlikely branches should
+not affect to allocation performance, especially if the static keys jump
+label patching functionality is available. Following is the kernel's code
+size change due to this facility.
 
 - Without page owner
    text    data     bss     dec     hex filename
diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index cacaabea8a09..8e2eb153c7b9 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -1,8 +1,10 @@
 #ifndef __LINUX_PAGE_OWNER_H
 #define __LINUX_PAGE_OWNER_H
 
+#include <linux/jump_label.h>
+
 #ifdef CONFIG_PAGE_OWNER
-extern bool page_owner_inited;
+extern struct static_key_false page_owner_inited;
 extern struct page_ext_operations page_owner_ops;
 
 extern void __reset_page_owner(struct page *page, unsigned int order);
@@ -12,27 +14,23 @@ extern gfp_t __get_page_owner_gfp(struct page *page);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
-	if (likely(!page_owner_inited))
-		return;
-
-	__reset_page_owner(page, order);
+	if (static_branch_unlikely(&page_owner_inited))
+		__reset_page_owner(page, order);
 }
 
 static inline void set_page_owner(struct page *page,
 			unsigned int order, gfp_t gfp_mask)
 {
-	if (likely(!page_owner_inited))
-		return;
-
-	__set_page_owner(page, order, gfp_mask);
+	if (static_branch_unlikely(&page_owner_inited))
+		__set_page_owner(page, order, gfp_mask);
 }
 
 static inline gfp_t get_page_owner_gfp(struct page *page)
 {
-	if (likely(!page_owner_inited))
+	if (static_branch_unlikely(&page_owner_inited))
+		return __get_page_owner_gfp(page);
+	else
 		return 0;
-
-	return __get_page_owner_gfp(page);
 }
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 5392195fca61..c8ea1361146e 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -5,10 +5,11 @@
 #include <linux/bootmem.h>
 #include <linux/stacktrace.h>
 #include <linux/page_owner.h>
+#include <linux/jump_label.h>
 #include "internal.h"
 
 static bool page_owner_disabled = true;
-bool page_owner_inited __read_mostly;
+DEFINE_STATIC_KEY_FALSE(page_owner_inited);
 
 static void init_early_allocated_pages(void);
 
@@ -37,7 +38,7 @@ static void init_page_owner(void)
 	if (page_owner_disabled)
 		return;
 
-	page_owner_inited = true;
+	static_branch_enable(&page_owner_inited);
 	init_early_allocated_pages();
 }
 
@@ -147,7 +148,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	struct page *page;
 	struct page_ext *page_ext;
 
-	if (!page_owner_inited)
+	if (!static_branch_unlikely(&page_owner_inited))
 		return -EINVAL;
 
 	page = NULL;
@@ -295,7 +296,7 @@ static int __init pageowner_init(void)
 {
 	struct dentry *dentry;
 
-	if (!page_owner_inited) {
+	if (!static_branch_unlikely(&page_owner_inited)) {
 		pr_info("page_owner is disabled\n");
 		return 0;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 475d154411f0..649680698afe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1120,7 +1120,7 @@ static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
 #ifdef CONFIG_PAGE_OWNER
 	int mtype;
 
-	if (!page_owner_inited)
+	if (!static_branch_unlikely(&page_owner_inited))
 		return;
 
 	drain_all_pages(NULL);
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
