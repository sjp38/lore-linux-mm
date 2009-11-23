Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2CEEF6B0044
	for <linux-mm@kvack.org>; Mon, 23 Nov 2009 09:09:10 -0500 (EST)
From: Gleb Natapov <gleb@redhat.com>
Subject: [PATCH v2 01/12] Move kvm_smp_prepare_boot_cpu() from kvmclock.c to kvm.c.
Date: Mon, 23 Nov 2009 16:05:56 +0200
Message-Id: <1258985167-29178-2-git-send-email-gleb@redhat.com>
In-Reply-To: <1258985167-29178-1-git-send-email-gleb@redhat.com>
References: <1258985167-29178-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Async PF also needs to hook into smp_prepare_boot_cpu so move the hook
into generic code.

Signed-off-by: Gleb Natapov <gleb@redhat.com>
---
 arch/x86/include/asm/kvm_para.h |    1 +
 arch/x86/kernel/kvm.c           |   11 +++++++++++
 arch/x86/kernel/kvmclock.c      |   13 +------------
 3 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/arch/x86/include/asm/kvm_para.h b/arch/x86/include/asm/kvm_para.h
index c584076..5f580f2 100644
--- a/arch/x86/include/asm/kvm_para.h
+++ b/arch/x86/include/asm/kvm_para.h
@@ -51,6 +51,7 @@ struct kvm_mmu_op_release_pt {
 #include <asm/processor.h>
 
 extern void kvmclock_init(void);
+extern int kvm_register_clock(char *txt);
 
 
 /* This instruction is vmcall.  On non-VT architectures, it will generate a
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 63b0ec8..e6db179 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -231,10 +231,21 @@ static void __init paravirt_ops_setup(void)
 #endif
 }
 
+#ifdef CONFIG_SMP
+static void __init kvm_smp_prepare_boot_cpu(void)
+{
+	WARN_ON(kvm_register_clock("primary cpu clock"));
+	native_smp_prepare_boot_cpu();
+}
+#endif
+
 void __init kvm_guest_init(void)
 {
 	if (!kvm_para_available())
 		return;
 
 	paravirt_ops_setup();
+#ifdef CONFIG_SMP
+	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
+#endif
 }
diff --git a/arch/x86/kernel/kvmclock.c b/arch/x86/kernel/kvmclock.c
index feaeb0d..6ab9622 100644
--- a/arch/x86/kernel/kvmclock.c
+++ b/arch/x86/kernel/kvmclock.c
@@ -122,7 +122,7 @@ static struct clocksource kvm_clock = {
 	.flags = CLOCK_SOURCE_IS_CONTINUOUS,
 };
 
-static int kvm_register_clock(char *txt)
+int kvm_register_clock(char *txt)
 {
 	int cpu = smp_processor_id();
 	int low, high;
@@ -146,14 +146,6 @@ static void __cpuinit kvm_setup_secondary_clock(void)
 }
 #endif
 
-#ifdef CONFIG_SMP
-static void __init kvm_smp_prepare_boot_cpu(void)
-{
-	WARN_ON(kvm_register_clock("primary cpu clock"));
-	native_smp_prepare_boot_cpu();
-}
-#endif
-
 /*
  * After the clock is registered, the host will keep writing to the
  * registered memory location. If the guest happens to shutdown, this memory
@@ -192,9 +184,6 @@ void __init kvmclock_init(void)
 		x86_cpuinit.setup_percpu_clockev =
 			kvm_setup_secondary_clock;
 #endif
-#ifdef CONFIG_SMP
-		smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
-#endif
 		machine_ops.shutdown  = kvm_shutdown;
 #ifdef CONFIG_KEXEC
 		machine_ops.crash_shutdown  = kvm_crash_shutdown;
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
