Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD976B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:41:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so9966137pfj.2
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:41:36 -0700 (PDT)
Received: from mx0b-00010702.pphosted.com (mx0a-00010702.pphosted.com. [148.163.156.75])
        by mx.google.com with ESMTPS id q1si5617704plk.908.2017.08.07.10.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 10:41:34 -0700 (PDT)
From: Julia Cartwright <julia@ni.com>
Subject: [PATCH RT 1/6] lockdep: Fix per-cpu static objects
Date: Mon, 7 Aug 2017 12:40:57 -0500
Message-ID: <20170807174102.5448-2-julia@ni.com>
In-Reply-To: <20170807174102.5448-1-julia@ni.com>
References: <20170807174102.5448-1-julia@ni.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Carsten Emde <C.Emde@osadl.org>, Sebastian Andrzej
 Siewior <bigeasy@linutronix.de>, John Kacur <jkacur@redhat.com>, Paul
 Gortmaker <paul.gortmaker@windriver.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, wfg@linux.intel.com, kernel
 test robot <fengguang.wu@intel.com>, LKP <lkp@01.org>

4.1.42-rt50-rc1 stable review patch.
If you have any objection to the inclusion of this patch, let me know.

--- 8< --- 8< --- 8< ---
From: Peter Zijlstra <peterz@infradead.org>

Since commit 383776fa7527 ("locking/lockdep: Handle statically initialized
PER_CPU locks properly") we try to collapse per-cpu locks into a single
class by giving them all the same key. For this key we choose the canonical
address of the per-cpu object, which would be the offset into the per-cpu
area.

This has two problems:

 - there is a case where we run !0 lock->key through static_obj() and
   expect this to pass; it doesn't for canonical pointers.

 - 0 is a valid canonical address.

Cure both issues by redefining the canonical address as the address of the
per-cpu variable on the boot CPU.

Since I didn't want to rely on CPU0 being the boot-cpu, or even existing at
all, track the boot CPU in a variable.

Fixes: 383776fa7527 ("locking/lockdep: Handle statically initialized PER_CPU locks properly")
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Tested-by: Borislav Petkov <bp@suse.de>
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org
Cc: wfg@linux.intel.com
Cc: kernel test robot <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>
Link: http://lkml.kernel.org/r/20170320114108.kbvcsuepem45j5cr@hirez.programming.kicks-ass.net
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
(cherry picked from commit c9fe9196079f738c89c3ffcdce3fbe142ac3f3c4)
Signed-off-by: Julia Cartwright <julia@ni.com>
---
 include/linux/smp.h | 12 ++++++++++++
 init/main.c         |  8 ++++++++
 kernel/module.c     |  6 +++++-
 mm/percpu.c         |  5 ++++-
 4 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/include/linux/smp.h b/include/linux/smp.h
index e6ab36aeaaab..cbf6836524dc 100644
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -120,6 +120,13 @@ extern unsigned int setup_max_cpus;
 extern void __init setup_nr_cpu_ids(void);
 extern void __init smp_init(void);
 
+extern int __boot_cpu_id;
+
+static inline int get_boot_cpu_id(void)
+{
+	return __boot_cpu_id;
+}
+
 #else /* !SMP */
 
 static inline void smp_send_stop(void) { }
@@ -158,6 +165,11 @@ static inline void smp_init(void) { up_late_init(); }
 static inline void smp_init(void) { }
 #endif
 
+static inline int get_boot_cpu_id(void)
+{
+	return 0;
+}
+
 #endif /* !SMP */
 
 /*
diff --git a/init/main.c b/init/main.c
index 0486a8e11fc0..e1bae15a2154 100644
--- a/init/main.c
+++ b/init/main.c
@@ -451,6 +451,10 @@ void __init parse_early_param(void)
  *	Activate the first processor.
  */
 
+#ifdef CONFIG_SMP
+int __boot_cpu_id;
+#endif
+
 static void __init boot_cpu_init(void)
 {
 	int cpu = smp_processor_id();
@@ -459,6 +463,10 @@ static void __init boot_cpu_init(void)
 	set_cpu_active(cpu, true);
 	set_cpu_present(cpu, true);
 	set_cpu_possible(cpu, true);
+
+#ifdef CONFIG_SMP
+	__boot_cpu_id = cpu;
+#endif
 }
 
 void __init __weak smp_setup_processor_id(void)
diff --git a/kernel/module.c b/kernel/module.c
index a7ac858fd1a1..982c57b2c2a1 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -542,8 +542,12 @@ bool __is_module_percpu_address(unsigned long addr, unsigned long *can_addr)
 			void *va = (void *)addr;
 
 			if (va >= start && va < start + mod->percpu_size) {
-				if (can_addr)
+				if (can_addr) {
 					*can_addr = (unsigned long) (va - start);
+					*can_addr += (unsigned long)
+						per_cpu_ptr(mod->percpu,
+							    get_boot_cpu_id());
+				}
 				preempt_enable();
 				return true;
 			}
diff --git a/mm/percpu.c b/mm/percpu.c
index 4146b00bfde7..b41c3960d5fb 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1297,8 +1297,11 @@ bool __is_kernel_percpu_address(unsigned long addr, unsigned long *can_addr)
 		void *va = (void *)addr;
 
 		if (va >= start && va < start + static_size) {
-			if (can_addr)
+			if (can_addr) {
 				*can_addr = (unsigned long) (va - start);
+				*can_addr += (unsigned long)
+					per_cpu_ptr(base, get_boot_cpu_id());
+			}
 			return true;
 		}
 	}
-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
