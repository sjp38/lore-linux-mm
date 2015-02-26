Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id F0A8D6B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 01:14:57 -0500 (EST)
Received: by lamq1 with SMTP id q1so8858346lam.5
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 22:14:57 -0800 (PST)
Received: from mail-lb0-x234.google.com (mail-lb0-x234.google.com. [2a00:1450:4010:c04::234])
        by mx.google.com with ESMTPS id nx9si30077402lbb.71.2015.02.25.22.14.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 22:14:56 -0800 (PST)
Received: by lbjb6 with SMTP id b6so8682311lbj.12
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 22:14:55 -0800 (PST)
Subject: [PATCH] mm: completely remove dumping per-cpu lists from show_mem()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Thu, 26 Feb 2015 09:14:54 +0300
Message-ID: <20150226061454.24653.49733.stgit@zurg>
In-Reply-To: <20150225134426.d907ecb7130d12dc8ad97c90@linux-foundation.org>
References: <20150225134426.d907ecb7130d12dc8ad97c90@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@suse.cz>

It seems nobody needs this.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 include/linux/mm.h |    1 -
 mm/page_alloc.c    |   22 ++--------------------
 2 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9c21b42..6571dd78 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1126,7 +1126,6 @@ extern void pagefault_out_of_memory(void);
  * various contexts.
  */
 #define SHOW_MEM_FILTER_NODES		(0x0001u)	/* disallowed nodes */
-#define SHOW_MEM_PERCPU_LISTS		(0x0002u)	/* per-zone per-cpu */
 
 extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a120bce..8ddcb0e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3254,7 +3254,6 @@ static void show_migration_types(unsigned char type)
  * Bits in @filter:
  * SHOW_MEM_FILTER_NODES: suppress nodes that are not allowed by current's
  *   cpuset.
- * SHOW_MEM_PERCPU_LISTS: display full per-node per-cpu pcp lists
  */
 void show_free_areas(unsigned int filter)
 {
@@ -3266,25 +3265,8 @@ void show_free_areas(unsigned int filter)
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
 
-		if (filter & SHOW_MEM_PERCPU_LISTS) {
-			show_node(zone);
-			printk("%s per-cpu:\n", zone->name);
-		}
-
-		for_each_online_cpu(cpu) {
-			struct per_cpu_pageset *pageset;
-
-			pageset = per_cpu_ptr(zone->pageset, cpu);
-
-			free_pcp += pageset->pcp.count;
-
-			if (!(filter & SHOW_MEM_PERCPU_LISTS))
-				continue;
-
-			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp.high,
-			       pageset->pcp.batch, pageset->pcp.count);
-		}
+		for_each_online_cpu(cpu)
+			free_pcp += per_cpu_ptr(zone->pageset, cpu)->pcp.count;
 	}
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
