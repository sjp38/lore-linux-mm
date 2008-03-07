Date: Fri, 7 Mar 2008 16:23:28 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
	methods to sleep (#v9 was 1/4)
Message-ID: <20080307152328.GE24114@v2.random>
References: <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com> <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com> <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com> <20080307151722.GD24114@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307151722.GD24114@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

This combines the non-sleep-capable RCU locking of #v9 with a seqlock
so the mmu notifier fast path will require zero cacheline
writes/bouncing while still providing mmu_notifier_unregister and
allowing to schedule inside the mmu notifier methods. If we drop
mmu_notifier_unregister we can as well drop all seqlock and
rcu_read_lock()s. But this locking scheme combination is sexy enough
and 100% scalable (the mmu_notifier_list cacheline will be preloaded
anyway and that will most certainly include the sequence number value
in l1 for free even in Christoph's NUMA systems) so IMHO it worth to
keep mmu_notifier_unregister.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -10,6 +10,7 @@
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
 #include <linux/completion.h>
+#include <linux/seqlock.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -230,6 +231,7 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_MMU_NOTIFIER
 	struct hlist_head mmu_notifier_list;
+	seqlock_t mmu_notifier_lock;
 #endif
 };
 
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -130,6 +130,7 @@ static inline void mmu_notifier_mm_init(
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 	INIT_HLIST_HEAD(&mm->mmu_notifier_list);
+	seqlock_init(&mm->mmu_notifier_lock);
 }
 
 
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -20,7 +20,9 @@ void __mmu_notifier_release(struct mm_st
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
+	unsigned seq;
 
+	seq = read_seqbegin(&mm->mmu_notifier_lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_list))) {
 		mn = hlist_entry(mm->mmu_notifier_list.first,
 				 struct mmu_notifier,
@@ -28,6 +30,7 @@ void __mmu_notifier_release(struct mm_st
 		hlist_del(&mn->hlist);
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
+		BUG_ON(read_seqretry(&mm->mmu_notifier_lock, seq));
 	}
 }
 
@@ -42,11 +45,19 @@ int __mmu_notifier_clear_flush_young(str
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 	int young = 0;
+	unsigned seq;
 
 	rcu_read_lock();
+restart:
+	seq = read_seqbegin(&mm->mmu_notifier_lock);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
-		if (mn->ops->clear_flush_young)
+		if (mn->ops->clear_flush_young) {
+			rcu_read_unlock();
 			young |= mn->ops->clear_flush_young(mn, mm, address);
+			rcu_read_lock();
+		}
+		if (read_seqretry(&mm->mmu_notifier_lock, seq))
+			goto restart;
 	}
 	rcu_read_unlock();
 
@@ -58,11 +69,19 @@ void __mmu_notifier_invalidate_page(stru
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	unsigned seq;
 
 	rcu_read_lock();
+restart:
+	seq = read_seqbegin(&mm->mmu_notifier_lock);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
-		if (mn->ops->invalidate_page)
+		if (mn->ops->invalidate_page) {
+			rcu_read_unlock();
 			mn->ops->invalidate_page(mn, mm, address);
+			rcu_read_lock();
+		}
+		if (read_seqretry(&mm->mmu_notifier_lock, seq))
+			goto restart;
 	}
 	rcu_read_unlock();
 }
@@ -72,11 +91,19 @@ void __mmu_notifier_invalidate_range_beg
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	unsigned seq;
 
 	rcu_read_lock();
+restart:
+	seq = read_seqbegin(&mm->mmu_notifier_lock);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
-		if (mn->ops->invalidate_range_begin)
+		if (mn->ops->invalidate_range_begin) {
+			rcu_read_unlock();
 			mn->ops->invalidate_range_begin(mn, mm, start, end);
+			rcu_read_lock();
+		}
+		if (read_seqretry(&mm->mmu_notifier_lock, seq))
+			goto restart;
 	}
 	rcu_read_unlock();
 }
@@ -86,11 +113,19 @@ void __mmu_notifier_invalidate_range_end
 {
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
+	unsigned seq;
 
 	rcu_read_lock();
+restart:
+	seq = read_seqbegin(&mm->mmu_notifier_lock);
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
-		if (mn->ops->invalidate_range_end)
+		if (mn->ops->invalidate_range_end) {
+			rcu_read_unlock();
 			mn->ops->invalidate_range_end(mn, mm, start, end);
+			rcu_read_lock();
+		}
+		if (read_seqretry(&mm->mmu_notifier_lock, seq))
+			goto restart;
 	}
 	rcu_read_unlock();
 }
@@ -103,12 +138,20 @@ void __mmu_notifier_invalidate_range_end
  */
 void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
+	/* no need of seqlock for hlist_add_head_rcu */
 	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_list);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
+	/*
+	 * The seqlock tracks if a hlist_del_rcu happens while a
+	 * notifier method is scheduling and in such a case the "mn"
+	 * memory may have been freed by the time the method returns.
+	 */
+	write_seqlock(&mm->mmu_notifier_lock);
 	hlist_del_rcu(&mn->hlist);
+	write_sequnlock(&mm->mmu_notifier_lock);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
