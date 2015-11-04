Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id ECE476B0255
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:31 -0500 (EST)
Received: by wicll6 with SMTP id ll6so91537338wic.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si2090298wju.26.2015.11.04.07.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 2/5] mm, page_owner: convert page_owner_inited to static key
Date: Wed,  4 Nov 2015 16:00:58 +0100
Message-Id: <1446649261-27122-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

CONFIG_PAGE_OWNER attempts to impose negligible runtime overhead when enabled
during compilation, but not actually enabled during runtime by boot param
page_owner=on. This overhead can be further reduced using the static key
mechanism, which this patch does.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/vm/page_owner.txt |  9 +++++----
 include/linux/page_owner.h      | 22 ++++++++++------------
 mm/page_owner.c                 |  9 +++++----
 mm/vmstat.c                     |  2 +-
 4 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/Documentation/vm/page_owner.txt b/Documentation/vm/page_owner.txt
index 8f3ce9b..ffff143 100644
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
index cacaabe..8e2eb15 100644
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
index a9f16b8..7664b85 100644
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
 
@@ -157,7 +158,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	struct page *page;
 	struct page_ext *page_ext;
 
-	if (!page_owner_inited)
+	if (!static_branch_unlikely(&page_owner_inited))
 		return -EINVAL;
 
 	page = NULL;
@@ -305,7 +306,7 @@ static int __init pageowner_init(void)
 {
 	struct dentry *dentry;
 
-	if (!page_owner_inited) {
+	if (!static_branch_unlikely(&page_owner_inited)) {
 		pr_info("page_owner is disabled\n");
 		return 0;
 	}
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 34f480b..d9be9ab 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1131,7 +1131,7 @@ static void pagetypeinfo_showmixedcount(struct seq_file *m, pg_data_t *pgdat)
 #ifdef CONFIG_PAGE_OWNER
 	int mtype;
 
-	if (!page_owner_inited)
+	if (!static_branch_unlikely(&page_owner_inited))
 		return;
 
 	drain_all_pages(NULL);
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
