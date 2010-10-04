Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D12076B007B
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 11:56:44 -0400 (EDT)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v6 07/12] Add async PF initialization to PV guest.
Date: Mon,  4 Oct 2010 17:56:29 +0200
Message-Id: <1286207794-16120-8-git-send-email-gleb@redhat.com>
In-Reply-To: <1286207794-16120-1-git-send-email-gleb@redhat.com>
References: <1286207794-16120-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

Enable async PF in a guest if async PF capability is discovered.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 Documentation/kernel-parameters.txt |    3 +
 arch/x86/include/asm/kvm_para.h     |    5 ++
 arch/x86/kernel/kvm.c               |   92 +++++++++++++++++++++++++++++++++++
 3 files changed, 100 insertions(+), 0 deletions(-)

diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
index 8dc2548..0bd2203 100644
--- a/Documentation/kernel-parameters.txt
+++ b/Documentation/kernel-parameters.txt
@@ -1699,6 +1699,9 @@ and is between 256 and 4096 characters. It is defined in the file
 
 	no-kvmclock	[X86,KVM] Disable paravirtualized KVM clock driver
 
+	no-kvmapf	[X86,KVM] Disable paravirtualized asynchronous page
+			fault handling.
+
 	nolapic		[X86-32,APIC] Do not enable or use the local APIC.
 
 	nolapic_timer	[X86-32,APIC] Do not use the local APIC timer.
diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index 8662ae0..e193c4f 100644
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
index e6db179..67d1c8d 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -27,16 +27,30 @@
 #include <linux/mm.h>
 #include <linux/highmem.h>
 #include <linux/hardirq.h>
+#include <linux/notifier.h>
+#include <linux/reboot.h>
 #include <asm/timer.h>
+#include <asm/cpu.h>
 
 #define MMU_QUEUE_SIZE 1024
 
+static int kvmapf = 1;
+
+static int parse_no_kvmapf(char *arg)
+{
+        kvmapf = 0;
+        return 0;
+}
+
+early_param("no-kvmapf", parse_no_kvmapf);
+
 struct kvm_para_state {
 	u8 mmu_queue[MMU_QUEUE_SIZE];
 	int mmu_queue_len;
 };
 
 static DEFINE_PER_CPU(struct kvm_para_state, para_state);
+static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
 
 static struct kvm_para_state *kvm_para_state(void)
 {
@@ -231,12 +245,86 @@ static void __init paravirt_ops_setup(void)
 #endif
 }
 
+void __cpuinit kvm_guest_cpu_init(void)
+{
+	if (!kvm_para_available())
+		return;
+
+	if (kvm_para_has_feature(KVM_FEATURE_ASYNC_PF) && kvmapf) {
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
+static void kvm_guest_cpu_notify(void *dummy)
+{
+	if (!dummy)
+		kvm_guest_cpu_init();
+	else
+		kvm_pv_disable_apf(NULL);
+}
+
+static int __cpuinit kvm_cpu_notify(struct notifier_block *self,
+				    unsigned long action, void *hcpu)
+{
+	int cpu = (unsigned long)hcpu;
+	switch (action) {
+	case CPU_ONLINE:
+	case CPU_DOWN_FAILED:
+	case CPU_ONLINE_FROZEN:
+		smp_call_function_single(cpu, kvm_guest_cpu_notify, NULL, 0);
+		break;
+	case CPU_DOWN_PREPARE:
+	case CPU_DOWN_PREPARE_FROZEN:
+		smp_call_function_single(cpu, kvm_guest_cpu_notify, (void*)1, 1);
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
@@ -245,7 +333,11 @@ void __init kvm_guest_init(void)
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
