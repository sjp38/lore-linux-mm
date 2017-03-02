Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB9A6B03B2
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 10:17:33 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id s132so33794488oie.1
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 07:17:33 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0048.outbound.protection.outlook.com. [104.47.38.48])
        by mx.google.com with ESMTPS id o110si2491547ota.66.2017.03.02.07.17.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 07:17:32 -0800 (PST)
Subject: [RFC PATCH v2 24/32] kvm: x86: prepare for SEV guest management API
 support
From: Brijesh Singh <brijesh.singh@amd.com>
Date: Thu, 2 Mar 2017 10:17:22 -0500
Message-ID: <148846784278.2349.17771314083820274411.stgit@brijesh-build-machine>
In-Reply-To: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: simon.guinot@sequanux.org, linux-efi@vger.kernel.org, brijesh.singh@amd.com, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

The patch adds initial support required to integrate Secure Encrypted
Virtualization (SEV) feature.

ASID management:
 - Reserve asid range for SEV guest, SEV asid range is obtained through
   CPUID Fn8000_001f[ECX]. A non-SEV guest can use any asid outside the SEV
   asid range.
 - SEV guest must have asid value within asid range obtained through CPUID.
 - SEV guest must have the same asid for all vcpu's. A TLB flush is required
   if different vcpu for the same ASID is to be run on the same host CPU.

Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
---
 arch/x86/include/asm/kvm_host.h |    8 ++
 arch/x86/kvm/svm.c              |  189 +++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/kvm.h        |   98 ++++++++++++++++++++
 3 files changed, 294 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 62651ad..fcc4710 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -719,6 +719,12 @@ struct kvm_hv {
 	HV_REFERENCE_TSC_PAGE tsc_ref;
 };
 
+struct kvm_sev_info {
+	unsigned int handle;	/* firmware handle */
+	unsigned int asid;	/* asid for this guest */
+	int sev_fd;		/* SEV device fd */
+};
+
 struct kvm_arch {
 	unsigned int n_used_mmu_pages;
 	unsigned int n_requested_mmu_pages;
@@ -805,6 +811,8 @@ struct kvm_arch {
 
 	bool x2apic_format;
 	bool x2apic_broadcast_quirk_disabled;
+
+	struct kvm_sev_info sev_info;
 };
 
 struct kvm_vm_stat {
diff --git a/arch/x86/kvm/svm.c b/arch/x86/kvm/svm.c
index 8d8fe62..fb63398 100644
--- a/arch/x86/kvm/svm.c
+++ b/arch/x86/kvm/svm.c
@@ -36,6 +36,7 @@
 #include <linux/slab.h>
 #include <linux/amd-iommu.h>
 #include <linux/hashtable.h>
+#include <linux/psp-sev.h>
 
 #include <asm/apic.h>
 #include <asm/perf_event.h>
@@ -211,6 +212,9 @@ struct vcpu_svm {
 	 */
 	struct list_head ir_list;
 	spinlock_t ir_list_lock;
+
+	/* which host cpu was used for running this vcpu */
+	bool last_cpuid;
 };
 
 /*
@@ -490,6 +494,64 @@ static inline bool gif_set(struct vcpu_svm *svm)
 	return !!(svm->vcpu.arch.hflags & HF_GIF_MASK);
 }
 
+/* Secure Encrypted Virtualization */
+static unsigned int max_sev_asid;
+static unsigned long *sev_asid_bitmap;
+
+static bool kvm_sev_enabled(void)
+{
+	return max_sev_asid ? 1 : 0;
+}
+
+static inline struct kvm_sev_info *sev_get_info(struct kvm *kvm)
+{
+	struct kvm_arch *vm_data = &kvm->arch;
+
+	return &vm_data->sev_info;
+}
+
+static unsigned int sev_get_handle(struct kvm *kvm)
+{
+	struct kvm_sev_info *sev_info = sev_get_info(kvm);
+
+	return sev_info->handle;
+}
+
+static inline int sev_guest(struct kvm *kvm)
+{
+	return sev_get_handle(kvm);
+}
+
+static inline int sev_get_asid(struct kvm *kvm)
+{
+	struct kvm_sev_info *sev_info = sev_get_info(kvm);
+
+	if (!sev_info)
+		return -EINVAL;
+
+	return sev_info->asid;
+}
+
+static inline int sev_get_fd(struct kvm *kvm)
+{
+	struct kvm_sev_info *sev_info = sev_get_info(kvm);
+
+	if (!sev_info)
+		return -EINVAL;
+
+	return sev_info->sev_fd;
+}
+
+static inline void sev_set_asid(struct kvm *kvm, int asid)
+{
+	struct kvm_sev_info *sev_info = sev_get_info(kvm);
+
+	if (!sev_info)
+		return;
+
+	sev_info->asid = asid;
+}
+
 static unsigned long iopm_base;
 
 struct kvm_ldttss_desc {
@@ -511,6 +573,8 @@ struct svm_cpu_data {
 	struct kvm_ldttss_desc *tss_desc;
 
 	struct page *save_area;
+
+	struct vmcb **sev_vmcbs;  /* index = sev_asid, value = vmcb pointer */
 };
 
 static DEFINE_PER_CPU(struct svm_cpu_data *, svm_data);
@@ -764,7 +828,7 @@ static int svm_hardware_enable(void)
 	sd->asid_generation = 1;
 	sd->max_asid = cpuid_ebx(SVM_CPUID_FUNC) - 1;
 	sd->next_asid = sd->max_asid + 1;
-	sd->min_asid = 1;
+	sd->min_asid = max_sev_asid + 1;
 
 	native_store_gdt(&gdt_descr);
 	gdt = (struct desc_struct *)gdt_descr.address;
@@ -825,6 +889,7 @@ static void svm_cpu_uninit(int cpu)
 
 	per_cpu(svm_data, raw_smp_processor_id()) = NULL;
 	__free_page(sd->save_area);
+	kfree(sd->sev_vmcbs);
 	kfree(sd);
 }
 
@@ -842,6 +907,14 @@ static int svm_cpu_init(int cpu)
 	if (!sd->save_area)
 		goto err_1;
 
+	if (kvm_sev_enabled()) {
+		sd->sev_vmcbs = kmalloc((max_sev_asid + 1) * sizeof(void *),
+					GFP_KERNEL);
+		r = -ENOMEM;
+		if (!sd->sev_vmcbs)
+			goto err_1;
+	}
+
 	per_cpu(svm_data, cpu) = sd;
 
 	return 0;
@@ -1017,6 +1090,61 @@ static int avic_ga_log_notifier(u32 ga_tag)
 	return 0;
 }
 
+static __init void sev_hardware_setup(void)
+{
+	int ret, error, nguests;
+	struct sev_data_init *init;
+	struct sev_data_status *status;
+
+	/*
+	 * Get maximum number of encrypted guest supported: Fn8001_001F[ECX]
+	 * 	Bit 31:0: Number of supported guest
+	 */
+	nguests = cpuid_ecx(0x8000001F);
+	if (!nguests)
+		return;
+
+	init = kzalloc(sizeof(*init), GFP_KERNEL);
+	if (!init)
+		return;
+
+	status = kzalloc(sizeof(*status), GFP_KERNEL);
+	if (!status)
+		goto err_1;
+
+	/* Initialize SEV firmware */
+	ret = sev_platform_init(init, &error);
+	if (ret) {
+		pr_err("SEV: PLATFORM_INIT ret=%d (%#x)\n", ret, error);
+		goto err_2;
+	}
+
+	/* Initialize SEV ASID bitmap */
+	sev_asid_bitmap = kcalloc(BITS_TO_LONGS(nguests),
+				  sizeof(unsigned long), GFP_KERNEL);
+	if (IS_ERR(sev_asid_bitmap)) {
+		sev_platform_shutdown(&error);
+		goto err_2;
+	}
+
+	/* Query the platform status and print API version */
+	ret = sev_platform_status(status, &error);
+	if (ret) {
+		printk(KERN_ERR "SEV: PLATFORM_STATUS ret=%#x\n", error);
+		goto err_2;
+	}
+
+	max_sev_asid = nguests;
+
+	printk(KERN_INFO "kvm: SEV enabled\n");
+	printk(KERN_INFO "SEV API: %d.%d\n",
+			status->api_major, status->api_minor);
+err_2:
+	kfree(status);
+err_1:
+	kfree(init);
+}
+
 static __init int svm_hardware_setup(void)
 {
 	int cpu;
@@ -1052,6 +1180,9 @@ static __init int svm_hardware_setup(void)
 		kvm_enable_efer_bits(EFER_SVME | EFER_LMSLE);
 	}
 
+	if (boot_cpu_has(X86_FEATURE_SEV))
+		sev_hardware_setup();
+
 	for_each_possible_cpu(cpu) {
 		r = svm_cpu_init(cpu);
 		if (r)
@@ -1094,10 +1225,25 @@ static __init int svm_hardware_setup(void)
 	return r;
 }
 
+static __exit void sev_hardware_unsetup(void)
+{
+	int ret, err;
+
+	ret = sev_platform_shutdown(&err);
+	if (ret)
+		printk(KERN_ERR "failed to shutdown PSP rc=%d (%#0x10x)\n",
+		ret, err);
+
+	kfree(sev_asid_bitmap);
+}
+
 static __exit void svm_hardware_unsetup(void)
 {
 	int cpu;
 
+	if (kvm_sev_enabled())
+		sev_hardware_unsetup();
+
 	for_each_possible_cpu(cpu)
 		svm_cpu_uninit(cpu);
 
@@ -1157,6 +1303,11 @@ static void avic_init_vmcb(struct vcpu_svm *svm)
 	svm->vcpu.arch.apicv_active = true;
 }
 
+static void sev_init_vmcb(struct vcpu_svm *svm)
+{
+	svm->vmcb->control.nested_ctl |= SVM_NESTED_CTL_SEV_ENABLE;
+}
+
 static void init_vmcb(struct vcpu_svm *svm)
 {
 	struct vmcb_control_area *control = &svm->vmcb->control;
@@ -1271,6 +1422,9 @@ static void init_vmcb(struct vcpu_svm *svm)
 	if (avic)
 		avic_init_vmcb(svm);
 
+	if (sev_guest(svm->vcpu.kvm))
+		sev_init_vmcb(svm);
+
 	mark_all_dirty(svm->vmcb);
 
 	enable_gif(svm);
@@ -2084,6 +2238,11 @@ static int pf_interception(struct vcpu_svm *svm)
 	default:
 		error_code = svm->vmcb->control.exit_info_1;
 
+		/* In SEV mode, the guest physical address will have C-bit
+		 * set. C-bit must be cleared before handling the fault.
+		 */
+		if (sev_guest(svm->vcpu.kvm))
+			fault_address &= ~sme_me_mask;
 		trace_kvm_page_fault(fault_address, error_code);
 		if (!npt_enabled && kvm_event_needs_reinjection(&svm->vcpu))
 			kvm_mmu_unprotect_page_virt(&svm->vcpu, fault_address);
@@ -4258,12 +4417,40 @@ static void reload_tss(struct kvm_vcpu *vcpu)
 	load_TR_desc();
 }
 
+static void pre_sev_run(struct vcpu_svm *svm)
+{
+	int asid = sev_get_asid(svm->vcpu.kvm);
+	int cpu = raw_smp_processor_id();
+	struct svm_cpu_data *sd = per_cpu(svm_data, cpu);
+
+	/* Assign the asid allocated for this SEV guest */
+	svm->vmcb->control.asid = asid;
+
+	/* Flush guest TLB:
+	 * - when different VMCB for the same ASID is to be run on the
+	 *   same host CPU
+	 *   or
+	 * - this VMCB was executed on different host cpu in previous VMRUNs.
+	 */
+	if (sd->sev_vmcbs[asid] != (void *)svm->vmcb ||
+		svm->last_cpuid != cpu)
+		svm->vmcb->control.tlb_ctl = TLB_CONTROL_FLUSH_ALL_ASID;
+
+	svm->last_cpuid = cpu;
+	sd->sev_vmcbs[asid] = (void *)svm->vmcb;
+
+	mark_dirty(svm->vmcb, VMCB_ASID);
+}
+
 static void pre_svm_run(struct vcpu_svm *svm)
 {
 	int cpu = raw_smp_processor_id();
 
 	struct svm_cpu_data *sd = per_cpu(svm_data, cpu);
 
+	if (sev_guest(svm->vcpu.kvm))
+		return pre_sev_run(svm);
+
 	/* FIXME: handle wraparound of asid_generation */
 	if (svm->asid_generation != sd->asid_generation)
 		new_asid(svm, sd);
diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
index fef7d83..9df37a2 100644
--- a/include/uapi/linux/kvm.h
+++ b/include/uapi/linux/kvm.h
@@ -1284,6 +1284,104 @@ struct kvm_s390_ucas_mapping {
 /* Memory Encryption Commands */
 #define KVM_MEMORY_ENCRYPT_OP	  _IOWR(KVMIO, 0xb8, unsigned long)
 
+/* Secure Encrypted Virtualization mode */
+enum sev_cmd_id {
+	/* Guest launch commands */
+	KVM_SEV_LAUNCH_START = 0,
+	KVM_SEV_LAUNCH_UPDATE_DATA,
+	KVM_SEV_LAUNCH_MEASURE,
+	KVM_SEV_LAUNCH_FINISH,
+	/* Guest migration commands (outgoing) */
+	KVM_SEV_SEND_START,
+	KVM_SEV_SEND_UPDATE_DATA,
+	KVM_SEV_SEND_FINISH,
+	/* Guest migration commands (incoming) */
+	KVM_SEV_RECEIVE_START,
+	KVM_SEV_RECEIVE_UPDATE_DATA,
+	KVM_SEV_RECEIVE_FINISH,
+	/* Guest status and debug commands */
+	KVM_SEV_GUEST_STATUS,
+	KVM_SEV_DBG_DECRYPT,
+	KVM_SEV_DBG_ENCRYPT,
+
+	KVM_SEV_NR_MAX,
+};
+
+struct kvm_sev_cmd {
+	__u32 id;
+	__u64 data;
+	__u32 error;
+	__u32 sev_fd;
+};
+
+struct kvm_sev_launch_start {
+	__u32 handle;
+	__u32 policy;
+	__u64 dh_cert_data;
+	__u32 dh_cert_length;
+	__u64 session_data;
+	__u32 session_length;
+};
+
+struct kvm_sev_launch_update_data {
+	__u64 address;
+	__u32 length;
+};
+
+struct kvm_sev_launch_measure {
+	__u64 address;
+	__u32 length;
+};
+
+struct kvm_sev_send_start {
+	__u64 pdh_cert_data;
+	__u32 pdh_cert_length;
+	__u64 plat_cert_data;
+	__u32 plat_cert_length;
+	__u64 amd_cert_data;
+	__u32 amd_cert_length;
+	__u64 session_data;
+	__u32 session_length;
+};
+
+struct kvm_sev_send_update_data {
+	__u64 hdr_data;
+	__u32 hdr_length;
+	__u64 guest_address;
+	__u32 guest_length;
+	__u64 host_address;
+	__u32 host_length;
+};
+
+struct kvm_sev_receive_start {
+	__u32 handle;
+	__u64 pdh_cert_data;
+	__u32 pdh_cert_length;
+	__u64 session_data;
+	__u32 session_length;
+};
+
+struct kvm_sev_receive_update_data {
+	__u64 hdr_data;
+	__u32 hdr_length;
+	__u64 guest_address;
+	__u32 guest_length;
+	__u64 host_address;
+	__u32 host_length;
+};
+
+struct kvm_sev_guest_status {
+	__u32 handle;
+	__u32 policy;
+	__u32 state;
+};
+
+struct kvm_sev_dbg {
+	__u64 src_addr;
+	__u64 dst_addr;
+	__u32 length;
+};
+
 #define KVM_DEV_ASSIGN_ENABLE_IOMMU	(1 << 0)
 #define KVM_DEV_ASSIGN_PCI_2_3		(1 << 1)
 #define KVM_DEV_ASSIGN_MASK_INTX	(1 << 2)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
