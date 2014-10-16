Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 34C036B0071
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 23:36:21 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so2426494pdb.39
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 20:36:20 -0700 (PDT)
Received: from manager.mioffice.cn ([42.62.48.242])
        by mx.google.com with ESMTP id rf9si17524319pbc.221.2014.10.15.20.36.19
        for <linux-mm@kvack.org>;
        Wed, 15 Oct 2014 20:36:20 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH 4/4] (CMA_AGGRESSIVE) Update page alloc function
Date: Thu, 16 Oct 2014 11:35:51 +0800
Message-ID: <1413430551-22392-5-git-send-email-zhuhui@xiaomi.com>
In-Reply-To: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
References: <1413430551-22392-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@rjwysocki.net, len.brown@intel.com, pavel@ucw.cz, m.szyprowski@samsung.com, akpm@linux-foundation.org, mina86@mina86.com, aneesh.kumar@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@suse.de, minchan@kernel.org, nasa4836@gmail.com, ddstreet@ieee.org, hughd@google.com, mingo@kernel.org, rientjes@google.com, peterz@infradead.org, keescook@chromium.org, atomlin@redhat.com, raistlin@linux.it, axboe@fb.com, paulmck@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, k.khlebnikov@samsung.com, msalter@redhat.com, deller@gmx.de, tangchen@cn.fujitsu.com, ben@decadent.org.uk, akinobu.mita@gmail.com, lauraa@codeaurora.org, vbabka@suse.cz, sasha.levin@oracle.com, vdavydov@parallels.com, suleiman@google.com
Cc: linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org, Hui Zhu <zhuhui@xiaomi.com>

If page alloc function __rmqueue try to get pages from MIGRATE_MOVABLE and
conditions (cma_alloc_counter, cma_aggressive_free_min, cma_alloc_counter)
allow, MIGRATE_CMA will be allocated as MIGRATE_MOVABLE first.

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/page_alloc.c | 42 +++++++++++++++++++++++++++++++-----------
 1 file changed, 31 insertions(+), 11 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 736d8e1..87bc326 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -65,6 +65,10 @@
 #include <asm/div64.h>
 #include "internal.h"
 
+#ifdef CONFIG_CMA_AGGRESSIVE
+#include <linux/cma.h>
+#endif
+
 /* prevent >1 _updater_ of zone percpu pageset ->high and ->batch fields */
 static DEFINE_MUTEX(pcp_batch_high_lock);
 #define MIN_PERCPU_PAGELIST_FRACTION	(8)
@@ -1189,20 +1193,36 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
-retry_reserve:
+#ifdef CONFIG_CMA_AGGRESSIVE
+	if (cma_aggressive_switch
+	    && migratetype == MIGRATE_MOVABLE
+	    && atomic_read(&cma_alloc_counter) == 0
+	    && global_page_state(NR_FREE_CMA_PAGES) > cma_aggressive_free_min
+							+ (1 << order))
+		migratetype = MIGRATE_CMA;
+#endif
+retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
-	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
-		page = __rmqueue_fallback(zone, order, migratetype);
+	if (unlikely(!page)) {
+#ifdef CONFIG_CMA_AGGRESSIVE
+		if (migratetype == MIGRATE_CMA) {
+			migratetype = MIGRATE_MOVABLE;
+			goto retry;
+		}
+#endif
+		if (migratetype != MIGRATE_RESERVE) {
+			page = __rmqueue_fallback(zone, order, migratetype);
 
-		/*
-		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
-		 * is used because __rmqueue_smallest is an inline function
-		 * and we want just one call site
-		 */
-		if (!page) {
-			migratetype = MIGRATE_RESERVE;
-			goto retry_reserve;
+			/*
+			* Use MIGRATE_RESERVE rather than fail an allocation.
+			* goto is used because __rmqueue_smallest is an inline
+			* function and we want just one call site
+			*/
+			if (!page) {
+				migratetype = MIGRATE_RESERVE;
+				goto retry;
+			}
 		}
 	}
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
