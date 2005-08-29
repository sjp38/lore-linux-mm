Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep12-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050829044017.MZAZ1863.amsfep12-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Mon, 29 Aug 2005 06:40:17 +0200
Message-Id: <20050829044018.908467000@twins>
References: <20050829043132.908007000@twins>
Date: Mon, 29 Aug 2005 06:31:35 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][patch 2/6] CART Implementation ver 2
Content-Disposition: inline; filename=cart-nonresident-stats.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Index: linux-2.6-cart/fs/proc/proc_misc.c
===================================================================
--- linux-2.6-cart.orig/fs/proc/proc_misc.c
+++ linux-2.6-cart/fs/proc/proc_misc.c
@@ -233,6 +233,20 @@ static struct file_operations proc_zonei
 	.release	= seq_release,
 };
 
+extern struct seq_operations nonresident_op;
+static int nonresident_open(struct inode *inode, struct file *file)
+{
+       (void)inode;
+       return seq_open(file, &nonresident_op);
+}
+
+static struct file_operations nonresident_file_operations = {
+       .open           = nonresident_open,
+       .read           = seq_read,
+       .llseek         = seq_lseek,
+       .release        = seq_release,
+};
+
 static int version_read_proc(char *page, char **start, off_t off,
 				 int count, int *eof, void *data)
 {
@@ -602,6 +616,7 @@ void __init proc_misc_init(void)
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("nonresident",S_IRUGO, &nonresident_file_operations);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 	create_seq_entry("diskstats", 0, &proc_diskstats_operations);
Index: linux-2.6-cart/mm/nonresident.c
===================================================================
--- linux-2.6-cart.orig/mm/nonresident.c
+++ linux-2.6-cart/mm/nonresident.c
@@ -275,3 +275,74 @@ static int __init set_nonresident_factor
 }
 
 __setup("nonresident_factor=", set_nonresident_factor);
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *stats_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos < 0 || *pos >= (1 << nonres_shift))
+		return NULL;
+
+	m->private = (unsigned long)*pos;
+
+	return pos;
+}
+
+static void *stats_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	if (*pos < (1 << nonres_shift)-1) {
+		(*pos)++;
+		(unsigned long)m->private++;
+		return pos;
+	}
+	return NULL;
+}
+
+static void stats_stop(struct seq_file *m, void *arg)
+{
+}
+
+static void bucket_stats(struct nr_bucket * nr_bucket, int * b1, int * b2)
+{
+	unsigned int i, b[2] = {0, 0};
+	for (i = 0; i < 2; ++i) {
+		unsigned int j = nr_bucket->hand[i];
+		do
+		{
+			u32 *slot = &nr_bucket->slot[j];
+			if (!!(GET_FLAGS(*slot) & NR_list) != !!i)
+				break;
+
+			j = GET_INDEX(*slot);
+			++b[i];
+		} while (j != nr_bucket->hand[i]);
+	}
+	*b1=b[0];
+	*b2=b[1];
+}
+
+static int stats_show(struct seq_file *m, void *arg)
+{
+	unsigned int index = (unsigned long)m->private;
+	struct nr_bucket *nr_bucket = &nonres_table[index];
+	unsigned long flags;
+	unsigned int b1, b2;
+
+	spin_lock_irqsave(&nr_bucket->lock, flags);
+	bucket_stats(nr_bucket, &b1, &b2);
+	spin_unlock_irqrestore(&nr_bucket->lock, flags);
+	seq_printf(m, "%d\t%d\t%d\n", b1, b2, b1+b2);
+
+	return 0;
+}
+
+struct seq_operations nonresident_op = {
+	.start = stats_start,
+	.next = stats_next,
+	.stop = stats_stop,
+	.show = stats_show,
+};
+
+#endif /* CONFIG_PROC_FS */

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
