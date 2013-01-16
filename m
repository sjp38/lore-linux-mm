Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id EFE3F6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 16:01:26 -0500 (EST)
Date: Wed, 16 Jan 2013 15:01:24 -0600
From: Robin Holt <holt@sgi.com>
Subject: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
Message-ID: <20130116210124.GB3460@sgi.com>
References: <20130115162956.GH3438@sgi.com>
 <20130116200018.GA3460@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130116200018.GA3460@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>


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

Tested with this patch applied.  My test case which was failing
approximately every 300th iteration passed 25,000 tests.

Signed-off-by: Robin Holt <holt@sgi.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Avi Kivity <avi@redhat.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Sagi Grimberg <sagig@mellanox.co.il>
Cc: Haggai Eran <haggaie@mellanox.com>
---
 mm/mmu_notifier.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 8a5ac8c..b873598 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -55,7 +55,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-	srcu_read_unlock(&srcu, id);
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -72,6 +71,8 @@ void __mmu_notifier_release(struct mm_struct *mm)
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
+	srcu_read_unlock(&srcu, id);
+
 	/*
 	 * synchronize_srcu here prevents mmu_notifier_release to
 	 * return to exit_mmap (which would proceed freeing all pages
@@ -292,16 +293,24 @@ void __mmu_notifier_mm_destroy(struct mm_struct *mm)
  */
 void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 {
+	int id;
+
 	BUG_ON(atomic_read(&mm->mm_count) <= 0);
 
+	if (hlist_unhashed(&mn->hlist))
+		goto released;
+
+	/*
+	 * SRCU here will force exit_mmap to wait ->release to finish
+	 * before freeing the pages.
+	 */
+	id = srcu_read_lock(&srcu);
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
 	if (!hlist_unhashed(&mn->hlist)) {
-		/*
-		 * SRCU here will force exit_mmap to wait ->release to finish
-		 * before freeing the pages.
-		 */
-		int id;
+		hlist_del_rcu(&mn->hlist);
+		spin_unlock(&mm->mmu_notifier_mm->lock);
 
-		id = srcu_read_lock(&srcu);
 		/*
 		 * exit_mmap will block in mmu_notifier_release to
 		 * guarantee ->release is called before freeing the
@@ -309,16 +318,16 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-		srcu_read_unlock(&srcu, id);
 
-		spin_lock(&mm->mmu_notifier_mm->lock);
-		hlist_del_rcu(&mn->hlist);
+	} else
 		spin_unlock(&mm->mmu_notifier_mm->lock);
-	}
 
+	srcu_read_unlock(&srcu, id);
+
+released:
 	/*
 	 * Wait any running method to finish, of course including
-	 * ->release if it was run by mmu_notifier_relase instead of us.
+	 * ->release if it was run by __mmu_notifier_release instead of us.
 	 */
 	synchronize_srcu(&srcu);
 
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
