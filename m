Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BD9686B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 08:17:43 -0400 (EDT)
Date: Tue, 8 Sep 2009 13:17:01 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
In-Reply-To: <20090908073119.GA29902@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0909081258160.25652@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909072238320.15430@sister.anvils> <20090908073119.GA29902@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Sep 2009, Nick Piggin wrote:
> On Mon, Sep 07, 2009 at 10:39:34PM +0100, Hugh Dickins wrote:
> > KAMEZAWA Hiroyuki has observed customers of earlier kernels taking
> > advantage of the ZERO_PAGE: which we stopped do_anonymous_page() from
> > using in 2.6.24.  And there were a couple of regression reports on LKML.
> > 
> > Following suggestions from Linus, reinstate do_anonymous_page() use of
> > the ZERO_PAGE; but this time avoid dirtying its struct page cacheline
> > with (map)count updates - let vm_normal_page() regard it as abnormal.
> > 
> > Use it only on arches which __HAVE_ARCH_PTE_SPECIAL (x86, s390, sh32,
> > most powerpc): that's not essential, but minimizes additional branches
> > (keeping them in the unlikely pte_special case); and incidentally
> > excludes mips (some models of which needed eight colours of ZERO_PAGE
> > to avoid costly exceptions).
> 
> Without looking closely, why is it a big problem to have a
> !HAVE PTE SPECIAL case? Couldn't it just be a check for
> pfn == zero_pfn that is conditionally compiled away for pte
> special architectures anyway?

Yes, I'm uncomfortable with that restriction too: it makes for
neater looking code in a couple of places, but it's not so good
for the architectures to diverge gratuitously there.

I'll give it a try without that restriction, see how it looks:
it was Linus who proposed the "special" approach, I'm sure he'll
speak up if he doesn't like how the alternative comes out.

Tucking the test away in an asm-generic macro, we can leave
the pain of a rangetest to the one mips case.

By the way, in compiling that list of "special" architectures,
I was surprised not to find ia64 amongst them.  Not that it
matters to me, but I thought the Fujitsu guys were usually
keen on Itanium - do they realize that the special test is
excluding it, or do they have their own special patch for it?

> 
> If zero page is such a good idea, I don't see the logic of
> limiting it like thisa. Your patch looks pretty clean though.
> 
> At any rate, I think it might be an idea to cc linux-arch. 

Yes, thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
