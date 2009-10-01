Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F0DD56B006A
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 14:48:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B990082C799
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:36:29 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HFyxAGR-slLk for <linux-mm@kvack.org>;
	Thu,  1 Oct 2009 15:36:25 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1AEAF82C657
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 15:36:25 -0400 (EDT)
Message-Id: <20091001174120.495729538@gentwo.org>
References: <20091001174033.576397715@gentwo.org>
Date: Thu, 01 Oct 2009 13:40:38 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V3 05/19] use this_cpu ops for network statistics
Content-Disposition: inline; filename=this_cpu_net
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>, mingo@elte.hu, rusty@rustcorp.com.au, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Acked-by: Tejun Heo <tj@kernel.org>
CC: David Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/net/neighbour.h              |    7 +------
 include/net/netfilter/nf_conntrack.h |    4 ++--
 2 files changed, 3 insertions(+), 8 deletions(-)

Index: linux-2.6/include/net/neighbour.h
===================================================================
--- linux-2.6.orig/include/net/neighbour.h	2009-09-30 18:32:31.000000000 -0500
+++ linux-2.6/include/net/neighbour.h	2009-09-30 18:32:55.000000000 -0500
@@ -90,12 +90,7 @@ struct neigh_statistics
 	unsigned long unres_discards;	/* number of unresolved drops */
 };
 
-#define NEIGH_CACHE_STAT_INC(tbl, field)				\
-	do {								\
-		preempt_disable();					\
-		(per_cpu_ptr((tbl)->stats, smp_processor_id())->field)++; \
-		preempt_enable();					\
-	} while (0)
+#define NEIGH_CACHE_STAT_INC(tbl, field) this_cpu_inc((tbl)->stats->field)
 
 struct neighbour
 {
Index: linux-2.6/include/net/netfilter/nf_conntrack.h
===================================================================
--- linux-2.6.orig/include/net/netfilter/nf_conntrack.h	2009-09-30 18:32:57.000000000 -0500
+++ linux-2.6/include/net/netfilter/nf_conntrack.h	2009-09-30 18:34:13.000000000 -0500
@@ -295,11 +295,11 @@ extern unsigned int nf_conntrack_htable_
 extern unsigned int nf_conntrack_max;
 
 #define NF_CT_STAT_INC(net, count)	\
-	(per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++)
+	__this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count)		\
 do {							\
 	local_bh_disable();				\
-	per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++;	\
+	__this_cpu_inc((net)->ct.stat->count);		\
 	local_bh_enable();				\
 } while (0)
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
