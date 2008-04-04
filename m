From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mmu notifier #v11
Date: Fri, 4 Apr 2008 15:06:18 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0804041504310.12396@schroedinger.engr.sgi.com>
References: <20080401205635.793766935@sgi.com> <20080402064952.GF19189@duo.random>
 <Pine.LNX.4.64.0804021048460.27214@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0804021402190.30337@schroedinger.engr.sgi.com>
 <20080402220148.GV19189@duo.random> <Pine.LNX.4.64.0804021503320.31247@schroedinger.engr.sgi.com>
 <20080402221716.GY19189@duo.random> <Pine.LNX.4.64.0804021821230.639@schroedinger.engr.sgi.com>
 <20080403151908.GB9603@duo.random> <Pine.LNX.4.64.0804031215050.7480@schroedinger.engr.sgi.com>
 <20080404202055.GA14784@duo.random>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753910AbYDDWGf@vger.kernel.org>
In-Reply-To: <20080404202055.GA14784@duo.random>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Hugh Dickins <hugh@veritas.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Nick Piggin <npiggin@suse.de>
List-Id: linux-mm.kvack.org

I am always the guy doing the cleanup after Andrea it seems. Sigh.

Here is the mm_lock/mm_unlock logic separated out for easier review.
Adds some comments. Still objectionable is the multiple ways of
invalidating pages in #v11. Callout now has similar locking to emm.

From: Christoph Lameter <clameter@sgi.com>
Subject: mm_lock: Lock a process against reclaim

Provide a way to lock an mm_struct against reclaim (try_to_unmap
etc). This is necessary for the invalidate notifier approaches so
that they can reliably add and remove a notifier.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h |   10 ++++++++
 mm/mmap.c          |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2008-04-02 11:41:47.741678873 -0700
+++ linux-2.6/include/linux/mm.h	2008-04-04 15:02:17.660504756 -0700
@@ -1050,6 +1050,16 @@ extern int install_special_mapping(struc
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+/*
+ * Locking and unlocking an mm against reclaim.
+ *
+ * mm_lock will take mmap_sem writably (to prevent additional vmas from being
+ * added) and then take all mapping locks of the existing vmas. With that
+ * reclaim is effectively stopped.
+ */
+extern void mm_lock(struct mm_struct *mm);
+extern void mm_unlock(struct mm_struct *mm);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-04-04 14:55:03.477593980 -0700
+++ linux-2.6/mm/mmap.c	2008-04-04 14:59:05.505395402 -0700
@@ -2242,3 +2242,69 @@ int install_special_mapping(struct mm_st
 
 	return 0;
 }
+
+static void mm_lock_unlock(struct mm_struct *mm, int lock)
+{
+	struct vm_area_struct *vma;
+	spinlock_t *i_mmap_lock_last, *anon_vma_lock_last;
+
+	i_mmap_lock_last = NULL;
+	for (;;) {
+		spinlock_t *i_mmap_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			if (vma->vm_file && vma->vm_file->f_mapping &&
+			    (unsigned long) i_mmap_lock >
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock &&
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock >
+			    (unsigned long) i_mmap_lock_last)
+				i_mmap_lock =
+					&vma->vm_file->f_mapping->i_mmap_lock;
+		if (i_mmap_lock == (spinlock_t *) -1UL)
+			break;
+		i_mmap_lock_last = i_mmap_lock;
+		if (lock)
+			spin_lock(i_mmap_lock);
+		else
+			spin_unlock(i_mmap_lock);
+	}
+
+	anon_vma_lock_last = NULL;
+	for (;;) {
+		spinlock_t *anon_vma_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next)
+			if (vma->anon_vma &&
+			    (unsigned long) anon_vma_lock >
+			    (unsigned long) &vma->anon_vma->lock &&
+			    (unsigned long) &vma->anon_vma->lock >
+			    (unsigned long) anon_vma_lock_last)
+				anon_vma_lock = &vma->anon_vma->lock;
+		if (anon_vma_lock == (spinlock_t *) -1UL)
+			break;
+		anon_vma_lock_last = anon_vma_lock;
+		if (lock)
+			spin_lock(anon_vma_lock);
+		else
+			spin_unlock(anon_vma_lock);
+	}
+}
+
+/*
+ * This operation locks against the VM for all pte/vma/mm related
+ * operations that could ever happen on a certain mm. This includes
+ * vmtruncate, try_to_unmap, and all page faults. The holder
+ * must not hold any mm related lock. A single task can't take more
+ * than one mm lock in a row or it would deadlock.
+ */
+void mm_lock(struct mm_struct * mm)
+{
+	down_write(&mm->mmap_sem);
+	mm_lock_unlock(mm, 1);
+}
+
+void mm_unlock(struct mm_struct *mm)
+{
+	mm_lock_unlock(mm, 0);
+	up_write(&mm->mmap_sem);
+}
