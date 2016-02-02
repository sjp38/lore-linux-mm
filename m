Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1836B0009
	for <linux-mm@kvack.org>; Tue,  2 Feb 2016 04:10:26 -0500 (EST)
Received: by mail-lf0-f50.google.com with SMTP id j78so44039317lfb.1
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 01:10:26 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id i138si242738lfg.163.2016.02.02.01.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Feb 2016 01:10:24 -0800 (PST)
Received: by mail-lb0-x234.google.com with SMTP id x4so91517745lbm.0
        for <linux-mm@kvack.org>; Tue, 02 Feb 2016 01:10:24 -0800 (PST)
Subject: [PATCH] mm: replace vma_lock_anon_vma with anon_vma_lock_read/write
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 02 Feb 2016 12:10:19 +0300
Message-ID: <145440421918.17103.16454803336779455616.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>

Sequence vma_lock_anon_vma() - vma_unlock_anon_vma() isn't safe if
anon_vma appeared between lock and unlock. We have to check anon_vma
first or call anon_vma_prepare() to be sure that it's here. There are
only few users of these legacy helpers. Let's get rid of them.

This patch fixes anon_vma lock imbalance in validate_mm().
Write lock isn't required here, read lock is enough.

And reorders expand_downwards/expand_upwards: security_mmap_addr() and
wrapping-around check don't have to be under anon vma lock.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Link: https://lkml.kernel.org/r/CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com
---
 include/linux/rmap.h |   14 -------------
 mm/mmap.c            |   55 +++++++++++++++++++++++---------------------------
 2 files changed, 25 insertions(+), 44 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index bdf597c4f0be..a07f42bedda3 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -109,20 +109,6 @@ static inline void put_anon_vma(struct anon_vma *anon_vma)
 		__put_anon_vma(anon_vma);
 }
 
-static inline void vma_lock_anon_vma(struct vm_area_struct *vma)
-{
-	struct anon_vma *anon_vma = vma->anon_vma;
-	if (anon_vma)
-		down_write(&anon_vma->root->rwsem);
-}
-
-static inline void vma_unlock_anon_vma(struct vm_area_struct *vma)
-{
-	struct anon_vma *anon_vma = vma->anon_vma;
-	if (anon_vma)
-		up_write(&anon_vma->root->rwsem);
-}
-
 static inline void anon_vma_lock_write(struct anon_vma *anon_vma)
 {
 	down_write(&anon_vma->root->rwsem);
diff --git a/mm/mmap.c b/mm/mmap.c
index cfc0cdca421e..ed4a9390ef1e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -456,12 +456,16 @@ static void validate_mm(struct mm_struct *mm)
 	struct vm_area_struct *vma = mm->mmap;
 
 	while (vma) {
+		struct anon_vma *anon_vma = vma->anon_vma;
 		struct anon_vma_chain *avc;
 
-		vma_lock_anon_vma(vma);
-		list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
-			anon_vma_interval_tree_verify(avc);
-		vma_unlock_anon_vma(vma);
+		if (anon_vma) {
+			anon_vma_lock_read(anon_vma);
+			list_for_each_entry(avc, &vma->anon_vma_chain, same_vma)
+				anon_vma_interval_tree_verify(avc);
+			anon_vma_unlock_read(anon_vma);
+		}
+
 		highest_address = vma->vm_end;
 		vma = vma->vm_next;
 		i++;
@@ -2142,32 +2146,27 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
 int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	int error;
+	int error = 0;
 
 	if (!(vma->vm_flags & VM_GROWSUP))
 		return -EFAULT;
 
-	/*
-	 * We must make sure the anon_vma is allocated
-	 * so that the anon_vma locking is not a noop.
-	 */
+	/* Guard against wrapping around to address 0. */
+	if (address < PAGE_ALIGN(address+4))
+		address = PAGE_ALIGN(address+4);
+	else
+		return -ENOMEM;
+
+	/* We must make sure the anon_vma is allocated. */
 	if (unlikely(anon_vma_prepare(vma)))
 		return -ENOMEM;
-	vma_lock_anon_vma(vma);
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
 	 * is required to hold the mmap_sem in read mode.  We need the
 	 * anon_vma lock to serialize against concurrent expand_stacks.
-	 * Also guard against wrapping around to address 0.
 	 */
-	if (address < PAGE_ALIGN(address+4))
-		address = PAGE_ALIGN(address+4);
-	else {
-		vma_unlock_anon_vma(vma);
-		return -ENOMEM;
-	}
-	error = 0;
+	anon_vma_lock_write(vma->anon_vma);
 
 	/* Somebody else might have raced and expanded it already */
 	if (address > vma->vm_end) {
@@ -2185,7 +2184,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 				 * updates, but we only hold a shared mmap_sem
 				 * lock here, so we need to protect against
 				 * concurrent vma expansions.
-				 * vma_lock_anon_vma() doesn't help here, as
+				 * anon_vma_lock_write() doesn't help here, as
 				 * we don't guarantee that all growable vmas
 				 * in a mm share the same root anon vma.
 				 * So, we reuse mm->page_table_lock to guard
@@ -2208,7 +2207,7 @@ int expand_upwards(struct vm_area_struct *vma, unsigned long address)
 			}
 		}
 	}
-	vma_unlock_anon_vma(vma);
+	anon_vma_unlock_write(vma->anon_vma);
 	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(mm);
 	return error;
@@ -2224,25 +2223,21 @@ int expand_downwards(struct vm_area_struct *vma,
 	struct mm_struct *mm = vma->vm_mm;
 	int error;
 
-	/*
-	 * We must make sure the anon_vma is allocated
-	 * so that the anon_vma locking is not a noop.
-	 */
-	if (unlikely(anon_vma_prepare(vma)))
-		return -ENOMEM;
-
 	address &= PAGE_MASK;
 	error = security_mmap_addr(address);
 	if (error)
 		return error;
 
-	vma_lock_anon_vma(vma);
+	/* We must make sure the anon_vma is allocated. */
+	if (unlikely(anon_vma_prepare(vma)))
+		return -ENOMEM;
 
 	/*
 	 * vma->vm_start/vm_end cannot change under us because the caller
 	 * is required to hold the mmap_sem in read mode.  We need the
 	 * anon_vma lock to serialize against concurrent expand_stacks.
 	 */
+	anon_vma_lock_write(vma->anon_vma);
 
 	/* Somebody else might have raced and expanded it already */
 	if (address < vma->vm_start) {
@@ -2260,7 +2255,7 @@ int expand_downwards(struct vm_area_struct *vma,
 				 * updates, but we only hold a shared mmap_sem
 				 * lock here, so we need to protect against
 				 * concurrent vma expansions.
-				 * vma_lock_anon_vma() doesn't help here, as
+				 * anon_vma_lock_write() doesn't help here, as
 				 * we don't guarantee that all growable vmas
 				 * in a mm share the same root anon vma.
 				 * So, we reuse mm->page_table_lock to guard
@@ -2281,7 +2276,7 @@ int expand_downwards(struct vm_area_struct *vma,
 			}
 		}
 	}
-	vma_unlock_anon_vma(vma);
+	anon_vma_unlock_write(vma->anon_vma);
 	khugepaged_enter_vma_merge(vma, vma->vm_flags);
 	validate_mm(mm);
 	return error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
