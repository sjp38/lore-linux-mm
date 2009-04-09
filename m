Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 11C225F0002
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 23:58:50 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 1/4] MMU_NOTIFIERS: add set_pte_at_notify()
Date: Thu,  9 Apr 2009 06:58:38 +0300
Message-Id: <1239249521-5013-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
References: <1239249521-5013-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, aarcange@redhat.com, chrisw@redhat.com, mtosatti@redhat.com, hugh@veritas.com, kamezawa.hiroyu@jp.fujitsu.com, Izik Eidus <ieidus@redhat.com>
List-ID: <linux-mm.kvack.org>

this macro allow setting the pte in the shadow page tables directly
instead of flushing the shadow page table entry and then get vmexit in
order to set it.

This function is optimzation for kvm/users of mmu_notifiers for COW
pages, it is useful for kvm when ksm is used beacuse it allow kvm
not to have to recive VMEXIT and only then map the shared page into
the mmu shadow pages, but instead map it directly at the same time
linux map the page into the host page table.

this mmu notifer macro is working by calling to callback that will map
directly the physical page into the shadow page tables.

(users of mmu_notifiers that didnt implement the set_pte_at_notify()
call back will just recive the mmu_notifier_invalidate_page callback)

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/mmu_notifier.h |   34 ++++++++++++++++++++++++++++++++++
 mm/memory.c                  |   10 ++++++++--
 mm/mmu_notifier.c            |   20 ++++++++++++++++++++
 3 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b77486d..8bb245f 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -61,6 +61,15 @@ struct mmu_notifier_ops {
 				 struct mm_struct *mm,
 				 unsigned long address);
 
+	/* 
+	* change_pte is called in cases that pte mapping into page is changed
+	* for example when ksm mapped pte to point into a new shared page.
+	*/
+	void (*change_pte)(struct mmu_notifier *mn,
+			   struct mm_struct *mm,
+			   unsigned long address,
+			   pte_t pte);
+
 	/*
 	 * Before this is invoked any secondary MMU is still ok to
 	 * read/write to the page previously pointed to by the Linux
@@ -154,6 +163,8 @@ extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
+extern void __mmu_notifier_change_pte(struct mm_struct *mm, 
+				      unsigned long address, pte_t pte);
 extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
@@ -175,6 +186,13 @@ static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_change_pte(mm, address, pte);
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -236,6 +254,16 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	__young;							\
 })
 
+#define set_pte_at_notify(__mm, __address, __ptep, __pte)		\
+({									\
+	struct mm_struct *___mm = __mm;					\
+	unsigned long ___address = __address;				\
+	pte_t ___pte = __pte;						\
+									\
+	set_pte_at(__mm, __address, __ptep, ___pte);			\
+	mmu_notifier_change_pte(___mm, ___address, ___pte);		\
+})
+
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -248,6 +276,11 @@ static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return 0;
 }
 
+static inline void mmu_notifier_change_pte(struct mm_struct *mm,
+					   unsigned long address, pte_t pte)
+{
+}
+
 static inline void mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
@@ -273,6 +306,7 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define ptep_clear_flush_notify ptep_clear_flush
+#define set_pte_at_notify set_pte_at
 
 #endif /* CONFIG_MMU_NOTIFIER */
 
diff --git a/mm/memory.c b/mm/memory.c
index cf6873e..1e1a14b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2051,9 +2051,15 @@ gotten:
 		 * seen in the presence of one thread doing SMC and another
 		 * thread doing COW.
 		 */
-		ptep_clear_flush_notify(vma, address, page_table);
+		ptep_clear_flush(vma, address, page_table);
 		page_add_new_anon_rmap(new_page, vma, address);
-		set_pte_at(mm, address, page_table, entry);
+		/*
+		 * We call here the notify macro beacuse in cases of using
+		 * secondary mmu page table like kvm shadow page, tables we want
+		 * the new page to be mapped directly into the secondary page
+		 * table
+		 */
+		set_pte_at_notify(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		if (old_page) {
 			/*
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5f4ef02..c3e8779 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -99,6 +99,26 @@ int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 	return young;
 }
 
+void __mmu_notifier_change_pte(struct mm_struct *mm, unsigned long address,
+			       pte_t pte)
+{
+	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn->ops->change_pte)
+			mn->ops->change_pte(mn, mm, address, pte);
+		/* 
+		 * some drivers dont have change_pte and therefor we must call
+		 * for invalidate_page in that case
+		 */
+		else if (mn->ops->invalidate_page)
+			mn->ops->invalidate_page(mn, mm, address);
+	}
+	rcu_read_unlock();
+}
+
 void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  unsigned long address)
 {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
