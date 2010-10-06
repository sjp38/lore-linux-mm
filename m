Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 759586B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 17:02:16 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 2/2] HWPOISON: Attempt directed shrinking of slabs
Date: Wed,  6 Oct 2010 23:02:10 +0200
Message-Id: <1286398930-11956-3-git-send-email-andi@firstfloor.org>
In-Reply-To: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
References: <1286398930-11956-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: penberg@cs.helsinki.fi, cl@linux-foundation.org, mpm@selenic.com, Andi Kleen <ak@linux.intel.com>, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

From: Andi Kleen <ak@linux.intel.com>

When a slab page is found try to shrink the specific slab first
before trying to shrink all slabs and call other shrinkers.
This can be done now using the new kmem_page_cache() call.

Cc: fengguang.wu@intel.com
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 9c26eec..b49d81a 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -212,6 +212,20 @@ static int kill_proc_ao(struct task_struct *t, unsigned long addr, int trapno,
 	return ret;
 }
 
+/* 
+ * Try to free a slab page by shrinking the slab.
+ */
+static int shake_slab(struct page *p)
+{
+	struct kmem_cache *cache;
+
+	cache = kmem_page_cache(p);
+	if (!cache)
+		return 0;
+	kmem_cache_shrink(cache);
+	return page_count(p) == 1;
+}
+
 /*
  * When a unknown page type is encountered drain as many buffers as possible
  * in the hope to turn the page into a LRU or free page, which we can handle.
@@ -233,6 +247,10 @@ void shake_page(struct page *p, int access)
 	 */
 	if (access) {
 		int nr;
+
+		if (shake_slab(p))
+			return;
+
 		do {
 			nr = shrink_slab(1000, GFP_KERNEL, 1000);
 			if (page_count(p) == 0)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
