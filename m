Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79C406B0280
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 09:32:43 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e201so3702575wme.1
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:32:43 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id g4si8683472wjy.235.2016.04.28.06.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 06:24:27 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id a17so65227584wme.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 06:24:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 20/20] jbd2: get rid of superfluous __GFP_REPEAT
Date: Thu, 28 Apr 2016 15:24:06 +0200
Message-Id: <1461849846-27209-21-git-send-email-mhocko@kernel.org>
In-Reply-To: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
References: <1461849846-27209-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Theodore Ts'o <tytso@mit.edu>

From: Michal Hocko <mhocko@suse.com>

jbd2_alloc is explicit about its allocation preferences wrt. the
allocation size. Sub page allocations go to the slab allocator
and larger are using either the page allocator or vmalloc. This
is all good but the logic is unnecessarily complex.
1) as per Ted, the vmalloc fallback is a left-over:
: jbd2_alloc is only passed in the bh->b_size, which can't be >
: PAGE_SIZE, so the code path that calls vmalloc() should never get
: called.  When we conveted jbd2_alloc() to suppor sub-page size
: allocations in commit d2eecb039368, there was an assumption that it
: could be called with a size greater than PAGE_SIZE, but that's
: certaily not true today.
Moreover vmalloc allocation might even lead to a deadlock because
the callers expect GFP_NOFS context while vmalloc is GFP_KERNEL.

2) __GFP_REPEAT for requests <= PAGE_ALLOC_COSTLY_ORDER is ignored
since the flag was introduced.

Let's simplify the code flow and use the slab allocator for sub-page
requests and the page allocator for others. Even though order > 0 is
not currently used as per above leave that option open.

Cc: "Theodore Ts'o" <tytso@mit.edu>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 fs/jbd2/journal.c | 32 +++++++-------------------------
 1 file changed, 7 insertions(+), 25 deletions(-)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index b31852f76f46..e3ca4b4cac84 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -2329,18 +2329,10 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 
 	BUG_ON(size & (size-1)); /* Must be a power of 2 */
 
-	flags |= __GFP_REPEAT;
-	if (size == PAGE_SIZE)
-		ptr = (void *)__get_free_pages(flags, 0);
-	else if (size > PAGE_SIZE) {
-		int order = get_order(size);
-
-		if (order < 3)
-			ptr = (void *)__get_free_pages(flags, order);
-		else
-			ptr = vmalloc(size);
-	} else
+	if (size < PAGE_SIZE)
 		ptr = kmem_cache_alloc(get_slab(size), flags);
+	else
+		ptr = (void *)__get_free_pages(flags, get_order(size));
 
 	/* Check alignment; SLUB has gotten this wrong in the past,
 	 * and this can lead to user data corruption! */
@@ -2351,20 +2343,10 @@ void *jbd2_alloc(size_t size, gfp_t flags)
 
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
+	else
+		free_pages((unsigned long)ptr, get_order(size));
 };
 
 /*
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
