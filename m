Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8A4A6B0030
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 11:50:42 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id q63so1941929qtd.12
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 08:50:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id r94si464043qkh.194.2018.02.06.08.50.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 08:50:41 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w16Gn7LY098483
	for <linux-mm@kvack.org>; Tue, 6 Feb 2018 11:50:41 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fyf6uk9sf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 06 Feb 2018 11:50:40 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 6 Feb 2018 16:50:38 -0000
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: [PATCH v7 09/24] mm: protect mremap() against SPF hanlder
Date: Tue,  6 Feb 2018 17:49:55 +0100
In-Reply-To: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
Message-Id: <1517935810-31177-10-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

If a thread is remapping an area while another one is faulting on the
destination area, the SPF handler may fetch the vma from the RB tree before
the pte has been moved by the other thread. This means that the moved ptes
will overwrite those create by the page fault handler leading to page
leaked.

	CPU 1				CPU2
	enter mremap()
	unmap the dest area
	copy_vma()			Enter speculative page fault handler
	   >> at this time the dest area is present in the RB tree
					fetch the vma matching dest area
					create a pte as the VMA matched
					Exit the SPF handler
					<data written in the new page>
	move_ptes()
	  > it is assumed that the dest area is empty,
 	  > the move ptes overwrite the page mapped by the CPU2.

To prevent that, when the VMA matching the dest area is extended or created
by copy_vma(), it should be marked as non available to the SPF handler.
The usual way to so is to rely on vm_write_begin()/end().
This is already in __vma_adjust() called by copy_vma() (through
vma_merge()). But __vma_adjust() is calling vm_write_end() before returning
which create a window for another thread.
This patch adds a new parameter to vma_merge() which is passed down to
vma_adjust().
The assumption is that copy_vma() is returning a vma which should be
released by calling vm_raw_write_end() by the callee once the ptes have
been moved.

Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
---
 include/linux/mm.h | 16 ++++++++++++----
 mm/mmap.c          | 47 ++++++++++++++++++++++++++++++++++++-----------
 mm/mremap.c        | 13 +++++++++++++
 3 files changed, 61 insertions(+), 15 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 89e5dba22900..bb771afa59a2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2186,16 +2186,24 @@ void anon_vma_interval_tree_verify(struct anon_vma_chain *node);
 extern int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin);
 extern int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
-	struct vm_area_struct *expand);
+	struct vm_area_struct *expand, bool keep_locked);
 static inline int vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert)
 {
-	return __vma_adjust(vma, start, end, pgoff, insert, NULL);
+	return __vma_adjust(vma, start, end, pgoff, insert, NULL, false);
 }
-extern struct vm_area_struct *vma_merge(struct mm_struct *,
+extern struct vm_area_struct *__vma_merge(struct mm_struct *,
 	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
 	unsigned long vm_flags, struct anon_vma *, struct file *, pgoff_t,
-	struct mempolicy *, struct vm_userfaultfd_ctx);
+	struct mempolicy *, struct vm_userfaultfd_ctx, bool keep_locked);
+static inline struct vm_area_struct *vma_merge(struct mm_struct *vma,
+	struct vm_area_struct *prev, unsigned long addr, unsigned long end,
+	unsigned long vm_flags, struct anon_vma *anon, struct file *file,
+	pgoff_t off, struct mempolicy *pol, struct vm_userfaultfd_ctx uff)
+{
+	return __vma_merge(vma, prev, addr, end, vm_flags, anon, file, off,
+			   pol, uff, false);
+}
 extern struct anon_vma *find_mergeable_anon_vma(struct vm_area_struct *);
 extern int __split_vma(struct mm_struct *, struct vm_area_struct *,
 	unsigned long addr, int new_below);
diff --git a/mm/mmap.c b/mm/mmap.c
index c4d944e1be23..13c799710a8a 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -684,7 +684,7 @@ static inline void __vma_unlink_prev(struct mm_struct *mm,
  */
 int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end, pgoff_t pgoff, struct vm_area_struct *insert,
-	struct vm_area_struct *expand)
+	struct vm_area_struct *expand, bool keep_locked)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct vm_area_struct *next = vma->vm_next, *orig_vma = vma;
@@ -996,7 +996,8 @@ int __vma_adjust(struct vm_area_struct *vma, unsigned long start,
 
 	if (next && next != vma)
 		vm_raw_write_end(next);
-	vm_raw_write_end(vma);
+	if (!keep_locked)
+		vm_raw_write_end(vma);
 
 	validate_mm(mm);
 
@@ -1132,12 +1133,13 @@ can_vma_merge_after(struct vm_area_struct *vma, unsigned long vm_flags,
  * parameter) may establish ptes with the wrong permissions of NNNN
  * instead of the right permissions of XXXX.
  */
-struct vm_area_struct *vma_merge(struct mm_struct *mm,
+struct vm_area_struct *__vma_merge(struct mm_struct *mm,
 			struct vm_area_struct *prev, unsigned long addr,
 			unsigned long end, unsigned long vm_flags,
 			struct anon_vma *anon_vma, struct file *file,
 			pgoff_t pgoff, struct mempolicy *policy,
-			struct vm_userfaultfd_ctx vm_userfaultfd_ctx)
+			struct vm_userfaultfd_ctx vm_userfaultfd_ctx,
+			bool keep_locked)
 {
 	pgoff_t pglen = (end - addr) >> PAGE_SHIFT;
 	struct vm_area_struct *area, *next;
@@ -1185,10 +1187,11 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 							/* cases 1, 6 */
 			err = __vma_adjust(prev, prev->vm_start,
 					 next->vm_end, prev->vm_pgoff, NULL,
-					 prev);
+					 prev, keep_locked);
 		} else					/* cases 2, 5, 7 */
 			err = __vma_adjust(prev, prev->vm_start,
-					 end, prev->vm_pgoff, NULL, prev);
+					   end, prev->vm_pgoff, NULL, prev,
+					   keep_locked);
 		if (err)
 			return NULL;
 		khugepaged_enter_vma_merge(prev, vm_flags);
@@ -1205,10 +1208,12 @@ struct vm_area_struct *vma_merge(struct mm_struct *mm,
 					     vm_userfaultfd_ctx)) {
 		if (prev && addr < prev->vm_end)	/* case 4 */
 			err = __vma_adjust(prev, prev->vm_start,
-					 addr, prev->vm_pgoff, NULL, next);
+					 addr, prev->vm_pgoff, NULL, next,
+					 keep_locked);
 		else {					/* cases 3, 8 */
 			err = __vma_adjust(area, addr, next->vm_end,
-					 next->vm_pgoff - pglen, NULL, next);
+					 next->vm_pgoff - pglen, NULL, next,
+					 keep_locked);
 			/*
 			 * In case 3 area is already equal to next and
 			 * this is a noop, but in case 8 "area" has
@@ -3163,9 +3168,20 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 
 	if (find_vma_links(mm, addr, addr + len, &prev, &rb_link, &rb_parent))
 		return NULL;	/* should never get here */
-	new_vma = vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
-			    vma->anon_vma, vma->vm_file, pgoff, vma_policy(vma),
-			    vma->vm_userfaultfd_ctx);
+
+	/* There is 3 cases to manage here in
+	 *     AAAA            AAAA              AAAA              AAAA
+	 * PPPP....      PPPP......NNNN      PPPP....NNNN      PP........NN
+	 * PPPPPPPP(A)   PPPP..NNNNNNNN(B)   PPPPPPPPPPPP(1)       NULL
+	 *                                   PPPPPPPPNNNN(2)
+	 *				     PPPPNNNNNNNN(3)
+	 *
+	 * new_vma == prev in case A,1,2
+	 * new_vma == next in case B,3
+	 */
+	new_vma = __vma_merge(mm, prev, addr, addr + len, vma->vm_flags,
+			      vma->anon_vma, vma->vm_file, pgoff,
+			      vma_policy(vma), vma->vm_userfaultfd_ctx, true);
 	if (new_vma) {
 		/*
 		 * Source vma may have been merged into new_vma
@@ -3205,6 +3221,15 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 			get_file(new_vma->vm_file);
 		if (new_vma->vm_ops && new_vma->vm_ops->open)
 			new_vma->vm_ops->open(new_vma);
+		/*
+		 * As the VMA is linked right now, it may be hit by the
+		 * speculative page fault handler. But we don't want it to
+		 * to start mapping page in this area until the caller has
+		 * potentially move the pte from the moved VMA. To prevent
+		 * that we protect it right now, and let the caller unprotect
+		 * it once the move is done.
+		 */
+		vm_raw_write_begin(new_vma);
 		vma_link(mm, new_vma, prev, rb_link, rb_parent);
 		*need_rmap_locks = false;
 	}
diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..8ed1a1d6eaed 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -302,6 +302,14 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	if (!new_vma)
 		return -ENOMEM;
 
+	/* new_vma is returned protected by copy_vma, to prevent speculative
+	 * page fault to be done in the destination area before we move the pte.
+	 * Now, we must also protect the source VMA since we don't want pages
+	 * to be mapped in our back while we are copying the PTEs.
+	 */
+	if (vma != new_vma)
+		vm_raw_write_begin(vma);
+
 	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, old_len,
 				     need_rmap_locks);
 	if (moved_len < old_len) {
@@ -318,6 +326,8 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		 */
 		move_page_tables(new_vma, new_addr, vma, old_addr, moved_len,
 				 true);
+		if (vma != new_vma)
+			vm_raw_write_end(vma);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
@@ -326,7 +336,10 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 		mremap_userfaultfd_prep(new_vma, uf);
 		arch_remap(mm, old_addr, old_addr + old_len,
 			   new_addr, new_addr + new_len);
+		if (vma != new_vma)
+			vm_raw_write_end(vma);
 	}
+	vm_raw_write_end(new_vma);
 
 	/* Conceal VM_ACCOUNT so old reservation is not undone */
 	if (vm_flags & VM_ACCOUNT) {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
