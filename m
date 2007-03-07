Date: Wed, 7 Mar 2007 13:02:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 8/6] mm: fix cpdfio vs fault race
Message-Id: <20070307130214.56d4b03b.akpm@linux-foundation.org>
In-Reply-To: <20070307113121.GA18704@wotan.suse.de>
References: <20070307110429.GF5555@wotan.suse.de>
	<20070307032038.f08333a8.akpm@linux-foundation.org>
	<20070307113121.GA18704@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: miklos@szeredi.hu, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2007 12:31:21 +0100
Nick Piggin <npiggin@suse.de> wrote:

> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -1664,6 +1664,15 @@ gotten:
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  	if (dirty_page) {
> +		/*
> +		 * Yes, Virginia, this is actually required to prevent a race
> +		 * with clear_page_dirty_for_io() from clearing the page dirty
> +		 * bit after it clear all dirty ptes, but before a racing
> +		 * do_wp_page installs a dirty pte.
> +		 *
> +		 * do_no_page is protected similarly.
> +		 */
> +		wait_on_page_locked(dirty_page);
>  		set_page_dirty_balance(dirty_page);
>  		put_page(dirty_page);
>  	}
> @@ -2316,6 +2325,7 @@ retry:
>  unlock:
>  	pte_unmap_unlock(page_table, ptl);
>  	if (dirty_page) {
> +		wait_on_page_locked(dirty_page);
>  		set_page_dirty_balance(dirty_page);
>  		put_page(dirty_page);
>  	}
> Index: linux-2.6/mm/page-writeback.c

now that's scary - applying this on top of your
lock-the-page-in-the-fault-handler patches gives:

	if (dirty_page) {
		/*
		 * Yes, Virginia, this is actually required to prevent a race
		 * with clear_page_dirty_for_io() from clearing the page dirty
		 * bit after it clear all dirty ptes, but before a racing
		 * do_wp_page installs a dirty pte.
		 *
		 * do_no_page is protected similarly.
		 */
		wait_on_page_locked(dirty_page);
		wait_on_page_locked(dirty_page);
		set_page_dirty_balance(dirty_page);
		put_page(dirty_page);
	}

One wonders how on earth patch(1) managed to do that.  If it has inserted
the comment twice as well then it might be explicable..



Oh well, let's try this:

From: Nick Piggin <npiggin@suse.de>

Fix msync data loss and (less importantly) dirty page accounting
inaccuracies due to the race remaining in clear_page_dirty_for_io().

The deleted comment explains what the race was, and the added comments
explain how it is fixed.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/memory.c         |    9 +++++++++
 mm/page-writeback.c |   17 ++++++++++++-----
 2 files changed, 21 insertions(+), 5 deletions(-)

diff -puN mm/memory.c~mm-fix-cpdfio-vs-fault-race mm/memory.c
--- a/mm/memory.c~mm-fix-cpdfio-vs-fault-race
+++ a/mm/memory.c
@@ -1669,6 +1669,15 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		/*
+		 * Yes, Virginia, this is actually required to prevent a race
+		 * with clear_page_dirty_for_io() from clearing the page dirty
+		 * bit after it clear all dirty ptes, but before a racing
+		 * do_wp_page installs a dirty pte.
+		 *
+		 * do_no_page is protected similarly.
+		 */
+		wait_on_page_locked(dirty_page);
 		set_page_dirty_balance(dirty_page);
 		put_page(dirty_page);
 	}
diff -puN mm/page-writeback.c~mm-fix-cpdfio-vs-fault-race mm/page-writeback.c
--- a/mm/page-writeback.c~mm-fix-cpdfio-vs-fault-race
+++ a/mm/page-writeback.c
@@ -903,6 +903,8 @@ int clear_page_dirty_for_io(struct page 
 {
 	struct address_space *mapping = page_mapping(page);
 
+	BUG_ON(!PageLocked(page));
+
 	if (mapping && mapping_cap_account_dirty(mapping)) {
 		/*
 		 * Yes, Virginia, this is indeed insane.
@@ -928,14 +930,19 @@ int clear_page_dirty_for_io(struct page 
 		 * We basically use the page "master dirty bit"
 		 * as a serialization point for all the different
 		 * threads doing their things.
-		 *
-		 * FIXME! We still have a race here: if somebody
-		 * adds the page back to the page tables in
-		 * between the "page_mkclean()" and the "TestClearPageDirty()",
-		 * we might have it mapped without the dirty bit set.
 		 */
 		if (page_mkclean(page))
 			set_page_dirty(page);
+		/*
+		 * We carefully synchronise fault handlers against
+		 * installing a dirty pte and marking the page dirty
+		 * at this point. We do this by having them hold the
+		 * page lock at some point after installing their
+		 * pte, but before marking the page dirty.
+		 * Pages are always locked coming in here, so we get
+		 * the desired exclusion. See mm/memory.c:do_wp_page()
+		 * for more comments.
+		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			return 1;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
