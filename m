Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id D4CEC6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 07:44:28 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id l7so111083776qtd.2
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 04:44:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x124si3669309qke.287.2017.01.11.04.44.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 04:44:28 -0800 (PST)
Date: Wed, 11 Jan 2017 13:44:20 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/4] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
Message-ID: <20170111134420.368efb9e@redhat.com>
In-Reply-To: <20170109163518.6001-4-mgorman@techsingularity.net>
References: <20170109163518.6001-1-mgorman@techsingularity.net>
	<20170109163518.6001-4-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, brouer@redhat.com


On Mon,  9 Jan 2017 16:35:17 +0000 Mel Gorman <mgorman@techsingularity.net> wrote:
 
> The following is results from a page allocator micro-benchmark. Only
> order-0 is interesting as higher orders do not use the per-cpu allocator

Micro-benchmarked with [1] page_bench02:
 modprobe page_bench02 page_order=0 run_flags=$((2#010)) loops=$((10**8)); \
  rmmod page_bench02 ; dmesg --notime | tail -n 4

Compared to baseline: 213 cycles(tsc) 53.417 ns
 - against this     : 184 cycles(tsc) 46.056 ns
 - Saving           : -29 cycles
 - Very close to expected 27 cycles saving [see below [2]]


> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

[1] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/bench
-
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

[2] Expected saving comes from Mel removing a local_irq_{save,restore}
and adding a preempt_{disable,enable} instead.

Micro benchmarking via time_bench_sample[3], we get the cost of these
operations:

 time_bench: Type:for_loop                 Per elem: 0 cycles(tsc) 0.232 ns (step:0)
 time_bench: Type:spin_lock_unlock         Per elem: 33 cycles(tsc) 8.334 ns (step:0)
 time_bench: Type:spin_lock_unlock_irqsave Per elem: 62 cycles(tsc) 15.607 ns (step:0)
 time_bench: Type:irqsave_before_lock      Per elem: 57 cycles(tsc) 14.344 ns (step:0)
 time_bench: Type:spin_lock_unlock_irq     Per elem: 34 cycles(tsc) 8.560 ns (step:0)
 time_bench: Type:simple_irq_disable_before_lock Per elem: 37 cycles(tsc) 9.289 ns (step:0)
 time_bench: Type:local_BH_disable_enable  Per elem: 19 cycles(tsc) 4.920 ns (step:0)
 time_bench: Type:local_IRQ_disable_enable Per elem: 7 cycles(tsc) 1.864 ns (step:0)
 time_bench: Type:local_irq_save_restore   Per elem: 38 cycles(tsc) 9.665 ns (step:0)
 [Mel's patch removes a ^^^^^^^^^^^^^^^^]            ^^^^^^^^^ expected saving - preempt cost
 time_bench: Type:preempt_disable_enable   Per elem: 11 cycles(tsc) 2.794 ns (step:0)
 [adds a preempt  ^^^^^^^^^^^^^^^^^^^^^^]            ^^^^^^^^^ adds this cost
 time_bench: Type:funcion_call_cost        Per elem: 6 cycles(tsc) 1.689 ns (step:0)
 time_bench: Type:func_ptr_call_cost       Per elem: 11 cycles(tsc) 2.767 ns (step:0)
 time_bench: Type:page_alloc_put           Per elem: 211 cycles(tsc) 52.803 ns (step:0)

Thus, expected improvement is: 38-11 = 27 cycles.

[3] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/time_bench_sample.c

CPU used: Intel(R) Core(TM) i7-4790K CPU @ 4.00GHz

Config options of interest:
 CONFIG_NUMA=y
 CONFIG_DEBUG_LIST=n
 CONFIG_VM_EVENT_COUNTERS=y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
