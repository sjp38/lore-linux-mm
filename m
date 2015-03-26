Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id BA4F56B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 21:00:39 -0400 (EDT)
Received: by oier21 with SMTP id r21so36979146oie.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 18:00:39 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id go5si2704459obb.32.2015.03.25.18.00.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 25 Mar 2015 18:00:38 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] mm/memory-failure.c: define page types for
 action_result() in one place
Date: Thu, 26 Mar 2015 00:58:27 +0000
Message-ID: <1427331500-5453-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, Xie XiuQi <xiexiuqi@huawei.com>, Steven Rostedt <rostedt@goodmis.org>, Chen Gong <gong.chen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This cleanup patch moves all strings passed to action_result() into a singl=
e
array action_page_type so that a reader can easily find which kind of actio=
n
results are possible. And this patch also fixes the odd lines to be printed
out, like "unknown page state page" or "free buddy, 2nd try page".

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
---
ChangeLog v1 -> v2:
- fix DIRTY_UNEVICTABLE_LRU typo
- adding "MSG_" prefix to each enum value
- use declaration with type "enum page_type" instead of int
- define action_type_type as "static const char * const" (not "static const=
 char *")
---
 mm/memory-failure.c | 108 +++++++++++++++++++++++++++++++++++++-----------=
----
 1 file changed, 77 insertions(+), 31 deletions(-)

diff --git v4.0-rc4.orig/mm/memory-failure.c v4.0-rc4/mm/memory-failure.c
index 181850a760ea..8c8c9ed0dcdf 100644
--- v4.0-rc4.orig/mm/memory-failure.c
+++ v4.0-rc4/mm/memory-failure.c
@@ -523,6 +523,52 @@ static const char *action_name[] =3D {
 	[RECOVERED] =3D "Recovered",
 };
=20
+enum page_type {
+	MSG_KERNEL,
+	MSG_KERNEL_HIGH_ORDER,
+	MSG_SLAB,
+	MSG_DIFFERENT_COMPOUND,
+	MSG_POISONED_HUGE,
+	MSG_HUGE,
+	MSG_FREE_HUGE,
+	MSG_UNMAP_FAILED,
+	MSG_DIRTY_SWAPCACHE,
+	MSG_CLEAN_SWAPCACHE,
+	MSG_DIRTY_MLOCKED_LRU,
+	MSG_CLEAN_MLOCKED_LRU,
+	MSG_DIRTY_UNEVICTABLE_LRU,
+	MSG_CLEAN_UNEVICTABLE_LRU,
+	MSG_DIRTY_LRU,
+	MSG_CLEAN_LRU,
+	MSG_TRUNCATED_LRU,
+	MSG_BUDDY,
+	MSG_BUDDY_2ND,
+	MSG_UNKNOWN,
+};
+
+static const char * const action_page_type[] =3D {
+	[MSG_KERNEL]			=3D "reserved kernel page",
+	[MSG_KERNEL_HIGH_ORDER]		=3D "high-order kernel page",
+	[MSG_SLAB]			=3D "kernel slab page",
+	[MSG_DIFFERENT_COMPOUND]	=3D "different compound page after locking",
+	[MSG_POISONED_HUGE]		=3D "huge page already hardware poisoned",
+	[MSG_HUGE]			=3D "huge page",
+	[MSG_FREE_HUGE]			=3D "free huge page",
+	[MSG_UNMAP_FAILED]		=3D "unmapping failed page",
+	[MSG_DIRTY_SWAPCACHE]		=3D "dirty swapcache page",
+	[MSG_CLEAN_SWAPCACHE]		=3D "clean swapcache page",
+	[MSG_DIRTY_MLOCKED_LRU]		=3D "dirty mlocked LRU page",
+	[MSG_CLEAN_MLOCKED_LRU]		=3D "clean mlocked LRU page",
+	[MSG_DIRTY_UNEVICTABLE_LRU]	=3D "dirty unevictable LRU page",
+	[MSG_CLEAN_UNEVICTABLE_LRU]	=3D "clean unevictable LRU page",
+	[MSG_DIRTY_LRU]			=3D "dirty LRU page",
+	[MSG_CLEAN_LRU]			=3D "clean LRU page",
+	[MSG_TRUNCATED_LRU]		=3D "already truncated LRU page",
+	[MSG_BUDDY]			=3D "free buddy page",
+	[MSG_BUDDY_2ND]			=3D "free buddy page (2nd try)",
+	[MSG_UNKNOWN]			=3D "unknown page",
+};
+
 /*
  * XXX: It is possible that a page is isolated from LRU cache,
  * and then kept in swap cache or failed to remove from page cache.
@@ -779,10 +825,10 @@ static int me_huge_page(struct page *p, unsigned long=
 pfn)
 static struct page_state {
 	unsigned long mask;
 	unsigned long res;
-	char *msg;
+	enum page_type type;
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] =3D {
-	{ reserved,	reserved,	"reserved kernel",	me_kernel },
+	{ reserved,	reserved,	MSG_KERNEL,	me_kernel },
 	/*
 	 * free pages are specially detected outside this table:
 	 * PG_buddy pages only make a small fraction of all free pages.
@@ -793,31 +839,31 @@ static struct page_state {
 	 * currently unused objects without touching them. But just
 	 * treat it as standard kernel for now.
 	 */
-	{ slab,		slab,		"kernel slab",	me_kernel },
+	{ slab,		slab,		MSG_SLAB,	me_kernel },
=20
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
-	{ head,		head,		"huge",		me_huge_page },
-	{ tail,		tail,		"huge",		me_huge_page },
+	{ head,		head,		MSG_HUGE,		me_huge_page },
+	{ tail,		tail,		MSG_HUGE,		me_huge_page },
 #else
-	{ compound,	compound,	"huge",		me_huge_page },
+	{ compound,	compound,	MSG_HUGE,		me_huge_page },
 #endif
=20
-	{ sc|dirty,	sc|dirty,	"dirty swapcache",	me_swapcache_dirty },
-	{ sc|dirty,	sc,		"clean swapcache",	me_swapcache_clean },
+	{ sc|dirty,	sc|dirty,	MSG_DIRTY_SWAPCACHE,	me_swapcache_dirty },
+	{ sc|dirty,	sc,		MSG_CLEAN_SWAPCACHE,	me_swapcache_clean },
=20
-	{ mlock|dirty,	mlock|dirty,	"dirty mlocked LRU",	me_pagecache_dirty },
-	{ mlock|dirty,	mlock,		"clean mlocked LRU",	me_pagecache_clean },
+	{ mlock|dirty,	mlock|dirty,	MSG_DIRTY_MLOCKED_LRU,	me_pagecache_dirty },
+	{ mlock|dirty,	mlock,		MSG_CLEAN_MLOCKED_LRU,	me_pagecache_clean },
=20
-	{ unevict|dirty, unevict|dirty,	"dirty unevictable LRU", me_pagecache_dir=
ty },
-	{ unevict|dirty, unevict,	"clean unevictable LRU", me_pagecache_clean },
+	{ unevict|dirty, unevict|dirty,	MSG_DIRTY_UNEVICTABLE_LRU,	me_pagecache_d=
irty },
+	{ unevict|dirty, unevict,	MSG_CLEAN_UNEVICTABLE_LRU,	me_pagecache_clean }=
,
=20
-	{ lru|dirty,	lru|dirty,	"dirty LRU",	me_pagecache_dirty },
-	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
+	{ lru|dirty,	lru|dirty,	MSG_DIRTY_LRU,	me_pagecache_dirty },
+	{ lru|dirty,	lru,		MSG_CLEAN_LRU,	me_pagecache_clean },
=20
 	/*
 	 * Catchall entry: must be at end.
 	 */
-	{ 0,		0,		"unknown page state",	me_unknown },
+	{ 0,		0,		MSG_UNKNOWN,	me_unknown },
 };
=20
 #undef dirty
@@ -837,10 +883,10 @@ static struct page_state {
  * "Dirty/Clean" indication is not 100% accurate due to the possibility of
  * setting PG_dirty outside page lock. See also comment above set_page_dir=
ty().
  */
-static void action_result(unsigned long pfn, char *msg, int result)
+static void action_result(unsigned long pfn, enum page_type type, int resu=
lt)
 {
-	pr_err("MCE %#lx: %s page recovery: %s\n",
-		pfn, msg, action_name[result]);
+	pr_err("MCE %#lx: recovery action for %s: %s\n",
+		pfn, action_page_type[type], action_name[result]);
 }
=20
 static int page_action(struct page_state *ps, struct page *p,
@@ -856,11 +902,11 @@ static int page_action(struct page_state *ps, struct =
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
@@ -1109,7 +1155,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	if (!(flags & MF_COUNT_INCREASED) &&
 		!get_page_unless_zero(hpage)) {
 		if (is_free_buddy_page(p)) {
-			action_result(pfn, "free buddy", DELAYED);
+			action_result(pfn, MSG_BUDDY, DELAYED);
 			return 0;
 		} else if (PageHuge(hpage)) {
 			/*
@@ -1126,12 +1172,12 @@ int memory_failure(unsigned long pfn, int trapno, i=
nt flags)
 			}
 			set_page_hwpoison_huge_page(hpage);
 			res =3D dequeue_hwpoisoned_huge_page(hpage);
-			action_result(pfn, "free huge",
+			action_result(pfn, MSG_FREE_HUGE,
 				      res ? IGNORED : DELAYED);
 			unlock_page(hpage);
 			return res;
 		} else {
-			action_result(pfn, "high order kernel", IGNORED);
+			action_result(pfn, MSG_KERNEL_HIGH_ORDER, IGNORED);
 			return -EBUSY;
 		}
 	}
@@ -1153,9 +1199,10 @@ int memory_failure(unsigned long pfn, int trapno, in=
t flags)
 			 */
 			if (is_free_buddy_page(p)) {
 				if (flags & MF_COUNT_INCREASED)
-					action_result(pfn, "free buddy", DELAYED);
+					action_result(pfn, MSG_BUDDY, DELAYED);
 				else
-					action_result(pfn, "free buddy, 2nd try", DELAYED);
+					action_result(pfn, MSG_BUDDY_2ND,
+						      DELAYED);
 				return 0;
 			}
 		}
@@ -1168,7 +1215,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * If this happens just bail out.
 	 */
 	if (compound_head(p) !=3D hpage) {
-		action_result(pfn, "different compound page after locking", IGNORED);
+		action_result(pfn, MSG_DIFFERENT_COMPOUND, IGNORED);
 		res =3D -EBUSY;
 		goto out;
 	}
@@ -1208,8 +1255,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * on the head page to show that the hugepage is hwpoisoned
 	 */
 	if (PageHuge(p) && PageTail(p) && TestSetPageHWPoison(hpage)) {
-		action_result(pfn, "hugepage already hardware poisoned",
-				IGNORED);
+		action_result(pfn, MSG_POISONED_HUGE, IGNORED);
 		unlock_page(hpage);
 		put_page(hpage);
 		return 0;
@@ -1238,7 +1284,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 */
 	if (hwpoison_user_mappings(p, pfn, trapno, flags, &hpage)
 	    !=3D SWAP_SUCCESS) {
-		action_result(pfn, "unmapping failed", IGNORED);
+		action_result(pfn, MSG_UNMAP_FAILED, IGNORED);
 		res =3D -EBUSY;
 		goto out;
 	}
@@ -1247,7 +1293,7 @@ int memory_failure(unsigned long pfn, int trapno, int=
 flags)
 	 * Torn down by someone else?
 	 */
 	if (PageLRU(p) && !PageSwapCache(p) && p->mapping =3D=3D NULL) {
-		action_result(pfn, "already truncated LRU", IGNORED);
+		action_result(pfn, MSG_TRUNCATED_LRU, IGNORED);
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
