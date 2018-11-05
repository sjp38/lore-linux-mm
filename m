Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id AA6606B0266
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:56:34 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id r79-v6so1659949itc.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:56:34 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a192-v6si12015868ita.36.2018.11.05.08.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:56:33 -0800 (PST)
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: [RFC PATCH v4 04/13] ktask: run helper threads at MAX_NICE
Date: Mon,  5 Nov 2018 11:55:49 -0500
Message-Id: <20181105165558.11698-5-daniel.m.jordan@oracle.com>
In-Reply-To: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, daniel.m.jordan@oracle.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz

Multithreading may speed long-running kernel tasks, but overly
optimistic parallelization can go wrong if too many helper threads are
started on an already-busy system.  Such helpers can degrade the
performance of other tasks, so they should be sensitive to current CPU
utilization[1].

To achieve this, run helpers at MAX_NICE so that their CPU time is
proportional to idle CPU time.  The main thread that called into ktask
naturally runs at its original priority so that it can make progress on
a heavily loaded system, as it would if ktask were not in the picture.

I tested two different cases in which a non-ktask and a ktask workload
compete for the same CPUs with the goal of showing that normal priority
(i.e. nice=0) ktask helpers cause the non-ktask workload to run more
slowly, whereas MAX_NICE ktask helpers don't.

Testing notes:
  - Each case was run using 8 CPUs on a large two-socket server, with a
    cpumask allowing all test threads to run anywhere within the 8.
  - The non-ktask workload used 7 threads and the ktask workload used 8
    threads to evaluate how much ktask helpers, rather than the main ktask
    thread, disturbed the non-ktask workload.
  - The non-ktask workload was started after the ktask workload and run
    for less time to maximize the chances that the non-ktask workload would
    be disturbed.
  - Runtimes in seconds.

Case 1: Synthetic, worst-case CPU contention

    ktask_test - a tight loop doing integer multiplication to max out on CPU;
                 used for testing only, does not appear in this series
    stress-ng  - cpu stressor ("-c --cpu-method ackerman --cpu-ops 1200");

                 stress-ng
                     alone  (stdev)   max_nice  (stdev)   normal_prio  (stdev)
                  ------------------------------------------------------------
    ktask_test                           96.87  ( 1.09)         90.81  ( 0.29)
    stress-ng        43.04  ( 0.00)      43.58  ( 0.01)         75.86  ( 0.39)

This case shows MAX_NICE helpers make a significant difference compared
to normal priority helpers, with stress-ng taking 76% longer to finish
when competing with normal priority ktask threads than when run by
itself, but only 1% longer when run with MAX_NICE helpers.  The 1% comes
from the small amount of CPU time MAX_NICE threads are given despite
their low priority.

Case 2: Real-world CPU contention

    ktask_vfio - VFIO page pin a 175G kvm guest
    usemem     - faults in 25G of anonymous THP per thread, PAGE_SIZE stride;
                 used to mimic the page clearing that dominates in ktask_vfio
                 so that usemem competes for the same system resources

                    usemem
                     alone  (stdev)   max_nice  (stdev)   normal_prio  (stdev)
                  ------------------------------------------------------------
    ktask_vfio                           14.74  ( 0.04)          9.93  ( 0.09)
        usemem       10.45  ( 0.04)      10.75  ( 0.04)         14.14  ( 0.07)

In the more realistic case 2, the effect is similar although not as
pronounced.  The usemem threads take 35% longer to finish with normal
priority ktask threads than when run alone, but only 3% longer when
MAX_NICE is used.

All ktask users outside of VFIO boil down to page clearing, so I imagine
the results would be similar for them.

[1] lkml.kernel.org/r/20171206143509.GG7515@dhcp22.suse.cz

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 kernel/ktask.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/kernel/ktask.c b/kernel/ktask.c
index b91c62f14dcd..72293a0f50c3 100644
--- a/kernel/ktask.c
+++ b/kernel/ktask.c
@@ -575,6 +575,18 @@ void __init ktask_init(void)
 		goto alloc_fail;
 	}
 
+	/*
+	 * All ktask worker threads have the lowest priority on the system so
+	 * they don't disturb other workloads.
+	 */
+	attrs->nice = MAX_NICE;
+
+	ret = apply_workqueue_attrs(ktask_wq, attrs);
+	if (ret != 0) {
+		pr_warn("disabled (couldn't apply attrs to ktask_wq)");
+		goto apply_fail;
+	}
+
 	attrs->no_numa = true;
 
 	ret = apply_workqueue_attrs(ktask_nonuma_wq, attrs);
-- 
2.19.1
