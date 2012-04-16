Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5D6D16B00FC
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 11:50:46 -0400 (EDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 16 Apr 2012 16:50:41 +0100
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GFohOU2785454
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 16:50:43 +0100
Received: from d06av09.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GFogK4031439
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:50:42 -0600
Date: Mon, 16 Apr 2012 17:50:40 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
Message-ID: <20120416175040.0e33b37f@de.ibm.com>
In-Reply-To: <20120416141423.GD2359@suse.de>
References: <20120416141423.GD2359@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 16 Apr 2012 15:14:23 +0100
Mel Gorman <mgorman@suse.de> wrote:

> This patch is horribly ugly and there has to be a better way of doing
> it. I'm looking for suggestions on what s390 can do here that is not
> painful or broken. 
> 
> However, s390 needs a better way of guarding against
> PageSwapCache pages being removed from the radix tree while set_page_dirty()
> is being called. The patch would be marginally better if in the PageSwapCache
> case we simply tried to lock once and in the contended case just fail to
> propogate the storage key. I lack familiarity with the s390 architecture
> to be certain if this is safe or not. Suggestions on a better fix?

One though that crossed my mind is that maybe a better approach would be
to move the page_test_and_clear_dirty check out of page_remove_rmap.
What we need to look out for are code sequences of the form:

	if (pte_dirty(pte))
		set_page_dirty(page);
	...
	page_remove_rmap(page);

There are four of those as far as I can see: in try_to_unmap_one,
try_to_unmap_cluster, zap_pte, and zap_pte_range.

A valid implementation for s390 would be to test and clear the changed
bit in the storage key for every of those pte_dirty() calls.

	if (pte_dirty(pte) || page_test_and_clear_dirty(page))
		set_page_dirty(page);
	...
	page_remove_rmap(page); /* w/o page_test_clear_dirty */

Trouble is that the ISKE and SSKE instructions are very expensive, that
is why we currently have the operation in page_remove_rmap after the
map counter dropped to zero (which is wrong as we now have learned the
hard way). The additional check for (!PageAnon || PageSwapCache) is
just another variation of avoiding ISKE/SSKE.

Thinking about a function like this:

static inline int page_test_dirty_eco(struct page *page)
{
	if (page_mapcount(page) > 1)
		return 0;
	if (PageAnon(page) && !PageSwapCache(page))
		return 0;
	return page_test_and_clear_dirty(page);
}

and use it alongside the pte_dirty() check. The worry I have is the
map counter. What guarantees us that the map counter is not decremented
concurrently? Which is probably a problem with the current patch as
well, checking atomic_add_negative(-1, &page->_mapcount) against zero
works, doing (page_mapcount(page) == 1) followed by the decrement 
can race. And we better not forget a dirty bit ..

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
