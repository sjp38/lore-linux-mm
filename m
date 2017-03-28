Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CEDDC6B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 04:14:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id w66so49134643qkb.10
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 01:14:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x42si2882163qtb.49.2017.03.28.01.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 01:14:11 -0700 (PDT)
Date: Tue, 28 Mar 2017 10:14:03 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Bisected softirq accounting issue in v4.11-rc1~170^2~28
Message-ID: <20170328101403.34a82fbf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org
Cc: brouer@redhat.com, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>


(While evaluating some changes to the page allocator) I ran into an
issue with ksoftirqd getting too much CPU sched time.

I bisected the problem to
 a499a5a14dbd ("sched/cputime: Increment kcpustat directly on irqtime account")

 a499a5a14dbd1d0315a96fc62a8798059325e9e6 is the first bad commit
 commit a499a5a14dbd1d0315a96fc62a8798059325e9e6
 Author: Frederic Weisbecker <fweisbec@gmail.com>
 Date:   Tue Jan 31 04:09:32 2017 +0100

    sched/cputime: Increment kcpustat directly on irqtime account
    
    The irqtime is accounted is nsecs and stored in
    cpu_irq_time.hardirq_time and cpu_irq_time.softirq_time. Once the
    accumulated amount reaches a new jiffy, this one gets accounted to the
    kcpustat.
    
    This was necessary when kcpustat was stored in cputime_t, which could at
    worst have jiffies granularity. But now kcpustat is stored in nsecs
    so this whole discretization game with temporary irqtime storage has
    become unnecessary.
    
    We can now directly account the irqtime to the kcpustat.
    
    Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
    Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
    Cc: Fenghua Yu <fenghua.yu@intel.com>
    Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
    Cc: Linus Torvalds <torvalds@linux-foundation.org>
    Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
    Cc: Michael Ellerman <mpe@ellerman.id.au>
    Cc: Paul Mackerras <paulus@samba.org>
    Cc: Peter Zijlstra <peterz@infradead.org>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: Stanislaw Gruszka <sgruszka@redhat.com>
    Cc: Thomas Gleixner <tglx@linutronix.de>
    Cc: Tony Luck <tony.luck@intel.com>
    Cc: Wanpeng Li <wanpeng.li@hotmail.com>
    Link: http://lkml.kernel.org/r/1485832191-26889-17-git-send-email-fweisbec@gmail.com
    Signed-off-by: Ingo Molnar <mingo@kernel.org>

The reproducer is running a userspace udp_sink[1] program, and taskset
pinning the process to the same CPU as softirq RX is running on, and
starting a UDP flood with pktgen (tool part of kernel tree:
samples/pktgen/pktgen_sample03_burst_single_flow.sh).

[1] udp_sink
 https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

The expected results (after commit 4cd13c21b207 ("softirq: Let
ksoftirqd do its job")) is that the scheduler split the CPU time 50/50
between udp_sink and ksoftirqd.

After this commit, the udp_sink program does not get any sched CPU
time, and no packets are delivered to userspace.  (All packets are
dropped by softirq due to a full socket queue, nstat UdpRcvbufErrors).

A related symptom is that ksoftirqd no longer get accounted in top.

$ grep CONFIG_IRQ_TIME_ACCOUNTING .config
CONFIG_IRQ_TIME_ACCOUNTING=y

Full .config uploaded here[2]:
 [2] http://people.netfilter.org/hawk/kconfig/config02-bisect-softirq-a499a5a14dbd

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
