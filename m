Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0CFE6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 17:04:07 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g2so4686150pge.7
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 14:04:07 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g63sor13550448pfd.18.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 14:04:06 -0800 (PST)
From: Thomas Garnier <thgarnie@google.com>
Subject: [PATCH v5 3/3] x86: Make the GDT remapping read-only on 64-bit
Date: Mon,  6 Mar 2017 14:03:48 -0800
Message-Id: <20170306220348.79702-3-thgarnie@google.com>
In-Reply-To: <20170306220348.79702-1-thgarnie@google.com>
References: <20170306220348.79702-1-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Juergen Gross <jgross@suse.com>, Lorenzo Stoakes <lstoakes@gmail.com>, Andy Lutomirski <luto@kernel.org>, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, zijun_hu <zijun_hu@htc.com>, Chris Wilson <chris@chris-wilson.co.uk>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andy Lutomirski <luto@amacapital.net>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Jiri Kosina <jikos@kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Rusty Russell <rusty@rustcorp.com.au>, Paolo Bonzini <pbonzini@redhat.com>, Borislav Petkov <bp@suse.de>, Christian Borntraeger <borntraeger@de.ibm.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, He Chen <he.chen@linux.intel.com>, Brian Gerst <brgerst@gmail.com>, Frederic Weisbecker <fweisbec@gmail.com>, Stanislaw Gruszka <sgruszka@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Jiri Olsa <jolsa@redhat.com>, Prarit Bhargava <prarit@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Joerg Roedel <joro@8bytes.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>
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
Based on next-20170306
---
 arch/x86/include/asm/desc.h      | 106 +++++++++++++++++++++++++--------------
 arch/x86/include/asm/processor.h |   1 +
 arch/x86/kernel/cpu/common.c     |  28 ++++++++---
 arch/x86/kvm/svm.c               |   4 +-
 arch/x86/kvm/vmx.c               |  11 ++--
 5 files changed, 96 insertions(+), 54 deletions(-)

diff --git a/arch/x86/include/asm/desc.h b/arch/x86/include/asm/desc.h
index 549393ae93a0..9b7fda6a2d73 100644
--- a/arch/x86/include/asm/desc.h
+++ b/arch/x86/include/asm/desc.h
@@ -247,9 +247,77 @@ static inline void native_set_ldt(const void *addr, unsigned int entries)
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
@@ -304,44 +372,6 @@ static inline void invalidate_tss_limit(void)
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
index a9e847da014a..bff2f8bb13b5 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -448,13 +448,31 @@ void load_percpu_segment(int cpu)
 	load_stack_canary_segment();
 }
 
+/* On 64-bit the GDT remapping is read-only */
+#ifdef CONFIG_X86_64
+#define PAGE_FIXMAP_GDT PAGE_KERNEL_RO
+#else
+#define PAGE_FIXMAP_GDT PAGE_KERNEL
+#endif
+
 /* Setup the fixmap mapping only once per-processor */
 static inline void setup_fixmap_gdt(int cpu)
 {
 	__set_fixmap(get_cpu_gdt_ro_index(cpu),
-		     __pa(get_cpu_gdt_rw(cpu)), PAGE_KERNEL);
+		     __pa(get_cpu_gdt_rw(cpu)), PAGE_FIXMAP_GDT);
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
@@ -464,6 +482,7 @@ void load_fixmap_gdt(int cpu)
 	gdt_descr.size = GDT_SIZE - 1;
 	load_gdt(&gdt_descr);
 }
+EXPORT_SYMBOL_GPL(load_fixmap_gdt);
 
 /*
  * Current gdt points %fs at the "master" per-cpu area: after this,
@@ -471,11 +490,8 @@ void load_fixmap_gdt(int cpu)
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
index 283aa8601833..440ba96e4dfe 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -935,7 +935,6 @@ static DEFINE_PER_CPU(struct vmcs *, current_vmcs);
  * when a CPU is brought down, and we need to VMCLEAR all VMCSs loaded on it.
  */
 static DEFINE_PER_CPU(struct list_head, loaded_vmcss_on_cpu);
-static DEFINE_PER_CPU(struct desc_ptr, host_gdt);
 
 /*
  * We maintian a per-CPU linked-list of vCPU, so in wakeup_handler() we
@@ -2059,7 +2058,7 @@ static unsigned long segment_base(u16 selector)
 	if (!(selector & ~SEGMENT_RPL_MASK))
 		return 0;
 
-	table = (struct desc_struct *)gdt->address;
+	table = get_current_gdt_ro();
 
 	if ((selector & SEGMENT_TI_MASK) == SEGMENT_LDT) {
 		u16 ldt_selector = kvm_read_ldt();
@@ -2164,7 +2163,7 @@ static void __vmx_load_host_state(struct vcpu_vmx *vmx)
 #endif
 	if (vmx->host_state.msr_host_bndcfgs)
 		wrmsrl(MSR_IA32_BNDCFGS, vmx->host_state.msr_host_bndcfgs);
-	load_gdt(this_cpu_ptr(&host_gdt));
+	load_fixmap_gdt(raw_smp_processor_id());
 }
 
 static void vmx_load_host_state(struct vcpu_vmx *vmx)
@@ -2266,7 +2265,7 @@ static void vmx_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 	}
 
 	if (!already_loaded) {
-		struct desc_ptr *gdt = this_cpu_ptr(&host_gdt);
+		unsigned long gdt = get_current_gdt_ro_vaddr();
 		unsigned long sysenter_esp;
 
 		kvm_make_request(KVM_REQ_TLB_FLUSH, vcpu);
@@ -2277,7 +2276,7 @@ static void vmx_vcpu_load(struct kvm_vcpu *vcpu, int cpu)
 		 */
 		vmcs_writel(HOST_TR_BASE,
 			    (unsigned long)this_cpu_ptr(&cpu_tss));
-		vmcs_writel(HOST_GDTR_BASE, gdt->address);
+		vmcs_writel(HOST_GDTR_BASE, gdt);   /* 22.2.4 */
 
 		/*
 		 * VM exits change the host TR limit to 0x67 after a VM
@@ -3465,8 +3464,6 @@ static int hardware_enable(void)
 		ept_sync_global();
 	}
 
-	native_store_gdt(this_cpu_ptr(&host_gdt));
-
 	return 0;
 }
 
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
