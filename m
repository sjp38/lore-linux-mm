Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3306B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 05:55:01 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id t5so298137760qkc.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 02:55:01 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id k88si2993257uak.82.2016.04.17.02.54.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 02:55:00 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [added to the 4.1 stable tree] sched: Fix crash in sched_init_numa()
Date: Sun, 17 Apr 2016 05:50:09 -0400
Message-Id: <1460886804-19372-10-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1460886804-19372-1-git-send-email-sasha.levin@oracle.com>
References: <1460886804-19372-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: stable@vger.kernel.org, stable-commits@vger.kernel.org
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, peterz@infradead.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, Ingo Molnar <mingo@kernel.org>, Sasha Levin <sasha.levin@oracle.com>

From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

This patch has been added to the 4.1 stable tree. If you have any
objections, please let us know.

===============

[ Upstream commit 9c03ee147193645be4c186d3688232fa438c57c7 ]

The following PowerPC commit:

  c118baf80256 ("arch/powerpc/mm/numa.c: do not allocate bootmem memory for non existing nodes")

avoids allocating bootmem memory for non existent nodes.

But when DEBUG_PER_CPU_MAPS=y is enabled, my powerNV system failed to boot
because in sched_init_numa(), cpumask_or() operation was done on
unallocated nodes.

Fix that by making cpumask_or() operation only on existing nodes.

[ Tested with and w/o DEBUG_PER_CPU_MAPS=y on x86 and PowerPC. ]

Reported-by: Jan Stancek <jstancek@redhat.com>
Tested-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Cc: <gkurz@linux.vnet.ibm.com>
Cc: <grant.likely@linaro.org>
Cc: <nikunj@linux.vnet.ibm.com>
Cc: <vdavydov@parallels.com>
Cc: <linuxppc-dev@lists.ozlabs.org>
Cc: <linux-mm@kvack.org>
Cc: <peterz@infradead.org>
Cc: <benh@kernel.crashing.org>
Cc: <paulus@samba.org>
Cc: <mpe@ellerman.id.au>
Cc: <anton@samba.org>
Link: http://lkml.kernel.org/r/1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 kernel/sched/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 4d870eb..3b0f4c0 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6480,7 +6480,7 @@ static void sched_init_numa(void)
 
 			sched_domains_numa_masks[i][j] = mask;
 
-			for (k = 0; k < nr_node_ids; k++) {
+			for_each_node(k) {
 				if (node_distance(j, k) > sched_domains_numa_distance[i])
 					continue;
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
