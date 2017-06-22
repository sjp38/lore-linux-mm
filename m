Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 688486B0292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 05:22:08 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u127so22190760itg.11
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:22:08 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 33si894168iod.148.2017.06.22.02.22.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 02:22:07 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id h134so3384650iof.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 02:22:07 -0700 (PDT)
Message-ID: <1498123263.7935.3.camel@gmail.com>
Subject: Re: [RFC v3 01/23] powerpc: Free up four 64K PTE bits in 4K backed
 HPTE pages
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 22 Jun 2017 19:21:03 +1000
In-Reply-To: <1498095579-6790-2-git-send-email-linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
	 <1498095579-6790-2-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Wed, 2017-06-21 at 18:39 -0700, Ram Pai wrote:
> Rearrange 64K PTE bits to  free  up  bits 3, 4, 5  and  6,
> in the 4K backed HPTE pages. These bits continue to be used
> for 64K backed HPTE pages in this patch,  but will be freed
> up in the next patch. The  bit  numbers  are big-endian  as
> defined in the ISA3.0
> 
> The patch does the following change to the 64K PTE format
>

Why can't we stuff the bits in the VMA and retrieve it from there?
Basically always get a minor fault in hash and for keys handle
the fault in do_page_fault() and handle the keys from the VMA?
 
> H_PAGE_BUSY moves from bit 3 to bit 9
> H_PAGE_F_SECOND which occupied bit 4 moves to the second part
> 	of the pte.
> H_PAGE_F_GIX which  occupied bit 5, 6 and 7 also moves to the
> 	second part of the pte.
> 
> the four  bits((H_PAGE_F_SECOND|H_PAGE_F_GIX) that represent a slot
> is  initialized  to  0xF  indicating  an invalid  slot.  If  a HPTE
> gets cached in a 0xF  slot(i.e  7th  slot  of  secondary),  it   is
> released immediately. In  other  words, even  though   0xF   is   a
> valid slot we discard  and consider it as an invalid
> slot;i.e HPTE(). This  gives  us  an opportunity to not
> depend on a bit in the primary PTE in order to determine the
> validity of a slot.

This is not clear, could you please rephrase? What is the bit in the
primary key we rely on?

> 
> When  we  release  a    HPTE   in the 0xF   slot we also   release a
> legitimate primary   slot  and    unmap    that  entry. This  is  to
> ensure  that we do get a   legimate   non-0xF  slot the next time we
> retry for a slot.
> 
> Though treating 0xF slot as invalid reduces the number of available
> slots  and  may  have an effect  on the performance, the probabilty
> of hitting a 0xF is extermely low.
> 
> Compared  to the current scheme, the above described scheme reduces
> the number of false hash table updates  significantly  and  has the
> added  advantage  of  releasing  four  valuable  PTE bits for other
> purpose.
> 
> This idea was jointly developed by Paul Mackerras, Aneesh, Michael
> Ellermen and myself.
>

It would be helpful if you had a text diagram explaining the PTE bits
before and after.
 
> 4K PTE format remain unchanged currently.
>

The code seems to be doing a lot more than the changelog suggests. A few
functions are completely removed, common code between 64K and 4K has been
split under #ifndef. It would be good to call all of these out.
 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> 
> Conflicts:
> 	arch/powerpc/include/asm/book3s/64/hash.h
> ---
>  arch/powerpc/include/asm/book3s/64/hash-4k.h  |  7 +++
>  arch/powerpc/include/asm/book3s/64/hash-64k.h | 17 ++++---
>  arch/powerpc/include/asm/book3s/64/hash.h     | 12 +++--
>  arch/powerpc/mm/hash64_64k.c                  | 70 +++++++++++++++------------
>  arch/powerpc/mm/hash_utils_64.c               |  4 +-
>  5 files changed, 66 insertions(+), 44 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> index b4b5e6b..9c2c8f1 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> @@ -16,6 +16,13 @@
>  #define H_PUD_TABLE_SIZE	(sizeof(pud_t) << H_PUD_INDEX_SIZE)
>  #define H_PGD_TABLE_SIZE	(sizeof(pgd_t) << H_PGD_INDEX_SIZE)
>  
> +#define H_PAGE_F_SECOND        _RPAGE_RSV2     /* HPTE is in 2ndary HPTEG */
> +#define H_PAGE_F_GIX           (_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
> +#define H_PAGE_F_GIX_SHIFT     56
> +
> +#define H_PAGE_BUSY	_RPAGE_RSV1     /* software: PTE & hash are busy */
> +#define H_PAGE_HASHPTE	_RPAGE_RPN43    /* PTE has associated HPTE */
> +
>  /* PTE flags to conserve for HPTE identification */
>  #define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_HASHPTE | \
>  			 H_PAGE_F_SECOND | H_PAGE_F_GIX)
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index 9732837..3f49941 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -10,20 +10,21 @@
>   * 64k aligned address free up few of the lower bits of RPN for us
>   * We steal that here. For more deatils look at pte_pfn/pfn_pte()
>   */
> -#define H_PAGE_COMBO	_RPAGE_RPN0 /* this is a combo 4k page */
> -#define H_PAGE_4K_PFN	_RPAGE_RPN1 /* PFN is for a single 4k page */
> +#define H_PAGE_COMBO   _RPAGE_RPN0 /* this is a combo 4k page */
> +#define H_PAGE_4K_PFN  _RPAGE_RPN1 /* PFN is for a single 4k page */

It would be good to split out these as cleanups, I can't see anything
change above, its a little confusing to review it.

> +#define H_PAGE_F_SECOND	_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
> +#define H_PAGE_F_GIX	(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
> +#define H_PAGE_F_GIX_SHIFT	56
> +
> +#define H_PAGE_BUSY	_RPAGE_RPN42     /* software: PTE & hash are busy */
> +#define H_PAGE_HASHPTE	_RPAGE_RPN43    /* PTE has associated HPTE */
> +
>  /*
>   * We need to differentiate between explicit huge page and THP huge
>   * page, since THP huge page also need to track real subpage details
>   */
>  #define H_PAGE_THP_HUGE  H_PAGE_4K_PFN
>  
> -/*
> - * Used to track subpage group valid if H_PAGE_COMBO is set
> - * This overloads H_PAGE_F_GIX and H_PAGE_F_SECOND
> - */
> -#define H_PAGE_COMBO_VALID	(H_PAGE_F_GIX | H_PAGE_F_SECOND)
> -
>  /* PTE flags to conserve for HPTE identification */
>  #define _PAGE_HPTEFLAGS (H_PAGE_BUSY | H_PAGE_F_SECOND | \
>  			 H_PAGE_F_GIX | H_PAGE_HASHPTE | H_PAGE_COMBO)
> diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
> index 4e957b0..ac049de 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash.h
> @@ -8,11 +8,8 @@
>   *
>   */
>  #define H_PTE_NONE_MASK		_PAGE_HPTEFLAGS
> -#define H_PAGE_F_GIX_SHIFT	56
> -#define H_PAGE_BUSY		_RPAGE_RSV1 /* software: PTE & hash are busy */
> -#define H_PAGE_F_SECOND		_RPAGE_RSV2	/* HPTE is in 2ndary HPTEG */
> -#define H_PAGE_F_GIX		(_RPAGE_RSV3 | _RPAGE_RSV4 | _RPAGE_RPN44)
> -#define H_PAGE_HASHPTE		_RPAGE_RPN43	/* PTE has associated HPTE */
> +
> +#define INIT_HIDX (~0x0UL)
>  
>  #ifdef CONFIG_PPC_64K_PAGES
>  #include <asm/book3s/64/hash-64k.h>
> @@ -160,6 +157,11 @@ static inline int hash__pte_none(pte_t pte)
>  	return (pte_val(pte) & ~H_PTE_NONE_MASK) == 0;
>  }
>  
> +static inline bool hpte_soft_invalid(unsigned long slot)
> +{
> +	return ((slot & 0xfUL) == 0xfUL);
> +}
> +
>  /* This low level function performs the actual PTE insertion
>   * Setting the PTE depends on the MMU type and other factors. It's
>   * an horrible mess that I'm not going to try to clean up now but
> diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
> index 1a68cb1..a16cd28 100644
> --- a/arch/powerpc/mm/hash64_64k.c
> +++ b/arch/powerpc/mm/hash64_64k.c
> @@ -20,29 +20,7 @@
>   */
>  bool __rpte_sub_valid(real_pte_t rpte, unsigned long index)
>  {
> -	unsigned long g_idx;
> -	unsigned long ptev = pte_val(rpte.pte);
> -
> -	g_idx = (ptev & H_PAGE_COMBO_VALID) >> H_PAGE_F_GIX_SHIFT;
> -	index = index >> 2;
> -	if (g_idx & (0x1 << index))
> -		return true;
> -	else
> -		return false;
> -}
> -/*
> - * index from 0 - 15
> - */
> -static unsigned long mark_subptegroup_valid(unsigned long ptev, unsigned long index)
> -{
> -	unsigned long g_idx;
> -
> -	if (!(ptev & H_PAGE_COMBO))
> -		return ptev;
> -	index = index >> 2;
> -	g_idx = 0x1 << index;
> -
> -	return ptev | (g_idx << H_PAGE_F_GIX_SHIFT);
> +	return !(hpte_soft_invalid(rpte.hidx >> (index << 2)));
>  }
>  
>  int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
> @@ -50,12 +28,11 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
>  		   int ssize, int subpg_prot)
>  {
>  	real_pte_t rpte;
> -	unsigned long *hidxp;
>  	unsigned long hpte_group;
>  	unsigned int subpg_index;
> -	unsigned long rflags, pa, hidx;
> +	unsigned long rflags, pa;
>  	unsigned long old_pte, new_pte, subpg_pte;
> -	unsigned long vpn, hash, slot;
> +	unsigned long vpn, hash, slot, gslot;
>  	unsigned long shift = mmu_psize_defs[MMU_PAGE_4K].shift;
>  
>  	/*
> @@ -116,8 +93,8 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
>  		 * On hash insert failure we use old pte value and we don't
>  		 * want slot information there if we have a insert failure.
>  		 */
> -		old_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
> -		new_pte &= ~(H_PAGE_HASHPTE | H_PAGE_F_GIX | H_PAGE_F_SECOND);
> +		old_pte &= ~(H_PAGE_HASHPTE);
> +		new_pte &= ~(H_PAGE_HASHPTE);
>  		goto htab_insert_hpte;
>  	}
>  	/*
> @@ -148,6 +125,15 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
>  	}
>  
>  htab_insert_hpte:
> +
> +	/*
> +	 * initialize all hidx entries to a invalid value,
> +	 * the first time the PTE is about to allocate
> +	 * a 4K hpte
> +	 */
> +	if (!(old_pte & H_PAGE_COMBO))
> +		rpte.hidx = INIT_HIDX;
> +
>  	/*
>  	 * handle H_PAGE_4K_PFN case
>  	 */
> @@ -172,15 +158,39 @@ int __hash_page_4K(unsigned long ea, unsigned long access, unsigned long vsid,
>  	 * Primary is full, try the secondary
>  	 */
>  	if (unlikely(slot == -1)) {
> +		bool soft_invalid;
> +
>  		hpte_group = ((~hash & htab_hash_mask) * HPTES_PER_GROUP) & ~0x7UL;
>  		slot = mmu_hash_ops.hpte_insert(hpte_group, vpn, pa,
>  						rflags, HPTE_V_SECONDARY,
>  						MMU_PAGE_4K, MMU_PAGE_4K,
>  						ssize);
> -		if (slot == -1) {
> -			if (mftb() & 0x1)
> +
> +		soft_invalid = hpte_soft_invalid(slot);
> +		if (unlikely(soft_invalid)) {
> +			/* we got a valid slot from a hardware point of view.
> +			 * but we cannot use it, because we use this special
> +			 * value; as defined by hpte_soft_invalid(),
> +			 * to track invalid slots. We cannot use it.
> +			 * So invalidate it.
> +			 */

Comment style -- needs fixing

> +			gslot = slot & _PTEIDX_GROUP_IX;
> +			mmu_hash_ops.hpte_invalidate(hpte_group+gslot, vpn,
> +				MMU_PAGE_4K, MMU_PAGE_4K,
> +				ssize, 0);
> +		}
> +
> +		if (unlikely(slot == -1 || soft_invalid)) {
> +			/* for soft invalid slot lets ensure that we
> +			 * release a slot from the primary, with the
> +			 * hope that we will acquire that slot next
> +			 * time we try. This will ensure that we dont
> +			 * get the same soft-invalid slot.
> +			 */
> +			if (soft_invalid || (mftb() & 0x1))
>  				hpte_group = ((hash & htab_hash_mask) *
>  					      HPTES_PER_GROUP) & ~0x7UL;
> +
>  			mmu_hash_ops.hpte_remove(hpte_group);
>  			/*
>  			 * FIXME!! Should be try the group from which we removed ?
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> index f2095ce..1b494d0 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -975,8 +975,9 @@ void __init hash__early_init_devtree(void)
>  
>  void __init hash__early_init_mmu(void)
>  {
> +#ifndef CONFIG_PPC_64K_PAGES
>  	/*
> -	 * We have code in __hash_page_64K() and elsewhere, which assumes it can
> +	 * We have code in __hash_page_4K() and elsewhere, which assumes it can
>  	 * do the following:
>  	 *   new_pte |= (slot << H_PAGE_F_GIX_SHIFT) & (H_PAGE_F_SECOND | H_PAGE_F_GIX);
>  	 *
> @@ -987,6 +988,7 @@ void __init hash__early_init_mmu(void)
>  	 * with a BUILD_BUG_ON().
>  	 */
>  	BUILD_BUG_ON(H_PAGE_F_SECOND != (1ul  << (H_PAGE_F_GIX_SHIFT + 3)));
> +#endif /* CONFIG_PPC_64K_PAGES */
>  
>  	htab_init_page_sizes();
>

Balbir Singh.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
