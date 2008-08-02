Received: from [172.20.17.31]([172.20.17.31]) (2562 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1KPM55-00017IC@megami.veritas.com>
	for <linux-mm@kvack.org>; Sat, 2 Aug 2008 11:43:55 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Sat, 2 Aug 2008 19:44:08 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: s390's PageSwapCache test
In-Reply-To: <1217694031.22955.14.camel@localhost>
Message-ID: <Pine.LNX.4.64.0808021924450.9727@blonde.site>
References: <Pine.LNX.4.64.0808020944330.1992@blonde.site>
 <1217694031.22955.14.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Aug 2008, Martin Schwidefsky wrote:
> On Sat, 2008-08-02 at 10:05 +0100, Hugh Dickins wrote:
> > I'm slightly bothered by that PageSwapCache() test you've just added
> > in page_remove_rmap(), before s390's page_test_dirty():
> > 
> > 		if ((!PageAnon(page) || PageSwapCache(page)) &&
> > 		    page_test_dirty(page)) {
> > 			page_clear_dirty(page);
> > 			set_page_dirty(page);
> > 		}
> > 
> > It's not wrong; but if it's necessary, then I need to understand why;
> > and if it's unnecessary, then we'd do better to remove it (optimizing
> > your optimization a little).
> ... 
> Hmm, what about the following sequence:
> 1) a page is added to the swap
> 2) the page is dirtied again
> 3) the process forks
> 4) the first process does an mlock
> 5) vmscan succeeds in replacing the pte of the second process with a
> swap entry but fails for the pte of the first process.
> 6) the first process exists.
                       exits
> 
> If the PageSwapCache() check is missing zap_pte_range() will drop the
> last pte for the page but won't transfer the dirty bit.
> Wouldn't that break?

Yes, it took me a while to understand, but you are right.  I was
blinkered, thinking always of page_remove_rmap called by zap_pte_range,
forgetting page_remove_rmap called by try_to_unmap_one i.e. vmscan.

Your example is dealt with on the non-s390 arches by try_to_unmap_one's
	if (pte_dirty(pteval))
		set_page_dirty(page);
but s390 needs something else: and since you can't do it until the
last mapping is removed, you're stuck with detecting the possibility
of this case by testing PageSwapCache in there.

It's a pity that so often it's irrelevant, but I can't offhand think
of a better answer, and it would only be a small optimization to an
already non-optimal path.

Good thinking, Martin, and thank you for enlightening me:
when I'm next in patch mode I'll add a comment there on it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
