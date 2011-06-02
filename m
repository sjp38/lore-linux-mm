Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D17CA6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 11:38:04 -0400 (EDT)
Date: Thu, 2 Jun 2011 17:37:54 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110602153754.GF19505@random.random>
References: <20110531133340.GB3490@barrios-laptop>
 <20110531141402.GK19505@random.random>
 <20110601005747.GC7019@csn.ul.ie>
 <20110601175809.GB7306@suse.de>
 <20110601191529.GY19505@random.random>
 <20110601214018.GC7306@suse.de>
 <20110601233036.GZ19505@random.random>
 <20110602010352.GD7306@suse.de>
 <20110602132954.GC19505@random.random>
 <20110602145019.GG7306@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602145019.GG7306@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan.kim@gmail.com>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Thu, Jun 02, 2011 at 03:50:19PM +0100, Mel Gorman wrote:
> I thought spin lock acquisition was one-way where loads/stores
> preceeding the lock are allowed to leak into the protected region
> but not the other way around?

That's true for ia64, x86 not AFIK.

> So we have
> 
> clear_huge_page()
> __SetPageUptodate(page);
> spin_lock(&mm->page_table_lock);
> ...
> set_pmd_at(mm, haddr, pmd, entry);
> 
> This spinlock itself does not guarantee that writes from
> clear_huge_page are complete before that set_pmd_at().

It does on x86.

> Whether this is right or wrong, why is the same not true in
> collapse_huge_page()? There we are
> 
>        __collapse_huge_page_copy(pte, new_page, vma, address, ptl);
> 	....
>         smp_wmb();
>         spin_lock(&mm->page_table_lock);
> 	...
>         set_pmd_at(mm, address, pmd, _pmd);
> 
> with the comment stressing that this is necessary.

So your first part of the patch is right, but it should be only a
theoretical improvement.

> > But smp_wmb() is optimized away at build time by cpp so this can't
> > possibly help if you're reproducing !SMP.
> > 
> 
> On X86 !SMP, this is still a barrier() which on gcc is
> 
> #define barrier() __asm__ __volatile__("": : :"memory")
> 
> so it's a compiler barrier. I'm not working on this at this at the
> moment but when I get to it, I'll compare the object files and see
> if there are relevant differences. Could be tomorrow before I get
> the chance again.

clear_huge_page called by do_huge_pmd_anonymous_page is an external
function (not static so gcc can't make assumption) and that is a full
equivalent to a barrier() after the function returns, so the only
relevancy of a smp_wmb on x86 SMP or !SMP would be zero (unless
X86_OOSTORE is set which I think is not, and that would only apply to
SMP).

> > >  		page_add_new_anon_rmap(page, vma, haddr);
> > >  		set_pmd_at(mm, haddr, pmd, entry);
> > >  		prepare_pmd_huge_pte(pgtable, mm);
> > > @@ -753,6 +755,13 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> > >  
> > >  	pmdp_set_wrprotect(src_mm, addr, src_pmd);
> > >  	pmd = pmd_mkold(pmd_wrprotect(pmd));
> > > +
> > > +	/*
> > > +	 * Write barrier to make sure the setup for the PMD is fully visible
> > > +	 * before the set_pmd_at
> > > +	 */
> > > +	smp_wmb();
> > > +
> > >  	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
> > >  	prepare_pmd_huge_pte(pgtable, dst_mm);
> > 
> > This part seems superfluous to me, it's also noop for !SMP.
> 
> Other than being a compiler barrier.

Yes but my point is this is ok to be cached in registers, the pmd
setup doesn't need to hit on main memory to be safe, it's local.

pmdp_set_wrprotect is done with a clear_bit and the dependency of the
code will require reading that after the clear_bit on !SMP. Not sure
how can possibly a barrier() above can matter.

> > Only wmb()
> > would stay. the pmd is perfectly fine to stay in a register, not even
> > a compiler barrier is needed, even less a smp serialization.
> 
> There is an explanation in here somewhere because as I write this,
> the test machine has survived 14 hours under continual stress without
> the isolated counters going negative with over 128 million pages
> successfully migrated and a million pages failed to migrate due to
> direct compaction being called 80,000 times. It's possible it's a
> co-incidence but it's some co-incidence!

No idea...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
