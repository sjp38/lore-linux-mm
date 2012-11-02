Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 7D3CF6B005D
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 12:33:37 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 1/2 v2] HWPOISON: fix action_result() to print out dirty/clean
Date: Fri,  2 Nov 2012 12:33:12 -0400
Message-Id: <1351873993-9373-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1351873993-9373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1351873993-9373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

action_result() fails to print out "dirty" even if an error occurred on a
dirty pagecache, because when we check PageDirty in action_result() it was
cleared after page isolation even if it's dirty before error handling. This
can break some applications that monitor this message, so should be fixed.

There are several callers of action_result() except page_action(), but
either of them are not for LRU pages but for free pages or kernel pages,
so we don't have to consider dirty or not for them.

Note that PG_dirty can be set outside page locks as described in commit
554940dc8c1e, so this patch does not completely closes the race window,
but just narrows it.

Changelog v2:
  - Add comment about setting PG_dirty outside page lock

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git v3.7-rc3.orig/mm/memory-failure.c v3.7-rc3/mm/memory-failure.c
index 6c5899b..4377de9 100644
--- v3.7-rc3.orig/mm/memory-failure.c
+++ v3.7-rc3/mm/memory-failure.c
@@ -781,16 +781,16 @@ static struct page_state {
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
@@ -812,14 +812,14 @@ static struct page_state {
 #undef slab
 #undef reserved
 
+/*
+ * "Dirty/Clean" indication is not 100% accurate due to the possibility of
+ * setting PG_dirty outside page lock. See also comment above set_page_dirty().
+ */
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
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
