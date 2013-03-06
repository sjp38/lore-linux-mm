Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 124326B0036
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 03:52:14 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so5666046pbc.24
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 00:52:13 -0800 (PST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH V2 04/11] frontswap: Get rid of swap_lock dependency
Date: Wed,  6 Mar 2013 16:51:23 +0800
Message-Id: <1362559890-16710-4-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
References: <1362559890-16710-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: dan.magenheimer@oracle.com, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, rcj@linux.vnet.ibm.com, ngupta@vflare.org, minchan@kernel.org, ric.masonn@gmail.com, Konrad Rzeszutek Wilk <konrad@darnok.org>, Bob Liu <lliubbo@gmail.com>

From: Minchan Kim <minchan@kernel.org>

Frontswap initialization routine depends on swap_lock, which want
to be atomic about frontswap's first appearance.
IOW, frontswap is not present and will fail all calls OR frontswap is
fully functional but if new swap_info_struct isn't registered
by enable_swap_info, swap subsystem doesn't start I/O so there is no
race
between init procedure and page I/O working on frontswap.

So let's remove unnecessary swap_lock dependency.

Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
[v1: Rebased on my branch, reworked to work with backends loading late]
[v2: Added a check for !map]
[v3: Made the invalidate path follow the init path]
[v4: Address comments by Wanpeng Li <liwanp@linux.vnet.ibm.com>]
Signed-off-by: Konrad Rzeszutek Wilk <konrad@darnok.org>
Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 include/linux/frontswap.h |    6 +++---
 mm/frontswap.c            |   31 +++++++++++++++++++++++--------
 mm/swapfile.c             |   18 +++++++++---------
 3 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 6c49e1e..8293262 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -23,7 +23,7 @@ extern void frontswap_writethrough(bool);
 extern void frontswap_tmem_exclusive_gets(bool);
 
 extern bool __frontswap_test(struct swap_info_struct *, pgoff_t);
-extern void __frontswap_init(unsigned type);
+extern void __frontswap_init(unsigned type, unsigned long *map);
 extern int __frontswap_store(struct page *page);
 extern int __frontswap_load(struct page *page);
 extern void __frontswap_invalidate_page(unsigned, pgoff_t);
@@ -98,10 +98,10 @@ static inline void frontswap_invalidate_area(unsigned type)
 		__frontswap_invalidate_area(type);
 }
 
-static inline void frontswap_init(unsigned type)
+static inline void frontswap_init(unsigned type, unsigned long *map)
 {
 	if (frontswap_enabled)
-		__frontswap_init(type);
+		__frontswap_init(type, map);
 }
 
 #endif /* _LINUX_FRONTSWAP_H */
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 2760b0f..538367e 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -121,8 +121,13 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
 	int i;
 
 	for (i = 0; i < MAX_SWAPFILES; i++) {
-		if (test_and_clear_bit(i, need_init))
+		if (test_and_clear_bit(i, need_init)) {
+			struct swap_info_struct *sis = swap_info[i];
+			/* __frontswap_init _should_ have set it! */
+			if (!sis->frontswap_map)
+				return ERR_PTR(-EINVAL);
 			ops->init(i);
+		}
 	}
 	/*
 	 * We MUST have frontswap_ops set _after_ the frontswap_init's
@@ -156,20 +161,30 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
 /*
  * Called when a swap device is swapon'd.
  */
-void __frontswap_init(unsigned type)
+void __frontswap_init(unsigned type, unsigned long *map)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (frontswap_ops) {
-		BUG_ON(sis == NULL);
-		if (sis->frontswap_map == NULL)
-			return;
+	BUG_ON(sis == NULL);
+
+	/*
+	 * p->frontswap is a bitmap that we MUST have to figure out which page
+	 * has gone in frontswap. Without it there is no point of continuing.
+	 */
+	if (WARN_ON(!map))
+		return;
+	/*
+	 * Irregardless of whether the frontswap backend has been loaded
+	 * before this function or it will be later, we _MUST_ have the
+	 * p->frontswap set to something valid to work properly.
+	 */
+	frontswap_map_set(sis, map);
+	if (frontswap_ops)
 		frontswap_ops->init(type);
-	} else {
+	else {
 		BUG_ON(type > MAX_SWAPFILES);
 		set_bit(type, need_init);
 	}
-
 }
 EXPORT_SYMBOL(__frontswap_init);
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index e97a0e5..086c287 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1444,8 +1444,7 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 }
 
 static void _enable_swap_info(struct swap_info_struct *p, int prio,
-				unsigned char *swap_map,
-				unsigned long *frontswap_map)
+				unsigned char *swap_map)
 {
 	int i, prev;
 
@@ -1454,11 +1453,9 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	else
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
-	frontswap_map_set(p, frontswap_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
-
 	/* insert swap space into swap_list: */
 	prev = -1;
 	for (i = swap_list.head; i >= 0; i = swap_info[i]->next) {
@@ -1477,16 +1474,16 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				unsigned long *frontswap_map)
 {
+	frontswap_init(p->type, frontswap_map);
 	spin_lock(&swap_lock);
-	_enable_swap_info(p, prio, swap_map, frontswap_map);
-	frontswap_init(p->type);
+	_enable_swap_info(p, prio, swap_map);
 	spin_unlock(&swap_lock);
 }
 
 static void reinsert_swap_info(struct swap_info_struct *p)
 {
 	spin_lock(&swap_lock);
-	_enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
+	_enable_swap_info(p, p->prio, p->swap_map);
 	spin_unlock(&swap_lock);
 }
 
@@ -1494,6 +1491,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 {
 	struct swap_info_struct *p = NULL;
 	unsigned char *swap_map;
+	unsigned long *frontswap_map;
 	struct file *swap_file, *victim;
 	struct address_space *mapping;
 	struct inode *inode;
@@ -1588,11 +1586,13 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
 	p->flags = 0;
-	frontswap_invalidate_area(type);
+	frontswap_map = frontswap_map_get(p);
+	frontswap_map_set(p, NULL);
 	spin_unlock(&swap_lock);
+	frontswap_invalidate_area(type);
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
-	vfree(frontswap_map_get(p));
+	vfree(frontswap_map);
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
