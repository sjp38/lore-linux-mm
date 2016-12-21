Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 89CD96B03B0
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:20:20 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so379235571pgi.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:20:20 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id g15si27052004pli.166.2016.12.21.07.20.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 07:20:19 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so7045378pgh.2
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 07:20:19 -0800 (PST)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked
Date: Thu, 22 Dec 2016 01:19:50 +1000
Message-Id: <20161221151951.16396-2-npiggin@gmail.com>
In-Reply-To: <20161221151951.16396-1-npiggin@gmail.com>
References: <20161221151951.16396-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>
Cc: Nicholas Piggin <npiggin@gmail.com>

---
 include/linux/page-flags.h     | 24 ++++++++++++++++--------
 include/trace/events/mmflags.h |  1 -
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda91238..a57c909a15e4 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -87,7 +87,6 @@ enum pageflags {
 	PG_private_2,		/* If pagecache, has fs aux data */
 	PG_writeback,		/* Page is under writeback */
 	PG_head,		/* A head page */
-	PG_swapcache,		/* Swap page: swp_entry_t in private */
 	PG_mappedtodisk,	/* Has blocks allocated on-disk */
 	PG_reclaim,		/* To be reclaimed asap */
 	PG_swapbacked,		/* Page is backed by RAM/swap */
@@ -110,6 +109,9 @@ enum pageflags {
 	/* Filesystems */
 	PG_checked = PG_owner_priv_1,
 
+	/* SwapBacked */
+	PG_swapcache = PG_owner_priv_1,	/* Swap page: swp_entry_t in private */
+
 	/* Two page bits are conscripted by FS-Cache to maintain local caching
 	 * state.  These bits are set on pages belonging to the netfs's inodes
 	 * when those inodes are being locally cached.
@@ -314,7 +316,13 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
+static __always_inline int PageSwapCache(struct page *page)
+{
+	return PageSwapBacked(page) && test_bit(PG_swapcache, &page->flags);
+
+}
+SETPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
+CLEARPAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
@@ -701,12 +709,12 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  * Flags checked when a page is freed.  Pages being freed should not have
  * these flags set.  It they are, there is a problem.
  */
-#define PAGE_FLAGS_CHECK_AT_FREE \
-	(1UL << PG_lru	 | 1UL << PG_locked    | \
-	 1UL << PG_private | 1UL << PG_private_2 | \
-	 1UL << PG_writeback | 1UL << PG_reserved | \
-	 1UL << PG_slab	 | 1UL << PG_swapcache | 1UL << PG_active | \
-	 1UL << PG_unevictable | __PG_MLOCKED)
+#define PAGE_FLAGS_CHECK_AT_FREE				\
+	(1UL << PG_lru		| 1UL << PG_locked	|	\
+	 1UL << PG_private	| 1UL << PG_private_2	|	\
+	 1UL << PG_writeback	| 1UL << PG_reserved	|	\
+	 1UL << PG_slab		| 1UL << PG_active 	|	\
+	 1UL << PG_unevictable	| __PG_MLOCKED)
 
 /*
  * Flags checked when a page is prepped for return by the page allocator.
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab48a2fb..30c2adbdebe8 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -95,7 +95,6 @@
 	{1UL << PG_private_2,		"private_2"	},		\
 	{1UL << PG_writeback,		"writeback"	},		\
 	{1UL << PG_head,		"head"		},		\
-	{1UL << PG_swapcache,		"swapcache"	},		\
 	{1UL << PG_mappedtodisk,	"mappedtodisk"	},		\
 	{1UL << PG_reclaim,		"reclaim"	},		\
 	{1UL << PG_swapbacked,		"swapbacked"	},		\
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
