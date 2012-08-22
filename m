Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id EB0326B00C0
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:17:58 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/3] HWPOISON: fix action_result() to print out dirty/clean
Date: Wed, 22 Aug 2012 11:17:33 -0400
Message-Id: <1345648655-4497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1345648655-4497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

action_result() fails to print out "dirty" even if an error occurred on a
dirty pagecache, because when we check PageDirty in action_result() it was
cleared after page isolation even if it's dirty before error handling. This
can break some applications that monitor this message, so should be fixed.

There are several callers of action_result() except page_action(), but
either of them are not for LRU pages but for free pages or kernel pages,
so we don't have to consider dirty or not for them.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
index a6e2141..79dfb2f 100644
--- v3.6-rc1.orig/mm/memory-failure.c
+++ v3.6-rc1/mm/memory-failure.c
@@ -779,16 +779,16 @@ static struct page_state {
 	{ compound,	compound,	"huge",		me_huge_page },
 #endif
 
-	{ sc|dirty,	sc|dirty,	"swapcache",	me_swapcache_dirty },
-	{ sc|dirty,	sc,		"swapcache",	me_swapcache_clean },
+	{ sc|dirty,	sc|dirty,	"dirty swapcache",	me_swapcache_dirty },
+	{ sc|dirty,	sc,		"clean swapcache",	me_swapcache_clean },
 
-	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
-	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
+	{ unevict|dirty, unevict|dirty,	"dirty unevictable LRU", me_pagecache_dirty },
+	{ unevict,	unevict,	"clean unevictable LRU", me_pagecache_clean },
 
-	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
-	{ mlock,	mlock,		"mlocked LRU",	me_pagecache_clean },
+	{ mlock|dirty,	mlock|dirty,	"dirty mlocked LRU",	me_pagecache_dirty },
+	{ mlock,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
 
-	{ lru|dirty,	lru|dirty,	"LRU",		me_pagecache_dirty },
+	{ lru|dirty,	lru|dirty,	"dirty LRU",	me_pagecache_dirty },
 	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
 
 	/*
@@ -812,12 +812,8 @@ static struct page_state {
 
 static void action_result(unsigned long pfn, char *msg, int result)
 {
-	struct page *page = pfn_to_page(pfn);
-
-	printk(KERN_ERR "MCE %#lx: %s%s page recovery: %s\n",
-		pfn,
-		PageDirty(page) ? "dirty " : "",
-		msg, action_name[result]);
+	pr_err("MCE %#lx: %s page recovery: %s\n",
+		pfn, msg, action_name[result]);
 }
 
 static int page_action(struct page_state *ps, struct page *p,
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
