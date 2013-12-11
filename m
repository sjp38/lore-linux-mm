Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id EFBB36B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 09:39:09 -0500 (EST)
Received: by mail-qa0-f41.google.com with SMTP id j5so4807537qaq.14
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:39:09 -0800 (PST)
Received: from devils.ext.ti.com (devils.ext.ti.com. [198.47.26.153])
        by mx.google.com with ESMTPS id b6si15626750qak.166.2013.12.11.06.39.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 06:39:08 -0800 (PST)
From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/2] mm/memblock: add more comments in code
Date: Wed, 11 Dec 2013 17:36:13 +0200
Message-ID: <1386776175-23779-1-git-send-email-grygorii.strashko@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: santosh.shilimkar@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

Add additional description on:
- why warning is produced in case if slab is ready
- why kmemleak_alloc is called for each allocated memory block

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---

It's additional change on top of the memblock series 
https://lkml.org/lkml/2013/12/9/715

 mm/memblock.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index d03d50a..974f0d3 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -985,6 +985,11 @@ static void * __init memblock_virt_alloc_internal(
 		pr_warn("%s: usage of MAX_NUMNODES is depricated. Use NUMA_NO_NODE\n",
 			__func__);
 
+	/*
+	 * Detect any accidental use of these APIs after slab is ready, as at
+	 * this moment memblock may be deinitialized already and its
+	 * internal data may be destroyed (after execution of free_all_bootmem)
+	 */
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
 
@@ -1021,7 +1026,9 @@ done:
 
 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks
-	 * are never reported as leaks.
+	 * are never reported as leaks. This is because many of these blocks
+	 * are only referred via the physical address which is not
+	 * looked up by kmemleak.
 	 */
 	kmemleak_alloc(ptr, size, 0, 0);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
