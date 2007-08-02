Date: Thu, 2 Aug 2007 20:42:11 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070802194211.GE23133@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com> <20070802140904.GA16940@skynet.ie> <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708021152370.7719@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (02/08/07 11:56), Christoph Lameter didst pronounce:
> On Thu, 2 Aug 2007, Mel Gorman wrote:
> 
> > Hence the regression test is dependant on timing. The question is if the values
> > should always be up-to-date when read from userspace. I put together one patch
> > that would refresh the counters when numastat or vmstat was being read but it
> > requires a per-cpu function to be called. This may be undesirable as it would
> > be punishing on large systems running tools that frequently read /proc/vmstat
> > for example. Was it done this way on purpose? The comments around the stats
> > code would led me to believe this lag is on purpose to avoid per-cpu calls.
> 
> The lag was introduced with the vm statistics rework since ZVCs use 
> deferred updates. We could call refresh_vm_stats before handing out the 
> counters?
> 

We could but as I said, this might be a problem for monitor programs because
an IPI call is involved for it to be 100% safe. I've included a patch below
to illustrate what appears to be required for the stats read always to be
up-to-date. Prehaps there is a less expensive way of doing it.

> > The alternative was to apply this patch to numactl so that the
> > regression test waits on the timers to update. With this patch, the
> > regression tests passed on a 4-node x86_64 machine.
> 
> Another possible solution. Andi: Which solution would you prefer?

Option 2 currently looks like;

--- 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index cae346e..3656489 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -98,6 +98,7 @@ static SYSDEV_ATTR(meminfo, S_IRUGO, node_read_meminfo, NULL);
 
 static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
 {
+	refresh_all_cpu_vm_stats();
 	return sprintf(buf,
 		       "numa_hit %lu\n"
 		       "numa_miss %lu\n"
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 75370ec..31046e2 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -213,6 +213,7 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
 extern void __dec_zone_state(struct zone *, enum zone_stat_item);
 
 void refresh_cpu_vm_stats(int);
+void refresh_all_cpu_vm_stats(void);
 #else /* CONFIG_SMP */
 
 /*
@@ -259,6 +260,7 @@ static inline void __dec_zone_page_state(struct page *page,
 #define mod_zone_page_state __mod_zone_page_state
 
 static inline void refresh_cpu_vm_stats(int cpu) { }
+static inline void refresh_all_cpu_vm_stats(int cpu) { }
 #endif
 
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c64d169..9c75baa 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -621,6 +621,24 @@ const struct seq_operations zoneinfo_op = {
 	.show	= zoneinfo_show,
 };
 
+#ifdef CONFIG_SMP
+void __refresh_all_cpu_vm_stats(void *arg)
+{
+	refresh_cpu_vm_stats(smp_processor_id());
+}
+
+void refresh_all_cpu_vm_stats(void)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	refresh_cpu_vm_stats(smp_processor_id());
+	local_irq_restore(flags);
+
+	smp_call_function(__refresh_all_cpu_vm_stats, NULL, 0, 1);
+}
+#endif /* CONFIG_SMP */
+
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
 	unsigned long *v;
@@ -642,6 +660,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 	m->private = v;
 	if (!v)
 		return ERR_PTR(-ENOMEM);
+	refresh_all_cpu_vm_stats();
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 		v[i] = global_page_state(i);
 #ifdef CONFIG_VM_EVENT_COUNTERS
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
