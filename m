Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 459EC6B0072
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 14:17:36 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Jul 2012 14:17:33 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2C340D102B4
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 13:56:39 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6PHuarT342868
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 13:56:37 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6PHuTtq010632
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 11:56:32 -0600
Date: Wed, 25 Jul 2012 10:56:28 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120725175628.GH2378@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
 <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1207241356350.2094@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Tue, Jul 24, 2012 at 02:51:05PM -0700, Hugh Dickins wrote:
> On Mon, 23 Jul 2012, Peter Zijlstra wrote:
> > 
> > While staring at mm/huge_memory.c I found a very under-commented
> > smp_wmb() in __split_huge_page_map(). It turns out that its copied from
> > __{pte,pmd,pud}_alloc() but forgot the useful comment (or a reference
> > thereto).
> > 
> > Now, afaict we're not good, as per that comment. Paul has since
> > convinced some of us that compiler writers are pure evil and out to get
> > us.
> > 
> > Therefore we should do what rcu_dereference() does and use
> > ACCESS_ONCE()/barrier() followed smp_read_barrier_depends() every time
> > we dereference a page-table pointer.
> > 
> > 
> > In particular it looks like things like
> > mm/memcontrol.c:mem_cgroup_count_precharge(), which use
> > walk_page_range() under down_read(&mm->mmap_sem) and can thus be
> > concurrent with __{pte,pmd,pud}_alloc() from faults (and possibly
> > itself) are quite broken on Alpha
> 
> The Alpha pmd_offset() and pte_offset_map() already contain an
> smp_read_barrier_depends() (362a61ad from Nick); with comment that
> it's not needed on the pgd, and I presume the pud level is folded.
> Does Alpha really need more of them, as you have put below?
> 
> > and subtly broken for those of us with 'creative' compilers.
> 
> I don't want to fight against ACCESS_ONCE() (or barrier(): that's
> interesting, thank you, I hadn't seen it used as an ACCESS_ONCE()
> substitute before); but I do want to question it a little.
> 
> I'm totally unclear whether the kernel ever gets built with these
> 'creative' compilers that you refer to.  Is ACCESS_ONCE() a warning
> of where some future compiler would be permitted to mess with our
> assumptions?  Or is it actually saving us already today?  Would we
> know?  Could there be a boottime test that would tell us?  Is it
> likely that a future compiler would have an "--access_once"
> option that the kernel build would want to turn on?
> 
> Those may all be questions for Paul!

The problem is that, unless you tell it otherwise, the compiler is
permitted to assume that the code that it is generating is the only thing
active in that address space at that time.  So the compiler might know
that it already has a perfectly good copy of that value somewhere in
its registers, or it might decide to fetch the value twice rather than
once due to register pressure, either of which can be fatal in SMP code.
And then there are more aggressive optimizations as well.

ACCESS_ONCE() is a way of telling the compiler to access the value
once, regardless of what cute single-threaded optimizations that it
otherwise might want to apply.

							Thanx, Paul

> > Should I go do a more extensive audit of page-table walkers or are we
> > happy with the status quo?
> 
> I do love the status quo, but an audit would be welcome.  When
> it comes to patches, personally I tend to prefer ACCESS_ONCE() and
> smp_read_barrier_depends() and accompanying comments to be hidden away
> in the underlying macros or inlines where reasonable, rather than
> repeated all over; but I may have my priorities wrong on that.
> 
> The last time we rewrote the main pgd-pud-pmd-pte walkers,
> we believed that no ACCESS_ONCE() was necessary, because although a
> pgd-pud-pmd entry might be racily instantiated at any instant, it
> could never change beneath us - the freeing of page tables happens
> only when we cannot reach them by other routes.
> 
> (Never quite true: those _clear_bad() things can zero entries at any
> instant, but we're already in a bad place when those come into play,
> so we never worried about racing against them.)
> 
> Since then, I think THP has made the rules more complicated; but I
> believe Andrea paid a great deal of attention to that kind of issue.
> 
> I suspect your arch/x86/mm/gup.c ACCESS_ONCE()s are necessary:
> gup_fast() breaks as many rules as it can, and in particular may
> be racing with the freeing of page tables; but I'm not so sure
> about the pagewalk mods - we could say "cannot do any harm",
> but I don't like adding lines on that basis.
> 
> Hugh
> 
> > 
> > ---
> >  arch/x86/mm/gup.c |    6 +++---
> >  mm/pagewalk.c     |   24 ++++++++++++++++++++++++
> >  2 files changed, 27 insertions(+), 3 deletions(-)
> > 
> > diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> > index dd74e46..4958fb1 100644
> > --- a/arch/x86/mm/gup.c
> > +++ b/arch/x86/mm/gup.c
> > @@ -150,7 +150,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
> >  
> >  	pmdp = pmd_offset(&pud, addr);
> >  	do {
> > -		pmd_t pmd = *pmdp;
> > +		pmd_t pmd = ACCESS_ONCE(*pmdp);
> >  
> >  		next = pmd_addr_end(addr, end);
> >  		/*
> > @@ -220,7 +220,7 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
> >  
> >  	pudp = pud_offset(&pgd, addr);
> >  	do {
> > -		pud_t pud = *pudp;
> > +		pud_t pud = ACCESS_ONCE(*pudp);
> >  
> >  		next = pud_addr_end(addr, end);
> >  		if (pud_none(pud))
> > @@ -280,7 +280,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
> >  	local_irq_save(flags);
> >  	pgdp = pgd_offset(mm, addr);
> >  	do {
> > -		pgd_t pgd = *pgdp;
> > +		pgd_t pgd = ACCESS_ONCE(*pgdp);
> >  
> >  		next = pgd_addr_end(addr, end);
> >  		if (pgd_none(pgd))
> > diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> > index 6c118d0..2ba2a74 100644
> > --- a/mm/pagewalk.c
> > +++ b/mm/pagewalk.c
> > @@ -10,6 +10,14 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  	int err = 0;
> >  
> >  	pte = pte_offset_map(pmd, addr);
> > +	/*
> > +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> > +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> > +	 * actual dereference of p[gum]d, but that's hidden deep within the
> > +	 * bowels of {pte,pmd,pud}_offset.
> > +	 */
> > +	barrier();
> > +	smp_read_barrier_depends();
> >  	for (;;) {
> >  		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
> >  		if (err)
> > @@ -32,6 +40,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
> >  	int err = 0;
> >  
> >  	pmd = pmd_offset(pud, addr);
> > +	/*
> > +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> > +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> > +	 * actual dereference of p[gum]d, but that's hidden deep within the
> > +	 * bowels of {pte,pmd,pud}_offset.
> > +	 */
> > +	barrier();
> > +	smp_read_barrier_depends();
> >  	do {
> >  again:
> >  		next = pmd_addr_end(addr, end);
> > @@ -77,6 +93,14 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
> >  	int err = 0;
> >  
> >  	pud = pud_offset(pgd, addr);
> > +	/*
> > +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> > +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> > +	 * actual dereference of p[gum]d, but that's hidden deep within the
> > +	 * bowels of {pte,pmd,pud}_offset.
> > +	 */
> > +	barrier();
> > +	smp_read_barrier_depends();
> >  	do {
> >  		next = pud_addr_end(addr, end);
> >  		if (pud_none_or_clear_bad(pud)) {
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
