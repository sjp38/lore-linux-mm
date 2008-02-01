Date: Thu, 31 Jan 2008 20:31:13 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 1/3] mmu_notifier: Core code
Message-ID: <20080201023113.GB26420@sgi.com>
References: <20080131045750.855008281@sgi.com> <20080131045812.553249048@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080131045812.553249048@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

Christoph,

Jack has repeatedly pointed out needing an unregister outside the
mmap_sem.  I still don't see the benefit to not having the lock in the mm.

Thanks,
Robin

Index: mmu_notifiers-cl-v4/include/linux/mm_types.h
===================================================================
--- mmu_notifiers-cl-v4.orig/include/linux/mm_types.h	2008-01-31 19:56:08.000000000 -0600
+++ mmu_notifiers-cl-v4/include/linux/mm_types.h	2008-01-31 19:56:58.000000000 -0600
@@ -155,6 +155,7 @@ struct vm_area_struct {
 
 struct mmu_notifier_head {
 #ifdef CONFIG_MMU_NOTIFIER
+	spinlock_t	list_lock;
 	struct hlist_head head;
 #endif
 };
Index: mmu_notifiers-cl-v4/mm/mmu_notifier.c
===================================================================
--- mmu_notifiers-cl-v4.orig/mm/mmu_notifier.c	2008-01-31 19:56:08.000000000 -0600
+++ mmu_notifiers-cl-v4/mm/mmu_notifier.c	2008-01-31 20:26:31.000000000 -0600
@@ -60,25 +60,19 @@ int mmu_notifier_age_page(struct mm_stru
  * Note that all notifiers use RCU. The updates are only guaranteed to be
  * visible to other processes after a RCU quiescent period!
  */
-void __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
-{
-	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
-}
-EXPORT_SYMBOL_GPL(__mmu_notifier_register);
-
 void mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	down_write(&mm->mmap_sem);
-	__mmu_notifier_register(mn, mm);
-	up_write(&mm->mmap_sem);
+	spin_lock(&mm->mmu_notifier.list_lock);
+	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier.head);
+	spin_unlock(&mm->mmu_notifier.list_lock);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
 
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
-	down_write(&mm->mmap_sem);
+	spin_lock(&mm->mmu_notifier.list_lock);
 	hlist_del_rcu(&mn->hlist);
-	up_write(&mm->mmap_sem);
+	spin_unlock(&mm->mmu_notifier.list_lock);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
