Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 614EB6B0267
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 14:06:05 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id e32so426753329qgf.3
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 11:06:05 -0800 (PST)
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com. [129.33.205.208])
        by mx.google.com with ESMTPS id 205si14598680qhr.99.2016.01.15.11.06.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jan 2016 11:06:04 -0800 (PST)
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Fri, 15 Jan 2016 14:06:04 -0500
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 155A238C803B
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 14:06:01 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22036.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0FJ605J27132136
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 19:06:00 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0FJ5ql3027944
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 14:06:00 -0500
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH] Fix: PowerNV crash with 4.4.0-rc8 at sched_init_numa
Date: Sat, 16 Jan 2016 00:31:23 +0530
Message-Id: <1452884483-11676-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mingo@redhat.com, peterz@infradead.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, anton@samba.org, akpm@linux-foundation.org
Cc: jstancek@redhat.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, raghavendra.kt@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Commit c118baf80256 ("arch/powerpc/mm/numa.c: do not allocate bootmem
memory for non existing nodes") avoided bootmem memory allocation for
non existent nodes.

When DEBUG_PER_CPU_MAPS enabled, powerNV system failed to boot because
in sched_init_numa, cpumask_or operation was done on unallocated nodes.
Fix that by making cpumask_or operation only on existing nodes.

[ Tested with and w/o DEBUG_PER_CPU_MAPS on x86 and powerpc ]

Reported-by: Jan Stancek <jstancek@redhat.com>
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 kernel/sched/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/sched/core.c b/kernel/sched/core.c
index 44253ad..474658b 100644
--- a/kernel/sched/core.c
+++ b/kernel/sched/core.c
@@ -6840,7 +6840,7 @@ static void sched_init_numa(void)
 
 			sched_domains_numa_masks[i][j] = mask;
 
-			for (k = 0; k < nr_node_ids; k++) {
+			for_each_node(k) {
 				if (node_distance(j, k) > sched_domains_numa_distance[i])
 					continue;
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
