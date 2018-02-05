Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA086B000A
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:28:05 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b3so8961660plr.23
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:28:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m37-v6si6153375pla.667.2018.02.04.17.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:04 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 12/64] fs/userfaultfd: teach userfaultfd_must_wait() about range locking
Date: Mon,  5 Feb 2018 02:27:02 +0100
Message-Id: <20180205012754.23615-13-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

And make use of mm_is_locked() which is why we pass down the
vmf->lockrange.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 fs/userfaultfd.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index e3089865fd52..883fbffb284e 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -217,13 +217,14 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 					 struct vm_area_struct *vma,
 					 unsigned long address,
 					 unsigned long flags,
-					 unsigned long reason)
+					 unsigned long reason,
+					 struct range_lock *mmrange)
 {
 	struct mm_struct *mm = ctx->mm;
 	pte_t *pte;
 	bool ret = true;
 
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON(!mm_is_locked(mm, mmrange));
 
 	pte = huge_pte_offset(mm, address, vma_mmu_pagesize(vma));
 	if (!pte)
@@ -247,7 +248,8 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 					 struct vm_area_struct *vma,
 					 unsigned long address,
 					 unsigned long flags,
-					 unsigned long reason)
+					 unsigned long reason,
+					 struct range_lock *mmrange)
 {
 	return false;	/* should never get here */
 }
@@ -263,7 +265,8 @@ static inline bool userfaultfd_huge_must_wait(struct userfaultfd_ctx *ctx,
 static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 					 unsigned long address,
 					 unsigned long flags,
-					 unsigned long reason)
+					 unsigned long reason,
+					 struct range_lock *mmrange)
 {
 	struct mm_struct *mm = ctx->mm;
 	pgd_t *pgd;
@@ -273,7 +276,7 @@ static inline bool userfaultfd_must_wait(struct userfaultfd_ctx *ctx,
 	pte_t *pte;
 	bool ret = true;
 
-	VM_BUG_ON(!rwsem_is_locked(&mm->mmap_sem));
+	VM_BUG_ON(!mm_is_locked(mm, mmrange));
 
 	pgd = pgd_offset(mm, address);
 	if (!pgd_present(*pgd))
@@ -365,7 +368,7 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * Coredumping runs without mmap_sem so we can only check that
 	 * the mmap_sem is held, if PF_DUMPCORE was not set.
 	 */
-	WARN_ON_ONCE(!rwsem_is_locked(&mm->mmap_sem));
+	WARN_ON_ONCE(!mm_is_locked(mm, vmf->lockrange));
 
 	ctx = vmf->vma->vm_userfaultfd_ctx.ctx;
 	if (!ctx)
@@ -473,11 +476,12 @@ int handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
 	if (!is_vm_hugetlb_page(vmf->vma))
 		must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
-						  reason);
+						  reason, vmf->lockrange);
 	else
 		must_wait = userfaultfd_huge_must_wait(ctx, vmf->vma,
 						       vmf->address,
-						       vmf->flags, reason);
+						       vmf->flags, reason,
+						       vmf->lockrange);
 	up_read(&mm->mmap_sem);
 
 	if (likely(must_wait && !READ_ONCE(ctx->released) &&
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
