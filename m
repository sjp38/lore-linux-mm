Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 263EE6B0038
	for <linux-mm@kvack.org>; Thu, 19 Mar 2015 02:25:55 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so47689806obb.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 23:25:54 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id pq7si188842oeb.97.2015.03.18.23.25.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 23:25:54 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/memory-failure.c: define page types for action_result()
 in one place
Date: Thu, 19 Mar 2015 06:24:35 +0000
Message-ID: <1426746272-24306-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>, Chen Gong <gong.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This cleanup patch moves all strings passed to action_result() into a singl=
e
array action_page_type so that a reader can easily find which kind of actio=
n
results are possible. And this patch also fixes the odd lines to be printed
out, like "unknown page state page" or "free buddy, 2nd try page".

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 107 +++++++++++++++++++++++++++++++++++++-----------=
----
 1 file changed, 76 insertions(+), 31 deletions(-)

diff --git v3.19.orig/mm/memory-failure.c v3.19/mm/memory-failure.c
index d487f8dc6d39..afb740e1c8b0 100644
--- v3.19.orig/mm/memory-failure.c
+++ v3.19/mm/memory-failure.c
@@ -521,6 +521,52 @@ static const char *action_name[] =3D {
 	[RECOVERED] =3D "Recovered",
 };
=20
+enum page_type {
+	KERNEL,
+	KERNEL_HIGH_ORDER,
+	SLAB,
+	DIFFERENT_COMPOUND,
+	POISONED_HUGE,
+	HUGE,
+	FREE_HUGE,
+	UNMAP_FAILED,
+	DIRTY_SWAPCACHE,
+	CLEAN_SWAPCACHE,
+	DIRTY_MLOCKED_LRU,
+	CLEAN_MLOCKED_LRU,
+	DIRTY_UNEVICTABLE_LRU,
+	CLEAN_UNEVICTABLE_LRU,
+	DIRTY_LRU,
+	CLEAN_LRU,
+	TRUNCATED_LRU,
+	BUDDY,
+	BUDDY_2ND,
+	UNKNOWN,
+};
+
+static const char *action_page_type[] =3D {
+	[KERNEL]		=3D "reserved kernel page",
+	[KERNEL_HIGH_ORDER]	=3D "high-order kernel page",
+	[SLAB]			=3D "kernel slab page",
+	[DIFFERENT_COMPOUND]	=3D "different compound page after locking",
+	[POISONED_HUGE]		=3D "huge page already hardware poisoned",
+	[HUGE]			=3D "huge page",
+	[FREE_HUGE]		=3D "free huge page",
+	[UNMAP_FAILED]		=3D "unmapping failed page",
+	[DIRTY_SWAPCACHE]	=3D "dirty swapcache page",
+	[CLEAN_SWAPCACHE]	=3D "clean swapcache page",
+	[DIRTY_MLOCKED_LRU]	=3D "dirty mlocked LRU page",
+	[CLEAN_MLOCKED_LRU]	=3D "clean mlocked LRU page",
+	[DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
+	[CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
+	[DIRTY_LRU]		=3D "dirty LRU page",
+	[CLEAN_LRU]		=3D "clean LRU page",
+	[TRUNCATED_LRU]		=3D "already truncated LRU page",
+	[BUDDY]			=3D "free buddy page",
+	[BUDDY_2ND]		=3D "free buddy page (2nd try)",
+	[UNKNOWN]		=3D "unknown page",
+};
+
 /*
  * XXX: It is possible that a page is isolated from LRU cache,
  * and then kept in swap cache or failed to remove from page cache.
@@ -777,10 +823,10 @@ static int me_huge_page(struct page *p, unsigned long=
 pfn)
 static struct page_state {
 	unsigned long mask;
 	unsigned long res;
-	char *msg;
+	int type;
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] =3D {
-	{ reserved,	reserved,	"reserved kernel",	me_kernel },
+	{ reserved,	reserved,	KERNEL,	me_kernel },
 	/*
 	 * free pages are specially detected outside this table:
 	 * PG_buddy pages only make a small fraction of all free pages.
@@ -791,31 +837,31 @@ static struct page_state {
 	 * currently unused objects without touching them. But just
 	 * treat it as standard kernel for now.
 	 */
-	{ slab,		slab,		"kernel slab",	me_kernel },
+	{ slab,		slab,		SLAB,	me_kernel },
=20
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
-	{ head,		head,		"huge",		me_huge_page },
-	{ tail,		tail,		"huge",		me_huge_page },
+	{ head,		head,		HUGE,		me_huge_page },
+	{ tail,		tail,		HUGE,		me_huge_page },
 #else
-	{ compound,	compound,	"huge",		me_huge_page },
+	{ compound,	compound,	HUGE,		me_huge_page },
 #endif
=20
-	{ sc|dirty,	sc|dirty,	"dirty swapcache",	me_swapcache_dirty },
-	{ sc|dirty,	sc,		"clean swapcache",	me_swapcache_clean },
+	{ sc|dirty,	sc|dirty,	DIRTY_SWAPCACHE,	me_swapcache_dirty },
+	{ sc|dirty,	sc,		CLEAN_SWAPCACHE,	me_swapcache_clean },
=20
-	{ mlock|dirty,	mlock|dirty,	"dirty mlocked LRU",	me_pagecache_dirty },
-	{ mlock|dirty,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
+	{ mlock|dirty,	mlock|dirty,	DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
+	{ mlock|dirty,	mlock,		CLEAN_MLOCKED_LRU,	me_pagecache_clean },
=20
-	{ unevict|dirty, unevict|dirty,	"dirty unevictable LRU", me_pagecache_dir=
ty },
-	{ unevict|dirty, unevict,	"clean unevictable LRU", me_pagecache_clean },
+	{ unevict|dirty, unevict|dirty,	DIRTY_UNEVICTABLE_LRU,	me_pagecache_dirty=
 },
+	{ unevict|dirty, unevict,	DIRTY_UNEVICTABLE_LRU,	me_pagecache_clean },
=20
-	{ lru|dirty,	lru|dirty,	"dirty LRU",	me_pagecache_dirty },
-	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
+	{ lru|dirty,	lru|dirty,	DIRTY_LRU,	me_pagecache_dirty },
+	{ lru|dirty,	lru,		CLEAN_LRU,	me_pagecache_clean },
=20
 	/*
 	 * Catchall entry: must be at end.
 	 */
-	{ 0,		0,		"unknown page state",	me_unknown },
+	{ 0,		0,		UNKNOWN,	me_unknown },
 };
=20
 #undef dirty
@@ -835,10 +881,10 @@ static struct page_state {
  * "Dirty/Clean" indication is not 100% accurate due to the possibility of
  * setting PG_dirty outside page lock. See also comment above set_page_dir=
ty().
  */
-static void action_result(unsigned long pfn, char *msg, int result)
+static void action_result(unsigned long pfn, int type, int result)
 {
-	pr_err("MCE %#lx: %s page recovery: %s\n",
-		pfn, msg, action_name[result]);
+	pr_err("MCE %#lx: recovery action for %s: %s\n",
+		pfn, action_page_type[type], action_name[result]);
 }
=20
 static int page_action(struct page_state *ps, struct page *p,
@@ -854,11 +900,11 @@ static int page_action(struct page_state *ps, struct =
page *p,
 		count--;
 	if (count !=3D 0) {
 		printk(KERN_ERR
-		       "MCE %#lx: %s page still referenced by %d users\n",
-		       pfn, ps->msg, count);
+		       "MCE %#lx: %s still referenced by %d users\n",
+		       pfn, action_page_type[ps->type], count);
 		result =3D FAILED;
 	}
-	action_result(pfn, ps->msg, result);
+	action_result(pfn, ps->type, result);
=20
 	/* Could do more checks here if page looks ok */
 	/*
@@ -1106,7 +1152,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	if (!(flags & MF_COUNT_INCREASED) &&
 		!get_page_unless_zero(hpage)) {
 		if (is_free_buddy_page(p)) {
-			action_result(pfn, "free buddy", DELAYED);
+			action_result(pfn, BUDDY, DELAYED);
 			return 0;
 		} else if (PageHuge(hpage)) {
 			/*
@@ -1123,12 +1169,12 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 			}
 			set_page_hwpoison_huge_page(hpage);
 			res =3D dequeue_hwpoisoned_huge_page(hpage);
-			action_result(pfn, "free huge",
+			action_result(pfn, FREE_HUGE,
 				      res ? IGNORED : DELAYED);
 			unlock_page(hpage);
 			return res;
 		} else {
-			action_result(pfn, "high order kernel", IGNORED);
+			action_result(pfn, KERNEL_HIGH_ORDER, IGNORED);
 			return -EBUSY;
 		}
 	}
@@ -1150,9 +1196,9 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 			 */
 			if (is_free_buddy_page(p)) {
 				if (flags & MF_COUNT_INCREASED)
-					action_result(pfn, "free buddy", DELAYED);
+					action_result(pfn, BUDDY, DELAYED);
 				else
-					action_result(pfn, "free buddy, 2nd try", DELAYED);
+					action_result(pfn, BUDDY_2ND, DELAYED);
 				return 0;
 			}
 		}
@@ -1165,7 +1211,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * If this happens just bail out.
 	 */
 	if (compound_head(p) !=3D hpage) {
-		action_result(pfn, "different compound page after locking", IGNORED);
+		action_result(pfn, DIFFERENT_COMPOUND, IGNORED);
 		res =3D -EBUSY;
 		goto out;
 	}
@@ -1205,8 +1251,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * on the head page to show that the hugepage is hwpoisoned
 	 */
 	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
-		action_result(pfn, "hugepage already hardware poisoned",
-				IGNORED);
+		action_result(pfn, POISONED_HUGE, IGNORED);
 		unlock_page(hpage);
 		put_page(hpage);
 		return 0;
@@ -1235,7 +1280,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 */
 	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
 	    !=3D SWAP_SUCCESS) {
-		action_result(pfn, "unmapping failed", IGNORED);
+		action_result(pfn, UNMAP_FAILED, IGNORED);
 		res =3D -EBUSY;
 		goto out;
 	}
@@ -1244,7 +1289,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping =3D=3D NULL) {
-		action_result(pfn, "already truncated LRU", IGNORED);
+		action_result(pfn, TRUNCATED_LRU, IGNORED);
 		res =3D -EBUSY;
 		goto out;
 	}
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
