Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C772B6B0003
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 22:09:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id l7-v6so4237929plg.6
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:09:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v19-v6sor6495435pff.34.2018.10.24.19.09.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 19:09:11 -0700 (PDT)
Date: Wed, 24 Oct 2018 19:09:07 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH 2/4] mm: speed up mremap by 500x on large regions (v2)
Message-ID: <20181025020907.GA13560@joelaf.mtv.corp.google.com>
References: <20181013013200.206928-1-joel@joelfernandes.org>
 <20181013013200.206928-3-joel@joelfernandes.org>
 <20181024101255.it4lptrjogalxbey@kshutemo-mobl1>
 <20181024115733.GN8537@350D>
 <20181024125724.yf6frdimjulf35do@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024125724.yf6frdimjulf35do@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, anton.ivanov@kot-begemot.co.uk, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Max Filippov <jcmvbkbc@gmail.com>, nios2-dev@lists.rocketboards.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Wed, Oct 24, 2018 at 03:57:24PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 24, 2018 at 10:57:33PM +1100, Balbir Singh wrote:
> > On Wed, Oct 24, 2018 at 01:12:56PM +0300, Kirill A. Shutemov wrote:
> > > On Fri, Oct 12, 2018 at 06:31:58PM -0700, Joel Fernandes (Google) wrote:
> > > > diff --git a/mm/mremap.c b/mm/mremap.c
> > > > index 9e68a02a52b1..2fd163cff406 100644
> > > > --- a/mm/mremap.c
> > > > +++ b/mm/mremap.c
> > > > @@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
> > > >  		drop_rmap_locks(vma);
> > > >  }
> > > >  
> > > > +static bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
> > > > +		  unsigned long new_addr, unsigned long old_end,
> > > > +		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
> > > > +{
> > > > +	spinlock_t *old_ptl, *new_ptl;
> > > > +	struct mm_struct *mm = vma->vm_mm;
> > > > +
> > > > +	if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
> > > > +	    || old_end - old_addr < PMD_SIZE)
> > > > +		return false;
> > > > +
> > > > +	/*
> > > > +	 * The destination pmd shouldn't be established, free_pgtables()
> > > > +	 * should have release it.
> > > > +	 */
> > > > +	if (WARN_ON(!pmd_none(*new_pmd)))
> > > > +		return false;
> > > > +
> > > > +	/*
> > > > +	 * We don't have to worry about the ordering of src and dst
> > > > +	 * ptlocks because exclusive mmap_sem prevents deadlock.
> > > > +	 */
> > > > +	old_ptl = pmd_lock(vma->vm_mm, old_pmd);
> > > > +	if (old_ptl) {
> > > 
> > > How can it ever be false?

Kirill,
It cannot, you are right. I'll remove the test.

By the way, there are new changes upstream by Linus which flush the TLB
before releasing the ptlock instead of after. I'm guessing that patch came
about because of reviews of this patch and someone spotted an issue in the
existing code :)

Anyway the patch in concern is:
eb66ae030829 ("mremap: properly flush TLB before releasing the page")

I need to rebase on top of that with appropriate modifications, but I worry
that this patch will slow down performance since we have to flush at every
PMD/PTE move before releasing the ptlock. Where as with my patch, the
intention is to flush only at once in the end of move_page_tables. When I
tried to flush TLB on every PMD move, it was quite slow on my arm64 device [2].

Further observation [1] is, it seems like the move_huge_pmds and move_ptes code
is a bit sub optimal in the sense, we are acquiring and releasing the same
ptlock for a bunch of PMDs if the said PMDs are on the same page-table page
right? Instead we can do better by acquiring and release the ptlock less
often.

I think this observation [1] and the frequent TLB flush issue [2] can be solved
by acquiring the ptlock once for a bunch of PMDs, move them all, then flush
the tlb and then release the ptlock, and then proceed to doing the same thing
for the PMDs in the next page-table page. What do you think?

- Joel
