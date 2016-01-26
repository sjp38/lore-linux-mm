Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 051106B0255
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:53:21 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id 123so104604609wmz.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 04:53:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r201si4151992wmd.103.2016.01.26.04.46.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Jan 2016 04:46:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 13/14] mm, page_owner: dump page owner info from dump_page()
Date: Tue, 26 Jan 2016 13:45:52 +0100
Message-Id: <1453812353-26744-14-git-send-email-vbabka@suse.cz>
In-Reply-To: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
References: <1453812353-26744-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>

The page_owner mechanism is useful for dealing with memory leaks. By reading
/sys/kernel/debug/page_owner one can determine the stack traces leading to
allocations of all pages, and find e.g. a buggy driver.

This information might be also potentially useful for debugging, such as the
VM_BUG_ON_PAGE() calls to dump_page(). So let's print the stored info from
dump_page().

Example output:

page:ffffea000292f1c0 count:1 mapcount:0 mapping:ffff8800b2f6cc18 index:0x91d
flags: 0x1fffff8001002c(referenced|uptodate|lru|mappedtodisk)
page dumped because: VM_BUG_ON_PAGE(1)
page->mem_cgroup:ffff8801392c5000
page allocated via order 0, migratetype Movable, gfp_mask 0x24213ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD|__GFP_NOWARN|__GFP_NORETRY)
 [<ffffffff811682c4>] __alloc_pages_nodemask+0x134/0x230
 [<ffffffff811b40c8>] alloc_pages_current+0x88/0x120
 [<ffffffff8115e386>] __page_cache_alloc+0xe6/0x120
 [<ffffffff8116ba6c>] __do_page_cache_readahead+0xdc/0x240
 [<ffffffff8116bd05>] ondemand_readahead+0x135/0x260
 [<ffffffff8116be9c>] page_cache_async_readahead+0x6c/0x70
 [<ffffffff811604c2>] generic_file_read_iter+0x3f2/0x760
 [<ffffffff811e0dc7>] __vfs_read+0xa7/0xd0
page has been migrated, last migrate reason: compaction

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/page_owner.h |  9 +++++++++
 mm/debug.c                 |  2 ++
 mm/page_alloc.c            |  1 +
 mm/page_owner.c            | 25 +++++++++++++++++++++++++
 4 files changed, 37 insertions(+)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 555893bf13d7..46f1b939948c 100644
--- a/include/linux/page_owner.h
+++ b/include/linux/page_owner.h
@@ -13,6 +13,7 @@ extern void __set_page_owner(struct page *page,
 extern gfp_t __get_page_owner_gfp(struct page *page);
 extern void __copy_page_owner(struct page *oldpage, struct page *newpage);
 extern void __set_page_owner_migrate_reason(struct page *page, int reason);
+extern void __dump_page_owner(struct page *page);
 
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -44,6 +45,11 @@ static inline void set_page_owner_migrate_reason(struct page *page, int reason)
 	if (static_branch_unlikely(&page_owner_inited))
 		__set_page_owner_migrate_reason(page, reason);
 }
+static inline void dump_page_owner(struct page *page)
+{
+	if (static_branch_unlikely(&page_owner_inited))
+		__dump_page_owner(page);
+}
 #else
 static inline void reset_page_owner(struct page *page, unsigned int order)
 {
@@ -62,5 +68,8 @@ static inline void copy_page_owner(struct page *oldpage, struct page *newpage)
 static inline void set_page_owner_migrate_reason(struct page *page, int reason)
 {
 }
+static inline void dump_page_owner(struct page *page)
+{
+}
 #endif /* CONFIG_PAGE_OWNER */
 #endif /* __LINUX_PAGE_OWNER_H */
diff --git a/mm/debug.c b/mm/debug.c
index 78dc54877075..61b1f1bb328e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -11,6 +11,7 @@
 #include <linux/memcontrol.h>
 #include <trace/events/mmflags.h>
 #include <linux/migrate.h>
+#include <linux/page_owner.h>
 
 #include "internal.h"
 
@@ -67,6 +68,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 void dump_page(struct page *page, const char *reason)
 {
 	dump_page_badflags(page, reason, 0);
+	dump_page_owner(page);
 }
 EXPORT_SYMBOL(dump_page);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d1f385a37b5c..e8b3cb78b5cf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -443,6 +443,7 @@ static void bad_page(struct page *page, const char *reason,
 	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
 	dump_page_badflags(page, reason, bad_flags);
+	dump_page_owner(page);
 
 	print_modules();
 	dump_stack();
diff --git a/mm/page_owner.c b/mm/page_owner.c
index a57068cfe52f..44ad1f00c4e1 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -183,6 +183,31 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	return -ENOMEM;
 }
 
+void __dump_page_owner(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+	struct stack_trace trace = {
+		.nr_entries = page_ext->nr_entries,
+		.entries = &page_ext->trace_entries[0],
+	};
+	gfp_t gfp_mask = page_ext->gfp_mask;
+	int mt = gfpflags_to_migratetype(gfp_mask);
+
+	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
+		pr_alert("page_owner info is not active (free page?)\n");
+		return;
+	}
+
+	pr_alert("page allocated via order %u, migratetype %s, "
+			"gfp_mask %#x(%pGg)\n", page_ext->order,
+			migratetype_names[mt], gfp_mask, &gfp_mask);
+	print_stack_trace(&trace, 0);
+
+	if (page_ext->last_migrate_reason != -1)
+		pr_alert("page has been migrated, last migrate reason: %s\n",
+			migrate_reason_names[page_ext->last_migrate_reason]);
+}
+
 static ssize_t
 read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 {
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
