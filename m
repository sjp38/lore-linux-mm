Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id A745E82F6A
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 11:16:23 -0500 (EST)
Received: by wmll128 with SMTP id l128so18103371wml.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:23 -0800 (PST)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id q6si9425218wmg.4.2015.11.05.08.16.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 08:16:22 -0800 (PST)
Received: by wicll6 with SMTP id ll6so12815116wic.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 08:16:22 -0800 (PST)
From: mhocko@kernel.org
Subject: [PATCH 3/3] jbd2: get rid of superfluous __GFP_REPEAT
Date: Thu,  5 Nov 2015 17:16:00 +0100
Message-Id: <1446740160-29094-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Theodore Ts'o <tytso@mit.edu>

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
 fs/jbd2/journal.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 81e622681c82..630abbfa4b61 100644
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
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
