Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 54EC06B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:27:58 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1C62D82C545
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:45:06 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Yrdhxs9eHAxP for <linux-mm@kvack.org>;
	Wed, 17 Jun 2009 17:45:01 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6C1F482C4F1
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 17:45:01 -0400 (EDT)
Message-Id: <20090617203442.978537774@gentwo.org>
References: <20090617203337.399182817@gentwo.org>
Date: Wed, 17 Jun 2009 16:33:38 -0400
From: cl@linux-foundation.org
Subject: [this_cpu_xx V2 01/19] Fix handling of pagesets for downed cpus
Content-Disposition: inline; filename=fixupli
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, mingo@elte.hu, rusty@rustcorp.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

If a processor is downed then we need to set the pageset pointer back to the
boot pageset.

Updates of the high water marks should not access pagesets of unpopulated zones
(those pointer go to the boot pagesets which would be no longer functional if
their size would be increased beyond zero).

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2009-06-17 14:06:22.000000000 -0500
+++ linux-2.6/mm/page_alloc.c	2009-06-17 14:07:50.000000000 -0500
@@ -3039,7 +3039,7 @@ static inline void free_zone_pagesets(in
 		/* Free per_cpu_pageset if it is slab allocated */
 		if (pset != &boot_pageset[cpu])
 			kfree(pset);
-		zone_pcp(zone, cpu) = NULL;
+		zone_pcp(zone, cpu) = &boot_pageset[cpu];
 	}
 }
 
@@ -4657,7 +4657,7 @@ int percpu_pagelist_fraction_sysctl_hand
 	ret = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
 	if (!write || (ret == -EINVAL))
 		return ret;
-	for_each_zone(zone) {
+	for_each_populated_zone(zone) {
 		for_each_online_cpu(cpu) {
 			unsigned long  high;
 			high = zone->present_pages / percpu_pagelist_fraction;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
