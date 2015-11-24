Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 28E5B6B0266
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 07:37:02 -0500 (EST)
Received: by wmww144 with SMTP id w144so24452159wmw.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:37:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ir3si14668642wjb.25.2015.11.24.04.36.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 04:36:44 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 7/9] mm, page_owner: dump page owner info from dump_page()
Date: Tue, 24 Nov 2015 13:36:19 +0100
Message-Id: <1448368581-6923-8-git-send-email-vbabka@suse.cz>
In-Reply-To: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

The page_owner mechanism is useful for dealing with memory leaks. By reading
/sys/kernel/debug/page_owner one can determine the stack traces leading to
allocations of all pages, and find e.g. a buggy driver.

This information might be also potentially useful for debugging, such as the
VM_BUG_ON_PAGE() calls to dump_page(). So let's print the stored info from
dump_page().

Example output:

page:ffffea0002868a00 count:1 mapcount:0 mapping:ffff8800bba8e958 index:0x63a22c
flags: 0x1fffff80000060(lru|active)
page dumped because: VM_BUG_ON_PAGE(1)
page->mem_cgroup:ffff880138efdc00
page allocated via order 0, migratetype Movable, gfp_mask 0x2420848(GFP_NOFS|GFP_NOFAIL|GFP_HARDWALL|GFP_MOVABLE)
 [<ffffffff81164e8a>] __alloc_pages_nodemask+0x15a/0xa30
 [<ffffffff811ab808>] alloc_pages_current+0x88/0x120
 [<ffffffff8115bc36>] __page_cache_alloc+0xe6/0x120
 [<ffffffff8115c226>] pagecache_get_page+0x56/0x200
 [<ffffffff812058c2>] __getblk_slow+0xd2/0x2b0
 [<ffffffff81205ae0>] __getblk_gfp+0x40/0x50
 [<ffffffffa0283abe>] jbd2_journal_get_descriptor_buffer+0x3e/0x90 [jbd2]
 [<ffffffffa027c793>] jbd2_journal_commit_transaction+0x8e3/0x1870 [jbd2]
page has been migrated, last migrate reason: compaction

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page_owner.h |  9 +++++++++
 mm/debug.c                 |  2 ++
 mm/page_alloc.c            |  1 +
 mm/page_owner.c            | 25 +++++++++++++++++++++++++
 4 files changed, 37 insertions(+)

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
index 1a71a3b..c3300ee 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -10,6 +10,7 @@
 #include <linux/trace_events.h>
 #include <linux/memcontrol.h>
 #include <trace/events/gfpflags.h>
+#include <linux/page_owner.h>
 
 static const struct trace_print_flags pageflag_names[] = {
 	{1UL << PG_locked,		"locked"	},
@@ -118,6 +119,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 void dump_page(struct page *page, const char *reason)
 {
 	dump_page_badflags(page, reason, 0);
+	dump_page_owner(page);
 }
 EXPORT_SYMBOL(dump_page);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61a023a..f806a1a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -448,6 +448,7 @@ static void bad_page(struct page *page, const char *reason,
 	printk(KERN_ALERT "BUG: Bad page state in process %s  pfn:%05lx\n",
 		current->comm, page_to_pfn(page));
 	dump_page_badflags(page, reason, bad_flags);
+	dump_page_owner(page);
 
 	print_modules();
 	dump_stack();
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 59fd6f1..a81cfa0 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -193,6 +193,31 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
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
+			                        ;
+	pr_alert("page allocated via order %u, migratetype %s, gfp_mask 0x%x",
+			page_ext->order, migratetype_names[mt], gfp_mask);
+	dump_gfpflag_names(gfp_mask);
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
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
