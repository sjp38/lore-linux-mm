Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 9CA706B0036
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 15:20:57 -0500 (EST)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH 05/11] frontswap: Get rid of swap_lock dependency
Date: Fri, 15 Feb 2013 15:20:29 -0500
Message-Id: <1360959635-18922-6-git-send-email-konrad.wilk@oracle.com>
In-Reply-To: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
References: <1360959635-18922-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dan.magenheimer@oracle.com, sjenning@linux.vnet.ibm.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, ngupta@vflare.org, rcj@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, minchan@kernel.org
Cc: ric.masonn@gmail.com, lliubbo@gmail.com, Konrad Rzeszutek Wilk <konrad@darnok.org>

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
---
 include/linux/frontswap.h |  6 +++---
 mm/frontswap.c            | 29 ++++++++++++++++++++++-------
 mm/swapfile.c             | 18 +++++++++---------
 3 files changed, 34 insertions(+), 19 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 8d24167..c120b90 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -20,7 +20,7 @@ extern void frontswap_writethrough(bool);
 #define FRONTSWAP_HAS_EXCLUSIVE_GETS
 extern void frontswap_tmem_exclusive_gets(bool);
 
-extern void __frontswap_init(unsigned type);
+extern void __frontswap_init(unsigned type, unsigned long *map);
 extern int __frontswap_store(struct page *page);
 extern int __frontswap_load(struct page *page);
 extern void __frontswap_invalidate_page(unsigned, pgoff_t);
@@ -122,9 +122,9 @@ static inline void frontswap_invalidate_area(unsigned type)
 	__frontswap_invalidate_area(type);
 }
 
-static inline void frontswap_init(unsigned type)
+static inline void frontswap_init(unsigned type, unsigned long *map)
 {
-	__frontswap_init(type);
+	__frontswap_init(type, map);
 }
 
 #endif /* _LINUX_FRONTSWAP_H */
diff --git a/mm/frontswap.c b/mm/frontswap.c
index ebf4c18..c84fc3b 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -127,8 +127,13 @@ struct frontswap_ops *frontswap_register_ops(struct frontswap_ops *ops)
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
@@ -166,16 +171,26 @@ EXPORT_SYMBOL(frontswap_tmem_exclusive_gets);
  *
  * Can be called without any backend driver is registered.
  */
-void __frontswap_init(unsigned type)
+void __frontswap_init(unsigned type, unsigned long *map)
 {
 	struct swap_info_struct *sis = swap_info[type];
 
-	if (static_key_false(&frontswap_key)) {
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
+	if (static_key_false(&frontswap_key))
 		frontswap_ops->init(type);
-	}
 	else {
 		BUG_ON(type > MAX_SWAPFILES);
 		set_bit(type, need_init);
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
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
