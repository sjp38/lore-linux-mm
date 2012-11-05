Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 451956B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 17:40:41 -0500 (EST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3] HWPOISON: fix action_result() to print out dirty/clean (Re: [PATCH 1/2 v2] HWPOISON: fix action_result() to print out) dirty/clean
Date: Mon,  5 Nov 2012 17:40:24 -0500
Message-Id: <1352155224-18649-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121105135628.db79602c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 05, 2012 at 01:56:28PM -0800, Andrew Morton wrote:
> On Fri,  2 Nov 2012 12:33:12 -0400
> Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
>
> > action_result() fails to print out "dirty" even if an error occurred on a
> > dirty pagecache, because when we check PageDirty in action_result() it was
> > cleared after page isolation even if it's dirty before error handling. This
> > can break some applications that monitor this message, so should be fixed.
> >
> > There are several callers of action_result() except page_action(), but
> > either of them are not for LRU pages but for free pages or kernel pages,
> > so we don't have to consider dirty or not for them.
> >
> > Note that PG_dirty can be set outside page locks as described in commit
> > 554940dc8c1e, so this patch does not completely closes the race window,
> > but just narrows it.
>
> I can find no commit 554940dc8c1e.  What commit are you referring to here?

Sorry, I pointed to a wrong ID somehow. Here is one I intended:

  commit 6746aff74da293b5fd24e5c68b870b721e86cd5f
  Author: Wu Fengguang <fengguang.wu@intel.com>
  Date:   Wed Sep 16 11:50:14 2009 +0200

      HWPOISON: shmem: call set_page_dirty() with locked page

Could you replace the previous one with an attached one?

> This is one of the reasons why we ask people to refer to commits by
> both hash and by name, using the form
>
> 078de5f706ece3 ("userns: Store uid and gid values in struct cred with
> kuid_t and kgid_t types")

OK, I'll keep this in my mind.

Naoya

---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 2 Nov 2012 13:44:41 -0400
Subject: [PATCH v3] HWPOISON: fix action_result() to print out dirty/clean

action_result() fails to print out "dirty" even if an error occurred on a
dirty pagecache, because when we check PageDirty in action_result() it was
cleared after page isolation even if it's dirty before error handling. This
can break some applications that monitor this message, so should be fixed.

There are several callers of action_result() except page_action(), but
either of them are not for LRU pages but for free pages or kernel pages,
so we don't have to consider dirty or not for them.

Note that PG_dirty can be set outside page locks as described in commit
6746aff74da29 ("HWPOISON: shmem: call set_page_dirty() with locked page"),
so this patch does not completely closes the race window, but just narrows it.

Changelog v3:
  - fix commit ID in description

Changelog v2:
  - Add comment about setting PG_dirty outside page lock

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
---
 mm/memory-failure.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1abffee..01509aa 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
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
