Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B7EF86B0085
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:57:21 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D949782C4B2
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:15:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pKkQKoGCffnP for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 21:15:23 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id EB7AD82C4DD
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:15:12 -0400 (EDT)
Message-Id: <20090617203446.475295571@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:56 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 19/19] this_cpu ops: Remove pageset_notifier
Content-Disposition: inline; filename=this_cpu_remove_pageset_notifier
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Remove the pageset notifier since it only marks that a processor
exists on a specific node. Move that code into the vmstat notifier.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/page_alloc.c |   27 ---------------------------
 mm/vmstat.c     |    1 +
 2 files changed, 1 insertion(+), 27 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2009-06-17 15:02:35.000000000 -0500
+++ linux-2.6/mm/vmstat.c	2009-06-17 15:10:43.000000000 -0500
@@ -903,6 +903,7 @@ static int __cpuinit vmstat_cpuup_callba
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
 		start_cpu_timer(cpu);
+		node_set_state(cpu_to_node(cpu), N_CPU);
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2009-06-17 15:10:52.000000000 -0500
+++ linux-2.6/mm/page_alloc.c	2009-06-17 15:12:37.000000000 -0500
@@ -2982,26 +2982,6 @@ static void setup_pagelist_highmark(stru
  */
 static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
 
-static int __cpuinit pageset_cpuup_callback(struct notifier_block *nfb,
-		unsigned long action,
-		void *hcpu)
-{
-	int cpu = (long)hcpu;
-
-	switch (action) {
-	case CPU_UP_PREPARE:
-	case CPU_UP_PREPARE_FROZEN:
-		node_set_state(cpu_to_node(cpu), N_CPU);
-		break;
-	default:
-		break;
-	}
-	return NOTIFY_OK;
-}
-
-static struct notifier_block __cpuinitdata pageset_notifier =
-	{ &pageset_cpuup_callback, NULL, 0 };
-
 /*
  * Allocate per cpu pagesets and initialize them.
  * Before this call only boot pagesets were available.
@@ -3026,13 +3006,6 @@ void __init setup_per_cpu_pageset(void)
 						percpu_pagelist_fraction));
 		}
 	}
-
-	/*
-	 * The boot cpu is always the first active.
-	 * The boot node has a processor
-	 */
-	node_set_state(cpu_to_node(smp_processor_id()), N_CPU);
-	register_cpu_notifier(&pageset_notifier);
 }
 
 static noinline __init_refok

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
