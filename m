Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f42.google.com (mail-vb0-f42.google.com [209.85.212.42])
	by kanga.kvack.org (Postfix) with ESMTP id C0B7F6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 14:17:42 -0500 (EST)
Received: by mail-vb0-f42.google.com with SMTP id w5so2541296vbf.15
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 11:17:42 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id n4si6739615qeu.23.2014.01.09.11.17.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 11:17:41 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 9 Jan 2014 12:17:40 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A766F1FF001B
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 12:17:07 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s09JHRMN9109798
	for <linux-mm@kvack.org>; Thu, 9 Jan 2014 20:17:27 +0100
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s09JHaf0015310
	for <linux-mm@kvack.org>; Thu, 9 Jan 2014 12:17:36 -0700
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [RFC PATCH V4] mm readahead: Fix readahead fail for no local memory and limit readahead pages
Date: Fri, 10 Jan 2014 00:54:50 +0530
Message-Id: <1389295490-28707-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, jack@suse.cz, Linus <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

We limit the number of readahead pages to 4k.

max_sane_readahead returns zero on the cpu having no local memory
node. Fix that by returning a sanitized number of pages viz.,
minimum of (requested pages, 4k, number of local free pages)

Result:
fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
32GB* 4G RAM  numa machine ( 12 iterations) yielded

kernel       Avg        Stddev
base         7.264      0.56%
patched      7.285      1.14%

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 mm/readahead.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

V4:  incorporated 16MB limit suggested by Linus for readahead and
fixed transitioning to large readahead anomaly pointed by Andrew Morton with
Honza's suggestion.

Test results shows no significant overhead with the current changes.

(Do I have to break patches into two??)

Suggestions/Comments please let me know.

diff --git a/mm/readahead.c b/mm/readahead.c
index 7cdbb44..2f561a0 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -237,14 +237,30 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
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
+	unsigned long sane_nr;
+	int nid;
+
+	nid = numa_node_id();
+	sane_nr = min(nr, MAX_REMOTE_READAHEAD);
+
+	local_free_page = node_page_state(nid, NR_INACTIVE_FILE)
+			  + node_page_state(nid, NR_FREE_PAGES);
+
+	/*
+	 * Readahead onto remote memory is better than no readahead when local
+	 * numa node does not have memory. We sanitize readahead size depending
+	 * on free memory in the local node but limiting to 4k pages.
+	 */
+	return node_present_pages(nid) ?
+				min(sane_nr, local_free_page / 2) : sane_nr;
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
