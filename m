Date: Mon, 29 Mar 2004 12:40:27 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap
 complexity fix
Message-Id: <20040329124027.36335d93.akpm@osdl.org>
In-Reply-To: <20040329180109.GW3808@dualathlon.random>
References: <Pine.LNX.4.44.0403150527400.28579-100000@localhost.localdomain>
	<Pine.GSO.4.58.0403211634350.10248@azure.engin.umich.edu>
	<20040325225919.GL20019@dualathlon.random>
	<Pine.GSO.4.58.0403252258170.4298@azure.engin.umich.edu>
	<20040326075343.GB12484@dualathlon.random>
	<Pine.LNX.4.58.0403261013480.672@ruby.engin.umich.edu>
	<20040326175842.GC9604@dualathlon.random>
	<Pine.GSO.4.58.0403271448120.28539@sapphire.engin.umich.edu>
	<20040329172248.GR3808@dualathlon.random>
	<Pine.GSO.4.58.0403291240040.14450@eecs2340u20.engin.umich.edu>
	<20040329180109.GW3808@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> There's now also a screwup in the writeback -mm changes for swapsuspend,
> it bugs out in radix tree tag, I believe it's because it doesn't
> insert the page in the radix tree before doing writeback I/O on it.

hmm, yes, we have pages which satisfy PageSwapCache(), but which are not
actually in swapcache.

How about we use the normal pagecache APIs for this?

(untested):

--- 25/mm/page_io.c~rw_swap_page_sync-fix	Mon Mar 29 12:34:24 2004
+++ 25-akpm/mm/page_io.c	Mon Mar 29 12:37:13 2004
@@ -139,7 +139,7 @@ struct address_space_operations swap_aop
 
 /*
  * A scruffy utility function to read or write an arbitrary swap page
- * and wait on the I/O.
+ * and wait on the I/O.  The caller must have a ref on the page.
  */
 int rw_swap_page_sync(int rw, swp_entry_t entry, struct page *page)
 {
@@ -151,8 +151,7 @@ int rw_swap_page_sync(int rw, swp_entry_
 	lock_page(page);
 
 	BUG_ON(page->mapping);
-	page->mapping = &swapper_space;
-	page->index = entry.val;
+	add_to_page_cache(page, &swapper_space, entry.val, GFP_NOIO);
 
 	if (rw == READ) {
 		ret = swap_readpage(NULL, page);
@@ -161,7 +160,11 @@ int rw_swap_page_sync(int rw, swp_entry_
 		ret = swap_writepage(page, &swap_wbc);
 		wait_on_page_writeback(page);
 	}
-	page->mapping = NULL;
+
+	lock_page(page);
+	remove_from_page_cache(page);
+	unlock_page(page);
+
 	if (ret == 0 && (!PageUptodate(page) || PageError(page)))
 		ret = -EIO;
 	return ret;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
