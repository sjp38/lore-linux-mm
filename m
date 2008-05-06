Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m46DWUPh031261
	for <linux-mm@kvack.org>; Tue, 6 May 2008 09:32:30 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m46DWULO184838
	for <linux-mm@kvack.org>; Tue, 6 May 2008 07:32:30 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m46DWPVK005282
	for <linux-mm@kvack.org>; Tue, 6 May 2008 07:32:25 -0600
Date: Tue, 6 May 2008 06:32:24 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [patch 2/2] fix SMP data race in pagetable setup vs walking
Message-ID: <20080506133224.GD9443@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20080505112021.GC5018@wotan.suse.de> <20080505121240.GD5018@wotan.suse.de> <20080505143547.GD14809@linux.vnet.ibm.com> <20080506093823.GD10141@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080506093823.GD10141@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-arch@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 06, 2008 at 11:38:24AM +0200, Nick Piggin wrote:
> On Mon, May 05, 2008 at 07:35:47AM -0700, Paul E. McKenney wrote:
> > On Mon, May 05, 2008 at 02:12:40PM +0200, Nick Piggin wrote:
> > > I only converted x86 and powerpc. I think comments in x86 are good because
> > > that is more or less the reference implementation and is where many VM
> > > developers would look to understand mm/ code. Commenting all page table
> > > walking in all other architectures is kind of beyond my skill or patience,
> > > and maintainers might consider this weird "alpha thingy" is below them ;)
> > > But they are quite free to add smp_read_barrier_depends to their own code.
> > > 
> > > Still would like more acks on this before it is applied.
> > 
> > Need ACCESS_ONCE(), as called out below.  Note that without this, the
> > compiler would be within its rights to refetch the pointer, which could
> > cause later dereferences to be using different versions of the structure.
> > I suspect that there are not many pieces of code anticipating that sort
> > of abuse...
> 
> I'm wondering about this... and the problem does not only exist in
> memory ordering situations, but also just when using a single loaded
> value in a lot of times.
> 
> I'd be slightly worried about requiring this of threaded code. Even
> the regular memory ordering bugs we even have in core mm code is kind of
> annoying (and it is by no means just this current bug).
> 
> Is it such an improvement to refetch a pointer versus spilling to stack?
> Can we just ask gcc for a -multithreading-for-dummies mode?

I have thus far not been successful on this one in the general case.
It would be nice to be able to tell gcc that you really mean it when
you assign to a local variable...

> > > --
> > > 
> > > There is a possible data race in the page table walking code. After the split
> > > ptlock patches, it actually seems to have been introduced to the core code, but
> > > even before that I think it would have impacted some architectures (powerpc and
> > > sparc64, at least, walk the page tables without taking locks eg. see
> > > find_linux_pte()).
> > > 
> > > The race is as follows:
> > > The pte page is allocated, zeroed, and its struct page gets its spinlock
> > > initialized. The mm-wide ptl is then taken, and then the pte page is inserted
> > > into the pagetables.
> > > 
> > > At this point, the spinlock is not guaranteed to have ordered the previous
> > > stores to initialize the pte page with the subsequent store to put it in the
> > > page tables. So another Linux page table walker might be walking down (without
> > > any locks, because we have split-leaf-ptls), and find that new pte we've
> > > inserted. It might try to take the spinlock before the store from the other
> > > CPU initializes it. And subsequently it might read a pte_t out before stores
> > > from the other CPU have cleared the memory.
> > > 
> > > There seem to be similar races in higher levels of the page tables, but they
> > > obviously don't involve the spinlock, but one could see uninitialized memory.
> > > 
> > > Arch code and hardware pagetable walkers that walk the pagetables without
> > > locks could see similar uninitialized memory problems (regardless of whether
> > > we have split ptes or not).
> > > 
> > > Fortunately, on x86 (except OOSTORE), nothing needs to be done, because stores
> > > are in order, and so are loads.
> > > 
> > > I prefer to put the barriers in core code, because that's where the higher
> > > level logic happens, but the page table accessors are per-arch, and open-coding
> > > them everywhere I don't think is an option.
> > > 
> > > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > > 
> > > Index: linux-2.6/include/asm-x86/pgtable_32.h
> > > ===================================================================
> > > --- linux-2.6.orig/include/asm-x86/pgtable_32.h
> > > +++ linux-2.6/include/asm-x86/pgtable_32.h
> > > @@ -133,7 +133,12 @@ extern int pmd_bad(pmd_t pmd);
> > >   * pgd_offset() returns a (pgd_t *)
> > >   * pgd_index() is used get the offset into the pgd page's array of pgd_t's;
> > >   */
> > > -#define pgd_offset(mm, address) ((mm)->pgd + pgd_index((address)))
> > > +#define pgd_offset(mm, address)						\
> > > +({									\
> > > +	pgd_t *ret = ((mm)->pgd + pgd_index((address)));		\
> > 
> > +	pgd_t *ret = (ACCESS_ONCE((mm)->pgd) + pgd_index((address)));	\
> > 
> > Without this change, the compiler could refetch mm->pgd.
> 
> You mean:
> ret = pgd_offset();
> pgd = *ret;
> x = pgd;
> y = pgd;
> x might != y because pgd might have been recalculated?

The example would need to be more complex, but in general, yes.
Something like the following:

ret = pgd_offset();
pgd = *ret;
x = pgd;
/* code with lots of register pressure. */
y = pgd;


> In that case it isn't really an ordering issue between two variables,
> but an issue within a single variable. And I'm not exactly sure we want
> to go down the path of trying to handle this. At least it probably belongs
> in a different patch.

Well, I have seen this sort of thing in real life with gcc, so I can't say
that I agree...  I was quite surprised the first time around!

> > It is not clear to me why we double-nest the parentheses around "address".
> 
> Typo maybe. I didn't want to make unnecessary changes.

Fair enough.

> > Also might want to either make this an inline function or use a
> > more-obscure name than "ret".
> 
> Hmm, inlines might be difficult as Hugh points out. I'll add a couple of
> underscores though ;)

Works for me!!!

> > Similar changes are needed for the rest of these.
> 
> Thanks. I'll try to improve them.

Sounds good!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
