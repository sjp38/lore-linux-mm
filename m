Date: Tue, 27 Nov 2007 16:09:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu
 variables
In-Reply-To: <20071127154213.11970e63.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711271608120.7293@schroedinger.engr.sgi.com>
References: <20071127215052.090968000@sgi.com> <20071127215054.660250000@sgi.com>
 <20071127221628.GG24223@one.firstfloor.org> <20071127151241.038c146d.akpm@linux-foundation.org>
 <20071127152122.1d5fbce3.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0711271522050.6713@schroedinger.engr.sgi.com>
 <20071127154213.11970e63.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: andi@firstfloor.org, travis@sgi.com, ak@suse.de, pageexec@freemail.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 27 Nov 2007, Andrew Morton wrote:

> I don't recall anyone ever demonstrating that prefetch is useful in-kernel.

vmstat: remove prefetch

Remove the prefetch logic in order to avoid touching impossible per cpu 
areas.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmstat.c |   11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-11-27 16:04:15.345713812 -0800
+++ linux-2.6/mm/vmstat.c	2007-11-27 16:07:00.552713192 -0800
@@ -21,21 +21,14 @@ EXPORT_PER_CPU_SYMBOL(vm_event_states);
 
 static void sum_vm_events(unsigned long *ret, cpumask_t *cpumask)
 {
-	int cpu = 0;
+	int cpu;
 	int i;
 
 	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
 
-	cpu = first_cpu(*cpumask);
-	while (cpu < NR_CPUS) {
+	for_each_cpu_mask(cpu, *cpumask) {
 		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
 
-		cpu = next_cpu(cpu, *cpumask);
-
-		if (cpu < NR_CPUS)
-			prefetch(&per_cpu(vm_event_states, cpu));
-
-
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
 			ret[i] += this->event[i];
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
