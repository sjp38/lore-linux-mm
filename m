Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B90206B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:47:19 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u186so382285756ita.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:47:19 -0700 (PDT)
Received: from cliff.cs.toronto.edu (cliff.cs.toronto.edu. [128.100.3.120])
        by mx.google.com with ESMTPS id f84si9218015ita.39.2016.07.25.20.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 20:47:16 -0700 (PDT)
Message-Id: <0be7cf06443482bfa1ee5c71ada14f7bd899ca02.1469489884.git.gamvrosi@gmail.com>
In-Reply-To: <cover.1469489884.git.gamvrosi@gmail.com>
References: <cover.1469489884.git.gamvrosi@gmail.com>
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: [PATCH 1/3] mm: support for duet hooks
Date: Mon, 25 Jul 2016 23:47:15 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: George Amvrosiadis <gamvrosi@gmail.com>

Adds the Duet hooks in the page cache. In filemap.c, two hooks are added at the
time of addition and removal of a page descriptor. In page-flags.h, two more
hooks are added to track page dirtying and flushing.

The hooks are inactive while Duet is offline.

Signed-off-by: George Amvrosiadis <gamvrosi@gmail.com>
---
 include/linux/duet.h       | 43 +++++++++++++++++++++++++++++++++++++
 include/linux/page-flags.h | 53 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/filemap.c               | 11 ++++++++++
 3 files changed, 107 insertions(+)
 create mode 100644 include/linux/duet.h

diff --git a/include/linux/duet.h b/include/linux/duet.h
new file mode 100644
index 0000000..80491e2
--- /dev/null
+++ b/include/linux/duet.h
@@ -0,0 +1,43 @@
+/*
+ * Defs necessary for Duet hooks
+ *
+ * Author: George Amvrosiadis <gamvrosi@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public
+ * License v2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+#ifndef _DUET_H
+#define _DUET_H
+
+/*
+ * Duet hooks into the page cache to monitor four types of events:
+ *   ADDED:	a page __descriptor__ was inserted into the page cache
+ *   REMOVED:	a page __describptor__ was removed from the page cache
+ *   DIRTY:	page's dirty bit was set
+ *   FLUSHED:	page's dirty bit was cleared
+ */
+#define DUET_PAGE_ADDED		0x0001
+#define DUET_PAGE_REMOVED	0x0002
+#define DUET_PAGE_DIRTY		0x0004
+#define DUET_PAGE_FLUSHED	0x0008
+
+#define DUET_HOOK(funp, evt, data) \
+	do { \
+		rcu_read_lock(); \
+		funp = rcu_dereference(duet_hook_fp); \
+		if (funp) \
+			funp(evt, (void *)data); \
+		rcu_read_unlock(); \
+	} while (0)
+
+/* Hook function pointer initialized by the Duet framework */
+typedef void (duet_hook_t) (__u16, void *);
+extern duet_hook_t *duet_hook_fp;
+
+#endif /* _DUET_H */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e5a3244..53be4a0 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -12,6 +12,9 @@
 #include <linux/mm_types.h>
 #include <generated/bounds.h>
 #endif /* !__GENERATING_BOUNDS_H */
+#ifdef CONFIG_DUET
+#include <linux/duet.h>
+#endif /* CONFIG_DUET */
 
 /*
  * Various page->flags bits:
@@ -254,8 +257,58 @@ PAGEFLAG(Error, error, PF_NO_COMPOUND) TESTCLEARFLAG(Error, error, PF_NO_COMPOUN
 PAGEFLAG(Referenced, referenced, PF_HEAD)
 	TESTCLEARFLAG(Referenced, referenced, PF_HEAD)
 	__SETPAGEFLAG(Referenced, referenced, PF_HEAD)
+#ifdef CONFIG_DUET
+TESTPAGEFLAG(Dirty, dirty, PF_HEAD)
+
+static inline void SetPageDirty(struct page *page)
+{
+	duet_hook_t *dhfp = NULL;
+
+	if (!test_and_set_bit(PG_dirty, &page->flags))
+		DUET_HOOK(dhfp, DUET_PAGE_DIRTY, page);
+}
+
+static inline void __ClearPageDirty(struct page *page)
+{
+	duet_hook_t *dhfp = NULL;
+
+	if (__test_and_clear_bit(PG_dirty, &page->flags))
+		DUET_HOOK(dhfp, DUET_PAGE_FLUSHED, page);
+}
+
+static inline void ClearPageDirty(struct page *page)
+{
+	duet_hook_t *dhfp = NULL;
+
+	if (test_and_clear_bit(PG_dirty, &page->flags))
+		DUET_HOOK(dhfp, DUET_PAGE_FLUSHED, page);
+}
+
+static inline int TestSetPageDirty(struct page *page)
+{
+	duet_hook_t *dhfp = NULL;
+
+	if (!test_and_set_bit(PG_dirty, &page->flags)) {
+		DUET_HOOK(dhfp, DUET_PAGE_DIRTY, page);
+		return 0;
+	}
+	return 1;
+}
+
+static inline int TestClearPageDirty(struct page *page)
+{
+	duet_hook_t *dhfp = NULL;
+
+	if (test_and_clear_bit(PG_dirty, &page->flags)) {
+		DUET_HOOK(dhfp, DUET_PAGE_FLUSHED, page);
+		return 1;
+	}
+	return 0;
+}
+#else
 PAGEFLAG(Dirty, dirty, PF_HEAD) TESTSCFLAG(Dirty, dirty, PF_HEAD)
 	__CLEARPAGEFLAG(Dirty, dirty, PF_HEAD)
+#endif /* CONFIG_DUET */
 PAGEFLAG(LRU, lru, PF_HEAD) __CLEARPAGEFLAG(LRU, lru, PF_HEAD)
 PAGEFLAG(Active, active, PF_HEAD) __CLEARPAGEFLAG(Active, active, PF_HEAD)
 	TESTCLEARFLAG(Active, active, PF_HEAD)
diff --git a/mm/filemap.c b/mm/filemap.c
index 20f3b1f..f06ebc0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -166,6 +166,11 @@ static void page_cache_tree_delete(struct address_space *mapping,
 void __delete_from_page_cache(struct page *page, void *shadow)
 {
 	struct address_space *mapping = page->mapping;
+#ifdef CONFIG_DUET
+	duet_hook_t *dhfp = NULL;
+
+	DUET_HOOK(dhfp, DUET_PAGE_REMOVED, page);
+#endif /* CONFIG_DUET */
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -628,6 +633,9 @@ static int __add_to_page_cache_locked(struct page *page,
 	int huge = PageHuge(page);
 	struct mem_cgroup *memcg;
 	int error;
+#ifdef CONFIG_DUET
+	duet_hook_t *dhfp = NULL;
+#endif
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapBacked(page), page);
@@ -663,6 +671,9 @@ static int __add_to_page_cache_locked(struct page *page,
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false, false);
 	trace_mm_filemap_add_to_page_cache(page);
+#ifdef CONFIG_DUET
+	DUET_HOOK(dhfp, DUET_PAGE_ADDED, page);
+#endif
 	return 0;
 err_insert:
 	page->mapping = NULL;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
