Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 44C646B014F
	for <linux-mm@kvack.org>; Wed, 20 May 2015 23:50:30 -0400 (EDT)
Received: by oiww2 with SMTP id w2so2037725oiw.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 20:50:30 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id dh3si11891310oeb.1.2015.05.20.20.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 20:50:24 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v6 1/5] memory-failure: export page_type and action result
Date: Thu, 21 May 2015 11:41:21 +0800
Message-ID: <1432179685-11369-2-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com
Cc: rostedt@goodmis.org, gong.chen@linux.intel.com, mingo@redhat.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

Export 'outcome' and 'action_page_type' to mm.h, so we could use
this emnus outside.

This patch is preparation for adding trace events for memory-failure
recovery action.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/linux/mm.h  |   34 ++++++++++
 mm/memory-failure.c |  168 ++++++++++++++++++++------------------------------
 2 files changed, 101 insertions(+), 101 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0755b9f..3abf13c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2152,6 +2152,40 @@ extern void shake_page(struct page *p, int access);
 extern atomic_long_t num_poisoned_pages;
 extern int soft_offline_page(struct page *page, int flags);
 
+
+/*
+ * Error handlers for various types of pages.
+ */
+enum mf_outcome {
+	MF_IGNORED,	/* Error: cannot be handled */
+	MF_FAILED,	/* Error: handling failed */
+	MF_DELAYED,	/* Will be handled later */
+	MF_RECOVERED,	/* Successfully recovered */
+};
+
+enum mf_action_page_type {
+	MF_MSG_KERNEL,
+	MF_MSG_KERNEL_HIGH_ORDER,
+	MF_MSG_SLAB,
+	MF_MSG_DIFFERENT_COMPOUND,
+	MF_MSG_POISONED_HUGE,
+	MF_MSG_HUGE,
+	MF_MSG_FREE_HUGE,
+	MF_MSG_UNMAP_FAILED,
+	MF_MSG_DIRTY_SWAPCACHE,
+	MF_MSG_CLEAN_SWAPCACHE,
+	MF_MSG_DIRTY_MLOCKED_LRU,
+	MF_MSG_CLEAN_MLOCKED_LRU,
+	MF_MSG_DIRTY_UNEVICTABLE_LRU,
+	MF_MSG_CLEAN_UNEVICTABLE_LRU,
+	MF_MSG_DIRTY_LRU,
+	MF_MSG_CLEAN_LRU,
+	MF_MSG_TRUNCATED_LRU,
+	MF_MSG_BUDDY,
+	MF_MSG_BUDDY_2ND,
+	MF_MSG_UNKNOWN,
+};
+
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr,
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 501820c..5650dec 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -503,68 +503,34 @@ static void collect_procs(struct page *page, struct list_head *tokill,
 	kfree(tk);
 }
 
-/*
- * Error handlers for various types of pages.
- */
-
-enum outcome {
-	IGNORED,	/* Error: cannot be handled */
-	FAILED,		/* Error: handling failed */
-	DELAYED,	/* Will be handled later */
-	RECOVERED,	/* Successfully recovered */
-};
-
 static const char *action_name[] = {
-	[IGNORED] = "Ignored",
-	[FAILED] = "Failed",
-	[DELAYED] = "Delayed",
-	[RECOVERED] = "Recovered",
-};
-
-enum action_page_type {
-	MSG_KERNEL,
-	MSG_KERNEL_HIGH_ORDER,
-	MSG_SLAB,
-	MSG_DIFFERENT_COMPOUND,
-	MSG_POISONED_HUGE,
-	MSG_HUGE,
-	MSG_FREE_HUGE,
-	MSG_UNMAP_FAILED,
-	MSG_DIRTY_SWAPCACHE,
-	MSG_CLEAN_SWAPCACHE,
-	MSG_DIRTY_MLOCKED_LRU,
-	MSG_CLEAN_MLOCKED_LRU,
-	MSG_DIRTY_UNEVICTABLE_LRU,
-	MSG_CLEAN_UNEVICTABLE_LRU,
-	MSG_DIRTY_LRU,
-	MSG_CLEAN_LRU,
-	MSG_TRUNCATED_LRU,
-	MSG_BUDDY,
-	MSG_BUDDY_2ND,
-	MSG_UNKNOWN,
+	[MF_IGNORED] = "Ignored",
+	[MF_FAILED] = "Failed",
+	[MF_DELAYED] = "Delayed",
+	[MF_RECOVERED] = "Recovered",
 };
 
 static const char * const action_page_types[] = {
-	[MSG_KERNEL]			= "reserved kernel page",
-	[MSG_KERNEL_HIGH_ORDER]		= "high-order kernel page",
-	[MSG_SLAB]			= "kernel slab page",
-	[MSG_DIFFERENT_COMPOUND]	= "different compound page after locking",
-	[MSG_POISONED_HUGE]		= "huge page already hardware poisoned",
-	[MSG_HUGE]			= "huge page",
-	[MSG_FREE_HUGE]			= "free huge page",
-	[MSG_UNMAP_FAILED]		= "unmapping failed page",
-	[MSG_DIRTY_SWAPCACHE]		= "dirty swapcache page",
-	[MSG_CLEAN_SWAPCACHE]		= "clean swapcache page",
-	[MSG_DIRTY_MLOCKED_LRU]		= "dirty mlocked LRU page",
-	[MSG_CLEAN_MLOCKED_LRU]		= "clean mlocked LRU page",
-	[MSG_DIRTY_UNEVICTABLE_LRU]	= "dirty unevictable LRU page",
-	[MSG_CLEAN_UNEVICTABLE_LRU]	= "clean unevictable LRU page",
-	[MSG_DIRTY_LRU]			= "dirty LRU page",
-	[MSG_CLEAN_LRU]			= "clean LRU page",
-	[MSG_TRUNCATED_LRU]		= "already truncated LRU page",
-	[MSG_BUDDY]			= "free buddy page",
-	[MSG_BUDDY_2ND]			= "free buddy page (2nd try)",
-	[MSG_UNKNOWN]			= "unknown page",
+	[MF_MSG_KERNEL]			= "reserved kernel page",
+	[MF_MSG_KERNEL_HIGH_ORDER]	= "high-order kernel page",
+	[MF_MSG_SLAB]			= "kernel slab page",
+	[MF_MSG_DIFFERENT_COMPOUND]	= "different compound page after locking",
+	[MF_MSG_POISONED_HUGE]		= "huge page already hardware poisoned",
+	[MF_MSG_HUGE]			= "huge page",
+	[MF_MSG_FREE_HUGE]		= "free huge page",
+	[MF_MSG_UNMAP_FAILED]		= "unmapping failed page",
+	[MF_MSG_DIRTY_SWAPCACHE]	= "dirty swapcache page",
+	[MF_MSG_CLEAN_SWAPCACHE]	= "clean swapcache page",
+	[MF_MSG_DIRTY_MLOCKED_LRU]	= "dirty mlocked LRU page",
+	[MF_MSG_CLEAN_MLOCKED_LRU]	= "clean mlocked LRU page",
+	[MF_MSG_DIRTY_UNEVICTABLE_LRU]	= "dirty unevictable LRU page",
+	[MF_MSG_CLEAN_UNEVICTABLE_LRU]	= "clean unevictable LRU page",
+	[MF_MSG_DIRTY_LRU]		= "dirty LRU page",
+	[MF_MSG_CLEAN_LRU]		= "clean LRU page",
+	[MF_MSG_TRUNCATED_LRU]		= "already truncated LRU page",
+	[MF_MSG_BUDDY]			= "free buddy page",
+	[MF_MSG_BUDDY_2ND]		= "free buddy page (2nd try)",
+	[MF_MSG_UNKNOWN]		= "unknown page",
 };
 
 /*
@@ -598,7 +564,7 @@ static int delete_from_lru_cache(struct page *p)
  */
 static int me_kernel(struct page *p, unsigned long pfn)
 {
-	return IGNORED;
+	return MF_IGNORED;
 }
 
 /*
@@ -607,7 +573,7 @@ static int me_kernel(struct page *p, unsigned long pfn)
 static int me_unknown(struct page *p, unsigned long pfn)
 {
 	printk(KERN_ERR "MCE %#lx: Unknown page state\n", pfn);
-	return FAILED;
+	return MF_FAILED;
 }
 
 /*
@@ -616,7 +582,7 @@ static int me_unknown(struct page *p, unsigned long pfn)
 static int me_pagecache_clean(struct page *p, unsigned long pfn)
 {
 	int err;
-	int ret = FAILED;
+	int ret = MF_FAILED;
 	struct address_space *mapping;
 
 	delete_from_lru_cache(p);
@@ -626,7 +592,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 	 * should be the one m_f() holds.
 	 */
 	if (PageAnon(p))
-		return RECOVERED;
+		return MF_RECOVERED;
 
 	/*
 	 * Now truncate the page in the page cache. This is really
@@ -640,7 +606,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 		/*
 		 * Page has been teared down in the meanwhile
 		 */
-		return FAILED;
+		return MF_FAILED;
 	}
 
 	/*
@@ -657,7 +623,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 				!try_to_release_page(p, GFP_NOIO)) {
 			pr_info("MCE %#lx: failed to release buffers\n", pfn);
 		} else {
-			ret = RECOVERED;
+			ret = MF_RECOVERED;
 		}
 	} else {
 		/*
@@ -665,7 +631,7 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
 		 * This fails on dirty or anything with private pages
 		 */
 		if (invalidate_inode_page(p))
-			ret = RECOVERED;
+			ret = MF_RECOVERED;
 		else
 			printk(KERN_INFO "MCE %#lx: Failed to invalidate\n",
 				pfn);
@@ -751,9 +717,9 @@ static int me_swapcache_dirty(struct page *p, unsigned long pfn)
 	ClearPageUptodate(p);
 
 	if (!delete_from_lru_cache(p))
-		return DELAYED;
+		return MF_DELAYED;
 	else
-		return FAILED;
+		return MF_FAILED;
 }
 
 static int me_swapcache_clean(struct page *p, unsigned long pfn)
@@ -761,9 +727,9 @@ static int me_swapcache_clean(struct page *p, unsigned long pfn)
 	delete_from_swap_cache(p);
 
 	if (!delete_from_lru_cache(p))
-		return RECOVERED;
+		return MF_RECOVERED;
 	else
-		return FAILED;
+		return MF_FAILED;
 }
 
 /*
@@ -789,9 +755,9 @@ static int me_huge_page(struct page *p, unsigned long pfn)
 	if (!(page_mapping(hpage) || PageAnon(hpage))) {
 		res = dequeue_hwpoisoned_huge_page(hpage);
 		if (!res)
-			return RECOVERED;
+			return MF_RECOVERED;
 	}
-	return DELAYED;
+	return MF_DELAYED;
 }
 
 /*
@@ -823,10 +789,10 @@ static int me_huge_page(struct page *p, unsigned long pfn)
 static struct page_state {
 	unsigned long mask;
 	unsigned long res;
-	enum action_page_type type;
+	enum mf_action_page_type type;
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] = {
-	{ reserved,	reserved,	MSG_KERNEL,	me_kernel },
+	{ reserved,	reserved,	MF_MSG_KERNEL,	me_kernel },
 	/*
 	 * free pages are specially detected outside this table:
 	 * PG_buddy pages only make a small fraction of all free pages.
@@ -837,31 +803,31 @@ static struct page_state {
 	 * currently unused objects without touching them. But just
 	 * treat it as standard kernel for now.
 	 */
-	{ slab,		slab,		MSG_SLAB,	me_kernel },
+	{ slab,		slab,		MF_MSG_SLAB,	me_kernel },
 
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
-	{ head,		head,		MSG_HUGE,		me_huge_page },
-	{ tail,		tail,		MSG_HUGE,		me_huge_page },
+	{ head,		head,		MF_MSG_HUGE,		me_huge_page },
+	{ tail,		tail,		MF_MSG_HUGE,		me_huge_page },
 #else
-	{ compound,	compound,	MSG_HUGE,		me_huge_page },
+	{ compound,	compound,	MF_MSG_HUGE,		me_huge_page },
 #endif
 
-	{ sc|dirty,	sc|dirty,	MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
-	{ sc|dirty,	sc,		MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
+	{ sc|dirty,	sc|dirty,	MF_MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
+	{ sc|dirty,	sc,		MF_MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
 
-	{ mlock|dirty,	mlock|dirty,	MSG_DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
-	{ mlock|dirty,	mlock,		MSG_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
+	{ mlock|dirty,	mlock|dirty,	MF_MSG_DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
+	{ mlock|dirty,	mlock,		MF_MSG_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
 
-	{ unevict|dirty, unevict|dirty,	MSG_DIRTY_UNEVICTABLE_LRU,	me_pagecache_dirty },
-	{ unevict|dirty, unevict,	MSG_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean },
+	{ unevict|dirty, unevict|dirty,	MF_MSG_DIRTY_UNEVICTABLE_LRU,	me_pagecache_dirty },
+	{ unevict|dirty, unevict,	MF_MSG_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean },
 
-	{ lru|dirty,	lru|dirty,	MSG_DIRTY_LRU,	me_pagecache_dirty },
-	{ lru|dirty,	lru,		MSG_CLEAN_LRU,	me_pagecache_clean },
+	{ lru|dirty,	lru|dirty,	MF_MSG_DIRTY_LRU,	me_pagecache_dirty },
+	{ lru|dirty,	lru,		MF_MSG_CLEAN_LRU,	me_pagecache_clean },
 
 	/*
 	 * Catchall entry: must be at end.
 	 */
-	{ 0,		0,		MSG_UNKNOWN,	me_unknown },
+	{ 0,		0,		MF_MSG_UNKNOWN,	me_unknown },
 };
 
 #undef dirty
@@ -881,7 +847,7 @@ static struct page_state {
  * "Dirty/Clean" indication is not 100% accurate due to the possibility of
  * setting PG_dirty outside page lock. See also comment above set_page_dirty().
  */
-static void action_result(unsigned long pfn, enum action_page_type type, int result)
+static void action_result(unsigned long pfn, enum mf_action_page_type type, int result)
 {
 	pr_err("MCE %#lx: recovery action for %s: %s\n",
 		pfn, action_page_types[type], action_name[result]);
@@ -896,13 +862,13 @@ static int page_action(struct page_state *ps, struct page *p,
 	result = ps->action(p, pfn);
 
 	count = page_count(p) - 1;
-	if (ps->action == me_swapcache_dirty && result == DELAYED)
+	if (ps->action == me_swapcache_dirty && result == MF_DELAYED)
 		count--;
 	if (count != 0) {
 		printk(KERN_ERR
 		       "MCE %#lx: %s still referenced by %d users\n",
 		       pfn, action_page_types[ps->type], count);
-		result = FAILED;
+		result = MF_FAILED;
 	}
 	action_result(pfn, ps->type, result);
 
@@ -911,7 +877,7 @@ static int page_action(struct page_state *ps, struct page *p,
 	 * Could adjust zone counters here to correct for the missing page.
 	 */
 
-	return (result == RECOVERED || result == DELAYED) ? 0 : -EBUSY;
+	return (result == MF_RECOVERED || result == MF_DELAYED) ? 0 : -EBUSY;
 }
 
 /*
@@ -1152,7 +1118,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	if (!(flags & MF_COUNT_INCREASED) &&
 		!get_page_unless_zero(hpage)) {
 		if (is_free_buddy_page(p)) {
-			action_result(pfn, MSG_BUDDY, DELAYED);
+			action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
 			return 0;
 		} else if (PageHuge(hpage)) {
 			/*
@@ -1169,12 +1135,12 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			}
 			set_page_hwpoison_huge_page(hpage);
 			res = dequeue_hwpoisoned_huge_page(hpage);
-			action_result(pfn, MSG_FREE_HUGE,
-				      res ? IGNORED : DELAYED);
+			action_result(pfn, MF_MSG_FREE_HUGE,
+				      res ? MF_IGNORED : MF_DELAYED);
 			unlock_page(hpage);
 			return res;
 		} else {
-			action_result(pfn, MSG_KERNEL_HIGH_ORDER, IGNORED);
+			action_result(pfn, MF_MSG_KERNEL_HIGH_ORDER, MF_IGNORED);
 			return -EBUSY;
 		}
 	}
@@ -1196,10 +1162,10 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 			 */
 			if (is_free_buddy_page(p)) {
 				if (flags & MF_COUNT_INCREASED)
-					action_result(pfn, MSG_BUDDY, DELAYED);
+					action_result(pfn, MF_MSG_BUDDY, MF_DELAYED);
 				else
-					action_result(pfn, MSG_BUDDY_2ND,
-						      DELAYED);
+					action_result(pfn, MF_MSG_BUDDY_2ND,
+						      MF_DELAYED);
 				return 0;
 			}
 		}
@@ -1212,7 +1178,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * If this happens just bail out.
 	 */
 	if (compound_head(p) != hpage) {
-		action_result(pfn, MSG_DIFFERENT_COMPOUND, IGNORED);
+		action_result(pfn, MF_MSG_DIFFERENT_COMPOUND, MF_IGNORED);
 		res = -EBUSY;
 		goto out;
 	}
@@ -1252,7 +1218,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * on the head page to show that the hugepage is hwpoisoned
 	 */
 	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
-		action_result(pfn, MSG_POISONED_HUGE, IGNORED);
+		action_result(pfn, MF_MSG_POISONED_HUGE, MF_IGNORED);
 		unlock_page(hpage);
 		put_page(hpage);
 		return 0;
@@ -1281,7 +1247,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 */
 	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
 	    != SWAP_SUCCESS) {
-		action_result(pfn, MSG_UNMAP_FAILED, IGNORED);
+		action_result(pfn, MF_MSG_UNMAP_FAILED, MF_IGNORED);
 		res = -EBUSY;
 		goto out;
 	}
@@ -1290,7 +1256,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping == NULL) {
-		action_result(pfn, MSG_TRUNCATED_LRU, IGNORED);
+		action_result(pfn, MF_MSG_TRUNCATED_LRU, MF_IGNORED);
 		res = -EBUSY;
 		goto out;
 	}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
