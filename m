Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id A72BA6B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:06:20 -0400 (EDT)
Received: by mail-ie0-f181.google.com with SMTP id a14so522961iee.26
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 04:06:20 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 23 Aug 2013 19:06:20 +0800
Message-ID: <CAL1ERfNdZX_j2Qg-fb9g1U4Wjv8qZwKgUX=JGGjOa6q0zOWEEA@mail.gmail.com>
Subject: [PATCH 2/4] zswap: use GFP_NOIO instead of GFP_KERNEL
From: Weijie Yang <weijie.yang.kh@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Bob Liu <bob.liu@oracle.com>, sjenning@linux.vnet.ibm.com
Cc: weijie.yang@samsung.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

avoid zswap store and reclaim functions called recursively.

---
 mm/zswap.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index 1cf1c07..5f97f4f 100644
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

@@ -628,7 +628,7 @@ static int zswap_frontswap_store(unsigned type,
pgoff_t offset,
 	}

 	/* allocate entry */
-	entry = zswap_entry_cache_alloc(GFP_KERNEL);
+	entry = zswap_entry_cache_alloc(GFP_NOIO);
 	if (!entry) {
 		zswap_reject_kmemcache_fail++;
 		ret = -ENOMEM;
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
