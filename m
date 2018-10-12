Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA0C56B0006
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 17:40:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x2-v6so10262297pgr.8
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 14:40:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c2-v6sor2126896pll.61.2018.10.12.14.40.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Oct 2018 14:40:14 -0700 (PDT)
Date: Sat, 13 Oct 2018 00:40:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 2/2] mm: speed up mremap by 500x on large regions
Message-ID: <20181012214008.jj7vhh76vte7xj7i@kshutemo-mobl1>
References: <20181012013756.11285-1-joel@joelfernandes.org>
 <20181012013756.11285-2-joel@joelfernandes.org>
 <9ed82f9e-88c4-8e4f-8c45-3ef153469603@kot-begemot.co.uk>
 <20181012143728.t42uvr6etg7gp7fh@kshutemo-mobl1>
 <4dd52e22-5b51-9b30-7178-fde603a08f88@kot-begemot.co.uk>
 <97cb3fe1-7bc1-12ff-d602-56c72a5496c5@kot-begemot.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <97cb3fe1-7bc1-12ff-d602-56c72a5496c5@kot-begemot.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, mhocko@kernel.org, linux-mm@kvack.org, lokeshgidra@google.com, linux-riscv@lists.infradead.org, elfring@users.sourceforge.net, Jonas Bonn <jonas@southpole.se>, linux-s390@vger.kernel.org, dancol@google.com, Yoshinori Sato <ysato@users.sourceforge.jp>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-hexagon@vger.kernel.org, Helge Deller <deller@gmx.de>, "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>, hughd@google.com, "James E.J. Bottomley" <jejb@parisc-linux.org>, kasan-dev@googlegroups.com, kvmarm@lists.cs.columbia.edu, Ingo Molnar <mingo@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-snps-arc@lists.infradead.org, kernel-team@android.com, Sam Creasey <sammy@sammy.net>, Fenghua Yu <fenghua.yu@intel.com>, Jeff Dike <jdike@addtoit.com>, linux-um@lists.infradead.org, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Julia Lawall <Julia.Lawall@lip6.fr>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, nios2-dev@lists.rocketboards.org, Stafford Horne <shorne@gmail.com>, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Chris Zankel <chris@zankel.net>, Tony Luck <tony.luck@intel.com>, Richard Weinberger <richard@nod.at>, linux-parisc@vger.kernel.org, pantin@google.com, Max Filippov <jcmvbkbc@gmail.com>, minchan@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-alpha@vger.kernel.org, Ley Foon Tan <lftan@altera.com>, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>

On Fri, Oct 12, 2018 at 05:42:24PM +0100, Anton Ivanov wrote:
> 
> On 10/12/18 3:48 PM, Anton Ivanov wrote:
> > On 12/10/2018 15:37, Kirill A. Shutemov wrote:
> > > On Fri, Oct 12, 2018 at 03:09:49PM +0100, Anton Ivanov wrote:
> > > > On 10/12/18 2:37 AM, Joel Fernandes (Google) wrote:
> > > > > Android needs to mremap large regions of memory during
> > > > > memory management
> > > > > related operations. The mremap system call can be really
> > > > > slow if THP is
> > > > > not enabled. The bottleneck is move_page_tables, which is copying each
> > > > > pte at a time, and can be really slow across a large map.
> > > > > Turning on THP
> > > > > may not be a viable option, and is not for us. This patch
> > > > > speeds up the
> > > > > performance for non-THP system by copying at the PMD level
> > > > > when possible.
> > > > > 
> > > > > The speed up is three orders of magnitude. On a 1GB mremap, the mremap
> > > > > completion times drops from 160-250 millesconds to 380-400
> > > > > microseconds.
> > > > > 
> > > > > Before:
> > > > > Total mremap time for 1GB data: 242321014 nanoseconds.
> > > > > Total mremap time for 1GB data: 196842467 nanoseconds.
> > > > > Total mremap time for 1GB data: 167051162 nanoseconds.
> > > > > 
> > > > > After:
> > > > > Total mremap time for 1GB data: 385781 nanoseconds.
> > > > > Total mremap time for 1GB data: 388959 nanoseconds.
> > > > > Total mremap time for 1GB data: 402813 nanoseconds.
> > > > > 
> > > > > Incase THP is enabled, the optimization is skipped. I also flush the
> > > > > tlb every time we do this optimization since I couldn't find a way to
> > > > > determine if the low-level PTEs are dirty. It is seen that the cost of
> > > > > doing so is not much compared the improvement, on both
> > > > > x86-64 and arm64.
> > > > > 
> > > > > Cc: minchan@kernel.org
> > > > > Cc: pantin@google.com
> > > > > Cc: hughd@google.com
> > > > > Cc: lokeshgidra@google.com
> > > > > Cc: dancol@google.com
> > > > > Cc: mhocko@kernel.org
> > > > > Cc: kirill@shutemov.name
> > > > > Cc: akpm@linux-foundation.org
> > > > > Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
> > > > > ---
> > > > >    mm/mremap.c | 62
> > > > > +++++++++++++++++++++++++++++++++++++++++++++++++++++
> > > > >    1 file changed, 62 insertions(+)
> > > > > 
> > > > > diff --git a/mm/mremap.c b/mm/mremap.c
> > > > > index 9e68a02a52b1..d82c485822ef 100644
> > > > > --- a/mm/mremap.c
> > > > > +++ b/mm/mremap.c
> > > > > @@ -191,6 +191,54 @@ static void move_ptes(struct
> > > > > vm_area_struct *vma, pmd_t *old_pmd,
> > > > >            drop_rmap_locks(vma);
> > > > >    }
> > > > > +static bool move_normal_pmd(struct vm_area_struct *vma,
> > > > > unsigned long old_addr,
> > > > > +          unsigned long new_addr, unsigned long old_end,
> > > > > +          pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush)
> > > > > +{
> > > > > +    spinlock_t *old_ptl, *new_ptl;
> > > > > +    struct mm_struct *mm = vma->vm_mm;
> > > > > +
> > > > > +    if ((old_addr & ~PMD_MASK) || (new_addr & ~PMD_MASK)
> > > > > +        || old_end - old_addr < PMD_SIZE)
> > > > > +        return false;
> > > > > +
> > > > > +    /*
> > > > > +     * The destination pmd shouldn't be established, free_pgtables()
> > > > > +     * should have release it.
> > > > > +     */
> > > > > +    if (WARN_ON(!pmd_none(*new_pmd)))
> > > > > +        return false;
> > > > > +
> > > > > +    /*
> > > > > +     * We don't have to worry about the ordering of src and dst
> > > > > +     * ptlocks because exclusive mmap_sem prevents deadlock.
> > > > > +     */
> > > > > +    old_ptl = pmd_lock(vma->vm_mm, old_pmd);
> > > > > +    if (old_ptl) {
> > > > > +        pmd_t pmd;
> > > > > +
> > > > > +        new_ptl = pmd_lockptr(mm, new_pmd);
> > > > > +        if (new_ptl != old_ptl)
> > > > > +            spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
> > > > > +
> > > > > +        /* Clear the pmd */
> > > > > +        pmd = *old_pmd;
> > > > > +        pmd_clear(old_pmd);
> > > > > +
> > > > > +        VM_BUG_ON(!pmd_none(*new_pmd));
> > > > > +
> > > > > +        /* Set the new pmd */
> > > > > +        set_pmd_at(mm, new_addr, new_pmd, pmd);
> > > > UML does not have set_pmd_at at all
> > > Every architecture does. :)
> > 
> > I tried to build it patching vs 4.19-rc before I made this statement and
> > ran into that.
> > 
> > Presently it does not.
> > 
> > https://elixir.bootlin.com/linux/v4.19-rc7/ident/set_pmd_at - UML is not
> > on the list.
> 
> Once this problem as well as the omissions in the include changes for UML in
> patch one have been fixed it appears to be working.
> 
> What it needs is attached.

Well, the optization is only suitable for arch that has 3 or more levels
of page tables. Otherwise it will not have [non-folded] pmd.

And in this case arch/um already should have set_pmd_at(), see
3_LEVEL_PGTABLES.

To port on 2-level paging, it has to be handled on pgd level. It
complicates the code and will not bring much value.

-- 
 Kirill A. Shutemov
