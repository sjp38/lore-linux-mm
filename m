Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7FBB76B0044
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 15:29:19 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 13:29:17 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B9B733E4004F
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 19:28:27 +0000 (WET)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6NJRuv7098932
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 13:27:57 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6NJRhtR011083
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 13:27:44 -0600
Date: Mon, 23 Jul 2012 12:27:40 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] page-table walkers vs memory order
Message-ID: <20120723192740.GC2491@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1343064870.26034.23.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343064870.26034.23.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@kernel.dk>, linux-kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Jul 23, 2012 at 07:34:30PM +0200, Peter Zijlstra wrote:
> 
> While staring at mm/huge_memory.c I found a very under-commented
> smp_wmb() in __split_huge_page_map(). It turns out that its copied from
> __{pte,pmd,pud}_alloc() but forgot the useful comment (or a reference
> thereto).
> 
> Now, afaict we're not good, as per that comment. Paul has since
> convinced some of us that compiler writers are pure evil and out to get
> us.

I have seen the glint in their eyes when they discuss optimization
techniques that you would not want your children to know about!

> Therefore we should do what rcu_dereference() does and use
> ACCESS_ONCE()/barrier() followed smp_read_barrier_depends() every time
> we dereference a page-table pointer.
> 
> 
> In particular it looks like things like
> mm/memcontrol.c:mem_cgroup_count_precharge(), which use
> walk_page_range() under down_read(&mm->mmap_sem) and can thus be
> concurrent with __{pte,pmd,pud}_alloc() from faults (and possibly
> itself) are quite broken on Alpha and subtly broken for those of us with
> 'creative' compilers.

Looks good to me, though given my ignorance of mm, not sure that counts
for much.

							Thanx, Paul

> Should I go do a more extensive audit of page-table walkers or are we
> happy with the status quo?
> 
> ---
>  arch/x86/mm/gup.c |    6 +++---
>  mm/pagewalk.c     |   24 ++++++++++++++++++++++++
>  2 files changed, 27 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
> index dd74e46..4958fb1 100644
> --- a/arch/x86/mm/gup.c
> +++ b/arch/x86/mm/gup.c
> @@ -150,7 +150,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
>  
>  	pmdp = pmd_offset(&pud, addr);
>  	do {
> -		pmd_t pmd = *pmdp;
> +		pmd_t pmd = ACCESS_ONCE(*pmdp);

Here, ACCESS_ONCE() suffices because this is x86-specific code.
Core code would need to worry about Alpha, and would thus also need
smp_read_barrier_depends(), as you in fact do have further down.

>  		next = pmd_addr_end(addr, end);
>  		/*
> @@ -220,7 +220,7 @@ static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
>  
>  	pudp = pud_offset(&pgd, addr);
>  	do {
> -		pud_t pud = *pudp;
> +		pud_t pud = ACCESS_ONCE(*pudp);
>  
>  		next = pud_addr_end(addr, end);
>  		if (pud_none(pud))
> @@ -280,7 +280,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  	local_irq_save(flags);
>  	pgdp = pgd_offset(mm, addr);
>  	do {
> -		pgd_t pgd = *pgdp;
> +		pgd_t pgd = ACCESS_ONCE(*pgdp);
>  
>  		next = pgd_addr_end(addr, end);
>  		if (pgd_none(pgd))
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 6c118d0..2ba2a74 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -10,6 +10,14 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	int err = 0;
>  
>  	pte = pte_offset_map(pmd, addr);
> +	/*
> +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> +	 * actual dereference of p[gum]d, but that's hidden deep within the
> +	 * bowels of {pte,pmd,pud}_offset.
> +	 */
> +	barrier();
> +	smp_read_barrier_depends();
>  	for (;;) {
>  		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
>  		if (err)
> @@ -32,6 +40,14 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  	int err = 0;
>  
>  	pmd = pmd_offset(pud, addr);
> +	/*
> +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> +	 * actual dereference of p[gum]d, but that's hidden deep within the
> +	 * bowels of {pte,pmd,pud}_offset.
> +	 */
> +	barrier();
> +	smp_read_barrier_depends();
>  	do {
>  again:
>  		next = pmd_addr_end(addr, end);
> @@ -77,6 +93,14 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  	int err = 0;
>  
>  	pud = pud_offset(pgd, addr);
> +	/*
> +	 * Pairs with the smp_wmb() in __{pte,pmd,pud}_alloc() and
> +	 * __split_huge_page_map(). Ideally we'd use ACCESS_ONCE() on the
> +	 * actual dereference of p[gum]d, but that's hidden deep within the
> +	 * bowels of {pte,pmd,pud}_offset.
> +	 */
> +	barrier();
> +	smp_read_barrier_depends();
>  	do {
>  		next = pud_addr_end(addr, end);
>  		if (pud_none_or_clear_bad(pud)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
