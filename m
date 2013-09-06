Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CD33C6B0033
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:17:21 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MSO00GCVUOE9PP0@mailout1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Sep 2013 14:17:19 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
Subject: [PATCH v2 4/4] mm/zswap: use GFP_NOIO instead of GFP_KERNEL
Date: Fri, 06 Sep 2013 13:16:45 +0800
Message-id: <000601ceaac0$5be39f90$13aadeb0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjenning@linux.vnet.ibm.com
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

To avoid zswap store and reclaim functions called recursively,
use GFP_NOIO instead of GFP_KERNEL

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/zswap.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index cc40e6a..3d05ed8 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -427,7 +427,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page(GFP_KERNEL);
+			new_page = alloc_page(GFP_NOIO);
 			if (!new_page)
 				break; /* Out of memory */
 		}
@@ -435,7 +435,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		/*
 		 * call radix_tree_preload() while we can wait.
 		 */
-		err = radix_tree_preload(GFP_KERNEL);
+		err = radix_tree_preload(GFP_NOIO);
 		if (err)
 			break;
 
@@ -636,7 +636,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	}
 
 	/* allocate entry */
-	entry = zswap_entry_cache_alloc(GFP_KERNEL);
+	entry = zswap_entry_cache_alloc(GFP_NOIO);
 	if (!entry) {
 		zswap_reject_kmemcache_fail++;
 		ret = -ENOMEM;
-- 
1.7.10.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
