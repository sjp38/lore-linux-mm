Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFD36B0038
	for <linux-mm@kvack.org>; Mon, 20 Mar 2017 07:41:17 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 76so133040918itj.0
        for <linux-mm@kvack.org>; Mon, 20 Mar 2017 04:41:17 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k14si17473891ioo.44.2017.03.20.04.41.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Mar 2017 04:41:16 -0700 (PDT)
Date: Mon, 20 Mar 2017 12:41:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [locking/lockdep] 383776fa75:  INFO: trying to register
 non-static key.
Message-ID: <20170320114108.kbvcsuepem45j5cr@hirez.programming.kicks-ass.net>
References: <58cad449.RTO+aYLdogbZs5Le%fengguang.wu@intel.com>
 <20170317134109.e7qmjwpryelpbgz2@hirez.programming.kicks-ass.net>
 <20170317144140.cpsdlpairb2falsv@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317144140.cpsdlpairb2falsv@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: kernel test robot <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, LKP <lkp@01.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, wfg@linux.intel.com

On Fri, Mar 17, 2017 at 03:41:41PM +0100, Sebastian Andrzej Siewior wrote:
> On 2017-03-17 14:41:09 [+0100], Peter Zijlstra wrote:
> > On Fri, Mar 17, 2017 at 02:07:05AM +0800, kernel test robot wrote:
> > 
> > >     locking/lockdep: Handle statically initialized PER_CPU locks properly
> > 
> > > [   11.712266] INFO: trying to register non-static key.
> > 
> > Blergh; so the problem is that when we assign can_addr to lock->key, we
> > can, upon using a different subclass, reach static_obj(lock->key), which
> > will fail on the can_addr.
> > 
> > One way to fix this would be to redefine the canonical address as the
> > per-cpu address for a specific cpu; the below hard codes cpu0, but I'm
> > not sure we want to rely on cpu0 being a valid cpu.
> 
> This solves two problems: The one reported by the bot. The other thing,
> that is fixed by the patch, is that the first PER-CPU variable built-in
> will return 0 for can_addr and so will the first variable in every
> module. As far as I understand it, this should be unique and having the
> same value for multiple different variables does not look too good :)
> So adding the offset from CPU0 sounds good.

Right; so how about something liek this?

---
Subject: lockdep: Fix per-cpu static objects
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon Mar 20 12:26:55 CET 2017

Since commit:

  383776fa7527 ("locking/lockdep: Handle statically initialized PER_CPU locks properly")

we try to collapse per-cpu locks into a single class by giving them
all the same key. For this key we choose the canonical address of the
per-cpu object, which would be the offset into the per-cpu area.

This has two problems:

 - there is a case where we run !0 lock->key through static_obj() and
   expect this to pass; it doesn't for canonical pointers.

 - 0 is a valid canonical address.

Cure both issues by redefining the canonical address as the address of
the per-cpu variable on the boot CPU.

Since I didn't want to rely on CPU0 being the boot-cpu, or even
existing at all, track the boot CPU in a variable.

Fixes: 383776fa7527 ("locking/lockdep: Handle statically initialized PER_CPU locks properly")
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
--- a/include/linux/smp.h
+++ b/include/linux/smp.h
@@ -120,6 +120,13 @@ extern unsigned int setup_max_cpus;
 extern void __init setup_nr_cpu_ids(void);
 extern void __init smp_init(void);
 
+extern int __boot_cpu_id;
+
+static inline int boot_cpu_id(void)
+{
+	return __boot_cpu_id;
+}
+
 #else /* !SMP */
 
 static inline void smp_send_stop(void) { }
@@ -158,6 +165,11 @@ static inline void smp_init(void) { up_l
 static inline void smp_init(void) { }
 #endif
 
+static inline int boot_cpu_id(void)
+{
+	return 0;
+}
+
 #endif /* !SMP */
 
 /*
--- a/kernel/cpu.c
+++ b/kernel/cpu.c
@@ -1125,6 +1125,8 @@ core_initcall(cpu_hotplug_pm_sync_init);
 
 #endif /* CONFIG_PM_SLEEP_SMP */
 
+int __boot_cpu_id;
+
 #endif /* CONFIG_SMP */
 
 /* Boot processor state steps */
@@ -1815,6 +1817,10 @@ void __init boot_cpu_init(void)
 	set_cpu_active(cpu, true);
 	set_cpu_present(cpu, true);
 	set_cpu_possible(cpu, true);
+
+#ifdef CONFIG_SMP
+	__boot_cpu_id = cpu;
+#endif
 }
 
 /*
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -682,8 +682,11 @@ bool __is_module_percpu_address(unsigned
 			void *va = (void *)addr;
 
 			if (va >= start && va < start + mod->percpu_size) {
-				if (can_addr)
+				if (can_addr) {
 					*can_addr = (unsigned long) (va - start);
+					*can_addr += (unsigned long)
+						per_cpu_ptr(mod->percpu, boot_cpu_id());
+				}
 				preempt_enable();
 				return true;
 			}
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1296,8 +1296,11 @@ bool __is_kernel_percpu_address(unsigned
 		void *va = (void *)addr;
 
 		if (va >= start && va < start + static_size) {
-			if (can_addr)
+			if (can_addr) {
 				*can_addr = (unsigned long) (va - start);
+				*can_addr += (unsigned long)
+					per_cpu_ptr(base, boot_cpu_id());
+			}
 			return true;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
