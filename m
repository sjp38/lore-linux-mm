Message-ID: <3EB04FE4.6000404@us.ibm.com>
Date: Wed, 30 Apr 2003 15:36:20 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: Memory allocation problem
References: <20030430221438.16759.qmail@webmail35.rediffmail.com>
Content-Type: multipart/mixed;
 boundary="------------090506030400040105010907"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: anand kumar <a_santha@rediffmail.com>
Cc: linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090506030400040105010907
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

anand kumar wrote:
> We are developing a PCI driver for a specialized hardware which
> needs blocks of physically contiguous memory regions of
> 32 KB. We need to allocate 514 such blocks for a total of 16 MB
> We were using an ioctl implementation in the driver which uses
> kmalloc() to allocate the required memory blocks. 
> kmalloc()(GFP_KERNEL)
> fails after allocating some 250 blocks of memory (probably due to 
> fragmentation).
> We then tried using __get_free_pages() and the result was the 
> same.

Well, kmalloc() falls back to __get_free_pages() eventually (after going
through the slab cache), so it isn't much of a surprise that both failed.

> Even though the free pages in zone NORMAL and DMA were 10000 and
> 1500 respectively.

Can you try this on a kernel that has /proc/buddyinfo?  It exports the
buddy allocators internal structures so that you can see the
fragmentation.  buddyinfo has been in 2.5 since ~2.5.35.  There may even
be a 2.4 version floating around...

If you can post some code too, it might be helpful.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------090506030400040105010907
Content-Type: text/plain;
 name="buddyinfo-2.5.34-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="buddyinfo-2.5.34-0.patch"

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.508.1.116 -> 1.513  
#	     mm/page_alloc.c	1.89.1.8 -> 1.92   
#	 fs/proc/proc_misc.c	1.34.1.2 -> 1.36   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/09/09	haveblue@elm3b96.(none)	1.513
# Merge elm3b96.(none):/work/dave/bk/linux-2.5
# into elm3b96.(none):/work/dave/bk/linux-2.5-buddyinfo
# --------------------------------------------
#
diff -Nru a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
--- a/fs/proc/proc_misc.c	Wed Sep 11 10:45:01 2002
+++ b/fs/proc/proc_misc.c	Wed Sep 11 10:45:01 2002
@@ -208,6 +208,20 @@
 #undef K
 }
 
+extern struct seq_operations fragmentation_op;
+static int fragmentation_open(struct inode *inode, struct file *file)
+{
+	(void)inode;
+	return seq_open(file, &fragmentation_op);
+}
+
+static struct file_operations fragmentation_file_operations = {
+	open:		fragmentation_open,
+	read:		seq_read,
+	llseek:		seq_lseek,
+	release:	seq_release,
+};
+
 static int version_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
@@ -624,6 +638,7 @@
 	create_seq_entry("partitions", 0, &proc_partitions_operations);
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
+	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
 #ifdef CONFIG_MODULES
 	create_seq_entry("modules", 0, &proc_modules_operations);
 	create_seq_entry("ksyms", 0, &proc_ksyms_operations);
diff -Nru a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c	Wed Sep 11 10:45:01 2002
+++ b/mm/page_alloc.c	Wed Sep 11 10:45:01 2002
@@ -949,3 +949,69 @@
 }
 
 __setup("memfrac=", setup_mem_frac);
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *frag_start(struct seq_file *m, loff_t *pos)
+{
+	pg_data_t *pgdat;
+	loff_t node = *pos;
+
+	for (pgdat = pgdat_list; pgdat && node; pgdat = pgdat->pgdat_next)
+		--node;
+
+	return pgdat;
+}
+
+static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+
+	(*pos)++;
+	return pgdat->pgdat_next;
+}
+
+static void frag_stop(struct seq_file *m, void *arg)
+{
+}
+
+/* 
+ * This walks the freelist for each zone. Whilst this is slow, I'd rather 
+ * be slow here than slow down the fast path by keeping stats - mjbligh
+ */
+static int frag_show(struct seq_file *m, void *arg)
+{
+	pg_data_t *pgdat = (pg_data_t *)arg;
+	zone_t *zone, *node_zones = pgdat->node_zones;
+	unsigned long flags;
+	int order;
+
+	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
+		if (!zone->size)
+			continue;
+
+		spin_lock_irqsave(&zone->lock, flags);
+		seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
+		for (order = 0; order < MAX_ORDER; ++order) {
+			unsigned long nr_bufs = 0;
+			list_t *elem;
+			list_for_each(elem, &zone->free_area[order].free_list)
+				++nr_bufs;
+			seq_printf(m, "%6lu ", nr_bufs);
+		}
+		spin_unlock_irqrestore(&zone->lock, flags);
+		seq_putc(m, '\n');
+	}
+	return 0;
+}
+
+struct seq_operations fragmentation_op = {
+	start:	frag_start,
+	next:	frag_next,
+	stop:	frag_stop,
+	show:	frag_show,
+};
+
+#endif /* CONFIG_PROC_FS */

--------------090506030400040105010907--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
