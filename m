Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE94831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 14:20:42 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t126so39899075pgc.9
        for <linux-mm@kvack.org>; Thu, 18 May 2017 11:20:42 -0700 (PDT)
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com. [209.85.192.177])
        by mx.google.com with ESMTPS id m11si4057831pgc.389.2017.05.18.11.20.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 11:20:41 -0700 (PDT)
Received: by mail-pf0-f177.google.com with SMTP id m17so27629535pfg.3
        for <linux-mm@kvack.org>; Thu, 18 May 2017 11:20:41 -0700 (PDT)
From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] mm, page_alloc: Mark bad_range() and meminit_pfn_in_nid() as __maybe_unused
Date: Thu, 18 May 2017 11:20:30 -0700
Message-Id: <20170518182030.165633-1-mka@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>

The functions are not used in some configurations. Adding the attribute
fixes the following warnings when building with clang:

mm/page_alloc.c:409:19: error: function 'bad_range' is not needed and
    will not be emitted [-Werror,-Wunneeded-internal-declaration]

mm/page_alloc.c:1106:30: error: unused function 'meminit_pfn_in_nid'
    [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 mm/page_alloc.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9e450c6b6e4..30d0dede3cf4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -500,7 +500,7 @@ static int page_is_consistent(struct zone *zone, struct page *page)
 /*
  * Temporary debugging check for pages not lying within a given zone.
  */
-static int bad_range(struct zone *zone, struct page *page)
+static int __maybe_unused bad_range(struct zone *zone, struct page *page)
 {
 	if (page_outside_zone_boundaries(zone, page))
 		return 1;
@@ -510,7 +510,7 @@ static int bad_range(struct zone *zone, struct page *page)
 	return 0;
 }
 #else
-static inline int bad_range(struct zone *zone, struct page *page)
+static inline int __maybe_unused bad_range(struct zone *zone, struct page *page)
 {
 	return 0;
 }
@@ -1286,8 +1286,9 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 #endif
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-					struct mminit_pfnnid_cache *state)
+static inline bool __meminit __maybe_unused
+meminit_pfn_in_nid(unsigned long pfn, int node,
+		   struct mminit_pfnnid_cache *state)
 {
 	int nid;
 
@@ -1309,8 +1310,9 @@ static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 {
 	return true;
 }
-static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-					struct mminit_pfnnid_cache *state)
+static inline bool __meminit  __maybe_unused
+meminit_pfn_in_nid(unsigned long pfn, int node,
+		   struct mminit_pfnnid_cache *state)
 {
 	return true;
 }
-- 
2.13.0.303.g4ebf302169-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
