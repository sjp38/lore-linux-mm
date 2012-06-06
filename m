Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 7D4A46B0074
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 04:15:22 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 7/7] highmem: avoid page_address() in flush_all_zero_pkmaps()
Date: Wed, 6 Jun 2012 16:15:01 +0800
Message-Id: <1338970501-5098-7-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
References: <1338970501-5098-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Tejun Heo <tj@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@linux.intel.com>, Ian Campbell <ian.campbell@citrix.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Lai Jiangshan <laijs@cn.fujitsu.com>

We can get the virtual address from PKMAP_ADDR(i),
we don't need to call page_address() here.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 mm/highmem.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/mm/highmem.c b/mm/highmem.c
index 6f028cb..994fd68 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -103,8 +103,6 @@ static void flush_all_zero_pkmaps(void)
 	flush_cache_kmaps();
 
 	for (i = 0; i < LAST_PKMAP; i++) {
-		struct page *page;
-
 		/*
 		 * zero means we don't have anything to do,
 		 * >1 means that it is still in use. Only
@@ -125,9 +123,7 @@ static void flush_all_zero_pkmaps(void)
 		 * getting the kmap_lock (which is held here).
 		 * So no dangers, even with speculative execution.
 		 */
-		page = pte_page(pkmap_page_table[i]);
-		pte_clear(&init_mm, (unsigned long)page_address(page),
-			  &pkmap_page_table[i]);
+		pte_clear(&init_mm, PKMAP_ADDR(i), &pkmap_page_table[i]);
 
 		clear_high_page_map(i);
 		need_flush = 1;
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
