Message-ID: <402240FB.7070801@cyberone.com.au>
Date: Fri, 06 Feb 2004 00:11:23 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] RSS limit enforcement for 2.6
References: <Pine.LNX.4.44.0401271248580.23718-100000@chimarrao.boston.redhat.com> <20040204231840.67cbb388.akpm@osdl.org>
In-Reply-To: <20040204231840.67cbb388.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rik van Riel <riel@redhat.com>, pavel@ucw.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

Snip [RSS not effective]

>
>Note that there is still a problem in refill_inactive_zone():
>
>		if (page_mapped(page)) {
>
>			/*
>			 * Don't clear page referenced if we're not going
>			 * to use it.
>			 */
>			if (!reclaim_mapped && !over_rsslimit) {
>				list_add(&page->lru, &l_ignore);
>				continue;
>			}
>
>			/*
>			 * probably it would be useful to transfer dirty bit
>			 * from pte to the @page here.
>			 */
>			pte_chain_lock(page);
>			if (page_mapped(page) &&
>					page_referenced(page, &over_rsslimit) &&
>					!over_rsslimit) {
>				pte_chain_unlock(page);
>				list_add(&page->lru, &l_active);
>				continue;
>			}
>			pte_chain_unlock(page);
>		}
>
>That first test of over_rsslimit is kinda bogus: we haven't run
>

Probably why it isn't reclaiming your mapped pages

>page_referenced() yet!  But the recent change of moving that little chunk
>of code to before the page_referenced() check was correct.
>
>So to get this right, we may need to split the over-limit stuff apart from
>the page_referenced() processing.
>
>

This is one thing I was worried about with my change, and I
thought the same thing.

Have a function to check rss limit and could also move
referenced bits to the page's flags, then page_referenced could
just return TestClearPageReferenced.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
