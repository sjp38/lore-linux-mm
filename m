Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 10BCF6B0006
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:18:38 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id b202-v6so12626341oii.23
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 01:18:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k33si4487613otd.216.2018.10.15.01.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 01:18:36 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9F8E9VZ057662
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:18:36 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n4kntfqne-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 04:18:35 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Mon, 15 Oct 2018 09:18:31 +0100
Date: Mon, 15 Oct 2018 10:18:14 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
In-Reply-To: <6580a62b-69c6-f2e3-767c-bd36b977bea2@de.ibm.com>
References: <20181012013756.11285-1-joel@joelfernandes.org>
	<20181012013756.11285-2-joel@joelfernandes.org>
	<6580a62b-69c6-f2e3-767c-bd36b977bea2@de.ibm.com>
MIME-Version: 1.0
Message-Id: <20181015101814.306d257c@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, linux-kernel@vger.kernel.org, kernel-team@android.com, minchan@kernel.org, pantin@google.com, hughd@google.com, lokeshgidra@google.com, dancol@google.com, mhocko@kernel.org, kirill@shutemov.name, akpm@linux-foundation.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, Dave Hansen <dave.hansen@linux.intel.com>, "David S. Miller" <davem@davemloft.net>, elfring@users.sourceforge.net, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Guan Xuetao <gxt@pku.edu.cn>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jeff Dike <jdike@addtoit.com>, Jonas Bonn <jonas@southpole.se>, Julia Lawall <Julia.Lawall@lip6.fr>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ley Foon Tan <lftan@altera.com>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Max Filippov <jcmvbkbc@gmail.com>, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, Peter Zijlstra <peterz@infradead.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Sam Creasey <sammy@sammy.net>, sparclinux@vger.kernel.org, Stafford Horne <shorne@gmail.com>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>

On Mon, 15 Oct 2018 09:10:53 +0200
Christian Borntraeger <borntraeger@de.ibm.com> wrote:

> On 10/12/2018 03:37 AM, Joel Fernandes (Google) wrote:
> > Android needs to mremap large regions of memory during memory management
> > related operations. The mremap system call can be really slow if THP is
> > not enabled. The bottleneck is move_page_tables, which is copying each
> > pte at a time, and can be really slow across a large map. Turning on THP
> > may not be a viable option, and is not for us. This patch speeds up the
> > performance for non-THP system by copying at the PMD level when possible.
> > 
> > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > completion times drops from 160-250 millesconds to 380-400 microseconds.
> > 
> > Before:
> > Total mremap time for 1GB data: 242321014 nanoseconds.
> > Total mremap time for 1GB data: 196842467 nanoseconds.
> > Total mremap time for 1GB data: 167051162 nanoseconds.
> > 
> > After:
> > Total mremap time for 1GB data: 385781 nanoseconds.
> > Total mremap time for 1GB data: 388959 nanoseconds.
> > Total mremap time for 1GB data: 402813 nanoseconds.
> > 
> > Incase THP is enabled, the optimization is skipped. I also flush the
> > tlb every time we do this optimization since I couldn't find a way to
> > determine if the low-level PTEs are dirty. It is seen that the cost of
> > doing so is not much compared the improvement, on both x86-64 and arm64.
> > 
> > Cc: minchan@kernel.org
> > Cc: pantin@google.com
> > Cc: hughd@google.com
> > Cc: lokeshgidra@google.com
> > Cc: dancol@google.com
> > Cc: mhocko@kernel.org
> > Cc: kirill@shutemov.name
> > Cc: akpm@linux-foundation.org
> > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > ---
> >  mm/mremap.c | 62 +++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 62 insertions(+)
> > 
> > diff --git a/mm/mremap.c b/mm/mremap.c
> > index 9e68a02a52b1..d82c485822ef 100644
> > --- a/mm/mremap.c
> > +++ b/mm/mremap.c
> > @@ -191,6 +191,54 @@ static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
> >  		drop_rmap_locks(vma);
> >  }
> >  
> > +static bool move_normal_pmd(struct vm_area_struct *vma, unsigned long old_addr,
> > +		  unsigned long new_addr, unsigned long old_end,
> > +		  pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
> > +{
> > +	spinlock_t *old_ptl, *new_ptl;
> > +	struct mm_struct *mm = vma->vm_mm;
> > +
> > +	if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
> > +	    || old_end - old_addr < PMD_SIZE)
> > +		return false;
> > +
> > +	/*
> > +	 * The destination pmd shouldn't be established, free_pgtables()
> > +	 * should have release it.
> > +	 */
> > +	if (WARN_ON(!pmd_none(*new_pmd)))
> > +		return false;
> > +
> > +	/*
> > +	 * We don't have to worry about the ordering of src and dst
> > +	 * ptlocks because exclusive mmap_sem prevents deadlock.
> > +	 */
> > +	old_ptl = pmd_lock(vma->vm_mm, old_pmd);
> > +	if (old_ptl) {
> > +		pmd_t pmd;
> > +
> > +		new_ptl = pmd_lockptr(mm, new_pmd);
> > +		if (new_ptl != old_ptl)
> > +			spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> > +
> > +		/* Clear the pmd */
> > +		pmd = *old_pmd;
> > +		pmd_clear(old_pmd);  
> 
> Adding Martin Schwidefsky.
> Is this mapping maybe still in use on other CPUs? If yes, I think for
> s390 we need to flush here as well (in other word we might need to introduce
> pmd_clear_flush). On s390 you have to use instructions like CRDTE,IPTE or IDTE
> to modify page table entries that are still in use. Otherwise you can get a 
> delayed access exception which is - in contrast to page faults - not recoverable.

Just clearing an active pmd would be broken for s390. We need the equivalent
of the ptep_get_and_clear() function for pmds. For s390 this function would
look like this:

static inline pte_t pmdp_get_and_clear(struct mm_struct *mm,
                                       unsigned long addr, pmd_t *pmdp)
{
        return pmdp_xchg_lazy(mm, addr, pmdp, __pmd(_SEGMENT_ENTRY_INVALID));
}

Just like pmdp_huge_get_and_clear() in fact.

> 
> 
> 
> > +
> > +		VM_BUG_ON(!pmd_none(*new_pmd));
> > +
> > +		/* Set the new pmd */
> > +		set_pmd_at(mm, new_addr, new_pmd, pmd);
> > +		if (new_ptl != old_ptl)
> > +			spin_unlock(new_ptl);
> > +		spin_unlock(old_ptl);
> > +
> > +		*need_flush = true;
> > +		return true;
> > +	}
> > +	return false;
> > +}
> > +

So the idea is to move the pmd entry to the new location, dragging
the whole pte table to a new location with a different address.
I wonder if that is safe in regard to get_user_pages_fast().

> >  unsigned long move_page_tables(struct vm_area_struct *vma,
> >  		unsigned long old_addr, struct vm_area_struct *new_vma,
> >  		unsigned long new_addr, unsigned long len,
> > @@ -239,7 +287,21 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
> >  			split_huge_pmd(vma, old_pmd, old_addr);
> >  			if (pmd_trans_unstable(old_pmd))
> >  				continue;
> > +		} else if (extent == PMD_SIZE) {
> > +			bool moved;
> > +
> > +			/* See comment in move_ptes() */
> > +			if (need_rmap_locks)
> > +				take_rmap_locks(vma);
> > +			moved = move_normal_pmd(vma, old_addr, new_addr,
> > +					old_end, old_pmd, new_pmd,
> > +					&need_flush);
> > +			if (need_rmap_locks)
> > +				drop_rmap_locks(vma);
> > +			if (moved)
> > +				continue;
> >  		}
> > +
> >  		if (pte_alloc(new_vma->vm_mm, new_pmd))
> >  			break;
> >  		next = (new_addr + PMD_SIZE) & PMD_MASK;
> >   

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
