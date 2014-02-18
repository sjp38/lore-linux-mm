Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5CA6B0031
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 02:19:42 -0500 (EST)
Received: by mail-oa0-f51.google.com with SMTP id h16so18678213oag.24
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 23:19:41 -0800 (PST)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id iz10si10834553obb.39.2014.02.17.23.19.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 23:19:41 -0800 (PST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 18 Feb 2014 00:19:41 -0700
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C83E56E803A
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 02:19:32 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1I7Jbfl60620856
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:19:37 GMT
Received: from d01av02.pok.ibm.com (localhost [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1I7JaJ1017997
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 02:19:37 -0500
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu and limit readahead pages
Date: Tue, 18 Feb 2014 12:55:38 +0530
Message-Id: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>

Currently max_sane_readahead() returns zero on the cpu having no local memory node
which leads to readahead failure. Fix the readahead failure by returning
minimum of (requested pages, 512). Users running application on a memory-less cpu
which needs readahead such as streaming application see considerable boost in the
performance.

Result:
fadvise experiment with FADV_WILLNEED on a PPC machine having memoryless CPU
with 1GB testfile ( 12 iterations) yielded around 46.66% improvement.

fadvise experiment with FADV_WILLNEED on a x240 machine with 1GB testfile
32GB* 4G RAM  numa machine ( 12 iterations) showed no impact on the normal
NUMA cases w/ patch.

Kernel     Avg  Stddev
base	7.4975	3.92%
patched	7.4174  3.26%

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
[Andrew: making return value PAGE_SIZE independent]
Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 I would like to thank Honza, David for their valuable suggestions and 
 patiently reviewing the patches.

 Changes in V6:
  - Just limit the readahead to 2MB on 4k pages system as suggested by Linus.
 and make it independent of PAGE_SIZE. 

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
 mm/readahead.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/readahead.c b/mm/readahead.c
index 0de2360..1fa0d6f 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -233,14 +233,14 @@ int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	return 0;
 }
 
+#define MAX_READAHEAD   ((512*4096)/PAGE_CACHE_SIZE)
 /*
  * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
  * sensible upper limit.
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
-		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
+	return min(nr, MAX_READAHEAD);
 }
 
 /*
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
