Message-ID: <3E39EFF6.6050909@us.ibm.com>
Date: Thu, 30 Jan 2003 19:39:34 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] export NUMA allocation fragmentation
Content-Type: multipart/mixed;
 boundary="------------030007030407080109020501"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030007030407080109020501
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

The NUMA memory allocation support attempts to allocate pages close to
the CPUs that it is currently running on.  We have a hard time
determining how effective these strategies have been, or how fragmented
the allocations might get if a process is bounced around between nodes.
 This patch adds a new /proc/<pid> entry: nodepages.

It walks the process's vm_area_structs for all vaddr ranges, then
examines the ptes to determine on which node each virtual address
physically resides.

I'm a little worried about just taking the pte from __follow_page() and
dumping it into pte_pfn().  Is there something I should be testing for,
before I feed it along?

I've tested it on both NUMA and non-NUMA systems (see the pfn_to_nid()
changes).  The below are from a 4-quad 16-proc NUMAQ.

This is a process that allocates, then faults in a 256MB chunk of
memory, bound to CPU 4 (node 1).
curly:~# cat /proc/378/nodepages
Node 0 pages: 369
Node 1 pages: 65571
Node 2 pages: 0
Node 3 pages: 0

Here is the same thing, bound to CPU12 (node 3), probably forked on node
1, before it was bound.
Node 0 pages: 369
Node 1 pages: 2
Node 2 pages: 0
Node 3 pages: 65569

I would imagine that the pages on node 0 are from libc, which was
originally mapped on node 0.  The other processes inherit this.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------030007030407080109020501
Content-Type: text/plain;
 name="proc-pid-nodepages-2.5.59-mjb2-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="proc-pid-nodepages-2.5.59-mjb2-1.patch"

diff -ru linux-2.5.59-mjb2-clean/fs/proc/base.c linux-2.5.59-mjb2-vma-stat/fs/proc/base.c
--- linux-2.5.59-mjb2-clean/fs/proc/base.c	Wed Jan 29 19:02:49 2003
+++ linux-2.5.59-mjb2-vma-stat/fs/proc/base.c	Thu Jan 30 17:57:51 2003
@@ -45,6 +45,7 @@
 enum pid_directory_inos {
 	PROC_PID_INO = 2,
 	PROC_PID_STATUS,
+	PROC_PID_NODE_PAGES,
 	PROC_PID_MEM,
 	PROC_PID_CWD,
 	PROC_PID_ROOT,
@@ -72,6 +73,7 @@
   E(PROC_PID_FD,	"fd",		S_IFDIR|S_IRUSR|S_IXUSR),
   E(PROC_PID_ENVIRON,	"environ",	S_IFREG|S_IRUSR),
   E(PROC_PID_STATUS,	"status",	S_IFREG|S_IRUGO),
+  E(PROC_PID_NODE_PAGES,"nodepages",	S_IFREG|S_IRUGO),
   E(PROC_PID_CMDLINE,	"cmdline",	S_IFREG|S_IRUGO),
   E(PROC_PID_STAT,	"stat",		S_IFREG|S_IRUGO),
   E(PROC_PID_STATM,	"statm",	S_IFREG|S_IRUGO),
@@ -102,6 +104,7 @@
 int proc_pid_status(struct task_struct*,char*);
 int proc_pid_statm(struct task_struct*,char*);
 int proc_pid_cpu(struct task_struct*,char*);
+int proc_pid_nodepages(struct task_struct*,char*);
 
 static int proc_fd_link(struct inode *inode, struct dentry **dentry, struct vfsmount **mnt)
 {
@@ -1012,6 +1015,10 @@
 		case PROC_PID_STATUS:
 			inode->i_fop = &proc_info_file_operations;
 			ei->op.proc_read = proc_pid_status;
+			break;
+		case PROC_PID_NODE_PAGES:
+			inode->i_fop = &proc_info_file_operations;
+			ei->op.proc_read = proc_pid_nodepages;
 			break;
 		case PROC_PID_STAT:
 			inode->i_fop = &proc_info_file_operations;
diff -ru linux-2.5.59-mjb2-clean/fs/proc/task_mmu.c linux-2.5.59-mjb2-vma-stat/fs/proc/task_mmu.c
--- linux-2.5.59-mjb2-clean/fs/proc/task_mmu.c	Wed Jan 29 19:02:49 2003
+++ linux-2.5.59-mjb2-vma-stat/fs/proc/task_mmu.c	Thu Jan 30 19:25:54 2003
@@ -2,6 +2,7 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
 #include <asm/uaccess.h>
+#include <asm/mmzone.h>
 
 char *task_mem(struct mm_struct *mm, char *buffer)
 {
@@ -243,5 +244,56 @@
 out_free1:
 	free_page((unsigned long)kbuf);
 out:
+	return retval;
+}
+
+extern pte_t
+__follow_page(struct mm_struct *mm, unsigned long address);
+
+ssize_t proc_pid_nodepages(struct task_struct *task, char* buf)
+{
+	struct mm_struct *mm;
+	struct vm_area_struct * map;
+	long retval;
+	int nids[MAX_NR_NODES];
+	int i;
+
+	for(i=0;i<numnodes;i++)
+		nids[i] = 0;
+	
+	/*
+	 * We might sleep getting the page, so get it first.
+	 */
+	mm = get_task_mm(task);
+
+	if(!mm) {
+		printk("%s(): !mm !!\n", __FUNCTION__);
+		return 0;
+	}
+	
+	retval = 0;
+
+	down_read(&mm->mmap_sem);
+	map = mm->mmap;
+	while (map) {
+		unsigned long vaddr = map->vm_start;
+		unsigned long vm_end = map->vm_end;
+		pte_t pte;
+		unsigned long pfn;
+		
+		for(;vaddr < vm_end; vaddr += PAGE_SIZE) {
+			pte = __follow_page(mm, vaddr);
+			pfn = pte_pfn(pte);
+			nids[pfn_to_nid(pfn)]++;
+		}
+		map = map->vm_next;
+	}
+	up_read(&mm->mmap_sem);
+	mmput(mm);
+
+	for(i=0;i<numnodes;i++) {
+		retval += sprintf(&buf[retval], "Node %d pages: %d\n", 
+				i, nids[i]);
+	}
 	return retval;
 }
diff -ru linux-2.5.59-mjb2-clean/include/asm-i386/mmzone.h linux-2.5.59-mjb2-vma-stat/include/asm-i386/mmzone.h
--- linux-2.5.59-mjb2-clean/include/asm-i386/mmzone.h	Wed Jan 29 19:02:38 2003
+++ linux-2.5.59-mjb2-vma-stat/include/asm-i386/mmzone.h	Thu Jan 30 19:25:54 2003
@@ -8,14 +8,17 @@
 
 #include <asm/smp.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_DISCONTIGMEM
+
+#define pfn_to_nid(pfn)		(0)
+
+#else
 
 #ifdef CONFIG_X86_NUMAQ
 #include <asm/numaq.h>
 #elif CONFIG_X86_SUMMIT
 #include <asm/srat.h>
 #else
-#define pfn_to_nid(pfn)		(0)
 #endif /* CONFIG_X86_NUMAQ */
 
 extern struct pglist_data *node_data[];
diff -ru linux-2.5.59-mjb2-clean/mm/memory.c linux-2.5.59-mjb2-vma-stat/mm/memory.c
--- linux-2.5.59-mjb2-clean/mm/memory.c	Wed Jan 29 19:02:54 2003
+++ linux-2.5.59-mjb2-vma-stat/mm/memory.c	Thu Jan 30 16:45:55 2003
@@ -612,13 +612,12 @@
  * Do a quick page-table lookup for a single page.
  * mm->page_table_lock must be held.
  */
-struct page *
-follow_page(struct mm_struct *mm, unsigned long address, int write) 
+pte_t 
+__follow_page(struct mm_struct *mm, unsigned long address)
 {
 	pgd_t *pgd;
 	pmd_t *pmd;
 	pte_t *ptep, pte;
-	unsigned long pfn;
 
 	pgd = pgd_offset(mm, address);
 	if (pgd_none(*pgd) || pgd_bad(*pgd))
@@ -629,11 +628,25 @@
 		goto out;
 
 	ptep = pte_offset_map(pmd, address);
-	if (!ptep)
+	if (!ptep) {
+		pte.pte_low = 0; //__bad_page();		
+		pte.pte_high = 0;
 		goto out;
-
+	}
 	pte = *ptep;
 	pte_unmap(ptep);
+
+out:
+	return pte;
+}
+	
+struct page *
+follow_page(struct mm_struct *mm, unsigned long address, int write) 
+{
+	pte_t pte;	
+	unsigned long pfn;
+	
+	pte = __follow_page(mm, address);
 	if (pte_present(pte)) {
 		if (!write || (pte_write(pte) && pte_dirty(pte))) {
 			pfn = pte_pfn(pte);
@@ -642,7 +655,6 @@
 		}
 	}
 
-out:
 	return NULL;
 }
 

--------------030007030407080109020501--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
