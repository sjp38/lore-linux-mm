Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A913C6B0078
	for <linux-mm@kvack.org>; Sun,  1 Nov 2009 06:56:34 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH 01/11] Add shared memory hypercall to PV Linux guest.
Date: Sun,  1 Nov 2009 13:56:20 +0200
Message-Id: <1257076590-29559-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1257076590-29559-1-git-send-email-gleb@redhat.com>
References: <1257076590-29559-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add hypercall that allows guest and host to setup per cpu shared
memory.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_host.h |    3 +
 arch/x86/include/asm/kvm_para.h |   11 +++++
 arch/x86/kernel/kvm.c           |   82 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/setup.c         |    1 +
 arch/x86/kernel/smpboot.c       |    3 +
 arch/x86/kvm/x86.c              |   70 +++++++++++++++++++++++++++++++++
 include/linux/kvm.h             |    1 +
 include/linux/kvm_para.h        |    4 ++
 8 files changed, 175 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
index 26a74b7..2d1f526 100644
--- a/arch/x86/include/asm/kvm_host.h
+++ b/arch/x86/include/asm/kvm_host.h
@@ -374,6 +374,9 @@ struct kvm_vcpu_arch {
 	/* used for guest single stepping over the given code position */
 	u16 singlestep_cs;
 	unsigned long singlestep_rip;
+
+	struct kvm_vcpu_pv_shm *pv_shm;
+	struct page *pv_shm_page;
 };
 
 struct kvm_mem_alias {
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index c584076..90708b7 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -15,6 +15,7 @@
 #define KVM_FEATURE_CLOCKSOURCE		0
 #define KVM_FEATURE_NOP_IO_DELAY	1
 #define KVM_FEATURE_MMU_OP		2
+#define KVM_FEATURE_ASYNC_PF		3
 
 #define MSR_KVM_WALL_CLOCK  0x11
 #define MSR_KVM_SYSTEM_TIME 0x12
@@ -47,6 +48,16 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+#define KVM_PV_SHM_VERSION 1
+
+#define KVM_PV_SHM_FEATURES_ASYNC_PF		(1 << 0)
+
+struct kvm_vcpu_pv_shm {
+	__u64 features;
+	__u64 reason;
+	__u64 param;
+};
+
 #ifdef __KERNEL__
 #include <asm/processor.h>
 
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 63b0ec8..d03f33c 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -27,7 +27,11 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/hardirq.h>
+#include <linux/bootmem.h>
+#include <linux/notifier.h>
+#include <linux/reboot.h>
 #include <asm/timer.h>
+#include <asm/cpu.h>
 
 #define MMU_QUEUE_SIZE 1024
 
@@ -37,6 +41,7 @@ struct kvm_para_state {
 };
 
 static DEFINE_PER_CPU(struct kvm_para_state, para_state);
+static DEFINE_PER_CPU(struct kvm_vcpu_pv_shm *, kvm_vcpu_pv_shm);
 
 static struct kvm_para_state *kvm_para_state(void)
 {
@@ -50,6 +55,17 @@ static void kvm_io_delay(void)
 {
 }
 
+static void kvm_end_context_switch(struct task_struct *next)
+{
+	struct kvm_vcpu_pv_shm *pv_shm =
+		per_cpu(kvm_vcpu_pv_shm, smp_processor_id());
+
+	if (!pv_shm)
+		return;
+
+	pv_shm->current_task = (u64)next;
+}
+
 static void kvm_mmu_op(void *buffer, unsigned len)
 {
 	int r;
@@ -231,10 +247,76 @@ static void __init paravirt_ops_setup(void)
 #endif
 }
 
+static void kvm_pv_unregister_shm(void *unused)
+{
+	if (per_cpu(kvm_vcpu_pv_shm, smp_processor_id()) == NULL)
+		return;
+
+	kvm_hypercall3(KVM_HC_SETUP_SHM, 0, 0, KVM_PV_SHM_VERSION);
+	printk(KERN_INFO"Unregister pv shared memory for cpu %d\n",
+	       smp_processor_id());
+
+}
+
+static int kvm_pv_reboot_notify(struct notifier_block *nb,
+				unsigned long code, void *unused)
+{
+	if (code == SYS_RESTART)
+		on_each_cpu(kvm_pv_unregister_shm, NULL, 1);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block kvm_pv_reboot_nb = {
+        .notifier_call = kvm_pv_reboot_notify,
+};
+
 void __init kvm_guest_init(void)
 {
 	if (!kvm_para_available())
 		return;
 
 	paravirt_ops_setup();
+	register_reboot_notifier(&kvm_pv_reboot_nb);
+}
+
+void __cpuinit kvm_guest_cpu_init(void)
+{
+	int r;
+	unsigned long a0, a1, a2;
+	struct kvm_vcpu_pv_shm *pv_shm;
+
+	if (!kvm_para_available())
+		return;
+
+	if (smp_processor_id() == boot_cpu_id)
+		pv_shm = alloc_bootmem(sizeof(*pv_shm));
+	else
+		pv_shm = kmalloc(sizeof(*pv_shm), GFP_ATOMIC);
+
+	if (!pv_shm)
+		return;
+
+	memset(pv_shm, 0, sizeof(*pv_shm));
+
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF))
+		pv_shm->features |= KVM_PV_SHM_FEATURES_ASYNC_PF;
+
+	per_cpu(kvm_vcpu_pv_shm, smp_processor_id()) = pv_shm;
+	a0 = __pa(pv_shm);
+	a1 = sizeof(*pv_shm);
+	a2 = KVM_PV_SHM_VERSION;
+	r = kvm_hypercall3(KVM_HC_SETUP_SHM, a0, a1, a2);
+
+	if (!r) {
+		printk(KERN_INFO"Setup pv shared memory for cpu %d\n",
+		       smp_processor_id());
+		return;
+	}
+
+	if (smp_processor_id() == boot_cpu_id)
+		free_bootmem(__pa(pv_shm), sizeof(*pv_shm));
+	else
+		kfree(pv_shm);
+
+	per_cpu(kvm_vcpu_pv_shm, smp_processor_id()) = NULL;
 }
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index e09f0e2..1c2f8dd 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1007,6 +1007,7 @@ void __init setup_arch(char **cmdline_p)
 	probe_nr_irqs_gsi();
 
 	kvm_guest_init();
+	kvm_guest_cpu_init();
 
 	e820_reserve_resources();
 	e820_mark_nosave_regions(max_low_pfn);
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index 565ebc6..5599098 100644
--- a/arch/x86/kernel/smpboot.c
+++ b/arch/x86/kernel/smpboot.c
@@ -65,6 +65,7 @@
 #include <asm/setup.h>
 #include <asm/uv/uv.h>
 #include <linux/mc146818rtc.h>
+#include <linux/kvm_para.h>
 
 #include <asm/smpboot_hooks.h>
 
@@ -321,6 +322,8 @@ notrace static void __cpuinit start_secondary(void *unused)
 	ipi_call_unlock();
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 
+	kvm_guest_cpu_init();
+
 	/* enable local interrupts */
 	local_irq_enable();
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 2ef3906..c177933 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -1342,6 +1342,7 @@ int kvm_dev_ioctl_check_extension(long ext)
 	case KVM_CAP_SET_IDENTITY_MAP_ADDR:
 	case KVM_CAP_XEN_HVM:
 	case KVM_CAP_ADJUST_CLOCK:
+	case KVM_CAP_ASYNC_PF:
 		r = 1;
 		break;
 	case KVM_CAP_COALESCED_MMIO:
@@ -3371,6 +3372,68 @@ int kvm_emulate_halt(struct kvm_vcpu *vcpu)
 }
 EXPORT_SYMBOL_GPL(kvm_emulate_halt);
 
+static void kvm_pv_release_shm(struct kvm_vcpu *vcpu)
+{
+	if (!vcpu->arch.pv_shm_page)
+		return;
+
+	kunmap(vcpu->arch.pv_shm_page);
+	put_page(vcpu->arch.pv_shm_page);
+	vcpu->arch.pv_shm_page = NULL;
+	vcpu->arch.pv_shm = NULL;
+}
+
+static int kvm_pv_setup_shm(struct kvm_vcpu *vcpu, unsigned long gpa,
+			    unsigned long size, unsigned long version,
+			    unsigned long *ret)
+{
+	int r;
+	unsigned long addr;
+	gfn_t gfn = gpa >> PAGE_SHIFT;
+	int offset = offset_in_page(gpa);
+	struct mm_struct *mm = current->mm;
+	void *p;
+
+	*ret = -KVM_EINVAL;
+
+	if (size == 0 && vcpu->arch.pv_shm != NULL &&
+	    version == KVM_PV_SHM_VERSION) {
+		kvm_pv_release_shm(vcpu);
+		goto out;
+	}
+
+	if (vcpu->arch.pv_shm != NULL || size != sizeof(*vcpu->arch.pv_shm) ||
+	    size > PAGE_SIZE || version != KVM_PV_SHM_VERSION)
+		return -EINVAL;
+
+	*ret = -KVM_EFAULT;
+
+	addr = gfn_to_hva(vcpu->kvm, gfn);
+	if (kvm_is_error_hva(addr))
+		return -EFAULT;
+
+	/* pin page with pv shared memory */
+	down_read(&mm->mmap_sem);
+	r = get_user_pages(current, mm, addr, 1, 1, 0, &vcpu->arch.pv_shm_page,
+			   NULL);
+	up_read(&mm->mmap_sem);
+	if (r != 1)
+		return -EFAULT;
+
+	p = kmap(vcpu->arch.pv_shm_page);
+	if (!p) {
+		put_page(vcpu->arch.pv_shm_page);
+		vcpu->arch.pv_shm_page = NULL;
+		return -ENOMEM;
+	}
+
+	vcpu->arch.pv_shm = p + offset;
+
+out:
+	*ret = 0;
+	return 0;
+}
+
 static inline gpa_t hc_gpa(struct kvm_vcpu *vcpu, unsigned long a0,
 			   unsigned long a1)
 {
@@ -3413,6 +3476,9 @@ int kvm_emulate_hypercall(struct kvm_vcpu *vcpu)
 	case KVM_HC_MMU_OP:
 		r = kvm_pv_mmu_op(vcpu, a0, hc_gpa(vcpu, a1, a2), &ret);
 		break;
+	case KVM_HC_SETUP_SHM:
+		r = kvm_pv_setup_shm(vcpu, a0, a1, a2, &ret);
+		break;
 	default:
 		ret = -KVM_ENOSYS;
 		break;
@@ -4860,6 +4926,8 @@ free_vcpu:
 
 void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
 {
+	kvm_pv_release_shm(vcpu);
+
 	vcpu_load(vcpu);
 	kvm_mmu_unload(vcpu);
 	vcpu_put(vcpu);
@@ -4877,6 +4945,8 @@ int kvm_arch_vcpu_reset(struct kvm_vcpu *vcpu)
 	vcpu->arch.dr6 = DR6_FIXED_1;
 	vcpu->arch.dr7 = DR7_FIXED_1;
 
+	kvm_pv_release_shm(vcpu);
+
 	return kvm_x86_ops->vcpu_reset(vcpu);
 }
 
diff --git a/include/linux/kvm.h b/include/linux/kvm.h
index 6ed1a12..2fec4a2 100644
--- a/include/linux/kvm.h
+++ b/include/linux/kvm.h
@@ -440,6 +440,7 @@ struct kvm_ioeventfd {
 #define KVM_CAP_XEN_HVM 38
 #endif
 #define KVM_CAP_ADJUST_CLOCK 39
+#define KVM_CAP_ASYNC_PF 40
 
 #ifdef KVM_CAP_IRQ_ROUTING
 
diff --git a/include/linux/kvm_para.h b/include/linux/kvm_para.h
index d731092..1c37495 100644
--- a/include/linux/kvm_para.h
+++ b/include/linux/kvm_para.h
@@ -14,9 +14,11 @@
 #define KVM_EFAULT		EFAULT
 #define KVM_E2BIG		E2BIG
 #define KVM_EPERM		EPERM
+#define KVM_EINVAL		EINVAL
 
 #define KVM_HC_VAPIC_POLL_IRQ		1
 #define KVM_HC_MMU_OP			2
+#define KVM_HC_SETUP_SHM		3
 
 /*
  * hypercalls use architecture specific
@@ -26,8 +28,10 @@
 #ifdef __KERNEL__
 #ifdef CONFIG_KVM_GUEST
 void __init kvm_guest_init(void);
+void __cpuinit kvm_guest_cpu_init(void);
 #else
 #define kvm_guest_init() do { } while (0)
+#define kvm_guest_cpu_init() do { } while (0)
 #endif
 
 static inline int kvm_para_has_feature(unsigned int feature)
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
