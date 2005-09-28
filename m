Date: Wed, 28 Sep 2005 16:29:29 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: vmtrace
Message-ID: <20050928192929.GA19059@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

Hi,

The sequence of pages which a given process or workload accesses during
its lifetime, a.k.a. "reference trace", is very important information.

It has been used in the past for comparison of page replacement
algorithms and other optimizations.

We've been talking on IRC on how to generate reference traces for
memory accesses, and a suggestion came up to periodically unmap all
present pte's of a given process. The following patch implements a
"kptecleaner" thread which is woken at a certain interval (hardcoded to
HZ/2 at present) which does that, copying the pte walking functions from
zap_pte_range().

Note: The patch lacks "pte_disable"/"pte_enable" macro pair (those are
supposed to operate on a free bit in the flags field of the page table
which was defined as PTE_DISABLE) and "pte_presprotect" macro to disable
the PTE_PRESENT bit. I had that written down but _I LOST MY LAPTOP_ with 
the complete patch inside :(

Here is how the patch works: You write the target UID into
/proc/vmtrace_uid and the "kptecleaner" thread begins disabling the
present bit of every pte for all processes for the target UID. The
pagefault path records the addresses via relayfs.

Here is is the plotting of virtual time versus user address for a few
programs:

compilation of a small C file with gcc
http://master.kernel.org/~marcelo/gcc.png

And with crippled disabling of pte's (thats why the text accesses
are not present: because refaulting was not being catch, but still
interesting data in that one can see the sequential nature of memory
accesses by these programs). 

mmap002 from "memtest"
http://master.kernel.org/~marcelo/mmap002.png 

"qsbench"
http://master.kernel.org/~marcelo/qsbench.png

Scott Kaplan wrote a much more complete patch for v2.4 to record memory
accesses (along with read/write syscalls, and others) and generate a reference
trace. http://www.cs.amherst.edu/~sfkaplan/research/kVMTrace/

Scott, do you have any plans to port your work to v2.6? Relayfs (present
in recent v2.6 kernels) implements a mechanism to send data to userspace
which is very convenient.


diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/include/linux/vmtrace.h linux-2.6.13/include/linux/vmtrace.h
--- linux-2.6.13.orig/include/linux/vmtrace.h	1969-12-31 21:00:00.000000000 -0300
+++ linux-2.6.13/include/linux/vmtrace.h	2005-09-16 10:55:21.000000000 -0300
@@ -0,0 +1,11 @@
+
+struct vm_trace_entry {
+	unsigned long inode;
+	unsigned long bdev;
+	unsigned long offset;
+	unsigned long len;
+	unsigned long prot;
+	pid_t pid;
+	unsigned long tstamp;
+};
+
diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/Makefile linux-2.6.13/mm/Makefile
--- linux-2.6.13.orig/mm/Makefile	2005-09-16 10:24:04.000000000 -0300
+++ linux-2.6.13/mm/Makefile	2005-09-16 12:23:14.000000000 -0300
@@ -20,3 +20,4 @@
 obj-$(CONFIG_TINY_SHMEM) += tiny-shmem.o
 obj-$(CONFIG_MEMORY_HOTPLUG) += memory_hotplug.o
 obj-$(CONFIG_FS_XIP) += filemap_xip.o
+obj-$(CONFIG_VMTRACE) += vmtrace.o
diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/memory.c linux-2.6.13/mm/memory.c
--- linux-2.6.13.orig/mm/memory.c	2005-09-16 10:24:04.000000000 -0300
+++ linux-2.6.13/mm/memory.c	2005-09-20 19:07:39.000000000 -0300
@@ -351,7 +351,7 @@
 	unsigned long pfn;
 
 	/* pte contains position in swap or file, so copy. */
-	if (unlikely(!pte_present(pte))) {
+	if (unlikely(!pte_present(pte)) && !pte_disabled(pte)) {
 		if (!pte_file(pte)) {
 			swap_duplicate(pte_to_swp_entry(pte));
 			/* make sure dst_mm is on swapoff's mmlist. */
@@ -536,7 +536,7 @@
 		pte_t ptent = *pte;
 		if (pte_none(ptent))
 			continue;
-		if (pte_present(ptent)) {
+		if (pte_present(ptent) || pte_disabled(ptent)) {
 			struct page *page = NULL;
 			unsigned long pfn = pte_pfn(ptent);
 			if (pfn_valid(pfn)) {
@@ -579,7 +579,7 @@
 			else if (pte_young(ptent))
 				mark_page_accessed(page);
 			tlb->freed++;
-			page_remove_rmap(page);
+			__page_remove_rmap(page, ptent);
 			tlb_remove_page(tlb, page);
 			continue;
 		}
@@ -2004,6 +2004,15 @@
 
 	entry = *pte;
 	if (!pte_present(entry)) {
+		vmtrace(vma, address);
+		if (pte_disabled(entry)) {
+			set_pte_at(vma->vm_mm, address, pte, pte_enable(pte_mkpresent(entry)));
+			flush_tlb_page(vma, address);
+			update_mmu_cache(vma, address, entry);
+			pte_unmap(pte);
+			spin_unlock(&mm->page_table_lock);
+			return VM_FAULT_MINOR;
+		}
 		/*
 		 * If it truly wasn't present, we know that kswapd
 		 * and the PTE updates will not touch it later. So
diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/page_alloc.c linux-2.6.13/mm/page_alloc.c
--- linux-2.6.13.orig/mm/page_alloc.c	2005-09-16 10:24:04.000000000 -0300
+++ linux-2.6.13/mm/page_alloc.c	2005-09-20 16:34:25.000000000 -0300
@@ -122,13 +122,19 @@
 	return 0;
 }
 
-static void bad_page(const char *function, struct page *page)
+
+void dump_page(struct page *page, char *function)
 {
 	printk(KERN_EMERG "Bad page state at %s (in process '%s', page %p)\n",
 		function, current->comm, page);
 	printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
 		(int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
 		page->mapping, page_mapcount(page), page_count(page));
+}
+
+static void bad_page(const char *function, struct page *page)
+{
+	dump_page(page, function);
 	printk(KERN_EMERG "Backtrace:\n");
 	dump_stack();
 	printk(KERN_EMERG "Trying to fix it up, but a reboot is needed\n");
diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/rmap.c linux-2.6.13/mm/rmap.c
--- linux-2.6.13.orig/mm/rmap.c	2005-09-16 10:24:04.000000000 -0300
+++ linux-2.6.13/mm/rmap.c	2005-09-20 16:52:57.000000000 -0300
@@ -477,18 +477,32 @@
 		inc_page_state(nr_mapped);
 }
 
+void page_remove_rmap(struct page * page)
+{
+	__page_remove_rmap(page, NULL);
+}
+
+void dump_pte(pte_t pte)
+{
+	printk(KERN_ERR "pte.low:%lx\n", pte.pte_low);
+}
+
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
  *
  * Caller needs to hold the mm->page_table_lock.
  */
-void page_remove_rmap(struct page *page)
+void __page_remove_rmap(struct page *page, pte_t pte)
 {
 	BUG_ON(PageReserved(page));
 
 	if (atomic_add_negative(-1, &page->_mapcount)) {
-		BUG_ON(page_mapcount(page) < 0);
+		if (page_mapcount(page) < 0) {
+			dump_page(page, "__page_remove_rmap");
+			dump_pte(pte);
+			BUG();
+		}
 		/*
 		 * It would be tidy to reset the PageAnon mapping here,
 		 * but that might overwrite a racing page_add_anon_rmap
diff -Nur --exclude-from=/home/marcelo/excl linux-2.6.13.orig/mm/vmtrace.c linux-2.6.13/mm/vmtrace.c
--- linux-2.6.13.orig/mm/vmtrace.c	1969-12-31 21:00:00.000000000 -0300
+++ linux-2.6.13/mm/vmtrace.c	2005-09-20 19:04:35.000000000 -0300
@@ -0,0 +1,251 @@
+#include <linux/slab.h>
+#include <linux/sched.h>
+#include <linux/fs.h>
+#include <linux/relayfs_fs.h>
+#include <linux/proc_fs.h>
+#include <linux/kthread.h>
+#include <linux/vmtrace.h>
+#include <asm/uaccess.h>
+#include <asm/tlb.h>
+
+struct rchan *vmtrace_chan = NULL;
+static struct proc_dir_entry *vmtrace_proc_file = NULL;
+uid_t vmtrace_uid = -1;
+static int ptecleaner_stop = 0;
+struct task_struct *cleaner_tsk = NULL;
+
+#define SUBBUF_SIZE (128 * 1024)
+#define N_SUBBUFS 8
+
+static struct timer_list ptecleaner_timer;
+
+static void start_vmtrace_thread(void);
+
+inline int vmtrace_match(uid_t uid)
+{
+	return (uid == vmtrace_uid);
+}
+
+static void ptecleaner_timer_expire(unsigned long exp)
+{
+	if (cleaner_tsk)
+		wake_up_process(cleaner_tsk);
+	mod_timer(&ptecleaner_timer, jiffies + (HZ/2));
+}
+
+inline void vmtrace(struct vm_area_struct *vma, unsigned long offset) 
+{
+        if (vmtrace_match(current->uid) && vmtrace_chan) {
+		struct vm_trace_entry entry;
+		unsigned long i_ino = 0, bdev = 0;
+		if (vma->vm_file && vma->vm_file->f_dentry && vma->vm_file->f_dentry->d_inode) {
+			i_ino = vma->vm_file->f_dentry->d_inode->i_ino;
+			bdev = vma->vm_file->f_dentry->d_inode->i_rdev;
+		}
+		entry.inode = i_ino;
+		entry.bdev = bdev;
+		entry.offset = offset;
+		entry.len = 0;
+		entry.prot = (unsigned long)vma->vm_page_prot.pgprot;
+		entry.pid = current->pid;
+		entry.tstamp = 0;
+
+		__relay_write(vmtrace_chan, (void *) &entry, sizeof(struct vm_trace_entry));
+	}
+}
+
+int disabled_ptes = 0;
+
+static int proc_vmtrace_read(char *page, char **start,
+                             off_t off, int count,
+                             int *eof, void *data)
+{
+        int len;
+
+        len = sprintf(page, "vmtrace UID = %ld disabled_ptes = %d\n", vmtrace_uid, disabled_ptes);
+        return len;
+}
+
+static int proc_vmtrace_write(struct file *file, const char *buffer,
+				unsigned long count, void *data)
+{
+	int len;
+	char val;
+
+	if (copy_from_user(&val, buffer, sizeof(&val)))
+		return -EFAULT;
+
+	if (val == -1) {
+		ptecleaner_stop = 1;
+		vmtrace_uid = -1;
+	} else {
+		vmtrace_uid = simple_strtoul(&val, NULL, 10);
+		start_vmtrace_thread();
+	}
+
+	return sizeof(&val);
+}
+
+
+static void disable_pte_range(struct mmu_gather *tlb, pmd_t *pmd,
+                                unsigned long addr, unsigned long end)
+{
+        pte_t *pte;
+
+        pte = pte_offset_map(pmd, addr);
+        do {
+                pte_t ptent = *pte;
+                if (pte_none(ptent))
+                        continue;
+                if (ptent.pte_low & _PAGE_PRESENT) {
+			unsigned long pfn;
+			struct page *page;
+			pfn = pte_pfn(ptent);
+			if (pfn_valid(pfn)) {
+				page = pfn_to_page(pfn);
+				if (ptep_test_and_clear_dirty(NULL, addr, &ptent)) 
+					set_page_dirty(page);
+				set_pte_at(tlb->mm, addr, pte, pte_disable(pte_presprotect(ptent)));
+				tlb_remove_tlb_entry(tlb, pte, addr);
+				__flush_tlb();
+				disabled_ptes++;
+			}
+		}
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap(pte - 1);
+}
+
+static inline void disable_pmd_range(struct mmu_gather *tlb, pud_t *pud,
+                                unsigned long addr, unsigned long end)
+{
+        pmd_t *pmd;
+        unsigned long next;
+
+        pmd = pmd_offset(pud, addr);
+        do {
+                next = pmd_addr_end(addr, end);
+                if (pmd_none_or_clear_bad(pmd))
+                        continue;
+                disable_pte_range(tlb, pmd, addr, next);
+        } while (pmd++, addr = next, addr != end);
+}
+
+static inline void disable_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
+				unsigned long addr, unsigned long end)
+{
+
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+	        next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+                	continue;
+    	    disable_pmd_range(tlb, pud, addr, next);
+	} while (pud++, addr = next, addr != end);
+}
+
+static void ptecleaner_disable_range(struct mmu_gather *tlb, struct vm_area_struct *vma,
+                                unsigned long addr, unsigned long end)
+{
+        pgd_t *pgd;
+        unsigned long next;
+
+        BUG_ON(addr >= end);
+        tlb_start_vma(tlb, vma);
+        pgd = pgd_offset(vma->vm_mm, addr);
+        do {
+                next = pgd_addr_end(addr, end);
+                if (pgd_none_or_clear_bad(pgd))
+                        continue;
+                disable_pud_range(tlb, pgd, addr, next);
+        } while (pgd++, addr = next, addr != end);
+        tlb_end_vma(tlb, vma);
+}
+
+
+void ptecleaner_tskclean(struct vm_area_struct *vma, struct mmu_gather *tlb)
+{
+	unsigned long start, end, end_addr = -1;
+
+	for ( ; vma && vma->vm_start < end_addr; vma = vma->vm_next) {
+		start = vma->vm_start;
+		end = vma->vm_end;
+		ptecleaner_disable_range(tlb, vma, start, end);
+	}
+}
+
+int ptecleaner_tskwalk(void)
+{
+	struct task_struct *p;
+
+	for_each_process(p) {
+		struct vm_area_struct *vma;
+		struct mmu_gather *tlb;
+		struct mm_struct *mm;
+
+		if (!p->mm)
+			continue;
+		if (p->uid != vmtrace_uid)
+			continue;
+		if ((vma = p->mm->mmap) == NULL)
+			continue;
+
+		mm = p->mm;
+		
+		down_write(&mm->mmap_sem);
+		spin_lock(&mm->page_table_lock);
+		tlb = tlb_gather_mmu(mm, 1);
+		ptecleaner_tskclean(vma, tlb);
+	        tlb_finish_mmu(tlb, 0, -1);
+		spin_unlock(&mm->page_table_lock);
+		up_write(&mm->mmap_sem);
+	} 
+}
+
+static int ptecleaner(void *dummy)
+{
+	for ( ; ; ) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule();
+		ptecleaner_tskwalk();
+		if (ptecleaner_stop) {
+			del_timer(&ptecleaner_timer);
+			break;
+		}
+	}
+	ptecleaner_stop = 0;
+}
+
+static void start_vmtrace_thread(void)
+{
+	ptecleaner_timer.expires = jiffies + (HZ/2);
+	ptecleaner_timer.function = &ptecleaner_timer_expire;
+	ptecleaner_timer.data = NULL;
+	add_timer(&ptecleaner_timer);
+	cleaner_tsk = kthread_run(ptecleaner, NULL, "kptecleaner");
+}
+
+static void __init vmtrace_init(void)
+{
+	vmtrace_chan = relay_open("vmtrace", NULL, SUBBUF_SIZE,
+                                  N_SUBBUFS, NULL);
+        if (!vmtrace_chan)
+                printk("vmtrace channel creation failed\n");
+        else
+                printk("vmtrace channel ready\n");
+
+	vmtrace_proc_file = create_proc_entry("vmtrace_uid", 0644, NULL);
+	
+	if (vmtrace_proc_file) {
+		vmtrace_proc_file->read_proc = proc_vmtrace_read;
+		vmtrace_proc_file->write_proc = proc_vmtrace_write;
+		vmtrace_proc_file->data = NULL;
+	}
+	init_timer(&ptecleaner_timer);
+}
+
+late_initcall(vmtrace_init);
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
