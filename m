Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3D0646B0005
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 13:17:18 -0500 (EST)
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Wed, 6 Feb 2013 18:15:40 -0000
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r16IGsj233161274
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 18:16:55 GMT
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r16HGUpp012027
	for <linux-mm@kvack.org>; Wed, 6 Feb 2013 12:16:30 -0500
Date: Wed, 6 Feb 2013 10:16:56 -0800
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [PATCH] s390/mm: implement software dirty bits
Message-ID: <20130206101656.4d45b80f@mschwide>
In-Reply-To: <20130206112111.GP21389@suse.de>
References: <1360087925-8456-1-git-send-email-schwidefsky@de.ibm.com>
	<1360087925-8456-3-git-send-email-schwidefsky@de.ibm.com>
	<20130206112111.GP21389@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-s390@vger.kernel.org, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

Hi Mel,

On Wed, 6 Feb 2013 11:21:11 +0000
Mel Gorman <mgorman@suse.de> wrote:

> On Tue, Feb 05, 2013 at 10:12:05AM -0800, Martin Schwidefsky wrote:
> > The s390 architecture is unique in respect to dirty page detection,
> > it uses the change bit in the per-page storage key to track page
> > modifications. All other architectures track dirty bits by means
> > of page table entries. This property of s390 has caused numerous
> > problems in the past, e.g. see git commit ef5d437f71afdf4a
> > "mm: fix XFS oops due to dirty pages without buffers on s390".
> > 
> > To avoid future issues in regard to per-page dirty bits convert
> > s390 to a fault based software dirty bit detection mechanism. All
> > user page table entries which are marked as clean will be hardware
> > read-only, even if the pte is supposed to be writable. A write by
> > the user process will trigger a protection fault which will cause
> > the user pte to be marked as dirty and the hardware read-only bit
> > is removed.
> > 
> > With this change the dirty bit in the storage key is irrelevant
> > for Linux as a host, but the storage key is still required for
> > KVM guests. The effect is that page_test_and_clear_dirty and the
> > related code can be removed. The referenced bit in the storage
> > key is still used by the page_test_and_clear_young primitive to
> > provide page age information.
> > 
> > For page cache pages of mappings with mapping_cap_account_dirty
> > there will not be any change in behavior as the dirty bit tracking
> > already uses read-only ptes to control the amount of dirty pages.
> > Only for swap cache pages and pages of mappings without
> > mapping_cap_account_dirty there can be additional protection faults.
> > To avoid an excessive number of additional faults the mk_pte
> > primitive checks for PageDirty if the pgprot value allows for writes
> > and pre-dirties the pte. That avoids all additional faults for
> > tmpfs and shmem pages until these pages are added to the swap cache.
> > 
> > Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> 
> I have a few clarifications below just to make sure I'm reading it right
> but I think it looks fine and the change to mm/rmap.c is welcome.

It is welcome to me as well. That XFS problem really convinced me that this
is the right way to go.

> > diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> > index 098adbb..2b3d3b6 100644
> > --- a/arch/s390/include/asm/pgtable.h
> > +++ b/arch/s390/include/asm/pgtable.h
> > @@ -29,6 +29,7 @@
> >  #ifndef __ASSEMBLY__
> >  #include <linux/sched.h>
> >  #include <linux/mm_types.h>
> > +#include <linux/page-flags.h>
> >  #include <asm/bug.h>
> >  #include <asm/page.h>
> >  
> > @@ -221,13 +222,15 @@ extern unsigned long MODULES_END;
> >  /* Software bits in the page table entry */
> >  #define _PAGE_SWT	0x001		/* SW pte type bit t */
> >  #define _PAGE_SWX	0x002		/* SW pte type bit x */
> > -#define _PAGE_SWC	0x004		/* SW pte changed bit (for KVM) */
> > -#define _PAGE_SWR	0x008		/* SW pte referenced bit (for KVM) */
> > -#define _PAGE_SPECIAL	0x010		/* SW associated with special page */
> > +#define _PAGE_SWC	0x004		/* SW pte changed bit */
> > +#define _PAGE_SWR	0x008		/* SW pte referenced bit */
> > +#define _PAGE_SWW	0x010		/* SW pte write bit */
> > +#define _PAGE_SPECIAL	0x020		/* SW associated with special page */
> >  #define __HAVE_ARCH_PTE_SPECIAL
> >  
> >  /* Set of bits not changed in pte_modify */
> > -#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_SPECIAL | _PAGE_SWC | _PAGE_SWR)
> > +#define _PAGE_CHG_MASK		(PAGE_MASK | _PAGE_SPECIAL | _PAGE_CO | \
> > +				 _PAGE_SWC | _PAGE_SWR)
> >  
> 
> If I'm reading it right, the _PAGE_CO is bit is what allows you to force
> the hardware to trap even if the PTE says the page is writable. This is
> what necessitates the shuffling of _PAGE_SPECIAL so you have a software
> write bit and a hardware write bit.

No, the _PAGE_CO bit is the change-bit-override. This allows the hardware to
avoid to set the dirty bit in the storage key for a write access over a pte.
It is a optimization, the code would work without _PAGE_CO as well.
The basic idea is to introduce a software bit which indicates the software
view of writable vs. non-writable (the _PAGE_SWW bit). The hardware
_PAGE_RO is used to disallow writes while the pte is clean.

> For existing distributions they might not be able to use this patch for
> bugs like ""mm: fix XFS oops due to dirty pages without buffers on s390"
> because this shuffling of bits will break KABIi but that's not your problem.

I am not really sure if we should backport that change to the existing
distributions. It is a non-trivial change.

> >  /* Six different types of pages. */
> >  #define _PAGE_TYPE_EMPTY	0x400
> > @@ -321,6 +324,7 @@ extern unsigned long MODULES_END;
> >  
> >  /* Bits in the region table entry */
> >  #define _REGION_ENTRY_ORIGIN	~0xfffUL/* region/segment table origin	    */
> > +#define _REGION_ENTRY_RO	0x200	/* region protection bit	    */
> >  #define _REGION_ENTRY_INV	0x20	/* invalid region table entry	    */
> >  #define _REGION_ENTRY_TYPE_MASK	0x0c	/* region/segment table type mask   */
> >  #define _REGION_ENTRY_TYPE_R1	0x0c	/* region first table type	    */
> > @@ -382,9 +386,10 @@ extern unsigned long MODULES_END;
> >   */
> >  #define PAGE_NONE	__pgprot(_PAGE_TYPE_NONE)
> >  #define PAGE_RO		__pgprot(_PAGE_TYPE_RO)
> > -#define PAGE_RW		__pgprot(_PAGE_TYPE_RW)
> > +#define PAGE_RW		__pgprot(_PAGE_TYPE_RO | _PAGE_SWW)
> > +#define PAGE_RWC	__pgprot(_PAGE_TYPE_RW | _PAGE_SWW | _PAGE_SWC)
> >  
> > -#define PAGE_KERNEL	PAGE_RW
> > +#define PAGE_KERNEL	PAGE_RWC
> >  #define PAGE_COPY	PAGE_RO
> >  
> >  /*
> 
> And this combination of page bits looks consistent. The details are
> heavily buried in the arch code so I hope however deals with this area
> in the future spots the changelog. Of course, that guy is likely to be
> you anyway :)

Yep, I will be that guy. With the move of the complexity to handle s390
to the arch implementation even more than before.

> > @@ -631,23 +636,23 @@ static inline pgste_t pgste_update_all(pte_t *ptep, pgste_t pgste)
> >  	bits = skey & (_PAGE_CHANGED | _PAGE_REFERENCED);
> >  	/* Clear page changed & referenced bit in the storage key */
> >  	if (bits & _PAGE_CHANGED)
> > -		page_set_storage_key(address, skey ^ bits, 1);
> > +		page_set_storage_key(address, skey ^ bits, 0);
> >  	else if (bits)
> >  		page_reset_referenced(address);
> >  	/* Transfer page changed & referenced bit to guest bits in pgste */
> >  	pgste_val(pgste) |= bits << 48;		/* RCP_GR_BIT & RCP_GC_BIT */
> >  	/* Get host changed & referenced bits from pgste */
> >  	bits |= (pgste_val(pgste) & (RCP_HR_BIT | RCP_HC_BIT)) >> 52;
> > -	/* Clear host bits in pgste. */
> > +	/* Transfer page changed & referenced bit to kvm user bits */
> > +	pgste_val(pgste) |= bits << 45;		/* KVM_UR_BIT & KVM_UC_BIT */
> > +	/* Clear relevant host bits in pgste. */
> >  	pgste_val(pgste) &= ~(RCP_HR_BIT | RCP_HC_BIT);
> >  	pgste_val(pgste) &= ~(RCP_ACC_BITS | RCP_FP_BIT);
> >  	/* Copy page access key and fetch protection bit to pgste */
> >  	pgste_val(pgste) |=
> >  		(unsigned long) (skey & (_PAGE_ACC_BITS | _PAGE_FP_BIT)) << 56;
> > -	/* Transfer changed and referenced to kvm user bits */
> > -	pgste_val(pgste) |= bits << 45;		/* KVM_UR_BIT & KVM_UC_BIT */
> > -	/* Transfer changed & referenced to pte sofware bits */
> > -	pte_val(*ptep) |= bits << 1;		/* _PAGE_SWR & _PAGE_SWC */
> > +	/* Transfer referenced bit to pte */
> > +	pte_val(*ptep) |= (bits & _PAGE_REFERENCED) << 1;
> >  #endif
> >  	return pgste;
> >  
> > @@ -660,20 +665,25 @@ static inline pgste_t pgste_update_young(pte_t *ptep, pgste_t pgste)
> >  
> >  	if (!pte_present(*ptep))
> >  		return pgste;
> > +	/* Get referenced bit from storage key */
> >  	young = page_reset_referenced(pte_val(*ptep) & PAGE_MASK);
> > -	/* Transfer page referenced bit to pte software bit (host view) */
> > -	if (young || (pgste_val(pgste) & RCP_HR_BIT))
> > +	if (young)
> > +		pgste_val(pgste) |= RCP_GR_BIT;
> > +	/* Get host referenced bit from pgste */
> > +	if (pgste_val(pgste) & RCP_HR_BIT) {
> > +		pgste_val(pgste) &= ~RCP_HR_BIT;
> > +		young = 1;
> > +	}
> > +	/* Transfer referenced bit to kvm user bits and pte */
> > +	if (young) {
> > +		pgste_val(pgste) |= KVM_UR_BIT;
> >  		pte_val(*ptep) |= _PAGE_SWR;
> > -	/* Clear host referenced bit in pgste. */
> > -	pgste_val(pgste) &= ~RCP_HR_BIT;
> > -	/* Transfer page referenced bit to guest bit in pgste */
> > -	pgste_val(pgste) |= (unsigned long) young << 50; /* set RCP_GR_BIT */
> > +	}
> >  #endif
> >  	return pgste;
> > -
> >  }
> >  
> > -static inline void pgste_set_pte(pte_t *ptep, pgste_t pgste, pte_t entry)
> > +static inline void pgste_set_key(pte_t *ptep, pgste_t pgste, pte_t entry)
> >  {
> >  #ifdef CONFIG_PGSTE
> >  	unsigned long address;
> > @@ -687,10 +697,23 @@ static inline void pgste_set_pte(pte_t *ptep, pgste_t pgste, pte_t entry)
> >  	/* Set page access key and fetch protection bit from pgste */
> >  	nkey |= (pgste_val(pgste) & (RCP_ACC_BITS | RCP_FP_BIT)) >> 56;
> >  	if (okey != nkey)
> > -		page_set_storage_key(address, nkey, 1);
> > +		page_set_storage_key(address, nkey, 0);
> >  #endif
> >  }
> >  
> > +static inline void pgste_set_pte(pte_t *ptep, pte_t entry)
> > +{
> > +	if (!MACHINE_HAS_ESOP && (pte_val(entry) & _PAGE_SWW)) {
> > +		/*
> > +		 * Without enhanced suppression-on-protection force
> > +		 * the dirty bit on for all writable ptes.
> > +		 */
> > +		pte_val(entry) |= _PAGE_SWC;
> > +		pte_val(entry) &= ~_PAGE_RO;
> > +	}
> > +	*ptep = entry;
> > +}
> > +
> >  /**
> >   * struct gmap_struct - guest address space
> >   * @mm: pointer to the parent mm_struct
> 
> So establishing a writable PTE clears the hardware RO override as
> well and the changed bit is set so it'll be considered dirty.

Yes, that case for old machines running KVM is a bit unfortunate.
I need to force the changed bit so that the read-only bit can be cleared.
KVM will not work with read-only ptes if the enhanced suppression-on-
protection is not available.
 
> Reading down through the other page tables updates, I couldn't spot a place
> where you were inconsistent with the handling of the hardware _PAGE_CO
> and _PAGE_RO. Writes were allowed when the change bit was already set.
> I couldn't follow it all, particularly around the KVM bits so take it with
> a grain of salt but for me anyway;
> 
> Acked-by: Mel Gorman <mgorman@suse.de>
 
Much appreciated. Thanks Mel.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
