Message-Id: <20080325021956.349576000@polaris-admin.engr.sgi.com>
References: <20080325021954.979158000@polaris-admin.engr.sgi.com>
Date: Mon, 24 Mar 2008 19:20:03 -0700
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 09/10] x86: oprofile: remove NR_CPUS arrays in arch/x86/oprofile/nmi_int.c
Content-Disposition: inline; filename=nr_cpus-in-nmi_int_c
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Philippe Elie <phil.el@wanadoo.fr>
List-ID: <linux-mm.kvack.org>

Change the following arrays sized by NR_CPUS to be PERCPU variables:

	static struct op_msrs cpu_msrs[NR_CPUS];
	static unsigned long saved_lvtpc[NR_CPUS];

Also some minor complaints from checkpatch.pl fixed.

Based on linux-2.6.25-rc5-mm1

Cc: Philippe Elie <phil.el@wanadoo.fr>

Signed-off-by: Mike Travis <travis@sgi.com>
---

All changes were transparent except for:

 static void nmi_shutdown(void)
 {
+	struct op_msrs *msrs = &__get_cpu_var(cpu_msrs);
 	nmi_enabled = 0;
 	on_each_cpu(nmi_cpu_shutdown, NULL, 0, 1);
 	unregister_die_notifier(&profile_exceptions_nb);
-	model->shutdown(cpu_msrs);
+	model->shutdown(msrs);
 	free_msrs();
 }

The existing code passed a reference to cpu 0's instance of struct op_msrs
to model->shutdown, whilst the other functions are passed a reference to
<this cpu's> instance of a struct op_msrs.  This seemed to be a bug to me
even though as long as cpu 0 and <this cpu> are of the same type it would
have the same effect...?
---
 arch/x86/oprofile/nmi_int.c |   49 ++++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 22 deletions(-)

--- linux-2.6.25-rc5.orig/arch/x86/oprofile/nmi_int.c
+++ linux-2.6.25-rc5/arch/x86/oprofile/nmi_int.c
@@ -23,8 +23,8 @@
 #include "op_x86_model.h"
 
 static struct op_x86_model_spec const *model;
-static struct op_msrs cpu_msrs[NR_CPUS];
-static unsigned long saved_lvtpc[NR_CPUS];
+static DEFINE_PER_CPU(struct op_msrs, cpu_msrs);
+static DEFINE_PER_CPU(unsigned long, saved_lvtpc);
 
 static int nmi_start(void);
 static void nmi_stop(void);
@@ -89,7 +89,7 @@ static int profile_exceptions_notify(str
 
 	switch (val) {
 	case DIE_NMI:
-		if (model->check_ctrs(args->regs, &cpu_msrs[cpu]))
+		if (model->check_ctrs(args->regs, &per_cpu(cpu_msrs, cpu)))
 			ret = NOTIFY_STOP;
 		break;
 	default:
@@ -126,7 +126,7 @@ static void nmi_cpu_save_registers(struc
 static void nmi_save_registers(void *dummy)
 {
 	int cpu = smp_processor_id();
-	struct op_msrs *msrs = &cpu_msrs[cpu];
+	struct op_msrs *msrs = &per_cpu(cpu_msrs, cpu);
 	nmi_cpu_save_registers(msrs);
 }
 
@@ -134,10 +134,10 @@ static void free_msrs(void)
 {
 	int i;
 	for_each_possible_cpu(i) {
-		kfree(cpu_msrs[i].counters);
-		cpu_msrs[i].counters = NULL;
-		kfree(cpu_msrs[i].controls);
-		cpu_msrs[i].controls = NULL;
+		kfree(per_cpu(cpu_msrs, i).counters);
+		per_cpu(cpu_msrs, i).counters = NULL;
+		kfree(per_cpu(cpu_msrs, i).controls);
+		per_cpu(cpu_msrs, i).controls = NULL;
 	}
 }
 
@@ -149,13 +149,15 @@ static int allocate_msrs(void)
 
 	int i;
 	for_each_possible_cpu(i) {
-		cpu_msrs[i].counters = kmalloc(counters_size, GFP_KERNEL);
-		if (!cpu_msrs[i].counters) {
+		per_cpu(cpu_msrs, i).counters = kmalloc(counters_size,
+								GFP_KERNEL);
+		if (!per_cpu(cpu_msrs, i).counters) {
 			success = 0;
 			break;
 		}
-		cpu_msrs[i].controls = kmalloc(controls_size, GFP_KERNEL);
-		if (!cpu_msrs[i].controls) {
+		per_cpu(cpu_msrs, i).controls = kmalloc(controls_size,
+								GFP_KERNEL);
+		if (!per_cpu(cpu_msrs, i).controls) {
 			success = 0;
 			break;
 		}
@@ -170,11 +172,11 @@ static int allocate_msrs(void)
 static void nmi_cpu_setup(void *dummy)
 {
 	int cpu = smp_processor_id();
-	struct op_msrs *msrs = &cpu_msrs[cpu];
+	struct op_msrs *msrs = &per_cpu(cpu_msrs, cpu);
 	spin_lock(&oprofilefs_lock);
 	model->setup_ctrs(msrs);
 	spin_unlock(&oprofilefs_lock);
-	saved_lvtpc[cpu] = apic_read(APIC_LVTPC);
+	per_cpu(saved_lvtpc, cpu) = apic_read(APIC_LVTPC);
 	apic_write(APIC_LVTPC, APIC_DM_NMI);
 }
 
@@ -203,13 +205,15 @@ static int nmi_setup(void)
 	 */
 
 	/* Assume saved/restored counters are the same on all CPUs */
-	model->fill_in_addresses(&cpu_msrs[0]);
+	model->fill_in_addresses(&per_cpu(cpu_msrs, 0));
 	for_each_possible_cpu(cpu) {
 		if (cpu != 0) {
-			memcpy(cpu_msrs[cpu].counters, cpu_msrs[0].counters,
+			memcpy(per_cpu(cpu_msrs, cpu).counters,
+				per_cpu(cpu_msrs, 0).counters,
 				sizeof(struct op_msr) * model->num_counters);
 
-			memcpy(cpu_msrs[cpu].controls, cpu_msrs[0].controls,
+			memcpy(per_cpu(cpu_msrs, cpu).controls,
+				per_cpu(cpu_msrs, 0).controls,
 				sizeof(struct op_msr) * model->num_controls);
 		}
 
@@ -249,7 +253,7 @@ static void nmi_cpu_shutdown(void *dummy
 {
 	unsigned int v;
 	int cpu = smp_processor_id();
-	struct op_msrs *msrs = &cpu_msrs[cpu];
+	struct op_msrs *msrs = &__get_cpu_var(cpu_msrs);
 
 	/* restoring APIC_LVTPC can trigger an apic error because the delivery
 	 * mode and vector nr combination can be illegal. That's by design: on
@@ -258,23 +262,24 @@ static void nmi_cpu_shutdown(void *dummy
 	 */
 	v = apic_read(APIC_LVTERR);
 	apic_write(APIC_LVTERR, v | APIC_LVT_MASKED);
-	apic_write(APIC_LVTPC, saved_lvtpc[cpu]);
+	apic_write(APIC_LVTPC, per_cpu(saved_lvtpc, cpu));
 	apic_write(APIC_LVTERR, v);
 	nmi_restore_registers(msrs);
 }
 
 static void nmi_shutdown(void)
 {
+	struct op_msrs *msrs = &__get_cpu_var(cpu_msrs);
 	nmi_enabled = 0;
 	on_each_cpu(nmi_cpu_shutdown, NULL, 0, 1);
 	unregister_die_notifier(&profile_exceptions_nb);
-	model->shutdown(cpu_msrs);
+	model->shutdown(msrs);
 	free_msrs();
 }
 
 static void nmi_cpu_start(void *dummy)
 {
-	struct op_msrs const *msrs = &cpu_msrs[smp_processor_id()];
+	struct op_msrs const *msrs = &__get_cpu_var(cpu_msrs);
 	model->start(msrs);
 }
 
@@ -286,7 +291,7 @@ static int nmi_start(void)
 
 static void nmi_cpu_stop(void *dummy)
 {
-	struct op_msrs const *msrs = &cpu_msrs[smp_processor_id()];
+	struct op_msrs const *msrs = &__get_cpu_var(cpu_msrs);
 	model->stop(msrs);
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
