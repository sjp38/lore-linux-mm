Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCE1A828E1
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:58:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e189so147695842pfa.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:04 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id x13si11081448pfi.161.2016.06.17.00.58.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 00:58:03 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id c74so5747700pfb.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:58:03 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 6/9] mm/page_owner: use stackdepot to store stacktrace
Date: Fri, 17 Jun 2016 16:57:36 +0900
Message-Id: <1466150259-27727-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1466150259-27727-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we store each page's allocation stacktrace on corresponding
page_ext structure and it requires a lot of memory.  This causes the
problem that memory tight system doesn't work well if page_owner is
enabled.  Moreover, even with this large memory consumption, we cannot get
full stacktrace because we allocate memory at boot time and just maintain
8 stacktrace slots to balance memory consumption.  We could increase it to
more but it would make system unusable or change system behaviour.

To solve the problem, this patch uses stackdepot to store stacktrace.  It
obviously provides memory saving but there is a drawback that stackdepot
could fail.

stackdepot allocates memory at runtime so it could fail if system has not
enough memory.  But, most of allocation stack are generated at very early
time and there are much memory at this time.  So, failure would not happen
easily.  And, one failure means that we miss just one page's allocation
stacktrace so it would not be a big problem.  In this patch, when memory
allocation failure happens, we store special stracktrace handle to the
page that is failed to save stacktrace.  With it, user can guess memory
usage properly even if failure happens.

Memory saving looks as following. (4GB memory system with page_owner)
(before the patch -> after the patch)

static allocation:
92274688 bytes -> 25165824 bytes

dynamic allocation after boot + kernel build:
0 bytes -> 327680 bytes

total:
92274688 bytes -> 25493504 bytes

72% reduction in total.

Note that implementation looks complex than someone would imagine because
there is recursion issue.  stackdepot uses page allocator and page_owner
is called at page allocation.  Using stackdepot in page_owner could
re-call page allcator and then page_owner.  That is a recursion.  To
detect and avoid it, whenever we obtain stacktrace, recursion is checked
and page_owner is set to dummy information if found.  Dummy information
means that this page is allocated for page_owner feature itself (such as
stackdepot) and it's understandable behavior for user.

Link: http://lkml.kernel.org/r/1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Alexander Potapenko <glider@google.com>
Cc: Hugh Dickins <hughd@google.com>
---
 include/linux/page_ext.h |   4 +-
 lib/Kconfig.debug        |   1 +
 mm/page_owner.c          | 142 ++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 126 insertions(+), 21 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index e1fe7cf..03f2a3e 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 #include <linux/stacktrace.h>
+#include <linux/stackdepot.h>
 
 struct pglist_data;
 struct page_ext_operations {
@@ -44,9 +45,8 @@ struct page_ext {
 #ifdef CONFIG_PAGE_OWNER
 	unsigned int order;
 	gfp_t gfp_mask;
-	unsigned int nr_entries;
 	int last_migrate_reason;
-	unsigned long trace_entries[8];
+	depot_stack_handle_t handle;
 #endif
 };
 
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 5a7f978..d40833b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -248,6 +248,7 @@ config PAGE_OWNER
 	depends on DEBUG_KERNEL && STACKTRACE_SUPPORT
 	select DEBUG_FS
 	select STACKTRACE
+	select STACKDEPOT
 	select PAGE_EXTENSION
 	help
 	  This keeps track of what call chain is the owner of a page, may
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 499ad26..dc92241 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -7,11 +7,22 @@
 #include <linux/page_owner.h>
 #include <linux/jump_label.h>
 #include <linux/migrate.h>
+#include <linux/stackdepot.h>
+
 #include "internal.h"
 
+/*
+ * TODO: teach PAGE_OWNER_STACK_DEPTH (__dump_page_owner and save_stack)
+ * to use off stack temporal storage
+ */
+#define PAGE_OWNER_STACK_DEPTH (16)
+
 static bool page_owner_disabled = true;
 DEFINE_STATIC_KEY_FALSE(page_owner_inited);
 
+static depot_stack_handle_t dummy_handle;
+static depot_stack_handle_t failure_handle;
+
 static void init_early_allocated_pages(void);
 
 static int early_page_owner_param(char *buf)
@@ -34,11 +45,41 @@ static bool need_page_owner(void)
 	return true;
 }
 
+static noinline void register_dummy_stack(void)
+{
+	unsigned long entries[4];
+	struct stack_trace dummy;
+
+	dummy.nr_entries = 0;
+	dummy.max_entries = ARRAY_SIZE(entries);
+	dummy.entries = &entries[0];
+	dummy.skip = 0;
+
+	save_stack_trace(&dummy);
+	dummy_handle = depot_save_stack(&dummy, GFP_KERNEL);
+}
+
+static noinline void register_failure_stack(void)
+{
+	unsigned long entries[4];
+	struct stack_trace failure;
+
+	failure.nr_entries = 0;
+	failure.max_entries = ARRAY_SIZE(entries);
+	failure.entries = &entries[0];
+	failure.skip = 0;
+
+	save_stack_trace(&failure);
+	failure_handle = depot_save_stack(&failure, GFP_KERNEL);
+}
+
 static void init_page_owner(void)
 {
 	if (page_owner_disabled)
 		return;
 
+	register_dummy_stack();
+	register_failure_stack();
 	static_branch_enable(&page_owner_inited);
 	init_early_allocated_pages();
 }
@@ -61,25 +102,66 @@ void __reset_page_owner(struct page *page, unsigned int order)
 	}
 }
 
-void __set_page_owner(struct page *page, unsigned int order, gfp_t gfp_mask)
+static inline bool check_recursive_alloc(struct stack_trace *trace,
+					unsigned long ip)
 {
-	struct page_ext *page_ext = lookup_page_ext(page);
+	int i, count;
+
+	if (!trace->nr_entries)
+		return false;
+
+	for (i = 0, count = 0; i < trace->nr_entries; i++) {
+		if (trace->entries[i] == ip && ++count == 2)
+			return true;
+	}
 
+	return false;
+}
+
+static noinline depot_stack_handle_t save_stack(gfp_t flags)
+{
+	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
 	struct stack_trace trace = {
 		.nr_entries = 0,
-		.max_entries = ARRAY_SIZE(page_ext->trace_entries),
-		.entries = &page_ext->trace_entries[0],
-		.skip = 3,
+		.entries = entries,
+		.max_entries = PAGE_OWNER_STACK_DEPTH,
+		.skip = 0
 	};
+	depot_stack_handle_t handle;
+
+	save_stack_trace(&trace);
+	if (trace.nr_entries != 0 &&
+	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
+		trace.nr_entries--;
+
+	/*
+	 * We need to check recursion here because our request to stackdepot
+	 * could trigger memory allocation to save new entry. New memory
+	 * allocation would reach here and call depot_save_stack() again
+	 * if we don't catch it. There is still not enough memory in stackdepot
+	 * so it would try to allocate memory again and loop forever.
+	 */
+	if (check_recursive_alloc(&trace, _RET_IP_))
+		return dummy_handle;
+
+	handle = depot_save_stack(&trace, flags);
+	if (!handle)
+		handle = failure_handle;
+
+	return handle;
+}
+
+noinline void __set_page_owner(struct page *page, unsigned int order,
+					gfp_t gfp_mask)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
 
 	if (unlikely(!page_ext))
 		return;
 
-	save_stack_trace(&trace);
-
+	page_ext->handle = save_stack(gfp_mask);
 	page_ext->order = order;
 	page_ext->gfp_mask = gfp_mask;
-	page_ext->nr_entries = trace.nr_entries;
 	page_ext->last_migrate_reason = -1;
 
 	__set_bit(PAGE_EXT_OWNER, &page_ext->flags);
@@ -111,7 +193,6 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 {
 	struct page_ext *old_ext = lookup_page_ext(oldpage);
 	struct page_ext *new_ext = lookup_page_ext(newpage);
-	int i;
 
 	if (unlikely(!old_ext || !new_ext))
 		return;
@@ -119,10 +200,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 	new_ext->order = old_ext->order;
 	new_ext->gfp_mask = old_ext->gfp_mask;
 	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
-	new_ext->nr_entries = old_ext->nr_entries;
-
-	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
-		new_ext->trace_entries[i] = old_ext->trace_entries[i];
+	new_ext->handle = old_ext->handle;
 
 	/*
 	 * We don't clear the bit on the oldpage as it's going to be freed
@@ -138,14 +216,18 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 
 static ssize_t
 print_page_owner(char __user *buf, size_t count, unsigned long pfn,
-		struct page *page, struct page_ext *page_ext)
+		struct page *page, struct page_ext *page_ext,
+		depot_stack_handle_t handle)
 {
 	int ret;
 	int pageblock_mt, page_mt;
 	char *kbuf;
+	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
 	struct stack_trace trace = {
-		.nr_entries = page_ext->nr_entries,
-		.entries = &page_ext->trace_entries[0],
+		.nr_entries = 0,
+		.entries = entries,
+		.max_entries = PAGE_OWNER_STACK_DEPTH,
+		.skip = 0
 	};
 
 	kbuf = kmalloc(count, GFP_KERNEL);
@@ -174,6 +256,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (ret >= count)
 		goto err;
 
+	depot_fetch_stack(handle, &trace);
 	ret += snprint_stack_trace(kbuf + ret, count - ret, &trace, 0);
 	if (ret >= count)
 		goto err;
@@ -204,10 +287,14 @@ err:
 void __dump_page_owner(struct page *page)
 {
 	struct page_ext *page_ext = lookup_page_ext(page);
+	unsigned long entries[PAGE_OWNER_STACK_DEPTH];
 	struct stack_trace trace = {
-		.nr_entries = page_ext->nr_entries,
-		.entries = &page_ext->trace_entries[0],
+		.nr_entries = 0,
+		.entries = entries,
+		.max_entries = PAGE_OWNER_STACK_DEPTH,
+		.skip = 0
 	};
+	depot_stack_handle_t handle;
 	gfp_t gfp_mask = page_ext->gfp_mask;
 	int mt = gfpflags_to_migratetype(gfp_mask);
 
@@ -221,6 +308,13 @@ void __dump_page_owner(struct page *page)
 		return;
 	}
 
+	handle = READ_ONCE(page_ext->handle);
+	if (!handle) {
+		pr_alert("page_owner info is not active (free page?)\n");
+		return;
+	}
+
+	depot_fetch_stack(handle, &trace);
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
 		 page_ext->order, migratetype_names[mt], gfp_mask, &gfp_mask);
 	print_stack_trace(&trace, 0);
@@ -236,6 +330,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	unsigned long pfn;
 	struct page *page;
 	struct page_ext *page_ext;
+	depot_stack_handle_t handle;
 
 	if (!static_branch_unlikely(&page_owner_inited))
 		return -EINVAL;
@@ -284,10 +379,19 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags))
 			continue;
 
+		/*
+		 * Access to page_ext->handle isn't synchronous so we should
+		 * be careful to access it.
+		 */
+		handle = READ_ONCE(page_ext->handle);
+		if (!handle)
+			continue;
+
 		/* Record the next PFN to read in the file offset */
 		*ppos = (pfn - min_low_pfn) + 1;
 
-		return print_page_owner(buf, count, pfn, page, page_ext);
+		return print_page_owner(buf, count, pfn, page,
+				page_ext, handle);
 	}
 
 	return 0;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
