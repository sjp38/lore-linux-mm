Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id DB0126B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 13:11:46 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] HWPOISON: check dirty flag to match against clean page
Date: Mon, 25 Feb 2013 13:10:52 -0500
Message-Id: <1361815852-23891-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Currently page_action() does not check dirty flag to determine whether
the error page is "clean mlocked/unevictable LRU" page.
This doesn't cause any misjudgement because we do matching against
"dirty mlocked/unevictable LRU" just before the check.
But in order to make code consistent and/or to avoid potential regression,
we had better check dirty flag explicitly.

Dependency:
  This patch depends on the patch "HWPOISON: change order of
  error_states[]'s elements" which perhaps will be merged in v3.9-rc1.

Suggested-by: Chen Gong <gong.chen@linux.intel.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git v3.8.orig/mm/memory-failure.c v3.8/mm/memory-failure.c
index 01e4676..d99cd79 100644
--- v3.8.orig/mm/memory-failure.c
+++ v3.8/mm/memory-failure.c
@@ -785,10 +785,10 @@ static struct page_state {
 	{ sc|dirty,	sc,		"clean swapcache",	me_swapcache_clean },
 
 	{ mlock|dirty,	mlock|dirty,	"dirty mlocked LRU",	me_pagecache_dirty },
-	{ mlock,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
+	{ mlock|dirty,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
 
 	{ unevict|dirty, unevict|dirty,	"dirty unevictable LRU", me_pagecache_dirty },
-	{ unevict,	unevict,	"clean unevictable LRU", me_pagecache_clean },
+	{ unevict|dirty, unevict,	"clean unevictable LRU", me_pagecache_clean },
 
 	{ lru|dirty,	lru|dirty,	"dirty LRU",	me_pagecache_dirty },
 	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
