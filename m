Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1A46B0036
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 14:47:17 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id q107so2390247qgd.28
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:16 -0700 (PDT)
Received: from mail-qc0-x231.google.com (mail-qc0-x231.google.com [2607:f8b0:400d:c01::231])
        by mx.google.com with ESMTPS id t73si3492513qge.118.2014.07.17.11.47.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 11:47:16 -0700 (PDT)
Received: by mail-qc0-f177.google.com with SMTP id o8so2457530qcw.22
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 11:47:16 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 1/7] mmu_notifier: add call_srcu and sync function for listener to delay call and sync.
Date: Thu, 17 Jul 2014 14:46:47 -0400
Message-Id: <1405622809-3797-2-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
References: <1405622809-3797-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Peter Zijlstra <peterz@infradead.org>

New mmu_notifier listener are eager to cleanup there structure after the
mmu_notifier::release callback. In order to allow this the patch provide
a function that allows to add a delayed call to the mmu_notifier srcu. It
also add a function that will call barrier_srcu so those listener can sync
with mmu_notifier.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mmu_notifier.h |  6 ++++++
 mm/mmu_notifier.c            | 40 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 45 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index deca874..2728869 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -170,6 +170,8 @@ extern int __mmu_notifier_register(struct mmu_notifier *mn,
 				   struct mm_struct *mm);
 extern void mmu_notifier_unregister(struct mmu_notifier *mn,
 				    struct mm_struct *mm);
+extern void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
+					       struct mm_struct *mm);
 extern void __mmu_notifier_mm_destroy(struct mm_struct *mm);
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
@@ -288,6 +290,10 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 	set_pte_at(___mm, ___address, __ptep, ___pte);			\
 })
 
+extern void mmu_notifier_call_srcu(struct rcu_head *rcu,
+				   void (*func)(struct rcu_head *rcu));
+extern void mmu_notifier_synchronize(void);
+
 #else /* CONFIG_MMU_NOTIFIER */
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 41cefdf..950813b 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -23,6 +23,25 @@
 static struct srcu_struct srcu;
 
 /*
+ * This function allows mmu_notifier::release callback to delay a call to
+ * a function that will free appropriate resources. The function must be
+ * quick and must not block.
+ */
+void mmu_notifier_call_srcu(struct rcu_head *rcu,
+			    void (*func)(struct rcu_head *rcu))
+{
+	call_srcu(&srcu, rcu, func);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_call_srcu);
+
+void mmu_notifier_synchronize(void)
+{
+	/* Wait for any running method to finish. */
+	srcu_barrier(&srcu);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_synchronize);
+
+/*
  * This function can't run concurrently against mmu_notifier_register
  * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
  * runs with mm_users == 0. Other tasks may still invoke mmu notifiers
@@ -53,7 +72,6 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		 */
 		if (mn->ops->release)
 			mn->ops->release(mn, mm);
-	srcu_read_unlock(&srcu, id);
 
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	while (unlikely(!hlist_empty(&mm->mmu_notifier_mm->list))) {
@@ -69,6 +87,7 @@ void __mmu_notifier_release(struct mm_struct *mm)
 		hlist_del_init_rcu(&mn->hlist);
 	}
 	spin_unlock(&mm->mmu_notifier_mm->lock);
+	srcu_read_unlock(&srcu, id);
 
 	/*
 	 * synchronize_srcu here prevents mmu_notifier_release from returning to
@@ -325,6 +344,25 @@ void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister);
 
+/*
+ * Same as mmu_notifier_unregister but no callback and no srcu synchronization.
+ */
+void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
+					struct mm_struct *mm)
+{
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	/*
+	 * Can not use list_del_rcu() since __mmu_notifier_release
+	 * can delete it before we hold the lock.
+	 */
+	hlist_del_init_rcu(&mn->hlist);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
+	BUG_ON(atomic_read(&mm->mm_count) <= 0);
+	mmdrop(mm);
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
+
 static int __init mmu_notifier_init(void)
 {
 	return init_srcu_struct(&srcu);
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
