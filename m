Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep17-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050911203418.RIEC1343.amsfep17-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 11 Sep 2005 22:34:18 +0200
Message-Id: <20050911203422.387822000@twins>
References: <20050911202540.581022000@twins>
Date: Sun, 11 Sep 2005 22:25:42 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 2/7] CART Implementation v3
Content-Disposition: inline; filename=cart-nonresident-stats.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Index: linux-2.6-git/fs/proc/proc_misc.c
===================================================================
--- linux-2.6-git.orig/fs/proc/proc_misc.c
+++ linux-2.6-git/fs/proc/proc_misc.c
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
Index: linux-2.6-git/mm/nonresident.c
===================================================================
--- linux-2.6-git.orig/mm/nonresident.c
+++ linux-2.6-git/mm/nonresident.c
@@ -370,3 +370,83 @@ static int __init set_nonresident_factor
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
+	m->private = (void*)(unsigned long)*pos;
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
+static void bucket_stats(struct nr_bucket * nr_bucket, int * b1, int * b2, int * free)
+{
+	unsigned long flags;
+	unsigned int i, b[3] = {0, 0, 0};
+
+	spin_lock_irqsave(&nr_bucket->lock, flags);
+	for (i = 0; i < 3; ++i) {
+		unsigned int j = nr_bucket->hand[i];
+		do
+		{
+			u32 *slot = &nr_bucket->slot[j];
+			if (GET_LISTID(*slot) != i)
+				break;
+			j = GET_INDEX(*slot);
+			++b[i];
+		} while (j != nr_bucket->hand[i]);
+	}
+	spin_unlock_irqrestore(&nr_bucket->lock, flags);
+
+	*b1=b[0];
+	*b2=b[1];
+	*free=b[2];
+}
+
+static int stats_show(struct seq_file *m, void *arg)
+{
+	unsigned int index = (unsigned long)m->private;
+	struct nr_bucket *nr_bucket = &nonres_table[index];
+	int b1, b2, free;
+
+	bucket_stats(nr_bucket, &b1, &b2, &free);
+	seq_printf(m, "%d\t%d\t%d", b1, b2, free);
+	if (index == 0) {
+		seq_printf(m, "\t%d\t%d\t%d",
+			   nonresident_count(NR_b1),
+			   nonresident_count(NR_b2),
+			   nonresident_count(NR_free));
+	}
+	seq_printf(m,"\n");
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
