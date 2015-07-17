Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 222EF280324
	for <linux-mm@kvack.org>; Fri, 17 Jul 2015 08:22:15 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so80923155wgx.3
        for <linux-mm@kvack.org>; Fri, 17 Jul 2015 05:22:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs3si8937553wib.117.2015.07.17.05.22.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 17 Jul 2015 05:22:13 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/3] mm, meminit: Allow early_pfn_to_nid to be used during runtime
Date: Fri, 17 Jul 2015 13:22:04 +0100
Message-Id: <1437135724-20110-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1437135724-20110-1-git-send-email-mgorman@suse.de>
References: <1437135724-20110-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolai Stange <nicstange@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Alex Ng <alexng@microsoft.com>, Fengguang Wu <fengguang.wu@intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

early_pfn_to_nid historically was inherently not SMP safe but only
used during boot which is inherently single threaded or during hotplug
which is protected by a giant mutex. With deferred memory initialisation
there was a thread-safe version introduced and the early_pfn_to_nid
would trigger a BUG_ON if used unsafely. Memory hotplug hit that check.
This patch makes early_pfn_to_nid introduces a lock to make it safe to
use during hotplug.

Reported-and-tested-by: Alex Ng <alexng@microsoft.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 94e2599830c2..f1e841c67b7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -982,21 +982,26 @@ static void __init __free_pages_boot_core(struct page *page,
 
 #if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) || \
 	defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
-/* Only safe to use early in boot when initialisation is single-threaded */
+
 static struct mminit_pfnnid_cache early_pfnnid_cache __meminitdata;
 
 int __meminit early_pfn_to_nid(unsigned long pfn)
 {
+	static DEFINE_SPINLOCK(early_pfn_lock);
 	int nid;
 
-	/* The system will behave unpredictably otherwise */
-	BUG_ON(system_state != SYSTEM_BOOTING);
+	/* Avoid locking overhead during boot but hotplug must lock */
+	if (system_state != SYSTEM_BOOTING)
+		spin_lock(&early_pfn_lock);
 
 	nid = __early_pfn_to_nid(pfn, &early_pfnnid_cache);
-	if (nid >= 0)
-		return nid;
-	/* just returns 0 */
-	return 0;
+	if (nid < 0)
+		nid = 0;
+
+	if (system_state != SYSTEM_BOOTING)
+		spin_unlock(&early_pfn_lock);
+
+	return nid;
 }
 #endif
 
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
