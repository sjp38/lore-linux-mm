Message-ID: <3E977215.2040300@us.ibm.com>
Date: Fri, 11 Apr 2003 18:55:33 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] per-node page breakout for /proc/<pid>/maps
Content-Type: multipart/mixed;
 boundary="------------050202090503000100010007"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050202090503000100010007
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

We're quite interested to see how effective our NUMA allocation
strategies are, and how fragmented things get.  The following patch
modifies /proc/<pid>/maps to display the number of pages each map has
allocated on each node of the system.

This should have few effects on non-numa machines.  It's aimed at
Martin's tree for now, but I figured I'd cc linux-mm just in case any
one else was interested.

Tested on 4-node 16-way NUMA-Q and 4-way SMP.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------050202090503000100010007
Content-Type: text/plain;
 name="pidmaps_nodepages-2.5.67-mjb1-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pidmaps_nodepages-2.5.67-mjb1-0.patch"

Only in linux-2.5.67-mjb1-pidmaps-nodepages/fs/proc: .task_mmu.c.swo
Only in linux-2.5.67-mjb1-pidmaps-nodepages/fs/proc: .task_mmu.c.swp
diff -ur linux-2.5.67-mjb1-clean/fs/proc/task_mmu.c linux-2.5.67-mjb1-pidmaps-nodepages/fs/proc/task_mmu.c
--- linux-2.5.67-mjb1-clean/fs/proc/task_mmu.c	Thu Apr 10 21:51:16 2003
+++ linux-2.5.67-mjb1-pidmaps-nodepages/fs/proc/task_mmu.c	Fri Apr 11 18:50:25 2003
@@ -2,6 +2,7 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
 #include <asm/uaccess.h>
+#include <asm/mmzone.h>
 
 char *task_mem(struct mm_struct *mm, char *buffer)
 {
@@ -111,7 +112,70 @@
 #define MAPS_LINE_FORMAT	(sizeof(void*) == 4 ? MAPS_LINE_FORMAT4 : MAPS_LINE_FORMAT8)
 #define MAPS_LINE_MAX	(sizeof(void*) == 4 ?  MAPS_LINE_MAX4 :  MAPS_LINE_MAX8)
 
-static int proc_pid_maps_get_line (char *buf, struct vm_area_struct *map)
+static int print_vma_nodepages(char* buf, struct mm_struct *mm, struct vm_area_struct *map)
+{
+	int retval = 0;
+	unsigned long vaddr = map->vm_start;
+	unsigned long vm_end = map->vm_end;
+	int pages_per_node[MAX_NR_NODES];
+	int i;
+
+	if (numnodes<=1)
+		goto out;
+		
+	for (i=0;i<numnodes;i++)
+		pages_per_node[i] = 0;
+
+	for (;vaddr < vm_end; vaddr += PAGE_SIZE) {
+		pgd_t *pgd;
+		pmd_t *pmd;
+		pte_t *ptep;
+		pte_t pte = __pte(0);
+		unsigned long pfn = 0;
+
+		spin_lock(&mm->page_table_lock);
+		pgd = pgd_offset(mm, vaddr);
+		if (pgd_none(*pgd) || pgd_bad(*pgd))
+			goto next;
+
+		pmd = pmd_offset(pgd, vaddr);
+		if (pmd_none(*pmd))
+			goto next;
+		if (pmd_huge(*pmd)) {
+			/* 
+			 * there have to be 86 gigillion ways to 
+			 * state hugetlb page size, or the area mapped
+			 * by a pmd entry, or ... 
+			 */
+			pages_per_node[page_to_pfn(pmd_page(*pmd))] 
+				+= PAGE_SIZE*PTRS_PER_PTE;
+			goto next;
+		}
+		if (pmd_bad(*pmd))
+			goto next;
+		
+		ptep = pte_offset_map(pmd, vaddr);
+		if (!ptep)
+			goto next;
+
+		pte = *ptep;
+	next:
+		spin_unlock(&mm->page_table_lock);
+		pfn = pte_pfn(pte);
+		if (pfn) /* don't count the zero page */
+			pages_per_node[pfn_to_nid(pfn)]++;
+	}
+	retval += sprintf(&buf[retval],"#");
+	for (i=0; i<numnodes; i++) 
+		retval += sprintf(&buf[retval], " %d", 
+				pages_per_node[i]);
+
+out:
+	return retval;
+}
+
+static int proc_pid_maps_get_line (char *buf, struct mm_struct *mm, 
+				   struct vm_area_struct *map)
 {
 	/* produce the next line */
 	char *line;
@@ -133,12 +197,56 @@
 	ino = 0;
 	if (map->vm_file != NULL) {
 		struct inode *inode = map->vm_file->f_dentry->d_inode;
+		int nplen, buf_left;
 		dev = inode->i_sb->s_dev;
 		ino = inode->i_ino;
+		/* 
+		 * this is relatively disgusting.  these functions are all
+		 * meant to print at the _end_ of the buffer that they're given.
+		 * I think this is to make the size calculation easier.
+		 *
+		 * if a print-into-buffer function is given a buffer, then 
+		 * just returns a pointer to that buffer, it may take
+		 * an extra run through the buffer to figure out how much
+		 * was actgually printed.  This way, you can figure it out 
+		 * by doing (buf_arg+buf_len)-returned_buf, instead of running
+		 * through it. 
+		 *
+		 * why we don't just print into the beginning of the buffer
+		 * and return the number of bytes written (like sprintf) I
+		 * don't know.
+		 *
+		 * it doesn't look like these need to be null-terminated
+		 * 
+		 * Dave Hansen <haveblue@us.ibm.com> 4-11-2003
+		 */
+
+		/* 
+		 * since most of print_vma_nodepages()'s output is in decimal,
+		 * and the number of nodes isn't known at compile time, it is 
+		 * hard to predetermine the length, which makes it extra
+		 * hard to print into the end of a buffer.
+		 *
+		 * here, we print to the beginning of the buffer, then move
+		 * it to them end
+		 */
+		nplen = print_vma_nodepages(buf, mm, map);
+		BUG_ON(nplen > (PAGE_SIZE/2));
+		/* leave space for the \n */
+		buf_left = PAGE_SIZE - nplen - 1;
+		memmove(buf+buf_left, buf, nplen);
+		memset(buf,0,nplen);
+		buf[PAGE_SIZE-1] = '\n';
+		
+		/* 
+		 * d_path is already designed to fill from the back of the buffer
+		 * to the front
+		 */
 		line = d_path(map->vm_file->f_dentry,
 			      map->vm_file->f_vfsmnt,
-			      buf, PAGE_SIZE);
-		buf[PAGE_SIZE-1] = '\n';
+			      buf, buf_left);
+		/* replace d_path's terminating NULL with a space */
+		buf[buf_left-1] = ' ';
 		line -= MAPS_LINE_MAX;
 		if(line < buf)
 			line = buf;
@@ -207,7 +315,7 @@
 			off -= PAGE_SIZE;
 			goto next;
 		}
-		len = proc_pid_maps_get_line(tmp, map);
+		len = proc_pid_maps_get_line(tmp, mm, map);
 		len -= off;
 		if (len > 0) {
 			if (retval+len > count) {
diff -ur linux-2.5.67-mjb1-clean/include/asm-i386/mmzone.h linux-2.5.67-mjb1-pidmaps-nodepages/include/asm-i386/mmzone.h
--- linux-2.5.67-mjb1-clean/include/asm-i386/mmzone.h	Thu Apr 10 21:51:23 2003
+++ linux-2.5.67-mjb1-pidmaps-nodepages/include/asm-i386/mmzone.h	Fri Apr 11 00:15:11 2003
@@ -8,7 +8,11 @@
 
 #include <asm/smp.h>
 
-#ifdef CONFIG_DISCONTIGMEM
+#ifndef CONFIG_DISCONTIGMEM
+
+#define pfn_to_nid(pfn)		(0)
+
+#else
 
 extern struct pglist_data *node_data[];
 

--------------050202090503000100010007--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
