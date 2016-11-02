Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B5F46B02BA
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 03:04:10 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id uc5so3764356pab.4
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:10 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id x6si1336730pgx.75.2016.11.02.00.04.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Nov 2016 00:04:09 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id n85so909104pfi.3
        for <linux-mm@kvack.org>; Wed, 02 Nov 2016 00:04:09 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH 1/2] mm: Use owner_priv bit for PageSwapCache, valid when PageSwapBacked
Date: Wed,  2 Nov 2016 18:03:45 +1100
Message-Id: <20161102070346.12489-2-npiggin@gmail.com>
In-Reply-To: <20161102070346.12489-1-npiggin@gmail.com>
References: <20161102070346.12489-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>

Can we do this? Seems too easy, I must be missing something.

---
 include/linux/page-flags.h     | 12 ++++++++++--
 include/trace/events/mmflags.h |  1 -
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..58d30b8 100644
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
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index 5a81ab4..30c2adb 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
