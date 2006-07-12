From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:44:04 +0200
Message-Id: <20060712144404.16998.25900.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 36/39] mm: refault histogram for non-resident policies
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Adds a refault histogram for those policies that use nonresident page tracking.
Based on ideas and code from Rik van Riel.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl

 fs/proc/proc_misc.c              |   23 +++++++
 include/linux/nonresident-cart.h |    2 
 include/linux/nonresident.h      |    4 -
 mm/Kconfig                       |    5 +
 mm/Makefile                      |    1 
 mm/cart.c                        |    4 -
 mm/clockpro.c                    |    8 +-
 mm/nonresident-cart.c            |  110 +++++++++++++++++++++++++++++++++----
 mm/nonresident.c                 |   17 ++++-
 mm/refault.c                     |  114 +++++++++++++++++++++++++++++++++++++++
 10 files changed, 262 insertions(+), 26 deletions(-)

Index: linux-2.6/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.orig/fs/proc/proc_misc.c	2006-07-12 16:07:25.000000000 +0200
+++ linux-2.6/fs/proc/proc_misc.c	2006-07-12 16:09:24.000000000 +0200
@@ -220,6 +220,26 @@ static struct file_operations fragmentat
 	.release	= seq_release,
 };
 
+#ifdef CONFIG_MM_REFAULT
+extern struct seq_operations refault_op;
+static int refault_open(struct inode *inode, struct file *file)
+{
+	(void)inode;
+	return seq_open(file, &refault_op);
+}
+
+extern ssize_t refault_write(struct file *, const char __user *buf,
+		             size_t count, loff_t *);
+
+static struct file_operations refault_file_operations = {
+	.open           = refault_open,
+	.read           = seq_read,
+	.llseek         = seq_lseek,
+	.release        = seq_release,
+	.write		= refault_write,
+};
+#endif
+
 extern struct seq_operations zoneinfo_op;
 static int zoneinfo_open(struct inode *inode, struct file *file)
 {
@@ -692,6 +712,9 @@ void __init proc_misc_init(void)
 #endif
 #endif
 	create_seq_entry("buddyinfo",S_IRUGO, &fragmentation_file_operations);
+#ifdef CONFIG_MM_REFAULT
+	create_seq_entry("refault",S_IRUGO, &refault_file_operations);
+#endif
 	create_seq_entry("vmstat",S_IRUGO, &proc_vmstat_file_operations);
 	create_seq_entry("zoneinfo",S_IRUGO, &proc_zoneinfo_file_operations);
 	create_seq_entry("diskstats", 0, &proc_diskstats_operations);
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Kconfig	2006-07-12 16:09:24.000000000 +0200
@@ -165,6 +165,11 @@ config MM_POLICY_RANDOM
 
 endchoice
 
+config MM_REFAULT
+	bool "Refault histogram"
+	def_bool y
+	depends on MM_POLICY_CLOCKPRO || MM_POLICY_CART || MM_POLICY_CART_R
+
 #
 # support for page migration
 #
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/Makefile	2006-07-12 16:09:24.000000000 +0200
@@ -17,6 +17,7 @@ obj-$(CONFIG_MM_POLICY_CLOCKPRO) += nonr
 obj-$(CONFIG_MM_POLICY_CART) += nonresident-cart.o cart.o
 obj-$(CONFIG_MM_POLICY_CART_R) += nonresident-cart.o cart.o
 obj-$(CONFIG_MM_POLICY_RANDOM) += random_policy.o
+obj-$(CONFIG_MM_REFAULT) += refault.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o thrash.o
 obj-$(CONFIG_HUGETLBFS)	+= hugetlb.o
Index: linux-2.6/mm/cart.c
===================================================================
--- linux-2.6.orig/mm/cart.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/cart.c	2006-07-12 16:09:24.000000000 +0200
@@ -253,7 +253,7 @@ void __pgrep_add(struct zone *zone, stru
 	 * specific PG_flags like: PG_t1, PG_longterm and PG_referenced.
 	 */
 
-	rflags = nonresident_get(page_mapping(page), page_index(page));
+	rflags = nonresident_get(page_mapping(page), page_index(page), 1);
 
 	if (rflags & NR_found) {
 		SetPageLongTerm(page);
@@ -516,7 +516,7 @@ void pgrep_remember(struct zone *zone, s
 
 void pgrep_forget(struct address_space *mapping, unsigned long index)
 {
-	nonresident_get(mapping, index);
+	nonresident_get(mapping, index, 0);
 }
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
Index: linux-2.6/mm/clockpro.c
===================================================================
--- linux-2.6.orig/mm/clockpro.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/clockpro.c	2006-07-12 16:09:24.000000000 +0200
@@ -169,10 +169,10 @@ static void __nonres_cutoff_dec(unsigned
 		__get_cpu_var(nonres_cutoff) -= cutoff;
 }
 
-static int nonres_get(struct address_space *mapping, unsigned long index)
+static int nonres_get(struct address_space *mapping, unsigned long index, int is_fault)
 {
 	int found = 0;
-	unsigned long distance = nonresident_get(mapping, index);
+	unsigned long distance = nonresident_get(mapping, index, is_fault);
 	if (distance != ~0UL) { /* valid page */
 		--__get_cpu_var(nonres_count);
 
@@ -310,7 +310,7 @@ void __pgrep_add(struct zone *zone, stru
 	int hand = HAND_HOT;
 
 	if (mapping)
-		found = nonres_get(mapping, page_index(page));
+		found = nonres_get(mapping, page_index(page), 1);
 
 #if 0
 	/* prefill the hot list */
@@ -550,7 +550,7 @@ void pgrep_remember(struct zone *zone, s
 
 void pgrep_forget(struct address_space *mapping, unsigned long index)
 {
-	nonres_get(mapping, index);
+	nonres_get(mapping, index, 0);
 }
 
 static unsigned long estimate_pageable_memory(void)
Index: linux-2.6/mm/nonresident-cart.c
===================================================================
--- linux-2.6.orig/mm/nonresident-cart.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/nonresident-cart.c	2006-07-12 16:09:24.000000000 +0200
@@ -49,6 +49,8 @@
 #include <linux/kernel.h>
 #include <linux/nonresident-cart.h>
 
+#include <asm/div64.h>
+
 #define TARGET_SLOTS	64
 #define NR_CACHELINES  (TARGET_SLOTS*sizeof(u32) / L1_CACHE_BYTES)
 #define NR_SLOTS	(((NR_CACHELINES * L1_CACHE_BYTES) - sizeof(spinlock_t) - 4*sizeof(u8)) / sizeof(u32))
@@ -207,6 +209,52 @@ static inline void __nonresident_push(st
 	__nonresident_insert(nr_bucket, listid, &nr_bucket->hand[listid], slot);
 }
 
+unsigned int nonresident_total(void)
+{
+	return NR_SLOTS << nonres_shift;
+}
+
+static DEFINE_PER_CPU(unsigned long, nonres_bal);
+
+static inline unsigned long __nonres_bal(void)
+{
+	return __sum_cpu_var(unsigned long, nonres_bal);
+}
+
+static void __nonres_bal_inc(unsigned long db)
+{
+	unsigned long nr_total;
+	unsigned long nr_bal;
+
+	preempt_disable();
+
+	nr_total = nonresident_total();
+	nr_bal = __nonres_bal();
+
+	if (nr_bal + db > nr_total)
+		db = nr_total - nr_bal;
+	__get_cpu_var(nonres_bal) += db;
+
+	preempt_enable();
+}
+
+static void __nonres_bal_dec(unsigned long db)
+{
+	unsigned long nr_total;
+	unsigned long nr_bal;
+
+	preempt_disable();
+
+	nr_total = nonresident_total();
+	nr_bal = __nonres_bal();
+
+	if (nr_bal < db)
+		db = nr_bal;
+	__get_cpu_var(nonres_bal) += db;
+
+	preempt_enable();
+}
+
 /*
  * Remembers a page by putting a hash-cookie on the @listid list.
  *
@@ -246,6 +294,10 @@ int nonresident_put(struct address_space
 	cookie = xchg(slot, cookie);
 	__nonresident_push(nr_bucket, listid, slot);
 	spin_unlock_irqrestore(&nr_bucket->lock, flags);
+	if (listid == NR_b1)
+		__nonres_bal_dec(1);
+	else
+		__nonres_bal_inc(1);
 
 	return evict;
 }
@@ -258,12 +310,13 @@ int nonresident_put(struct address_space
  *
  * returns listid of the list the item was found on with NR_found set if found.
  */
-int nonresident_get(struct address_space * mapping, unsigned long index)
+int nonresident_get(struct address_space * mapping, unsigned long index, int is_fault)
 {
 	struct nr_bucket * nr_bucket;
 	u32 wanted;
-	int j;
-	u8 i;
+	unsigned long tail_dist;
+	int pos;
+	int i;
 	unsigned long flags;
 	int ret = 0;
 
@@ -276,33 +329,64 @@ int nonresident_get(struct address_space
 
 	spin_lock_irqsave(&nr_bucket->lock, flags);
 	for (i = 0; i < 2; ++i) {
-		j = nr_bucket->hand[i];
+		tail_dist = 0;
+		pos = nr_bucket->hand[i];
 		do {
-			u32 *slot = &nr_bucket->slot[j];
+			u32 *slot = &nr_bucket->slot[pos];
 			if (GET_LISTID(*slot) != i)
 				break;
 
 			if ((*slot & COOKIE_MASK) == wanted) {
-				slot = __nonresident_del(nr_bucket, i, j, slot);
+				slot = __nonresident_del(nr_bucket, i, pos, slot);
 				__nonresident_push(nr_bucket, NR_free, slot);
+
 				ret = i | NR_found;
 				goto out;
 			}
 
-			j = GET_INDEX(*slot);
-		} while (j != nr_bucket->hand[i]);
+			pos = GET_INDEX(*slot);
+			++tail_dist;
+		} while (pos != nr_bucket->hand[i]);
 	}
 out:
+#ifdef CONFIG_MM_REFAULT
+	if (is_fault) {
+		extern void nonresident_refault(unsigned long);
+		unsigned long distance = ~0UL;
+
+		if (i < 2) {
+			unsigned long long dist;
+			unsigned long dist_total;
+			unsigned long bal[2] = {
+				nonresident_total() - __nonres_bal(),
+				__nonres_bal(),
+			};
+
+			dist_total =
+				__sum_cpu_var(unsigned long, nonres_count[i]);
+
+			tail_dist <<= nonres_shift;
+			tail_dist += (nr_bucket - nonres_table);
+
+			if (dist_total < tail_dist)
+				dist = 0;
+			else
+				dist = dist_total - tail_dist;
+
+			dist *= nonresident_total();
+			do_div(dist, bal[i] ?: 1);
+			distance = dist;
+		}
+
+		nonresident_refault(distance);
+	}
+#endif /* CONFIG_MM_REFAULT */
+
 	spin_unlock_irqrestore(&nr_bucket->lock, flags);
 
 	return ret;
 }
 
-unsigned int nonresident_total(void)
-{
-	return (1 << nonres_shift) * NR_SLOTS;
-}
-
 /*
  * For interactive workloads, we remember about as many non-resident pages
  * as we have actual memory pages.  For server workloads with large inter-
Index: linux-2.6/mm/nonresident.c
===================================================================
--- linux-2.6.orig/mm/nonresident.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/nonresident.c	2006-07-12 16:10:49.000000000 +0200
@@ -72,7 +72,8 @@ static u32 nr_cookie(struct address_spac
 	return (u32)(cookie >> (BITS_PER_LONG - 32));
 }
 
-unsigned long nonresident_get(struct address_space * mapping, unsigned long index)
+unsigned long nonresident_get(struct address_space * mapping, unsigned long index,
+	       	int is_fault)
 {
 	struct nr_bucket * nr_bucket;
 	int distance;
@@ -95,11 +96,19 @@ unsigned long nonresident_get(struct add
 			 * Add some jitter to the lower nonres_shift bits.
 			 */
 			distance += (nr_bucket - nonres_table);
-			return distance;
+			goto out;
 		}
 	}
 
-	return ~0UL;
+	distance = ~0UL;
+out:
+#ifdef CONFIG_MM_REFAULT
+	if (is_fault) {
+		extern void nonresident_refault(unsigned long);
+		nonresident_refault(distance);
+	}
+#endif /* CONFIG_MM_REFAULT */
+	return distance;
 }
 
 u32 nonresident_put(struct address_space * mapping, unsigned long index)
@@ -129,7 +138,7 @@ retry:
 	return xchg(&nr_bucket->page[i], nrpage);
 }
 
-unsigned long fastcall nonresident_total(void)
+unsigned long nonresident_total(void)
 {
 	return NUM_NR << nonres_shift;
 }
Index: linux-2.6/mm/refault.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/mm/refault.c	2006-07-12 16:09:24.000000000 +0200
@@ -0,0 +1,114 @@
+#include <linux/config.h>
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <asm/uaccess.h>
+
+#define BUCKETS 64
+
+DEFINE_PER_CPU(unsigned long[BUCKETS+1], refault_histogram);
+
+extern unsigned long nonresident_total(void);
+
+void nonresident_refault(unsigned long distance)
+{
+	unsigned long nonres_bucket = nonresident_total() / BUCKETS;
+	unsigned long bucket_id = distance / nonres_bucket;
+
+	if (bucket_id > BUCKETS)
+		bucket_id = BUCKETS;
+
+	__get_cpu_var(refault_histogram)[bucket_id]++;
+}
+
+#ifdef CONFIG_PROC_FS
+
+#include <linux/seq_file.h>
+
+static void *frag_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos < 0 || *pos > BUCKETS)
+		return NULL;
+
+	m->private = (void *)(unsigned long)*pos;
+
+	return pos;
+}
+
+static void *frag_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	if (*pos < BUCKETS) {
+		(*pos)++;
+		(unsigned long)m->private++;
+		return pos;
+	}
+	return NULL;
+}
+
+static void frag_stop(struct seq_file *m, void *arg)
+{
+}
+
+unsigned long get_refault_stat(unsigned long index)
+{
+	unsigned long total = 0;
+	int cpu;
+
+	for_each_cpu(cpu) {
+		total += per_cpu(refault_histogram, cpu)[index];
+	}
+	return total;
+}
+
+static int frag_show(struct seq_file *m, void *arg)
+{
+	unsigned long index = (unsigned long)m->private;
+	unsigned long nonres_bucket = nonresident_total() / BUCKETS;
+	unsigned long upper = ((unsigned long)index + 1) * nonres_bucket;
+	unsigned long lower = (unsigned long)index * nonres_bucket;
+	unsigned long hits = get_refault_stat(index);
+
+	if (index == 0)
+		seq_printf(m, "     Refault distance          Hits\n");
+
+	if (index < BUCKETS)
+		seq_printf(m, "%9lu - %9lu     %9lu\n", lower, upper, hits);
+	else
+		seq_printf(m, " New/Beyond %9lu     %9lu\n", lower, hits);
+
+	return 0;
+}
+
+struct seq_operations refault_op = {
+	.start  = frag_start,
+	.next   = frag_next,
+	.stop   = frag_stop,
+	.show   = frag_show,
+};
+
+static void refault_reset(void)
+{
+	int cpu;
+	int bucket_id;
+
+	for_each_cpu(cpu) {
+		for (bucket_id = 0; bucket_id <= BUCKETS; ++bucket_id)
+			per_cpu(refault_histogram, cpu)[bucket_id] = 0;
+	}
+}
+
+ssize_t refault_write(struct file *file, const char __user *buf,
+		      size_t count, loff_t *ppos)
+{
+	if (count) {
+		char c;
+
+		if (get_user(c, buf))
+			return -EFAULT;
+		if (c == '0')
+			refault_reset();
+	}
+	return count;
+}
+
+#endif /* CONFIG_PROCFS */
+
Index: linux-2.6/include/linux/nonresident-cart.h
===================================================================
--- linux-2.6.orig/include/linux/nonresident-cart.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/nonresident-cart.h	2006-07-12 16:09:24.000000000 +0200
@@ -15,7 +15,7 @@
 #define NR_found	0x80000000
 
 extern int nonresident_put(struct address_space *, unsigned long, int, int);
-extern int nonresident_get(struct address_space *, unsigned long);
+extern int nonresident_get(struct address_space *, unsigned long, int);
 extern unsigned int nonresident_total(void);
 extern void nonresident_init(void);
 
Index: linux-2.6/include/linux/nonresident.h
===================================================================
--- linux-2.6.orig/include/linux/nonresident.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/nonresident.h	2006-07-12 16:09:24.000000000 +0200
@@ -4,9 +4,9 @@
 #ifdef __KERNEL__
 
 extern void nonresident_init(void);
-extern unsigned long nonresident_get(struct address_space *, unsigned long);
+extern unsigned long nonresident_get(struct address_space *, unsigned long, int);
 extern u32 nonresident_put(struct address_space *, unsigned long);
-extern unsigned long fastcall nonresident_total(void);
+extern unsigned long nonresident_total(void);
 
 #endif /* __KERNEL */
 #endif /* _LINUX_NONRESIDENT_H_ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
