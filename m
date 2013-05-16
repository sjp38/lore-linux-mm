Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id F06916B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 10:19:34 -0400 (EDT)
Date: Thu, 16 May 2013 15:19:29 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: Remove lru parameter from __pagevec_lru_add and
 remove parts of pagevec API
Message-ID: <20130516141929.GJ11497@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
 <1368440482-27909-5-git-send-email-mgorman@suse.de>
 <20130515155601.370bb7c62a02487b422f7613@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130515155601.370bb7c62a02487b422f7613@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>, Theodore Tso <tytso@mit.edu>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>

On Wed, May 15, 2013 at 03:56:01PM -0700, Andrew Morton wrote:
> On Mon, 13 May 2013 11:21:22 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Now that the LRU to add a page to is decided at LRU-add time, remove the
> > misleading lru parameter from __pagevec_lru_add. A consequence of this is
> > that the pagevec_lru_add_file, pagevec_lru_add_anon and similar helpers
> > are misleading as the caller no longer has direct control over what LRU
> > the page is added to. Unused helpers are removed by this patch and existing
> > users of pagevec_lru_add_file() are converted to use lru_cache_add_file()
> > directly and use the per-cpu pagevecs instead of creating their own pagevec.
> 
> Well maybe.  The `lru' arg to __lru_cache_add is still there and is
> rather misleading (I find it maddening ;)).  AIUI, it's just there as
> the means by which the __lru_cache_add() caller tells the LRU manager
> that the caller wishes this page to start life on the active LRU, yes? 
> It doesn't _really_ specify an LRU list at all.
> 

Correct. This?

---8<---
mm: Remove lru parameter from __lru_cache_add and lru_cache_add_lru

Similar to __pagevec_lru_add, this patch removes the LRU parameter
from __lru_cache_add and lru_cache_add_lru as the caller does not
control the exact LRU the page gets added to. Instead, require that
the caller set or clear PageActive depending on whether it should
be added to the active or inactive list.

[akpm@linux-foundation.org: Suggested the patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/swap.h | 11 +++++++----
 mm/rmap.c            |  7 ++++---
 mm/swap.c            | 14 ++++----------
 mm/vmscan.c          |  4 +---
 4 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 1701ce4..85d7437 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -10,6 +10,7 @@
 #include <linux/node.h>
 #include <linux/fs.h>
 #include <linux/atomic.h>
+#include <linux/page-flags.h>
 #include <asm/page.h>
 
 struct notifier_block;
@@ -233,8 +234,8 @@ extern unsigned long nr_free_pagecache_pages(void);
 
 
 /* linux/mm/swap.c */
-extern void __lru_cache_add(struct page *, enum lru_list lru);
-extern void lru_cache_add_lru(struct page *, enum lru_list lru);
+extern void __lru_cache_add(struct page *);
+extern void lru_cache_add(struct page *);
 extern void lru_add_page_tail(struct page *page, struct page *page_tail,
 			 struct lruvec *lruvec, struct list_head *head);
 extern void activate_page(struct page *);
@@ -254,12 +255,14 @@ extern void add_page_to_unevictable_list(struct page *page);
  */
 static inline void lru_cache_add_anon(struct page *page)
 {
-	__lru_cache_add(page, LRU_INACTIVE_ANON);
+	ClearPageActive(page);
+	__lru_cache_add(page);
 }
 
 static inline void lru_cache_add_file(struct page *page)
 {
-	__lru_cache_add(page, LRU_INACTIVE_FILE);
+	ClearPageActive(page);
+	__lru_cache_add(page);
 }
 
 /* linux/mm/vmscan.c */
diff --git a/mm/rmap.c b/mm/rmap.c
index 6280da8..e22ceeb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1093,9 +1093,10 @@ void page_add_new_anon_rmap(struct page *page,
 	else
 		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
 	__page_set_anon_rmap(page, vma, address, 1);
-	if (!mlocked_vma_newpage(vma, page))
-		lru_cache_add_lru(page, LRU_ACTIVE_ANON);
-	else
+	if (!mlocked_vma_newpage(vma, page)) {
+		SetPageActive(page);
+		lru_cache_add(page);
+	} else
 		add_page_to_unevictable_list(page);
 }
 
diff --git a/mm/swap.c b/mm/swap.c
index b8a9000..05944d4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -496,15 +496,10 @@ EXPORT_SYMBOL(mark_page_accessed);
  * pages that are on the LRU, linear writes in subpage chunks would see
  * every PAGEVEC_SIZE page activated, which is unexpected.
  */
-void __lru_cache_add(struct page *page, enum lru_list lru)
+void __lru_cache_add(struct page *page)
 {
 	struct pagevec *pvec = &get_cpu_var(lru_add_pvec);
 
-	if (is_active_lru(lru))
-		SetPageActive(page);
-	else
-		ClearPageActive(page);
-
 	page_cache_get(page);
 	if (!pagevec_space(pvec))
 		__pagevec_lru_add(pvec);
@@ -514,11 +509,10 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
 EXPORT_SYMBOL(__lru_cache_add);
 
 /**
- * lru_cache_add_lru - add a page to a page list
+ * lru_cache_add - add a page to a page list
  * @page: the page to be added to the LRU.
- * @lru: the LRU list to which the page is added.
  */
-void lru_cache_add_lru(struct page *page, enum lru_list lru)
+void lru_cache_add(struct page *page)
 {
 	if (PageActive(page)) {
 		VM_BUG_ON(PageUnevictable(page));
@@ -527,7 +521,7 @@ void lru_cache_add_lru(struct page *page, enum lru_list lru)
 	}
 
 	VM_BUG_ON(PageLRU(page));
-	__lru_cache_add(page, lru);
+	__lru_cache_add(page);
 }
 
 /**
diff --git a/mm/vmscan.c b/mm/vmscan.c
index fa6a853..50088ba 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -546,7 +546,6 @@ int remove_mapping(struct address_space *mapping, struct page *page)
 void putback_lru_page(struct page *page)
 {
 	int lru;
-	int active = !!TestClearPageActive(page);
 	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
@@ -561,8 +560,7 @@ redo:
 		 * unevictable page on [in]active list.
 		 * We know how to handle that.
 		 */
-		lru = active + page_lru_base_type(page);
-		lru_cache_add_lru(page, lru);
+		lru_cache_add(page);
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
