Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 19E296B0005
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 08:03:09 -0500 (EST)
Date: Mon, 4 Feb 2013 07:03:06 -0600
From: Robin Holt <holt@sgi.com>
Subject: [PATCH] mmu_notifier_unregister NULL Pointer deref and multiple
 ->release() callouts. [V2]
Message-ID: <20130204130306.GL3438@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>, stable-kernel <stable@vger.kernel.org>


There is a race condition between mmu_notifier_unregister() and
__mmu_notifier_release().

Assume two tasks, one calling mmu_notifier_unregister() as a result
of a filp_close() ->flush() callout (task A), and the other calling
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

Additionally, the list traversal in __mmu_notifier_release() is not
protected by the by the mmu_notifier_mm->hlist_lock which can result in
callouts to the ->release() notifier from both mmu_notifier_unregister()
and __mmu_notifier_release().

Signed-off-by: Robin Holt <holt@sgi.com>
To: Andrew Morton <akpm@linux-foundation.org>
To: Andrea Arcangeli <aarcange@redhat.com>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Avi Kivity <avi@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Sagi Grimberg <sagig@mellanox.co.il>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: stable-kernel <stable@vger.kernel.org> # 3.[0-6].y 21a9273
Cc: stable-kernel <stable@vger.kernel.org> # 3.[0-6].y 7040030
Cc: stable-kernel <stable@vger.kernel.org>

---

Andrew, I have a question about the stable maintainer bits I hope you
could help me with.  Will the syntax I used above get this into 3.0.y
through 3.7.y?  3.7.y does not need the other two commits, but all the
rest do.  If not and you wouldn't mind fixing it up for me, I would
appreciate the help.

Tested with this patch applied.  My test case, which was failing
approximately every 300th iteration, passed 25,000 tests.

Changes:

V2
Reworked __mmu_notifier_release() to also use the hlist_lock to protect
hlist deletion and callouts to the ->release() method.

 mm/mmu_notifier.c | 82 ++++++++++++++++++++++++++++---------------------------
 1 file changed, 42 insertions(+), 40 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8a5ac8c..f5c3d96 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -37,49 +37,51 @@ static struct srcu_struct srcu;
 void __mmu_notifier_release(struct mm_struct *mm)
 {
 	struct mmu_notifier *mn;
-	struct hlist_node *n;
 	int id;
 
 	/*
-	 * SRCU here will block mmu_notifier_unregister until
-	 * ->release returns.
+	 * srcu_read_lock() here will block synchronize_srcu() in
+	 * mmu_notifier_unregister() until all registered
+	 * ->release() callouts this function makes have
+	 * returned.
 	 */
 	id = srcu_read_lock(&srcu);
-	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_mm->list, hlist)
-		/*
-		 * if ->release runs before mmu_notifier_unregister it
-		 * must be handled as it's the only way for the driver
-		 * to flush all existing sptes and stop the driver
-		 * from establishing any more sptes before all the
-		 * pages in the mm are freed.
-		 */
-		if (mn->ops->release)
-			mn->ops->release(mn, mm);
-	srcu_read_unlock(&srcu, id);
-
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
 		mn = hlist_entry(mm->mmu_notifier_mm->list.first,
 				 struct mmu_notifier,
 				 hlist);
+
 		/*
-		 * We arrived before mmu_notifier_unregister so
-		 * mmu_notifier_unregister will do nothing other than
-		 * to wait ->release to finish and
-		 * mmu_notifier_unregister to return.
+		 * Unlink.  This will prevent mmu_notifier_unregister()
+		 * from also making the ->release() callout.
 		 */
 		hlist_del_init_rcu(&mn->hlist);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+
+		/*
+		 * Clear sptes. (see 'release' description in mmu_notifier.h)
+		 */
+		if (mn->ops->release)
+			mn->ops->release(mn, mm);
+
+		spin_lock(&mm->mmu_notifier_mm->lock);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
 	/*
-	 * synchronize_srcu here prevents mmu_notifier_release to
-	 * return to exit_mmap (which would proceed freeing all pages
-	 * in the mm) until the ->release method returns, if it was
-	 * invoked by mmu_notifier_unregister.
-	 *
-	 * The mmu_notifier_mm can't go away from under us because one
-	 * mm_count is hold by exit_mmap.
+	 * All callouts to ->release() which we have done are complete.
+	 * Allow synchronize_srcu() in mmu_notifier_unregister() to complete
+	 */
+	srcu_read_unlock(&srcu, id);
+
+	/*
+	 * mmu_notifier_unregister() may have unlinked a notifier and may
+	 * still be calling out to it.	Additionally, other notifiers
+	 * may have been active via vmtruncate() et. al. Block here
+	 * to ensure that all notifier callouts for this mm have been
+	 * completed and the sptes are really cleaned up before returning
+	 * to exit_mmap().
 	 */
 	synchronize_srcu(&srcu);
 }
@@ -294,31 +296,31 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
+	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
-		/*
-		 * SRCU here will force exit_mmap to wait ->release to finish
-		 * before freeing the pages.
-		 */
 		int id;
 
-		id = srcu_read_lock(&srcu);
 		/*
-		 * exit_mmap will block in mmu_notifier_release to
-		 * guarantee ->release is called before freeing the
-		 * pages.
+		 * Ensure we synchronize up with __mmu_notifier_release().
 		 */
+		id = srcu_read_lock(&srcu);
+
+		hlist_del_rcu(&mn->hlist);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
+
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		srcu_read_unlock(&srcu, id);
 
-		spin_lock(&mm->mmu_notifier_mm->lock);
-		hlist_del_rcu(&mn->hlist);
+		/*
+		 * Allow __mmu_notifier_release() to complete.
+		 */
+		srcu_read_unlock(&srcu, id);
+	} else
 		spin_unlock(&mm->mmu_notifier_mm->lock);
-	}
 
 	/*
-	 * Wait any running method to finish, of course including
-	 * ->release if it was run by mmu_notifier_relase instead of us.
+	 * Wait for any running method to finish, including ->release() if it
+	 * was run by __mmu_notifier_release() instead of us.
 	 */
 	synchronize_srcu(&srcu);
 
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
