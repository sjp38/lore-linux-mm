Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f44.google.com (mail-yh0-f44.google.com [209.85.213.44])
	by kanga.kvack.org (Postfix) with ESMTP id B2D3F6B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 06:03:47 -0500 (EST)
Received: by mail-yh0-f44.google.com with SMTP id f73so50941yha.31
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 03:03:47 -0800 (PST)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id q69si10363434yhd.120.2014.01.22.03.03.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 03:03:43 -0800 (PST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Wed, 22 Jan 2014 04:03:38 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 753513E4003E
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:03:36 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0MB3a8952363508
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 12:03:36 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0MB3aQ1020761
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 04:03:36 -0700
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [RFC PATCH V5] mm readahead: Fix readahead fail for no local memory and limit readahead pages
Date: Wed, 22 Jan 2014 16:23:45 +0530
Message-Id: <1390388025-1418-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, Linus <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

max_sane_readahead returns zero on the cpu having no local memory
node. Fix that by returning a sanitized number of pages viz.,
minimum of (requested pages, 4k)

Result:
fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
32GB* 4G RAM  numa machine ( 12 iterations) yielded

Kernel     Avg      Stddev
base      7.2963    1.10 %
patched   7.2972    1.18 %

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 Changes in V5:
 - Drop the 4k limit for normal readahead. (Jan Kara)

 Changes in V4:
 - Check for total node memory to decide whether we don't
   have local memory (jan Kara)
 - Add 4k page limit on readahead for normal and remote readahead (Linus)
   (Linus suggestion was 16MB limit).

 Changes in V3:
 - Drop iterating over numa nodes that calculates total free pages (Linus)

 Agree that we do not have control on allocation for readahead on a
 particular numa node and hence for remote readahead we can not further
 sanitize based on potential free pages of that node. and also we do
 not want to itererate through all nodes to find total free pages.

 Suggestions and comments welcome

 mm/readahead.c | 22 ++++++++++++++++++++--
 1 file changed, 20 insertions(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 7cdbb44..9d2afd0 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -237,14 +237,32 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
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
+	int nid;
+
+	nid = numa_node_id();
+	if (node_present_pages(nid)) {
+		/*
+		 * We sanitize readahead size depending on free memory in
+		 * the local node.
+		 */
+		local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
+				 + node_page_state(nid, NR_FREE_PAGES);
+		return min(nr, local_free_page / 2);
+	}
+	/*
+	 * Readahead onto remote memory is better than no readahead when local
+	 * numa node does not have memory. We limit the readahead to 4k
+	 * pages though to avoid trashing page cache.
+	 */
+	return min(nr, MAX_REMOTE_READAHEAD);
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
