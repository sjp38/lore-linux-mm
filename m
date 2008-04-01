From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 8/9] XPMEM: The device driver
Date: Tue, 01 Apr 2008 13:55:39 -0700
Message-ID: <20080401205637.474020250@sgi.com>
References: <20080401205531.986291575@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <kvm-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename=xpmem_v003_emm_SSI_v3
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=kvm-devel>
List-Post: <mailto:kvm-devel@lists.sourceforge.net>
List-Help: <mailto:kvm-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/kvm-devel>,
	<mailto:kvm-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: kvm-devel-bounces@lists.sourceforge.net
Errors-To: kvm-devel-bounces@lists.sourceforge.net
To: Hugh Dickins <hugh@veritas.com>
Cc: steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

XPmem device driver that allows sharing of address spaces across different
instances of Linux. [Experimental, lots of issues still to be fixed].

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: emm_notifier_xpmem_v1/drivers/misc/xp/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/Makefile	2008-04-01 10:42:33.045763082 -0500
@@ -0,0 +1,16 @@
+# drivers/misc/xp/Makefile
+#
+# This file is subject to the terms and conditions of the GNU General Public
+# License.  See the file "COPYING" in the main directory of this archive
+# for more details.
+#
+# Copyright (C) 1999,2001-2008 Silicon Graphics, Inc.  All Rights Reserved.
+#
+
+# This is just temporary.  Please do not comment.  I am waiting for Dean
+# Nelson's XPC patches to go in and will modify files introduced by his patches
+# to enable.
+obj-m				+= xpmem.o
+xpmem-y				:= xpmem_main.o xpmem_make.o xpmem_get.o \
+				   xpmem_attach.o xpmem_pfn.o \
+				   xpmem_misc.o
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_attach.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_attach.c	2008-04-01 10:42:33.221784791 -0500
@@ -0,0 +1,824 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) attach support.
+ */
+
+#include <linux/device.h>
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/file.h>
+#include <linux/mman.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/*
+ * This function is called whenever a XPMEM address segment is unmapped.
+ * We only expect this to occur from a XPMEM detach operation, and if that
+ * is the case, there is nothing to do since the detach code takes care of
+ * everything. In all other cases, something is tinkering with XPMEM vmas
+ * outside of the XPMEM API, so we do the necessary cleanup and kill the
+ * current thread group. The vma argument is the portion of the address space
+ * that is being unmapped.
+ */
+static void
+xpmem_close(struct vm_area_struct *vma)
+{
+	struct vm_area_struct *remaining_vma;
+	u64 remaining_vaddr;
+	struct xpmem_access_permit *ap;
+	struct xpmem_attachment *att;
+
+	att = vma->vm_private_data;
+	if (att == NULL)
+		return;
+
+	xpmem_att_ref(att);
+	mutex_lock(&att->mutex);
+
+	if (att->flags & XPMEM_FLAG_DESTROYING) {
+		/* the unmap is being done via a detach operation */
+		mutex_unlock(&att->mutex);
+		xpmem_att_deref(att);
+		return;
+	}
+
+	if (current->flags & PF_EXITING) {
+		/* the unmap is being done via process exit */
+		mutex_unlock(&att->mutex);
+		ap = att->ap;
+		xpmem_ap_ref(ap);
+		xpmem_detach_att(ap, att);
+		xpmem_ap_deref(ap);
+		xpmem_att_deref(att);
+		return;
+	}
+
+	/*
+	 * See if the entire vma is being unmapped. If so, clean up the
+	 * the xpmem_attachment structure and leave the vma to be cleaned up
+	 * by the kernel exit path.
+	 */
+	if (vma->vm_start == att->at_vaddr &&
+	    ((vma->vm_end - vma->vm_start) == att->at_size)) {
+
+		xpmem_att_set_destroying(att);
+
+		ap = att->ap;
+		xpmem_ap_ref(ap);
+
+		spin_lock(&ap->lock);
+		list_del_init(&att->att_list);
+		spin_unlock(&ap->lock);
+
+		xpmem_ap_deref(ap);
+
+		xpmem_att_set_destroyed(att);
+		xpmem_att_destroyable(att);
+		goto out;
+	}
+
+	/*
+	 * Find the starting vaddr of the vma that will remain after the unmap
+	 * has finished. The following if-statement tells whether the kernel
+	 * is unmapping the head, tail, or middle of a vma respectively.
+	 */
+	if (vma->vm_start == att->at_vaddr)
+		remaining_vaddr = vma->vm_end;
+	else if (vma->vm_end == att->at_vaddr + att->at_size)
+		remaining_vaddr = att->at_vaddr;
+	else {
+		/*
+		 * If the unmap occurred in the middle of vma, we have two
+		 * remaining vmas to fix up. We first clear out the tail vma
+		 * so it gets cleaned up at exit without any ties remaining
+		 * to XPMEM.
+		 */
+		remaining_vaddr = vma->vm_end;
+		remaining_vma = find_vma(current->mm, remaining_vaddr);
+		BUG_ON(!remaining_vma ||
+		       remaining_vma->vm_start > remaining_vaddr ||
+		       remaining_vma->vm_private_data != vma->vm_private_data);
+
+		/* this should be safe (we have the mmap_sem write-locked) */
+		remaining_vma->vm_private_data = NULL;
+		remaining_vma->vm_ops = NULL;
+
+		/* now set the starting vaddr to point to the head vma */
+		remaining_vaddr = att->at_vaddr;
+	}
+
+	/*
+	 * Find the remaining vma left over by the unmap split and fix
+	 * up the corresponding xpmem_attachment structure.
+	 */
+	remaining_vma = find_vma(current->mm, remaining_vaddr);
+	BUG_ON(!remaining_vma ||
+	       remaining_vma->vm_start > remaining_vaddr ||
+	       remaining_vma->vm_private_data != vma->vm_private_data);
+
+	att->at_vaddr = remaining_vma->vm_start;
+	att->at_size = remaining_vma->vm_end - remaining_vma->vm_start;
+
+	/* clear out the private data for the vma being unmapped */
+	vma->vm_private_data = NULL;
+
+out:
+	mutex_unlock(&att->mutex);
+	xpmem_att_deref(att);
+
+	/* cause the demise of the current thread group */
+	dev_err(xpmem, "unexpected unmap of XPMEM segment at [0x%lx - 0x%lx], "
+		"killed process %d (%s)\n", vma->vm_start, vma->vm_end,
+		current->pid, current->comm);
+	sigaddset(&current->pending.signal, SIGKILL);
+	set_tsk_thread_flag(current, TIF_SIGPENDING);
+}
+
+static unsigned long
+xpmem_fault_handler(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	int ret;
+	int drop_memprot = 0;
+	int seg_tg_mmap_sem_locked = 0;
+	int vma_verification_needed = 0;
+	int recalls_blocked = 0;
+	u64 seg_vaddr;
+	u64 paddr;
+	unsigned long pfn = 0;
+	u64 *xpmem_pfn;
+	struct xpmem_thread_group *ap_tg;
+	struct xpmem_thread_group *seg_tg;
+	struct xpmem_access_permit *ap;
+	struct xpmem_attachment *att;
+	struct xpmem_segment *seg;
+	sigset_t oldset;
+
+	/* ensure do_coredump() doesn't fault pages of this attachment */
+	if (current->flags & PF_DUMPCORE)
+		return 0;
+
+	att = vma->vm_private_data;
+	if (att == NULL)
+		return 0;
+
+	xpmem_att_ref(att);
+	ap = att->ap;
+	xpmem_ap_ref(ap);
+	ap_tg = ap->tg;
+	xpmem_tg_ref(ap_tg);
+
+	seg = ap->seg;
+	xpmem_seg_ref(seg);
+	seg_tg = seg->tg;
+	xpmem_tg_ref(seg_tg);
+
+	DBUG_ON(current->tgid != ap_tg->tgid);
+	DBUG_ON(ap->mode != XPMEM_RDWR);
+
+	if ((ap->flags & XPMEM_FLAG_DESTROYING) ||
+	    (ap_tg->flags & XPMEM_FLAG_DESTROYING))
+		goto out_1;
+
+	/* translate the fault page offset to the source virtual address */
+	seg_vaddr = seg->vaddr + (vmf->pgoff << PAGE_SHIFT);
+
+	/*
+	 * The faulting thread has its mmap_sem locked on entrance to this
+	 * fault handler. In order to supply the missing page we will need
+	 * to get access to the segment that has it, as well as lock the
+	 * mmap_sem of the thread group that owns the segment should it be
+	 * different from the faulting thread's. Together these provide the
+	 * potential for a deadlock, which we attempt to avoid in what follows.
+	 */
+
+	ret = xpmem_seg_down_read(seg_tg, seg, 0, 0);
+
+avoid_deadlock_1:
+
+	if (ret == -EAGAIN) {
+		/* to avoid possible deadlock drop current->mm->mmap_sem */
+		up_read(&current->mm->mmap_sem);
+		ret = xpmem_seg_down_read(seg_tg, seg, 0, 1);
+		down_read(&current->mm->mmap_sem);
+		vma_verification_needed = 1;
+	}
+	if (ret != 0)
+		goto out_1;
+
+avoid_deadlock_2:
+
+	/* verify vma hasn't changed due to dropping current->mm->mmap_sem */
+	if (vma_verification_needed) {
+		struct vm_area_struct *retry_vma;
+
+		retry_vma = find_vma(current->mm, (u64)vmf->virtual_address);
+		if (!retry_vma ||
+		    retry_vma->vm_start > (u64)vmf->virtual_address ||
+		    !xpmem_is_vm_ops_set(retry_vma) ||
+		    retry_vma->vm_private_data != att)
+			goto out_2;
+
+		vma_verification_needed = 0;
+	}
+
+	xpmem_block_nonfatal_signals(&oldset);
+	if (mutex_lock_interruptible(&att->mutex)) {
+		xpmem_unblock_nonfatal_signals(&oldset);
+		goto out_2;
+	}
+	xpmem_unblock_nonfatal_signals(&oldset);
+
+	if ((att->flags & XPMEM_FLAG_DESTROYING) ||
+	    (ap_tg->flags & XPMEM_FLAG_DESTROYING) ||
+	    (seg_tg->flags & XPMEM_FLAG_DESTROYING))
+		goto out_3;
+
+	if (!seg_tg_mmap_sem_locked &&
+		   &current->mm->mmap_sem > &seg_tg->mm->mmap_sem) {
+		/*
+		 * The faulting thread's mmap_sem is numerically smaller
+		 * than the seg's thread group's mmap_sem address-wise,
+		 * therefore we need to acquire the latter's mmap_sem in a
+		 * safe manner before calling xpmem_ensure_valid_PFNs() to
+		 * avoid a potential deadlock.
+		 *
+		 * Concerning the inc/dec of mm_users in this function:
+		 * When /dev/xpmem is opened by a user process, xpmem_open()
+		 * increments mm_users and when it is flushed, xpmem_flush()
+		 * decrements it via mmput() after having first ensured that
+		 * no XPMEM attachments to this mm exist. Therefore, the
+		 * decrement of mm_users by this function will never take it
+		 * to zero.
+		 */
+		seg_tg_mmap_sem_locked = 1;
+		atomic_inc(&seg_tg->mm->mm_users);
+		if (!down_read_trylock(&seg_tg->mm->mmap_sem)) {
+			mutex_unlock(&att->mutex);
+			up_read(&current->mm->mmap_sem);
+			down_read(&seg_tg->mm->mmap_sem);
+			down_read(&current->mm->mmap_sem);
+			vma_verification_needed = 1;
+			goto avoid_deadlock_2;
+		}
+	}
+
+	ret = xpmem_ensure_valid_PFNs(seg, seg_vaddr, 1, drop_memprot, 1,
+				      (vma->vm_flags & VM_PFNMAP),
+				      seg_tg_mmap_sem_locked, &recalls_blocked);
+	if (seg_tg_mmap_sem_locked) {
+		up_read(&seg_tg->mm->mmap_sem);
+		/* mm_users won't dec to 0, see comment above where inc'd */
+		atomic_dec(&seg_tg->mm->mm_users);
+		seg_tg_mmap_sem_locked = 0;
+	}
+	if (ret != 0) {
+		/* xpmem_ensure_valid_PFNs could not re-acquire. */
+		if (ret == -ENOENT) {
+			mutex_unlock(&att->mutex);
+			goto out_3;
+		}
+
+		if (ret == -EAGAIN) {
+			if (recalls_blocked) {
+				xpmem_unblock_recall_PFNs(seg_tg);
+				recalls_blocked = 0;
+			}
+			mutex_unlock(&att->mutex);
+			xpmem_seg_up_read(seg_tg, seg, 0);
+			goto avoid_deadlock_1;
+		}
+
+		goto out_4;
+	}
+
+	xpmem_pfn = xpmem_vaddr_to_PFN(seg, seg_vaddr);
+	DBUG_ON(!XPMEM_PFN_IS_KNOWN(xpmem_pfn));
+
+	if (*xpmem_pfn & XPMEM_PFN_UNCACHED)
+		vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	paddr = XPMEM_PFN_TO_PADDR(xpmem_pfn);
+
+#ifdef CONFIG_IA64
+	if (att->flags & XPMEM_ATTACH_WC)
+		vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
+	else if (att->flags & XPMEM_ATTACH_GETSPACE)
+		paddr = __pa(TO_GET(paddr));
+#endif /* CONFIG_IA64 */
+
+	pfn = paddr >> PAGE_SHIFT;
+
+	att->flags |= XPMEM_FLAG_VALIDPTES;
+
+out_4:
+	if (recalls_blocked) {
+		xpmem_unblock_recall_PFNs(seg_tg);
+		recalls_blocked = 0;
+	}
+out_3:
+	mutex_unlock(&att->mutex);
+out_2:
+	if (seg_tg_mmap_sem_locked) {
+		up_read(&seg_tg->mm->mmap_sem);
+		/* mm_users won't dec to 0, see comment above where inc'd */
+		atomic_dec(&seg_tg->mm->mm_users);
+	}
+	xpmem_seg_up_read(seg_tg, seg, 0);
+out_1:
+	xpmem_att_deref(att);
+	xpmem_ap_deref(ap);
+	xpmem_tg_deref(ap_tg);
+	xpmem_seg_deref(seg);
+	xpmem_tg_deref(seg_tg);
+	return pfn;
+}
+
+/*
+ * This is the vm_ops->fault for xpmem_attach()'d segments. It is
+ * called by the Linux kernel function __do_fault().
+ */
+static int
+xpmem_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	unsigned long pfn;
+
+	pfn = xpmem_fault_handler(vma, vmf);
+	if (!pfn)
+		return VM_FAULT_SIGBUS;
+
+	BUG_ON(!pfn_valid(pfn));
+	vmf->page = pfn_to_page(pfn);
+	get_page(vmf->page);
+	return 0;
+}
+
+/*
+ * This is the vm_ops->nopfn for xpmem_attach()'d segments. It is
+ * called by the Linux kernel function do_no_pfn().
+ */
+static unsigned long
+xpmem_nopfn(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	struct vm_fault vmf;
+	unsigned long pfn;
+
+	vmf.virtual_address = (void __user *)vaddr;
+	vmf.pgoff = (((vaddr & PAGE_MASK) - vma->vm_start) >> PAGE_SHIFT) +
+		    vma->vm_pgoff;
+	vmf.flags = 0; /* >>> Should be (write_access ? FAULT_FLAG_WRITE : 0) */
+	vmf.page = NULL;
+
+	pfn = xpmem_fault_handler(vma, &vmf);
+	if (!pfn)
+		return NOPFN_SIGBUS;
+
+	return pfn;
+}
+
+struct vm_operations_struct xpmem_vm_ops_fault = {
+	.close = xpmem_close,
+	.fault = xpmem_fault
+};
+
+struct vm_operations_struct xpmem_vm_ops_nopfn = {
+	.close = xpmem_close,
+	.nopfn = xpmem_nopfn
+};
+
+/*
+ * This function is called via the Linux kernel mmap() code, which is
+ * instigated by the call to do_mmap() in xpmem_attach().
+ */
+int
+xpmem_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	/*
+	 * When a mapping is related to a file, the file pointer is typically
+	 * stored in vma->vm_file and a fput() is done to it when the VMA is
+	 * unmapped. Since file is of no interest in XPMEM's case, we ensure
+	 * vm_file is empty and do the fput() here.
+	 */
+	vma->vm_file = NULL;
+	fput(file);
+
+	vma->vm_ops = &xpmem_vm_ops_fault;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	return 0;
+}
+
+/*
+ * Attach a XPMEM address segment.
+ */
+int
+xpmem_attach(struct file *file, __s64 apid, off_t offset, size_t size,
+	     u64 vaddr, int fd, int att_flags, u64 *at_vaddr_p)
+{
+	int ret;
+	unsigned long flags;
+	unsigned long prot_flags = PROT_READ | PROT_WRITE;
+	unsigned long vm_pfnmap = 0;
+	u64 seg_vaddr;
+	u64 at_vaddr;
+	struct xpmem_thread_group *ap_tg;
+	struct xpmem_thread_group *seg_tg;
+	struct xpmem_access_permit *ap;
+	struct xpmem_segment *seg;
+	struct xpmem_attachment *att;
+	struct vm_area_struct *vma;
+	struct vm_area_struct *seg_vma;
+
+
+	/*
+	 * The attachment's starting offset into the source segment must be
+	 * page aligned and the attachment must be a multiple of pages in size.
+	 */
+	if (offset_in_page(offset) != 0 || offset_in_page(size) != 0)
+		return -EINVAL;
+
+	/* ensure the requested attach point (i.e., vaddr) is valid */
+	if (vaddr && (offset_in_page(vaddr) != 0 || vaddr + size > TASK_SIZE))
+		return -EINVAL;
+
+	/*
+	 * Ensure threads doing GET space attachments are pinned, and set
+	 * prot_flags to read-only.
+	 *
+	 * raw_smp_processor_id() is called directly to avoid the debug info
+	 * generated by smp_processor_id() should CONFIG_DEBUG_PREEMPT be set
+	 * and the thread not be pinned to this CPU, a condition for which
+	 * we return an error anyways.
+	 */
+	if (att_flags & XPMEM_ATTACH_GETSPACE) {
+		cpumask_t this_cpu;
+
+		this_cpu = cpumask_of_cpu(raw_smp_processor_id());
+
+		if (!cpus_equal(current->cpus_allowed, this_cpu))
+			return -EINVAL;
+
+		prot_flags = PROT_READ;
+	}
+
+	ap_tg = xpmem_tg_ref_by_apid(apid);
+	if (IS_ERR(ap_tg))
+		return PTR_ERR(ap_tg);
+
+	ap = xpmem_ap_ref_by_apid(ap_tg, apid);
+	if (IS_ERR(ap)) {
+		ret = PTR_ERR(ap);
+		goto out_1;
+	}
+
+	seg = ap->seg;
+	xpmem_seg_ref(seg);
+	seg_tg = seg->tg;
+	xpmem_tg_ref(seg_tg);
+
+	ret = xpmem_seg_down_read(seg_tg, seg, 0, 1);
+	if (ret != 0)
+		goto out_2;
+
+	seg_vaddr = xpmem_get_seg_vaddr(ap, offset, size, XPMEM_RDWR);
+	if (IS_ERR_VALUE(seg_vaddr)) {
+		ret = seg_vaddr;
+		goto out_3;
+	}
+
+	/*
+	 * Ensure thread is not attempting to attach its own memory on top
+	 * of itself (i.e. ensure the destination vaddr range doesn't overlap
+	 * the source vaddr range).
+	 */
+	if (current->tgid == seg_tg->tgid &&
+	    vaddr && (vaddr + size > seg_vaddr) && (vaddr < seg_vaddr + size)) {
+		ret = -EINVAL;
+		goto out_3;
+	}
+
+	/* source segment resides on this partition */
+	down_read(&seg_tg->mm->mmap_sem);
+	seg_vma = find_vma(seg_tg->mm, seg_vaddr);
+	if (seg_vma && seg_vma->vm_start <= seg_vaddr)
+		vm_pfnmap = (seg_vma->vm_flags & VM_PFNMAP);
+	up_read(&seg_tg->mm->mmap_sem);
+
+	/* create new attach structure */
+	att = kzalloc(sizeof(struct xpmem_attachment), GFP_KERNEL);
+	if (att == NULL) {
+		ret = -ENOMEM;
+		goto out_3;
+	}
+
+	mutex_init(&att->mutex);
+	att->offset = offset;
+	att->at_size = size;
+	att->flags |= (att_flags | XPMEM_FLAG_CREATING);
+	att->ap = ap;
+	INIT_LIST_HEAD(&att->att_list);
+	att->mm = current->mm;
+        init_waitqueue_head(&att->destroyed_wq);
+
+	xpmem_att_not_destroyable(att);
+	xpmem_att_ref(att);
+
+	/* must lock mmap_sem before att's sema to prevent deadlock */
+	down_write(&current->mm->mmap_sem);
+	mutex_lock(&att->mutex);	/* this will never block */
+
+	/* link attach structure to its access permit's att list */
+	spin_lock(&ap->lock);
+	list_add_tail(&att->att_list, &ap->att_list);
+	if (ap->flags & XPMEM_FLAG_DESTROYING) {
+		spin_unlock(&ap->lock);
+		ret = -ENOENT;
+		goto out_4;
+	}
+	spin_unlock(&ap->lock);
+
+	flags = MAP_SHARED;
+	if (vaddr)
+		flags |= MAP_FIXED;
+
+	/* check if a segment is already attached in the requested area */
+	if (flags & MAP_FIXED) {
+		struct vm_area_struct *existing_vma;
+
+		existing_vma = find_vma_intersection(current->mm, vaddr,
+						     vaddr + size);
+		if (existing_vma && xpmem_is_vm_ops_set(existing_vma)) {
+			ret = -ENOMEM;
+			goto out_4;
+		}
+	}
+
+	at_vaddr = do_mmap(file, vaddr, size, prot_flags, flags, offset);
+	if (IS_ERR_VALUE(at_vaddr)) {
+		ret = at_vaddr;
+		goto out_4;
+	}
+	att->at_vaddr = at_vaddr;
+	att->flags &= ~XPMEM_FLAG_CREATING;
+
+	vma = find_vma(current->mm, at_vaddr);
+	vma->vm_private_data = att;
+	vma->vm_flags |=
+	    VM_DONTCOPY | VM_RESERVED | VM_IO | VM_DONTEXPAND | vm_pfnmap;
+	if (vma->vm_flags & VM_PFNMAP) {
+		vma->vm_ops = &xpmem_vm_ops_nopfn;
+		vma->vm_flags &= ~VM_CAN_NONLINEAR;
+	}
+
+	*at_vaddr_p = at_vaddr;
+
+out_4:
+	if (ret != 0) {
+		xpmem_att_set_destroying(att);
+		spin_lock(&ap->lock);
+		list_del_init(&att->att_list);
+		spin_unlock(&ap->lock);
+		xpmem_att_set_destroyed(att);
+		xpmem_att_destroyable(att);
+	}
+	mutex_unlock(&att->mutex);
+	up_write(&current->mm->mmap_sem);
+	xpmem_att_deref(att);
+out_3:
+	xpmem_seg_up_read(seg_tg, seg, 0);
+out_2:
+	xpmem_seg_deref(seg);
+	xpmem_tg_deref(seg_tg);
+	xpmem_ap_deref(ap);
+out_1:
+	xpmem_tg_deref(ap_tg);
+	return ret;
+}
+
+/*
+ * Detach an attached XPMEM address segment.
+ */
+int
+xpmem_detach(u64 at_vaddr)
+{
+	int ret = 0;
+	struct xpmem_access_permit *ap;
+	struct xpmem_attachment *att;
+	struct vm_area_struct *vma;
+	sigset_t oldset;
+
+	down_write(&current->mm->mmap_sem);
+
+	/* find the corresponding vma */
+	vma = find_vma(current->mm, at_vaddr);
+	if (!vma || vma->vm_start > at_vaddr) {
+		ret = -ENOENT;
+		goto out_1;
+	}
+
+	att = vma->vm_private_data;
+	if (!xpmem_is_vm_ops_set(vma) || att == NULL) {
+		ret = -EINVAL;
+		goto out_1;
+	}
+	xpmem_att_ref(att);
+
+	xpmem_block_nonfatal_signals(&oldset);
+	if (mutex_lock_interruptible(&att->mutex)) {
+		xpmem_unblock_nonfatal_signals(&oldset);
+		ret = -EINTR;
+		goto out_2;
+	}
+	xpmem_unblock_nonfatal_signals(&oldset);
+
+	if (att->flags & XPMEM_FLAG_DESTROYING)
+		goto out_3;
+	xpmem_att_set_destroying(att);
+
+	ap = att->ap;
+	xpmem_ap_ref(ap);
+
+	if (current->tgid != ap->tg->tgid) {
+		xpmem_att_clear_destroying(att);
+		ret = -EACCES;
+		goto out_4;
+	}
+
+	vma->vm_private_data = NULL;
+
+	ret = do_munmap(current->mm, vma->vm_start, att->at_size);
+	DBUG_ON(ret != 0);
+
+	att->flags &= ~XPMEM_FLAG_VALIDPTES;
+
+	spin_lock(&ap->lock);
+	list_del_init(&att->att_list);
+	spin_unlock(&ap->lock);
+
+	xpmem_att_set_destroyed(att);
+	xpmem_att_destroyable(att);
+
+out_4:
+	xpmem_ap_deref(ap);
+out_3:
+	mutex_unlock(&att->mutex);
+out_2:
+	xpmem_att_deref(att);
+out_1:
+	up_write(&current->mm->mmap_sem);
+	return ret;
+}
+
+/*
+ * Detach an attached XPMEM address segment. This is functionally identical
+ * to xpmem_detach(). It is called when ap and att are known.
+ */
+void
+xpmem_detach_att(struct xpmem_access_permit *ap, struct xpmem_attachment *att)
+{
+	struct vm_area_struct *vma;
+	int ret;
+
+	/* must lock mmap_sem before att's sema to prevent deadlock */
+	down_write(&att->mm->mmap_sem);
+	mutex_lock(&att->mutex);
+
+	if (att->flags & XPMEM_FLAG_DESTROYING)
+		goto out;
+
+	xpmem_att_set_destroying(att);
+
+	/* find the corresponding vma */
+	vma = find_vma(att->mm, att->at_vaddr);
+	if (!vma || vma->vm_start > att->at_vaddr)
+		goto out;
+
+	DBUG_ON(!xpmem_is_vm_ops_set(vma));
+	DBUG_ON((vma->vm_end - vma->vm_start) != att->at_size);
+	DBUG_ON(vma->vm_private_data != att);
+
+	vma->vm_private_data = NULL;
+
+	if (!(current->flags & PF_EXITING)) {
+		ret = do_munmap(att->mm, vma->vm_start, att->at_size);
+		DBUG_ON(ret != 0);
+	}
+
+	att->flags &= ~XPMEM_FLAG_VALIDPTES;
+
+	spin_lock(&ap->lock);
+	list_del_init(&att->att_list);
+	spin_unlock(&ap->lock);
+
+	xpmem_att_set_destroyed(att);
+	xpmem_att_destroyable(att);
+
+out:
+	mutex_unlock(&att->mutex);
+	up_write(&att->mm->mmap_sem);
+}
+
+/*
+ * Clear all of the PTEs associated with the specified attachment.
+ */
+static void
+xpmem_clear_PTEs_of_att(struct xpmem_attachment *att, u64 vaddr, size_t size)
+{
+	if (att->flags & XPMEM_FLAG_DESTROYING)
+		xpmem_att_wait_destroyed(att);
+
+	if (att->flags & XPMEM_FLAG_DESTROYED)
+		return;
+
+	/* must lock mmap_sem before att's sema to prevent deadlock */
+	down_read(&att->mm->mmap_sem);
+	mutex_lock(&att->mutex);
+
+	/*
+	 * The att may have been detached before the down() succeeded.
+	 * If not, clear kernel PTEs, flush TLBs, etc.
+	 */
+	if (att->flags & XPMEM_FLAG_VALIDPTES) {
+		struct vm_area_struct *vma;
+
+		vma = find_vma(att->mm, vaddr);
+		zap_page_range(vma, vaddr, size, NULL);
+		att->flags &= ~XPMEM_FLAG_VALIDPTES;
+	}
+
+	mutex_unlock(&att->mutex);
+	up_read(&att->mm->mmap_sem);
+}
+
+/*
+ * Clear all of the PTEs associated with all attachments related to the
+ * specified access permit.
+ */
+static void
+xpmem_clear_PTEs_of_ap(struct xpmem_access_permit *ap, u64 seg_offset,
+		       size_t size)
+{
+	struct xpmem_attachment *att;
+	u64 t_vaddr;
+	size_t t_size;
+
+	spin_lock(&ap->lock);
+	list_for_each_entry(att, &ap->att_list, att_list) {
+		if (!(att->flags & XPMEM_FLAG_VALIDPTES))
+			continue;
+
+		t_vaddr = att->at_vaddr + seg_offset - att->offset,
+		t_size = size;
+		if (!xpmem_get_overlapping_range(att->at_vaddr, att->at_size,
+		    &t_vaddr, &t_size))
+			continue;
+
+		xpmem_att_ref(att);  /* don't care if XPMEM_FLAG_DESTROYING */
+		spin_unlock(&ap->lock);
+
+		xpmem_clear_PTEs_of_att(att, t_vaddr, t_size);
+
+		spin_lock(&ap->lock);
+		if (list_empty(&att->att_list)) {
+			/* att was deleted from ap->att_list, start over */
+			xpmem_att_deref(att);
+			att = list_entry(&ap->att_list, struct xpmem_attachment,
+					 att_list);
+		} else
+			xpmem_att_deref(att);
+	}
+	spin_unlock(&ap->lock);
+}
+
+/*
+ * Clear all of the PTEs associated with all attaches to the specified segment.
+ */
+void
+xpmem_clear_PTEs(struct xpmem_segment *seg, u64 vaddr, size_t size)
+{
+	struct xpmem_access_permit *ap;
+	u64 seg_offset = vaddr - seg->vaddr;
+
+	spin_lock(&seg->lock);
+	list_for_each_entry(ap, &seg->ap_list, ap_list) {
+		xpmem_ap_ref(ap);  /* don't care if XPMEM_FLAG_DESTROYING */
+		spin_unlock(&seg->lock);
+
+		xpmem_clear_PTEs_of_ap(ap, seg_offset, size);
+
+		spin_lock(&seg->lock);
+		if (list_empty(&ap->ap_list)) {
+			/* ap was deleted from seg->ap_list, start over */
+			xpmem_ap_deref(ap);
+			ap = list_entry(&seg->ap_list,
+					 struct xpmem_access_permit, ap_list);
+		} else
+			xpmem_ap_deref(ap);
+	}
+	spin_unlock(&seg->lock);
+}
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_get.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_get.c	2008-04-01 10:42:33.189780844 -0500
@@ -0,0 +1,343 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) get access support.
+ */
+
+#include <linux/err.h>
+#include <linux/mm.h>
+#include <linux/stat.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/*
+ * This is the kernel's IPC permission checking function without calls to
+ * do any extra security checks. See ipc/util.c for the original source.
+ */
+static int
+xpmem_ipcperms(struct kern_ipc_perm *ipcp, short flag)
+{
+	int requested_mode;
+	int granted_mode;
+
+	requested_mode = (flag >> 6) | (flag >> 3) | flag;
+	granted_mode = ipcp->mode;
+	if (current->euid == ipcp->cuid || current->euid == ipcp->uid)
+		granted_mode >>= 6;
+	else if (in_group_p(ipcp->cgid) || in_group_p(ipcp->gid))
+		granted_mode >>= 3;
+	/* is there some bit set in requested_mode but not in granted_mode? */
+	if ((requested_mode & ~granted_mode & 0007) && !capable(CAP_IPC_OWNER))
+		return -1;
+
+	return 0;
+}
+
+/*
+ * Ensure that the user is actually allowed to access the segment.
+ */
+static int
+xpmem_check_permit_mode(int flags, struct xpmem_segment *seg)
+{
+	struct kern_ipc_perm perm;
+	int ret;
+
+	DBUG_ON(seg->permit_type != XPMEM_PERMIT_MODE);
+
+	memset(&perm, 0, sizeof(struct kern_ipc_perm));
+	perm.uid = seg->tg->uid;
+	perm.gid = seg->tg->gid;
+	perm.cuid = seg->tg->uid;
+	perm.cgid = seg->tg->gid;
+	perm.mode = (u64)seg->permit_value;
+
+	ret = xpmem_ipcperms(&perm, S_IRUSR);
+	if (ret == 0 && (flags & XPMEM_RDWR))
+		ret = xpmem_ipcperms(&perm, S_IWUSR);
+
+	return ret;
+}
+
+/*
+ * Create a new and unique apid.
+ */
+static __s64
+xpmem_make_apid(struct xpmem_thread_group *ap_tg)
+{
+	struct xpmem_id apid;
+	__s64 *apid_p = (__s64 *)&apid;
+	int uniq;
+
+	DBUG_ON(sizeof(struct xpmem_id) != sizeof(__s64));
+	DBUG_ON(ap_tg->partid < 0 || ap_tg->partid >= XP_MAX_PARTITIONS);
+
+	uniq = atomic_inc_return(&ap_tg->uniq_apid);
+	if (uniq > XPMEM_MAX_UNIQ_ID) {
+		atomic_dec(&ap_tg->uniq_apid);
+		return -EBUSY;
+	}
+
+	apid.tgid = ap_tg->tgid;
+	apid.uniq = uniq;
+	apid.partid = ap_tg->partid;
+	return *apid_p;
+}
+
+/*
+ * Get permission to access a specified segid.
+ */
+int
+xpmem_get(__s64 segid, int flags, int permit_type, void *permit_value,
+	  __s64 *apid_p)
+{
+	__s64 apid;
+	struct xpmem_access_permit *ap;
+	struct xpmem_segment *seg;
+	struct xpmem_thread_group *ap_tg;
+	struct xpmem_thread_group *seg_tg;
+	int index;
+	int ret = 0;
+
+	if ((flags & ~(XPMEM_RDONLY | XPMEM_RDWR)) ||
+	    (flags & (XPMEM_RDONLY | XPMEM_RDWR)) ==
+	    (XPMEM_RDONLY | XPMEM_RDWR))
+		return -EINVAL;
+
+	if (permit_type != XPMEM_PERMIT_MODE || permit_value != NULL)
+		return -EINVAL;
+
+	ap_tg = xpmem_tg_ref_by_tgid(xpmem_my_part, current->tgid);
+	if (IS_ERR(ap_tg)) {
+		DBUG_ON(PTR_ERR(ap_tg) != -ENOENT);
+		return -XPMEM_ERRNO_NOPROC;
+	}
+
+	seg_tg = xpmem_tg_ref_by_segid(segid);
+	if (IS_ERR(seg_tg)) {
+		if (PTR_ERR(seg_tg) != -EREMOTE) {
+			ret = PTR_ERR(seg_tg);
+			goto out_1;
+		}
+
+		ret = -ENOENT;
+		goto out_1;
+	} else {
+		seg = xpmem_seg_ref_by_segid(seg_tg, segid);
+		if (IS_ERR(seg)) {
+			if (PTR_ERR(seg) != -EREMOTE) {
+				ret = PTR_ERR(seg);
+				goto out_2;
+			}
+			ret = -ENOENT;
+			goto out_2;
+		} else {
+			/* wait for proxy seg's creation to be complete */
+			wait_event(seg->created_wq,
+				   ((!(seg->flags & XPMEM_FLAG_CREATING)) ||
+				    (seg->flags & XPMEM_FLAG_DESTROYING)));
+			if (seg->flags & XPMEM_FLAG_DESTROYING) {
+				ret = -ENOENT;
+				goto out_3;
+			}
+		}
+	}
+
+	/* assuming XPMEM_PERMIT_MODE, do the appropriate permission check */
+	if (xpmem_check_permit_mode(flags, seg) != 0) {
+		ret = -EACCES;
+		goto out_3;
+	}
+
+	/* create a new xpmem_access_permit structure with a unique apid */
+
+	apid = xpmem_make_apid(ap_tg);
+	if (apid < 0) {
+		ret = apid;
+		goto out_3;
+	}
+
+	ap = kzalloc(sizeof(struct xpmem_access_permit), GFP_KERNEL);
+	if (ap == NULL) {
+		ret = -ENOMEM;
+		goto out_3;
+	}
+
+	spin_lock_init(&ap->lock);
+	ap->seg = seg;
+	ap->tg = ap_tg;
+	ap->apid = apid;
+	ap->mode = flags;
+	INIT_LIST_HEAD(&ap->att_list);
+	INIT_LIST_HEAD(&ap->ap_list);
+	INIT_LIST_HEAD(&ap->ap_hashlist);
+
+	xpmem_ap_not_destroyable(ap);
+
+	/* add ap to its seg's access permit list */
+	spin_lock(&seg->lock);
+	list_add_tail(&ap->ap_list, &seg->ap_list);
+	spin_unlock(&seg->lock);
+
+	/* add ap to its hash list */
+	index = xpmem_ap_hashtable_index(ap->apid);
+	write_lock(&ap_tg->ap_hashtable[index].lock);
+	list_add_tail(&ap->ap_hashlist, &ap_tg->ap_hashtable[index].list);
+	write_unlock(&ap_tg->ap_hashtable[index].lock);
+
+	*apid_p = apid;
+
+	/*
+	 * The following two derefs aren't being done at this time in order
+	 * to prevent the seg and seg_tg structures from being prematurely
+	 * kfree'd as long as the potential for them to be referenced via
+	 * this ap structure exists.
+	 *
+	 *      xpmem_seg_deref(seg);
+	 *      xpmem_tg_deref(seg_tg);
+	 *
+	 * These two derefs will be done by xpmem_release_ap() at the time
+	 * this ap structure is destroyed.
+	 */
+	goto out_1;
+
+out_3:
+	xpmem_seg_deref(seg);
+out_2:
+	xpmem_tg_deref(seg_tg);
+out_1:
+	xpmem_tg_deref(ap_tg);
+	return ret;
+}
+
+/*
+ * Release an access permit and detach all associated attaches.
+ */
+static void
+xpmem_release_ap(struct xpmem_thread_group *ap_tg,
+		  struct xpmem_access_permit *ap)
+{
+	int index;
+	struct xpmem_thread_group *seg_tg;
+	struct xpmem_attachment *att;
+	struct xpmem_segment *seg;
+
+	spin_lock(&ap->lock);
+	if (ap->flags & XPMEM_FLAG_DESTROYING) {
+		spin_unlock(&ap->lock);
+		return;
+	}
+	ap->flags |= XPMEM_FLAG_DESTROYING;
+
+	/* deal with all attaches first */
+	while (!list_empty(&ap->att_list)) {
+		att = list_entry((&ap->att_list)->next, struct xpmem_attachment,
+				 att_list);
+		xpmem_att_ref(att);
+		spin_unlock(&ap->lock);
+		xpmem_detach_att(ap, att);
+		DBUG_ON(atomic_read(&att->mm->mm_users) <= 0);
+		DBUG_ON(atomic_read(&att->mm->mm_count) <= 0);
+		xpmem_att_deref(att);
+		spin_lock(&ap->lock);
+	}
+	ap->flags |= XPMEM_FLAG_DESTROYED;
+	spin_unlock(&ap->lock);
+
+	/*
+	 * Remove access structure from its hash list.
+	 * This is done after the xpmem_detach_att to prevent any racing
+	 * thread from looking up access permits for the owning thread group
+	 * and not finding anything, assuming everything is clean, and
+	 * freeing the mm before xpmem_detach_att has a chance to
+	 * use it.
+	 */
+	index = xpmem_ap_hashtable_index(ap->apid);
+	write_lock(&ap_tg->ap_hashtable[index].lock);
+	list_del_init(&ap->ap_hashlist);
+	write_unlock(&ap_tg->ap_hashtable[index].lock);
+
+	/* the ap's seg and the seg's tg were ref'd in xpmem_get() */
+	seg = ap->seg;
+	seg_tg = seg->tg;
+
+	/* remove ap from its seg's access permit list */
+	spin_lock(&seg->lock);
+	list_del_init(&ap->ap_list);
+	spin_unlock(&seg->lock);
+
+	xpmem_seg_deref(seg);	/* deref of xpmem_get()'s ref */
+	xpmem_tg_deref(seg_tg);	/* deref of xpmem_get()'s ref */
+
+	xpmem_ap_destroyable(ap);
+}
+
+/*
+ * Release all access permits and detach all associated attaches for the given
+ * thread group.
+ */
+void
+xpmem_release_aps_of_tg(struct xpmem_thread_group *ap_tg)
+{
+	struct xpmem_hashlist *hashlist;
+	struct xpmem_access_permit *ap;
+	int index;
+
+	for (index = 0; index < XPMEM_AP_HASHTABLE_SIZE; index++) {
+		hashlist = &ap_tg->ap_hashtable[index];
+
+		read_lock(&hashlist->lock);
+		while (!list_empty(&hashlist->list)) {
+			ap = list_entry((&hashlist->list)->next,
+					struct xpmem_access_permit,
+					ap_hashlist);
+			xpmem_ap_ref(ap);
+			read_unlock(&hashlist->lock);
+
+			xpmem_release_ap(ap_tg, ap);
+
+			xpmem_ap_deref(ap);
+			read_lock(&hashlist->lock);
+		}
+		read_unlock(&hashlist->lock);
+	}
+}
+
+/*
+ * Release an access permit for a XPMEM address segment.
+ */
+int
+xpmem_release(__s64 apid)
+{
+	struct xpmem_thread_group *ap_tg;
+	struct xpmem_access_permit *ap;
+	int ret = 0;
+
+	ap_tg = xpmem_tg_ref_by_apid(apid);
+	if (IS_ERR(ap_tg))
+		return PTR_ERR(ap_tg);
+
+	if (current->tgid != ap_tg->tgid) {
+		ret = -EACCES;
+		goto out;
+	}
+
+	ap = xpmem_ap_ref_by_apid(ap_tg, apid);
+	if (IS_ERR(ap)) {
+		ret = PTR_ERR(ap);
+		goto out;
+	}
+	DBUG_ON(ap->tg != ap_tg);
+
+	xpmem_release_ap(ap_tg, ap);
+
+	xpmem_ap_deref(ap);
+out:
+	xpmem_tg_deref(ap_tg);
+	return ret;
+}
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_main.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_main.c	2008-04-01 10:42:33.065765549 -0500
@@ -0,0 +1,440 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) support.
+ *
+ * This module (along with a corresponding library) provides support for
+ * cross-partition shared memory between threads.
+ *
+ * Caveats
+ *
+ *   * XPMEM cannot allocate VM_IO pages on behalf of another thread group
+ *     since get_user_pages() doesn't handle VM_IO pages. This is normally
+ *     valid if a thread group attaches a portion of an address space and is
+ *     the first to touch that portion. In addition, any pages which come from
+ *     the "low granule" such as fetchops, pages for cross-coherence
+ *     write-combining, etc. also are impossible since the kernel will try
+ *     to find a struct page which will not exist.
+ */
+
+#include <linux/device.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/miscdevice.h>
+#include <linux/mm.h>
+#include <linux/file.h>
+#include <linux/err.h>
+#include <linux/proc_fs.h>
+#include <linux/uaccess.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/* define the XPMEM debug device structure to be used with dev_dbg() et al */
+
+static struct device_driver xpmem_dbg_name = {
+	.name = "xpmem"
+};
+
+static struct device xpmem_dbg_subname = {
+	.bus_id = {0},		/* set to "" */
+	.driver = &xpmem_dbg_name
+};
+
+struct device *xpmem = &xpmem_dbg_subname;
+
+/* array of partitions indexed by partid */
+struct xpmem_partition *xpmem_partitions;
+
+struct xpmem_partition *xpmem_my_part;	/* pointer to this partition */
+short xpmem_my_partid;		/* this partition's ID */
+
+/*
+ * User open of the XPMEM driver. Called whenever /dev/xpmem is opened.
+ * Create a struct xpmem_thread_group structure for the specified thread group.
+ * And add the structure to the tg hash table.
+ */
+static int
+xpmem_open(struct inode *inode, struct file *file)
+{
+	struct xpmem_thread_group *tg;
+	int index;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *unpin_entry;
+	char tgid_string[XPMEM_TGID_STRING_LEN];
+#endif /* CONFIG_PROC_FS */
+
+	/* if this has already been done, just return silently */
+	tg = xpmem_tg_ref_by_tgid(xpmem_my_part, current->tgid);
+	if (!IS_ERR(tg)) {
+		xpmem_tg_deref(tg);
+		return 0;
+	}
+
+	/* create tg */
+	tg = kzalloc(sizeof(struct xpmem_thread_group), GFP_KERNEL);
+	if (tg == NULL)
+		return -ENOMEM;
+
+	spin_lock_init(&tg->lock);
+	tg->partid = xpmem_my_partid;
+	tg->tgid = current->tgid;
+	tg->uid = current->uid;
+	tg->gid = current->gid;
+	atomic_set(&tg->uniq_segid, 0);
+	atomic_set(&tg->uniq_apid, 0);
+	atomic_set(&tg->n_pinned, 0);
+	tg->addr_limit = TASK_SIZE;
+	tg->seg_list_lock = RW_LOCK_UNLOCKED;
+	INIT_LIST_HEAD(&tg->seg_list);
+	INIT_LIST_HEAD(&tg->tg_hashlist);
+	atomic_set(&tg->n_recall_PFNs, 0);
+	mutex_init(&tg->recall_PFNs_mutex);
+	init_waitqueue_head(&tg->block_recall_PFNs_wq);
+	init_waitqueue_head(&tg->allow_recall_PFNs_wq);
+	tg->emm_notifier.callback = &xpmem_emm_notifier_callback;
+	spin_lock_init(&tg->page_requests_lock);
+	INIT_LIST_HEAD(&tg->page_requests);
+
+	/* create and initialize struct xpmem_access_permit hashtable */
+	tg->ap_hashtable = kzalloc(sizeof(struct xpmem_hashlist) *
+				     XPMEM_AP_HASHTABLE_SIZE, GFP_KERNEL);
+	if (tg->ap_hashtable == NULL) {
+		kfree(tg);
+		return -ENOMEM;
+	}
+	for (index = 0; index < XPMEM_AP_HASHTABLE_SIZE; index++) {
+		tg->ap_hashtable[index].lock = RW_LOCK_UNLOCKED;
+		INIT_LIST_HEAD(&tg->ap_hashtable[index].list);
+	}
+
+#ifdef CONFIG_PROC_FS
+	snprintf(tgid_string, XPMEM_TGID_STRING_LEN, "%d", current->tgid);
+	spin_lock(&xpmem_unpin_procfs_lock);
+	unpin_entry = create_proc_entry(tgid_string, 0644,
+					xpmem_unpin_procfs_dir);
+	spin_unlock(&xpmem_unpin_procfs_lock);
+	if (unpin_entry != NULL) {
+		unpin_entry->data = (void *)(unsigned long)current->tgid;
+		unpin_entry->write_proc = xpmem_unpin_procfs_write;
+		unpin_entry->read_proc = xpmem_unpin_procfs_read;
+		unpin_entry->owner = THIS_MODULE;
+		unpin_entry->uid = current->uid;
+		unpin_entry->gid = current->gid;
+	}
+#endif /* CONFIG_PROC_FS */
+
+	xpmem_tg_not_destroyable(tg);
+
+	/* add tg to its hash list */
+	index = xpmem_tg_hashtable_index(tg->tgid);
+	write_lock(&xpmem_my_part->tg_hashtable[index].lock);
+	list_add_tail(&tg->tg_hashlist,
+		      &xpmem_my_part->tg_hashtable[index].list);
+	write_unlock(&xpmem_my_part->tg_hashtable[index].lock);
+
+	/*
+	 * Increment 'mm->mm_users' for the current task's thread group leader.
+	 * This ensures that its mm_struct will still be around when our
+	 * thread group exits. (The Linux kernel normally tears down the
+	 * mm_struct prior to calling a module's 'flush' function.) Since all
+	 * XPMEM thread groups must go through this path, this extra reference
+	 * to mm_users also allows us to directly inc/dec mm_users in
+	 * xpmem_ensure_valid_PFNs() and avoid mmput() which has a scaling
+	 * issue with the mmlist_lock. Being a thread group leader guarantees
+	 * that the thread group leader's task_struct will still be around.
+	 */
+//>>> with the mm_users being bumped here do we even need to inc/dec mm_users
+//>>> in xpmem_ensure_valid_PFNs()?
+//>>>	get_task_struct(current->group_leader);
+	tg->group_leader = current->group_leader;
+
+	BUG_ON(current->mm != current->group_leader->mm);
+//>>>	atomic_inc(&current->group_leader->mm->mm_users);
+	tg->mm = current->group_leader->mm;
+
+	return 0;
+}
+
+/*
+ * The following function gets called whenever a thread group that has opened
+ * /dev/xpmem closes it.
+ */
+static int
+//>>> do we get rid of this function???
+xpmem_flush(struct file *file, fl_owner_t owner)
+{
+	struct xpmem_thread_group *tg;
+	int index;
+
+	tg = xpmem_tg_ref_by_tgid(xpmem_my_part, current->tgid);
+	if (IS_ERR(tg))
+		return 0;  /* probably child process who inherited fd */
+
+	spin_lock(&tg->lock);
+	if (tg->flags & XPMEM_FLAG_DESTROYING) {
+		spin_unlock(&tg->lock);
+		xpmem_tg_deref(tg);
+		return -EALREADY;
+	}
+	tg->flags |= XPMEM_FLAG_DESTROYING;
+	spin_unlock(&tg->lock);
+
+	xpmem_release_aps_of_tg(tg);
+	xpmem_remove_segs_of_tg(tg);
+
+	/*
+	 * At this point, XPMEM no longer needs to reference the thread group
+	 * leader's mm_struct. Decrement its 'mm->mm_users' to account for the
+	 * extra increment previously done in xpmem_open().
+	 */
+//>>>	mmput(tg->mm);
+//>>>	put_task_struct(tg->group_leader);
+
+	/* Remove tg structure from its hash list */
+	index = xpmem_tg_hashtable_index(tg->tgid);
+	write_lock(&xpmem_my_part->tg_hashtable[index].lock);
+	list_del_init(&tg->tg_hashlist);
+	write_unlock(&xpmem_my_part->tg_hashtable[index].lock);
+
+	xpmem_tg_destroyable(tg);
+	xpmem_tg_deref(tg);
+
+	return 0;
+}
+
+/*
+ * User ioctl to the XPMEM driver. Only 64-bit user applications are
+ * supported.
+ */
+static long
+xpmem_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
+{
+	struct xpmem_cmd_make make_info;
+	struct xpmem_cmd_remove remove_info;
+	struct xpmem_cmd_get get_info;
+	struct xpmem_cmd_release release_info;
+	struct xpmem_cmd_attach attach_info;
+	struct xpmem_cmd_detach detach_info;
+	__s64 segid;
+	__s64 apid;
+	u64 at_vaddr;
+	long ret;
+
+	switch (cmd) {
+	case XPMEM_CMD_VERSION:
+		return XPMEM_CURRENT_VERSION;
+
+	case XPMEM_CMD_MAKE:
+		if (copy_from_user(&make_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_make)))
+			return -EFAULT;
+
+		ret = xpmem_make(make_info.vaddr, make_info.size,
+				 make_info.permit_type,
+				 (void *)make_info.permit_value, &segid);
+		if (ret != 0)
+			return ret;
+
+		if (put_user(segid,
+			     &((struct xpmem_cmd_make __user *)arg)->segid)) {
+			(void)xpmem_remove(segid);
+			return -EFAULT;
+		}
+		return 0;
+
+	case XPMEM_CMD_REMOVE:
+		if (copy_from_user(&remove_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_remove)))
+			return -EFAULT;
+
+		return xpmem_remove(remove_info.segid);
+
+	case XPMEM_CMD_GET:
+		if (copy_from_user(&get_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_get)))
+			return -EFAULT;
+
+		ret = xpmem_get(get_info.segid, get_info.flags,
+				get_info.permit_type,
+				(void *)get_info.permit_value, &apid);
+		if (ret != 0)
+			return ret;
+
+		if (put_user(apid,
+			     &((struct xpmem_cmd_get __user *)arg)->apid)) {
+			(void)xpmem_release(apid);
+			return -EFAULT;
+		}
+		return 0;
+
+	case XPMEM_CMD_RELEASE:
+		if (copy_from_user(&release_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_release)))
+			return -EFAULT;
+
+		return xpmem_release(release_info.apid);
+
+	case XPMEM_CMD_ATTACH:
+		if (copy_from_user(&attach_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_attach)))
+			return -EFAULT;
+
+		ret = xpmem_attach(file, attach_info.apid, attach_info.offset,
+				   attach_info.size, attach_info.vaddr,
+				   attach_info.fd, attach_info.flags,
+				   &at_vaddr);
+		if (ret != 0)
+			return ret;
+
+		if (put_user(at_vaddr,
+			     &((struct xpmem_cmd_attach __user *)arg)->vaddr)) {
+			(void)xpmem_detach(at_vaddr);
+			return -EFAULT;
+		}
+		return 0;
+
+	case XPMEM_CMD_DETACH:
+		if (copy_from_user(&detach_info, (void __user *)arg,
+				   sizeof(struct xpmem_cmd_detach)))
+			return -EFAULT;
+
+		return xpmem_detach(detach_info.vaddr);
+
+	default:
+		break;
+	}
+	return -ENOIOCTLCMD;
+}
+
+static struct file_operations xpmem_fops = {
+	.owner = THIS_MODULE,
+	.open = xpmem_open,
+	.flush = xpmem_flush,
+	.unlocked_ioctl = xpmem_ioctl,
+	.mmap = xpmem_mmap
+};
+
+static struct miscdevice xpmem_dev_handle = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name = XPMEM_MODULE_NAME,
+	.fops = &xpmem_fops
+};
+
+/*
+ * Initialize the XPMEM driver.
+ */
+int __init
+xpmem_init(void)
+{
+	int i;
+	int ret;
+	struct xpmem_hashlist *hashtable;
+
+	xpmem_my_partid = sn_partition_id;
+	if (xpmem_my_partid >= XP_MAX_PARTITIONS) {
+		dev_err(xpmem, "invalid partition ID, XPMEM driver failed to "
+			"initialize\n");
+		return -EINVAL;
+	}
+
+	/* create and initialize struct xpmem_partition array */
+	xpmem_partitions = kzalloc(sizeof(struct xpmem_partition) *
+				   XP_MAX_PARTITIONS, GFP_KERNEL);
+	if (xpmem_partitions == NULL)
+		return -ENOMEM;
+
+	xpmem_my_part = &xpmem_partitions[xpmem_my_partid];
+	for (i = 0; i < XP_MAX_PARTITIONS; i++) {
+		xpmem_partitions[i].flags |=
+		    (XPMEM_FLAG_UNINITIALIZED | XPMEM_FLAG_DOWN);
+		spin_lock_init(&xpmem_partitions[i].lock);
+		xpmem_partitions[i].version = -1;
+		xpmem_partitions[i].coherence_id = -1;
+		atomic_set(&xpmem_partitions[i].n_threads, 0);
+		init_waitqueue_head(&xpmem_partitions[i].thread_wq);
+	}
+
+#ifdef CONFIG_PROC_FS
+	/* create the /proc interface directory (/proc/xpmem) */
+	xpmem_unpin_procfs_dir = proc_mkdir(XPMEM_MODULE_NAME, NULL);
+	if (xpmem_unpin_procfs_dir == NULL) {
+		ret = -EBUSY;
+		goto out_1;
+	}
+	xpmem_unpin_procfs_dir->owner = THIS_MODULE;
+#endif /* CONFIG_PROC_FS */
+
+	/* create the XPMEM character device (/dev/xpmem) */
+	ret = misc_register(&xpmem_dev_handle);
+	if (ret != 0)
+		goto out_2;
+
+	hashtable = kzalloc(sizeof(struct xpmem_hashlist) *
+			    XPMEM_TG_HASHTABLE_SIZE, GFP_KERNEL);
+	if (hashtable == NULL)
+		goto out_2;
+
+	for (i = 0; i < XPMEM_TG_HASHTABLE_SIZE; i++) {
+		hashtable[i].lock = RW_LOCK_UNLOCKED;
+		INIT_LIST_HEAD(&hashtable[i].list);
+	}
+
+	xpmem_my_part->tg_hashtable = hashtable;
+	xpmem_my_part->flags &= ~XPMEM_FLAG_UNINITIALIZED;
+	xpmem_my_part->version = XPMEM_CURRENT_VERSION;
+	xpmem_my_part->flags &= ~XPMEM_FLAG_DOWN;
+	xpmem_my_part->flags |= XPMEM_FLAG_UP;
+
+	dev_info(xpmem, "SGI XPMEM kernel module v%s loaded\n",
+		 XPMEM_CURRENT_VERSION_STRING);
+	return 0;
+
+	/* things didn't work out so well */
+out_2:
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry(XPMEM_MODULE_NAME, NULL);
+#endif /* CONFIG_PROC_FS */
+out_1:
+	kfree(xpmem_partitions);
+	return ret;
+}
+
+/*
+ * Remove the XPMEM driver from the system.
+ */
+void __exit
+xpmem_exit(void)
+{
+	int i;
+
+	for (i = 0; i < XP_MAX_PARTITIONS; i++) {
+		if (!(xpmem_partitions[i].flags & XPMEM_FLAG_UNINITIALIZED))
+			kfree(xpmem_partitions[i].tg_hashtable);
+	}
+
+	kfree(xpmem_partitions);
+
+	misc_deregister(&xpmem_dev_handle);
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry(XPMEM_MODULE_NAME, NULL);
+#endif /* CONFIG_PROC_FS */
+
+	dev_info(xpmem, "SGI XPMEM kernel module v%s unloaded\n",
+		 XPMEM_CURRENT_VERSION_STRING);
+}
+
+#ifdef EXPORT_NO_SYMBOLS
+EXPORT_NO_SYMBOLS;
+#endif
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Silicon Graphics, Inc.");
+MODULE_INFO(supported, "external");
+MODULE_DESCRIPTION("XPMEM support");
+module_init(xpmem_init);
+module_exit(xpmem_exit);
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_make.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_make.c	2008-04-01 10:42:33.141774923 -0500
@@ -0,0 +1,249 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) make segment support.
+ */
+
+#include <linux/err.h>
+#include <linux/mm.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/*
+ * Create a new and unique segid.
+ */
+static __s64
+xpmem_make_segid(struct xpmem_thread_group *seg_tg)
+{
+	struct xpmem_id segid;
+	__s64 *segid_p = (__s64 *)&segid;
+	int uniq;
+
+	DBUG_ON(sizeof(struct xpmem_id) != sizeof(__s64));
+	DBUG_ON(seg_tg->partid < 0 || seg_tg->partid >= XP_MAX_PARTITIONS);
+
+	uniq = atomic_inc_return(&seg_tg->uniq_segid);
+	if (uniq > XPMEM_MAX_UNIQ_ID) {
+		atomic_dec(&seg_tg->uniq_segid);
+		return -EBUSY;
+	}
+
+	segid.tgid = seg_tg->tgid;
+	segid.uniq = uniq;
+	segid.partid = seg_tg->partid;
+
+	DBUG_ON(*segid_p <= 0);
+	return *segid_p;
+}
+
+/*
+ * Make a segid and segment for the specified address segment.
+ */
+int
+xpmem_make(u64 vaddr, size_t size, int permit_type, void *permit_value,
+	   __s64 *segid_p)
+{
+	__s64 segid;
+	struct xpmem_thread_group *seg_tg;
+	struct xpmem_segment *seg;
+	int ret = 0;
+
+	if (permit_type != XPMEM_PERMIT_MODE ||
+	    ((u64)permit_value & ~00777) || size == 0)
+		return -EINVAL;
+
+	seg_tg = xpmem_tg_ref_by_tgid(xpmem_my_part, current->tgid);
+	if (IS_ERR(seg_tg)) {
+		DBUG_ON(PTR_ERR(seg_tg) != -ENOENT);
+		return -XPMEM_ERRNO_NOPROC;
+	}
+
+	if (vaddr + size > seg_tg->addr_limit) {
+		if (size != XPMEM_MAXADDR_SIZE) {
+			ret = -EINVAL;
+			goto out;
+		}
+		size = seg_tg->addr_limit - vaddr;
+	}
+
+	/*
+	 * The start of the segment must be page aligned and it must be a
+	 * multiple of pages in size.
+	 */
+	if (offset_in_page(vaddr) != 0 || offset_in_page(size) != 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	segid = xpmem_make_segid(seg_tg);
+	if (segid < 0) {
+		ret = segid;
+		goto out;
+	}
+
+	/* create a new struct xpmem_segment structure with a unique segid */
+	seg = kzalloc(sizeof(struct xpmem_segment), GFP_KERNEL);
+	if (seg == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock_init(&seg->lock);
+	init_rwsem(&seg->sema);
+	seg->segid = segid;
+	seg->vaddr = vaddr;
+	seg->size = size;
+	seg->permit_type = permit_type;
+	seg->permit_value = permit_value;
+	init_waitqueue_head(&seg->created_wq);	/* only used for proxy seg */
+	init_waitqueue_head(&seg->destroyed_wq);
+	seg->tg = seg_tg;
+	INIT_LIST_HEAD(&seg->ap_list);
+	INIT_LIST_HEAD(&seg->seg_list);
+
+	/* allocate PFN table (level 4 only) */
+	mutex_init(&seg->PFNtable_mutex);
+	seg->PFNtable = kzalloc(XPMEM_PFNTABLE_L4SIZE * sizeof(u64 ***),
+				GFP_KERNEL);
+	if (seg->PFNtable == NULL) {
+		kfree(seg);
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	xpmem_seg_not_destroyable(seg);
+
+	/*
+	 * Add seg to its tg's list of segs and register the tg's emm_notifier
+	 * if there are no previously existing segs for this thread group.
+	 */
+	write_lock(&seg_tg->seg_list_lock);
+	if (list_empty(&seg_tg->seg_list))
+		emm_notifier_register(&seg_tg->emm_notifier, seg_tg->mm);
+	list_add_tail(&seg->seg_list, &seg_tg->seg_list);
+	write_unlock(&seg_tg->seg_list_lock);
+
+	*segid_p = segid;
+
+out:
+	xpmem_tg_deref(seg_tg);
+	return ret;
+}
+
+/*
+ * Remove a segment from the system.
+ */
+static int
+xpmem_remove_seg(struct xpmem_thread_group *seg_tg, struct xpmem_segment *seg)
+{
+	DBUG_ON(atomic_read(&seg->refcnt) <= 0);
+
+	/* see if the requesting thread is the segment's owner */
+	if (current->tgid != seg_tg->tgid)
+		return -EACCES;
+
+	spin_lock(&seg->lock);
+	if (seg->flags & XPMEM_FLAG_DESTROYING) {
+		spin_unlock(&seg->lock);
+		return 0;
+	}
+	seg->flags |= XPMEM_FLAG_DESTROYING;
+	spin_unlock(&seg->lock);
+
+	xpmem_seg_down_write(seg);
+
+	/* clear all PTEs for each local attach to this segment, if any */
+	xpmem_clear_PTEs(seg, seg->vaddr, seg->size);
+
+	/* clear the seg's PFN table and unpin pages */
+	xpmem_clear_PFNtable(seg, seg->vaddr, seg->size, 1, 0);
+
+	/* indicate that the segment has been destroyed */
+	spin_lock(&seg->lock);
+	seg->flags |= XPMEM_FLAG_DESTROYED;
+	spin_unlock(&seg->lock);
+
+	/*
+	 * Remove seg from its tg's list of segs and unregister the tg's
+	 * emm_notifier if there are no other segs for this thread group and
+	 * the process is not in exit processsing (in which case the unregister
+	 * will be done automatically by emm_notifier_release()).
+	 */
+	write_lock(&seg_tg->seg_list_lock);
+	list_del_init(&seg->seg_list);
+// >>> 	if (list_empty(&seg_tg->seg_list) && !(current->flags & PF_EXITING))
+// >>> 		emm_notifier_unregister(&seg_tg->emm_notifier, seg_tg->mm);
+	write_unlock(&seg_tg->seg_list_lock);
+
+	xpmem_seg_up_write(seg);
+	xpmem_seg_destroyable(seg);
+
+	return 0;
+}
+
+/*
+ * Remove all segments belonging to the specified thread group.
+ */
+void
+xpmem_remove_segs_of_tg(struct xpmem_thread_group *seg_tg)
+{
+	struct xpmem_segment *seg;
+
+	DBUG_ON(current->tgid != seg_tg->tgid);
+
+	read_lock(&seg_tg->seg_list_lock);
+
+	while (!list_empty(&seg_tg->seg_list)) {
+		seg = list_entry((&seg_tg->seg_list)->next,
+				 struct xpmem_segment, seg_list);
+		if (!(seg->flags & XPMEM_FLAG_DESTROYING)) {
+			xpmem_seg_ref(seg);
+			read_unlock(&seg_tg->seg_list_lock);
+
+			(void)xpmem_remove_seg(seg_tg, seg);
+
+			xpmem_seg_deref(seg);
+			read_lock(&seg_tg->seg_list_lock);
+		}
+	}
+	read_unlock(&seg_tg->seg_list_lock);
+}
+
+/*
+ * Remove a segment from the system.
+ */
+int
+xpmem_remove(__s64 segid)
+{
+	struct xpmem_thread_group *seg_tg;
+	struct xpmem_segment *seg;
+	int ret;
+
+	seg_tg = xpmem_tg_ref_by_segid(segid);
+	if (IS_ERR(seg_tg))
+		return PTR_ERR(seg_tg);
+
+	if (current->tgid != seg_tg->tgid) {
+		xpmem_tg_deref(seg_tg);
+		return -EACCES;
+	}
+
+	seg = xpmem_seg_ref_by_segid(seg_tg, segid);
+	if (IS_ERR(seg)) {
+		xpmem_tg_deref(seg_tg);
+		return PTR_ERR(seg);
+	}
+	DBUG_ON(seg->tg != seg_tg);
+
+	ret = xpmem_remove_seg(seg_tg, seg);
+	xpmem_seg_deref(seg);
+	xpmem_tg_deref(seg_tg);
+
+	return ret;
+}
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_misc.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_misc.c	2008-04-01 10:42:33.201782324 -0500
@@ -0,0 +1,367 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) miscellaneous functions.
+ */
+
+#include <linux/mm.h>
+#include <linux/proc_fs.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/*
+ * xpmem_tg_ref() - see xpmem_private.h for inline definition
+ */
+
+/*
+ * Return a pointer to the xpmem_thread_group structure that corresponds to the
+ * specified tgid. Increment the refcnt as well if found.
+ */
+struct xpmem_thread_group *
+xpmem_tg_ref_by_tgid(struct xpmem_partition *part, pid_t tgid)
+{
+	int index;
+	struct xpmem_thread_group *tg;
+
+	index = xpmem_tg_hashtable_index(tgid);
+	read_lock(&part->tg_hashtable[index].lock);
+
+	list_for_each_entry(tg, &part->tg_hashtable[index].list, tg_hashlist) {
+		if (tg->tgid == tgid) {
+			if (tg->flags & XPMEM_FLAG_DESTROYING)
+				continue;  /* could be others with this tgid */
+
+			xpmem_tg_ref(tg);
+			read_unlock(&part->tg_hashtable[index].lock);
+			return tg;
+		}
+	}
+
+	read_unlock(&part->tg_hashtable[index].lock);
+	return ((part != xpmem_my_part) ? ERR_PTR(-EREMOTE) : ERR_PTR(-ENOENT));
+}
+
+/*
+ * Return a pointer to the xpmem_thread_group structure that corresponds to the
+ * specified segid. Increment the refcnt as well if found.
+ */
+struct xpmem_thread_group *
+xpmem_tg_ref_by_segid(__s64 segid)
+{
+	short partid = xpmem_segid_to_partid(segid);
+	struct xpmem_partition *part;
+
+	if (partid < 0 || partid >= XP_MAX_PARTITIONS)
+		return ERR_PTR(-EINVAL);
+
+	part = &xpmem_partitions[partid];
+	/* XPMEM_FLAG_UNINITIALIZED could be an -EHOSTDOWN situation */
+	if (part->flags & XPMEM_FLAG_UNINITIALIZED)
+		return ERR_PTR(-EINVAL);
+
+	return xpmem_tg_ref_by_tgid(part, xpmem_segid_to_tgid(segid));
+}
+
+/*
+ * Return a pointer to the xpmem_thread_group structure that corresponds to the
+ * specified apid. Increment the refcnt as well if found.
+ */
+struct xpmem_thread_group *
+xpmem_tg_ref_by_apid(__s64 apid)
+{
+	short partid = xpmem_apid_to_partid(apid);
+	struct xpmem_partition *part;
+
+	if (partid < 0 || partid >= XP_MAX_PARTITIONS)
+		return ERR_PTR(-EINVAL);
+
+	part = &xpmem_partitions[partid];
+	/* XPMEM_FLAG_UNINITIALIZED could be an -EHOSTDOWN situation */
+	if (part->flags & XPMEM_FLAG_UNINITIALIZED)
+		return ERR_PTR(-EINVAL);
+
+	return xpmem_tg_ref_by_tgid(part, xpmem_apid_to_tgid(apid));
+}
+
+/*
+ * Decrement the refcnt for a xpmem_thread_group structure previously
+ * referenced via xpmem_tg_ref(), xpmem_tg_ref_by_tgid(), or
+ * xpmem_tg_ref_by_segid().
+ */
+void
+xpmem_tg_deref(struct xpmem_thread_group *tg)
+{
+#ifdef CONFIG_PROC_FS
+	char tgid_string[XPMEM_TGID_STRING_LEN];
+#endif /* CONFIG_PROC_FS */
+
+	DBUG_ON(atomic_read(&tg->refcnt) <= 0);
+	if (atomic_dec_return(&tg->refcnt) != 0)
+		return;
+
+	/*
+	 * Process has been removed from lookup lists and is no
+	 * longer being referenced, so it is safe to remove it.
+	 */
+	DBUG_ON(!(tg->flags & XPMEM_FLAG_DESTROYING));
+	DBUG_ON(!list_empty(&tg->seg_list));
+
+#ifdef CONFIG_PROC_FS
+	snprintf(tgid_string, XPMEM_TGID_STRING_LEN, "%d", tg->tgid);
+	spin_lock(&xpmem_unpin_procfs_lock);
+	remove_proc_entry(tgid_string, xpmem_unpin_procfs_dir);
+	spin_unlock(&xpmem_unpin_procfs_lock);
+#endif /* CONFIG_PROC_FS */
+
+	kfree(tg->ap_hashtable);
+
+	kfree(tg);
+}
+
+/*
+ * xpmem_seg_ref - see xpmem_private.h for inline definition
+ */
+
+/*
+ * Return a pointer to the xpmem_segment structure that corresponds to the
+ * given segid. Increment the refcnt as well.
+ */
+struct xpmem_segment *
+xpmem_seg_ref_by_segid(struct xpmem_thread_group *seg_tg, __s64 segid)
+{
+	struct xpmem_segment *seg;
+
+	read_lock(&seg_tg->seg_list_lock);
+
+	list_for_each_entry(seg, &seg_tg->seg_list, seg_list) {
+		if (seg->segid == segid) {
+			if (seg->flags & XPMEM_FLAG_DESTROYING)
+				continue; /* could be others with this segid */
+
+			xpmem_seg_ref(seg);
+			read_unlock(&seg_tg->seg_list_lock);
+			return seg;
+		}
+	}
+
+	read_unlock(&seg_tg->seg_list_lock);
+	return ERR_PTR(-ENOENT);
+}
+
+/*
+ * Decrement the refcnt for a xpmem_segment structure previously referenced via
+ * xpmem_seg_ref() or xpmem_seg_ref_by_segid().
+ */
+void
+xpmem_seg_deref(struct xpmem_segment *seg)
+{
+	int i;
+	int j;
+	int k;
+	u64 ****l4table;
+	u64 ***l3table;
+	u64 **l2table;
+
+	DBUG_ON(atomic_read(&seg->refcnt) <= 0);
+	if (atomic_dec_return(&seg->refcnt) != 0)
+		return;
+
+	/*
+	 * Segment has been removed from lookup lists and is no
+	 * longer being referenced so it is safe to free it.
+	 */
+	DBUG_ON(!(seg->flags & XPMEM_FLAG_DESTROYING));
+
+	/* free this segment's PFN table  */
+	DBUG_ON(seg->PFNtable == NULL);
+	l4table = seg->PFNtable;
+	for (i = 0; i < XPMEM_PFNTABLE_L4SIZE; i++) {
+		if (l4table[i] == NULL)
+			continue;
+
+		l3table = l4table[i];
+		for (j = 0; j < XPMEM_PFNTABLE_L3SIZE; j++) {
+			if (l3table[j] == NULL)
+				continue;
+
+			l2table = l3table[j];
+			for (k = 0; k < XPMEM_PFNTABLE_L2SIZE; k++) {
+				if (l2table[k] != NULL)
+					kfree(l2table[k]);
+			}
+			kfree(l2table);
+		}
+		kfree(l3table);
+	}
+	kfree(l4table);
+
+	kfree(seg);
+}
+
+/*
+ * xpmem_ap_ref() - see xpmem_private.h for inline definition
+ */
+
+/*
+ * Return a pointer to the xpmem_access_permit structure that corresponds to
+ * the given apid. Increment the refcnt as well.
+ */
+struct xpmem_access_permit *
+xpmem_ap_ref_by_apid(struct xpmem_thread_group *ap_tg, __s64 apid)
+{
+	int index;
+	struct xpmem_access_permit *ap;
+
+	index = xpmem_ap_hashtable_index(apid);
+	read_lock(&ap_tg->ap_hashtable[index].lock);
+
+	list_for_each_entry(ap, &ap_tg->ap_hashtable[index].list,
+			    ap_hashlist) {
+		if (ap->apid == apid) {
+			if (ap->flags & XPMEM_FLAG_DESTROYING)
+				break;	/* can't be others with this apid */
+
+			xpmem_ap_ref(ap);
+			read_unlock(&ap_tg->ap_hashtable[index].lock);
+			return ap;
+		}
+	}
+
+	read_unlock(&ap_tg->ap_hashtable[index].lock);
+	return ERR_PTR(-ENOENT);
+}
+
+/*
+ * Decrement the refcnt for a xpmem_access_permit structure previously
+ * referenced via xpmem_ap_ref() or xpmem_ap_ref_by_apid().
+ */
+void
+xpmem_ap_deref(struct xpmem_access_permit *ap)
+{
+	DBUG_ON(atomic_read(&ap->refcnt) <= 0);
+	if (atomic_dec_return(&ap->refcnt) == 0) {
+		/*
+		 * Access has been removed from lookup lists and is no
+		 * longer being referenced so it is safe to remove it.
+		 */
+		DBUG_ON(!(ap->flags & XPMEM_FLAG_DESTROYING));
+		kfree(ap);
+	}
+}
+
+/*
+ * xpmem_att_ref() - see xpmem_private.h for inline definition
+ */
+
+/*
+ * Decrement the refcnt for a xpmem_attachment structure previously referenced
+ * via xpmem_att_ref().
+ */
+void
+xpmem_att_deref(struct xpmem_attachment *att)
+{
+	DBUG_ON(atomic_read(&att->refcnt) <= 0);
+	if (atomic_dec_return(&att->refcnt) == 0) {
+		/*
+		 * Attach has been removed from lookup lists and is no
+		 * longer being referenced so it is safe to remove it.
+		 */
+		DBUG_ON(!(att->flags & XPMEM_FLAG_DESTROYING));
+		kfree(att);
+	}
+}
+
+/*
+ * Acquire read access to a xpmem_segment structure.
+ */
+int
+xpmem_seg_down_read(struct xpmem_thread_group *seg_tg,
+		    struct xpmem_segment *seg, int block_recall_PFNs, int wait)
+{
+	int ret;
+
+	if (block_recall_PFNs) {
+		ret = xpmem_block_recall_PFNs(seg_tg, wait);
+		if (ret != 0)
+			return ret;
+	}
+
+	if (!down_read_trylock(&seg->sema)) {
+		if (!wait) {
+			if (block_recall_PFNs)
+				xpmem_unblock_recall_PFNs(seg_tg);
+			return -EAGAIN;
+		}
+		down_read(&seg->sema);
+	}
+
+	if ((seg->flags & XPMEM_FLAG_DESTROYING) ||
+	    (seg_tg->flags & XPMEM_FLAG_DESTROYING)) {
+		up_read(&seg->sema);
+		if (block_recall_PFNs)
+			xpmem_unblock_recall_PFNs(seg_tg);
+		return -ENOENT;
+	}
+	return 0;
+}
+
+/*
+ * Ensure that a user is correctly accessing a segment for a copy or an attach
+ * and if so, return the segment's vaddr adjusted by the user specified offset.
+ */
+u64
+xpmem_get_seg_vaddr(struct xpmem_access_permit *ap, off_t offset,
+		    size_t size, int mode)
+{
+	/* first ensure that this thread has permission to access segment */
+	if (current->tgid != ap->tg->tgid ||
+	    (mode == XPMEM_RDWR && ap->mode == XPMEM_RDONLY))
+		return -EACCES;
+
+	if (offset < 0 || size == 0 || offset + size > ap->seg->size)
+		return -EINVAL;
+
+	return ap->seg->vaddr + offset;
+}
+
+/*
+ * Only allow through SIGTERM or SIGKILL if they will be fatal to the
+ * current thread.
+ */
+void
+xpmem_block_nonfatal_signals(sigset_t *oldset)
+{
+	unsigned long flags;
+	sigset_t new_blocked_signals;
+
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	*oldset = current->blocked;
+	sigfillset(&new_blocked_signals);
+	sigdelset(&new_blocked_signals, SIGTERM);
+	if (current->sighand->action[SIGKILL - 1].sa.sa_handler == SIG_DFL)
+		sigdelset(&new_blocked_signals, SIGKILL);
+
+	current->blocked = new_blocked_signals;
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
+}
+
+/*
+ * Return blocked signal mask to default.
+ */
+void
+xpmem_unblock_nonfatal_signals(sigset_t *oldset)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&current->sighand->siglock, flags);
+	current->blocked = *oldset;
+	recalc_sigpending();
+	spin_unlock_irqrestore(&current->sighand->siglock, flags);
+}
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_pfn.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_pfn.c	2008-04-01 10:42:33.165777884 -0500
@@ -0,0 +1,1242 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) PFN support.
+ */
+
+#include <linux/device.h>
+#include <linux/efi.h>
+#include <linux/pagemap.h>
+#include "xpmem.h"
+#include "xpmem_private.h"
+
+/* #of pages rounded up to that which vaddr and size would occupy */
+static int
+xpmem_num_of_pages(u64 vaddr, size_t size)
+{
+	return (offset_in_page(vaddr) + size + (PAGE_SIZE - 1)) >> PAGE_SHIFT;
+}
+
+/*
+ * Recall all PFNs belonging to the specified segment that have been
+ * accessed by other thread groups.
+ */
+static void
+xpmem_recall_PFNs(struct xpmem_segment *seg, u64 vaddr, size_t size)
+{
+	int handled;	//>>> what name should this have?
+
+	DBUG_ON(atomic_read(&seg->refcnt) <= 0);
+	DBUG_ON(atomic_read(&seg->tg->refcnt) <= 0);
+
+	if (!xpmem_get_overlapping_range(seg->vaddr, seg->size, &vaddr, &size))
+		return;
+
+	spin_lock(&seg->lock);
+	while (seg->flags & (XPMEM_FLAG_DESTROYING |
+	       XPMEM_FLAG_RECALLINGPFNS)) {
+
+		handled = (vaddr >= seg->recall_vaddr && vaddr + size <=
+			     seg->recall_vaddr + seg->recall_size);
+		spin_unlock(&seg->lock);
+
+		xpmem_wait_for_seg_destroyed(seg);
+		if (handled || (seg->flags & XPMEM_FLAG_DESTROYED))
+			return;
+
+		spin_lock(&seg->lock);
+	}
+	seg->recall_vaddr = vaddr;
+	seg->recall_size = size;
+	seg->flags |= XPMEM_FLAG_RECALLINGPFNS;
+	spin_unlock(&seg->lock);
+
+	xpmem_seg_down_write(seg);
+
+	/* clear all PTEs for each local attach to this segment */
+	xpmem_clear_PTEs(seg, vaddr, size);
+
+	/* clear the seg's PFN table and unpin pages */
+	xpmem_clear_PFNtable(seg, vaddr, size, 1, 0);
+
+	spin_lock(&seg->lock);
+	seg->flags &= ~XPMEM_FLAG_RECALLINGPFNS;
+	spin_unlock(&seg->lock);
+
+	xpmem_seg_up_write(seg);
+}
+
+// >>> Argh.
+int xpmem_zzz(struct xpmem_segment *seg, u64 vaddr, size_t size);
+/*
+ * Recall all PFNs belonging to the specified thread group's XPMEM segments
+ * that have been accessed by other thread groups.
+ */
+static void
+xpmem_recall_PFNs_of_tg(struct xpmem_thread_group *seg_tg, u64 vaddr,
+			size_t size)
+{
+	struct xpmem_segment *seg;
+	struct xpmem_page_request *preq;
+	u64 t_vaddr;
+	size_t t_size;
+
+	/* mark any current faults as invalid. */
+	list_for_each_entry(preq, &seg_tg->page_requests, page_requests) {
+		t_vaddr = vaddr;
+		t_size = size;
+		if (xpmem_get_overlapping_range(preq->vaddr, preq->size, &t_vaddr, &t_size))
+			preq->valid = 0;
+	}
+
+	read_lock(&seg_tg->seg_list_lock);
+	list_for_each_entry(seg, &seg_tg->seg_list, seg_list) {
+
+		t_vaddr = vaddr;
+		t_size = size;
+		if (xpmem_get_overlapping_range(seg->vaddr, seg->size,
+		    &t_vaddr, &t_size)) {
+
+			xpmem_seg_ref(seg);
+			read_unlock(&seg_tg->seg_list_lock);
+
+			if (xpmem_zzz(seg, t_vaddr, t_size))
+				xpmem_recall_PFNs(seg, t_vaddr, t_size);
+
+			read_lock(&seg_tg->seg_list_lock);
+			if (list_empty(&seg->seg_list)) {
+				/* seg was deleted from seg_tg->seg_list */
+				xpmem_seg_deref(seg);
+				seg = list_entry(&seg_tg->seg_list,
+						 struct xpmem_segment,
+						 seg_list);
+			} else
+				xpmem_seg_deref(seg);
+		}
+	}
+	read_unlock(&seg_tg->seg_list_lock);
+}
+
+int
+xpmem_block_recall_PFNs(struct xpmem_thread_group *tg, int wait)
+{
+	int value;
+	int returned_value;
+
+	while (1) {
+		if (waitqueue_active(&tg->allow_recall_PFNs_wq))
+			goto wait;
+
+		value = atomic_read(&tg->n_recall_PFNs);
+		while (1) {
+			if (unlikely(value > 0))
+				break;
+
+			returned_value = atomic_cmpxchg(&tg->n_recall_PFNs,
+							value, value - 1);
+			if (likely(returned_value == value))
+				break;
+
+			value = returned_value;
+		}
+
+		if (value <= 0)
+			return 0;
+wait:
+		if (!wait)
+			return -EAGAIN;
+
+		wait_event(tg->block_recall_PFNs_wq,
+			   (atomic_read(&tg->n_recall_PFNs) <= 0));
+	}
+}
+
+void
+xpmem_unblock_recall_PFNs(struct xpmem_thread_group *tg)
+{
+	if (atomic_inc_return(&tg->n_recall_PFNs) == 0)
+		wake_up(&tg->allow_recall_PFNs_wq);
+}
+
+static void
+xpmem_disallow_blocking_recall_PFNs(struct xpmem_thread_group *tg)
+{
+	int value;
+	int returned_value;
+
+	while (1) {
+		value = atomic_read(&tg->n_recall_PFNs);
+		while (1) {
+			if (unlikely(value < 0))
+				break;
+			returned_value = atomic_cmpxchg(&tg->n_recall_PFNs,
+							value, value + 1);
+			if (likely(returned_value == value))
+				break;
+			value = returned_value;
+		}
+
+		if (value >= 0)
+			return;
+
+		wait_event(tg->allow_recall_PFNs_wq,
+			  (atomic_read(&tg->n_recall_PFNs) >= 0));
+	}
+}
+
+static void
+xpmem_allow_blocking_recall_PFNs(struct xpmem_thread_group *tg)
+{
+	if (atomic_dec_return(&tg->n_recall_PFNs) == 0)
+		wake_up(&tg->block_recall_PFNs_wq);
+}
+
+
+int xpmem_emm_notifier_callback(struct emm_notifier *e, struct mm_struct *mm,
+		enum emm_operation op, unsigned long start, unsigned long end)
+{
+	struct xpmem_thread_group *tg;
+
+	tg = container_of(e, struct xpmem_thread_group, emm_notifier);
+	xpmem_tg_ref(tg);
+
+	DBUG_ON(tg->mm != mm);
+	switch(op) {
+	case emm_release:
+		xpmem_remove_segs_of_tg(tg);
+		break;
+	case emm_invalidate_start:
+		xpmem_disallow_blocking_recall_PFNs(tg);
+
+		mutex_lock(&tg->recall_PFNs_mutex);
+		xpmem_recall_PFNs_of_tg(tg, start, end - start);
+		mutex_unlock(&tg->recall_PFNs_mutex);
+		break;
+	case emm_invalidate_end:
+		xpmem_allow_blocking_recall_PFNs(tg);
+		break;
+	case emm_referenced:
+		break;
+	}
+
+	xpmem_tg_deref(tg);
+	return 0;
+}
+
+/*
+ * Fault in and pin all pages in the given range for the specified task and mm.
+ * VM_IO pages can't be pinned via get_user_pages().
+ */
+static int
+xpmem_pin_pages(struct xpmem_thread_group *tg, struct xpmem_segment *seg,
+		struct task_struct *src_task, struct mm_struct *src_mm,
+		u64 vaddr, size_t size, int *pinned, int *recalls_blocked)
+{
+	int ret;
+	int bret;
+	int malloc = 0;
+	int n_pgs = xpmem_num_of_pages(vaddr, size);
+//>>> What is pages_array being used for by get_user_pages() and can
+//>>> xpmem_fill_in_PFNtable() use it to do what it needs to do?
+	struct page *pages_array[16];
+	struct page **pages;
+	struct vm_area_struct *vma;
+	cpumask_t saved_mask = CPU_MASK_NONE;
+	struct xpmem_page_request preq = {.valid = 1, .page_requests = LIST_HEAD_INIT(preq.page_requests), };
+	int request_retries = 0;
+
+	*pinned = 1;
+
+	vma = find_vma(src_mm, vaddr);
+	if (!vma || vma->vm_start > vaddr)
+		return -ENOENT;
+
+	/* don't pin pages in an address range which itself is an attachment */
+	if (xpmem_is_vm_ops_set(vma))
+		return -ENOENT;
+
+	if (n_pgs > 16) {
+		pages = kzalloc(sizeof(struct page *) * n_pgs, GFP_KERNEL);
+		if (pages == NULL)
+			return -ENOMEM;
+
+		malloc = 1;
+	} else
+		pages = pages_array;
+
+	/*
+	 * get_user_pages() may have to allocate pages on behalf of
+	 * the source thread group. If so, we want to ensure that pages
+	 * are allocated near the source thread group and not the current
+	 * thread calling get_user_pages(). Since this does not happen when
+	 * the policy is node-local (the most common default policy),
+	 * we might have to temporarily switch cpus to get the page
+	 * placed where we want it. Since MPI rarely uses xpmem_copy(),
+	 * we don't bother doing this unless we are allocating XPMEM
+	 * attached memory (i.e. n_pgs == 1).
+	 */
+	if (n_pgs == 1 && xpmem_vaddr_to_pte(src_mm, vaddr) == NULL &&
+	    cpu_to_node(task_cpu(current)) != cpu_to_node(task_cpu(src_task))) {
+		saved_mask = current->cpus_allowed;
+		set_cpus_allowed(current, cpumask_of_cpu(task_cpu(src_task)));
+	}
+
+	/*
+	 * At this point, we are ready to call the kernel to fault and reference
+	 * pages.  There is a deadlock case where our fault action may need to
+	 * do an invalidate_range.  To handle this case, we add our page_request
+	 * information to a list which any new invalidates will check and then
+	 * unblock invalidates.
+	 */
+	preq.vaddr = vaddr;
+	preq.size = size;
+	init_waitqueue_head(&preq.wq);
+	spin_lock(&tg->page_requests_lock);
+	list_add(&preq.page_requests, &tg->page_requests);
+	spin_unlock(&tg->page_requests_lock);
+
+retry_fault:
+	mutex_unlock(&seg->PFNtable_mutex);
+	if (recalls_blocked) {
+		xpmem_unblock_recall_PFNs(tg);
+		recalls_blocked = 0;
+	}
+
+	/* get_user_pages() faults and pins the pages */
+	ret = get_user_pages(src_task, src_mm, vaddr, n_pgs, 1, 1, pages, NULL);
+
+	bret = xpmem_block_recall_PFNs(tg, 1);
+	mutex_lock(&seg->PFNtable_mutex);
+
+	if (bret != 0 || !preq.valid) {
+		int to_free = ret;
+
+		while (to_free-- > 0) {
+			page_cache_release(pages[to_free]);
+		}
+		request_retries++;
+	}
+
+	if (preq.valid || bret != 0 || request_retries > 3 ) {
+		spin_lock(&tg->page_requests_lock);
+		list_del(&preq.page_requests);
+		spin_unlock(&tg->page_requests_lock);
+		wake_up_all(&preq.wq);
+	}
+
+	if (bret != 0) {
+		*recalls_blocked = 0;
+		return bret;
+	}
+	if (request_retries > 3)
+		return -EAGAIN;
+
+	if (!preq.valid) {
+
+		preq.valid = 1;
+		goto retry_fault;
+	}
+
+	if (!cpus_empty(saved_mask))
+		set_cpus_allowed(current, saved_mask);
+
+	if (malloc)
+		kfree(pages);
+
+	if (ret >= 0) {
+		DBUG_ON(ret != n_pgs);
+		atomic_add(ret, &tg->n_pinned);
+	} else {
+		struct vm_area_struct *vma;
+		u64 end_vaddr;
+		u64 tmp_vaddr;
+
+		/*
+		 * get_user_pages() doesn't pin VM_IO mappings. If the entire
+		 * area is locked I/O space however, we can continue and just
+		 * make note of the fact that this area was not pinned by
+		 * XPMEM. Fetchop (AMO) pages fall into this category.
+		 */
+		end_vaddr = vaddr + size;
+		tmp_vaddr = vaddr;
+		do {
+			vma = find_vma(src_mm, tmp_vaddr);
+			if (!vma || vma->vm_start >= end_vaddr ||
+//>>> VM_PFNMAP may also be set? Can we say it's always set?
+//>>> perhaps we could check for it and VM_IO and set something to indicate
+//>>> whether one or the other or both of these were set
+			    !(vma->vm_flags & VM_IO))
+				return ret;
+
+			tmp_vaddr = vma->vm_end;
+
+		} while (tmp_vaddr < end_vaddr);
+
+		/*
+		 * All mappings are pinned for I/O. Check the page tables to
+		 * ensure that all pages are present.
+		 */
+		while (n_pgs--) {
+			if (xpmem_vaddr_to_pte(src_mm, vaddr) == NULL)
+				return -EFAULT;
+
+			vaddr += PAGE_SIZE;
+		}
+		*pinned = 0;
+	}
+
+	return 0;
+}
+
+/*
+ * For a given virtual address range, grab the underlying PFNs from the
+ * page table and store them in XPMEM's PFN table. The underlying pages
+ * have already been pinned by the time this function is executed.
+ */
+static int
+xpmem_fill_in_PFNtable(struct mm_struct *src_mm, struct xpmem_segment *seg,
+		       u64 vaddr, size_t size, int drop_memprot, int pinned)
+{
+	int n_pgs = xpmem_num_of_pages(vaddr, size);
+	int n_pgs_unpinned;
+	pte_t *pte_p;
+	u64 *pfn_p;
+	u64 pfn;
+	int ret;
+
+	while (n_pgs--) {
+		pte_p = xpmem_vaddr_to_pte(src_mm, vaddr);
+		if (pte_p == NULL) {
+			ret = -ENOENT;
+			goto unpin_pages;
+		}
+		DBUG_ON(!pte_present(*pte_p));
+
+		pfn_p = xpmem_vaddr_to_PFN(seg, vaddr);
+		DBUG_ON(!XPMEM_PFN_IS_UNKNOWN(pfn_p));
+		pfn = pte_pfn(*pte_p);
+		DBUG_ON(!XPMEM_PFN_IS_KNOWN(&pfn));
+
+#ifdef CONFIG_IA64
+		/* check if this is an uncached page */
+		if (pte_val(*pte_p) & _PAGE_MA_UC)
+			pfn |= XPMEM_PFN_UNCACHED;
+#endif
+
+		if (!pinned)
+			pfn |= XPMEM_PFN_IO;
+
+		if (drop_memprot)
+			pfn |= XPMEM_PFN_MEMPROT_DOWN;
+
+		*pfn_p = pfn;
+		vaddr += PAGE_SIZE;
+	}
+
+	return 0;
+
+unpin_pages:
+	/* unpin any pinned pages not yet added to the PFNtable */
+	if (pinned) {
+		n_pgs_unpinned = 0;
+		do {
+//>>> The fact that the pte can be cleared after we've pinned the page suggests
+//>>> that we need to utilize the page_array set up by get_user_pages() as
+//>>> the only accurate means to find what indeed we've actually pinned.
+//>>> Can in fact the pte really be cleared from the time we pinned the page?
+			if (pte_p != NULL) {
+				page_cache_release(pte_page(*pte_p));
+				n_pgs_unpinned++;
+			}
+			vaddr += PAGE_SIZE;
+			if (n_pgs > 0)
+				pte_p = xpmem_vaddr_to_pte(src_mm, vaddr);
+		} while (n_pgs--);
+
+		atomic_sub(n_pgs_unpinned, &seg->tg->n_pinned);
+	}
+	return ret;
+}
+
+/*
+ * Determine unknown PFNs for a given virtual address range.
+ */
+static int
+xpmem_get_PFNs(struct xpmem_segment *seg, u64 vaddr, size_t size,
+	       int drop_memprot, int *recalls_blocked)
+{
+	struct xpmem_thread_group *seg_tg = seg->tg;
+	struct task_struct *src_task = seg_tg->group_leader;
+	struct mm_struct *src_mm = seg_tg->mm;
+	int ret;
+	int pinned;
+
+	/*
+	 * We used to look up the source task_struct by tgid, but that was
+	 * a performance killer. Instead we stash a pointer to the thread
+	 * group leader's task_struct in the xpmem_thread_group structure.
+	 * This is safe because we incremented the task_struct's usage count
+	 * at the same time we stashed the pointer.
+	 */
+
+	/*
+	 * Find and pin the pages. xpmem_pin_pages() fails if there are
+	 * holes in the vaddr range (which is what we want to happen).
+	 * VM_IO pages can't be pinned, however the Linux kernel ensures
+	 * those pages aren't swapped, so XPMEM keeps its hands off and
+	 * everything works out.
+	 */
+	ret = xpmem_pin_pages(seg_tg, seg, src_task, src_mm, vaddr, size, &pinned, recalls_blocked);
+	if (ret == 0) {
+		/* record the newly discovered pages in XPMEM's PFN table */
+		ret = xpmem_fill_in_PFNtable(src_mm, seg, vaddr, size,
+					     drop_memprot, pinned);
+	}
+	return ret;
+}
+
+/*
+ * Given a virtual address range and XPMEM segment, determine which portions
+ * of that range XPMEM needs to fetch PFN information for. As unknown
+ * contiguous portions of the virtual address range are determined, other
+ * functions are called to do the actual PFN discovery tasks.
+ */
+int
+xpmem_ensure_valid_PFNs(struct xpmem_segment *seg, u64 vaddr, size_t size,
+			int drop_memprot, int faulting,
+			unsigned long expected_vm_pfnmap,
+			int mmap_sem_prelocked, int *recalls_blocked)
+{
+	u64 *pfn;
+	int ret;
+	int n_pfns;
+	int n_pgs = xpmem_num_of_pages(vaddr, size);
+	int mmap_sem_locked = 0;
+	int PFNtable_locked = 0;
+	u64 f_vaddr = vaddr;
+	u64 l_vaddr = vaddr + size;
+	u64 t_vaddr = t_vaddr;
+	size_t t_size;
+	struct xpmem_thread_group *seg_tg = seg->tg;
+	struct xpmem_page_request *preq;
+	DEFINE_WAIT(wait);
+
+
+	DBUG_ON(seg->PFNtable == NULL);
+	DBUG_ON(n_pgs <= 0);
+
+again:
+	/*
+	 * We must grab the mmap_sem before the PFNtable_mutex if we are
+	 * looking up partition-local page data. If we are faulting a page in
+	 * our own address space, we don't have to grab the mmap_sem since we
+	 * already have it via ia64_do_page_fault(). If we are faulting a page
+	 * from another address space, there is a potential for a deadlock
+	 * on the mmap_sem. If the fault handler detects this potential, it
+	 * acquires the two mmap_sems in numeric order (address-wise).
+	 */
+	if (!(faulting && seg_tg->mm == current->mm)) {
+		if (!mmap_sem_prelocked) {
+//>>> Since we inc the mm_users up front in xpmem_open(), why bother here?
+//>>> but do comment that that is the case.
+			atomic_inc(&seg_tg->mm->mm_users);
+			down_read(&seg_tg->mm->mmap_sem);
+			mmap_sem_locked = 1;
+		}
+	}
+
+single_faulter:
+	ret = xpmem_block_recall_PFNs(seg_tg, 0);
+	if (ret != 0)
+		goto unlock;
+	*recalls_blocked = 1;
+
+	mutex_lock(&seg->PFNtable_mutex);
+	spin_lock(&seg_tg->page_requests_lock);
+	/* mark any current faults as invalid. */
+	list_for_each_entry(preq, &seg_tg->page_requests, page_requests) {
+		t_vaddr = vaddr;
+		t_size = size;
+		if (xpmem_get_overlapping_range(preq->vaddr, preq->size, &t_vaddr, &t_size)) {
+			prepare_to_wait(&preq->wq, &wait, TASK_UNINTERRUPTIBLE);
+			spin_unlock(&seg_tg->page_requests_lock);
+			mutex_unlock(&seg->PFNtable_mutex);
+			if (*recalls_blocked) {
+				xpmem_unblock_recall_PFNs(seg_tg);
+				*recalls_blocked = 0;
+			}
+
+			schedule();
+			set_current_state(TASK_RUNNING);
+			goto single_faulter;
+		}
+	}
+	spin_unlock(&seg_tg->page_requests_lock);
+	PFNtable_locked = 1;
+
+	/* the seg may have been marked for destruction while we were down() */
+	if (seg->flags & XPMEM_FLAG_DESTROYING) {
+		ret = -ENOENT;
+		goto unlock;
+	}
+
+	/*
+	 * Determine the number of unknown PFNs and PFNs whose memory
+	 * protections need to be modified.
+	 */
+	n_pfns = 0;
+
+	do {
+		ret = xpmem_vaddr_to_PFN_alloc(seg, vaddr, &pfn, 1);
+		if (ret != 0)
+			goto unlock;
+
+		if (XPMEM_PFN_IS_KNOWN(pfn) &&
+		    !XPMEM_PFN_DROP_MEMPROT(pfn, drop_memprot)) {
+			n_pgs--;
+			vaddr += PAGE_SIZE;
+			break;
+		}
+
+		if (n_pfns++ == 0) {
+			t_vaddr = vaddr;
+			if (t_vaddr > f_vaddr)
+				t_vaddr -= offset_in_page(t_vaddr);
+		}
+
+		n_pgs--;
+		vaddr += PAGE_SIZE;
+
+	} while (n_pgs > 0);
+
+	if (n_pfns > 0) {
+		t_size = (n_pfns * PAGE_SIZE) - offset_in_page(t_vaddr);
+		if (t_vaddr + t_size > l_vaddr)
+			t_size = l_vaddr - t_vaddr;
+
+		ret = xpmem_get_PFNs(seg, t_vaddr, t_size,
+				     drop_memprot, recalls_blocked);
+
+		if (ret != 0) {
+			goto unlock;
+		}
+	}
+
+	if (faulting) {
+		struct vm_area_struct *vma;
+
+		vma = find_vma(seg_tg->mm, vaddr - PAGE_SIZE);
+		BUG_ON(!vma || vma->vm_start > vaddr - PAGE_SIZE);
+		if ((vma->vm_flags & VM_PFNMAP) != expected_vm_pfnmap)
+			ret = -EINVAL;
+	}
+
+unlock:
+	if (PFNtable_locked)
+		mutex_unlock(&seg->PFNtable_mutex);
+	if (mmap_sem_locked) {
+		up_read(&seg_tg->mm->mmap_sem);
+		atomic_dec(&seg_tg->mm->mm_users);
+	}
+	if (ret != 0) {
+		if (*recalls_blocked) {
+			xpmem_unblock_recall_PFNs(seg_tg);
+			*recalls_blocked = 0;
+		}
+		return ret;
+	}
+
+	/*
+	 * Spin through the PFNs until we encounter one that isn't known
+	 * or the memory protection needs to be modified.
+	 */
+	DBUG_ON(faulting && n_pgs > 0);
+	while (n_pgs > 0) {
+		ret = xpmem_vaddr_to_PFN_alloc(seg, vaddr, &pfn, 0);
+		if (ret != 0)
+			return ret;
+
+		if (XPMEM_PFN_IS_UNKNOWN(pfn) ||
+		    XPMEM_PFN_DROP_MEMPROT(pfn, drop_memprot)) {
+			if (*recalls_blocked) {
+				xpmem_unblock_recall_PFNs(seg_tg);
+				*recalls_blocked = 0;
+			}
+			goto again;
+		}
+
+		n_pgs--;
+		vaddr += PAGE_SIZE;
+	}
+
+	return ret;
+}
+
+#ifdef CONFIG_X86_64
+#ifndef CONFIG_NUMA
+#ifndef CONFIG_SMP
+#undef node_to_cpumask
+#define	node_to_cpumask(nid)	(xpmem_cpu_online_map)
+static cpumask_t xpmem_cpu_online_map;
+#endif /* !CONFIG_SMP */
+#endif /* !CONFIG_NUMA */
+#endif /* CONFIG_X86_64 */
+
+static int
+xpmem_find_node_with_cpus(struct xpmem_node_PFNlists *npls, int starting_nid)
+{
+	int nid;
+	struct xpmem_node_PFNlist *npl;
+	cpumask_t node_cpus;
+
+	nid = starting_nid;
+	while (--nid != starting_nid) {
+		if (nid == -1)
+			nid = MAX_NUMNODES - 1;
+
+		npl = &npls->PFNlists[nid];
+
+		if (npl->nid == XPMEM_NODE_OFFLINE)
+			continue;
+
+		if (npl->nid != XPMEM_NODE_UNINITIALIZED) {
+			nid = npl->nid;
+			break;
+		}
+
+		if (!node_online(nid)) {
+			DBUG_ON(!cpus_empty(node_to_cpumask(nid)));
+			npl->nid = XPMEM_NODE_OFFLINE;
+			npl->cpu = XPMEM_CPUS_OFFLINE;
+			continue;
+		}
+		node_cpus = node_to_cpumask(nid);
+		if (!cpus_empty(node_cpus)) {
+			DBUG_ON(npl->cpu != XPMEM_CPUS_UNINITIALIZED);
+			npl->nid = nid;
+			break;
+		}
+		npl->cpu = XPMEM_CPUS_OFFLINE;
+	}
+
+	BUG_ON(nid == starting_nid);
+	return nid;
+}
+
+static void
+xpmem_process_PFNlist_by_CPU(struct work_struct *work)
+{
+	int i;
+	int n_unpinned = 0;
+	struct xpmem_PFNlist *pl = (struct xpmem_PFNlist *)work;
+	struct xpmem_node_PFNlists *npls = pl->PFNlists;
+	u64 *pfn;
+	struct page *page;
+
+	/* for each PFN in the PFNlist do... */
+	for (i = 0; i < pl->n_PFNs; i++) {
+		pfn = &pl->PFNs[i];
+
+		if (*pfn & XPMEM_PFN_UNPIN) {
+			if (!(*pfn & XPMEM_PFN_IO)) {
+				/* unpin the page */
+				page = virt_to_page(__va(XPMEM_PFN(pfn)
+							 << PAGE_SHIFT));
+				page_cache_release(page);
+				n_unpinned++;
+			}
+		}
+	}
+
+	if (n_unpinned > 0)
+		atomic_sub(n_unpinned, pl->n_pinned);
+
+	/* indicate we are done processing this PFNlist */
+	if (atomic_dec_return(&npls->n_PFNlists_processing) == 0)
+		wake_up(&npls->PFNlists_processing_wq);
+
+	kfree(pl);
+}
+
+static void
+xpmem_schedule_PFNlist_processing(struct xpmem_node_PFNlists *npls, int nid)
+{
+	int cpu;
+	int ret;
+	struct xpmem_node_PFNlist *npl = &npls->PFNlists[nid];
+	cpumask_t node_cpus;
+
+	DBUG_ON(npl->nid != nid);
+	DBUG_ON(npl->PFNlist == NULL);
+	DBUG_ON(npl->cpu == XPMEM_CPUS_OFFLINE);
+
+	/* select a CPU to schedule work on */
+	cpu = npl->cpu;
+	node_cpus = node_to_cpumask(nid);
+	cpu = next_cpu(cpu, node_cpus);
+	if (cpu == NR_CPUS)
+		cpu = first_cpu(node_cpus);
+
+	npl->cpu = cpu;
+
+	preempt_disable();
+	ret = schedule_delayed_work_on(cpu, &npl->PFNlist->dwork, 0);
+	preempt_enable();
+	BUG_ON(ret != 1);
+
+	npl->PFNlist = NULL;
+	npls->n_PFNlists_scheduled++;
+}
+
+/*
+ * Add the specified PFN to a node based list of PFNs. Each list is to be
+ * 'processed' by the CPUs resident on that node. If a node does not have
+ * any CPUs, the list processing will be scheduled on the CPUs of a node
+ * that does.
+ */
+static void
+xpmem_add_to_PFNlist(struct xpmem_segment *seg,
+		     struct xpmem_node_PFNlists **npls_ptr, u64 *pfn)
+{
+	int nid;
+	struct xpmem_node_PFNlists *npls = *npls_ptr;
+	struct xpmem_node_PFNlist *npl;
+	struct xpmem_PFNlist *pl;
+	cpumask_t node_cpus;
+
+	if (npls == NULL) {
+		npls = kmalloc(sizeof(struct xpmem_node_PFNlists), GFP_KERNEL);
+		BUG_ON(npls == NULL);
+		*npls_ptr = npls;
+
+		atomic_set(&npls->n_PFNlists_processing, 0);
+		init_waitqueue_head(&npls->PFNlists_processing_wq);
+
+		npls->n_PFNlists_created = 0;
+		npls->n_PFNlists_scheduled = 0;
+		npls->PFNlists = kmalloc(sizeof(struct xpmem_node_PFNlist) *
+					 MAX_NUMNODES, GFP_KERNEL);
+		BUG_ON(npls->PFNlists == NULL);
+
+		for (nid = 0; nid < MAX_NUMNODES; nid++) {
+			npls->PFNlists[nid].nid = XPMEM_NODE_UNINITIALIZED;
+			npls->PFNlists[nid].cpu = XPMEM_CPUS_UNINITIALIZED;
+			npls->PFNlists[nid].PFNlist = NULL;
+		}
+	}
+
+#ifdef CONFIG_IA64
+	nid = nasid_to_cnodeid(NASID_GET(XPMEM_PFN_TO_PADDR(pfn)));
+#else
+	nid = pfn_to_nid(XPMEM_PFN(pfn));
+#endif
+	BUG_ON(nid >= MAX_NUMNODES);
+	DBUG_ON(!node_online(nid));
+	npl = &npls->PFNlists[nid];
+
+	pl = npl->PFNlist;
+	if (pl == NULL) {
+
+		DBUG_ON(npl->nid == XPMEM_NODE_OFFLINE);
+		if (npl->nid == XPMEM_NODE_UNINITIALIZED) {
+			node_cpus = node_to_cpumask(nid);
+			if (npl->cpu == XPMEM_CPUS_OFFLINE ||
+			    cpus_empty(node_cpus)) {
+				/* mark this node as headless */
+				npl->cpu = XPMEM_CPUS_OFFLINE;
+
+				/* switch to a node with CPUs */
+				npl->nid = xpmem_find_node_with_cpus(npls, nid);
+				npl = &npls->PFNlists[npl->nid];
+			} else
+				npl->nid = nid;
+
+		} else if (npl->nid != nid) {
+			/* we're on a headless node, switch to one with CPUs */
+			DBUG_ON(npl->cpu != XPMEM_CPUS_OFFLINE);
+			npl = &npls->PFNlists[npl->nid];
+		}
+
+		pl = npl->PFNlist;
+		if (pl == NULL) {
+			pl = kmalloc_node(sizeof(struct xpmem_PFNlist) +
+					  sizeof(u64) * XPMEM_MAXNPFNs_PER_LIST,
+					  GFP_KERNEL, npl->nid);
+			BUG_ON(pl == NULL);
+
+			INIT_DELAYED_WORK(&pl->dwork,
+					  xpmem_process_PFNlist_by_CPU);
+			pl->n_pinned = &seg->tg->n_pinned;
+			pl->PFNlists = npls;
+			pl->n_PFNs = 0;
+
+			npl->PFNlist = pl;
+			npls->n_PFNlists_created++;
+		}
+	}
+
+	pl->PFNs[pl->n_PFNs++] = *pfn;
+
+	if (pl->n_PFNs == XPMEM_MAXNPFNs_PER_LIST)
+		xpmem_schedule_PFNlist_processing(npls, npl->nid);
+}
+
+/*
+ * Search for any PFNs found in the specified seg's level 1 PFNtable.
+ */
+static inline int
+xpmem_zzz_l1(struct xpmem_segment *seg, u64 *l1table, u64 *vaddr,
+			u64 end_vaddr)
+{
+	int nfound = 0;
+	int index = XPMEM_PFNTABLE_L1INDEX(*vaddr);
+	u64 *pfn;
+
+	for (; index < XPMEM_PFNTABLE_L1SIZE && *vaddr <= end_vaddr && nfound == 0;
+	     index++, *vaddr += PAGE_SIZE) {
+		pfn = &l1table[index];
+		if (XPMEM_PFN_IS_UNKNOWN(pfn))
+			continue;
+
+		nfound++;
+	}
+	return nfound;
+}
+
+/*
+ * Search for any PFNs found in the specified seg's level 2 PFNtable.
+ */
+static inline int
+xpmem_zzz_l2(struct xpmem_segment *seg, u64 **l2table, u64 *vaddr,
+			u64 end_vaddr)
+{
+	int nfound = 0;
+	int index = XPMEM_PFNTABLE_L2INDEX(*vaddr);
+	u64 *l1;
+
+	for (; index < XPMEM_PFNTABLE_L2SIZE && *vaddr <= end_vaddr && nfound == 0; index++) {
+		l1 = l2table[index];
+		if (l1 == NULL) {
+			*vaddr = (*vaddr & PMD_MASK) + PMD_SIZE;
+			continue;
+		}
+
+		nfound += xpmem_zzz_l1(seg, l1, vaddr, end_vaddr);
+	}
+	return nfound;
+}
+
+/*
+ * Search for any PFNs found in the specified seg's level 3 PFNtable.
+ */
+static inline int
+xpmem_zzz_l3(struct xpmem_segment *seg, u64 ***l3table, u64 *vaddr,
+			u64 end_vaddr)
+{
+	int nfound = 0;
+	int index = XPMEM_PFNTABLE_L3INDEX(*vaddr);
+	u64 **l2;
+
+	for (; index < XPMEM_PFNTABLE_L3SIZE && *vaddr <= end_vaddr && nfound == 0; index++) {
+		l2 = l3table[index];
+		if (l2 == NULL) {
+			*vaddr = (*vaddr & PUD_MASK) + PUD_SIZE;
+			continue;
+		}
+
+		nfound += xpmem_zzz_l2(seg, l2, vaddr, end_vaddr);
+	}
+	return nfound;
+}
+
+/*
+ * Search for any PFNs found in the specified seg's PFNtable.
+ *
+ * This function should only be called when XPMEM can guarantee that no
+ * other thread will be rummaging through the PFNtable at the same time.
+ */
+int
+xpmem_zzz(struct xpmem_segment *seg, u64 vaddr, size_t size)
+{
+	int nfound = 0;
+	int index;
+	int start_index;
+	int end_index;
+	u64 ***l3;
+	u64 end_vaddr = vaddr + size - 1;
+
+	mutex_lock(&seg->PFNtable_mutex);
+
+	/* ensure vaddr is aligned on a page boundary */
+	if (offset_in_page(vaddr))
+		vaddr = (vaddr & PAGE_MASK);
+
+	start_index = XPMEM_PFNTABLE_L4INDEX(vaddr);
+	end_index = XPMEM_PFNTABLE_L4INDEX(end_vaddr);
+
+	for (index = start_index; index <= end_index && nfound == 0; index++) {
+		/*
+		 * The virtual address space is broken up into 8 regions
+		 * of equal size, and upper portions of each region are
+		 * unaccessible by user page tables. When we encounter
+		 * the unaccessible portion of a region, we set vaddr to
+		 * the beginning of the next region and continue scanning
+		 * the XPMEM PFN table. Note: the region is stored in
+		 * bits 63..61 of a virtual address.
+		 *
+		 * This check would ideally use Linux kernel macros to
+		 * determine when vaddr overlaps with unimplemented space,
+		 * but such macros do not exist in 2.4.19. Instead, we jump
+		 * to the next region at each 1/8 of the page table.
+		 */
+		if ((index != start_index) &&
+		    ((index % (PTRS_PER_PGD / 8)) == 0))
+			vaddr = ((vaddr >> 61) + 1) << 61;
+
+		l3 = seg->PFNtable[index];
+		if (l3 == NULL) {
+			vaddr = (vaddr & PGDIR_MASK) + PGDIR_SIZE;
+			continue;
+		}
+
+		nfound += xpmem_zzz_l3(seg, l3, &vaddr, end_vaddr);
+	}
+
+	mutex_unlock(&seg->PFNtable_mutex);
+	return nfound;
+}
+
+/*
+ * Clear all PFNs found in the specified seg's level 1 PFNtable.
+ */
+static inline void
+xpmem_clear_PFNtable_l1(struct xpmem_segment *seg, u64 *l1table, u64 *vaddr,
+			u64 end_vaddr, int unpin_pages, int recall_only,
+			struct xpmem_node_PFNlists **npls_ptr)
+{
+	int index = XPMEM_PFNTABLE_L1INDEX(*vaddr);
+	u64 *pfn;
+
+	for (; index < XPMEM_PFNTABLE_L1SIZE && *vaddr <= end_vaddr;
+	     index++, *vaddr += PAGE_SIZE) {
+		pfn = &l1table[index];
+		if (XPMEM_PFN_IS_UNKNOWN(pfn))
+			continue;
+
+		if (recall_only) {
+			if (!(*pfn & XPMEM_PFN_UNCACHED) &&
+			    (*pfn & XPMEM_PFN_MEMPROT_DOWN))
+				xpmem_add_to_PFNlist(seg, npls_ptr, pfn);
+
+			continue;
+		}
+
+		if (unpin_pages) {
+			*pfn |= XPMEM_PFN_UNPIN;
+			xpmem_add_to_PFNlist(seg, npls_ptr, pfn);
+		}
+		*pfn = 0;
+	}
+}
+
+/*
+ * Clear all PFNs found in the specified seg's level 2 PFNtable.
+ */
+static inline void
+xpmem_clear_PFNtable_l2(struct xpmem_segment *seg, u64 **l2table, u64 *vaddr,
+			u64 end_vaddr, int unpin_pages, int recall_only,
+			struct xpmem_node_PFNlists **npls_ptr)
+{
+	int index = XPMEM_PFNTABLE_L2INDEX(*vaddr);
+	u64 *l1;
+
+	for (; index < XPMEM_PFNTABLE_L2SIZE && *vaddr <= end_vaddr; index++) {
+		l1 = l2table[index];
+		if (l1 == NULL) {
+			*vaddr = (*vaddr & PMD_MASK) + PMD_SIZE;
+			continue;
+		}
+
+		xpmem_clear_PFNtable_l1(seg, l1, vaddr, end_vaddr,
+					unpin_pages, recall_only, npls_ptr);
+	}
+}
+
+/*
+ * Clear all PFNs found in the specified seg's level 3 PFNtable.
+ */
+static inline void
+xpmem_clear_PFNtable_l3(struct xpmem_segment *seg, u64 ***l3table, u64 *vaddr,
+			u64 end_vaddr, int unpin_pages, int recall_only,
+			struct xpmem_node_PFNlists **npls_ptr)
+{
+	int index = XPMEM_PFNTABLE_L3INDEX(*vaddr);
+	u64 **l2;
+
+	for (; index < XPMEM_PFNTABLE_L3SIZE && *vaddr <= end_vaddr; index++) {
+		l2 = l3table[index];
+		if (l2 == NULL) {
+			*vaddr = (*vaddr & PUD_MASK) + PUD_SIZE;
+			continue;
+		}
+
+		xpmem_clear_PFNtable_l2(seg, l2, vaddr, end_vaddr,
+					unpin_pages, recall_only, npls_ptr);
+	}
+}
+
+/*
+ * Clear all PFNs found in the specified seg's PFNtable and, if requested,
+ * unpin the underlying physical pages.
+ *
+ * This function should only be called when XPMEM can guarantee that no
+ * other thread will be rummaging through the PFNtable at the same time.
+ */
+void
+xpmem_clear_PFNtable(struct xpmem_segment *seg, u64 vaddr, size_t size,
+		     int unpin_pages, int recall_only)
+{
+	int index;
+	int nid;
+	int start_index;
+	int end_index;
+	struct xpmem_node_PFNlists *npls = NULL;
+	u64 ***l3;
+	u64 end_vaddr = vaddr + size - 1;
+
+	DBUG_ON(unpin_pages && recall_only);
+
+	mutex_lock(&seg->PFNtable_mutex);
+
+	/* ensure vaddr is aligned on a page boundary */
+	if (offset_in_page(vaddr))
+		vaddr = (vaddr & PAGE_MASK);
+
+	start_index = XPMEM_PFNTABLE_L4INDEX(vaddr);
+	end_index = XPMEM_PFNTABLE_L4INDEX(end_vaddr);
+
+	for (index = start_index; index <= end_index; index++) {
+		/*
+		 * The virtual address space is broken up into 8 regions
+		 * of equal size, and upper portions of each region are
+		 * unaccessible by user page tables. When we encounter
+		 * the unaccessible portion of a region, we set vaddr to
+		 * the beginning of the next region and continue scanning
+		 * the XPMEM PFN table. Note: the region is stored in
+		 * bits 63..61 of a virtual address.
+		 *
+		 * This check would ideally use Linux kernel macros to
+		 * determine when vaddr overlaps with unimplemented space,
+		 * but such macros do not exist in 2.4.19. Instead, we jump
+		 * to the next region at each 1/8 of the page table.
+		 */
+		if ((index != start_index) &&
+		    ((index % (PTRS_PER_PGD / 8)) == 0))
+			vaddr = ((vaddr >> 61) + 1) << 61;
+
+		l3 = seg->PFNtable[index];
+		if (l3 == NULL) {
+			vaddr = (vaddr & PGDIR_MASK) + PGDIR_SIZE;
+			continue;
+		}
+
+		xpmem_clear_PFNtable_l3(seg, l3, &vaddr, end_vaddr,
+					unpin_pages, recall_only, &npls);
+	}
+
+	if (npls != NULL) {
+		if (npls->n_PFNlists_created > npls->n_PFNlists_scheduled) {
+			for_each_online_node(nid) {
+				if (npls->PFNlists[nid].PFNlist != NULL)
+					xpmem_schedule_PFNlist_processing(npls,
+									  nid);
+			}
+		}
+		DBUG_ON(npls->n_PFNlists_scheduled != npls->n_PFNlists_created);
+
+		atomic_add(npls->n_PFNlists_scheduled,
+			   &npls->n_PFNlists_processing);
+		wait_event(npls->PFNlists_processing_wq,
+			   (atomic_read(&npls->n_PFNlists_processing) == 0));
+
+		kfree(npls->PFNlists);
+		kfree(npls);
+	}
+
+	mutex_unlock(&seg->PFNtable_mutex);
+}
+
+#ifdef CONFIG_PROC_FS
+DEFINE_SPINLOCK(xpmem_unpin_procfs_lock);
+struct proc_dir_entry *xpmem_unpin_procfs_dir;
+
+static int
+xpmem_is_thread_group_stopped(struct xpmem_thread_group *tg)
+{
+	struct task_struct *task = tg->group_leader;
+
+	rcu_read_lock();
+	do {
+		if (!(task->flags & PF_EXITING) &&
+		    task->state != TASK_STOPPED) {
+			rcu_read_unlock();
+			return 0;
+		}
+		task = next_thread(task);
+	} while (task != tg->group_leader);
+	rcu_read_unlock();
+	return 1;
+}
+
+int
+xpmem_unpin_procfs_write(struct file *file, const char __user *buffer,
+			 unsigned long count, void *_tgid)
+{
+	pid_t tgid = (unsigned long)_tgid;
+	struct xpmem_thread_group *tg;
+
+	tg = xpmem_tg_ref_by_tgid(xpmem_my_part, tgid);
+	if (IS_ERR(tg))
+		return -ESRCH;
+
+	if (!xpmem_is_thread_group_stopped(tg)) {
+		xpmem_tg_deref(tg);
+		return -EPERM;
+	}
+
+	xpmem_disallow_blocking_recall_PFNs(tg);
+
+	mutex_lock(&tg->recall_PFNs_mutex);
+	xpmem_recall_PFNs_of_tg(tg, 0, VMALLOC_END);
+	mutex_unlock(&tg->recall_PFNs_mutex);
+
+	xpmem_allow_blocking_recall_PFNs(tg);
+
+	xpmem_tg_deref(tg);
+	return count;
+}
+
+int
+xpmem_unpin_procfs_read(char *page, char **start, off_t off, int count,
+			int *eof, void *_tgid)
+{
+	pid_t tgid = (unsigned long)_tgid;
+	struct xpmem_thread_group *tg;
+	int len = 0;
+
+	tg = xpmem_tg_ref_by_tgid(xpmem_my_part, tgid);
+	if (!IS_ERR(tg)) {
+		len = snprintf(page, count, "pages pinned by XPMEM: %d\n",
+			       atomic_read(&tg->n_pinned));
+		xpmem_tg_deref(tg);
+	}
+
+	return len;
+}
+#endif /* CONFIG_PROC_FS */
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem.h	2008-04-01 10:42:33.093769003 -0500
@@ -0,0 +1,130 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Cross Partition Memory (XPMEM) structures and macros.
+ */
+
+#ifndef _ASM_IA64_SN_XPMEM_H
+#define _ASM_IA64_SN_XPMEM_H
+
+#include <linux/types.h>
+#include <linux/ioctl.h>
+
+/*
+ * basic argument type definitions
+ */
+struct xpmem_addr {
+	__s64 apid;		/* apid that represents memory */
+	off_t offset;		/* offset into apid's memory */
+};
+
+#define XPMEM_MAXADDR_SIZE	(size_t)(-1L)
+
+#define XPMEM_ATTACH_WC		0x10000
+#define XPMEM_ATTACH_GETSPACE	0x20000
+
+/*
+ * path to XPMEM device
+ */
+#define XPMEM_DEV_PATH  "/dev/xpmem"
+
+/*
+ * The following are the possible XPMEM related errors.
+ */
+#define XPMEM_ERRNO_NOPROC	2004	/* unknown thread due to fork() */
+
+/*
+ * flags for segment permissions
+ */
+#define XPMEM_RDONLY	0x1
+#define XPMEM_RDWR	0x2
+
+/*
+ * Valid permit_type values for xpmem_make().
+ */
+#define XPMEM_PERMIT_MODE	0x1
+
+/*
+ * ioctl() commands used to interface to the kernel module.
+ */
+#define XPMEM_IOC_MAGIC		'x'
+#define XPMEM_CMD_VERSION	_IO(XPMEM_IOC_MAGIC, 0)
+#define XPMEM_CMD_MAKE		_IO(XPMEM_IOC_MAGIC, 1)
+#define XPMEM_CMD_REMOVE	_IO(XPMEM_IOC_MAGIC, 2)
+#define XPMEM_CMD_GET		_IO(XPMEM_IOC_MAGIC, 3)
+#define XPMEM_CMD_RELEASE	_IO(XPMEM_IOC_MAGIC, 4)
+#define XPMEM_CMD_ATTACH	_IO(XPMEM_IOC_MAGIC, 5)
+#define XPMEM_CMD_DETACH	_IO(XPMEM_IOC_MAGIC, 6)
+#define XPMEM_CMD_COPY		_IO(XPMEM_IOC_MAGIC, 7)
+#define XPMEM_CMD_BCOPY		_IO(XPMEM_IOC_MAGIC, 8)
+#define XPMEM_CMD_FORK_BEGIN	_IO(XPMEM_IOC_MAGIC, 9)
+#define XPMEM_CMD_FORK_END	_IO(XPMEM_IOC_MAGIC, 10)
+
+/*
+ * Structures used with the preceding ioctl() commands to pass data.
+ */
+struct xpmem_cmd_make {
+	__u64 vaddr;
+	size_t size;
+	int permit_type;
+	__u64 permit_value;
+	__s64 segid;		/* returned on success */
+};
+
+struct xpmem_cmd_remove {
+	__s64 segid;
+};
+
+struct xpmem_cmd_get {
+	__s64 segid;
+	int flags;
+	int permit_type;
+	__u64 permit_value;
+	__s64 apid;		/* returned on success */
+};
+
+struct xpmem_cmd_release {
+	__s64 apid;
+};
+
+struct xpmem_cmd_attach {
+	__s64 apid;
+	off_t offset;
+	size_t size;
+	__u64 vaddr;
+	int fd;
+	int flags;
+};
+
+struct xpmem_cmd_detach {
+	__u64 vaddr;
+};
+
+struct xpmem_cmd_copy {
+	__s64 src_apid;
+	off_t src_offset;
+	__s64 dst_apid;
+	off_t dst_offset;
+	size_t size;
+};
+
+#ifndef __KERNEL__
+extern int xpmem_version(void);
+extern __s64 xpmem_make(void *, size_t, int, void *);
+extern int xpmem_remove(__s64);
+extern __s64 xpmem_get(__s64, int, int, void *);
+extern int xpmem_release(__s64);
+extern void *xpmem_attach(struct xpmem_addr, size_t, void *);
+extern void *xpmem_attach_wc(struct xpmem_addr, size_t, void *);
+extern void *xpmem_attach_getspace(struct xpmem_addr, size_t, void *);
+extern int xpmem_detach(void *);
+extern int xpmem_bcopy(struct xpmem_addr, struct xpmem_addr, size_t);
+#endif
+
+#endif /* _ASM_IA64_SN_XPMEM_H */
Index: emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_private.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ emm_notifier_xpmem_v1/drivers/misc/xp/xpmem_private.h	2008-04-01 10:42:33.117771963 -0500
@@ -0,0 +1,783 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+/*
+ * Private Cross Partition Memory (XPMEM) structures and macros.
+ */
+
+#ifndef _ASM_IA64_XPMEM_PRIVATE_H
+#define _ASM_IA64_XPMEM_PRIVATE_H
+
+#include <linux/rmap.h>
+#include <linux/version.h>
+#include <linux/bit_spinlock.h>
+#include <linux/workqueue.h>
+#include <linux/signal.h>
+#include <linux/sched.h>
+#ifdef CONFIG_IA64
+#include <asm/sn/arch.h>
+#else
+#define sn_partition_id			0
+#endif
+
+#ifdef CONFIG_SGI_XP
+#include <asm/sn/xp.h>
+#else
+#define XP_MAX_PARTITIONS		1
+#endif
+
+#ifndef DBUG_ON
+#define DBUG_ON(condition)
+#endif
+/*
+ * XPMEM_CURRENT_VERSION is used to identify functional differences
+ * between various releases of XPMEM to users. XPMEM_CURRENT_VERSION_STRING
+ * is printed when the kernel module is loaded and unloaded.
+ *
+ *   version  differences
+ *
+ *     1.0    initial implementation of XPMEM
+ *     1.1    fetchop (AMO) pages supported
+ *     1.2    GET space and write combining attaches supported
+ *     1.3    Convert to build for both 2.4 and 2.6 versions of kernel
+ *     1.4    add recall PFNs RPC
+ *     1.5    first round of resiliency improvements
+ *     1.6    make coherence domain union of sharing partitions
+ *     2.0    replace 32-bit xpmem_handle_t by 64-bit segid (no typedef)
+ *            replace 32-bit xpmem_id_t by 64-bit apid (no typedef)
+ *
+ *
+ * This int constant has the following format:
+ *
+ *      +----+------------+----------------+
+ *      |////|   major    |     minor      |
+ *      +----+------------+----------------+
+ *
+ *       major - major revision number (12-bits)
+ *       minor - minor revision number (16-bits)
+ */
+#define XPMEM_CURRENT_VERSION		0x00020000
+#define XPMEM_CURRENT_VERSION_STRING	"2.0"
+
+#define XPMEM_MODULE_NAME "xpmem"
+
+#ifndef L1_CACHE_MASK
+#define L1_CACHE_MASK			(L1_CACHE_BYTES - 1)
+#endif /* L1_CACHE_MASK */
+
+/*
+ * Given an address space and a virtual address return a pointer to its
+ * pte if one is present.
+ */
+static inline pte_t *
+xpmem_vaddr_to_pte(struct mm_struct *mm, u64 vaddr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte_p;
+
+	pgd = pgd_offset(mm, vaddr);
+	if (!pgd_present(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, vaddr);
+	if (!pud_present(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, vaddr);
+	if (!pmd_present(*pmd))
+		return NULL;
+
+	pte_p = pte_offset_map(pmd, vaddr);
+	if (!pte_present(*pte_p))
+		return NULL;
+
+	return pte_p;
+}
+
+/*
+ * A 64-bit PFNtable entry contans the following fields:
+ *
+ *                                ,-- XPMEM_PFN_WIDTH (currently 38 bits)
+ *                                |
+ *                    ,-----------'----------------,
+ *      +-+-+-+-+-----+----------------------------+
+ *      |a|u|i|p|/////|            pfn             |
+ *      +-+-+-+-+-----+----------------------------+
+ *      `-^-'-'-'
+ *       | | | |
+ *       | | | |
+ *       | | | |
+ *       | | | `-- unpin page bit
+ *       | | `-- I/O bit
+ *       | `-- uncached bit
+ *       `-- cross-partition access bit
+ *
+ *       a   - all access allowed (i/o and cpu)
+ *       u   - page is a uncached page
+ *       i   - page is an I/O page which wasn't pinned by XPMEM
+ *       p   - page was pinned by XPMEM and now needs to be unpinned
+ *       pfn - actual PFN value
+ */
+
+#define XPMEM_PFN_WIDTH			38
+
+#define XPMEM_PFN_UNPIN			((u64)1 << 60)
+#define XPMEM_PFN_IO			((u64)1 << 61)
+#define XPMEM_PFN_UNCACHED		((u64)1 << 62)
+#define XPMEM_PFN_MEMPROT_DOWN		((u64)1 << 63)
+#define XPMEM_PFN_DROP_MEMPROT(p, f)	((f) && \
+					       !(*(p) & XPMEM_PFN_MEMPROT_DOWN))
+
+#define XPMEM_PFN(p)			(*(p) & (((u64)1 << \
+						 XPMEM_PFN_WIDTH) - 1))
+#define XPMEM_PFN_TO_PADDR(p)		((u64)XPMEM_PFN(p) << PAGE_SHIFT)
+
+#define XPMEM_PFN_IS_UNKNOWN(p)		(*(p) == 0)
+#define XPMEM_PFN_IS_KNOWN(p)		(XPMEM_PFN(p) > 0)
+
+/*
+ * general internal driver structures
+ */
+
+struct xpmem_thread_group {
+	spinlock_t lock;	/* tg lock */
+	short partid;		/* partid tg resides on */
+	pid_t tgid;		/* tg's tgid */
+	uid_t uid;		/* tg's uid */
+	gid_t gid;		/* tg's gid */
+	int flags;		/* tg attributes and state */
+	atomic_t uniq_segid;
+	atomic_t uniq_apid;
+	rwlock_t seg_list_lock;
+	struct list_head seg_list;	/* tg's list of segs */
+	struct xpmem_hashlist *ap_hashtable;	/* locks + ap hash lists */
+	atomic_t refcnt;	/* references to tg */
+	atomic_t n_pinned;	/* #of pages pinned by this tg */
+	u64 addr_limit;		/* highest possible user addr */
+	struct list_head tg_hashlist;	/* tg hash list */
+	struct task_struct *group_leader;	/* thread group leader */
+	struct mm_struct *mm;	/* tg's mm */
+	atomic_t n_recall_PFNs;	/* #of recall of PFNs in progress */
+	struct mutex recall_PFNs_mutex;	/* lock for serializing recall of PFNs*/
+	wait_queue_head_t block_recall_PFNs_wq;	/*wait to block recall of PFNs*/
+	wait_queue_head_t allow_recall_PFNs_wq;	/*wait to allow recall of PFNs*/
+	struct emm_notifier emm_notifier;	/* >>> */
+	spinlock_t page_requests_lock;
+	struct list_head page_requests;		/* get_user_pages while unblocked */
+};
+
+struct xpmem_segment {
+	spinlock_t lock;	/* seg lock */
+	struct rw_semaphore sema;	/* seg sema */
+	__s64 segid;		/* unique segid */
+	u64 vaddr;		/* starting address */
+	size_t size;		/* size of seg */
+	int permit_type;	/* permission scheme */
+	void *permit_value;	/* permission data */
+	int flags;		/* seg attributes and state */
+	atomic_t refcnt;	/* references to seg */
+	wait_queue_head_t created_wq;	/* wait for seg to be created */
+	wait_queue_head_t destroyed_wq;	/* wait for seg to be destroyed */
+	struct xpmem_thread_group *tg;	/* creator tg */
+	struct list_head ap_list;	/* local access permits of seg */
+	struct list_head seg_list;	/* tg's list of segs */
+	int coherence_id;	/* where the seg resides */
+	u64 recall_vaddr;	/* vaddr being recalled if _RECALLINGPFNS set */
+	size_t recall_size;	/* size being recalled if _RECALLINGPFNS set */
+	struct mutex PFNtable_mutex;	/* serialization lock for PFN table */
+	u64 ****PFNtable;	/* PFN table */
+};
+
+struct xpmem_access_permit {
+	spinlock_t lock;	/* access permit lock */
+	__s64 apid;		/* unique apid */
+	int mode;		/* read/write mode */
+	int flags;		/* access permit attributes and state */
+	atomic_t refcnt;	/* references to access permit */
+	struct xpmem_segment *seg;	/* seg permitted to be accessed */
+	struct xpmem_thread_group *tg;	/* access permit's tg */
+	struct list_head att_list;	/* atts of this access permit's seg */
+	struct list_head ap_list;	/* access permits linked to seg */
+	struct list_head ap_hashlist;	/* access permit hash list */
+};
+
+struct xpmem_attachment {
+	struct mutex mutex;	/* att lock for serialization */
+	u64 offset;		/* starting offset within seg */
+	u64 at_vaddr;		/* address where seg is attached */
+	size_t at_size;		/* size of seg attachment */
+	int flags;		/* att attributes and state */
+	atomic_t refcnt;	/* references to att */
+	struct xpmem_access_permit *ap;/* associated access permit */
+	struct list_head att_list;	/* atts linked to access permit */
+	struct mm_struct *mm;	/* mm struct attached to */
+	wait_queue_head_t destroyed_wq;	/* wait for att to be destroyed */
+};
+
+struct xpmem_partition {
+	spinlock_t lock;	/* part lock */
+	int flags;		/* part attributes and state */
+	int n_proxies;		/* #of segs [im|ex]ported */
+	struct xpmem_hashlist *tg_hashtable;	/* locks + tg hash lists */
+	int version;		/* version of XPMEM running */
+	int coherence_id;	/* coherence id for partition */
+	atomic_t n_threads;	/* # of threads active */
+	wait_queue_head_t thread_wq;	/* notified when threads done */
+};
+
+/*
+ * Both the segid and apid are of type __s64 and designed to be opaque to
+ * the user. Both consist of the same underlying fields.
+ *
+ * The 'partid' field identifies the partition on which the thread group
+ * identified by 'tgid' field resides. The 'uniq' field is designed to give
+ * each segid or apid a unique value. Each type is only unique with respect
+ * to itself.
+ *
+ * An ID is never less than or equal to zero.
+ */
+struct xpmem_id {
+	pid_t tgid;		/* thread group that owns ID */
+	unsigned short uniq;	/* this value makes the ID unique */
+	signed short partid;	/* partition where tgid resides */
+};
+
+#define XPMEM_MAX_UNIQ_ID	((1 << (sizeof(short) * 8)) - 1)
+
+static inline signed short
+xpmem_segid_to_partid(__s64 segid)
+{
+	DBUG_ON(segid <= 0);
+	return ((struct xpmem_id *)&segid)->partid;
+}
+
+static inline pid_t
+xpmem_segid_to_tgid(__s64 segid)
+{
+	DBUG_ON(segid <= 0);
+	return ((struct xpmem_id *)&segid)->tgid;
+}
+
+static inline signed short
+xpmem_apid_to_partid(__s64 apid)
+{
+	DBUG_ON(apid <= 0);
+	return ((struct xpmem_id *)&apid)->partid;
+}
+
+static inline pid_t
+xpmem_apid_to_tgid(__s64 apid)
+{
+	DBUG_ON(apid <= 0);
+	return ((struct xpmem_id *)&apid)->tgid;
+}
+
+/*
+ * Attribute and state flags for various xpmem structures. Some values
+ * are defined in xpmem.h, so we reserved space here via XPMEM_DONT_USE_X
+ * to prevent overlap.
+ */
+#define XPMEM_FLAG_UNINITIALIZED	0x00001	/* state is uninitialized */
+#define XPMEM_FLAG_UP			0x00002	/* state is up */
+#define XPMEM_FLAG_DOWN			0x00004	/* state is down */
+
+#define XPMEM_FLAG_CREATING		0x00020	/* being created */
+#define XPMEM_FLAG_DESTROYING		0x00040	/* being destroyed */
+#define XPMEM_FLAG_DESTROYED		0x00080	/* 'being destroyed' finished */
+
+#define XPMEM_FLAG_PROXY		0x00100	/* is a proxy */
+#define XPMEM_FLAG_VALIDPTES		0x00200	/* valid PTEs exist */
+#define XPMEM_FLAG_RECALLINGPFNS	0x00400	/* recalling PFNs */
+
+#define XPMEM_FLAG_GOINGDOWN		0x00800	/* state is changing to down */
+
+#define	XPMEM_DONT_USE_1		0x10000	/* see XPMEM_ATTACH_WC */
+#define	XPMEM_DONT_USE_2		0x20000	/* see XPMEM_ATTACH_GETSPACE */
+#define	XPMEM_DONT_USE_3		0x40000	/* reserved for xpmem.h */
+#define	XPMEM_DONT_USE_4		0x80000	/* reserved for xpmem.h */
+
+/*
+ * The PFN table is a four-level table that can map all of a thread group's
+ * memory. This table is equivalent to the general Linux four-level segment
+ * table described in the pgtable.h file. The sizes of each level are the same,
+ * but the type is different (here the type is a u64).
+ */
+
+/* Size of the XPMEM PFN four-level table */
+#define XPMEM_PFNTABLE_L4SIZE		PTRS_PER_PGD	/* #of L3 pointers */
+#define XPMEM_PFNTABLE_L3SIZE		PTRS_PER_PUD	/* #of L2 pointers */
+#define XPMEM_PFNTABLE_L2SIZE		PTRS_PER_PMD	/* #of L1 pointers */
+#define XPMEM_PFNTABLE_L1SIZE		PTRS_PER_PTE	/* #of PFN entries */
+
+/* Return an index into the specified level given a virtual address */
+#define XPMEM_PFNTABLE_L4INDEX(v)   pgd_index(v)
+#define XPMEM_PFNTABLE_L3INDEX(v)   ((v >> PUD_SHIFT) & (PTRS_PER_PUD - 1))
+#define XPMEM_PFNTABLE_L2INDEX(v)   ((v >> PMD_SHIFT) & (PTRS_PER_PMD - 1))
+#define XPMEM_PFNTABLE_L1INDEX(v)   ((v >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))
+
+/* The following assumes all levels have been allocated for the given vaddr */
+static inline u64 *
+xpmem_vaddr_to_PFN(struct xpmem_segment *seg, u64 vaddr)
+{
+	u64 ****l4table;
+	u64 ***l3table;
+	u64 **l2table;
+	u64 *l1table;
+
+	l4table = seg->PFNtable;
+	DBUG_ON(l4table == NULL);
+	l3table = l4table[XPMEM_PFNTABLE_L4INDEX(vaddr)];
+	DBUG_ON(l3table == NULL);
+	l2table = l3table[XPMEM_PFNTABLE_L3INDEX(vaddr)];
+	DBUG_ON(l2table == NULL);
+	l1table = l2table[XPMEM_PFNTABLE_L2INDEX(vaddr)];
+	DBUG_ON(l1table == NULL);
+	return &l1table[XPMEM_PFNTABLE_L1INDEX(vaddr)];
+}
+
+/* the following will allocate missing levels for the given vaddr */
+
+static inline void *
+xpmem_alloc_PFNtable_entry(size_t size)
+{
+	void *entry;
+
+	entry = kzalloc(size, GFP_KERNEL);
+	wmb();	/* ensure that others will see the allocated space as zeroed */
+	return entry;
+}
+
+static inline int
+xpmem_vaddr_to_PFN_alloc(struct xpmem_segment *seg, u64 vaddr, u64 **pfn,
+			 int locked)
+{
+	u64 ****l4entry;
+	u64 ***l3entry;
+	u64 **l2entry;
+
+	DBUG_ON(seg->PFNtable == NULL);
+
+	l4entry = seg->PFNtable + XPMEM_PFNTABLE_L4INDEX(vaddr);
+	if (*l4entry == NULL) {
+		if (!locked)
+			mutex_lock(&seg->PFNtable_mutex);
+
+		if (locked || *l4entry == NULL)
+			*l4entry =
+			    xpmem_alloc_PFNtable_entry(XPMEM_PFNTABLE_L3SIZE *
+						       sizeof(u64 *));
+		if (!locked)
+			mutex_unlock(&seg->PFNtable_mutex);
+
+		if (*l4entry == NULL)
+			return -ENOMEM;
+	}
+	l3entry = *l4entry + XPMEM_PFNTABLE_L3INDEX(vaddr);
+	if (*l3entry == NULL) {
+		if (!locked)
+			mutex_lock(&seg->PFNtable_mutex);
+
+		if (locked || *l3entry == NULL)
+			*l3entry =
+			    xpmem_alloc_PFNtable_entry(XPMEM_PFNTABLE_L2SIZE *
+						       sizeof(u64 *));
+		if (!locked)
+			mutex_unlock(&seg->PFNtable_mutex);
+
+		if (*l3entry == NULL)
+			return -ENOMEM;
+	}
+	l2entry = *l3entry + XPMEM_PFNTABLE_L2INDEX(vaddr);
+	if (*l2entry == NULL) {
+		if (!locked)
+			mutex_lock(&seg->PFNtable_mutex);
+
+		if (locked || *l2entry == NULL)
+			*l2entry =
+			    xpmem_alloc_PFNtable_entry(XPMEM_PFNTABLE_L1SIZE *
+						       sizeof(u64));
+		if (!locked)
+			mutex_unlock(&seg->PFNtable_mutex);
+
+		if (*l2entry == NULL)
+			return -ENOMEM;
+	}
+	*pfn = *l2entry + XPMEM_PFNTABLE_L1INDEX(vaddr);
+
+	return 0;
+}
+
+/* node based PFN work list used when PFN tables are being cleared */
+
+struct xpmem_PFNlist {
+	struct delayed_work dwork;	/* for scheduling purposes */
+	atomic_t *n_pinned;	/* &tg->n_pinned */
+	struct xpmem_node_PFNlists *PFNlists;	/* PFNlists this belongs to */
+	int n_PFNs;		/* #of PFNs in array of PFNs */
+	u64 PFNs[0];		/* an array of PFNs */
+};
+
+struct xpmem_node_PFNlist {
+	int nid;		/* node to schedule work on */
+	int cpu;		/* last cpu work was scheduled on */
+	struct xpmem_PFNlist *PFNlist;	/* node based list to process */
+};
+
+struct xpmem_node_PFNlists {
+	atomic_t n_PFNlists_processing;
+	wait_queue_head_t PFNlists_processing_wq;
+
+	int n_PFNlists_created ____cacheline_aligned;
+	int n_PFNlists_scheduled;
+	struct xpmem_node_PFNlist *PFNlists;
+};
+
+#define XPMEM_NODE_UNINITIALIZED	-1
+#define XPMEM_CPUS_UNINITIALIZED	-1
+#define XPMEM_NODE_OFFLINE		-2
+#define XPMEM_CPUS_OFFLINE		-2
+
+/*
+ * Calculate the #of PFNs that can have their cache lines recalled within
+ * one timer tick. The hardcoded '4273504' represents the #of cache lines that
+ * can be recalled per second, which is based on a measured 30usec per page.
+ * The rest of it is just units conversion to pages per tick which allows
+ * for HZ and page size to change.
+ *
+ * (cachelines_per_sec / ticks_per_sec * bytes_per_cacheline / bytes_per_page)
+ */
+#define XPMEM_MAXNPFNs_PER_LIST		(4273504 / HZ * 128 / PAGE_SIZE)
+
+/*
+ * The following are active requests in get_user_pages.  If the address range
+ * is invalidated while these requests are pending, we have to assume the
+ * returned pages are not the correct ones.
+ */
+struct xpmem_page_request {
+	struct list_head page_requests;
+	u64 vaddr;
+	size_t size;
+	int valid;
+	wait_queue_head_t wq;
+};
+
+
+/*
+ * Functions registered by such things as add_timer() or called by functions
+ * like kernel_thread() only allow for a single 64-bit argument. The following
+ * inlines can be used to pack and unpack two (32-bit, 16-bit or 8-bit)
+ * arguments into or out from the passed argument.
+ */
+static inline u64
+xpmem_pack_arg1(u64 args, u32 arg1)
+{
+	return ((args & (((1UL << 32) - 1) << 32)) | arg1);
+}
+
+static inline u64
+xpmem_pack_arg2(u64 args, u32 arg2)
+{
+	return ((args & ((1UL << 32) - 1)) | ((u64)arg2 << 32));
+}
+
+static inline u32
+xpmem_unpack_arg1(u64 args)
+{
+	return (u32)(args & ((1UL << 32) - 1));
+}
+
+static inline u32
+xpmem_unpack_arg2(u64 args)
+{
+	return (u32)(args >> 32);
+}
+
+/* found in xpmem_main.c */
+extern struct device *xpmem;
+extern struct xpmem_thread_group *xpmem_open_proxy_tg_with_ref(__s64);
+extern void xpmem_flush_proxy_tg_with_nosegs(struct xpmem_thread_group *);
+extern int xpmem_send_version(short);
+
+/* found in xpmem_make.c */
+extern int xpmem_make(u64, size_t, int, void *, __s64 *);
+extern void xpmem_remove_segs_of_tg(struct xpmem_thread_group *);
+extern int xpmem_remove(__s64);
+
+/* found in xpmem_get.c */
+extern int xpmem_get(__s64, int, int, void *, __s64 *);
+extern void xpmem_release_aps_of_tg(struct xpmem_thread_group *);
+extern int xpmem_release(__s64);
+
+/* found in xpmem_attach.c */
+extern struct vm_operations_struct xpmem_vm_ops_fault;
+extern struct vm_operations_struct xpmem_vm_ops_nopfn;
+extern int xpmem_attach(struct file *, __s64, off_t, size_t, u64, int, int,
+			u64 *);
+extern void xpmem_clear_PTEs(struct xpmem_segment *, u64, size_t);
+extern int xpmem_detach(u64);
+extern void xpmem_detach_att(struct xpmem_access_permit *,
+			     struct xpmem_attachment *);
+extern int xpmem_mmap(struct file *, struct vm_area_struct *);
+
+/* found in xpmem_pfn.c */
+extern int xpmem_emm_notifier_callback(struct emm_notifier *, struct mm_struct *,
+		enum emm_operation, unsigned long, unsigned long);
+extern int xpmem_ensure_valid_PFNs(struct xpmem_segment *, u64, size_t, int,
+				   int, unsigned long, int, int *);
+extern void xpmem_clear_PFNtable(struct xpmem_segment *, u64, size_t, int, int);
+extern int xpmem_block_recall_PFNs(struct xpmem_thread_group *, int);
+extern void xpmem_unblock_recall_PFNs(struct xpmem_thread_group *);
+extern int xpmem_fork_begin(void);
+extern int xpmem_fork_end(void);
+#ifdef CONFIG_PROC_FS
+#define XPMEM_TGID_STRING_LEN	11
+extern spinlock_t xpmem_unpin_procfs_lock;
+extern struct proc_dir_entry *xpmem_unpin_procfs_dir;
+extern int xpmem_unpin_procfs_write(struct file *, const char __user *,
+				    unsigned long, void *);
+extern int xpmem_unpin_procfs_read(char *, char **, off_t, int, int *, void *);
+#endif /* CONFIG_PROC_FS */
+
+/* found in xpmem_partition.c */
+extern struct xpmem_partition *xpmem_partitions;
+extern struct xpmem_partition *xpmem_my_part;
+extern short xpmem_my_partid;
+/* found in xpmem_misc.c */
+extern struct xpmem_thread_group *xpmem_tg_ref_by_tgid(struct xpmem_partition *,
+						       pid_t);
+extern struct xpmem_thread_group *xpmem_tg_ref_by_segid(__s64);
+extern struct xpmem_thread_group *xpmem_tg_ref_by_apid(__s64);
+extern void xpmem_tg_deref(struct xpmem_thread_group *);
+extern struct xpmem_segment *xpmem_seg_ref_by_segid(struct xpmem_thread_group *,
+						    __s64);
+extern void xpmem_seg_deref(struct xpmem_segment *);
+extern struct xpmem_access_permit *xpmem_ap_ref_by_apid(struct
+							xpmem_thread_group *,
+							__s64);
+extern void xpmem_ap_deref(struct xpmem_access_permit *);
+extern void xpmem_att_deref(struct xpmem_attachment *);
+extern int xpmem_seg_down_read(struct xpmem_thread_group *,
+			       struct xpmem_segment *, int, int);
+extern u64 xpmem_get_seg_vaddr(struct xpmem_access_permit *, off_t, size_t,
+			       int);
+extern void xpmem_block_nonfatal_signals(sigset_t *);
+extern void xpmem_unblock_nonfatal_signals(sigset_t *);
+
+/*
+ * Inlines that mark an internal driver structure as being destroyable or not.
+ * The idea is to set the refcnt to 1 at structure creation time and then
+ * drop that reference at the time the structure is to be destroyed.
+ */
+static inline void
+xpmem_tg_not_destroyable(struct xpmem_thread_group *tg)
+{
+	atomic_set(&tg->refcnt, 1);
+}
+
+static inline void
+xpmem_tg_destroyable(struct xpmem_thread_group *tg)
+{
+	xpmem_tg_deref(tg);
+}
+
+static inline void
+xpmem_seg_not_destroyable(struct xpmem_segment *seg)
+{
+	atomic_set(&seg->refcnt, 1);
+}
+
+static inline void
+xpmem_seg_destroyable(struct xpmem_segment *seg)
+{
+	xpmem_seg_deref(seg);
+}
+
+static inline void
+xpmem_ap_not_destroyable(struct xpmem_access_permit *ap)
+{
+	atomic_set(&ap->refcnt, 1);
+}
+
+static inline void
+xpmem_ap_destroyable(struct xpmem_access_permit *ap)
+{
+	xpmem_ap_deref(ap);
+}
+
+static inline void
+xpmem_att_not_destroyable(struct xpmem_attachment *att)
+{
+	atomic_set(&att->refcnt, 1);
+}
+
+static inline void
+xpmem_att_destroyable(struct xpmem_attachment *att)
+{
+	xpmem_att_deref(att);
+}
+
+static inline void
+xpmem_att_set_destroying(struct xpmem_attachment *att)
+{
+	att->flags |= XPMEM_FLAG_DESTROYING;
+}
+
+static inline void
+xpmem_att_clear_destroying(struct xpmem_attachment *att)
+{
+	att->flags &= ~XPMEM_FLAG_DESTROYING;
+	wake_up(&att->destroyed_wq);
+}
+
+static inline void
+xpmem_att_set_destroyed(struct xpmem_attachment *att)
+{
+	att->flags |= XPMEM_FLAG_DESTROYED;
+	wake_up(&att->destroyed_wq);
+}
+
+static inline void
+xpmem_att_wait_destroyed(struct xpmem_attachment *att)
+{
+	wait_event(att->destroyed_wq, (!(att->flags & XPMEM_FLAG_DESTROYING) ||
+					(att->flags & XPMEM_FLAG_DESTROYED)));
+}
+
+
+/*
+ * Inlines that increment the refcnt for the specified structure.
+ */
+static inline void
+xpmem_tg_ref(struct xpmem_thread_group *tg)
+{
+	DBUG_ON(atomic_read(&tg->refcnt) <= 0);
+	atomic_inc(&tg->refcnt);
+}
+
+static inline void
+xpmem_seg_ref(struct xpmem_segment *seg)
+{
+	DBUG_ON(atomic_read(&seg->refcnt) <= 0);
+	atomic_inc(&seg->refcnt);
+}
+
+static inline void
+xpmem_ap_ref(struct xpmem_access_permit *ap)
+{
+	DBUG_ON(atomic_read(&ap->refcnt) <= 0);
+	atomic_inc(&ap->refcnt);
+}
+
+static inline void
+xpmem_att_ref(struct xpmem_attachment *att)
+{
+	DBUG_ON(atomic_read(&att->refcnt) <= 0);
+	atomic_inc(&att->refcnt);
+}
+
+/*
+ * A simple test to determine whether the specified vma corresponds to a
+ * XPMEM attachment.
+ */
+static inline int
+xpmem_is_vm_ops_set(struct vm_area_struct *vma)
+{
+	return ((vma->vm_flags & VM_PFNMAP) ?
+		(vma->vm_ops == &xpmem_vm_ops_nopfn) :
+		(vma->vm_ops == &xpmem_vm_ops_fault));
+}
+
+
+/* xpmem_seg_down_read() can be found in arch/ia64/sn/kernel/xpmem_misc.c */
+
+static inline void
+xpmem_seg_up_read(struct xpmem_thread_group *seg_tg,
+		  struct xpmem_segment *seg, int unblock_recall_PFNs)
+{
+	up_read(&seg->sema);
+	if (unblock_recall_PFNs)
+		xpmem_unblock_recall_PFNs(seg_tg);
+}
+
+static inline void
+xpmem_seg_down_write(struct xpmem_segment *seg)
+{
+	down_write(&seg->sema);
+}
+
+static inline void
+xpmem_seg_up_write(struct xpmem_segment *seg)
+{
+	up_write(&seg->sema);
+	wake_up(&seg->destroyed_wq);
+}
+
+static inline void
+xpmem_wait_for_seg_destroyed(struct xpmem_segment *seg)
+{
+	wait_event(seg->destroyed_wq, ((seg->flags & XPMEM_FLAG_DESTROYED) ||
+				       !(seg->flags & (XPMEM_FLAG_DESTROYING |
+						   XPMEM_FLAG_RECALLINGPFNS))));
+}
+
+/*
+ * Hash Tables
+ *
+ * XPMEM utilizes hash tables to enable faster lookups of list entries.
+ * These hash tables are implemented as arrays. A simple modulus of the hash
+ * key yields the appropriate array index. A hash table's array element (i.e.,
+ * hash table bucket) consists of a hash list and the lock that protects it.
+ *
+ * XPMEM has the following two hash tables:
+ *
+ * table		bucket					key
+ * part->tg_hashtable	list of struct xpmem_thread_group	tgid
+ * tg->ap_hashtable	list of struct xpmem_access_permit	apid.uniq
+ *
+ * (The 'part' pointer is defined as: &xpmem_partitions[tg->partid])
+ */
+
+struct xpmem_hashlist {
+	rwlock_t lock;		/* lock for hash list */
+	struct list_head list;	/* hash list */
+} ____cacheline_aligned;
+
+#define XPMEM_TG_HASHTABLE_SIZE	512
+#define XPMEM_AP_HASHTABLE_SIZE	8
+
+static inline int
+xpmem_tg_hashtable_index(pid_t tgid)
+{
+	return (tgid % XPMEM_TG_HASHTABLE_SIZE);
+}
+
+static inline int
+xpmem_ap_hashtable_index(__s64 apid)
+{
+	DBUG_ON(apid <= 0);
+	return (((struct xpmem_id *)&apid)->uniq % XPMEM_AP_HASHTABLE_SIZE);
+}
+
+/*
+ * >>>
+ */
+static inline size_t
+xpmem_get_overlapping_range(u64 base_vaddr, size_t base_size, u64 *vaddr_p,
+			    size_t *size_p)
+{
+	u64 start = max(*vaddr_p, base_vaddr);
+	u64 end = min(*vaddr_p + *size_p, base_vaddr + base_size);
+
+	*vaddr_p = start;
+	*size_p	= max((ssize_t)0, (ssize_t)(end - start));
+	return *size_p;
+}
+
+#endif /* _ASM_IA64_XPMEM_PRIVATE_H */
Index: emm_notifier_xpmem_v1/drivers/misc/Makefile
===================================================================
--- emm_notifier_xpmem_v1.orig/drivers/misc/Makefile	2008-04-01 10:12:01.278062055 -0500
+++ emm_notifier_xpmem_v1/drivers/misc/Makefile	2008-04-01 10:13:22.304137897 -0500
@@ -22,3 +22,4 @@ obj-$(CONFIG_FUJITSU_LAPTOP)	+= fujitsu-
 obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
 obj-$(CONFIG_INTEL_MENLOW)	+= intel_menlow.o
 obj-$(CONFIG_ENCLOSURE_SERVICES) += enclosure.o
+obj-y				+= xp/

-- 

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
