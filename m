Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 018106B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 06:06:55 -0400 (EDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOD00GCXO3CTT01@mailout4.samsung.com> for linux-mm@kvack.org;
 Fri, 14 Jun 2013 19:06:54 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH] mm: vmscan: remove redundant querying to shrinker
Date: Fri, 14 Jun 2013 19:07:51 +0900
Message-id: <1371204471-13518-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, riel@redhat.com, kyungmin.park@samsung.com, d.j.shin@samsung.com, sunae.seo@samsung.com, Heesub Shin <heesub.shin@samsung.com>

shrink_slab() queries each slab cache to get the number of
elements in it. In most cases such queries are cheap but,
on some caches. For example, Android low-memory-killer,
which is operates as a slab shrinker, does relatively
long calculation once invoked and it is quite expensive.

This patch removes redundant queries to shrinker function
in the loop of shrink batch.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..11b6695 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -282,9 +282,8 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 					max_pass, delta, total_scan);
 
 		while (total_scan >= batch_size) {
-			int nr_before;
+			int nr_before = max_pass;
 
-			nr_before = do_shrinker_shrink(shrinker, shrink, 0);
 			shrink_ret = do_shrinker_shrink(shrinker, shrink,
 							batch_size);
 			if (shrink_ret == -1)
@@ -293,6 +292,7 @@ unsigned long shrink_slab(struct shrink_control *shrink,
 				ret += nr_before - shrink_ret;
 			count_vm_events(SLABS_SCANNED, batch_size);
 			total_scan -= batch_size;
+			max_pass = shrink_ret;
 
 			cond_resched();
 		}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
