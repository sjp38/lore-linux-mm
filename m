Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 38AA46B0035
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:45 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so9622934pab.17
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:44 -0700 (PDT)
Subject: [RFC][PATCH 2/8] mm: pcp: consolidate percpu_pagelist_fraction code
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:40 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203540.460D7F91@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

pageset_set_high_and_batch() and percpu_pagelist_fraction_sysctl_handler()
both do the same calculation for establishing pcp->high:

	high = zone->managed_pages / percpu_pagelist_fraction;

pageset_set_high_and_batch() also knows when it should be
using the sysctl-provided value or the boot-time default
behavior.  There's no reason to keep
percpu_pagelist_fraction_sysctl_handler()'s copy separate.
So, consolidate them.

The only bummer here is that pageset_set_high_and_batch() is
currently __meminit.  So, axe that and make it available at
runtime.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/page_alloc.c |   12 ++++--------
 1 file changed, 4 insertions(+), 8 deletions(-)

diff -puN mm/page_alloc.c~consolidate-percpu_pagelist_fraction-code mm/page_alloc.c
--- linux.git/mm/page_alloc.c~consolidate-percpu_pagelist_fraction-code	2013-10-15 09:57:06.143624213 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:06.148624435 -0700
@@ -4183,7 +4183,7 @@ static void pageset_setup_from_high_mark
 	pageset_update(&p->pcp, high, batch);
 }
 
-static void __meminit pageset_set_high_and_batch(struct zone *zone,
+static void pageset_set_high_and_batch(struct zone *zone,
 		struct per_cpu_pageset *pcp)
 {
 	if (percpu_pagelist_fraction)
@@ -5785,14 +5785,10 @@ int percpu_pagelist_fraction_sysctl_hand
 		return ret;
 
 	mutex_lock(&pcp_batch_high_lock);
-	for_each_populated_zone(zone) {
-		unsigned long  high;
-		high = zone->managed_pages / percpu_pagelist_fraction;
+	for_each_populated_zone(zone)
 		for_each_possible_cpu(cpu)
-			pageset_setup_from_high_mark(
-					per_cpu_ptr(zone->pageset, cpu),
-					high);
-	}
+			pageset_set_high_and_batch(zone,
+					per_cpu_ptr(zone->pageset, cpu));
 	mutex_unlock(&pcp_batch_high_lock);
 	return 0;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
