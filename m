Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id 107B66B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 05:14:49 -0500 (EST)
Received: by mail-oa0-f44.google.com with SMTP id h16so1576668oag.3
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 02:14:48 -0800 (PST)
Received: from e8.ny.us.ibm.com (e8.ny.us.ibm.com. [32.97.182.138])
        by mx.google.com with ESMTPS id iz10si55614205obb.0.2014.01.06.02.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 02:14:47 -0800 (PST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Mon, 6 Jan 2014 05:14:46 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D05F86E803C
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 05:14:40 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s06AEidh8257928
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 10:14:44 GMT
Received: from d01av04.pok.ibm.com (localhost [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s06AEisH021778
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 05:14:44 -0500
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [RFC PATCH V3] mm readahead: Fix the readahead fail in case of empty numa node
Date: Mon,  6 Jan 2014 15:51:55 +0530
Message-Id: <1389003715-29733-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Currently, max_sane_readahead returns zero on the cpu with empty numa node,
fix this by checking for potential empty numa node case during calculation.
We also limit the number of readahead pages to 4k.

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
The current patch limits the readahead into 4k pages (16MB was suggested by Linus).
and also handles the case of memoryless cpu issuing readahead failures.
We still do not consider [fm]advise() specific calculations here.
I have dropped the iterating over numa node to calculate free page idea.
I do not have much idea whether there is any impact on big streaming apps..
Comments/suggestions ?

 mm/readahead.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 7cdbb44..be4d205 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -237,14 +237,25 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	return ret;
 }
 
+#define MAX_REMOTE_READAHEAD   4096UL
 /*
  * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
  * sensible upper limit.
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
-		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
+	unsigned long local_free_page;
+	unsigned long sane_nr = min(nr, MAX_REMOTE_READAHEAD);
+
+	local_free_page = node_page_state(numa_node_id(), NR_INACTIVE_FILE)
+			  + node_page_state(numa_node_id(), NR_FREE_PAGES);
+
+	/*
+	 * Readahead onto remote memory is better than no readahead when local
+	 * numa node does not have memory. We sanitize readahead size depending
+	 * on free memory in the local node but limiting to 4k pages.
+	 */
+	return local_free_page ? min(sane_nr, local_free_page / 2) : sane_nr;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
