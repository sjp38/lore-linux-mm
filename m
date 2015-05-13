Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 294F36B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 04:10:58 -0400 (EDT)
Received: by widdi4 with SMTP id di4so187126973wid.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 01:10:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kz7si31531083wjb.155.2015.05.13.01.10.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 May 2015 01:10:56 -0700 (PDT)
Date: Wed, 13 May 2015 09:10:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm, numa: Really disable NUMA balancing by default on single
 node machines
Message-ID: <20150513081053.GQ2462@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

NUMA balancing is meant to be disabled by default on UMA machines but
the check is using nr_node_ids (highest node) instead of num_online_nodes
(online nodes). The consequences are that a UMA machine with a node ID of 1
or higher will enable NUMA balancing. This will incur useless overhead due
to minor faults with the impact depending on the workload. These are the
impact on the stats when running a kernel build on a single node machine
whose node ID happened to be 1;

			       vanilla     patched
NUMA base PTE updates          5113158           0
NUMA huge PMD updates              643           0
NUMA page range updates        5442374           0
NUMA hint faults               2109622           0
NUMA hint local faults         2109622           0
NUMA hint local percent            100         100
NUMA pages migrated                  0           0

Signed-off-by: Mel Gorman <mgorman@suse.de>
Cc: <stable@vger.kernel.org> #v3.8+
---
 mm/mempolicy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ede26291d4aa..747743237d9f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2518,7 +2518,7 @@ static void __init check_numabalancing_enable(void)
 	if (numabalancing_override)
 		set_numabalancing_state(numabalancing_override == 1);
 
-	if (nr_node_ids > 1 && !numabalancing_override) {
+	if (num_online_nodes() > 1 && !numabalancing_override) {
 		pr_info("%s automatic NUMA balancing. "
 			"Configure with numa_balancing= or the "
 			"kernel.numa_balancing sysctl",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
