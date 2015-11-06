Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 184D082F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 11:17:14 -0500 (EST)
Received: by wmll128 with SMTP id l128so38663331wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 08:17:13 -0800 (PST)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id 82si1797726wmu.21.2015.11.06.08.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 08:17:13 -0800 (PST)
Received: by wikq8 with SMTP id q8so33336156wik.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 08:17:12 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH] jbd2: get rid of superfluous __GFP_REPEAT
Date: Fri,  6 Nov 2015 17:17:03 +0100
Message-Id: <1446826623-23959-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
References: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

jbd2_alloc is explicit about its allocation preferences wrt. the
allocation size. Sub page allocations go to the slab allocator
and larger are using either the page allocator or vmalloc. This
is all good but the logic is unnecessarily complex. Requests larger
than order-3 are doing the vmalloc directly while smaller go to the
page allocator with __GFP_REPEAT. The flag doesn't do anything useful
for those because they are smaller than PAGE_ALLOC_COSTLY_ORDER.

Let's simplify the code flow and use kmalloc for sub-page requests
and the page allocator for others with fallback to vmalloc if the
allocation fails.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/jbd2/journal.c | 35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 81e622681c82..2945c96f171f 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2299,18 +2299,15 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 
 	BUG_ON(size & (size-1)); /* Must be a power of 2 */
 
-	flags |= __GFP_REPEAT;
-	if (size == PAGE_SIZE)
-		ptr = (void *)__get_free_pages(flags, 0);
-	else if (size > PAGE_SIZE) {
+	if (size < PAGE_SIZE)
+		ptr = kmem_cache_alloc(get_slab(size), flags);
+	else {
 		int order = get_order(size);
 
-		if (order < 3)
-			ptr = (void *)__get_free_pages(flags, order);
-		else
+		ptr = (void *)__get_free_pages(flags, order);
+		if (!ptr)
 			ptr = vmalloc(size);
-	} else
-		ptr = kmem_cache_alloc(get_slab(size), flags);
+	}
 
 	/* Check alignment; SLUB has gotten this wrong in the past,
 	 * and this can lead to user data corruption! */
@@ -2321,20 +2318,12 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 
 void jbd2_free(void *ptr, size_t size)
 {
-	if (size == PAGE_SIZE) {
-		free_pages((unsigned long)ptr, 0);
-		return;
-	}
-	if (size > PAGE_SIZE) {
-		int order = get_order(size);
-
-		if (order < 3)
-			free_pages((unsigned long)ptr, order);
-		else
-			vfree(ptr);
-		return;
-	}
-	kmem_cache_free(get_slab(size), ptr);
+	if (size < PAGE_SIZE)
+		kmem_cache_free(get_slab(size), ptr);
+	else if (is_vmalloc_addr(ptr))
+		vfree(ptr);
+	else
+		free_pages((unsigned long)ptr, get_order(size));
 };
 
 /*
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
