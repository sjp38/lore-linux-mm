Date: Sun, 4 Apr 2004 02:40:36 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040404004036.GR2307@dualathlon.random>
References: <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random> <20040402104334.A871@infradead.org> <20040402164634.GF21341@dualathlon.random> <20040403174043.GK2307@dualathlon.random> <20040403120227.398268aa.akpm@osdl.org> <20040403232717.GO2307@dualathlon.random> <20040403154608.78e98877.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040403154608.78e98877.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: hch@infradead.org, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 03, 2004 at 03:46:08PM -0800, Andrew Morton wrote:
> Andrea Arcangeli <andrea@suse.de> wrote:
> > @@ -439,6 +457,8 @@ static struct page * follow_page(struct
> >         pmd = pmd_offset(pgd, address);
> >         if (pmd_none(*pmd))
> >                 goto out;
> > +       if (pmd_bigpage(*pmd))
> > +               return __pmd_page(*pmd) + (address & BIGPAGE_MASK) / PAGE_SIZE;
> 
> OK, that's an x86 solution.  But this addresses the easy part - the messy

you mean because it assumes the pmd is involved, right?

> part happens where we want to unpin the pages at I/O completion in
> bio_release_pages() when the page may not even be in a vma any more..

the vma in 2.4 doesn't matter, there's no refcounting on the bigpage
based on the pagetables that maps it, this is the zap_pmd code, go
figure:

[..]
	do {
		if (pmd_bigpage(*pmd))
			pmd_clear(pmd);
		else
			freed += zap_pte_range(tlb, pmd, address, end - address);
[..]



So a vma going away isn't going to make any difference for
get_user_pages or things would go bad. However I just noticed if you
truncate or delete the shm segment during I/O that will corrupt memory
since the only refcounting happening happens in the shm in form of
physical pages idexed by an array, 1 entry in the array for every
bigpages, so no issues again with refcounting but you're right it's racy
against truncate/unlink. that's fine compromise for 2.4 where bigpages
are under a sysctl that disables local security anyways, but I agree in
2.6 doing it with proper refcounting is needed and I see better the
point for compound now.

Replacing the compound framework with a wrapper that reaches the master
page given any page_t* and the size of the bigpage is certainly doable
as I suggested some email ago (even if it's not exactly what 2.4 is
doing, or better 2.4 it's doing that just fine in the shm layer but not
in the I/O completion routine which means truncate can race with rawio),
though we'll end up filling the pagecache layer with these math
calculations. So it may not make an huge difference for the pagecache
itself, but it'll definitely free all the nonpagecache users from the
compound-or-equivalent-math overhead.

The thing I care most is that alloc_pages should return the same thing
for every arch. It's just asking for troubles to return compound pages
in x86 and non-compound pages for ppc. Drivers can very wall start
depending on compound pages too, then ppc users will be more sorry at
runtime than losing 16k ;), there's nothing that prevents drivers from
using compound pages too.

BTW, had you a look at Christoph's oops on ppc with the gfp-no-compound
applied? I'm currently scratching my head on it. Can you imagine
something corrupting page->private for a compound slab-page? I can't see
any problem in my gfp-no-compound patch in rc3-aa3 (infact now
swapsuspend works fine finally ;). I feel like my change is exposing
some other bug that was hidden previously with compound turned off.
It'll be very interesting to hear the effect of the three debugging
patches I posted.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
