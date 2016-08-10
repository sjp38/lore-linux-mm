Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 24924828F3
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 02:16:34 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so64598240pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:34 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id f63si46905411pfb.109.2016.08.09.23.16.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 23:16:31 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id h186so2233270pfg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 23:16:30 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 5/5] mm/page_owner: don't define fields on struct page_ext by hard-coding
Date: Wed, 10 Aug 2016 15:16:24 +0900
Message-Id: <1470809784-11516-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1470809784-11516-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a memory waste problem if we define field on struct page_ext
by hard-coding. Entry size of struct page_ext includes the size of
those fields even if it is disabled at runtime. Now, extra memory request
at runtime is possible so page_owner don't need to define it's own fields
by hard-coding.

This patch removes hard-coded define and uses extra memory for storing
page_owner information in page_owner. Most of code are just mechanical
changes.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/page_ext.h |  6 ----
 mm/page_owner.c          | 83 +++++++++++++++++++++++++++++++++---------------
 2 files changed, 58 insertions(+), 31 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 179bdc4..9298c39 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -44,12 +44,6 @@ enum page_ext_flags {
  */
 struct page_ext {
 	unsigned long flags;
-#ifdef CONFIG_PAGE_OWNER
-	unsigned int order;
-	gfp_t gfp_mask;
-	int last_migrate_reason;
-	depot_stack_handle_t handle;
-#endif
 };
 
 extern void pgdat_page_ext_init(struct pglist_data *pgdat);
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 14c8e65..59d7490 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -17,6 +17,13 @@
  */
 #define PAGE_OWNER_STACK_DEPTH (16)
 
+struct page_owner {
+	unsigned int order;
+	gfp_t gfp_mask;
+	int last_migrate_reason;
+	depot_stack_handle_t handle;
+};
+
 static bool page_owner_disabled = true;
 DEFINE_STATIC_KEY_FALSE(page_owner_inited);
 
@@ -85,10 +92,16 @@ static void init_page_owner(void)
 }
 
 struct page_ext_operations page_owner_ops = {
+	.size = sizeof(struct page_owner),
 	.need = need_page_owner,
 	.init = init_page_owner,
 };
 
+static inline struct page_owner *get_page_owner(struct page_ext *page_ext)
+{
+	return (void *)page_ext + page_owner_ops.offset;
+}
+
 void __reset_page_owner(struct page *page, unsigned int order)
 {
 	int i;
@@ -155,14 +168,16 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
 					gfp_t gfp_mask)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
+	struct page_owner *page_owner;
 
 	if (unlikely(!page_ext))
 		return;
 
-	page_ext->handle = save_stack(gfp_mask);
-	page_ext->order = order;
-	page_ext->gfp_mask = gfp_mask;
-	page_ext->last_migrate_reason = -1;
+	page_owner = get_page_owner(page_ext);
+	page_owner->handle = save_stack(gfp_mask);
+	page_owner->order = order;
+	page_owner->gfp_mask = gfp_mask;
+	page_owner->last_migrate_reason = -1;
 
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
 }
@@ -170,21 +185,26 @@ noinline void __set_page_owner(struct page *page, unsigned int order,
 void __set_page_owner_migrate_reason(struct page *page, int reason)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
+	struct page_owner *page_owner;
+
 	if (unlikely(!page_ext))
 		return;
 
-	page_ext->last_migrate_reason = reason;
+	page_owner = get_page_owner(page_ext);
+	page_owner->last_migrate_reason = reason;
 }
 
 void __split_page_owner(struct page *page, unsigned int order)
 {
 	int i;
 	struct page_ext *page_ext = lookup_page_ext(page);
+	struct page_owner *page_owner;
 
 	if (unlikely(!page_ext))
 		return;
 
-	page_ext->order = 0;
+	page_owner = get_page_owner(page_ext);
+	page_owner->order = 0;
 	for (i = 1; i < (1 << order); i++)
 		__copy_page_owner(page, page + i);
 }
@@ -193,14 +213,18 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 {
 	struct page_ext *old_ext = lookup_page_ext(oldpage);
 	struct page_ext *new_ext = lookup_page_ext(newpage);
+	struct page_owner *old_page_owner, *new_page_owner;
 
 	if (unlikely(!old_ext || !new_ext))
 		return;
 
-	new_ext->order = old_ext->order;
-	new_ext->gfp_mask = old_ext->gfp_mask;
-	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
-	new_ext->handle = old_ext->handle;
+	old_page_owner = get_page_owner(old_ext);
+	new_page_owner = get_page_owner(new_ext);
+	new_page_owner->order = old_page_owner->order;
+	new_page_owner->gfp_mask = old_page_owner->gfp_mask;
+	new_page_owner->last_migrate_reason =
+		old_page_owner->last_migrate_reason;
+	new_page_owner->handle = old_page_owner->handle;
 
 	/*
 	 * We don't clear the bit on the oldpage as it's going to be freed
@@ -219,6 +243,7 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m, pg_data_t *pgdat,
 {
 	struct page *page;
 	struct page_ext *page_ext;
+	struct page_owner *page_owner;
 	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
 	unsigned long end_pfn = pfn + zone->spanned_pages;
 	unsigned long count[MIGRATE_TYPES] = { 0, };
@@ -269,14 +294,16 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m, pg_data_t *pgdat,
 			if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
 				continue;
 
-			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
+			page_owner = get_page_owner(page_ext);
+			page_mt = gfpflags_to_migratetype(
+					page_owner->gfp_mask);
 			if (pageblock_mt != page_mt) {
 				count[pageblock_mt]++;
 
 				pfn = block_end_pfn;
 				break;
 			}
-			pfn += (1UL << page_ext->order) - 1;
+			pfn += (1UL << page_owner->order) - 1;
 		}
 	}
 
@@ -289,7 +316,7 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m, pg_data_t *pgdat,
 
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
-		struct page *page, struct page_ext *page_ext,
+		struct page *page, struct page_owner *page_owner,
 		depot_stack_handle_t handle)
 {
 	int ret;
@@ -309,15 +336,15 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 
 	ret = snprintf(kbuf, count,
 			"Page allocated via order %u, mask %#x(%pGg)\n",
-			page_ext->order, page_ext->gfp_mask,
-			&page_ext->gfp_mask);
+			page_owner->order, page_owner->gfp_mask,
+			&page_owner->gfp_mask);
 
 	if (ret >= count)
 		goto err;
 
 	/* Print information relevant to grouping pages by mobility */
 	pageblock_mt = get_pageblock_migratetype(page);
-	page_mt  = gfpflags_to_migratetype(page_ext->gfp_mask);
+	page_mt  = gfpflags_to_migratetype(page_owner->gfp_mask);
 	ret += snprintf(kbuf + ret, count - ret,
 			"PFN %lu type %s Block %lu type %s Flags %#lx(%pGp)\n",
 			pfn,
@@ -334,10 +361,10 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (ret >= count)
 		goto err;
 
-	if (page_ext->last_migrate_reason != -1) {
+	if (page_owner->last_migrate_reason != -1) {
 		ret += snprintf(kbuf + ret, count - ret,
 			"Page has been migrated, last migrate reason: %s\n",
-			migrate_reason_names[page_ext->last_migrate_reason]);
+			migrate_reason_names[page_owner->last_migrate_reason]);
 		if (ret >= count)
 			goto err;
 	}
@@ -360,6 +387,7 @@ err:
 void __dump_page_owner(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
+	struct page_owner *page_owner;
 	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
 	struct stack_trace trace = {
 		.nr_entries = 0,
@@ -375,7 +403,9 @@ void __dump_page_owner(struct page *page)
 		pr_alert("There is not page extension available.\n");
 		return;
 	}
-	gfp_mask = page_ext->gfp_mask;
+
+	page_owner = get_page_owner(page_ext);
+	gfp_mask = page_owner->gfp_mask;
 	mt = gfpflags_to_migratetype(gfp_mask);
 
 	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
@@ -383,7 +413,7 @@ void __dump_page_owner(struct page *page)
 		return;
 	}
 
-	handle = READ_ONCE(page_ext->handle);
+	handle = READ_ONCE(page_owner->handle);
 	if (!handle) {
 		pr_alert("page_owner info is not active (free page?)\n");
 		return;
@@ -391,12 +421,12 @@ void __dump_page_owner(struct page *page)
 
 	depot_fetch_stack(handle, &trace);
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
-		 page_ext->order, migratetype_names[mt], gfp_mask, &gfp_mask);
+		 page_owner->order, migratetype_names[mt], gfp_mask, &gfp_mask);
 	print_stack_trace(&trace, 0);
 
-	if (page_ext->last_migrate_reason != -1)
+	if (page_owner->last_migrate_reason != -1)
 		pr_alert("page has been migrated, last migrate reason: %s\n",
-			migrate_reason_names[page_ext->last_migrate_reason]);
+			migrate_reason_names[page_owner->last_migrate_reason]);
 }
 
 static ssize_t
@@ -405,6 +435,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	unsigned long pfn;
 	struct page *page;
 	struct page_ext *page_ext;
+	struct page_owner *page_owner;
 	depot_stack_handle_t handle;
 
 	if (!static_branch_unlikely(&page_owner_inited))
@@ -454,11 +485,13 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
 			continue;
 
+		page_owner = get_page_owner(page_ext);
+
 		/*
 		 * Access to page_ext->handle isn't synchronous so we should
 		 * be careful to access it.
 		 */
-		handle = READ_ONCE(page_ext->handle);
+		handle = READ_ONCE(page_owner->handle);
 		if (!handle)
 			continue;
 
@@ -466,7 +499,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		*ppos = (pfn - min_low_pfn) + 1;
 
 		return print_page_owner(buf, count, pfn, page,
-				page_ext, handle);
+				page_owner, handle);
 	}
 
 	return 0;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
