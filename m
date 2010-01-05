Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9D3926007D6
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 09:13:14 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v3 03/12] Add async PF initialization to PV guest.
Date: Tue,  5 Jan 2010 16:12:45 +0200
Message-Id: <1262700774-1808-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>


Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    5 ++++
 arch/x86/kernel/kvm.c           |   49 +++++++++++++++++++++++++++++++++++++++
 arch/x86/kernel/smpboot.c       |    3 ++
 include/linux/kvm_para.h        |    2 +
 4 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index f77eed3..56ca41b 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -51,6 +51,11 @@ struct kvm_mmu_op_release_pt {
 	__u64 pt_phys;
 };
 
+struct kvm_vcpu_pv_apf_data {
+	__u32 reason;
+	__u32 enabled;
+};
+
 #ifdef __KERNEL__
 #include <asm/processor.h>
 
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index e6db179..001222c 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -27,7 +27,10 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/hardirq.h>
+#include <linux/notifier.h>
+#include <linux/reboot.h>
 #include <asm/timer.h>
+#include <asm/cpu.h>
 
 #define MMU_QUEUE_SIZE 1024
 
@@ -37,6 +40,7 @@ struct kvm_para_state {
 };
 
 static DEFINE_PER_CPU(struct kvm_para_state, para_state);
+static DEFINE_PER_CPU_ALIGNED(struct kvm_vcpu_pv_apf_data, apf_reason);
 
 static struct kvm_para_state *kvm_para_state(void)
 {
@@ -231,10 +235,35 @@ static void __init paravirt_ops_setup(void)
 #endif
 }
 
+static void kvm_pv_disable_apf(void *unused)
+{
+	if (!__get_cpu_var(apf_reason).enabled)
+		return;
+
+	wrmsrl(MSR_KVM_ASYNC_PF_EN, 0);
+	__get_cpu_var(apf_reason).enabled = 0;
+
+	printk(KERN_INFO"Unregister pv shared memory for cpu %d\n",
+	       smp_processor_id());
+}
+
+static int kvm_pv_reboot_notify(struct notifier_block *nb,
+				unsigned long code, void *unused)
+{
+	if (code == SYS_RESTART)
+		on_each_cpu(kvm_pv_disable_apf, NULL, 1);
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block kvm_pv_reboot_nb = {
+	.notifier_call = kvm_pv_reboot_notify,
+};
+
 #ifdef CONFIG_SMP
 static void __init kvm_smp_prepare_boot_cpu(void)
 {
 	WARN_ON(kvm_register_clock("primary cpu clock"));
+	kvm_guest_cpu_init();
 	native_smp_prepare_boot_cpu();
 }
 #endif
@@ -245,7 +274,27 @@ void __init kvm_guest_init(void)
 		return;
 
 	paravirt_ops_setup();
+	register_reboot_notifier(&kvm_pv_reboot_nb);
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
+#else
+	kvm_guest_cpu_init();
 #endif
 }
+
+void __cpuinit kvm_guest_cpu_init(void)
+{
+	if (!kvm_para_available())
+		return;
+
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF)) {
+		u64 pa = __pa(&__get_cpu_var(apf_reason));
+
+		if (native_write_msr_safe(MSR_KVM_ASYNC_PF_EN,
+					  pa | KVM_ASYNC_PF_ENABLED, pa >> 32))
+			return;
+		__get_cpu_var(apf_reason).enabled = 1;
+		printk(KERN_INFO"Setup pv shared memory for cpu %d\n",
+		       smp_processor_id());
+	}
+}
diff --git a/arch/x86/kernel/smpboot.c b/arch/x86/kernel/smpboot.c
index 678d0b8..0a9eef4 100644
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
 
diff --git a/include/linux/kvm_para.h b/include/linux/kvm_para.h
index d731092..4c8a2e6 100644
--- a/include/linux/kvm_para.h
+++ b/include/linux/kvm_para.h
@@ -26,8 +26,10 @@
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
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
