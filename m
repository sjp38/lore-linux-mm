Date: Fri, 15 Oct 2004 15:35:56 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] use find_trylock_page in free_swap_and_cache instead of hand coding
Message-ID: <20041015183556.GB4937@logos.cnet>
References: <20041015104502.GA1989@logos.cnet> <Pine.LNX.4.44.0410151411330.5770-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410151411330.5770-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 15, 2004 at 02:20:08PM +0100, Hugh Dickins wrote:
> On Fri, 15 Oct 2004, Marcelo Tosatti wrote:
> > 
> > This small cleanup to free_swap_and_cache() substitues a 
> > "lock - radix lookup - TestSetPageLocked - unlock" sequence
> > of instructions with "find_trylock_page()" (which does 
> > exactly that).
> 
> You're right: I must have been so excited by distinguishing the swapcache
> from the pagecache, that I was blind to how that was still applicable
> (unlike inserting and removing).
> 
> But please extend your patch to mm/swap_state.c, where you can get rid
> of the two radix_tree_lookups by reverting to find_get_page - thanks!

Hugh,

Here it is. Can you please review an Acked-by?

That raises a question in my mind: The swapper space statistics
are not protected by anything.

Two processors can write to it at the same time - I can imagine
we lose a increment (two CPUs increasing at the same time), but
what else can happen to the statistics due to the lack of locking?

Not that its critical data, just curiosity.

Andrew, please apply to -mm.

Description:
Use find_*_page helpers in swap code instead handcoding it.

Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

--- rc4-mm1.orig/mm/swapfile.c	2004-10-15 01:03:11.000000000 -0300
+++ rc4-mm1/mm/swapfile.c	2004-10-15 09:24:05.696640488 -0300
@@ -391,14 +391,8 @@ void free_swap_and_cache(swp_entry_t ent
 
 	p = swap_info_get(entry);
 	if (p) {
-		if (swap_entry_free(p, swp_offset(entry)) == 1) {
-			read_lock_irq(&swapper_space.tree_lock);
-			page = radix_tree_lookup(&swapper_space.page_tree,
-				entry.val);
-			if (page && TestSetPageLocked(page))
-				page = NULL;
-			read_unlock_irq(&swapper_space.tree_lock);
-		}
+		if (swap_entry_free(p, swp_offset(entry)) == 1) 
+			page = find_trylock_page(&swapper_space, entry.val);
 		swap_info_put(p);
 	}
 	if (page) {
--- rc4-mm1.orig/mm/swap_state.c	2004-10-15 01:03:11.000000000 -0300
+++ rc4-mm1/mm/swap_state.c	2004-10-15 17:04:58.032995848 -0300
@@ -313,13 +313,11 @@ struct page * lookup_swap_cache(swp_entr
 {
 	struct page *page;
 
-	read_lock_irq(&swapper_space.tree_lock);
-	page = radix_tree_lookup(&swapper_space.page_tree, entry.val);
-	if (page) {
-		page_cache_get(page);
+	page = find_get_page(&swapper_space, entry.val);
+
+	if (page) 
 		INC_CACHE_INFO(find_success);
-	}
-	read_unlock_irq(&swapper_space.tree_lock);
+
 	INC_CACHE_INFO(find_total);
 	return page;
 }
@@ -342,12 +340,7 @@ struct page *read_swap_cache_async(swp_e
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		read_lock_irq(&swapper_space.tree_lock);
-		found_page = radix_tree_lookup(&swapper_space.page_tree,
-						entry.val);
-		if (found_page)
-			page_cache_get(found_page);
-		read_unlock_irq(&swapper_space.tree_lock);
+		found_page = find_get_page(&swapper_space, entry.val);
 		if (found_page)
 			break;
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
