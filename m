Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep12-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050827220309.PVWJ1863.amsfep12-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 28 Aug 2005 00:03:09 +0200
Message-Id: <20050827220310.580707000@twins>
References: <20050827215756.726585000@twins>
Date: Sat, 27 Aug 2005 23:58:00 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 4/6] CART Implementation
Content-Disposition: inline; filename=cart-cart-stats.patch
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
 
+extern struct seq_operations cart_op;
+static int cart_open(struct inode *inode, struct file *file)
+{
+       (void)inode;
+       return seq_open(file, &cart_op);
+}
+
+static struct file_operations cart_file_operations = {
+       .open           = cart_open,
+       .read           = seq_read,
+       .llseek         = seq_lseek,
+       .release        = seq_release,
+};
+
 extern struct seq_operations nonresident_op;
 static int nonresident_open(struct inode *inode, struct file *file)
 {
@@ -616,6 +630,7 @@ void __init proc_misc_init(void)
 	create_seq_entry("interrupts", 0, &proc_interrupts_operations);
 	create_seq_entry("slabinfo",S_IWUSR|S_IRUGO,&proc_slabinfo_operations);
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+	create_seq_entry("cart",S_IRUGO, &cart_file_operations);
 	create_seq_entry("nonresident",S_IRUGO, &nonresident_file_operations);
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
Index: linux-2.6-cart/mm/cart.c
===================================================================
--- linux-2.6-cart.orig/mm/cart.c
+++ linux-2.6-cart/mm/cart.c
@@ -241,3 +241,89 @@ void __cart_remember(struct zone *zone, 
 		if (likely(size_B1)) --size_B1;
 	}
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
+		spin_lock_irq(&zone->lru_lock);
+		seq_printf(m, "\n\n======> zone: %lu <=====\n", (unsigned long)zone);
+		seq_printf(m, "struct zone values:\n");
+		seq_printf(m, "  zone->nr_active: %lu\n", zone->nr_active);
+		seq_printf(m, "  zone->nr_inactive: %lu\n", zone->nr_inactive);
+		seq_printf(m, "  zone->nr_evicted_active: %lu\n", zone->nr_evicted_active);
+		seq_printf(m, "  zone->nr_shortterm: %lu\n", zone->nr_shortterm);
+		seq_printf(m, "  zone->cart_p: %lu\n", zone->nr_p);
+		seq_printf(m, "  zone->cart_q: %lu\n", zone->nr_q);
+		seq_printf(m, "  zone->present_pages: %lu\n", zone->present_pages);
+		seq_printf(m, "  zone->free_pages: %lu\n", zone->free_pages);
+		seq_printf(m, "  zone->pages_min: %lu\n", zone->pages_min);
+		seq_printf(m, "  zone->pages_low: %lu\n", zone->pages_low);
+		seq_printf(m, "  zone->pages_high: %lu\n", zone->pages_high);
+
+		seq_printf(m, "\n");
+		seq_printf(m, "implicit values:\n");
+		seq_printf(m, "  zone->nr_evicted_longterm: %lu\n", size_B2);
+		seq_printf(m, "  zone->nr_longterm: %lu\n", nr_Nl);
+		seq_printf(m, "  zone->cart_c: %lu\n", cart_cT);
+
+		seq_printf(m, "\n");
+		seq_printf(m, "counted values:\n");
+
+		{
+			struct page *page;
+			unsigned long active = 0, s1 = 0, l1 = 0;
+			unsigned long inactive = 0, s2 = 0, l2 = 0;
+			list_for_each_entry(page, &zone->active_list, lru) {
+				++active;
+				if (PageLongTerm(page)) ++l1;
+				else ++s1;
+			}
+			list_for_each_entry(page, &zone->inactive_list, lru) {
+				++inactive;
+				if (PageLongTerm(page)) ++l2;
+				else ++s2;
+			}
+			seq_printf(m, "  zone->nr_active: %lu (%lu, %lu)\n", active, s1, l1);
+			seq_printf(m, "  zone->nr_inactive: %lu (%lu, %lu)\n", inactive, s2, l2);
+			seq_printf(m, "  zone->nr_shortterm: %lu\n", s1+s2);
+			seq_printf(m, "  zone->nr_longterm: %lu\n", l1+l2);
+		}
+
+		spin_unlock_irq(&zone->lru_lock);
+	}
+
+	return 0;
+}
+
+struct seq_operations cart_op = {
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
