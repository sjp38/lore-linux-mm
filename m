Message-ID: <3D61615C.451C2B44@zip.com.au>
Date: Mon, 19 Aug 2002 14:21:32 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: kernel BUG at rmap.c:409! with 2.5.31 and akpm patches.
References: <1029790457.14756.342.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>, Steven Cole <scole@lanl.gov>
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> Here's a new one.
> 
> With this patch applied to 2.5.31,
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.31/stuff-sent-to-linus/everything.gz
> 
> I got this BUG:
> kernel BUG at rmap.c:409!
> while running dbench 40 as a stress test.
> 

OK, ext3's habit of leaving buffers attached to truncated pages
seems to have tripped us up:

	if (page->pte.chain && !page->mapping && !PagePrivate(page)) {
		...
	}

	if (page->pte.chain) {
		switch (try_to_unmap(page)) {

So if the page has a pte_chain, and no ->mapping, but has buffers
we go blam.

 vmscan.c |    5 +++--
 1 files changed, 3 insertions, 2 deletions

--- 2.5.31/mm/vmscan.c~foo	Mon Aug 19 14:20:55 2002
+++ 2.5.31-akpm/mm/vmscan.c	Mon Aug 19 14:21:11 2002
@@ -146,11 +146,13 @@ shrink_list(struct list_head *page_list,
 			rmap_lock = lock_rmap(page);
 		}
 
+		mapping = page->mapping;
+
 		/*
 		 * The page is mapped into the page tables of one or more
 		 * processes. Try to unmap it here.
 		 */
-		if (page->pte.chain) {
+		if (page->pte.chain && mapping) {
 			switch (try_to_unmap(page)) {
 			case SWAP_ERROR:
 			case SWAP_FAIL:
@@ -164,7 +166,6 @@ shrink_list(struct list_head *page_list,
 			}
 		}
 		unlock_rmap(rmap_lock);
-		mapping = page->mapping;
 
 		/*
 		 * FIXME: this is CPU-inefficient for shared mappings.

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
