Message-Id: <20071127215054.660250000@sgi.com>
References: <20071127215052.090968000@sgi.com>
Date: Tue, 27 Nov 2007 13:50:53 -0800
From: travis@sgi.com
Subject: [PATCH 1/1] mm: Prevent dereferencing non-allocated per_cpu variables
Content-Disposition: inline; filename=change-NR_CPUS-to-for_each_possible_cpu
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, pageexec@freemail.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Change loops controlled by 'for (i = 0; i < NR_CPUS; i++)' to use
'for_each_possible_cpu(i)' when there's a _remote possibility_ of
dereferencing a non-allocated per_cpu variable involved.

All files except mm/vmstat.c are x86 arch.

Based on 2.6.24-rc3-mm1 .

Thanks to pageexec@freemail.hu for pointing this out.

Signed-off-by: Mike Travis <travis@sgi.com>
---
 arch/x86/kernel/smp_32.c     |    4 ++--
 arch/x86/kernel/smpboot_32.c |    4 ++--
 arch/x86/xen/smp.c           |    4 ++--
 mm/vmstat.c                  |    4 ++--
 4 files changed, 8 insertions(+), 8 deletions(-)

--- a/arch/x86/kernel/smp_32.c
+++ b/arch/x86/kernel/smp_32.c
@@ -223,7 +223,7 @@ void send_IPI_mask_sequence(cpumask_t ma
 	 */ 
 
 	local_irq_save(flags);
-	for (query_cpu = 0; query_cpu < NR_CPUS; ++query_cpu) {
+	for_each_possible_cpu(query_cpu) {
 		if (cpu_isset(query_cpu, mask)) {
 			__send_IPI_dest_field(cpu_to_logical_apicid(query_cpu),
 					      vector);
@@ -675,7 +675,7 @@ static int convert_apicid_to_cpu(int api
 {
 	int i;
 
-	for (i = 0; i < NR_CPUS; i++) {
+	for_each_possible_cpu(i) {
 		if (per_cpu(x86_cpu_to_apicid, i) == apic_id)
 			return i;
 	}
--- a/arch/x86/kernel/smpboot_32.c
+++ b/arch/x86/kernel/smpboot_32.c
@@ -1091,7 +1091,7 @@ static void __init smp_boot_cpus(unsigne
 	 * Allow the user to impress friends.
 	 */
 	Dprintk("Before bogomips.\n");
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	for_each_possible_cpu(cpu)
 		if (cpu_isset(cpu, cpu_callout_map))
 			bogosum += cpu_data(cpu).loops_per_jiffy;
 	printk(KERN_INFO
@@ -1122,7 +1122,7 @@ static void __init smp_boot_cpus(unsigne
 	 * construct cpu_sibling_map, so that we can tell sibling CPUs
 	 * efficiently.
 	 */
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_cpu(cpu) {
 		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		cpus_clear(per_cpu(cpu_core_map, cpu));
 	}
--- a/arch/x86/xen/smp.c
+++ b/arch/x86/xen/smp.c
@@ -146,7 +146,7 @@ void __init xen_smp_prepare_boot_cpu(voi
 	   old memory can be recycled */
 	make_lowmem_page_readwrite(&per_cpu__gdt_page);
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_cpu(cpu) {
 		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		/*
 		 * cpu_core_map lives in a per cpu area that is cleared
@@ -163,7 +163,7 @@ void __init xen_smp_prepare_cpus(unsigne
 {
 	unsigned cpu;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_cpu(cpu) {
 		cpus_clear(per_cpu(cpu_sibling_map, cpu));
 		/*
 		 * cpu_core_ map will be zeroed when the per
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -27,12 +27,12 @@ static void sum_vm_events(unsigned long 
 	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
 
 	cpu = first_cpu(*cpumask);
-	while (cpu < NR_CPUS) {
+	while (cpu < NR_CPUS && cpu_possible(cpu)) {
 		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
 
 		cpu = next_cpu(cpu, *cpumask);
 
-		if (cpu < NR_CPUS)
+		if (cpu < NR_CPUS && cpu_possible(cpu))
 			prefetch(&per_cpu(vm_event_states, cpu));
 
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
