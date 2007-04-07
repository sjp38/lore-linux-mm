Date: Sat, 7 Apr 2007 15:06:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: (SPARSE_VIRTUAL doubles sparsemem speed)
In-Reply-To: <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704071455060.31468@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
 <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
 <1175544797.22373.62.camel@localhost.localdomain>
 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
 <461169CF.6060806@google.com> <Pine.LNX.4.64.0704021345110.1224@schroedinger.engr.sgi.com>
 <4614E293.3010908@shadowen.org> <Pine.LNX.4.64.0704051119400.9800@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Martin Bligh <mbligh@google.com>, Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Apr 2007, Christoph Lameter wrote:

> On Thu, 5 Apr 2007, Andy Whitcroft wrote:
> > Christoph if you could let us know which benchmarks you are seeing gains
> > with that would be a help.
> 
> You saw the numbers that Ken got with the pipe test right?
> 
> Then there are some minor improvements if you run AIM7.
> 
> I could get real some performance numbers for this by sticking in a 
> performance counter before and after virt_to_page and page_address. But I 
> am pretty sure about the result just looking at the code.

Ok. Since I keep being asked, I stuck a performance counter in kfree on 
x86_64 to see the difference in performance:

Results:

x86_64 boot with virtual memmap

Format:               #events totaltime (min/avg/max)

kfree_virt_to_page       598430 5.6ms(3ns/9ns/322ns)

x86_64 boot regular sparsemem

kfree_virt_to_page       596360 10.5ms(4ns/18ns/28.7us)


On average sparsemem virtual takes half the time than of sparsemem.

Note that the maximum time for regular sparsemem is way higher than
sparse virtual. This reflects the possibility that regular sparsemem may
once in a while have to deal with a cache miss whereas sparsemem virtual 
has no memory reference. Thus the numbers stay consistently low. 

Patch that was used to get these results (this is not very clean sorry 
but it should be enough to verify the results):



Simple Performance Counters

This patch allows the use of simple performance counters to measure time
intervals in the kernel source code. This allows a detailed analysis of the
time spend and the amount of data processed in specific code sections of the
kernel.

Time is measured using the cycle counter (TSC on IA32, ITC on IA64) which has
a very low latency.

To use add #include <linux/perf.h> to the header of the file where the
measurement needs to take place.

Then add the folowing to the code:

To declare a time stamp do

	struct pc pc;

To mark the beginning of the time measurement do

	pc_start(&pc, <counter>)

(If measurement from the beginning of a function is desired one may use
INIT_PC(xx) instead).

To mark the end of the time frame do:

	pc_stop(&pc);

or if the amount of data transferred needs to be measured as well:

	pc_throughput(&pc, number-of-bytes);


The measurements will show up in /proc/perf/all.
Processor specific statistics
may be obtained via /proc/perf/<nr-of-processor>.
Writing to /proc/perf/reset will reset all counters. F.e.

echo >/proc/perf/reset

The first counter is the number of times that the time measurement was
performed. (+ xx) is the number of samples that were thrown away since
the processor on which the process is running changed. Cycle counters
may not be consistent across different processors.

Then follows the sum of the time spend in the code segment followed in
parentheses by the minimum / average / maximum time spent there.
The second block are the sizes of data processed.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc5-mm4/kernel/Makefile
===================================================================
--- linux-2.6.21-rc5-mm4.orig/kernel/Makefile	2007-04-07 14:04:32.000000000 -0700
+++ linux-2.6.21-rc5-mm4/kernel/Makefile	2007-04-07 14:05:12.000000000 -0700
@@ -55,6 +55,7 @@
 obj-$(CONFIG_TASKSTATS) += taskstats.o tsacct.o
 obj-$(CONFIG_UTRACE) += utrace.o
 obj-$(CONFIG_PTRACE) += ptrace.o
+obj-y += perf.o
 
 ifneq ($(CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan@linuxcare.com.au>, the -fno-omit-frame-pointer is
Index: linux-2.6.21-rc5-mm4/include/linux/perf.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc5-mm4/include/linux/perf.h	2007-04-07 14:05:12.000000000 -0700
@@ -0,0 +1,49 @@
+/*
+ * Performance Counters and Measurement macros
+ * (C) 2005 Silicon Graphics Incorporated
+ * by Christoph Lameter <clameter@sgi.com>, April 2005
+ *
+ * Counters are calculated using the cycle counter. If a process
+ * is migrated to another cpu during the measurement then the measurement
+ * is invalid.
+ *
+ * We cannot disable preemption during measurement since that may interfere
+ * with other things in the kernel and limit the usefulness of the counters.
+ */
+
+enum pc_item {
+	PC_KFREE_VIRT_TO_PAGE,
+	PC_PTE_ALLOC,
+	PC_PTE_FREE,
+	PC_PMD_ALLOC,
+	PC_PMD_FREE,
+	PC_PUD_ALLOC,
+	PC_PUD_FREE,
+	PC_PGD_ALLOC,
+	PC_PGD_FREE,
+	NR_PC_ITEMS
+};
+
+/*
+ * Information about the start of the measurement
+ */
+struct pc {
+	unsigned long time;
+	int processor;
+	enum pc_item item;
+};
+
+static inline void pc_start(struct pc *pc, enum pc_item nr)
+{
+	pc->item = nr;
+	pc->processor = smp_processor_id();
+	pc->time = get_cycles();
+}
+
+#define INIT_PC(__var, __item) struct pc __var = \
+		{ get_cycles(), smp_processor_id(), __item }
+
+void pc_throughput(struct pc *pc, unsigned long bytes);
+
+#define pc_stop(__pc) pc_throughput(__pc, 0)
+
Index: linux-2.6.21-rc5-mm4/kernel/perf.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.21-rc5-mm4/kernel/perf.c	2007-04-07 14:05:12.000000000 -0700
@@ -0,0 +1,345 @@
+/*
+ * Simple Performance Counter subsystem
+ *
+ * (C) 2007 sgi.
+ *
+ * April 2007, Christoph Lameter <clameter@sgi.com>
+ */
+
+#include <linux/module.h>
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/fs.h>
+#include <linux/proc_fs.h>
+#include <linux/cpumask.h>
+#include <linux/perf.h>
+/* For the hash function */
+#include <linux/dcache.h>
+
+#ifdef CONFIG_IA64
+#define cycles_to_ns(x) (((x) * local_cpu_data->nsec_per_cyc) >> IA64_NSEC_PER_CYC_SHIFT)
+#elif defined(CONFIG_X86_64)
+#define cycles_to_ns(x) cycles_2_ns(x)
+#else
+#error "cycles_to_ns not defined for this architecture"
+#endif
+
+const char *var_id[NR_PC_ITEMS] = {
+	"kfree_virt_to_page",
+	"pte_alloc",
+	"pte_free",
+	"pmd_alloc",
+	"pmd_free",
+	"pud_alloc",
+	"pud_free",
+	"pgd_alloc",
+	"pgd_free"
+};
+
+struct perf_counter {
+	u32 events;
+	u32 mintime;
+	u32 maxtime;
+	u32 minbytes;
+	u32 maxbytes;
+	u32 skipped;
+	u64 time;
+	u64 bytes;
+};
+
+static DEFINE_PER_CPU(struct perf_counter, perf_counters)[NR_PC_ITEMS];
+
+void pc_throughput(struct pc *pc, unsigned long bytes)
+{
+	unsigned long time = get_cycles();
+	unsigned long ns;
+	int cpu = smp_processor_id();
+	struct perf_counter *p = &get_cpu_var(perf_counters)[pc->item];
+
+	if (unlikely(pc->item >= NR_PC_ITEMS)) {
+		printk(KERN_CRIT "pc_throughput: item (%d) out of range\n",
+			pc->item);
+		dump_stack();
+		goto out;
+	}
+
+	if (unlikely(pc->processor != cpu)) {
+		/* On different processor. TSC measurement not possible. */
+		p->skipped++;
+		goto out;
+	}
+
+	ns = cycles_to_ns(time - pc->time);
+	if (unlikely(ns > (1UL << (BITS_PER_LONG - 2)))) {
+		printk(KERN_ERR "perfcount %s: invalid time difference.\n",
+			var_id[pc->item]);
+		goto out;
+	}
+
+	p->time += ns;
+	p->events++;
+
+	if (ns > p->maxtime)
+		p->maxtime = ns;
+
+	if (p->mintime == 0 || ns < p->mintime)
+		p->mintime = ns;
+
+	if (bytes) {
+		p->bytes += bytes;
+		if (bytes > p->maxbytes)
+			p->maxbytes = bytes;
+		if (p->minbytes == 0 || bytes < p->minbytes)
+			p->minbytes = bytes;
+	}
+out:
+	put_cpu_var();
+	return;
+}
+EXPORT_SYMBOL(pc_throughput);
+
+static void reset_perfcount_item(struct perf_counter *c)
+{
+	c->events =0;
+	c->time =0;
+	c->maxtime =0;
+	c->mintime =0;
+	c->bytes =0;
+	c->minbytes =0;
+	c->maxbytes =0;
+}
+
+static void perfcount_reset(void) {
+	int cpu;
+	enum pc_item i;
+
+	for_each_online_cpu(cpu)
+		for (i = 0; i < NR_PC_ITEMS; i++)
+		 	reset_perfcount_item(
+				&per_cpu(perf_counters, cpu)[i]);
+}
+
+struct unit {
+	unsigned int n;
+	const char * s;
+};
+
+static const struct unit event_units[] = {
+	{ 1000, "" },
+	{ 1000, "K" },
+	{ 1000, "M" },
+	{ 1000, "G" },
+	{ 1000, "T" },
+	{ 1000, "P" },
+	{ 1000, "XX" },
+};
+
+
+static const struct unit time_units[] = {
+	{ 1000, "ns" },
+	{ 1000, "us" },
+	{ 1000, "ms" },
+	{ 60, "s" },
+	{ 60, "m" },
+	{ 24, "h" },
+	{ 365, "d" },
+	{ 1000, "y" },
+};
+
+static const struct unit byte_units[] = {
+	{ 1000, "b" },
+	{ 1000, "kb" },
+	{ 1000, "mb" },
+	{ 1000, "gb" },
+	{ 1000, "tb" },
+	{ 1000, "pb" },
+	{ 1000, "xb" }
+};
+
+/* Print a value using the given array of units and scale it properly */
+static void pval(struct seq_file *s, unsigned long x, const struct unit *u)
+{
+	unsigned n = 0;
+	unsigned rem = 0;
+	unsigned last_divisor = 0;
+
+	while (x >= u[n].n) {
+		last_divisor = u[n].n;
+		rem = x % last_divisor;
+		x = x / last_divisor;
+		n++;
+	}
+
+	if (last_divisor)
+		rem = (rem * 10 + last_divisor / 2) / last_divisor;
+	else
+		rem = 0;
+
+	/*
+	 * Rounding may have resulted in the need to go
+	 * to the next number
+	 */
+	if (rem == 10) {
+		x++;
+		rem = 0;
+	};
+
+	seq_printf(s, "%lu", x);
+	if (rem) {
+		seq_putc(s, '.');
+		seq_putc(s, '0' + rem);
+	}
+	seq_puts(s, u[n].s);
+}
+
+/* Print a set of statistical values in the form sum(max/avg/min) */
+static void pc_print(struct seq_file *s, const struct unit *u,
+	unsigned long count, unsigned long sum,
+	unsigned long min, unsigned long max)
+{
+	pval(s, sum, u);
+	seq_putc(s,'(');
+	pval(s, min, u);
+	seq_putc(s,'/');
+	if (count)
+		pval(s, (sum + count / 2 ) / count, u);
+	else
+		pval(s, 0, u);
+	seq_putc(s,'/');
+	pval(s, max, u);
+	seq_putc(s,')');
+}
+
+
+static int perf_show(struct seq_file *s, void *v)
+{
+	int cpu = (unsigned long)s->private;
+	enum pc_item counter = (unsigned long)v - 1;
+	struct perf_counter summary, *x;
+
+	if (cpu >= 0)
+		x = &per_cpu(perf_counters, cpu)[counter];
+	else {
+		memcpy(&summary, &per_cpu(perf_counters, 0)[counter],
+			sizeof(summary));
+		for_each_online_cpu(cpu) {
+			struct perf_counter *c =
+				&per_cpu(perf_counters, 0)[counter];
+
+			summary.events += c->events;
+			summary.skipped += c->skipped;
+			summary.time += c->time;
+			summary.bytes += c->bytes;
+
+			if (summary.maxtime < c->maxtime)
+				summary.maxtime = c->maxtime;
+
+			if (summary.mintime == 0 ||
+				(c->mintime != 0 &&
+				summary.mintime > c->mintime))
+					summary.mintime = c->mintime;
+
+			if (summary.maxbytes < c->maxbytes)
+				summary.maxbytes = c->maxbytes;
+
+			if (summary.minbytes == 0 ||
+				(c->minbytes != 0 &&
+				summary.minbytes > c->minbytes))
+					summary.minbytes = c->minbytes;
+
+		}
+		x = &summary;
+	}
+
+	seq_printf(s, "%-20s %10u ", var_id[counter], x->events);
+	if (x->skipped)
+		seq_printf(s, "(+%3u) ", x->skipped);
+	pc_print(s, time_units, x->events, x->time, x->mintime, x->maxtime);
+	if (x->bytes) {
+		seq_putc(s,' ');
+		pc_print(s, byte_units, x->events, x->bytes, x->minbytes, x->maxbytes);
+	}
+	seq_putc(s, '\n');
+	return 0;
+}
+
+static void *perf_start(struct seq_file *m, loff_t *pos)
+{
+	return (*pos < NR_PC_ITEMS) ? (void *)(*pos +1) : NULL;
+}
+
+static void *perf_next(struct seq_file *m, void *v, loff_t *pos)
+{
+	++*pos;
+	return perf_start(m, pos);
+}
+
+static void perf_stop(struct seq_file *m, void *v)
+{
+}
+
+struct seq_operations perf_data_ops = {
+	.start  = perf_start,
+	.next   = perf_next,
+	.stop   = perf_stop,
+	.show   = perf_show,
+};
+
+static int perf_data_open(struct inode *inode, struct file *file)
+{
+	int res;
+
+	res = seq_open(file, &perf_data_ops);
+	if (!res)
+		((struct seq_file *)file->private_data)->private = PDE(inode)->data;
+
+	return res;
+}
+
+static struct file_operations perf_data_fops = {
+	.open		= perf_data_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int perf_reset_write(struct file *file, const char __user *buffer,
+	unsigned long count, void *data)
+{
+	perfcount_reset();
+	return count;
+}
+
+static __init int init_perfcounter(void) {
+	int cpu;
+
+	struct proc_dir_entry *proc_perf, *perf_reset, *perf_all;
+
+	proc_perf = proc_mkdir("perf", NULL);
+	if (!proc_perf)
+		return -ENOMEM;
+
+	perf_reset = create_proc_entry("reset", S_IWUGO, proc_perf);
+	perf_reset->write_proc = perf_reset_write;
+
+	perf_all = create_proc_entry("all", S_IRUGO, proc_perf);
+	perf_all->proc_fops = &perf_data_fops;
+	perf_all->data = (void *)-1;
+
+	for_each_possible_cpu(cpu) {
+		char name[20];
+		struct proc_dir_entry *p;
+
+		sprintf(name, "%d", cpu);
+		p = create_proc_entry(name, S_IRUGO, proc_perf);
+
+		p->proc_fops = &perf_data_fops;
+		p->data = (void *)(unsigned long)cpu;
+	}
+
+	perfcount_reset();
+	return 0;
+}
+
+__initcall(init_perfcounter);
+
Index: linux-2.6.21-rc5-mm4/arch/x86_64/kernel/tsc.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/arch/x86_64/kernel/tsc.c	2007-04-07 14:04:32.000000000 -0700
+++ linux-2.6.21-rc5-mm4/arch/x86_64/kernel/tsc.c	2007-04-07 14:05:12.000000000 -0700
@@ -23,7 +23,7 @@
 	cyc2ns_scale = (NSEC_PER_MSEC << NS_SCALE) / khz;
 }
 
-static unsigned long long cycles_2_ns(unsigned long long cyc)
+unsigned long long cycles_2_ns(unsigned long long cyc)
 {
 	return (cyc * cyc2ns_scale) >> NS_SCALE;
 }
Index: linux-2.6.21-rc5-mm4/include/asm-x86_64/timex.h
===================================================================
--- linux-2.6.21-rc5-mm4.orig/include/asm-x86_64/timex.h	2007-04-07 14:04:32.000000000 -0700
+++ linux-2.6.21-rc5-mm4/include/asm-x86_64/timex.h	2007-04-07 14:05:12.000000000 -0700
@@ -29,4 +29,5 @@
 
 extern void mark_tsc_unstable(void);
 extern void set_cyc2ns_scale(unsigned long khz);
+unsigned long long cycles_2_ns(unsigned long long cyc);
 #endif
Index: linux-2.6.21-rc5-mm4/mm/slub.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/slub.c	2007-04-07 14:05:11.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/slub.c	2007-04-07 14:05:15.000000000 -0700
@@ -20,6 +20,7 @@
 #include <linux/mempolicy.h>
 #include <linux/ctype.h>
 #include <linux/kallsyms.h>
+#include <linux/perf.h>
 
 /*
  * Lock order:
@@ -1299,8 +1302,11 @@
 void kmem_cache_free(struct kmem_cache *s, void *x)
 {
 	struct page * page;
+	struct pc pc;
 
+	pc_start(&pc, PC_KFREE_VIRT_TO_PAGE);
 	page = virt_to_page(x);
+	pc_stop(&pc);
 
 	page = compound_head(page);
 
@@ -1917,11 +1923,16 @@
 {
 	struct kmem_cache *s;
 	struct page * page;
+	struct pc pc;
 
 	if (!x)
 		return;
 
-	page = compound_head(virt_to_page(x));
+	pc_start(&pc, PC_KFREE_VIRT_TO_PAGE);
+	page = virt_to_page(x);
+	pc_stop(&pc);
+
+	page = compound_head(page);
 
 	s = page->slab;
 
Index: linux-2.6.21-rc5-mm4/kernel/fork.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/kernel/fork.c	2007-04-07 14:04:32.000000000 -0700
+++ linux-2.6.21-rc5-mm4/kernel/fork.c	2007-04-07 14:05:12.000000000 -0700
@@ -58,6 +58,8 @@
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
+#include <linux/perf.h>
+
 /*
  * Protected counters by write_lock_irq(&tasklist_lock)
  */
@@ -304,7 +306,10 @@
 
 static inline int mm_alloc_pgd(struct mm_struct * mm)
 {
+	INIT_PC(pc, PC_PGD_ALLOC);
+
 	mm->pgd = pgd_alloc(mm);
+	pc_stop(&pc);
 	if (unlikely(!mm->pgd))
 		return -ENOMEM;
 	return 0;
@@ -312,7 +317,9 @@
 
 static inline void mm_free_pgd(struct mm_struct * mm)
 {
+	INIT_PC(pc, PC_PGD_FREE);
 	pgd_free(mm->pgd);
+	pc_stop(&pc);
 }
 #else
 #define dup_mmap(mm, oldmm)	(0)
Index: linux-2.6.21-rc5-mm4/mm/memory.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/memory.c	2007-04-07 14:04:32.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/memory.c	2007-04-07 14:05:12.000000000 -0700
@@ -60,6 +60,8 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 
+#include <linux/perf.h>
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
@@ -302,15 +304,22 @@
 
 int __pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long address)
 {
+	INIT_PC(pc, PC_PTE_ALLOC);
 	struct page *new = pte_alloc_one(mm, address);
+
+	pc_stop(&pc);
 	if (!new)
 		return -ENOMEM;
 
 	pte_lock_init(new);
 	spin_lock(&mm->page_table_lock);
 	if (pmd_present(*pmd)) {	/* Another has populated it */
+		struct pc pc;
+
 		pte_lock_deinit(new);
+		pc_start(&pc, PC_PTE_FREE);
 		pte_free(new);
+		pc_stop(&pc);
 	} else {
 		mm->nr_ptes++;
 		inc_zone_page_state(new, NR_PAGETABLE);
@@ -2509,14 +2518,20 @@
  */
 int __pud_alloc(struct mm_struct *mm, pgd_t *pgd, unsigned long address)
 {
+	INIT_PC(pc, PC_PUD_ALLOC);
 	pud_t *new = pud_alloc_one(mm, address);
+
+	pc_stop(&pc);
 	if (!new)
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
 	if (pgd_present(*pgd))		/* Another has populated it */
+	{
+		INIT_PC(pc, PC_PUD_FREE);
 		pud_free(new);
-	else
+		pc_stop(&pc);
+	} else
 		pgd_populate(mm, pgd, new);
 	spin_unlock(&mm->page_table_lock);
 	return 0;
@@ -2530,20 +2545,29 @@
  */
 int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
+	INIT_PC(pc, PC_PMD_ALLOC);
 	pmd_t *new = pmd_alloc_one(mm, address);
+
+	pc_stop(&pc);
 	if (!new)
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
+	{
+		INIT_PC(pc, PC_PMD_FREE);
 		pmd_free(new);
-	else
+		pc_stop(&pc);
+	} else
 		pud_populate(mm, pud, new);
 #else
 	if (pgd_present(*pud))		/* Another has populated it */
+	{
+		INIT_PC(pc, PC_PMD_FREE);
 		pmd_free(new);
-	else
+		pc_stop(&pc);
+	} else
 		pgd_populate(mm, pud, new);
 #endif /* __ARCH_HAS_4LEVEL_HACK */
 	spin_unlock(&mm->page_table_lock);
Index: linux-2.6.21-rc5-mm4/mm/slab.c
===================================================================
--- linux-2.6.21-rc5-mm4.orig/mm/slab.c	2007-04-07 14:22:11.000000000 -0700
+++ linux-2.6.21-rc5-mm4/mm/slab.c	2007-04-07 14:24:14.000000000 -0700
@@ -621,7 +621,10 @@
 
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
+	INIT_PC(PC_KFREE_VIRT_TO_PAGE);
 	struct page *page = virt_to_page(obj);
+
+	pc_stop(&pc);
 	return page_get_cache(page);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
