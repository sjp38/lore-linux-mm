Date: Thu, 20 Nov 2008 01:20:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 5/7] mm: replace some BUG_ONs by VM_BUG_ONs
In-Reply-To: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
Message-ID: <Pine.LNX.4.64.0811200117370.19216@blonde.site>
References: <Pine.LNX.4.64.0811200108230.19216@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The swap code is over-provisioned with BUG_ONs on assorted page flags,
mostly dating back to 2.3.  They're good documentation, and guard against
developer error, but a waste of space on most systems: change them to
VM_BUG_ONs, conditional on CONFIG_DEBUG_VM.  Just delete the PagePrivate
ones: they're later, from 2.5.69, but even less interesting now.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
Could be taken further: this now looks like a random selection
which caught my eye at some point working in these files.

This patch clashes trivially in __delete_from_swap_cache with
memcg-memswap-controller-core.patch, which I'm assuming comes
later: sorry, but you'll have no difficulty in fixing it up.

 mm/page_io.c    |    4 ++--
 mm/swap_state.c |   19 +++++++++----------
 mm/swapfile.c   |    8 +++-----
 3 files changed, 14 insertions(+), 17 deletions(-)

--- mmclean4/mm/page_io.c	2008-04-17 03:49:44.000000000 +0100
+++ mmclean5/mm/page_io.c	2008-11-19 15:26:26.000000000 +0000
@@ -125,8 +125,8 @@ int swap_readpage(struct file *file, str
 	struct bio *bio;
 	int ret = 0;
 
-	BUG_ON(!PageLocked(page));
-	BUG_ON(PageUptodate(page));
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageUptodate(page));
 	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
 				end_swap_bio_read);
 	if (bio == NULL) {
--- mmclean4/mm/swap_state.c	2008-10-24 09:28:26.000000000 +0100
+++ mmclean5/mm/swap_state.c	2008-11-19 15:26:26.000000000 +0000
@@ -72,10 +72,10 @@ int add_to_swap_cache(struct page *page,
 {
 	int error;
 
-	BUG_ON(!PageLocked(page));
-	BUG_ON(PageSwapCache(page));
-	BUG_ON(PagePrivate(page));
-	BUG_ON(!PageSwapBacked(page));
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(PageSwapCache(page));
+	VM_BUG_ON(!PageSwapBacked(page));
+
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
 		page_cache_get(page);
@@ -108,10 +108,9 @@ int add_to_swap_cache(struct page *page,
  */
 void __delete_from_swap_cache(struct page *page)
 {
-	BUG_ON(!PageLocked(page));
-	BUG_ON(!PageSwapCache(page));
-	BUG_ON(PageWriteback(page));
-	BUG_ON(PagePrivate(page));
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapCache(page));
+	VM_BUG_ON(PageWriteback(page));
 
 	radix_tree_delete(&swapper_space.page_tree, page_private(page));
 	set_page_private(page, 0);
@@ -134,8 +133,8 @@ int add_to_swap(struct page * page, gfp_
 	swp_entry_t entry;
 	int err;
 
-	BUG_ON(!PageLocked(page));
-	BUG_ON(!PageUptodate(page));
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageUptodate(page));
 
 	for (;;) {
 		entry = get_swap_page();
--- mmclean4/mm/swapfile.c	2008-10-24 09:28:26.000000000 +0100
+++ mmclean5/mm/swapfile.c	2008-11-19 15:26:26.000000000 +0000
@@ -333,7 +333,7 @@ int can_share_swap_page(struct page *pag
 {
 	int count;
 
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageLocked(page));
 	count = page_mapcount(page);
 	if (count <= 1 && PageSwapCache(page))
 		count += page_swapcount(page);
@@ -350,8 +350,7 @@ static int remove_exclusive_swap_page_co
 	struct swap_info_struct * p;
 	swp_entry_t entry;
 
-	BUG_ON(PagePrivate(page));
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageLocked(page));
 
 	if (!PageSwapCache(page))
 		return 0;
@@ -432,7 +431,6 @@ void free_swap_and_cache(swp_entry_t ent
 	if (page) {
 		int one_user;
 
-		BUG_ON(PagePrivate(page));
 		one_user = (page_count(page) == 2);
 		/* Only cache user (+us), or swap space full? Free it! */
 		/* Also recheck PageSwapCache after page is locked (above) */
@@ -1209,7 +1207,7 @@ int page_queue_congested(struct page *pa
 {
 	struct backing_dev_info *bdi;
 
-	BUG_ON(!PageLocked(page));	/* It pins the swap_info_struct */
+	VM_BUG_ON(!PageLocked(page));	/* It pins the swap_info_struct */
 
 	if (PageSwapCache(page)) {
 		swp_entry_t entry = { .val = page_private(page) };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
