Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 1 of 9] Lock the entire mm to prevent any mmu related
	operation to happen
Message-Id: <ec6d8f91b299cf26cce5.1207669444@duo.random>
In-Reply-To: <patchbomb.1207669443@duo.random>
Date: Tue, 08 Apr 2008 17:44:04 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Steve Wise <swise@opengridcomputing.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1207666462 -7200
# Node ID ec6d8f91b299cf26cce5c3d49bb25d35ee33c137
# Parent  d4c25404de6376297ed34fada14cd6b894410eb0
Lock the entire mm to prevent any mmu related operation to happen.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1050,6 +1050,15 @@
 				   unsigned long addr, unsigned long len,
 				   unsigned long flags, struct page **pages);
 
+struct mm_lock_data {
+	spinlock_t **i_mmap_locks;
+	spinlock_t **anon_vma_locks;
+	unsigned long nr_i_mmap_locks;
+	unsigned long nr_anon_vma_locks;
+};
+extern struct mm_lock_data *mm_lock(struct mm_struct * mm);
+extern void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data);
+
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -26,6 +26,7 @@
 #include <linux/mount.h>
 #include <linux/mempolicy.h>
 #include <linux/rmap.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -2242,3 +2243,140 @@
 
 	return 0;
 }
+
+/*
+ * This operation locks against the VM for all pte/vma/mm related
+ * operations that could ever happen on a certain mm. This includes
+ * vmtruncate, try_to_unmap, and all page faults. The holder
+ * must not hold any mm related lock. A single task can't take more
+ * than one mm lock in a row or it would deadlock.
+ */
+struct mm_lock_data *mm_lock(struct mm_struct * mm)
+{
+	struct vm_area_struct *vma;
+	spinlock_t *i_mmap_lock_last, *anon_vma_lock_last;
+	unsigned long nr_i_mmap_locks, nr_anon_vma_locks, i;
+	struct mm_lock_data *data;
+	int err;
+
+	down_write(&mm->mmap_sem);
+
+	err = -EINTR;
+	nr_i_mmap_locks = nr_anon_vma_locks = 0;
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		cond_resched();
+		if (unlikely(signal_pending(current)))
+			goto out;
+
+		if (vma->vm_file && vma->vm_file->f_mapping)
+			nr_i_mmap_locks++;
+		if (vma->anon_vma)
+			nr_anon_vma_locks++;
+	}
+
+	err = -ENOMEM;
+	data = kmalloc(sizeof(struct mm_lock_data), GFP_KERNEL);
+	if (!data)
+		goto out;
+
+	if (nr_i_mmap_locks) {
+		data->i_mmap_locks = vmalloc(nr_i_mmap_locks *
+					     sizeof(spinlock_t));
+		if (!data->i_mmap_locks)
+			goto out_kfree;
+	} else
+		data->i_mmap_locks = NULL;
+
+	if (nr_anon_vma_locks) {
+		data->anon_vma_locks = vmalloc(nr_anon_vma_locks *
+					       sizeof(spinlock_t));
+		if (!data->anon_vma_locks)
+			goto out_vfree;
+	} else
+		data->anon_vma_locks = NULL;
+
+	err = -EINTR;
+	i_mmap_lock_last = NULL;
+	nr_i_mmap_locks = 0;
+	for (;;) {
+		spinlock_t *i_mmap_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			cond_resched();
+			if (unlikely(signal_pending(current)))
+				goto out_vfree_both;
+
+			if (!vma->vm_file || !vma->vm_file->f_mapping)
+				continue;
+			if ((unsigned long) i_mmap_lock >
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock &&
+			    (unsigned long)
+			    &vma->vm_file->f_mapping->i_mmap_lock >
+			    (unsigned long) i_mmap_lock_last)
+				i_mmap_lock =
+					&vma->vm_file->f_mapping->i_mmap_lock;
+		}
+		if (i_mmap_lock == (spinlock_t *) -1UL)
+			break;
+		i_mmap_lock_last = i_mmap_lock;
+		data->i_mmap_locks[nr_i_mmap_locks++] = i_mmap_lock;
+	}
+	data->nr_i_mmap_locks = nr_i_mmap_locks;
+
+	anon_vma_lock_last = NULL;
+	nr_anon_vma_locks = 0;
+	for (;;) {
+		spinlock_t *anon_vma_lock = (spinlock_t *) -1UL;
+		for (vma = mm->mmap; vma; vma = vma->vm_next) {
+			cond_resched();
+			if (unlikely(signal_pending(current)))
+				goto out_vfree_both;
+
+			if (!vma->anon_vma)
+				continue;
+			if ((unsigned long) anon_vma_lock >
+			    (unsigned long) &vma->anon_vma->lock &&
+			    (unsigned long) &vma->anon_vma->lock >
+			    (unsigned long) anon_vma_lock_last)
+				anon_vma_lock = &vma->anon_vma->lock;
+		}
+		if (anon_vma_lock == (spinlock_t *) -1UL)
+			break;
+		anon_vma_lock_last = anon_vma_lock;
+		data->anon_vma_locks[nr_anon_vma_locks++] = anon_vma_lock;
+	}
+	data->nr_anon_vma_locks = nr_anon_vma_locks;
+
+	for (i = 0; i < nr_i_mmap_locks; i++)
+		spin_lock(data->i_mmap_locks[i]);
+	for (i = 0; i < nr_anon_vma_locks; i++)
+		spin_lock(data->anon_vma_locks[i]);
+
+	return data;
+
+out_vfree_both:
+	vfree(data->anon_vma_locks);
+out_vfree:
+	vfree(data->i_mmap_locks);
+out_kfree:
+	kfree(data);
+out:
+	up_write(&mm->mmap_sem);
+	return ERR_PTR(err);
+}
+
+void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
+{
+	unsigned long i;
+
+	for (i = 0; i < data->nr_i_mmap_locks; i++)
+		spin_unlock(data->i_mmap_locks[i]);
+	for (i = 0; i < data->nr_anon_vma_locks; i++)
+		spin_unlock(data->anon_vma_locks[i]);
+
+	up_write(&mm->mmap_sem);
+	
+	vfree(data->i_mmap_locks);
+	vfree(data->anon_vma_locks);
+	kfree(data);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
