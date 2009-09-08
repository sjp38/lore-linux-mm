Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8EEA26B0085
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:34:55 -0400 (EDT)
Date: Tue, 8 Sep 2009 17:34:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 7/8] mm: reinstate ZERO_PAGE
Message-ID: <20090908153441.GB29902@wotan.suse.de>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072238320.15430@sister.anvils> <20090908073119.GA29902@wotan.suse.de> <Pine.LNX.4.64.0909081258160.25652@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0909081258160.25652@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 08, 2009 at 01:17:01PM +0100, Hugh Dickins wrote:
> On Tue, 8 Sep 2009, Nick Piggin wrote:
> > On Mon, Sep 07, 2009 at 10:39:34PM +0100, Hugh Dickins wrote:
> > > KAMEZAWA Hiroyuki has observed customers of earlier kernels taking
> > > advantage of the ZERO_PAGE: which we stopped do_anonymous_page() from
> > > using in 2.6.24.  And there were a couple of regression reports on LKML.
> > > 
> > > Following suggestions from Linus, reinstate do_anonymous_page() use of
> > > the ZERO_PAGE; but this time avoid dirtying its struct page cacheline
> > > with (map)count updates - let vm_normal_page() regard it as abnormal.
> > > 
> > > Use it only on arches which __HAVE_ARCH_PTE_SPECIAL (x86, s390, sh32,
> > > most powerpc): that's not essential, but minimizes additional branches
> > > (keeping them in the unlikely pte_special case); and incidentally
> > > excludes mips (some models of which needed eight colours of ZERO_PAGE
> > > to avoid costly exceptions).
> > 
> > Without looking closely, why is it a big problem to have a
> > !HAVE PTE SPECIAL case? Couldn't it just be a check for
> > pfn == zero_pfn that is conditionally compiled away for pte
> > special architectures anyway?
> 
> Yes, I'm uncomfortable with that restriction too: it makes for
> neater looking code in a couple of places, but it's not so good
> for the architectures to diverge gratuitously there.
> 
> I'll give it a try without that restriction, see how it looks:
> it was Linus who proposed the "special" approach, I'm sure he'll
> speak up if he doesn't like how the alternative comes out.

I guess using special is pretty neat and doesn't require an
additional branch in vm_normal_page paths. But I think it is
important to allow other architectures at least the _option_
to have equivalent behaviour as x86 here. So it would be
great if you would look into it.

 
> Tucking the test away in an asm-generic macro, we can leave
> the pain of a rangetest to the one mips case.
> 
> By the way, in compiling that list of "special" architectures,
> I was surprised not to find ia64 amongst them.  Not that it
> matters to me, but I thought the Fujitsu guys were usually
> keen on Itanium - do they realize that the special test is
> excluding it, or do they have their own special patch for it?

I don't understand your question. Are you asking whether they
know your patch will not enable zero pages on ia64?

I guess pte special was primarily driven by gup_fast, which in
turn was driven primarily by DB2 9.5, which I think might be
only available on x86 and ibm's architectures.

But I admit to being a curious as to when I'll see a gup_fast
patch come out of SGI or HP or Fujitsu :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
