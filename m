Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 526FE6B004D
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 18:57:23 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 396E682C55B
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:15:28 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id APxgfqh5Fyvh for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 19:15:21 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 84CB482C53F
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:15:17 -0400 (EDT)
Message-Id: <20090617203443.371256548@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:40 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 03/19] Use this_cpu operations for SNMP statistics
Content-Disposition: inline; filename=this_cpu_snmp
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

SNMP statistic macros can be signficantly simplified.
This will also reduce code size if the arch supports these operations
in harware.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/net/snmp.h |   41 ++++++++++++-----------------------------
 1 file changed, 12 insertions(+), 29 deletions(-)

Index: linux-2.6/include/net/snmp.h
===================================================================
--- linux-2.6.orig/include/net/snmp.h	2009-06-15 17:24:31.000000000 -0500
+++ linux-2.6/include/net/snmp.h	2009-06-15 17:53:29.000000000 -0500
@@ -136,35 +136,18 @@ struct linux_xfrm_mib {
 #define SNMP_STAT_BHPTR(name)	(name[0])
 #define SNMP_STAT_USRPTR(name)	(name[1])
 
-#define SNMP_INC_STATS_BH(mib, field) 	\
-	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]++)
-#define SNMP_INC_STATS_USER(mib, field) \
-	do { \
-		per_cpu_ptr(mib[1], get_cpu())->mibs[field]++; \
-		put_cpu(); \
-	} while (0)
-#define SNMP_INC_STATS(mib, field) 	\
-	do { \
-		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field]++; \
-		put_cpu(); \
-	} while (0)
-#define SNMP_DEC_STATS(mib, field) 	\
-	do { \
-		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field]--; \
-		put_cpu(); \
-	} while (0)
-#define SNMP_ADD_STATS(mib, field, addend) 	\
-	do { \
-		per_cpu_ptr(mib[!in_softirq()], get_cpu())->mibs[field] += addend; \
-		put_cpu(); \
-	} while (0)
-#define SNMP_ADD_STATS_BH(mib, field, addend) 	\
-	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
-#define SNMP_ADD_STATS_USER(mib, field, addend) 	\
-	do { \
-		per_cpu_ptr(mib[1], get_cpu())->mibs[field] += addend; \
-		put_cpu(); \
-	} while (0)
+#define SNMP_INC_STATS_BH(mib, field)	\
+			__this_cpu_inc(mib[0]->mibs[field])
+#define SNMP_INC_STATS_USER(mib, field)	\
+			this_cpu_inc(mib[1]->mibs[field])
+#define SNMP_INC_STATS(mib, field)	\
+			this_cpu_inc(mib[!in_softirq()]->mibs[field])
+#define SNMP_DEC_STATS(mib, field)	\
+		 	this_cpu_dec(mib[!in_softirq()]->mibs[field])
+#define SNMP_ADD_STATS_BH(mib, field, addend)	\
+			__this_cpu_add(mib[0]->mibs[field], addend)
+#define SNMP_ADD_STATS_USER(mib, field, addend)	\
+			this_cpu_add(mib[1]->mibs[field], addend)
 #define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
 	do { \
 		__typeof__(mib[0]) ptr = per_cpu_ptr(mib[!in_softirq()], get_cpu());\

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
