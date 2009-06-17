Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id DAA056B006A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 20:57:12 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7099F82C4FC
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:15:18 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id cRkv59Cj6zaO for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 21:15:12 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5A59782C4AD
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 21:15:12 -0400 (EDT)
Message-Id: <20090617203443.764664169@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:42 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 05/19] use this_cpu ops for network statistics
Content-Disposition: inline; filename=this_cpu_net
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au
List-ID: <linux-mm.kvack.org>

CC: David Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/net/neighbour.h              |    7 +------
 include/net/netfilter/nf_conntrack.h |    9 ++-------
 2 files changed, 3 insertions(+), 13 deletions(-)

Index: linux-2.6/include/net/neighbour.h
===================================================================
--- linux-2.6.orig/include/net/neighbour.h	2009-06-15 17:24:59.000000000 -0500
+++ linux-2.6/include/net/neighbour.h	2009-06-15 17:53:35.000000000 -0500
@@ -89,12 +89,7 @@ struct neigh_statistics
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
--- linux-2.6.orig/include/net/netfilter/nf_conntrack.h	2009-06-15 17:24:59.000000000 -0500
+++ linux-2.6/include/net/netfilter/nf_conntrack.h	2009-06-15 17:53:35.000000000 -0500
@@ -294,14 +294,9 @@ extern int nf_conntrack_set_hashsize(con
 extern unsigned int nf_conntrack_htable_size;
 extern unsigned int nf_conntrack_max;
 
-#define NF_CT_STAT_INC(net, count)	\
-	(per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++)
+#define NF_CT_STAT_INC(net, count) __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count)		\
-do {							\
-	local_bh_disable();				\
-	per_cpu_ptr((net)->ct.stat, raw_smp_processor_id())->count++;	\
-	local_bh_enable();				\
-} while (0)
+	this_cpu_inc((net)->ct.stat->count)
 
 #define MODULE_ALIAS_NFCT_HELPER(helper) \
         MODULE_ALIAS("nfct-helper-" helper)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
