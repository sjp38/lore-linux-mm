Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5E0706B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 10:57:59 -0500 (EST)
Date: Thu, 10 Nov 2011 16:57:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 4/5]thp: correct order in lru list for split huge page
Message-ID: <20111110155727.GA5075@redhat.com>
References: <1319511577.22361.140.camel@sli10-conroe>
 <20111027231928.GB29407@barrios-laptop.redhat.com>
 <1319778538.22361.152.camel@sli10-conroe>
 <20111028072102.GA6268@barrios-laptop.redhat.com>
 <20111110023915.GR5075@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111110023915.GR5075@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

I adjusted comment and removed the isolated lru changes which seem
unnecessary.

I would have preferred > 0, but I thought >= 1 may make it more
explicit it's really not meant to hit on the first page.

====
From: Shaohua Li <shaohua.li@intel.com>
Subject: thp: improve order in lru list for split huge page

Put the tail subpages of an isolated hugepage under splitting in the
lru reclaim head as they supposedly should be isolated too next.

Queues the subpages in physical order in the lru for non isolated
hugepages under splitting. That might provide some theoretical cache
benefit to the buddy allocator later.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    5 ++---
 mm/swap.c        |    2 +-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index fd925d0..e221fbf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1199,7 +1199,6 @@ static int __split_huge_page_splitting(struct page *page,
 static void __split_huge_page_refcount(struct page *page)
 {
 	int i;
-	unsigned long head_index = page->index;
 	struct zone *zone = page_zone(page);
 	int zonestat;
 	int tail_count = 0;
@@ -1208,7 +1207,7 @@ static void __split_huge_page_refcount(struct page *page)
 	spin_lock_irq(&zone->lru_lock);
 	compound_lock(page);
 
-	for (i = 1; i < HPAGE_PMD_NR; i++) {
+	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		struct page *page_tail = page + i;
 
 		/* tail_page->_mapcount cannot change */
@@ -1271,7 +1270,7 @@ static void __split_huge_page_refcount(struct page *page)
 		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
 
-		page_tail->index = ++head_index;
+		page_tail->index = page->index + i;
 
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
diff --git a/mm/swap.c b/mm/swap.c
index a91caf7..f8cfc91 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -684,7 +684,7 @@ void lru_add_page_tail(struct zone* zone,
 		if (likely(PageLRU(page)))
 			head = page->lru.prev;
 		else
-			head = &zone->lru[lru].list;
+			head = zone->lru[lru].list.prev;
 		__add_page_to_lru_list(zone, page_tail, lru, head);
 	} else {
 		SetPageUnevictable(page_tail);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
