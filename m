Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id E844E6B0006
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 00:50:58 -0500 (EST)
Date: Mon, 4 Mar 2013 16:48:48 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 09/24] powerpc: Decode the pte-lp-encoding bits
 correctly.
Message-ID: <20130304054848.GE27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1361865914-13911-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, Feb 26, 2013 at 01:34:59PM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We look at both the segment base page size and actual page size and store
> the pte-lp-encodings in an array per base page size.
> 
> We also update all relevant functions to take actual page size argument
> so that we can use the correct PTE LP encoding in HPTE. This should also
> get the basic Multiple Page Size per Segment (MPSS) support. This is needed
> to enable THP on ppc64.

Mostly looks OK, comments below...

> +/*
> + * HPTE LP details
> + */
> +#define LP_SHIFT	12
> +#define LP_BITS		8
> +#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)

The reader might be wondering at this point what "LP" is; be kind and
make it "large page" in the comment for them.

> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
> index 71d0c90..48f6d99 100644
> --- a/arch/powerpc/kvm/book3s_hv.c
> +++ b/arch/powerpc/kvm/book3s_hv.c
> @@ -1515,7 +1515,7 @@ static void kvmppc_add_seg_page_size(struct kvm_ppc_one_seg_page_size **sps,
>  	(*sps)->page_shift = def->shift;
>  	(*sps)->slb_enc = def->sllp;
>  	(*sps)->enc[0].page_shift = def->shift;
> -	(*sps)->enc[0].pte_enc = def->penc;
> +	(*sps)->enc[0].pte_enc = def->penc[linux_psize];
>  	(*sps)++;
>  }

This will only return the entries where actual page size == base page
size, which basically means that KVM guests won't be able to use
MPSS.  We will need to return multiple entries in that case.

> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
> +{
> +	unsigned int mask;
> +	int i, penc, shift;
> +	/* Look at the 8 bit LP value */
> +	unsigned int lp = (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
> +
> +	penc = 0;
> +	for (i = 0; i < MMU_PAGE_COUNT; i++) {
> +		/* valid entries have a shift value */
> +		if (!mmu_psize_defs[i].shift)
> +			continue;
> +
> +		/* encoding bits per actual page size */
> +		shift = mmu_psize_defs[i].shift - 11;
> +		if (shift > 9)
> +			shift = 9;
> +		mask = (1 << shift) - 1;
> +		if ((lp & mask) == mmu_psize_defs[psize].penc[i])
> +			return i;
> +	}
> +	return -1;
> +}

This doesn't look right to me.  First, it's not clear what the 11 and
9 refer to, and I think the 9 should be LP_BITS (i.e. 8).  Secondly,
the mask for the comparison needs to depend on the actual page size
not the base page size.

I strongly suggest you pull out this code together with
native_hpte_insert into a little userspace test program that runs
through all the possible page size combinations, creating an HPTE and
then decoding it with hpte_actual_psize() to check that you get back
the correct actual page size.

>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
> -			int *psize, int *ssize, unsigned long *vpn)
> +			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>  {
>  	unsigned long avpn, pteg, vpi;
>  	unsigned long hpte_r = hpte->r;
>  	unsigned long hpte_v = hpte->v;
>  	unsigned long vsid, seg_off;
> -	int i, size, shift, penc;
> +	int i, size, a_size = MMU_PAGE_4K, shift, penc;
>  
>  	if (!(hpte_v & HPTE_V_LARGE))
>  		size = MMU_PAGE_4K;
> @@ -395,12 +422,13 @@ static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>  			/* valid entries have a shift value */
>  			if (!mmu_psize_defs[size].shift)
>  				continue;
> -
> -			if (penc == mmu_psize_defs[size].penc)
> -				break;
> +			for (a_size = 0; a_size < MMU_PAGE_COUNT; a_size++)
> +				if (penc == mmu_psize_defs[size].penc[a_size])
> +					goto out;

Once again I don't think this is correct, since the number of bits in
the page size encoding depends on the page size.  In fact the
calculation of penc in that function looks completely bogus to me (not
that that is code that you have written or modified, but it looks to
me like it needs fixing).

>  static int __init htab_dt_scan_page_sizes(unsigned long node,
>  					  const char *uname, int depth,
>  					  void *data)
> @@ -294,60 +318,57 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
>  		size /= 4;
>  		cur_cpu_spec->mmu_features &= ~(MMU_FTR_16M_PAGE);
>  		while(size > 0) {
> -			unsigned int shift = prop[0];
> +			unsigned int base_shift = prop[0];
>  			unsigned int slbenc = prop[1];
>  			unsigned int lpnum = prop[2];
> -			unsigned int lpenc = 0;
>  			struct mmu_psize_def *def;
> -			int idx = -1;
> +			int idx, base_idx;
>  
>  			size -= 3; prop += 3;
> -			while(size > 0 && lpnum) {
> -				if (prop[0] == shift)
> -					lpenc = prop[1];
> +			base_idx = get_idx_from_shift(base_shift);
> +			if (base_idx < 0) {
> +				/*
> +				 * skip the pte encoding also
> +				 */
>  				prop += 2; size -= 2;
> -				lpnum--;
> +				continue;
>  			}
> -			switch(shift) {
> -			case 0xc:
> -				idx = MMU_PAGE_4K;
> -				break;
> -			case 0x10:
> -				idx = MMU_PAGE_64K;
> -				break;
> -			case 0x14:
> -				idx = MMU_PAGE_1M;
> -				break;
> -			case 0x18:
> -				idx = MMU_PAGE_16M;
> +			def = &mmu_psize_defs[base_idx];
> +			if (base_idx == MMU_PAGE_16M)
>  				cur_cpu_spec->mmu_features |= MMU_FTR_16M_PAGE;
> -				break;
> -			case 0x22:
> -				idx = MMU_PAGE_16G;
> -				break;
> -			}
> -			if (idx < 0)
> -				continue;
> -			def = &mmu_psize_defs[idx];
> -			def->shift = shift;
> -			if (shift <= 23)
> +
> +			def->shift = base_shift;
> +			if (base_shift <= 23)
>  				def->avpnm = 0;
>  			else
> -				def->avpnm = (1 << (shift - 23)) - 1;
> +				def->avpnm = (1 << (base_shift - 23)) - 1;
>  			def->sllp = slbenc;
> -			def->penc = lpenc;
> -			/* We don't know for sure what's up with tlbiel, so
> +			/*
> +			 * We don't know for sure what's up with tlbiel, so
>  			 * for now we only set it for 4K and 64K pages
>  			 */
> -			if (idx == MMU_PAGE_4K || idx == MMU_PAGE_64K)
> +			if (base_idx == MMU_PAGE_4K || base_idx == MMU_PAGE_64K)
>  				def->tlbiel = 1;
>  			else
>  				def->tlbiel = 0;
>  
> -			DBG(" %d: shift=%02x, sllp=%04lx, avpnm=%08lx, "
> -			    "tlbiel=%d, penc=%d\n",
> -			    idx, shift, def->sllp, def->avpnm, def->tlbiel,
> -			    def->penc);
> +			while (size > 0 && lpnum) {
> +				unsigned int shift = prop[0];
> +				unsigned int penc  = prop[1];
> +
> +				prop += 2; size -= 2;
> +				lpnum--;
> +
> +				idx = get_idx_from_shift(shift);
> +				if (idx < 0)
> +					continue;
> +
> +				def->penc[idx] = penc;
> +				DBG(" %d: shift=%02x, sllp=%04lx, "
> +				    "avpnm=%08lx, tlbiel=%d, penc=%d\n",
> +				    idx, shift, def->sllp, def->avpnm,
> +				    def->tlbiel, def->penc[idx]);
> +			}

I don't see where in this function you set the penc[] elements for
invalid actual page sizes to -1.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
