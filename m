From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20051230224342.765.35375.sendpatchset@twins.localnet>
In-Reply-To: <20051230223952.765.21096.sendpatchset@twins.localnet>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
Subject: [PATCH 9/9] clockpro-clockpro-stats.patch
Date: Fri, 30 Dec 2005 23:44:04 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@osdl.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Adds some /proc debugging information to the clockpro patch.

TODO:
 - use debugfs?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 fs/proc/proc_misc.c |   15 +++++++++++++
 mm/clockpro.c       |   60 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 75 insertions(+)

Index: linux-2.6-git/fs/proc/proc_misc.c
===================================================================
--- linux-2.6-git.orig/fs/proc/proc_misc.c
+++ linux-2.6-git/fs/proc/proc_misc.c
@@ -220,6 +220,20 @@
 	.release	= seq_release,
 };
 
+extern struct seq_operations clockpro_op;
+static int clockpro_open(struct inode *inode, struct file *file)
+{
+       (void)inode;
+       return seq_open(file, &clockpro_op);
+}
+
+static struct file_operations clockpro_file_operations = {
+       .open           = clockpro_open,
+       .read           = seq_read,
+       .llseek         = seq_lseek,
+       .release        = seq_release,
+};
+
 extern struct seq_operations zoneinfo_op;
 static int zoneinfo_open(struct inode *inode, struct file *file)
 {
@@ -602,6 +616,7 @@
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("clockpro",S_IRUGO, &clockpro_file_operations);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 	create_seq_entry("diskstats", 0, &proc_diskstats_operations);
Index: linux-2.6-git/mm/clockpro.c
--- linux-2.6-git.orig/mm/clockpro.c
+++ linux-2.6-git/mm/clockpro.c
@@ -555,3 +555,62 @@
 
 	mod_page_state(pgdeactivate, pgdeactivate);
 }
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *stats_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos != 0)
+		return NULL;
+
+	lru_add_drain();
+
+	return pos;
+}
+
+static void *stats_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	return NULL;
+}
+
+static void stats_stop(struct seq_file *m, void *arg)
+{
+}
+
+static int stats_show(struct seq_file *m, void *arg)
+{
+	struct zone *zone;
+	for_each_zone(zone) {
+		seq_printf(m, "\n\n======> zone: %lu <=====\n", (unsigned long)zone);
+		seq_printf(m, "struct zone values:\n");
+		seq_printf(m, "  zone->nr_resident: %lu\n", zone->nr_resident);
+		seq_printf(m, "  zone->nr_cold: %lu\n", zone->nr_cold);
+		seq_printf(m, "  zone->nr_cold_target: %lu\n", zone->nr_cold_target);
+		seq_printf(m, "  zone->nr_nonresident_scale: %lu\n", zone->nr_nonresident_scale);
+		seq_printf(m, "  zone->present_pages: %lu\n", zone->present_pages);
+		seq_printf(m, "  zone->free_pages: %lu\n", zone->free_pages);
+		seq_printf(m, "  zone->pages_min: %lu\n", zone->pages_min);
+		seq_printf(m, "  zone->pages_low: %lu\n", zone->pages_low);
+		seq_printf(m, "  zone->pages_high: %lu\n", zone->pages_high);
+
+		seq_printf(m, "\n");
+		seq_printf(m, "nonresident values:\n");
+		seq_printf(m, "  nonres_cycle: %lu\n", __sum_cpu_var(unsigned long, nonres_cycle));
+		seq_printf(m, "  T3-raw: %lu\n", __sum_cpu_var(unsigned long, nonres_count[NR_b1]));
+		seq_printf(m, "  T3-est: %u\n", nonresident_estimate());
+
+	}
+
+	return 0;
+}
+
+struct seq_operations clockpro_op = {
+	.start = stats_start,
+	.next = stats_next,
+	.stop = stats_stop,
+	.show = stats_show,
+};
+
+#endif /* CONFIG_PROC_FS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
