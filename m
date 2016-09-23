Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEBF06B028B
	for <linux-mm@kvack.org>; Fri, 23 Sep 2016 15:51:50 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id cg13so220033055pac.1
        for <linux-mm@kvack.org>; Fri, 23 Sep 2016 12:51:50 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z188si6378442itc.0.2016.09.23.12.51.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Sep 2016 12:51:50 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/4] mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
Date: Fri, 23 Sep 2016 21:51:45 +0200
Message-Id: <1474660305-19222-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <20160922191556.GF3485@redhat.com>
References: <20160922191556.GF3485@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>

vma->vm_page_prot is read lockless from the rmap_walk, it may be
updated concurrently and this prevents the risk of reading
intermediate values.

v2: avoid semantic change noticed by Hillf Danton in
    vma_wants_writenotify().

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h |  2 +-
 mm/huge_memory.c   |  2 +-
 mm/migrate.c       |  2 +-
 mm/mmap.c          | 16 +++++++++-------
 mm/mprotect.c      |  2 +-
 5 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2334052..67b48fb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1529,7 +1529,7 @@ static inline int pte_devmap(pte_t pte)
 }
 #endif
 
-int vma_wants_writenotify(struct vm_area_struct *vma);
+int vma_wants_writenotify(struct vm_area_struct *vma, pgprot_t vm_page_prot);
 
 extern pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			       spinlock_t **ptl);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a6abd76..ccdc703 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1566,7 +1566,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			if (soft_dirty)
 				entry = pte_swp_mksoft_dirty(entry);
 		} else {
-			entry = mk_pte(page + i, vma->vm_page_prot);
+			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
 			entry = maybe_mkwrite(entry, vma);
 			if (!write)
 				entry = pte_wrprotect(entry);
diff --git a/mm/migrate.c b/mm/migrate.c
index f7ee04a..99250ae 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -234,7 +234,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		goto unlock;
 
 	get_page(new);
-	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
+	pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
 	if (pte_swp_soft_dirty(*ptep))
 		pte = pte_mksoft_dirty(pte);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index d8b5fb3..12f32dd 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -111,13 +111,15 @@ static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
 void vma_set_page_prot(struct vm_area_struct *vma)
 {
 	unsigned long vm_flags = vma->vm_flags;
+	pgprot_t vm_page_prot;
 
-	vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
-	if (vma_wants_writenotify(vma)) {
+	vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
+	if (vma_wants_writenotify(vma, vm_page_prot)) {
 		vm_flags &= ~VM_SHARED;
-		vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
-						     vm_flags);
+		vm_page_prot = vm_pgprot_modify(vm_page_prot, vm_flags);
 	}
+	/* remove_protection_ptes reads vma->vm_page_prot without mmap_sem */
+	WRITE_ONCE(vma->vm_page_prot, vm_page_prot);
 }
 
 /*
@@ -1484,7 +1486,7 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
  * to the private version (using protection_map[] without the
  * VM_SHARED bit).
  */
-int vma_wants_writenotify(struct vm_area_struct *vma)
+int vma_wants_writenotify(struct vm_area_struct *vma, pgprot_t vm_page_prot)
 {
 	vm_flags_t vm_flags = vma->vm_flags;
 	const struct vm_operations_struct *vm_ops = vma->vm_ops;
@@ -1499,8 +1501,8 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
 
 	/* The open routine did something to the protections that pgprot_modify
 	 * won't preserve? */
-	if (pgprot_val(vma->vm_page_prot) !=
-	    pgprot_val(vm_pgprot_modify(vma->vm_page_prot, vm_flags)))
+	if (pgprot_val(vm_page_prot) !=
+	    pgprot_val(vm_pgprot_modify(vm_page_prot, vm_flags)))
 		return 0;
 
 	/* Do we need to track softdirty? */
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e55e2c9..ec91dfd 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -328,7 +328,7 @@ success:
 	 * held in write mode.
 	 */
 	vma->vm_flags = newflags;
-	dirty_accountable = vma_wants_writenotify(vma);
+	dirty_accountable = vma_wants_writenotify(vma, vma->vm_page_prot);
 	vma_set_page_prot(vma);
 
 	change_protection(vma, start, end, vma->vm_page_prot,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
