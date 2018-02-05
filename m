Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40EF86B0006
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:03 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id t18so10028538plo.9
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:03 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s16-v6si1410805plp.326.2018.02.04.17.28.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:01 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 09/64] mm/mmu_notifier: teach oom reaper about range locking
Date: Mon,  5 Feb 2018 02:26:59 +0100
Message-Id: <20180205012754.23615-10-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

Also begin using mm_is_locked() wrappers (which is sometimes
the only reason why mm_has_blockable_invalidate_notifiers()
needs to be aware of the range passed back in oom_reap_task_mm().

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 include/linux/mmu_notifier.h | 6 ++++--
 mm/mmu_notifier.c            | 5 +++--
 mm/oom_kill.c                | 3 ++-
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 2d07a1ed5a31..9172cb0bc15d 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -236,7 +236,8 @@ extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 				  bool only_end);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
-extern bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
+extern bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm,
+						  struct range_lock *mmrange);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -476,7 +477,8 @@ static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 {
 }
 
-static inline bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
+static inline bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm,
+							 struct range_lock *mmrange)
 {
 	return false;
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index eff6b88a993f..3e8a1a10607e 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -240,13 +240,14 @@ EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range);
  * Must be called while holding mm->mmap_sem for either read or write.
  * The result is guaranteed to be valid until mm->mmap_sem is dropped.
  */
-bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm)
+bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm,
+					   struct range_lock *mmrange)
 {
 	struct mmu_notifier *mn;
 	int id;
 	bool ret = false;
 
-	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
+	WARN_ON_ONCE(!mm_is_locked(mm, mmrange));
 
 	if (!mm_has_notifiers(mm))
 		return ret;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 8219001708e0..2288e1cb1bc9 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -490,6 +490,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
 	bool ret = true;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	/*
 	 * We have to make sure to not race with the victim exit path
@@ -519,7 +520,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 * TODO: we really want to get rid of this ugly hack and make sure that
 	 * notifiers cannot block for unbounded amount of time
 	 */
-	if (mm_has_blockable_invalidate_notifiers(mm)) {
+	if (mm_has_blockable_invalidate_notifiers(mm, &mmrange)) {
 		up_read(&mm->mmap_sem);
 		schedule_timeout_idle(HZ);
 		goto unlock_oom;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
