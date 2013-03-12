Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id C36166B003D
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 03:38:59 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC v7 08/11] add LRU handling for victim vrange
Date: Tue, 12 Mar 2013 16:38:32 +0900
Message-Id: <1363073915-25000-9-git-send-email-minchan@kernel.org>
In-Reply-To: <1363073915-25000-1-git-send-email-minchan@kernel.org>
References: <1363073915-25000-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Arun Sharma <asharma@fb.com>, John Stultz <john.stultz@linaro.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jason Evans <je@fb.com>, sanjay@google.com, Paul Turner <pjt@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>

This patch adds LRU data structure for selecting victim vrange
when memory pressure happens.

Basically, VM will select old vrange but if user try to access
purged page recenlty, the vrange includes the page will be activated
because page fault means one of them which user process will be
killed or recover SIGBUS and continue the work. For latter case,
we have to keep the vrange out of vicim selection.

I admit LRU might be not best but I can't imagine better idea
so wanted to make it simple. I think user space can handle better
with enough information so hope they handle it via mempressure
notifier. Otherwise, if you have better idea, welcome!

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/vrange.h |  4 ++++
 mm/memory.c            |  1 +
 mm/vrange.c            | 48 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 52 insertions(+), 1 deletion(-)

diff --git a/include/linux/vrange.h b/include/linux/vrange.h
index 5238a67..26db168 100644
--- a/include/linux/vrange.h
+++ b/include/linux/vrange.h
@@ -12,6 +12,7 @@ struct vrange {
 	struct interval_tree_node node;
 	bool purged;
 	struct mm_struct *mm;
+	struct list_head lru; /* protected by lru_lock */
 };
 
 #define vrange_entry(ptr) \
@@ -44,6 +45,9 @@ bool vrange_address(struct mm_struct *mm, unsigned long start,
 
 extern bool is_purged_vrange(struct mm_struct *mm, unsigned long address);
 
+unsigned int discard_vrange_pages(struct zone *zone, int nr_to_discard);
+void lru_move_vrange_to_head(struct mm_struct *mm, unsigned long address);
+
 #else
 
 static inline void vrange_init(void) {};
diff --git a/mm/memory.c b/mm/memory.c
index cc369ab..3cb0633 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3671,6 +3671,7 @@ anon:
 
 		if (unlikely(pte_vrange(entry))) {
 			if (!is_purged_vrange(mm, address)) {
+				lru_move_vrange_to_head(mm, address);
 				/* zap pte */
 				ptl = pte_lockptr(mm, pmd);
 				spin_lock(ptl);
diff --git a/mm/vrange.c b/mm/vrange.c
index f4c1d04..b9b1ffa 100644
--- a/mm/vrange.c
+++ b/mm/vrange.c
@@ -14,6 +14,9 @@
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
 
+static LIST_HEAD(lru_vrange);
+static DEFINE_SPINLOCK(lru_lock);
+
 static struct kmem_cache *vrange_cachep;
 
 void __init vrange_init(void)
@@ -28,10 +31,50 @@ static inline void __set_vrange(struct vrange *range,
 	range->node.last = end_idx;
 }
 
+void lru_add_vrange(struct vrange *vrange)
+{
+	spin_lock(&lru_lock);
+	WARN_ON(!list_empty(&vrange->lru));
+	list_add(&vrange->lru, &lru_vrange);
+	spin_unlock(&lru_lock);
+}
+
+void lru_remove_vrange(struct vrange *vrange)
+{
+	spin_lock(&lru_lock);
+	if (!list_empty(&vrange->lru))
+		list_del_init(&vrange->lru);
+	spin_unlock(&lru_lock);
+}
+
+void lru_move_vrange_to_head(struct mm_struct *mm, unsigned long address)
+{
+	struct rb_root *root = &mm->v_rb;
+	struct interval_tree_node *node;
+	struct vrange *vrange;
+
+	vrange_lock(mm);
+	node = interval_tree_iter_first(root, address, address + PAGE_SIZE - 1);
+	if (node) {
+		vrange = container_of(node, struct vrange, node);
+		spin_lock(&lru_lock);
+		/*
+		 * Race happens with get_victim_vrange so in such case,
+		 * we can't move but it can put the vrange into head
+		 * after finishing purging work so no problem.
+		 */
+		if (!list_empty(&vrange->lru))
+			list_move(&vrange->lru, &lru_vrange);
+		spin_unlock(&lru_lock);
+	}
+	vrange_unlock(mm);
+}
+
 static void __add_range(struct vrange *range,
 			struct rb_root *root, struct mm_struct *mm)
 {
 	range->mm = mm;
+	lru_add_vrange(range);
 	interval_tree_insert(&range->node, root);
 }
 
@@ -43,11 +86,14 @@ static void __remove_range(struct vrange *range,
 
 static struct vrange *alloc_vrange(void)
 {
-	return kmem_cache_alloc(vrange_cachep, GFP_KERNEL);
+	struct vrange *vrange = kmem_cache_alloc(vrange_cachep, GFP_KERNEL);
+	INIT_LIST_HEAD(&vrange->lru);
+	return vrange;
 }
 
 static void free_vrange(struct vrange *range)
 {
+	lru_remove_vrange(range);
 	kmem_cache_free(vrange_cachep, range);
 }
 
-- 
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
