Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 04B296B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 12:09:59 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q59so7149399wes.35
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:09:59 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id gf2si29337501wib.61.2014.06.03.09.09.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 09:09:58 -0700 (PDT)
Received: by mail-wi0-f171.google.com with SMTP id cc10so6878095wib.4
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 09:09:58 -0700 (PDT)
Date: Tue, 3 Jun 2014 18:09:55 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] vmstat: on demand updates from differentials V7
Message-ID: <20140603160953.GF23860@localhost.localdomain>
References: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1405291453260.2899@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Gilad Ben-Yossef <gilad@benyossef.com>, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, viresh.kumar@linaro.org, hpa@zytor.com, mingo@kernel.org, peterz@infradead.org, Mike Frysinger <vapier@gentoo.org>, Minchan Kim <minchan.kim@gmail.com>

On Thu, May 29, 2014 at 02:56:15PM -0500, Christoph Lameter wrote:
> 
> V6->V7
> - Remove /sysfs support and avoid the large cpumask definition.
> 
> V5->V6:
> - Shepherd thread as a general worker thread. This means
>   that the general mechanism to control worker thread
>   cpu use by Frederic Weisbecker is necessary to
>   restrict the shepherd thread to the cpus not used
>   for low latency tasks. Hopefully that is ready to be
>   merged soon. No need anymore to have a specific
>   cpu be the housekeeper cpu.
> 
> V4->V5:
> - Shepherd thread on a specific cpu (HOUSEKEEPING_CPU).
> - Incorporate Andrew's feedback
> - Work out the races.
> - Make visible which CPUs have stat updates switched off
>   in /sys/devices/system/cpu/stat_off
> 
> V3->V4:
> - Make the shepherd task not deferrable. It runs on the tick cpu
>   anyways. Deferral could get deltas too far out of sync if
>   vmstat operations are disabled for a certain processor.
> 
> V2->V3:
> - Introduce a new tick_get_housekeeping_cpu() function. Not sure
>   if that is exactly what we want but it is a start. Thomas?
> - Migrate the shepherd task if the output of
>   tick_get_housekeeping_cpu() changes.
> - Fixes recommended by Andrew.
> 
> V1->V2:
> - Optimize the need_update check by using memchr_inv.
> - Clean up.
> 
> vmstat workers are used for folding counter differentials into the
> zone, per node and global counters at certain time intervals.
> They currently run at defined intervals on all processors which will
> cause some holdoff for processors that need minimal intrusion by the
> OS.
> 
> The current vmstat_update mechanism depends on a deferrable timer
> firing every other second by default which registers a work queue item
> that runs on the local CPU, with the result that we have 1 interrupt
> and one additional schedulable task on each CPU every 2 seconds
> If a workload indeed causes VM activity or multiple tasks are running
> on a CPU, then there are probably bigger issues to deal with.
> 
> However, some workloads dedicate a CPU for a single CPU bound task.
> This is done in high performance computing, in high frequency
> financial applications, in networking (Intel DPDK, EZchip NPS) and with
> the advent of systems with more and more CPUs over time, this may become
> more and more common to do since when one has enough CPUs
> one cares less about efficiently sharing a CPU with other tasks and
> more about efficiently monopolizing a CPU per task.
> 
> The difference of having this timer firing and workqueue kernel thread
> scheduled per second can be enormous. An artificial test measuring the
> worst case time to do a simple "i++" in an endless loop on a bare metal
> system and under Linux on an isolated CPU with dynticks and with and
> without this patch, have Linux match the bare metal performance
> (~700 cycles) with this patch and loose by couple of orders of magnitude
> (~200k cycles) without it[*].  The loss occurs for something that just
> calculates statistics. For networking applications, for example, this
> could be the difference between dropping packets or sustaining line rate.
> 
> Statistics are important and useful, but it would be great if there
> would be a way to not cause statistics gathering produce a huge
> performance difference. This patche does just that.
> 
> This patch creates a vmstat shepherd worker that monitors the
> per cpu differentials on all processors. If there are differentials
> on a processor then a vmstat worker local to the processors
> with the differentials is created. That worker will then start
> folding the diffs in regular intervals. Should the worker
> find that there is no work to be done then it will make the shepherd
> worker monitor the differentials again.
> 
> With this patch it is possible then to have periods longer than
> 2 seconds without any OS event on a "cpu" (hardware thread).
> 
> Reviewed-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Signed-off-by: Christoph Lameter <cl@linux.com>

So after the cpumask_var_t conversion I have no other concern except
perhaps that the scan may bring some overhead on workloads that don't
care about isolation. You might want to make it optional. But I let you
check that.

And I can't judge much the -mm internal changes. But other than that, it looks good to me.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
