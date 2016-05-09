Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 407926B0005
	for <linux-mm@kvack.org>; Mon,  9 May 2016 10:54:44 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id d62so419192357iof.1
        for <linux-mm@kvack.org>; Mon, 09 May 2016 07:54:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q13si12881174ioi.7.2016.05.09.07.54.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 May 2016 07:54:42 -0700 (PDT)
Subject: x86_64 Question: Are concurrent IPI requests safe?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
In-Reply-To: <201605061958.HHG48967.JVFtSLFQOFOOMH@I-love.SAKURA.ne.jp>
Message-Id: <201605092354.AHF82313.FtQFOMVOFJLOSH@I-love.SAKURA.ne.jp>
Date: Mon, 9 May 2016 23:54:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> I'm hitting this bug while doing OOM-killer torture test, but I can't tell
> whether this is a mm bug.

I came to think that this is an IPI handling bug (including the possibility
of hardware dependent bug).

If I understand correctly, all "call a function with an argument" requests
in a per CPU call_single_queue are processed by one CALL_FUNCTION_VECTOR IPI
request.

----------------------------------------
void smp_call_function_many(const struct cpumask *mask, smp_call_func_t func, void *info, bool wait) { /* kernel/smp.c */
  for_each_cpu(cpu, cfd->cpumask) {
    llist_add(&csd->llist, &per_cpu(call_single_queue, cpu));
  }
  arch_send_call_function_ipi_mask(cfd->cpumask) { /* arch/x86/include/asm/smp.h */
    smp_ops.send_call_func_ipi(mask) {
      void native_send_call_func_ipi(const struct cpumask *mask) { /* arch/x86/kernel/smp.c */
        apic->send_IPI_mask(mask, CALL_FUNCTION_VECTOR) {
          static void flat_send_IPI_mask(const struct cpumask *cpumask, int vector) { /* arch/x86/kernel/apic/apic_flat_64.c */
            _flat_send_IPI_mask(mask, vector) {
              __default_send_IPI_dest_field(unsigned int mask, int vector, unsigned int dest) { /* arch/x86/kernel/apic/ipi.c */
                __xapic_wait_icr_idle();
                native_apic_mem_write(APIC_ICR2, cfg);
                native_apic_mem_write(APIC_ICR, cfg);
              }
            }
          }
        }
      }
    }
  }
  for_each_cpu(cpu, cfd->cpumask) {
    csd_lock_wait(csd);
  }
}
----------------------------------------

----------------------------------------
__visible void smp_call_function_interrupt(struct pt_regs *regs) { /* arch/x86/kernel/smp.c */
  ipi_entering_ack_irq();
  __smp_call_function_interrupt() {
    generic_smp_call_function_interrupt() {
      void generic_smp_call_function_single_interrupt(void) { /* kernel/smp.c */
        flush_smp_call_function_queue(true) {
          head = this_cpu_ptr(&call_single_queue);
          entry = llist_del_all(head);
          llist_for_each_entry_safe(csd, csd_next, entry, llist) {
             func(info);
             csd_unlock(csd);
          }
        }
      }
    }
  }
  exiting_irq();
}
----------------------------------------

Therefore, concurrent on_each_cpu_mask() calls with wait == true does not matter
as long as llist_del_all() is called from smp_call_function_interrupt()
after llist_add() is called from smp_call_function_many().

Since the SysRq-l shows that multiple CPUs are spinning at csd_lock_wait(),
I checked whether llist_del_all() is called after llist_add() is called
using debug printk() patch shown below.

----------------------------------------
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index e513940..6eb9f79 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -237,6 +237,8 @@ static DECLARE_WORK(sysrq_showallcpus, sysrq_showregs_othercpus);
 
 static void sysrq_handle_showallcpus(int key)
 {
+	extern void show_ipi_sequence(void);
+	show_ipi_sequence();
 	/*
 	 * Fall back to the workqueue based printing if the
 	 * backtrace printing did not succeed or the
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index afdcb7b..3744946 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -56,6 +56,7 @@
 #include <linux/random.h>
 #include <linux/trace_events.h>
 #include <linux/suspend.h>
+extern void show_ipi_sequence(void);
 
 #include "tree.h"
 #include "rcu.h"
@@ -1346,6 +1347,7 @@ static void print_other_cpu_stall(struct rcu_state *rsp, unsigned long gpnum)
 	 * See Documentation/RCU/stallwarn.txt for info on how to debug
 	 * RCU CPU stall warnings.
 	 */
+	show_ipi_sequence();
 	pr_err("INFO: %s detected stalls on CPUs/tasks:",
 	       rsp->name);
 	print_cpu_stall_info_begin();
@@ -1412,6 +1414,7 @@ static void print_cpu_stall(struct rcu_state *rsp)
 	 * See Documentation/RCU/stallwarn.txt for info on how to debug
 	 * RCU CPU stall warnings.
 	 */
+	show_ipi_sequence();
 	pr_err("INFO: %s self-detected stall on CPU", rsp->name);
 	print_cpu_stall_info_begin();
 	print_cpu_stall_info(rsp, smp_processor_id());
diff --git a/kernel/smp.c b/kernel/smp.c
index 7416544..0630eda 100644
--- a/kernel/smp.c
+++ b/kernel/smp.c
@@ -17,6 +17,21 @@
 
 #include "smpboot.h"
 
+static DEFINE_PER_CPU(unsigned int, ipi_call_func_sequence);
+static DEFINE_PER_CPU(unsigned int, ipi_call_func_last_sequence[4]);
+
+void show_ipi_sequence(void)
+{
+	int cpu;
+	for_each_online_cpu(cpu) {
+		printk(KERN_ERR "IPI(%d): last_requested=%u,%u last_responded=%u,%u\n",
+		       cpu, per_cpu_ptr(ipi_call_func_last_sequence, cpu)[0],
+		       per_cpu_ptr(ipi_call_func_last_sequence, cpu)[2],
+		       per_cpu_ptr(ipi_call_func_last_sequence, cpu)[1],
+		       per_cpu_ptr(ipi_call_func_last_sequence, cpu)[3]);
+	}
+}
+
 enum {
 	CSD_FLAG_LOCK		= 0x01,
 	CSD_FLAG_SYNCHRONOUS	= 0x02,
@@ -218,7 +233,9 @@ static void flush_smp_call_function_queue(bool warn_cpu_offline)
 	WARN_ON(!irqs_disabled());
 
 	head = this_cpu_ptr(&call_single_queue);
+	this_cpu_write(ipi_call_func_last_sequence[1], this_cpu_inc_return(ipi_call_func_sequence));
 	entry = llist_del_all(head);
+	this_cpu_write(ipi_call_func_last_sequence[3], this_cpu_inc_return(ipi_call_func_sequence));
 	entry = llist_reverse_order(entry);
 
 	/* There shouldn't be any pending callbacks on an offline CPU. */
@@ -452,7 +469,9 @@ void smp_call_function_many(const struct cpumask *mask,
 			csd->flags |= CSD_FLAG_SYNCHRONOUS;
 		csd->func = func;
 		csd->info = info;
+		this_cpu_write(ipi_call_func_last_sequence[0], this_cpu_inc_return(ipi_call_func_sequence));
 		llist_add(&csd->llist, &per_cpu(call_single_queue, cpu));
+		this_cpu_write(ipi_call_func_last_sequence[2], this_cpu_inc_return(ipi_call_func_sequence));
 	}
 
 	/* Send a message to all CPUs in the map */
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 2932f3e9..deb3243 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4404,6 +4404,8 @@ void show_workqueue_state(void)
 	struct worker_pool *pool;
 	unsigned long flags;
 	int pi;
+	extern void show_ipi_sequence(void);
+	show_ipi_sequence();
 
 	rcu_read_lock_sched();
 
----------------------------------------

This debug printk() patch shows sequence numbers using

  IPI($cpu): last_requested=$v0,$v2 last_responded=$v1,$v3

format and it is expected that $v0 == $v2 - 1 && $v1 == $v3 - 1 && $v2 < $v1
for most of the time.

However, I sometimes get $v2 > $v1 when I hit this bug.
(Complete log is at http://I-love.SAKURA.ne.jp/tmp/serial-20160509.txt.xz .)
----------------------------------------
[  120.469451] IPI(0): last_requested=21491,21492 last_responded=21493,21494
[  120.471484] IPI(1): last_requested=10485,10486 last_responded=10489,10490
[  120.473622] IPI(2): last_requested=11117,11118 last_responded=11111,11112
[  120.476205] IPI(3): last_requested=9663,9664 last_responded=9667,9668
[  133.889461] IPI(0): last_requested=21491,21492 last_responded=21493,21494
[  133.891353] IPI(1): last_requested=10485,10486 last_responded=10489,10490
[  133.893211] IPI(2): last_requested=11117,11118 last_responded=11111,11112
[  133.895008] IPI(3): last_requested=9663,9664 last_responded=9667,9668
[  150.550605] IPI(0): last_requested=21491,21492 last_responded=21493,21494
[  150.552350] IPI(1): last_requested=10485,10486 last_responded=10489,10490
[  150.554114] IPI(2): last_requested=11117,11118 last_responded=11111,11112
[  150.555865] IPI(3): last_requested=9663,9664 last_responded=9667,9668
----------------------------------------
This means that llist_del_all() is NOT called after llist_add() is called on
some CPUs. This suggests that IPI requests are dropped (or cannot be processed)
for some reason. 

Now, I got a question about __default_send_IPI_dest_field().

----------------------------------------
void __default_send_IPI_dest_field(unsigned int mask, int vector, unsigned int dest)
{
        unsigned long cfg;

        /*
         * Wait for idle.
         */
        if (unlikely(vector == NMI_VECTOR))
                safe_apic_wait_icr_idle();
        else
                __xapic_wait_icr_idle();

        /*
         * prepare target chip field
         */
        cfg = __prepare_ICR2(mask);
        native_apic_mem_write(APIC_ICR2, cfg);

        /*
         * program the ICR
         */
        cfg = __prepare_ICR(0, vector, dest);

        /*
         * Send the IPI. The write to APIC_ICR fires this off.
         */
        native_apic_mem_write(APIC_ICR, cfg);
}

static inline void __xapic_wait_icr_idle(void)
{
        while (native_apic_mem_read(APIC_ICR) & APIC_ICR_BUSY)
                cpu_relax();
}

static inline u32 native_apic_mem_read(u32 reg)
{
        return *((volatile u32 *)(APIC_BASE + reg));
}

static inline void native_apic_mem_write(u32 reg, u32 v)
{
        volatile u32 *addr = (volatile u32 *)(APIC_BASE + reg);

        alternative_io("movl %0, %P1", "xchgl %0, %P1", X86_BUG_11AP,
                       ASM_OUTPUT2("=r" (v), "=m" (*addr)),
                       ASM_OUTPUT2("0" (v), "m" (*addr)));
}
----------------------------------------

It seems to me that APIC_BASE APIC_ICR APIC_ICR_BUSY are all constant
regardless of calling cpu. Thus, native_apic_mem_read() and
native_apic_mem_write() are using globally shared constant memory
address and __xapic_wait_icr_idle() is making decision based on
globally shared constant memory address. Am I right?

Then, what happens if 2 CPUs called native_apic_mem_write(APIC_ICR),
one with vector == CALL_FUNCTION_VECTOR and the other with
vector != CALL_FUNCTION_VECTOR ? Since I can't find exclusion control
between CPUs here, native_apic_mem_write() for CALL_FUNCTION_VECTOR
can be ignored by concurrent !CALL_FUNCTION_VECTOR request?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
