Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7D9D76B0264
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:12:19 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id qh10so35725547pac.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:19 -0700 (PDT)
Received: from mail-pa0-x242.google.com (mail-pa0-x242.google.com. [2607:f8b0:400e:c03::242])
        by mx.google.com with ESMTPS id d185si3837802pfa.76.2016.07.08.05.12.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:12:18 -0700 (PDT)
Received: by mail-pa0-x242.google.com with SMTP id us13so6241691pab.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:12:18 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH v2 3/3] mm/page_owner: track page free call chain
Date: Fri,  8 Jul 2016 21:11:32 +0900
Message-Id: <20160708121132.8253-4-sergey.senozhatsky@gmail.com>
In-Reply-To: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
References: <20160708121132.8253-1-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Extend page_owner with free_pages() tracking functionality. This adds to the
dump_page_owner() output an additional backtrace, that tells us what path has
freed the page.

Aa a trivial example, let's assume that do_some_foo() has an error - an extra
put_page() on error return path, and the function is also getting preempted,
letting some other task to allocate the same page, which is then 'mistakenly'
getting freed once again by do_some_foo().

CPUA					CPUB

void do_some_foo(void)
{
	page = alloc_page();
	if (error) {
		put_page(page);
		goto out;
	}
	...
out:
	<<preempted>>
					void do_some_bar()
					{
						page = alloc_page();
						...
						<<preempted>>
	...
	put_page(page);
}
						<<use freed page>>
						put_page(page);
					}

With the existing implementation we would see only CPUB's backtrace
from bad_page. The extended page_owner would also report CPUA's
put_page(), which can be a helpful hint.

Backtrace:

 BUG: Bad page state in process cc1  pfn:bae1d
 page:ffffea0002eb8740 count:-1 mapcount:0 mapping:          (null) index:0x0
 flags: 0x4000000000000000()
 page dumped because: nonzero _count
 page allocated via order 0, migratetype Unmovable, gfp_mask 0x2000200(GFP_NOWAIT|__GFP_NOWARN)
  [<ffffffff8101bc9c>] save_stack_trace+0x26/0x41
  [<ffffffff81110fe4>] save_stack+0x46/0xc3
  [<ffffffff81111481>] __page_owner_alloc_pages+0x24/0x41
  [<ffffffff810c9867>] post_alloc_hook+0x1e/0x20
  [<ffffffff810ca63d>] get_page_from_freelist+0x4fd/0x756
  [<ffffffff810cadea>] __alloc_pages_nodemask+0xe7/0xbcf
  [<ffffffff810cb8e4>] __get_free_pages+0x12/0x40
  [<ffffffff810e6b64>] __tlb_remove_page_size.part.12+0x37/0x78
  [<ffffffff810e6d9b>] __tlb_remove_page_size+0x21/0x23
  [<ffffffff810e7ff2>] unmap_page_range+0x63a/0x75b
  [<ffffffff810e81cf>] unmap_single_vma+0xbc/0xc6
  [<ffffffff810e82d2>] unmap_vmas+0x35/0x44
  [<ffffffff810ee6f4>] exit_mmap+0x5a/0xec
  [<ffffffff810385b4>] mmput+0x4a/0xdc
  [<ffffffff8103dff7>] do_exit+0x398/0x8de
  [<ffffffff8103e5ae>] do_group_exit+0x45/0xb0
 page freed, was allocated via order 0, migratetype Unmovable, gfp_mask 0x2000200(GFP_NOWAIT|__GFP_NOWARN)
  [<ffffffff8101bc9c>] save_stack_trace+0x26/0x41
  [<ffffffff81110fe4>] save_stack+0x46/0xc3
  [<ffffffff81111411>] __page_owner_free_pages+0x25/0x71
  [<ffffffff810c9f0a>] free_hot_cold_page+0x1d6/0x1ea
  [<ffffffff810d03e1>] __put_page+0x37/0x3a
  [<ffffffff8115b8da>] do_some_foo()+0x8a/0x8e
	...
 Modules linked in: ....
 CPU: 3 PID: 1274 Comm: cc1 Not tainted 4.7.0-rc5-next-20160701-dbg-00009-ge01494f-dirty #535
  0000000000000000 ffff8800aeea3c18 ffffffff811e67ca ffffea0002eb8740
  ffffffff8175675e ffff8800aeea3c40 ffffffff810c87f5 0000000000000000
  ffffffff81880b40 ffff880137d98438 ffff8800aeea3c50 ffffffff810c88d5
 Call Trace:
  [<ffffffff811e67ca>] dump_stack+0x68/0x92
  [<ffffffff810c87f5>] bad_page+0xf8/0x11e
  [<ffffffff810c88d5>] check_new_page_bad+0x63/0x65
  [<ffffffff810ca36a>] get_page_from_freelist+0x22a/0x756
  [<ffffffff810cadea>] __alloc_pages_nodemask+0xe7/0xbcf
  [<ffffffff81073a43>] ? trace_hardirqs_on_caller+0x16d/0x189
  [<ffffffff810ede8d>] ? vma_merge+0x159/0x249
  [<ffffffff81074aa0>] ? __lock_acquire+0x2ac/0x15c7
  [<ffffffff81034ace>] pte_alloc_one+0x1b/0x67
  [<ffffffff810e922b>] __pte_alloc+0x19/0xa6
  [<ffffffff810eb09f>] handle_mm_fault+0x409/0xc59
  [<ffffffff810309f6>] __do_page_fault+0x1d8/0x3ac
  [<ffffffff81030bf7>] do_page_fault+0xc/0xe
  [<ffffffff814a84af>] page_fault+0x1f/0x30

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/page_ext.h | 11 ++++++-
 mm/page_owner.c          | 74 ++++++++++++++++++++++++++++++------------------
 mm/vmstat.c              |  3 ++
 3 files changed, 59 insertions(+), 29 deletions(-)

diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index 66ba2bb..0cccc94 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -27,12 +27,21 @@ enum page_ext_flags {
 	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
 	PAGE_EXT_DEBUG_GUARD,
 	PAGE_EXT_OWNER_ALLOC,
+	PAGE_EXT_OWNER_FREE,
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	PAGE_EXT_YOUNG,
 	PAGE_EXT_IDLE,
 #endif
 };
 
+#ifdef CONFIG_PAGE_OWNER
+enum page_owner_handles {
+	PAGE_OWNER_HANDLE_ALLOC,
+	PAGE_OWNER_HANDLE_FREE,
+	PAGE_OWNER_HANDLE_MAX
+};
+#endif
+
 /*
  * Page Extension can be considered as an extended mem_map.
  * A page_ext page is associated with every page descriptor. The
@@ -46,7 +55,7 @@ struct page_ext {
 	unsigned int order;
 	gfp_t gfp_mask;
 	int last_migrate_reason;
-	depot_stack_handle_t handle;
+	depot_stack_handle_t handles[PAGE_OWNER_HANDLE_MAX];
 #endif
 };
 
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 4acccb7..c431ac4 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -13,6 +13,11 @@
 
 #define PAGE_OWNER_STACK_DEPTH (16)
 
+static const char *page_owner_handles_names[PAGE_OWNER_HANDLE_MAX] = {
+	"page allocated",
+	"page freed, was allocated",
+};
+
 static bool page_owner_disabled = true;
 DEFINE_STATIC_KEY_FALSE(page_owner_inited);
 
@@ -85,19 +90,6 @@ struct page_ext_operations page_owner_ops = {
 	.init = init_page_owner,
 };
 
-void __page_owner_free_pages(struct page *page, unsigned int order)
-{
-	int i;
-	struct page_ext *page_ext;
-
-	for (i = 0; i < (1 << order); i++) {
-		page_ext = lookup_page_ext(page + i);
-		if (unlikely(!page_ext))
-			continue;
-		__clear_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
-	}
-}
-
 static inline bool check_recursive_alloc(struct stack_trace *trace,
 					unsigned long ip)
 {
@@ -147,6 +139,23 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 	return handle;
 }
 
+void __page_owner_free_pages(struct page *page, unsigned int order)
+{
+	int i;
+	depot_stack_handle_t handle = save_stack(0);
+
+	for (i = 0; i < (1 << order); i++) {
+		struct page_ext *page_ext = lookup_page_ext(page + i);
+
+		if (unlikely(!page_ext))
+			continue;
+
+		page_ext->handles[PAGE_OWNER_HANDLE_FREE] = handle;
+		__set_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags);
+		__clear_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags);
+	}
+}
+
 noinline void __page_owner_alloc_pages(struct page *page, unsigned int order,
 					gfp_t gfp_mask)
 {
@@ -155,7 +164,7 @@ noinline void __page_owner_alloc_pages(struct page *page, unsigned int order,
 	if (unlikely(!page_ext))
 		return;
 
-	page_ext->handle = save_stack(gfp_mask);
+	page_ext->handles[PAGE_OWNER_HANDLE_ALLOC] = save_stack(gfp_mask);
 	page_ext->order = order;
 	page_ext->gfp_mask = gfp_mask;
 	page_ext->last_migrate_reason = -1;
@@ -189,6 +198,7 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 {
 	struct page_ext *old_ext = lookup_page_ext(oldpage);
 	struct page_ext *new_ext = lookup_page_ext(newpage);
+	int i;
 
 	if (unlikely(!old_ext || !new_ext))
 		return;
@@ -196,7 +206,9 @@ void __copy_page_owner(struct page *oldpage, struct page *newpage)
 	new_ext->order = old_ext->order;
 	new_ext->gfp_mask = old_ext->gfp_mask;
 	new_ext->last_migrate_reason = old_ext->last_migrate_reason;
-	new_ext->handle = old_ext->handle;
+
+	for (i = 0; i < PAGE_OWNER_HANDLE_MAX; i++)
+		new_ext->handles[i] = old_ext->handles[i];
 
 	/*
 	 * We don't clear the bit on the oldpage as it's going to be freed
@@ -292,7 +304,7 @@ void __dump_page_owner(struct page *page)
 	};
 	depot_stack_handle_t handle;
 	gfp_t gfp_mask;
-	int mt;
+	int mt, i;
 
 	if (unlikely(!page_ext)) {
 		pr_alert("There is not page extension available.\n");
@@ -301,25 +313,31 @@ void __dump_page_owner(struct page *page)
 	gfp_mask = page_ext->gfp_mask;
 	mt = gfpflags_to_migratetype(gfp_mask);
 
-	if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags)) {
+	if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags) &&
+			!test_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags)) {
 		pr_alert("page_owner info is not active (free page?)\n");
 		return;
 	}
 
-	handle = READ_ONCE(page_ext->handle);
-	if (!handle) {
-		pr_alert("page_owner info is not active (free page?)\n");
-		return;
-	}
+	for (i = 0; i < PAGE_OWNER_HANDLE_MAX; i++) {
+		handle = READ_ONCE(page_ext->handles[i]);
+		if (!handle) {
+			pr_alert("page_owner info is not active for `%s'\n",
+					page_owner_handles_names[i]);
+			continue;
+		}
 
-	depot_fetch_stack(handle, &trace);
-	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
-		 page_ext->order, migratetype_names[mt], gfp_mask, &gfp_mask);
-	print_stack_trace(&trace, 0);
+		depot_fetch_stack(handle, &trace);
+		pr_alert("%s via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
+				page_owner_handles_names[i], page_ext->order,
+				migratetype_names[mt], gfp_mask, &gfp_mask);
+		print_stack_trace(&trace, 0);
 
-	if (page_ext->last_migrate_reason != -1)
+		if (page_ext->last_migrate_reason == -1)
+			continue;
 		pr_alert("page has been migrated, last migrate reason: %s\n",
 			migrate_reason_names[page_ext->last_migrate_reason]);
+	}
 }
 
 static ssize_t
@@ -381,7 +399,7 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 		 * Access to page_ext->handle isn't synchronous so we should
 		 * be careful to access it.
 		 */
-		handle = READ_ONCE(page_ext->handle);
+		handle = READ_ONCE(page_ext->handles[PAGE_OWNER_HANDLE_ALLOC]);
 		if (!handle)
 			continue;
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 63ef65f..4ff0135 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1073,6 +1073,9 @@ static void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 			if (!test_bit(PAGE_EXT_OWNER_ALLOC, &page_ext->flags))
 				continue;
 
+			if (!test_bit(PAGE_EXT_OWNER_FREE, &page_ext->flags))
+				continue;
+
 			page_mt = gfpflags_to_migratetype(page_ext->gfp_mask);
 			if (pageblock_mt != page_mt) {
 				if (is_migrate_cma(pageblock_mt))
-- 
2.9.0.37.g6d523a3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
