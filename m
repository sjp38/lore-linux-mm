Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7E9906007F8
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 11:31:22 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v5 03/12] Add async PF initialization to PV guest.
Date: Mon, 19 Jul 2010 18:30:53 +0300
Message-Id: <1279553462-7036-4-git-send-email-gleb@redhat.com>
In-Reply-To: <1279553462-7036-1-git-send-email-gleb@redhat.com>
References: <1279553462-7036-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Enable async PF in a guest if async PF capability is discovered.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    5 +++
 arch/x86/kernel/kvm.c           |   68 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 73 insertions(+), 0 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 5b05e9f..f1662d7 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -65,6 +65,11 @@ struct kvm_mmu_op_release_pt {
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
index e6db179..5177dd1 100644
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
+static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
 
 static struct kvm_para_state *kvm_para_state(void)
 {
@@ -231,12 +235,72 @@ static void __init paravirt_ops_setup(void)
 #endif
 }
 
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
+		printk(KERN_INFO"KVM setup async PF for cpu %d\n",
+		       smp_processor_id());
+	}
+}
+
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
+
+static int __cpuinit kvm_cpu_notify(struct notifier_block *self,
+				    unsigned long action, void *hcpu)
+{
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_ONLINE_FROZEN:
+		kvm_guest_cpu_init();
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block __cpuinitdata kvm_cpu_notifier = {
+        .notifier_call  = kvm_cpu_notify,
+};
 #endif
 
 void __init kvm_guest_init(void)
@@ -245,7 +309,11 @@ void __init kvm_guest_init(void)
 		return;
 
 	paravirt_ops_setup();
+	register_reboot_notifier(&kvm_pv_reboot_nb);
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
+	register_cpu_notifier(&kvm_cpu_notifier);
+#else
+	kvm_guest_cpu_init();
 #endif
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
