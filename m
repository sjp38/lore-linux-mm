From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16417.8644.203682.640759@laputa.namesys.com>
Date: Wed, 4 Feb 2004 19:45:56 +0300
Subject: Re: [PATCH 3/5] mm improvements
In-Reply-To: <Pine.LNX.4.44.0402041027380.24515-100000@chimarrao.boston.redhat.com>
References: <4020BE45.10007@cyberone.com.au>
	<Pine.LNX.4.44.0402041027380.24515-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel writes:
 > On Wed, 4 Feb 2004, Nick Piggin wrote:
 > > Nick Piggin wrote:
 > > 
 > > > 3/5: vm-lru-info.patch
 > > >     Keep more referenced info in the active list. Should also improve
 > > >     system time in some cases. Helps swapping loads significantly.
 > 
 > I suspect this is one of the more important ones in this
 > batch of patches...

I don't understand how this works. This patch just parks mapped pages on
the "ignored" segment of the active list, where they rest until
reclaim_mapped mode is entered.

This only makes a difference for the pages that were page_referenced():

1. they are moved to the ignored segment rather than to the head of the
active list.

2. their referenced bit is not cleared

Now, as "ignored" segment is not scanned in !reclaim_mode, (2) would
only make a difference when VM rapidly oscillates between reclaim_mapped
and !reclaim_mapped, because after a long period of !reclaim_mapped
operation preserved referenced bit on a page only means "this page has
been referenced in the past, but not necessary recently".

And if (1) affects performance significantly, that something rotten in
the idea of treating mapped pages preferentially by the replacement, and
the same effect can be achieved by simply increasing vm_swappiness.

Nick, can you test what will be an effect of doing something like

	while (!list_empty(&l_hold)) {
		page = lru_to_page(&l_hold);
		list_del(&page->lru);
		if (page_mapped(page)) {
			int referenced;

			referenced = page_referenced(page);
			if (!reclaim_mapped) {
				list_add(&page->lru, &l_ignore);
				continue;
			}
			pte_chain_lock(page);
			if (page_mapped(page) && referenced) {
				pte_chain_unlock(page);
				list_add(&page->lru, &l_active);
				continue;
			}
			pte_chain_unlock(page);
		}
		...

i.e., by cleaning the referenced bit before moving page to the l_ignore?

 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
