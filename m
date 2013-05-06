Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 24BF86B0119
	for <linux-mm@kvack.org>; Mon,  6 May 2013 04:09:50 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 6 May 2013 17:59:18 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 70570368476
	for <linux-mm@kvack.org>; Mon,  6 May 2013 15:50:24 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r465oHuv13369376
	for <linux-mm@kvack.org>; Mon, 6 May 2013 15:50:17 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r465oNu4014615
	for <linux-mm@kvack.org>; Mon, 6 May 2013 15:50:23 +1000
Message-ID: <5187449A.1000202@linux.vnet.ibm.com>
Date: Mon, 06 May 2013 13:50:18 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH RESEND] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Robin Holt <holt@sgi.com>, stable@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

The commit 751efd8610d3 (mmu_notifier_unregister NULL Pointer deref
and multiple ->release()) breaks the fix:
    3ad3d901bbcfb15a5e4690e55350db0899095a68
    (mm: mmu_notifier: fix freed page still mapped in secondary MMU)

Since hlist_for_each_entry_rcu() is changed now, we can not revert that patch
directly, so this patch reverts the commit and simply fix the bug spotted
by that patch

This bug spotted by commit 751efd8610d3 is:
======
There is a race condition between mmu_notifier_unregister() and
__mmu_notifier_release().

Assume two tasks, one calling mmu_notifier_unregister() as a result of a
filp_close() ->flush() callout (task A), and the other calling
mmu_notifier_release() from an mmput() (task B).

                    A                               B
t1                                              srcu_read_lock()
t2              if (!hlist_unhashed())
t3                                              srcu_read_unlock()
t4              srcu_read_lock()
t5                                              hlist_del_init_rcu()
t6                                              synchronize_srcu()
t7              srcu_read_unlock()
t8              hlist_del_rcu()  <--- NULL pointer deref.
======

This can be fixed by using hlist_del_init_rcu instead of hlist_del_rcu.

The another issue spotted in the commit is
"multiple ->release() callouts", we needn't care it too much because
it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
after exit_mmap()) and the later call of multiple ->release should be
fast since all the pages have already been released by the first call.
Anyway, this issue should be fixed in a separate patch.

-stable suggestions:
Any version has commit 751efd8610d3 need to be backported. I find the oldest
version has this commit is 3.0-stable.

Tested-by: Robin Holt <holt@sgi.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---

Andrew, this patch has been tested by Robin and the test shows that the bug
of "NULL Pointer deref" bas been fixed. However, we have the argument that
whether the fix of "multiple ->release" should be merged into this patch.
(This patch just do fix the bug of "NULL Pointer deref")

Your thought?

 mm/mmu_notifier.c |   81 +++++++++++++++++++++++++++--------------------------
 1 files changed, 41 insertions(+), 40 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index be04122..606777a 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -40,48 +40,45 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	int id;

 	/*
-	 * srcu_read_lock() here will block synchronize_srcu() in
-	 * mmu_notifier_unregister() until all registered
-	 * ->release() callouts this function makes have
-	 * returned.
+	 * SRCU here will block mmu_notifier_unregister until
+	 * ->release returns.
 	 */
 	id = srcu_read_lock(&srcu);
+	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist)
+		/*
+		 * if ->release runs before mmu_notifier_unregister it
+		 * must be handled as it's the only way for the driver
+		 * to flush all existing sptes and stop the driver
+		 * from establishing any more sptes before all the
+		 * pages in the mm are freed.
+		 */
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
+	srcu_read_unlock(&srcu, id);
+
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
 		mn = hlist_entry(mm->mmu_notifier_mm->list.first,
 				 struct mmu_notifier,
 				 hlist);
-
 		/*
-		 * Unlink.  This will prevent mmu_notifier_unregister()
-		 * from also making the ->release() callout.
+		 * We arrived before mmu_notifier_unregister so
+		 * mmu_notifier_unregister will do nothing other than
+		 * to wait ->release to finish and
+		 * mmu_notifier_unregister to return.
 		 */
 		hlist_del_init_rcu(&mn->hlist);
-		spin_unlock(&mm->mmu_notifier_mm->lock);
-
-		/*
-		 * Clear sptes. (see 'release' description in mmu_notifier.h)
-		 */
-		if (mn->ops->release)
-			mn->ops->release(mn, mm);
-
-		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);

 	/*
-	 * All callouts to ->release() which we have done are complete.
-	 * Allow synchronize_srcu() in mmu_notifier_unregister() to complete
-	 */
-	srcu_read_unlock(&srcu, id);
-
-	/*
-	 * mmu_notifier_unregister() may have unlinked a notifier and may
-	 * still be calling out to it.	Additionally, other notifiers
-	 * may have been active via vmtruncate() et. al. Block here
-	 * to ensure that all notifier callouts for this mm have been
-	 * completed and the sptes are really cleaned up before returning
-	 * to exit_mmap().
+	 * synchronize_srcu here prevents mmu_notifier_release to
+	 * return to exit_mmap (which would proceed freeing all pages
+	 * in the mm) until the ->release method returns, if it was
+	 * invoked by mmu_notifier_unregister.
+	 *
+	 * The mmu_notifier_mm can't go away from under us because one
+	 * mm_count is hold by exit_mmap.
 	 */
 	synchronize_srcu(&srcu);
 }
@@ -292,31 +289,35 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);

-	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
+		/*
+		 * SRCU here will force exit_mmap to wait ->release to finish
+		 * before freeing the pages.
+		 */
 		int id;

+		id = srcu_read_lock(&srcu);
 		/*
-		 * Ensure we synchronize up with __mmu_notifier_release().
+		 * exit_mmap will block in mmu_notifier_release to
+		 * guarantee ->release is called before freeing the
+		 * pages.
 		 */
-		id = srcu_read_lock(&srcu);
-
-		hlist_del_rcu(&mn->hlist);
-		spin_unlock(&mm->mmu_notifier_mm->lock);
-
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
+		srcu_read_unlock(&srcu, id);

+		spin_lock(&mm->mmu_notifier_mm->lock);
 		/*
-		 * Allow __mmu_notifier_release() to complete.
+		 * Can not use list_del_rcu() since __mmu_notifier_release
+		 * can delete it before we hold the lock.
 		 */
-		srcu_read_unlock(&srcu, id);
-	} else
+		hlist_del_init_rcu(&mn->hlist);
 		spin_unlock(&mm->mmu_notifier_mm->lock);
+	}

 	/*
-	 * Wait for any running method to finish, including ->release() if it
-	 * was run by __mmu_notifier_release() instead of us.
+	 * Wait any running method to finish, of course including
+	 * ->release if it was run by mmu_notifier_relase instead of us.
 	 */
 	synchronize_srcu(&srcu);

-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
