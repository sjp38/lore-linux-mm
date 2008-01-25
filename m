Date: Fri, 25 Jan 2008 13:18:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/4] mmu_notifier: Core code
In-Reply-To: <20080125193554.GP26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801251315350.19523@schroedinger.engr.sgi.com>
References: <20080125055606.102986685@sgi.com> <20080125055801.212744875@sgi.com>
 <20080125183934.GO26420@sgi.com> <Pine.LNX.4.64.0801251041040.672@schroedinger.engr.sgi.com>
 <20080125185646.GQ3058@sgi.com> <Pine.LNX.4.64.0801251058170.3198@schroedinger.engr.sgi.com>
 <20080125193554.GP26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Diff so far against V1

- Improve RCU support. (There is now a sychronize_rcu in mmu_release which 
is bad.)

- Clean compile for !MMU_NOTIFIER

- Use mmap_sem for serializing additions the mmu_notifier list in the 
mm_struct (but still global spinlock for mmu_rmap_notifier. The 
registration function is called only a couple of times))

- 

---
 include/linux/list.h         |   14 ++++++++++++++
 include/linux/mm_types.h     |    2 --
 include/linux/mmu_notifier.h |   39 ++++++++++++++++++++++++++++++++++++---
 mm/mmu_notifier.c            |   28 +++++++++++++++++++---------
 4 files changed, 69 insertions(+), 14 deletions(-)

Index: linux-2.6/mm/mmu_notifier.c
===================================================================
--- linux-2.6.orig/mm/mmu_notifier.c	2008-01-25 12:14:49.000000000 -0800
+++ linux-2.6/mm/mmu_notifier.c	2008-01-25 12:14:49.000000000 -0800
@@ -15,17 +15,18 @@
 void mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
-	struct hlist_node *n;
+	struct hlist_node *n, *t;
 
 	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
 		rcu_read_lock();
-		hlist_for_each_entry_rcu(mn, n,
+		hlist_for_each_entry_safe_rcu(mn, n, t,
 					  &mm->mmu_notifier.head, hlist) {
 			if (mn->ops->release)
 				mn->ops->release(mn, mm);
 			hlist_del(&mn->hlist);
 		}
 		rcu_read_unlock();
+		synchronize_rcu();
 	}
 }
 
@@ -53,24 +54,33 @@ int mmu_notifier_age_page(struct mm_stru
 	return young;
 }
 
-static DEFINE_SPINLOCK(mmu_notifier_list_lock);
+/*
+ * Note that all notifiers use RCU. The updates are only guaranteed to be
+ * visible to other processes after a RCU quiescent period!
+ */
+void __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
+{
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_register);
 
 void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	spin_lock(&mmu_notifier_list_lock);
-	hlist_add_head(&mn->hlist, &mm->mmu_notifier.head);
-	spin_unlock(&mmu_notifier_list_lock);
+	down_write(&mm->mmap_sem);
+	__mmu_notifier_register(mn, mm);
+	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	spin_lock(&mmu_notifier_list_lock);
-	hlist_del(&mn->hlist);
-	spin_unlock(&mmu_notifier_list_lock);
+	down_write(&mm->mmap_sem);
+	hlist_del_rcu(&mn->hlist);
+	up_write(&mm->mmap_sem);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
+static DEFINE_SPINLOCK(mmu_notifier_list_lock);
 HLIST_HEAD(mmu_rmap_notifier_list);
 
 void mmu_rmap_notifier_register(struct mmu_rmap_notifier *mrn)
Index: linux-2.6/include/linux/list.h
===================================================================
--- linux-2.6.orig/include/linux/list.h	2008-01-25 12:14:47.000000000 -0800
+++ linux-2.6/include/linux/list.h	2008-01-25 12:14:49.000000000 -0800
@@ -991,6 +991,20 @@ static inline void hlist_add_after_rcu(s
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
 	     pos = pos->next)
 
+/**
+ * hlist_for_each_entry_safe_rcu	- iterate over list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @n:		temporary pointer
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_safe_rcu(tpos, pos, n, head, member)	 \
+	for (pos = (head)->first;					 \
+	     rcu_dereference(pos) && ({ n = pos->next; 1;}) &&		 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = n)
+
 #else
 #warning "don't include kernel headers in userspace"
 #endif /* __KERNEL__ */
Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h	2008-01-25 12:14:49.000000000 -0800
+++ linux-2.6/include/linux/mm_types.h	2008-01-25 12:14:49.000000000 -0800
@@ -224,9 +224,7 @@ struct mm_struct {
 	rwlock_t		ioctx_list_lock;
 	struct kioctx		*ioctx_list;
 
-#ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_head mmu_notifier; /* MMU notifier list */
-#endif
 };
 
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/include/linux/mmu_notifier.h
===================================================================
--- linux-2.6.orig/include/linux/mmu_notifier.h	2008-01-25 12:14:49.000000000 -0800
+++ linux-2.6/include/linux/mmu_notifier.h	2008-01-25 13:07:54.000000000 -0800
@@ -46,6 +46,10 @@ struct mmu_notifier {
 };
 
 struct mmu_notifier_ops {
+	/*
+	 * Note the mmu_notifier structure must be released with
+	 * call_rcu
+	 */
 	void (*release)(struct mmu_notifier *mn,
 			struct mm_struct *mm);
 	int (*age_page)(struct mmu_notifier *mn,
@@ -78,10 +82,16 @@ struct mmu_rmap_notifier_ops {
 
 #ifdef CONFIG_MMU_NOTIFIER
 
+/* Must hold the mmap_sem */
+extern void __mmu_notifier_register(struct mmu_notifier *mn,
+				  struct mm_struct *mm);
+/* Will acquire mmap_sem */
 extern void mmu_notifier_register(struct mmu_notifier *mn,
 				  struct mm_struct *mm);
+/* Will acquire mmap_sem */
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
+
 extern void mmu_notifier_release(struct mm_struct *mm);
 extern int mmu_notifier_age_page(struct mm_struct *mm,
 				 unsigned long address);
@@ -130,15 +140,38 @@ extern struct hlist_head mmu_rmap_notifi
 
 #else /* CONFIG_MMU_NOTIFIER */
 
-#define mmu_notifier(function, mm, args...) do { } while (0)
-#define mmu_rmap_notifier(function, args...) do { } while (0)
+/*
+ * Notifiers that use the parameters that they were passed so that the
+ * compiler does not complain about unused variables but does proper
+ * parameter checks even if !CONFIG_MMU_NOTIFIER.
+ * Macros generate no code.
+ */
+#define mmu_notifier(function, mm, args...)				\
+	do {								\
+		if (0) {						\
+			struct mmu_notifier *__mn;			\
+									\
+			__mn = (struct mmu_notifier *)(0x00ff);		\
+			__mn->ops->function(__mn, mm, args);		\
+		};							\
+	} while (0)
+
+#define mmu_rmap_notifier(function, args...)				\
+	do {								\
+		if (0) {						\
+			struct mmu_rmap_notifier *__mrn;		\
+									\
+			__mrn = (struct mmu_rmap_notifier *)(0x00ff);	\
+			__mrn->ops->function(__mrn, args);		\
+		}							\
+	} while (0);
 
 static inline void mmu_notifier_register(struct mmu_notifier *mn,
 						struct mm_struct *mm) {}
 static inline void mmu_notifier_unregister(struct mmu_notifier *mn,
 						struct mm_struct *mm) {}
 static inline void mmu_notifier_release(struct mm_struct *mm) {}
-static inline void mmu_notifier_age(struct mm_struct *mm,
+static inline int mmu_notifier_age_page(struct mm_struct *mm,
 				unsigned long address)
 {
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
