Date: Wed, 28 May 2008 14:28:27 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 2/2] lockless get_user_pages
Message-ID: <20080528122827.GH2630@wotan.suse.de>
References: <20080525144847.GB25747@wotan.suse.de> <20080525145227.GC25747@wotan.suse.de> <20080528113906.GA699@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080528113906.GA699@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, shaggy@austin.ibm.com, jens.axboe@oracle.com, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 12:39:06PM +0100, Andy Whitcroft wrote:
> On Sun, May 25, 2008 at 04:52:27PM +0200, Nick Piggin wrote:
> > 
> > The downside of using fast_gup is that if there is not a pte with the
> > correct permissions for the access, we end up falling back to get_user_pages
> > and so the fast_gup is just extra work. This should not be the common case
> > in performance critical code, I'd hope.
> 
> >From what I can see of the algorithm, as it stops at the first non-present
> page, as long as the optimisation you allude to in the comments was
> implemented the overhead would be much less, and basically constant for
> the failure case.

Right.

 
> See below for my take on that optimisation.
> 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > 
> > ---
> >  arch/x86/mm/Makefile      |    2 
> >  arch/x86/mm/gup.c         |  193 ++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/bio.c                  |    8 -
> >  fs/direct-io.c            |   10 --
> >  fs/splice.c               |   41 ---------
> >  include/asm-x86/uaccess.h |    5 +
> >  include/linux/mm.h        |   19 ++++
> >  7 files changed, 225 insertions(+), 53 deletions(-)
> 
> I do wonder if it would be logical to introduce the generic version and
> the x86 implementation as separate patches as there will be further
> architecture specific implementations.

Yeah it probably would be. Probably also convert call sites over one
at a time too, which would make eg. regressions more bisectable. Will
do that.

 
> > Index: linux-2.6/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.orig/include/linux/mm.h
> > +++ linux-2.6/include/linux/mm.h
> > @@ -12,6 +12,7 @@
> >  #include <linux/prio_tree.h>
> >  #include <linux/debug_locks.h>
> >  #include <linux/mm_types.h>
> > +#include <linux/uaccess.h> /* for __HAVE_ARCH_FAST_GUP */
> >  
> >  struct mempolicy;
> >  struct anon_vma;
> > @@ -830,6 +831,24 @@ extern int mprotect_fixup(struct vm_area
> >  			  struct vm_area_struct **pprev, unsigned long start,
> >  			  unsigned long end, unsigned long newflags);
> >  
> > +#ifndef __HAVE_ARCH_FAST_GUP
> > +/* Should be moved to asm-generic, and architectures can include it if they
> > + * don't implement their own fast_gup.
> > + */
> > +#define fast_gup(start, nr_pages, write, pages)			\
> > +({								\
> > +	struct mm_struct *mm = current->mm;			\
> > +	int ret;						\
> > +								\
> > +	down_read(&mm->mmap_sem);				\
> > +	ret = get_user_pages(current, mm, start, nr_pages,	\
> > +					write, 0, pages, NULL);	\
> > +	up_read(&mm->mmap_sem);					\
> > +								\
> > +	ret;							\
> > +})
> > +#endif
> > +
> 
> Could this not be inserted into linux/uaccess.h?  That feels like a more
> natural fit given the location of the __HAVE_* flag as well.  Feels like
> that would pull something out of mm.h and as call sites convert they
> would necessarily get fixed should they need the additional header.
> 
> I had a quick try and it cirtainly seems like moving it there compiles
> on x86 at least (with the optimised version removed).

I don't know. uaccess seems to me like copying blindly to or from
userspace addresses (basically doesn't otherwise care about how the
vm is implemented). get_user_pages has a more mm.hish feel.

Doesn't bother me so much though.


> > +		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
> > +			goto slow;
> > +	} while (pgdp++, addr = next, addr != end);
> > +	local_irq_enable();
> > +
> > +	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
> > +	return nr;
> > +
> > +	{
> > +		int i, ret;
> > +
> > +slow:
> > +		local_irq_enable();
> > +slow_irqon:
> > +		/* Could optimise this more by keeping what we've already got */
> > +		for (i = 0; i < nr; i++)
> > +			put_page(pages[i]);
> 
> it feels like optimising this would be pretty simple, is not the
> following sufficient:
> 
> 		start += nr << PAGE_SHIFT;
> 		pages += nr;

Yeah... I can't remember whether I had any reservations about that.
But no, I think just doing that should be fine.

I suppose the get_user_pages return value has to be checked too.

> 	
> > +
> > +		down_read(&mm->mmap_sem);
> > +		ret = get_user_pages(current, mm, start,
> > +			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
> > +		up_read(&mm->mmap_sem);

                if (nr > 0) {
                        if (ret < 0)
                                ret = nr;
			else
				ret += nr;
		}

OK. I'll try to implement that and test it.


> > +
> > +		return ret;
> > +	}
> > +}
> > Index: linux-2.6/include/asm-x86/uaccess.h
> > ===================================================================
> > --- linux-2.6.orig/include/asm-x86/uaccess.h
> > +++ linux-2.6/include/asm-x86/uaccess.h
> > @@ -3,3 +3,8 @@
> >  #else
> >  # include "uaccess_64.h"
> >  #endif
> > +
> > +#define __HAVE_ARCH_FAST_GUP
> > +struct page;
> > +int fast_gup(unsigned long start, int nr_pages, int write, struct page **pages);
> > +
> 
> Reviewed-by: Andy Whitcroft <apw@shadowen.org>

Thanks. I'll resubmit after incorporating your comments.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
