Date: Mon, 7 Jul 2008 22:11:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/6] mm: Allow architectures to define additional protection
 bits
In-Reply-To: <1215409956.8970.82.camel@pasglop>
Message-ID: <Pine.LNX.4.64.0807072143200.27181@blonde.site>
References: <20080618223254.966080905@linux.vnet.ibm.com>
 <20080618223328.856102092@linux.vnet.ibm.com>  <20080701015301.3dc8749b.akpm@linux-foundation.org>
  <1214920499.18690.10.camel@norville.austin.ibm.com> <1215409956.8970.82.camel@pasglop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Paul Mackerras <paulus@au1.ibm.com>, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 7 Jul 2008, Benjamin Herrenschmidt wrote:
> On Tue, 2008-07-01 at 13:54 +0000, Dave Kleikamp wrote:
> > On Tue, 2008-07-01 at 01:53 -0700, Andrew Morton wrote:
> > > On Wed, 18 Jun 2008 17:32:55 -0500 shaggy@linux.vnet.ibm.com wrote:
> > > 
> > > > This patch allows architectures to define functions to deal with
> > > > additional protections bits for mmap() and mprotect().
> > > > 
> > > > arch_calc_vm_prot_bits() maps additonal protection bits to vm_flags
> > > > arch_vm_get_page_prot() maps additional vm_flags to the vma's vm_page_prot
> > > > arch_validate_prot() checks for valid values of the protection bits
> > > 
> > > It'd be simpler if Paul were to merge this.  It doesn't conflict with
> > > any pending work.
> > 
> > That works for me.  Paul, I'll send you an updated patchset.
> 
> Please, CC me as I'll handle this merge window.
> 
> > > Acked-by: Andrew Morton <akpm@linux-foundation.org>
> > > 
> > > > Note: vm_get_page_prot() is now pretty ugly.
> > > 
> > > It is.  But afacit it generates the same code for non-powerpc.
> > > 
> > > > Suggestions?
> > > 
> > > nfi.  Let us rub the Hugh-summoning lamp.
> 
> Didn't rub hard enough ? :-)

Sorry, Andrew got the wrong pantomime: I was appearing in Aladdin
a couple of years ago, but this year I'm the Sleeping Beauty.
(Did I hear a grumble of dissent from the back stalls?)

I don't find Dave's patch very handsome, but it gets the job done
so I'd better not carp.  The ugliness in vm_get_page_prot is just
an inevitable consequence of growing beyond the traditional neat
pairing of VM_xxx flags with VM_MAYxxx flags, along with the way
that opaque pgprot_t type becomes occasionally tiresome, as such
opaque types do: I don't think there's a better way of handling
it than Dave has done.

There is a little inconsistency, that arch_calc_vm_prot_bits
and arch_vm_get_page_prot just handle the exceptional flag (SAO),
whereas arch_validate_prot handles all of them; but I don't feel
so strongly about that to suggest resubmission.

And regarding VM_SAO added to include/linux/mm.h in 3/6: although
it's odd to be weaving back and forth between arch-specific and
common, it's already the case that mman definitions and pgtable
definitions are arch-specific but mm.h common: I'm much happier
to have VM_SAO defined once there as Dave has it, than get into
arch-specific vm_flags.

Is someone going to be asking for PROT_WC shortly?

Hugh

> 
> Cheers,
> Ben.
> 
> > > > Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
> > > > ---
> > > > 
> > > >  include/linux/mman.h |   28 +++++++++++++++++++++++++++-
> > > >  mm/mmap.c            |    5 +++--
> > > >  mm/mprotect.c        |    2 +-
> > > >  3 files changed, 31 insertions(+), 4 deletions(-)
> > > > 
> > > > Index: linux-2.6.26-rc5/include/linux/mman.h
> > > > ===================================================================
> > > > --- linux-2.6.26-rc5.orig/include/linux/mman.h
> > > > +++ linux-2.6.26-rc5/include/linux/mman.h
> > > > @@ -34,6 +34,31 @@ static inline void vm_unacct_memory(long
> > > >  }
> > > >  
> > > >  /*
> > > > + * Allow architectures to handle additional protection bits
> > > > + */
> > > > +
> > > > +#ifndef arch_calc_vm_prot_bits
> > > > +#define arch_calc_vm_prot_bits(prot) 0
> > > > +#endif
> > > > +
> > > > +#ifndef arch_vm_get_page_prot
> > > > +#define arch_vm_get_page_prot(vm_flags) __pgprot(0)
> > > > +#endif
> > > > +
> > > > +#ifndef arch_validate_prot
> > > > +/*
> > > > + * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
> > > > + * already been masked out.
> > > > + *
> > > > + * Returns true if the prot flags are valid
> > > > + */
> > > > +static inline int arch_validate_prot(unsigned long prot)
> > > > +{
> > > > +	return (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM)) == 0;
> > > > +}
> > > 
> > > Officially we should now have
> > > 
> > > #define arch_validate_prot arch_validate_prot
> > > 
> > > here.
> > 
> > No problem.
> > 
> > > > +#endif
> > > > +
> > > > +/*
> > > >   * Optimisation macro.  It is equivalent to:
> > > >   *      (x & bit1) ? bit2 : 0
> > > >   * but this version is faster.
> > > > @@ -51,7 +76,8 @@ calc_vm_prot_bits(unsigned long prot)
> > > >  {
> > > >  	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
> > > >  	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
> > > > -	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC );
> > > > +	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC) |
> > > > +	       arch_calc_vm_prot_bits(prot);
> > > >  }
> > > >  
> > > >  /*
> > > > Index: linux-2.6.26-rc5/mm/mmap.c
> > > > ===================================================================
> > > > --- linux-2.6.26-rc5.orig/mm/mmap.c
> > > > +++ linux-2.6.26-rc5/mm/mmap.c
> > > > @@ -72,8 +72,9 @@ pgprot_t protection_map[16] = {
> > > >  
> > > >  pgprot_t vm_get_page_prot(unsigned long vm_flags)
> > > >  {
> > > > -	return protection_map[vm_flags &
> > > > -				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
> > > > +	return __pgprot(pgprot_val(protection_map[vm_flags &
> > > > +				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
> > > > +			pgprot_val(arch_vm_get_page_prot(vm_flags)));
> > > >  }
> > > >  EXPORT_SYMBOL(vm_get_page_prot);
> > > >  
> > > > Index: linux-2.6.26-rc5/mm/mprotect.c
> > > > ===================================================================
> > > > --- linux-2.6.26-rc5.orig/mm/mprotect.c
> > > > +++ linux-2.6.26-rc5/mm/mprotect.c
> > > > @@ -239,7 +239,7 @@ sys_mprotect(unsigned long start, size_t
> > > >  	end = start + len;
> > > >  	if (end <= start)
> > > >  		return -ENOMEM;
> > > > -	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM))
> > > > +	if (!arch_validate_prot(prot))
> > > >  		return -EINVAL;
> > > >  
> > > >  	reqprot = prot;
> > > > 
> > > > -- 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
