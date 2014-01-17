Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f53.google.com (mail-qe0-f53.google.com [209.85.128.53])
	by kanga.kvack.org (Postfix) with ESMTP id EE3686B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 16:14:06 -0500 (EST)
Received: by mail-qe0-f53.google.com with SMTP id t7so4445845qeb.26
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 13:14:06 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id t32si3266781qgd.102.2014.01.17.13.14.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 17 Jan 2014 13:14:05 -0800 (PST)
From: riel@redhat.com
Subject: [PATCH v2 0/7] pseudo-interleaving for automatic NUMA balancing
Date: Fri, 17 Jan 2014 16:12:02 -0500
Message-Id: <1389993129-28180-1-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, chegu_vinod@hp.com, peterz@infradead.org, mgorman@suse.de, mingo@redhat.com

The current automatic NUMA balancing code base has issues with
workloads that do not fit on one NUMA load. Page migration is
slowed down, but memory distribution between the nodes where
the workload runs is essentially random, often resulting in a
suboptimal amount of memory bandwidth being available to the
workload.

In order to maximize performance of workloads that do not fit in one NUMA
node, we want to satisfy the following criteria:
1) keep private memory local to each thread
2) avoid excessive NUMA migration of pages
3) distribute shared memory across the active nodes, to
   maximize memory bandwidth available to the workload

This patch series identifies the NUMA nodes on which the workload
is actively running, and balances (somewhat lazily) the memory
between those nodes, satisfying the criteria above.

As usual, the series has had some performance testing, but it
could always benefit from more testing, on other systems.

Changes since v1:
 - fix divide by zero found by Chegu Vinod
 - improve comment, as suggested by Peter Zijlstra
 - do stats calculations in task_numa_placement in local variables


Some performance numbers, with two 40-warehouse specjbb instances
on an 8 node system with 10 CPU cores per node, using a pre-cleanup
version of these patches, courtesy of Chegu Vinod:

numactl manual pinning
spec1.txt:           throughput =     755900.20 SPECjbb2005 bops
spec2.txt:           throughput =     754914.40 SPECjbb2005 bops

NO-pinning results (Automatic NUMA balancing, with patches)
spec1.txt:           throughput =     706439.84 SPECjbb2005 bops
spec2.txt:           throughput =     729347.75 SPECjbb2005 bops

NO-pinning results (Automatic NUMA balancing, without patches)
spec1.txt:           throughput =     667988.47 SPECjbb2005 bops
spec2.txt:           throughput =     638220.45 SPECjbb2005 bops

No Automatic NUMA and NO-pinning results
spec1.txt:           throughput =     544120.97 SPECjbb2005 bops
spec2.txt:           throughput =     453553.41 SPECjbb2005 bops


My own performance numbers are not as relevant, since I have been
running with a more hostile workload on purpose, and I have run
into a scheduler issue that caused the workload to run on only
two of the four NUMA nodes on my test system...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
