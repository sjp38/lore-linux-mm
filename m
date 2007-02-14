Date: Wed, 14 Feb 2007 17:50:47 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [rfc][patch] rmap: more sanity checks
Message-ID: <20070214165047.GB11002@v2.random>
References: <20070214090425.GA14932@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070214090425.GA14932@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Petr Tesarik <ptesarik@suse.cz>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Wed, Feb 14, 2007 at 10:04:25AM +0100, Nick Piggin wrote:
> It would be nice to get some of these checks back into mainline, IMO. I

Obviously seconded. It's a bit ironic that my original implementation
was effectively safer that what was further "sanitized" and pushed
into mainline 8). (of course mainline over the dozen releases was
significantly improved in the locking etc.etc.. I don't mean that, but
as far as safety goes it clearly still lacks)

This isn't the first time that we catch subtle VM bugs in sles9 that
aren't reproducible in mainline (but that affects mainline too). I
tried a few times to complain about the removal of my bugchecks
(notably I recall the ones in do_no_page):

#ifndef CONFIG_DISCONTIGMEM
	/* this check is unreliable with numa enabled */
	BUG_ON(!pfn_valid(page_to_pfn(new_page)));
#endif
	pageable = !PageReserved(new_page);
	as = !!new_page->mapping;

	BUG_ON(!pageable && as);

	pageable &= as;

	/* ->nopage cannot return swapcache */
	BUG_ON(PageSwapCache(new_page));
	/* ->nopage cannot return anonymous pages */
	BUG_ON(PageAnon(new_page));

compare that with mainline...

I hope this incident will be enough to resurrect some of the
"sanitized" bugchecks.

> wonder if I'm correct in thinking that checking the page index and mapping
> is not actually racy?

Index and mapping shouldn't change if the page is locked, and you
already added the BUG_ON(!PageLocked(page)).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
