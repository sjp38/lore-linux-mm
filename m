Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D8D946B005D
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 02:29:44 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 3 Jul 2012 11:59:40 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q636Tb3c10027322
	for <linux-mm@kvack.org>; Tue, 3 Jul 2012 11:59:37 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q63BwtHp032429
	for <linux-mm@kvack.org>; Tue, 3 Jul 2012 21:58:55 +1000
Message-ID: <4FF29148.4030903@linux.vnet.ibm.com>
Date: Tue, 03 Jul 2012 14:29:28 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] mm: mmu_notifier: fix freed page still mapped in secondary
 MMU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, linux-mm@kvack.org

mmu_notifier_release is called when the process is exiting, it
will delete all the mmu notifiers, but, in this time, the page
belonged to the process is still present at the page table and
listed in the LRU list, so this race will happen:

      CPU 0                 CPU 1
mmu_notifier_release:    try_to_unmap:
   hlist_del_init_rcu(&mn->hlist);
                            ptep_clear_flush_notify:
                                  mmu nofifler not found
                            free page  !!!!!!
                            /*
                             * At the point, the page has been
                             * freed, but it is still mapped in
                             * the secondary MMU.
                             */

  mn->ops->release(mn, mm);

Then, the box is not stable and sometimes we can get this bug:
[  738.075923] BUG: Bad page state in process migrate-perf  pfn:03bec
[  738.075931] page:ffffea00000efb00 count:0 mapcount:0 mapping:          (null) index:0x8076
[  738.075936] page flags: 0x20000000000014(referenced|dirty)

The same issue is in the mmu_notifier_unregister

we can call ->release before deleting the notifier to ensure
the page has been unmapped from the secondary MMU before it is
freed

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 mm/mmu_notifier.c |   45 +++++++++++++++++++++++----------------------
 1 files changed, 23 insertions(+), 22 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 9a611d3..862b608 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -33,6 +33,24 @@
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
+	struct hlist_node *n;
+
+	/*
+	 * RCU here will block mmu_notifier_unregister until
+	 * ->release returns.
+	 */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist)
+		/*
+		 * if ->release runs before mmu_notifier_unregister it
+		 * must be handled as it's the only way for the driver
+		 * to flush all existing sptes and stop the driver
+		 * from establishing any more sptes before all the
+		 * pages in the mm are freed.
+		 */
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
+	rcu_read_unlock();

 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -46,23 +64,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 * mmu_notifier_unregister to return.
 		 */
 		hlist_del_init_rcu(&mn->hlist);
-		/*
-		 * RCU here will block mmu_notifier_unregister until
-		 * ->release returns.
-		 */
-		rcu_read_lock();
-		spin_unlock(&mm->mmu_notifier_mm->lock);
-		/*
-		 * if ->release runs before mmu_notifier_unregister it
-		 * must be handled as it's the only way for the driver
-		 * to flush all existing sptes and stop the driver
-		 * from establishing any more sptes before all the
-		 * pages in the mm are freed.
-		 */
-		if (mn->ops->release)
-			mn->ops->release(mn, mm);
-		rcu_read_unlock();
-		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);

@@ -284,16 +285,13 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);

-	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
-		hlist_del_rcu(&mn->hlist);
-
 		/*
 		 * RCU here will force exit_mmap to wait ->release to finish
 		 * before freeing the pages.
 		 */
 		rcu_read_lock();
-		spin_unlock(&mm->mmu_notifier_mm->lock);
+
 		/*
 		 * exit_mmap will block in mmu_notifier_release to
 		 * guarantee ->release is called before freeing the
@@ -302,8 +300,11 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
 		rcu_read_unlock();
-	} else
+
+		spin_lock(&mm->mmu_notifier_mm->lock);
+		hlist_del_rcu(&mn->hlist);
 		spin_unlock(&mm->mmu_notifier_mm->lock);
+	}

 	/*
 	 * Wait any running method to finish, of course including
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
