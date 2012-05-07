Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id E2F786B00E9
	for <linux-mm@kvack.org>; Mon,  7 May 2012 07:38:12 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 04/10] mm: bootmem: split out goal-to-node mapping from goal dropping
Date: Mon,  7 May 2012 13:37:46 +0200
Message-Id: <1336390672-14421-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
References: <1336390672-14421-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, David Miller <davem@davemloft.net>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Matching the desired goal to the right node is one thing, dropping the
goal when it can not be satisfied is another.  Split this into
separate functions so that subsequent patches can use the node-finding
but drop and handle the goal fallback on their own terms.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/bootmem.c |   17 +++++++++++++++--
 1 file changed, 15 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index ceed0df..bafeb2c 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -596,7 +596,7 @@ static void * __init alloc_arch_preferred_bootmem(bootmem_data_t *bdata,
 	return NULL;
 }
 
-static void * __init ___alloc_bootmem_nopanic(unsigned long size,
+static void * __init alloc_bootmem_core(unsigned long size,
 					unsigned long align,
 					unsigned long goal,
 					unsigned long limit)
@@ -604,7 +604,6 @@ static void * __init ___alloc_bootmem_nopanic(unsigned long size,
 	bootmem_data_t *bdata;
 	void *region;
 
-restart:
 	region = alloc_arch_preferred_bootmem(NULL, size, align, goal, limit);
 	if (region)
 		return region;
@@ -620,6 +619,20 @@ restart:
 			return region;
 	}
 
+	return NULL;
+}
+
+static void * __init ___alloc_bootmem_nopanic(unsigned long size,
+					      unsigned long align,
+					      unsigned long goal,
+					      unsigned long limit)
+{
+	void *ptr;
+
+restart:
+	ptr = alloc_bootmem_core(size, align, goal, limit);
+	if (ptr)
+		return ptr;
 	if (goal) {
 		goal = 0;
 		goto restart;
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
