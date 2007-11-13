Date: Tue, 13 Nov 2007 14:05:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Vmstat: Small revisions to refresh_cpu_vm_stats()
In-Reply-To: <20071113035509.5d221318.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711131341160.3714@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0711091837390.18567@schroedinger.engr.sgi.com>
 <20071113033755.c2e64c09.akpm@linux-foundation.org>
 <20071113.034737.199780122.davem@davemloft.net> <20071113035509.5d221318.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, ak@suse.de, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Nov 2007, Andrew Morton wrote:

> > However, for platforms like sparc32 that can do a xchg() atomically
> > but can't do cmpxchg, this idea won't work :-/
> 
> xchg() is nonatomic wrt other CPUs, so I think we can get by with
> local_irq_save()/swap()/local_irq_restore().

The xchg in the vmstat case does not need to be nonatomic vs. other 
processors. However, xchg is always atomic vs other processors.

from include/asm-x86/cmpxchg_64.h:

/*
 * Note: no "lock" prefix even on SMP: xchg always implies lock anyway
 * Note 2: xchg has side effect, so that attribute volatile is necessary,
 *        but generally the primitive is invalid, *ptr is output argument. --ANK
 */
static inline unsigned long __xchg(unsigned long x, volatile void * ptr, 
int size)

If we would have an xchg_local then I would have used it here. So I guess 
what we need is
a 

	xchg_local

which can be done just with interrupt/disable/enable and an

	xchg

which would require a spinlock.


Lets defer the xchg issue. Here is the patch without it:



Vmstat: Small revisions to refresh_cpu_vm_stats() V2

1. Add comments explaining how the function can be called.

2. Collect global diffs in a local array and only spill
   them once into the global counters when the zone scan
   is finished. This means that we only touch each global
   counter once instead of each time we fold cpu counters
   into zone counters.

V1->V2: Remove xchg on a s8.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmstat.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-11-13 13:55:48.365792120 -0800
+++ linux-2.6/mm/vmstat.c	2007-11-13 13:58:47.965676589 -0800
@@ -284,6 +284,10 @@ EXPORT_SYMBOL(dec_zone_page_state);
 /*
  * Update the zone counters for one cpu.
  *
+ * The cpu specified must be either the current cpu or a processor that
+ * is not online. If it is the current cpu then the execution thread must
+ * be pinned to the current cpu.
+ *
  * Note that refresh_cpu_vm_stats strives to only access
  * node local memory. The per cpu pagesets on remote zones are placed
  * in the memory local to the processor using that pageset. So the
@@ -299,7 +303,7 @@ void refresh_cpu_vm_stats(int cpu)
 {
 	struct zone *zone;
 	int i;
-	unsigned long flags;
+	int global_diff[NR_VM_ZONE_STAT_ITEMS] = { 0, };
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -311,15 +315,19 @@ void refresh_cpu_vm_stats(int cpu)
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
+				unsigned long flags;
+				int v;
+
 				local_irq_save(flags);
-				zone_page_state_add(p->vm_stat_diff[i],
-					zone, i);
+				v = p->vm_stat_diff[i];
 				p->vm_stat_diff[i] = 0;
+				local_irq_restore(flags);
+				atomic_long_add(v, &zone->vm_stat[i]);
+				global_diff[i] += v;
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				p->expire = 3;
 #endif
-				local_irq_restore(flags);
 			}
 #ifdef CONFIG_NUMA
 		/*
@@ -351,6 +359,10 @@ void refresh_cpu_vm_stats(int cpu)
 			drain_zone_pages(zone, p->pcp + 1);
 #endif
 	}
+
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+		if (global_diff[i])
+			atomic_long_add(global_diff[i], &vm_stat[i]);
 }
 
 #endif






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
