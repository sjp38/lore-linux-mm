Date: Fri, 27 Feb 2004 21:11:13 -0500 (EST)
From: Anand Eswaran <aeswaran@andrew.cmu.edu>
Subject: Desperate plea 
Message-ID: <Pine.LNX.4.58-035.0402272032450.3342@unix49.andrew.cmu.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: aeswaran@ece.cmu.edu
List-ID: <linux-mm.kvack.org>

Hi :

   Sorry but kernelnewbies seems offline, you're the only source
that can help me !

  Pls be kind enough to respond OR if busy, pls point me out to
some source which answers the question.

Question
--------

   I'm observing the following execution path in page_launder_zone
handling  *anonymous* page in 2.4.18:

1) A page starts out with PageInactiveDirty(page) and page->pte_chain ON
2) After add_to_swap() , PageInactiveDirty(page), page->pte_chain, page->mapping and
PageSwapCache(page) are ON
3) After try_to_unmap(), page->mapping is turned OFF
4) After that, it enters the writepage() function, after which it results
in non-NULL page->buffers
5) kswapd then continues to the next page.

Q1 :
---

When do these buffers formed from anonymous pages
in step 4 get written out to disk? I thought writepage was supposed to
clean the page's buffers, so Im surprised that after the writepage()
page->buffers is non-null.


Q2:
---

 Also, if anonymous pages always result in non-NULL buffers (as in step 4
), in the launder loop:

 if (page->buffers) {
	page_cache_get(page);
	spin_unlock(&pagemap_lru_lock);
        if (try_to_release_page(page,gfp_mask)) {
		if (!page->mapping) {
			...

why is there the need for the "if (!page->mapping)" loop?
Seems like by this stage, anonymous pages already are mapped
to swap_cache?

I know Im missing something. Could someone pls point it out to me?

Thanks a lot!
-----
Anand.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
