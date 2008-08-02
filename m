Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m72GKZs3273088
	for <linux-mm@kvack.org>; Sat, 2 Aug 2008 16:20:35 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m72GKZ2w4030712
	for <linux-mm@kvack.org>; Sat, 2 Aug 2008 18:20:35 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m72GKZRw008307
	for <linux-mm@kvack.org>; Sat, 2 Aug 2008 18:20:35 +0200
Subject: Re: s390's PageSwapCache test
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <Pine.LNX.4.64.0808020944330.1992@blonde.site>
References: <Pine.LNX.4.64.0808020944330.1992@blonde.site>
Content-Type: text/plain
Date: Sat, 02 Aug 2008 18:20:31 +0200
Message-Id: <1217694031.22955.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hugh,

On Sat, 2008-08-02 at 10:05 +0100, Hugh Dickins wrote:
> I'm slightly bothered by that PageSwapCache() test you've just added
> in page_remove_rmap(), before s390's page_test_dirty():
> 
> 		if ((!PageAnon(page) || PageSwapCache(page)) &&
> 		    page_test_dirty(page)) {
> 			page_clear_dirty(page);
> 			set_page_dirty(page);
> 		}
> 
> It's not wrong; but if it's necessary, then I need to understand why;
> and if it's unnecessary, then we'd do better to remove it (optimizing
> your optimization a little).

I want to play safe. I can conclude that the page dirty bit is of no
interest if the page is a purely anonymous page without a backing. That
is what the test checks for.

> I believe it's unnecessary: it is possible, yes, to arrive here and
> find the anon page dirty with respect to what's on swap disk; but
> because anon pages are COWed, never sharing modification with other
> users, that will only be so if we're the only user of that page, and
> about to free it, in which case no point in doing the set_page_dirty().

Hmm, what about the following sequence:
1) a page is added to the swap
2) the page is dirtied again
3) the process forks
4) the first process does an mlock
5) vmscan succeeds in replacing the pte of the second process with a
swap entry but fails for the pte of the first process.
6) the first process exists.

If the PageSwapCache() check is missing zap_pte_range() will drop the
last pte for the page but won't transfer the dirty bit.
Wouldn't that break?

> For a very similar case, see the PageAnon() test in zap_pte_range(),
> where we also skip the set_page_dirty().

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
