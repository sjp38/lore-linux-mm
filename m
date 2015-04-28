Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id BF4386B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 08:25:00 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so163249177pab.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 05:25:00 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id n5si34455053pdd.38.2015.04.28.05.24.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 05:24:59 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH v3 1/3] memcg: add page_cgroup_ino helper
Date: Tue, 28 Apr 2015 15:24:40 +0300
Message-ID: <691f393e37ee08049229ddb9fac341747609106a.1430217477.git.vdavydov@parallels.com>
In-Reply-To: <cover.1430217477.git.vdavydov@parallels.com>
References: <cover.1430217477.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hwpoison allows to filter pages by memory cgroup ino. To ahieve that, it
calls try_get_mem_cgroup_from_page(), then mem_cgroup_css(), and finally
cgroup_ino() on the cgroup returned. This looks bulky. Since in the next
patch I need to get the ino of the memory cgroup a page is charged to
too, in this patch I introduce the page_cgroup_ino() helper.

Note that page_cgroup_ino() only considers those pages that are charged
to mem_cgroup->memory (i.e. page->mem_cgroup != NULL), and for others it
returns 0, while try_get_mem_cgroup_page(), used by hwpoison before, may
extract the cgroup from a swapcache readahead page too. Ignoring
swapcache readahead pages allows to call page_cgroup_ino() on unlocked
pages, which is nice. Hwpoison users will hardly see any difference.

Another difference between try_get_mem_cgroup_page() and
page_cgroup_ino() is that the latter works on pages charged to offline
memory cgroups, returning the inode number of the closest online
ancestor in this case, while the former does not, which is crucial for
the next patch.

Since try_get_mem_cgroup_page() is not used by anyone else, this patch
removes this function. Also, it makes hwpoison memcg filter depend on
CONFIG_MEMCG instead of CONFIG_MEMCG_SWAP (I've no idea why it was made
dependant on CONFIG_MEMCG_SWAP initially).

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/memcontrol.h |    8 ++---
 mm/hwpoison-inject.c       |    5 +--
 mm/memcontrol.c            |   73 ++++++++++++++++++++++----------------------
 mm/memory-failure.c        |   16 ++--------
 4 files changed, 42 insertions(+), 60 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 72dff5fb0d0c..9262a8407af7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -91,7 +91,6 @@ bool mem_cgroup_is_descendant(struct mem_cgroup *memcg,
 			      struct mem_cgroup *root);
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 
-extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
@@ -192,6 +191,8 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 void mem_cgroup_split_huge_fixup(struct page *head);
 #endif
 
+unsigned long page_cgroup_ino(struct page *page);
+
 #else /* CONFIG_MEMCG */
 struct mem_cgroup;
 
@@ -252,11 +253,6 @@ static inline struct lruvec *mem_cgroup_page_lruvec(struct page *page,
 	return &zone->lruvec;
 }
 
-static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
-{
-	return NULL;
-}
-
 static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
index 329caf56df22..df63c3133d70 100644
--- a/mm/hwpoison-inject.c
+++ b/mm/hwpoison-inject.c
@@ -45,12 +45,9 @@ static int hwpoison_inject(void *data, u64 val)
 	/*
 	 * do a racy check with elevated page count, to make sure PG_hwpoison
 	 * will only be set for the targeted owner (or on a free page).
-	 * We temporarily take page lock for try_get_mem_cgroup_from_page().
 	 * memory_failure() will redo the check reliably inside page lock.
 	 */
-	lock_page(hpage);
 	err = hwpoison_filter(hpage);
-	unlock_page(hpage);
 	if (err)
 		return 0;
 
@@ -123,7 +120,7 @@ static int pfn_inject_init(void)
 	if (!dentry)
 		goto fail;
 
-#ifdef CONFIG_MEMCG_SWAP
+#ifdef CONFIG_MEMCG
 	dentry = debugfs_create_u64("corrupt-filter-memcg", 0600,
 				    hwpoison_dir, &hwpoison_filter_memcg);
 	if (!dentry)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 14c2f2017e37..87c7f852d45b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2349,40 +2349,6 @@ static void cancel_charge(struct mem_cgroup *memcg, unsigned int nr_pages)
 	css_put_many(&memcg->css, nr_pages);
 }
 
-/*
- * try_get_mem_cgroup_from_page - look up page's memcg association
- * @page: the page
- *
- * Look up, get a css reference, and return the memcg that owns @page.
- *
- * The page must be locked to prevent racing with swap-in and page
- * cache charges.  If coming from an unlocked page table, the caller
- * must ensure the page is on the LRU or this can race with charging.
- */
-struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
-{
-	struct mem_cgroup *memcg;
-	unsigned short id;
-	swp_entry_t ent;
-
-	VM_BUG_ON_PAGE(!PageLocked(page), page);
-
-	memcg = page->mem_cgroup;
-	if (memcg) {
-		if (!css_tryget_online(&memcg->css))
-			memcg = NULL;
-	} else if (PageSwapCache(page)) {
-		ent.val = page_private(page);
-		id = lookup_swap_cgroup_id(ent);
-		rcu_read_lock();
-		memcg = mem_cgroup_from_id(id);
-		if (memcg && !css_tryget_online(&memcg->css))
-			memcg = NULL;
-		rcu_read_unlock();
-	}
-	return memcg;
-}
-
 static void lock_page_lru(struct page *page, int *isolated)
 {
 	struct zone *zone = page_zone(page);
@@ -2774,6 +2740,31 @@ void mem_cgroup_split_huge_fixup(struct page *head)
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+/**
+ * page_cgroup_ino - return inode number of page's memcg
+ * @page: the page
+ *
+ * Look up the closest online ancestor of the memory cgroup @page is charged to
+ * and return its inode number. It is safe to call this function without taking
+ * a reference to the page.
+ */
+unsigned long page_cgroup_ino(struct page *page)
+{
+	struct mem_cgroup *memcg;
+	unsigned long ino = 0;
+
+	rcu_read_lock();
+	memcg = READ_ONCE(page->mem_cgroup);
+	while (memcg && !css_tryget_online(&memcg->css))
+		memcg = parent_mem_cgroup(memcg);
+	rcu_read_unlock();
+	if (memcg) {
+		ino = cgroup_ino(memcg->css.cgroup);
+		css_put(&memcg->css);
+	}
+	return ino;
+}
+
 #ifdef CONFIG_MEMCG_SWAP
 static void mem_cgroup_swap_statistics(struct mem_cgroup *memcg,
 					 bool charge)
@@ -5482,8 +5473,18 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 	}
 
-	if (do_swap_account && PageSwapCache(page))
-		memcg = try_get_mem_cgroup_from_page(page);
+	if (do_swap_account && PageSwapCache(page)) {
+		swp_entry_t ent = { .val = page_private(page), };
+		unsigned short id = lookup_swap_cgroup_id(ent);
+
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+
+		rcu_read_lock();
+		memcg = mem_cgroup_from_id(id);
+		if (memcg && !css_tryget_online(&memcg->css))
+			memcg = NULL;
+		rcu_read_unlock();
+	}
 	if (!memcg)
 		memcg = get_mem_cgroup_from_mm(mm);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9359b770cd9..64cd565fd4f8 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -128,27 +128,15 @@ static int hwpoison_filter_flags(struct page *p)
  * can only guarantee that the page either belongs to the memcg tasks, or is
  * a freed page.
  */
-#ifdef	CONFIG_MEMCG_SWAP
+#ifdef CONFIG_MEMCG
 u64 hwpoison_filter_memcg;
 EXPORT_SYMBOL_GPL(hwpoison_filter_memcg);
 static int hwpoison_filter_task(struct page *p)
 {
-	struct mem_cgroup *mem;
-	struct cgroup_subsys_state *css;
-	unsigned long ino;
-
 	if (!hwpoison_filter_memcg)
 		return 0;
 
-	mem = try_get_mem_cgroup_from_page(p);
-	if (!mem)
-		return -EINVAL;
-
-	css = mem_cgroup_css(mem);
-	ino = cgroup_ino(css->cgroup);
-	css_put(css);
-
-	if (ino != hwpoison_filter_memcg)
+	if (page_cgroup_ino(p) != hwpoison_filter_memcg)
 		return -EINVAL;
 
 	return 0;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
