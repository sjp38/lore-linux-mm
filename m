Message-ID: <3D6A4FBF.806F2D89@us.ibm.com>
Date: Mon, 26 Aug 2002 08:56:47 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] add vmalloc instrumentation
Content-Type: multipart/mixed;
 boundary="------------0245603C77A3B13BC1776157"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------0245603C77A3B13BC1776157
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

I run out of vmalloc space fairly often.  This patch helps me to figure
out whether I'm seeing vmalloc space fragmentation, or I've actually out
of vmalloc area.  It adds 3 fields to /proc/meminfo: total vmalloc
space, used vmalloc space, and the largest remaining chunk of free
vmalloc space.   
-- 
Dave Hansen
haveblue@us.ibm.com
--------------0245603C77A3B13BC1776157
Content-Type: text/plain; charset=us-ascii;
 name="vmalloc-stats-2.5.31+bk-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vmalloc-stats-2.5.31+bk-1.patch"

--- linux-2.5/fs/proc/proc_misc.c	Tue Aug 13 15:40:44 2002
+++ linux-2.5-vmalloc-stats-work/fs/proc/proc_misc.c	Mon Aug 26 08:43:17 2002
@@ -37,6 +37,7 @@
 #include <linux/smp_lock.h>
 #include <linux/seq_file.h>
 #include <linux/times.h>
+#include <linux/vmalloc.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -126,6 +127,41 @@
 	return proc_calc_metrics(page, start, off, count, eof, len);
 }
 
+struct vmalloc_info {
+	unsigned long used;
+	unsigned long largest_chunk;
+};
+
+static struct vmalloc_info get_vmalloc_info(void)
+{
+	unsigned long addr = VMALLOC_START;
+	struct vm_struct** p;
+	struct vm_struct* tmp;
+	struct vmalloc_info vmi;
+	vmi.used = 0;
+
+	read_lock(&vmlist_lock);
+	if( !vmlist ) {
+		vmi.largest_chunk = (unsigned long)vmlist->addr-VMALLOC_START;
+	} else {
+		vmi.largest_chunk = 0;
+	}
+	
+        for (p = &vmlist; (tmp = *p) ;p = &tmp->next) {
+		unsigned long free_area_size = 
+			(unsigned long)tmp->addr - (unsigned long)addr;
+		vmi.used += tmp->size;
+                if (vmi.largest_chunk < free_area_size ) {
+                        vmi.largest_chunk = free_area_size;
+		}
+                addr = tmp->size + (unsigned long)tmp->addr;
+        }
+	if( VMALLOC_END-addr > vmi.largest_chunk )
+		vmi.largest_chunk = (VMALLOC_END-addr);
+	read_unlock(&vmlist_lock);
+	return vmi;
+}
+
 extern atomic_t vm_committed_space;
 
 static int meminfo_read_proc(char *page, char **start, off_t off,
@@ -134,7 +170,9 @@
 	struct sysinfo i;
 	int len, committed;
 	struct page_state ps;
-
+	unsigned long vmtot;
+	struct vmalloc_info vmi;
+	
 	get_page_state(&ps);
 /*
  * display in kilobytes.
@@ -143,6 +181,11 @@
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_read(&vm_committed_space);
+	
+	vmtot = (VMALLOC_END-VMALLOC_START)>>10;
+	vmi = get_vmalloc_info();
+	vmi.used >>= 10;
+	vmi.largest_chunk >>= 10;
 
 	/*
 	 * Tagged format, for easy grepping and expansion.
@@ -165,7 +208,10 @@
 		"Writeback:    %8lu kB\n"
 		"Committed_AS: %8u kB\n"
 		"PageTables:   %8lu kB\n"
-		"ReverseMaps:  %8lu\n",
+		"ReverseMaps:  %8lu\n"
+		"VmalTotal:    %8lu kB\n"
+		"VmalUsed:     %8lu kB\n"
+		"VmalChunk:    %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.sharedram),
@@ -183,7 +229,10 @@
 		K(ps.nr_writeback),
 		K(committed),
 		K(ps.nr_page_table_pages),
-		ps.nr_reverse_maps
+		ps.nr_reverse_maps,
+		vmtot,
+		vmi.used,
+		vmi.largest_chunk
 		);
 
 	return proc_calc_metrics(page, start, off, count, eof, len);

--------------0245603C77A3B13BC1776157--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
