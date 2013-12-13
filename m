Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 10FCE6B00A0
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 09:10:14 -0500 (EST)
Received: by mail-ee0-f47.google.com with SMTP id e51so757006eek.20
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 06:10:14 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9si1999648eeo.86.2013.12.13.06.10.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 06:10:14 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/7] mm: Annotate page cache allocations
Date: Fri, 13 Dec 2013 14:10:04 +0000
Message-Id: <1386943807-29601-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386943807-29601-1-git-send-email-mgorman@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Annotations will be used for fair zone allocation policy. Patch is mostly
taken from a link posted by Johannes on IRC. It's not perfect because all
callers of these paths are not guaranteed to be allocating pages for page
cache. However, it's probably close enough to cover all cases that matter
with minimal distortion.

Not-signed-off
---
 include/linux/gfp.h     | 4 +++-
 include/linux/pagemap.h | 2 +-
 mm/filemap.c            | 2 ++
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 9b4dd49..f69e4cb 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -35,6 +35,7 @@ struct vm_area_struct;
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
 #define ___GFP_WRITE		0x1000000u
+#define ___GFP_PAGECACHE	0x2000000u
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -92,6 +93,7 @@ struct vm_area_struct;
 #define __GFP_OTHER_NODE ((__force gfp_t)___GFP_OTHER_NODE) /* On behalf of other node */
 #define __GFP_KMEMCG	((__force gfp_t)___GFP_KMEMCG) /* Allocation comes from a memcg-accounted resource */
 #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)	/* Allocator intends to dirty page */
+#define __GFP_PAGECACHE ((__force gfp_t)___GFP_PAGECACHE)   /* Page cache allocation */
 
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.
@@ -99,7 +101,7 @@ struct vm_area_struct;
  */
 #define __GFP_NOTRACK_FALSE_POSITIVE (__GFP_NOTRACK)
 
-#define __GFP_BITS_SHIFT 25	/* Room for N __GFP_FOO bits */
+#define __GFP_BITS_SHIFT 26	/* Room for N __GFP_FOO bits */
 #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
 
 /* This equals 0, but use constants in case they ever change */
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e3dea75..bda4845 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -221,7 +221,7 @@ extern struct page *__page_cache_alloc(gfp_t gfp);
 #else
 static inline struct page *__page_cache_alloc(gfp_t gfp)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp | __GFP_PAGECACHE, 0);
 }
 #endif
 
diff --git a/mm/filemap.c b/mm/filemap.c
index b7749a9..5bb9225 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -517,6 +517,8 @@ struct page *__page_cache_alloc(gfp_t gfp)
 	int n;
 	struct page *page;
 
+	gfp |= __GFP_PAGECACHE;
+
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
