Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DC4526B0092
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 18:44:03 -0400 (EDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [RFC/PATCH 3/3] frontswap/swap: allow frontswap "unuse" and add metadata for tracking it
Date: Wed,  3 Oct 2012 15:43:54 -0700
Message-Id: <1349304234-19273-4-git-send-email-dan.magenheimer@oracle.com>
In-Reply-To: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
References: <1349304234-19273-1-git-send-email-dan.magenheimer@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, minchan@kernel.org, hughd@google.com, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, dan.magenheimer@oracle.com, aarcange@redhat.com, mgorman@suse.de, gregkh@linuxfoundation.org

We wish for transcendent memory backends to be able to push
frontswap pages back into the swap cache and need to ensure
that such a page, once pushed back, doesn't get immediately
recaptured by frontswap.  We add frontswap_unuse to do the
pushing via the recently added read_frontswap_async.  We
also add metadata to track when a page has been pushed and
code to manage (and count with debugfs) this metadata.

The initialization/destruction code for the metadata (aka
frontswap_denial_map) is a bit clunky in swapfile.c but
cleanup can be addressed when all the unuse code is working.

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
---
 include/linux/frontswap.h |   57 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/swap.h      |    1 +
 mm/frontswap.c            |   29 +++++++++++++++++++++++
 mm/swapfile.c             |   18 ++++++++++----
 4 files changed, 100 insertions(+), 5 deletions(-)

diff --git a/include/linux/frontswap.h b/include/linux/frontswap.h
index 3044254..f48bb34 100644
--- a/include/linux/frontswap.h
+++ b/include/linux/frontswap.h
@@ -21,6 +21,8 @@ extern unsigned long frontswap_curr_pages(void);
 extern void frontswap_writethrough(bool);
 #define FRONTSWAP_HAS_EXCLUSIVE_GETS
 extern void frontswap_tmem_exclusive_gets(bool);
+#define FRONTSWAP_HAS_UNUSE
+extern int frontswap_unuse(int, pgoff_t, struct page *, gfp_t);
 
 extern void __frontswap_init(unsigned type);
 extern int __frontswap_store(struct page *page);
@@ -61,6 +63,38 @@ static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
 {
 	return p->frontswap_map;
 }
+
+static inline int frontswap_test_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+	int ret = 0;
+
+	if (frontswap_enabled && sis->frontswap_denial_map)
+		ret = test_bit(offset, sis->frontswap_denial_map);
+	return ret;
+}
+
+static inline void frontswap_set_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_denial_map)
+		set_bit(offset, sis->frontswap_denial_map);
+}
+
+static inline void frontswap_clear_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+	if (frontswap_enabled && sis->frontswap_denial_map)
+		clear_bit(offset, sis->frontswap_denial_map);
+}
+
+static inline void frontswap_denial_map_set(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+	p->frontswap_denial_map = map;
+}
+
+static inline unsigned long *frontswap_denial_map_get(struct swap_info_struct *p)
+{
+	return p->frontswap_denial_map;
+}
 #else
 /* all inline routines become no-ops and all externs are ignored */
 
@@ -88,6 +122,29 @@ static inline unsigned long *frontswap_map_get(struct swap_info_struct *p)
 {
 	return NULL;
 }
+
+static inline int frontswap_test_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+	return 0;
+}
+
+static inline void frontswap_set_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_clear_denial(struct swap_info_struct *sis, pgoff_t offset)
+{
+}
+
+static inline void frontswap_map_set_denial(struct swap_info_struct *p,
+				     unsigned long *map)
+{
+}
+
+static inline unsigned long *frontswap_map_get_denial(struct swap_info_struct *p)
+{
+	return NULL;
+}
 #endif
 
 static inline int frontswap_store(struct page *page)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8a59ddb..aef02bc 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -200,6 +200,7 @@ struct swap_info_struct {
 	unsigned int old_block_size;	/* seldom referenced */
 #ifdef CONFIG_FRONTSWAP
 	unsigned long *frontswap_map;	/* frontswap in-use, one bit per page */
+	unsigned long *frontswap_denial_map;	/* deny frontswap, 1bit/page */
 	atomic_t frontswap_pages;	/* frontswap pages in-use counter */
 #endif
 };
diff --git a/mm/frontswap.c b/mm/frontswap.c
index 2890e67..1af07d1 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -61,6 +61,8 @@ static u64 frontswap_loads;
 static u64 frontswap_succ_stores;
 static u64 frontswap_failed_stores;
 static u64 frontswap_invalidates;
+static u64 frontswap_unuses;
+static u64 frontswap_denials;
 
 static inline void inc_frontswap_loads(void) {
 	frontswap_loads++;
@@ -151,6 +153,11 @@ int __frontswap_store(struct page *page)
 	BUG_ON(sis == NULL);
 	if (frontswap_test(sis, offset))
 		dup = 1;
+	if (frontswap_test_denial(sis, offset) && (dup == 0)) {
+		frontswap_clear_denial(sis, offset);
+		frontswap_denials++;
+		goto out;
+	}
 	ret = frontswap_ops.store(type, offset, page);
 	if (ret == 0) {
 		frontswap_set(sis, offset);
@@ -169,6 +176,7 @@ int __frontswap_store(struct page *page)
 	if (frontswap_writethrough_enabled)
 		/* report failure so swap also writes to swap device */
 		ret = -1;
+out:
 	return ret;
 }
 EXPORT_SYMBOL(__frontswap_store);
@@ -213,6 +221,7 @@ void __frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	if (frontswap_test(sis, offset)) {
 		frontswap_ops.invalidate_page(type, offset);
 		__frontswap_clear(sis, offset);
+		frontswap_clear_denial(sis, offset);
 		inc_frontswap_invalidates();
 	}
 }
@@ -351,6 +360,24 @@ unsigned long frontswap_curr_pages(void)
 }
 EXPORT_SYMBOL(frontswap_curr_pages);
 
+int frontswap_unuse(int type, pgoff_t offset,
+			struct page *newpage, gfp_t gfp_mask)
+{
+	struct swap_info_struct *sis = swap_info[type];
+	int ret = 0;
+
+	frontswap_set_denial(sis, offset);
+	ret = read_frontswap_async(type, offset, newpage, gfp_mask);
+	if (ret == 0 || ret == -EEXIST) {
+		(*frontswap_ops.invalidate_page)(type, offset);
+		atomic_dec(&sis->frontswap_pages);
+		frontswap_clear(sis, offset);
+		frontswap_unuses++;
+	}
+	return ret;
+}
+EXPORT_SYMBOL(frontswap_unuse);
+
 static int __init init_frontswap(void)
 {
 #ifdef CONFIG_DEBUG_FS
@@ -363,6 +390,8 @@ static int __init init_frontswap(void)
 				&frontswap_failed_stores);
 	debugfs_create_u64("invalidates", S_IRUGO,
 				root, &frontswap_invalidates);
+	debugfs_create_u64("unuses", S_IRUGO, root, &frontswap_unuses);
+	debugfs_create_u64("denials", S_IRUGO, root, &frontswap_denials);
 #endif
 	return 0;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 14e254c..b3d6266 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1445,7 +1445,8 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
-				unsigned long *frontswap_map)
+				unsigned long *frontswap_map,
+				unsigned long *frontswap_denial_map)
 {
 	int i, prev;
 
@@ -1456,6 +1457,7 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
 		p->prio = --least_priority;
 	p->swap_map = swap_map;
 	frontswap_map_set(p, frontswap_map);
+	frontswap_denial_map_set(p, frontswap_denial_map);
 	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += p->pages;
 	total_swap_pages += p->pages;
@@ -1557,7 +1559,8 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		 * sys_swapoff for this swap_info_struct at this point.
 		 */
 		/* re-insert swap space back into swap_list */
-		enable_swap_info(p, p->prio, p->swap_map, frontswap_map_get(p));
+		enable_swap_info(p, p->prio, p->swap_map,
+			frontswap_map_get(p), frontswap_denial_map_get(p));
 		goto out_dput;
 	}
 
@@ -1588,6 +1591,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	mutex_unlock(&swapon_mutex);
 	vfree(swap_map);
 	vfree(frontswap_map_get(p));
+	vfree(frontswap_denial_map_get(p));
 	/* Destroy swap account informatin */
 	swap_cgroup_swapoff(type);
 
@@ -1948,6 +1952,7 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	unsigned long maxpages;
 	unsigned char *swap_map = NULL;
 	unsigned long *frontswap_map = NULL;
+	unsigned long *frontswap_denial_map = NULL;
 	struct page *page = NULL;
 	struct inode *inode = NULL;
 
@@ -2032,8 +2037,10 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 		goto bad_swap;
 	}
 	/* frontswap enabled? set up bit-per-page map for frontswap */
-	if (frontswap_enabled)
-		frontswap_map = vzalloc(maxpages / sizeof(long));
+	if (frontswap_enabled) {
+ 		frontswap_map = vzalloc(maxpages / sizeof(long));
+		frontswap_denial_map = vzalloc(maxpages / sizeof(long));
+	}
 
 	if (p->bdev) {
 		if (blk_queue_nonrot(bdev_get_queue(p->bdev))) {
@@ -2049,7 +2056,8 @@ SYSCALL_DEFINE2(swapon, const char __user *, specialfile, int, swap_flags)
 	if (swap_flags & SWAP_FLAG_PREFER)
 		prio =
 		  (swap_flags & SWAP_FLAG_PRIO_MASK) >> SWAP_FLAG_PRIO_SHIFT;
-	enable_swap_info(p, prio, swap_map, frontswap_map);
+	enable_swap_info(p, prio, swap_map,
+				frontswap_map, frontswap_denial_map);
 
 	printk(KERN_INFO "Adding %uk swap on %s.  "
 			"Priority:%d extents:%d across:%lluk %s%s%s\n",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
