Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0316A6B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 08:24:30 -0500 (EST)
Received: by qcyl6 with SMTP id l6so16399244qcy.2
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 05:24:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ks2si29448827qcb.39.2015.02.24.05.24.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 05:24:29 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH] mm: readahead: get back a sensible upper limit
Date: Tue, 24 Feb 2015 07:58:04 -0500
Message-Id: <9cc2b63100622f5fd17fa5e4adc59233a2b41877.1424779443.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, jweiner@redhat.com, riel@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org, loberman@redhat.com, lwoodman@redhat.com, raghavendra.kt@linux.vnet.ibm.com

commit 6d2be915e589 ("mm/readahead.c: fix readahead failure for memoryless NUMA
nodes and limit readahead pages")[1] imposed 2 mB hard limits to readahead by 
changing max_sane_readahead() to sort out a corner case where a thread runs on 
amemoryless NUMA node and it would have its readahead capability disabled.

The aforementioned change, despite fixing that corner case, is detrimental to
other ordinary workloads that memory map big files and rely on readahead() or
posix_fadvise(WILLNEED) syscalls to get most of the file populating system's cache.

Laurence Oberman reports, via https://bugzilla.redhat.com/show_bug.cgi?id=1187940,
slowdowns up to 3-4 times when changes for mentioned commit [1] got introduced in
RHEL kenrel. We also have an upstream bugzilla opened for similar complaint:
https://bugzilla.kernel.org/show_bug.cgi?id=79111

This patch brings back the old behavior of max_sane_readahead() where we used to
consider NR_INACTIVE_FILE and NR_FREE_PAGES pages to derive a sensible / adujstable
readahead upper limit. This patch also keeps the 2 mB ceiling scheme introduced by
commit [1] to avoid regressions on CONFIG_HAVE_MEMORYLESS_NODES systems,
where numa_mem_id(), by any buggy reason, might end up not returning
the 'local memory' for a memoryless node CPU.

Reported-by: Laurence Oberman <loberman@redhat.com>
Tested-by: Laurence Oberman <loberman@redhat.com>
Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 mm/readahead.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 9356758..73f934d 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -203,6 +203,7 @@ out:
 	return ret;
 }
 
+#define MAX_READAHEAD   ((512 * 4096) / PAGE_CACHE_SIZE)
 /*
  * Chunk the readahead into 2 megabyte units, so that we don't pin too much
  * memory at once.
@@ -217,7 +218,7 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	while (nr_to_read) {
 		int err;
 
-		unsigned long this_chunk = (2 * 1024 * 1024) / PAGE_CACHE_SIZE;
+		unsigned long this_chunk = MAX_READAHEAD;
 
 		if (this_chunk > nr_to_read)
 			this_chunk = nr_to_read;
@@ -232,14 +233,15 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	return 0;
 }
 
-#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
 /*
  * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
  * sensible upper limit.
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, MAX_READAHEAD);
+	return min(nr, max(MAX_READAHEAD,
+			  (node_page_state(numa_mem_id(), NR_INACTIVE_FILE) +
+			   node_page_state(numa_mem_id(), NR_FREE_PAGES)) / 2));
 }
 
 /*
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
