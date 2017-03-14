Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18A136B038D
	for <linux-mm@kvack.org>; Tue, 14 Mar 2017 13:05:33 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id x127so15337073pgb.4
        for <linux-mm@kvack.org>; Tue, 14 Mar 2017 10:05:33 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h187sor2674937pfe.9.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Mar 2017 10:05:32 -0700 (PDT)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v7 3/3] x86: Make the GDT remapping read-only on 64-bit
Date: Tue, 14 Mar 2017 10:05:08 -0700
Message-Id: <20170314170508.100882-3-thgarnie@google.com>
In-Reply-To: <20170314170508.100882-1-thgarnie@google.com>
References: <20170314170508.100882-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Thomas Garnier <thgarnie@google.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Stanislaw Gruszka <sgruszka@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, lguest@lists.ozlabs.org, kvm@vger.kernel.org, kernel-hardening@lists.openwall.com

This patch makes the GDT remapped pages read-only to prevent corruption.
This change is done only on 64-bit.

The native_load_tr_desc function was adapted to correctly handle a
read-only GDT. The LTR instruction always writes to the GDT TSS entry.
This generates a page fault if the GDT is read-only. This change checks
if the current GDT is a remap and swap GDTs as needed. This function was
tested by booting multiple machines and checking hibernation works
properly.

KVM SVM and VMX were adapted to use the writeable GDT. On VMX, the
per-cpu variable was removed for functions to fetch the original GDT.
Instead of reloading the previous GDT, VMX will reload the fixmap GDT as
expected. For testing, VMs were started and restored on multiple
configurations.

Signed-off-by: Thomas Garnier <thgarnie@google.com>
---
Based on next-20170308
---
 arch/x86/include/asm/desc.h      | 106 +++++++++++++++++++++++++--------------
 arch/x86/include/asm/processor.h |   1 +
 arch/x86/kernel/cpu/common.c     |  28 ++++++++---
 arch/x86/kvm/svm.c               |   4 +-
 arch/x86/kvm/vmx.c               |  12 ++---
 5 files changed, 96 insertions(+), 55 deletions(-)

diff --git a/arch/x86/include/asm/desc.h b/arch/x86/include/asm/desc.h
index 4b5ef0c64291..ec05f9c1a62c 100644
--- a/arch/x86/include/asm/desc.h
+++ b/arch/x86/include/asm/desc.h
@@ -248,9 +248,77 @@ static inline void native_set_ldt(const void *addr, unsigned int entries)
 	}
 }
 
+static inline void native_load_gdt(const struct desc_ptr *dtr)
+{
+	asm volatile("lgdt %0"::"m" (*dtr));
+}
+
+static inline void native_load_idt(const struct desc_ptr *dtr)
+{
+	asm volatile("lidt %0"::"m" (*dtr));
+}
+
+static inline void native_store_gdt(struct desc_ptr *dtr)
+{
+	asm volatile("sgdt %0":"=m" (*dtr));
+}
+
+static inline void native_store_idt(struct desc_ptr *dtr)
+{
+	asm volatile("sidt %0":"=m" (*dtr));
+}
+
+/*
+ * The LTR instruction marks the TSS GDT entry as busy. On 64-bit, the GDT is
+ * a read-only remapping. To prevent a page fault, the GDT is switched to the
+ * original writeable version when needed.
+ */
+#ifdef CONFIG_X86_64
 static inline void native_load_tr_desc(void)
 {
+	struct desc_ptr gdt;
+	int cpu = raw_smp_processor_id();
+	bool restore = 0;
+	struct desc_struct *fixmap_gdt;
+
+	native_store_gdt(&gdt);
+	fixmap_gdt = get_cpu_gdt_ro(cpu);
+
+	/*
+	 * If the current GDT is the read-only fixmap, swap to the original
+	 * writeable version. Swap back at the end.
+	 */
+	if (gdt.address == (unsigned long)fixmap_gdt) {
+		load_direct_gdt(cpu);
+		restore = 1;
+	}
 	asm volatile("ltr %w0"::"q" (GDT_ENTRY_TSS*8));
+	if (restore)
+		load_fixmap_gdt(cpu);
+}
+#else
+static inline void native_load_tr_desc(void)
+{
+	asm volatile("ltr %w0"::"q" (GDT_ENTRY_TSS*8));
+}
+#endif
+
+static inline unsigned long native_store_tr(void)
+{
+	unsigned long tr;
+
+	asm volatile("str %0":"=r" (tr));
+
+	return tr;
+}
+
+static inline void native_load_tls(struct thread_struct *t, unsigned int cpu)
+{
+	struct desc_struct *gdt = get_cpu_gdt_rw(cpu);
+	unsigned int i;
+
+	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++)
+		gdt[GDT_ENTRY_TLS_MIN + i] = t->tls_array[i];
 }
 
 DECLARE_PER_CPU(bool, __tss_limit_invalid);
@@ -305,44 +373,6 @@ static inline void invalidate_tss_limit(void)
 		this_cpu_write(__tss_limit_invalid, true);
 }
 
-static inline void native_load_gdt(const struct desc_ptr *dtr)
-{
-	asm volatile("lgdt %0"::"m" (*dtr));
-}
-
-static inline void native_load_idt(const struct desc_ptr *dtr)
-{
-	asm volatile("lidt %0"::"m" (*dtr));
-}
-
-static inline void native_store_gdt(struct desc_ptr *dtr)
-{
-	asm volatile("sgdt %0":"=m" (*dtr));
-}
-
-static inline void native_store_idt(struct desc_ptr *dtr)
-{
-	asm volatile("sidt %0":"=m" (*dtr));
-}
-
-static inline unsigned long native_store_tr(void)
-{
-	unsigned long tr;
-
-	asm volatile("str %0":"=r" (tr));
-
-	return tr;
-}
-
-static inline void native_load_tls(struct thread_struct *t, unsigned int cpu)
-{
-	struct desc_struct *gdt = get_cpu_gdt_rw(cpu);
-	unsigned int i;
-
-	for (i = 0; i < GDT_ENTRY_TLS_ENTRIES; i++)
-		gdt[GDT_ENTRY_TLS_MIN + i] = t->tls_array[i];
-}
-
 /* This intentionally ignores lm, since 32-bit apps don't have that field. */
 #define LDT_empty(info)					\
 	((info)->base_addr		== 0	&&	\
diff --git a/arch/x86/include/asm/processor.h b/arch/x86/include/asm/processor.h
index 2ec4d2dc559b..28828f1f99a4 100644
--- a/arch/x86/include/asm/processor.h
+++ b/arch/x86/include/asm/processor.h
@@ -716,6 +716,7 @@ extern struct desc_ptr		early_gdt_descr;
 
 extern void cpu_set_gdt(int);
 extern void switch_to_new_gdt(int);
+extern void load_direct_gdt(int);
 extern void load_fixmap_gdt(int);
 extern void load_percpu_segment(int);
 extern void cpu_init(void);
diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index 3cf1590ec9ce..f8e22dbad86c 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -448,8 +448,15 @@ void load_percpu_segment(int cpu)
 	load_stack_canary_segment();
 }
 
-/* Used by XEN to force the GDT read-only when required */
+/*
+ * On 64-bit the GDT remapping is read-only.
+ * A global is used for Xen to change the default when required.
+ */
+#ifdef CONFIG_X86_64
+pgprot_t pg_fixmap_gdt_flags = PAGE_KERNEL_RO;
+#else
 pgprot_t pg_fixmap_gdt_flags = PAGE_KERNEL;
+#endif
 
 /* Setup the fixmap mapping only once per-processor */
 static inline void setup_fixmap_gdt(int cpu)
@@ -458,6 +465,17 @@ static inline void setup_fixmap_gdt(int cpu)
 		     __pa(get_cpu_gdt_rw(cpu)), pg_fixmap_gdt_flags);
 }
 
+/* Load the original GDT from the per-cpu structure */
+void load_direct_gdt(int cpu)
+{
+	struct desc_ptr gdt_descr;
+
+	gdt_descr.address = (long)get_cpu_gdt_rw(cpu);
+	gdt_descr.size = GDT_SIZE - 1;
+	load_gdt(&gdt_descr);
+}
+EXPORT_SYMBOL_GPL(load_direct_gdt);
+
 /* Load a fixmap remapping of the per-cpu GDT */
 void load_fixmap_gdt(int cpu)
 {
@@ -467,6 +485,7 @@ void load_fixmap_gdt(int cpu)
 	gdt_descr.size = GDT_SIZE - 1;
 	load_gdt(&gdt_descr);
 }
+EXPORT_SYMBOL_GPL(load_fixmap_gdt);
 
 /*
  * Current gdt points %fs at the "master" per-cpu area: after this,
@@ -474,11 +493,8 @@ void load_fixmap_gdt(int cpu)
  */
 void switch_to_new_gdt(int cpu)
 {
-	struct desc_ptr gdt_descr;
-
-	gdt_descr.address = (long)get_cpu_gdt_rw(cpu);
-	gdt_descr.size = GDT_SIZE - 1;
-	load_gdt(&gdt_descr);
+	/* Load the original GDT */
+	load_direct_gdt(cpu);
 	/* Reload the per-cpu base */
 	load_percpu_segment(cpu);
 }
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index d1efe2c62b3f..c02b9af2056a 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -741,7 +741,6 @@ static int svm_hardware_enable(void)
 
 	struct svm_cpu_data *sd;
 	uint64_t efer;
-	struct desc_ptr gdt_descr;
 	struct desc_struct *gdt;
 	int me = raw_smp_processor_id();
 
@@ -763,8 +762,7 @@ static int svm_hardware_enable(void)
 	sd->max_asid = cpuid_ebx(SVM_CPUID_FUNC) - 1;
 	sd->next_asid = sd->max_asid + 1;
 
-	native_store_gdt(&gdt_descr);
-	gdt = (struct desc_struct *)gdt_descr.address;
+	gdt = get_current_gdt_rw();
 	sd->tss_desc = (struct kvm_ldttss_desc *)(gdt + GDT_ENTRY_TSS);
 
 	wrmsrl(MSR_EFER, efer | EFER_SVME);
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 283aa8601833..cfed1fff43ec 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -935,7 +935,6 @@ static DEFINE_PER_CPU(struct vmcs *, current_vmcs);
  * when a CPU is brought down, and we need to VMCLEAR all VMCSs loaded on it.
  */
 static DEFINE_PER_CPU(struct list_head, loaded_vmcss_on_cpu);
-static DEFINE_PER_CPU(struct desc_ptr, host_gdt);
 
 /*
  * We maintian a per-CPU linked-list of vCPU, so in wakeup_handler() we
@@ -2052,14 +2051,13 @@ static bool update_transition_efer(struct vcpu_vmx *vmx, int efer_offset)
  */
 static unsigned long segment_base(u16 selector)
 {
-	struct desc_ptr *gdt = this_cpu_ptr(&host_gdt);
 	struct desc_struct *table;
 	unsigned long v;
 
 	if (!(selector & ~SEGMENT_RPL_MASK))
 		return 0;
 
-	table = (struct desc_struct *)gdt->address;
+	table = get_current_gdt_ro();
 
 	if ((selector & SEGMENT_TI_MASK) == SEGMENT_LDT) {
 		u16 ldt_selector = kvm_read_ldt();
@@ -2164,7 +2162,7 @@ static void __vmx_load_host_state(struct vcpu_vmx *vmx)
 #endif
 	if (vmx->host_state.msr_host_bndcfgs)
 		wrmsrl(MSR_IA32_BNDCFGS, vmx->host_state.msr_host_bndcfgs);
-	load_gdt(this_cpu_ptr(&host_gdt));
+	load_fixmap_gdt(raw_smp_processor_id());
 }
 
 static void vmx_load_host_state(struct vcpu_vmx *vmx)
@@ -2266,7 +2264,7 @@ static void vmx_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 	}
 
 	if (!already_loaded) {
-		struct desc_ptr *gdt = this_cpu_ptr(&host_gdt);
+		unsigned long gdt = get_current_gdt_ro_vaddr();
 		unsigned long sysenter_esp;
 
 		kvm_make_request(KVM_REQ_TLB_FLUSH, vcpu);
@@ -2277,7 +2275,7 @@ static void vmx_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 		 */
 		vmcs_writel(HOST_TR_BASE,
 			    (unsigned long)this_cpu_ptr(&cpu_tss));
-		vmcs_writel(HOST_GDTR_BASE, gdt->address);
+		vmcs_writel(HOST_GDTR_BASE, gdt);   /* 22.2.4 */
 
 		/*
 		 * VM exits change the host TR limit to 0x67 after a VM
@@ -3465,8 +3463,6 @@ static int hardware_enable(void)
 		ept_sync_global();
 	}
 
-	native_store_gdt(this_cpu_ptr(&host_gdt));
-
 	return 0;
 }
 
-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
