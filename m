Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 290D86B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:34:55 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w11so51835439wrc.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:34:55 -0700 (PDT)
Received: from mail-wr0-x241.google.com (mail-wr0-x241.google.com. [2a00:1450:400c:c0c::241])
        by mx.google.com with ESMTPS id e21si4212942wrc.144.2017.03.28.03.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 03:34:53 -0700 (PDT)
Received: by mail-wr0-x241.google.com with SMTP id w43so18481478wrb.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:34:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328101403.34a82fbf@redhat.com>
References: <20170328101403.34a82fbf@redhat.com>
From: Wanpeng Li <kernellwp@gmail.com>
Date: Tue, 28 Mar 2017 18:34:52 +0800
Message-ID: <CANRm+Cwb3uAiZdufqDsyzQ1GZYh3nUr2uTyg1Hb2oVoxJZKMvg@mail.gmail.com>
Subject: Re: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>

2017-03-28 16:14 GMT+08:00 Jesper Dangaard Brouer <brouer@redhat.com>:
>
> (While evaluating some changes to the page allocator) I ran into an
> issue with ksoftirqd getting too much CPU sched time.
>
> I bisected the problem to
>  a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqtime account")
>
>  a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
>  commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
>  Author: Frederic Weisbecker <fweisbec@gmail.com>
>  Date:   Tue Jan 31 04:09:32 2017 +0100
>
>     sched/cputime: Increment kcpustat directly on irqtime account
>
>     The irqtime is accounted is nsecs and stored in
>     cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once the
>     accumulated amount reaches a new jiffy, this one gets accounted to the
>     kcpustat.
>
>     This was necessary when kcpustat was stored in cputime_t, which could at
>     worst have jiffies granularity. But now kcpustat is stored in nsecs
>     so this whole discretization game with temporary irqtime storage has
>     become unnecessary.
>
>     We can now directly account the irqtime to the kcpustat.
>
>     Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
>     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>     Cc: Fenghua Yu <fenghua.yu@intel.com>
>     Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>     Cc: Linus Torvalds <torvalds@linux-foundation.org>
>     Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>     Cc: Michael Ellerman <mpe@ellerman.id.au>
>     Cc: Paul Mackerras <paulus@samba.org>
>     Cc: Peter Zijlstra <peterz@infradead.org>
>     Cc: Rik van Riel <riel@redhat.com>
>     Cc: Stanislaw Gruszka <sgruszka@redhat.com>
>     Cc: Thomas Gleixner <tglx@linutronix.de>
>     Cc: Tony Luck <tony.luck@intel.com>
>     Cc: Wanpeng Li <wanpeng.li@hotmail.com>
>     Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-email-fweisbec@gmail.com
>     Signed-off-by: Ingo Molnar <mingo@kernel.org>
>
> The reproducer is running a userspace udp_sink[1] program, and taskset
> pinning the process to the same CPU as softirq RX is running on, and
> starting a UDP flood with pktgen (tool part of kernel tree:
> samples/pktgen/pktgen_sample03_burst_single_flow.sh).
>
> [1] udp_sink
>  https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c
>
> The expected results (after commit 4cd13c21b207 ("softirq: Let
> ksoftirqd do its job")) is that the scheduler split the CPU time 50/50
> between udp_sink and ksoftirqd.
>
> After this commit, the udp_sink program does not get any sched CPU
> time, and no packets are delivered to userspace.  (All packets are
> dropped by softirq due to a full socket queue, nstat UdpRcvbufErrors).
>
> A related symptom is that ksoftirqd no longer get accounted in top.
>
> $ grep CONFIG_IRQ_TIME_ACCOUNTING .config
> CONFIG_IRQ_TIME_ACCOUNTING=y
>
> Full .config uploaded here[2]:
>  [2] http://people.netfilter.org/hawk/kconfig/config02-bisect-softirq-a499a5a14dbd

void irqtime_account_irq(struct task_struct *curr)
{
    struct irqtime *irqtime = this_cpu_ptr(&cpu_irqtime);
    u64 *cpustat = kcpustat_this_cpu->cpustat;
    s64 delta;
    int cpu;

    if (!sched_clock_irqtime)
        return;

    cpu = smp_processor_id();
    delta = sched_clock_cpu(cpu) - irqtime->irq_start_time;

sched_clock_cpu(cpu) should be converted from cputime to ns. However,
cputime_to_nsecs() API is removed by
https://lkml.org/lkml/2017/1/22/230 for generic usage, so could you
try the below patch just for testing?

diff --git a/include/linux/sched/cputime.h b/include/linux/sched/cputime.h
index 4c5b973..166efba 100644
--- a/include/linux/sched/cputime.h
+++ b/include/linux/sched/cputime.h
@@ -7,14 +7,14 @@
  * cputime accounting APIs:
  */

-#ifdef CONFIG_VIRT_CPU_ACCOUNTING_NATIVE
-#include <asm/cputime.h>
+#define cputime_div(__ct, divisor) div_u64((__force u64)__ct, divisor)
+#define cputime_to_usecs(__ct) \
+    cputime_div(__ct, NSEC_PER_USEC)

 #ifndef cputime_to_nsecs
 # define cputime_to_nsecs(__ct)    \
     (cputime_to_usecs(__ct) * NSEC_PER_USEC)
 #endif
-#endif /* CONFIG_VIRT_CPU_ACCOUNTING_NATIVE */

 #ifdef CONFIG_VIRT_CPU_ACCOUNTING_GEN
 extern void task_cputime(struct task_struct *t,
diff --git a/kernel/sched/cputime.c b/kernel/sched/cputime.c
index f3778e2b..68064d1 100644
--- a/kernel/sched/cputime.c
+++ b/kernel/sched/cputime.c
@@ -49,7 +49,7 @@ void irqtime_account_irq(struct task_struct *curr)
         return;

     cpu = smp_processor_id();
-    delta = sched_clock_cpu(cpu) - irqtime->irq_start_time;
+    delta = cputime_to_nsecs(sched_clock_cpu(cpu)) - irqtime->irq_start_time;
     irqtime->irq_start_time += delta;

     u64_stats_update_begin(&irqtime->sync);

Regards,
Wanpeng Li

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
