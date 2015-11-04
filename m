Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id EA33F82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:38 -0500 (EST)
Received: by wijp11 with SMTP id p11so94106174wij.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xt8si2027180wjb.197.2015.11.04.07.01.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 5/5] mm, page_owner: dump page owner info from dump_page()
Date: Wed,  4 Nov 2015 16:01:01 +0100
Message-Id: <1446649261-27122-6-git-send-email-vbabka@suse.cz>
In-Reply-To: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

The page_owner mechanism is useful for dealing with memory leaks. By reading
/sys/kernel/debug/page_owner one can determine the stack traces leading to
allocations of all pages, and find e.g. a buggy driver.

This information might be also potentially useful for debugging, such as the
VM_BUG_ON_PAGE() calls to dump_page(). So let's print the stored info from
dump_page().

Example output:

[  199.188777] page:ffffea0002900540 count:2 mapcount:0 mapping:ffff880131993e18 index:0x34e
[  199.202832] flags: 0x1fffff80020048(uptodate|active|mappedtodisk)
[  199.207048] page dumped because: VM_BUG_ON_PAGE(1)
[  199.207048] page->mem_cgroup:ffff880138efdc00
[  199.207050] page allocated via order 0, mask 0x213da, migratetype 2, trace:
[  199.207050]  [<ffffffff811622c5>] __alloc_pages_nodemask+0x175/0x900
[  199.207057]  [<ffffffff811a69c1>] alloc_pages_current+0x91/0x100
[  199.207061]  [<ffffffff81158da1>] __page_cache_alloc+0xb1/0xf0
[  199.207066]  [<ffffffff81165eeb>] __do_page_cache_readahead+0xdb/0x200
[  199.207067]  [<ffffffff81166155>] ondemand_readahead+0x145/0x270
[  199.207069]  [<ffffffff811662ec>] page_cache_async_readahead+0x6c/0x70
[  199.207070]  [<ffffffff8115a838>] generic_file_read_iter+0x378/0x590
[  199.207074]  [<ffffffff811cd2d7>] __vfs_read+0xa7/0xd0
[  199.207074] page has been migrated, last migrate reason: 0

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page_owner.h |  9 +++++++++
 mm/debug.c                 |  2 ++
 mm/page_owner.c            | 18 ++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/linux/page_owner.h b/include/linux/page_owner.h
index 555893b..46f1b93 100644
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
index 8362765..93373d1 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -9,6 +9,7 @@
 #include <linux/mm.h>
 #include <linux/trace_events.h>
 #include <linux/memcontrol.h>
+#include <linux/page_owner.h>
 
 static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
@@ -98,6 +99,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 	if (page->mem_cgroup)
 		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
 #endif
+	dump_page_owner(page);
 }
 
 void dump_page(struct page *page, const char *reason)
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 388898f..d7e0aaf 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -183,6 +183,24 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	return -ENOMEM;
 }
 
+void __dump_page_owner(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+	struct stack_trace trace = {
+		.nr_entries = page_ext->nr_entries,
+		.entries = &page_ext->trace_entries[0],
+	};
+
+	pr_alert("page allocated via order %u, mask 0x%x, migratetype %d, trace:\n",
+			page_ext->order, page_ext->gfp_mask,
+			gfpflags_to_migratetype(page_ext->gfp_mask));
+	print_stack_trace(&trace, 0);
+
+	if (page_ext->last_migrate_reason != -1)
+		pr_alert("page has been migrated, last migrate reason: %d\n",
+			page_ext->last_migrate_reason);
+}
+
 static ssize_t
 read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 {
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
