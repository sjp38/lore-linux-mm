Date: Tue, 19 Feb 2008 09:44:50 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] my mmu notifier sample driver
Message-ID: <20080219084450.GB22249@wotan.suse.de>
References: <20080219084357.GA22249@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080219084357.GA22249@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Index: linux-2.6/drivers/char/mmu_notifier_skel.c
===================================================================
--- /dev/null
+++ linux-2.6/drivers/char/mmu_notifier_skel.c
@@ -0,0 +1,255 @@
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/miscdevice.h>
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/fs.h>
+#include <linux/mmu_notifier.h>
+#include <linux/radix-tree.h>
+#include <linux/seqlock.h>
+#include <asm/tlbflush.h>
+
+static DEFINE_SPINLOCK(mmn_lock);
+static RADIX_TREE(rmap_tree, GFP_ATOMIC);
+static seqcount_t rmap_seq = SEQCNT_ZERO;
+
+static int __rmap_add(unsigned long mem, unsigned long vaddr)
+{
+	int err;
+
+	err = radix_tree_insert(&rmap_tree, mem >> PAGE_SHIFT, (void *)vaddr);
+
+	return err;
+}
+
+static void __rmap_del(unsigned long mem)
+{
+	void *ret;
+
+	ret = radix_tree_delete(&rmap_tree, mem >> PAGE_SHIFT);
+	BUG_ON(!ret);
+}
+
+static unsigned long rmap_find(unsigned long mem)
+{
+	unsigned long vaddr;
+
+	rcu_read_lock();
+	vaddr = (unsigned long)radix_tree_lookup(&rmap_tree, mem >> PAGE_SHIFT);
+	rcu_read_unlock();
+
+	return vaddr;
+}
+
+static struct page *follow_page_atomic(struct mm_struct *mm, unsigned long address, int write)
+{
+	struct vm_area_struct *vma;
+
+	vma = find_vma(mm, address);
+        if (!vma || (vma->vm_start > address))
+                return NULL;
+
+	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
+		return NULL;
+
+	return follow_page(vma, address, FOLL_GET|(write ? FOLL_WRITE : 0));
+}
+
+static int mmn_vm_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long source_vaddr = (unsigned long)vmf->pgoff << PAGE_SHIFT;
+	unsigned long dest_vaddr = (unsigned long)vmf->virtual_address;
+	unsigned long pfn;
+	struct page *page;
+	pgprot_t prot;
+	int write = vmf->flags & FAULT_FLAG_WRITE;
+	int ret;
+
+	printk("mmn_vm_fault %s@vaddr=%lx sourcing from %lx\n", write ? "write" : "read", dest_vaddr, source_vaddr);
+
+	BUG_ON(mm != current->mm); /* disallow get_user_pages */
+
+again:
+	spin_lock(&mmn_lock);
+	write_seqcount_begin(&rmap_seq);
+	page = follow_page_atomic(mm, source_vaddr, write);
+	if (unlikely(!page)) {
+		write_seqcount_end(&rmap_seq);
+		spin_unlock(&mmn_lock);
+		ret = get_user_pages(current, mm, source_vaddr,
+					1, write, 0, &page, NULL);
+		if (ret != 1)
+			goto out_err;
+		put_page(page);
+		goto again;
+	}
+
+	ret = __rmap_add(source_vaddr, dest_vaddr);
+	if (ret)
+		goto out_lock;
+
+	pfn = page_to_pfn(page);
+	prot = vma->vm_page_prot;
+	if (!write)
+		vma->vm_page_prot = vm_get_page_prot(vma->vm_flags & ~(VM_WRITE|VM_MAYWRITE));
+	ret = vm_insert_pfn(vma, dest_vaddr, pfn);
+	vma->vm_page_prot = prot;
+	if (ret) {
+		if (ret == -EBUSY)
+			WARN_ON(1);
+		goto out_rmap;
+	}
+	write_seqcount_end(&rmap_seq);
+	spin_unlock(&mmn_lock);
+	put_page(page);
+
+        return VM_FAULT_NOPAGE;
+
+out_rmap:
+	__rmap_del(source_vaddr);
+out_lock:
+	write_seqcount_end(&rmap_seq);
+	spin_unlock(&mmn_lock);
+	put_page(page);
+out_err:
+	switch (ret) {
+	case -EFAULT:
+	case -EEXIST:
+	case -EBUSY:
+		return VM_FAULT_SIGBUS;
+	case -ENOMEM:
+		return VM_FAULT_OOM;
+	default:
+		BUG();
+	}
+}
+
+struct vm_operations_struct mmn_vm_ops = {
+        .fault = mmn_vm_fault,
+};
+
+static int mmu_notifier_busy;
+static struct mmu_notifier mmu_notifier;
+
+static int mmn_clear_young(struct mmu_notifier *mn, unsigned long address)
+{
+	unsigned long vaddr;
+	unsigned seq;
+	struct mm_struct *mm = mn->mm;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep, pte;
+
+	do {
+		seq = read_seqcount_begin(&rmap_seq);
+		vaddr = rmap_find(address);
+	} while (read_seqcount_retry(&rmap_seq, seq));
+
+	if (vaddr == 0)
+		return 0;
+
+	printk("mmn_clear_young@vaddr=%lx sourced from %lx\n", vaddr, address);
+
+	spin_lock(&mmn_lock);
+        pgd = pgd_offset(mm, vaddr);
+        pud = pud_offset(pgd, vaddr);
+	if (pud) {
+		pmd = pmd_offset(pud, vaddr);
+		if (pmd) {
+			ptep = pte_offset_map(pmd, vaddr);
+			if (ptep) {
+				pte = *ptep;
+				if (!pte_present(pte)) {
+					/* x86 specific, don't have a vma */
+					ptep_get_and_clear(mm, vaddr, ptep);
+					__flush_tlb_one(vaddr);
+				}
+				pte_unmap(ptep);
+			}
+		}
+	}
+	__rmap_del(address);
+	spin_unlock(&mmn_lock);
+
+        return 1;
+}
+
+static void mmn_unmap(struct mmu_notifier *mn, unsigned long address)
+{
+	mmn_clear_young(mn, address);
+}
+
+static void mmn_release(struct mmu_notifier *mn)
+{
+	mmu_notifier_busy = 0;
+}
+
+static struct mmu_notifier_operations mmn_ops = {
+	.clear_young = mmn_clear_young,
+	.unmap = mmn_unmap,
+	.release = mmn_release,
+};
+
+static int mmn_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	int busy;
+
+	if ((vma->vm_flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE)
+		return -EINVAL;
+
+	spin_lock(&mmn_lock);
+	busy = mmu_notifier_busy;
+	if (!busy)
+		mmu_notifier_busy = 1;
+	spin_unlock(&mmn_lock);
+	if (busy)
+		return -EBUSY;
+
+	vma->vm_flags |= VM_PFNMAP;
+	vma->vm_ops = &mmn_vm_ops;
+
+	mmu_notifier_init(&mmu_notifier, &mmn_ops, current->mm);
+	mmu_notifier_register(&mmu_notifier);
+
+	return 0;
+}
+
+static const struct file_operations mmn_fops =
+{
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.mmap		= mmn_mmap,
+};
+
+static struct miscdevice mmn_miscdev =
+{
+	.minor	= MISC_DYNAMIC_MINOR,
+	.name	= "mmn",
+	.fops	= &mmn_fops
+};
+
+static int __init mmn_init(void)
+{
+	if (misc_register(&mmn_miscdev)) {
+		printk(KERN_ERR "mmn: unable to register device\n");
+		return -EIO;
+	}
+	return 0;
+}
+
+static void __exit mmn_exit(void)
+{
+	misc_deregister(&mmn_miscdev);
+}
+
+MODULE_DESCRIPTION("mmu_notifier skeleton driver");
+MODULE_LICENSE("GPL");
+
+module_init(mmn_init);
+module_exit(mmn_exit);
+
Index: linux-2.6/drivers/char/Kconfig
===================================================================
--- linux-2.6.orig/drivers/char/Kconfig
+++ linux-2.6/drivers/char/Kconfig
@@ -4,6 +4,10 @@
 
 menu "Character devices"
 
+config MMU_NOTIFIER_SKEL
+	tristate "MMU Notifier skeleton driver"
+	default n
+
 config VT
 	bool "Virtual terminal" if EMBEDDED
 	depends on !S390
Index: linux-2.6/drivers/char/Makefile
===================================================================
--- linux-2.6.orig/drivers/char/Makefile
+++ linux-2.6/drivers/char/Makefile
@@ -97,6 +97,7 @@ obj-$(CONFIG_CS5535_GPIO)	+= cs5535_gpio
 obj-$(CONFIG_GPIO_VR41XX)	+= vr41xx_giu.o
 obj-$(CONFIG_GPIO_TB0219)	+= tb0219.o
 obj-$(CONFIG_TELCLOCK)		+= tlclk.o
+obj-$(CONFIG_MMU_NOTIFIER_SKEL) += mmu_notifier_skel.o
 
 obj-$(CONFIG_MWAVE)		+= mwave/
 obj-$(CONFIG_AGP)		+= agp/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
