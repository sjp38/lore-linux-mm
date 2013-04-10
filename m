Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 2DF696B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 03:19:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Wed, 10 Apr 2013 17:07:49 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DDDE42BB0052
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:19:01 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3A75h291835310
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:05:43 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3A7J0BI024288
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 17:19:00 +1000
Date: Wed, 10 Apr 2013 17:19:15 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V5 08/25] powerpc: Decode the pte-lp-encoding bits
 correctly.
Message-ID: <20130410071915.GI8165@truffula.fritz.box>
References: <1365055083-31956-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1365055083-31956-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="q5r20fdKX+PFtYHw"
Content-Disposition: inline
In-Reply-To: <1365055083-31956-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--q5r20fdKX+PFtYHw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 04, 2013 at 11:27:46AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We look at both the segment base page size and actual page size and store
> the pte-lp-encodings in an array per base page size.
>=20
> We also update all relevant functions to take actual page size argument
> so that we can use the correct PTE LP encoding in HPTE. This should also
> get the basic Multiple Page Size per Segment (MPSS) support. This is need=
ed
> to enable THP on ppc64.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/machdep.h      |    3 +-
>  arch/powerpc/include/asm/mmu-hash64.h   |   33 ++++----
>  arch/powerpc/kvm/book3s_hv.c            |    2 +-
>  arch/powerpc/mm/hash_low_64.S           |   18 ++--
>  arch/powerpc/mm/hash_native_64.c        |  138 ++++++++++++++++++++++---=
------
>  arch/powerpc/mm/hash_utils_64.c         |  121 +++++++++++++++++--------=
--
>  arch/powerpc/mm/hugetlbpage-hash64.c    |    4 +-
>  arch/powerpc/platforms/cell/beat_htab.c |   16 ++--
>  arch/powerpc/platforms/ps3/htab.c       |    6 +-
>  arch/powerpc/platforms/pseries/lpar.c   |    6 +-
>  10 files changed, 230 insertions(+), 117 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/as=
m/machdep.h
> index 19d9d96..6cee6e0 100644
> --- a/arch/powerpc/include/asm/machdep.h
> +++ b/arch/powerpc/include/asm/machdep.h
> @@ -50,7 +50,8 @@ struct machdep_calls {
>  				       unsigned long prpn,
>  				       unsigned long rflags,
>  				       unsigned long vflags,
> -				       int psize, int ssize);
> +				       int psize, int apsize,
> +				       int ssize);
>  	long		(*hpte_remove)(unsigned long hpte_group);
>  	void            (*hpte_removebolted)(unsigned long ea,
>  					     int psize, int ssize);
> diff --git a/arch/powerpc/include/asm/mmu-hash64.h b/arch/powerpc/include=
/asm/mmu-hash64.h
> index 300ac3c..e42f4a3 100644
> --- a/arch/powerpc/include/asm/mmu-hash64.h
> +++ b/arch/powerpc/include/asm/mmu-hash64.h
> @@ -154,7 +154,7 @@ extern unsigned long htab_hash_mask;
>  struct mmu_psize_def
>  {
>  	unsigned int	shift;	/* number of bits */
> -	unsigned int	penc;	/* HPTE encoding */
> +	int		penc[MMU_PAGE_COUNT];	/* HPTE encoding */
>  	unsigned int	tlbiel;	/* tlbiel supported for that page size */
>  	unsigned long	avpnm;	/* bits to mask out in AVPN in the HPTE */
>  	unsigned long	sllp;	/* SLB L||LP (exact mask to use in slbmte) */
> @@ -181,6 +181,13 @@ struct mmu_psize_def
>   */
>  #define VPN_SHIFT	12
> =20
> +/*
> + * HPTE Large Page (LP) details
> + */
> +#define LP_SHIFT	12
> +#define LP_BITS		8
> +#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
> +
>  #ifndef __ASSEMBLY__
> =20
>  static inline int segment_shift(int ssize)
> @@ -237,14 +244,14 @@ static inline unsigned long hpte_encode_avpn(unsign=
ed long vpn, int psize,
> =20
>  /*
>   * This function sets the AVPN and L fields of the HPTE  appropriately
> - * for the page size
> + * using the base page size and actual page size.
>   */
> -static inline unsigned long hpte_encode_v(unsigned long vpn,
> -					  int psize, int ssize)
> +static inline unsigned long hpte_encode_v(unsigned long vpn, int base_ps=
ize,
> +					  int actual_psize, int ssize)
>  {
>  	unsigned long v;
> -	v =3D hpte_encode_avpn(vpn, psize, ssize);
> -	if (psize !=3D MMU_PAGE_4K)
> +	v =3D hpte_encode_avpn(vpn, base_psize, ssize);
> +	if (actual_psize !=3D MMU_PAGE_4K)
>  		v |=3D HPTE_V_LARGE;
>  	return v;
>  }
> @@ -254,19 +261,17 @@ static inline unsigned long hpte_encode_v(unsigned =
long vpn,
>   * for the page size. We assume the pa is already "clean" that is proper=
ly
>   * aligned for the requested page size
>   */
> -static inline unsigned long hpte_encode_r(unsigned long pa, int psize)
> +static inline unsigned long hpte_encode_r(unsigned long pa, int base_psi=
ze,
> +					  int actual_psize)
>  {
> -	unsigned long r;
> -
>  	/* A 4K page needs no special encoding */
> -	if (psize =3D=3D MMU_PAGE_4K)
> +	if (actual_psize =3D=3D MMU_PAGE_4K)
>  		return pa & HPTE_R_RPN;
>  	else {
> -		unsigned int penc =3D mmu_psize_defs[psize].penc;
> -		unsigned int shift =3D mmu_psize_defs[psize].shift;
> -		return (pa & ~((1ul << shift) - 1)) | (penc << 12);
> +		unsigned int penc =3D mmu_psize_defs[base_psize].penc[actual_psize];
> +		unsigned int shift =3D mmu_psize_defs[actual_psize].shift;
> +		return (pa & ~((1ul << shift) - 1)) | (penc << LP_SHIFT);
>  	}
> -	return r;
>  }
> =20
>  /*
> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
> index 71d0c90..48f6d99 100644
> --- a/arch/powerpc/kvm/book3s_hv.c
> +++ b/arch/powerpc/kvm/book3s_hv.c
> @@ -1515,7 +1515,7 @@ static void kvmppc_add_seg_page_size(struct kvm_ppc=
_one_seg_page_size **sps,
>  	(*sps)->page_shift =3D def->shift;
>  	(*sps)->slb_enc =3D def->sllp;
>  	(*sps)->enc[0].page_shift =3D def->shift;
> -	(*sps)->enc[0].pte_enc =3D def->penc;
> +	(*sps)->enc[0].pte_enc =3D def->penc[linux_psize];
>  	(*sps)++;
>  }
> =20
> diff --git a/arch/powerpc/mm/hash_low_64.S b/arch/powerpc/mm/hash_low_64.S
> index abdd5e2..0e980ac 100644
> --- a/arch/powerpc/mm/hash_low_64.S
> +++ b/arch/powerpc/mm/hash_low_64.S
> @@ -196,7 +196,8 @@ htab_insert_pte:
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,0			/* !bolted, !secondary */
>  	li	r8,MMU_PAGE_4K		/* page size */
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_4K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(htab_call_hpte_insert1)
>  	bl	.			/* Patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> @@ -219,7 +220,8 @@ _GLOBAL(htab_call_hpte_insert1)
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
>  	li	r8,MMU_PAGE_4K		/* page size */
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_4K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(htab_call_hpte_insert2)
>  	bl	.			/* Patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> @@ -515,7 +517,8 @@ htab_special_pfn:
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,0			/* !bolted, !secondary */
>  	li	r8,MMU_PAGE_4K		/* page size */
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_4K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(htab_call_hpte_insert1)
>  	bl	.			/* patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> @@ -542,7 +545,8 @@ _GLOBAL(htab_call_hpte_insert1)
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
>  	li	r8,MMU_PAGE_4K		/* page size */
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_4K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(htab_call_hpte_insert2)
>  	bl	.			/* patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> @@ -840,7 +844,8 @@ ht64_insert_pte:
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,0			/* !bolted, !secondary */
>  	li	r8,MMU_PAGE_64K
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_64K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(ht64_call_hpte_insert1)
>  	bl	.			/* patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> @@ -863,7 +868,8 @@ _GLOBAL(ht64_call_hpte_insert1)
>  	mr	r4,r29			/* Retrieve vpn */
>  	li	r7,HPTE_V_SECONDARY	/* !bolted, secondary */
>  	li	r8,MMU_PAGE_64K
> -	ld	r9,STK_PARAM(R9)(r1)	/* segment size */
> +	li	r9,MMU_PAGE_64K		/* actual page size */
> +	ld	r10,STK_PARAM(R9)(r1)	/* segment size */
>  _GLOBAL(ht64_call_hpte_insert2)
>  	bl	.			/* patched by htab_finish_init() */
>  	cmpdi	0,r3,0
> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_nati=
ve_64.c
> index 9d8983a..aa0499b 100644
> --- a/arch/powerpc/mm/hash_native_64.c
> +++ b/arch/powerpc/mm/hash_native_64.c
> @@ -39,7 +39,7 @@
> =20
>  DEFINE_RAW_SPINLOCK(native_tlbie_lock);
> =20
> -static inline void __tlbie(unsigned long vpn, int psize, int ssize)
> +static inline void __tlbie(unsigned long vpn, int psize, int apsize, int=
 ssize)
>  {
>  	unsigned long va;
>  	unsigned int penc;
> @@ -68,7 +68,7 @@ static inline void __tlbie(unsigned long vpn, int psize=
, int ssize)
>  		break;
>  	default:
>  		/* We need 14 to 14 + i bits of va */
> -		penc =3D mmu_psize_defs[psize].penc;
> +		penc =3D mmu_psize_defs[psize].penc[apsize];
>  		va &=3D ~((1ul << mmu_psize_defs[psize].shift) - 1);
>  		va |=3D penc << 12;
>  		va |=3D ssize << 8;
> @@ -80,7 +80,7 @@ static inline void __tlbie(unsigned long vpn, int psize=
, int ssize)
>  	}
>  }
> =20
> -static inline void __tlbiel(unsigned long vpn, int psize, int ssize)
> +static inline void __tlbiel(unsigned long vpn, int psize, int apsize, in=
t ssize)
>  {
>  	unsigned long va;
>  	unsigned int penc;
> @@ -102,7 +102,7 @@ static inline void __tlbiel(unsigned long vpn, int ps=
ize, int ssize)
>  		break;
>  	default:
>  		/* We need 14 to 14 + i bits of va */
> -		penc =3D mmu_psize_defs[psize].penc;
> +		penc =3D mmu_psize_defs[psize].penc[apsize];
>  		va &=3D ~((1ul << mmu_psize_defs[psize].shift) - 1);
>  		va |=3D penc << 12;
>  		va |=3D ssize << 8;
> @@ -114,7 +114,8 @@ static inline void __tlbiel(unsigned long vpn, int ps=
ize, int ssize)
> =20
>  }
> =20
> -static inline void tlbie(unsigned long vpn, int psize, int ssize, int lo=
cal)
> +static inline void tlbie(unsigned long vpn, int psize, int apsize,
> +			 int ssize, int local)
>  {
>  	unsigned int use_local =3D local && mmu_has_feature(MMU_FTR_TLBIEL);
>  	int lock_tlbie =3D !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
> @@ -125,10 +126,10 @@ static inline void tlbie(unsigned long vpn, int psi=
ze, int ssize, int local)
>  		raw_spin_lock(&native_tlbie_lock);
>  	asm volatile("ptesync": : :"memory");
>  	if (use_local) {
> -		__tlbiel(vpn, psize, ssize);
> +		__tlbiel(vpn, psize, apsize, ssize);
>  		asm volatile("ptesync": : :"memory");
>  	} else {
> -		__tlbie(vpn, psize, ssize);
> +		__tlbie(vpn, psize, apsize, ssize);
>  		asm volatile("eieio; tlbsync; ptesync": : :"memory");
>  	}
>  	if (lock_tlbie && !use_local)
> @@ -156,7 +157,7 @@ static inline void native_unlock_hpte(struct hash_pte=
 *hptep)
> =20
>  static long native_hpte_insert(unsigned long hpte_group, unsigned long v=
pn,
>  			unsigned long pa, unsigned long rflags,
> -			unsigned long vflags, int psize, int ssize)
> +			unsigned long vflags, int psize, int apsize, int ssize)
>  {
>  	struct hash_pte *hptep =3D htab_address + hpte_group;
>  	unsigned long hpte_v, hpte_r;
> @@ -183,8 +184,8 @@ static long native_hpte_insert(unsigned long hpte_gro=
up, unsigned long vpn,
>  	if (i =3D=3D HPTES_PER_GROUP)
>  		return -1;
> =20
> -	hpte_v =3D hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
> -	hpte_r =3D hpte_encode_r(pa, psize) | rflags;
> +	hpte_v =3D hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_V=
ALID;
> +	hpte_r =3D hpte_encode_r(pa, psize, apsize) | rflags;
> =20
>  	if (!(vflags & HPTE_V_BOLTED)) {
>  		DBG_LOW(" i=3D%x hpte_v=3D%016lx, hpte_r=3D%016lx\n",
> @@ -244,6 +245,48 @@ static long native_hpte_remove(unsigned long hpte_gr=
oup)
>  	return i;
>  }
> =20
> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
> +{
> +	int i, shift;
> +	unsigned int mask;
> +	/* Look at the 8 bit LP value */
> +	unsigned int lp =3D (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
> +
> +	if (!(hptep->v & HPTE_V_VALID))
> +		return -1;

Folding the validity check into the size check seems confusing to me.

> +	/* First check if it is large page */
> +	if (!(hptep->v & HPTE_V_LARGE))
> +		return MMU_PAGE_4K;
> +
> +	/* start from 1 ignoring MMU_PAGE_4K */
> +	for (i =3D 1; i < MMU_PAGE_COUNT; i++) {
> +		/* valid entries have a shift value */
> +		if (!mmu_psize_defs[i].shift)
> +			continue;

Isn't this check redundant with the one below?

> +		/* invalid penc */
> +		if (mmu_psize_defs[psize].penc[i] =3D=3D -1)
> +			continue;
> +		/*
> +		 * encoding bits per actual page size
> +		 *        PTE LP     actual page size
> +		 *    rrrr rrrz		>=3D8KB
> +		 *    rrrr rrzz		>=3D16KB
> +		 *    rrrr rzzz		>=3D32KB
> +		 *    rrrr zzzz		>=3D64KB
> +		 * .......
> +		 */
> +		shift =3D mmu_psize_defs[i].shift - LP_SHIFT;
> +		if (shift > LP_BITS)
> +			shift =3D LP_BITS;
> +		mask =3D (1 << shift) - 1;
> +		if ((lp & mask) =3D=3D mmu_psize_defs[psize].penc[i])
> +			return i;
> +	}

Shouldn't we have a BUG() or something here.  If we get here we've
somehow created a PTE with LP bits we can't interpret, yes?

> +	return -1;
> +}
> +
>  static long native_hpte_updatepp(unsigned long slot, unsigned long newpp,
>  				 unsigned long vpn, int psize, int ssize,
>  				 int local)
> @@ -251,6 +294,7 @@ static long native_hpte_updatepp(unsigned long slot, =
unsigned long newpp,
>  	struct hash_pte *hptep =3D htab_address + slot;
>  	unsigned long hpte_v, want_v;
>  	int ret =3D 0;
> +	int actual_psize;
> =20
>  	want_v =3D hpte_encode_avpn(vpn, psize, ssize);
> =20
> @@ -260,9 +304,13 @@ static long native_hpte_updatepp(unsigned long slot,=
 unsigned long newpp,
>  	native_lock_hpte(hptep);
> =20
>  	hpte_v =3D hptep->v;
> -
> +	actual_psize =3D hpte_actual_psize(hptep, psize);
> +	if (actual_psize < 0) {
> +		native_unlock_hpte(hptep);
> +		return -1;
> +	}

Wouldn't it make more sense to only do the psize lookup once you've
found a matching hpte?

>  	/* Even if we miss, we need to invalidate the TLB */
> -	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID)) {
> +	if (!HPTE_V_COMPARE(hpte_v, want_v)) {
>  		DBG_LOW(" -> miss\n");
>  		ret =3D -1;
>  	} else {
> @@ -274,7 +322,7 @@ static long native_hpte_updatepp(unsigned long slot, =
unsigned long newpp,
>  	native_unlock_hpte(hptep);
> =20
>  	/* Ensure it is out of the tlb too. */
> -	tlbie(vpn, psize, ssize, local);
> +	tlbie(vpn, psize, actual_psize, ssize, local);
> =20
>  	return ret;
>  }
> @@ -315,6 +363,7 @@ static long native_hpte_find(unsigned long vpn, int p=
size, int ssize)
>  static void native_hpte_updateboltedpp(unsigned long newpp, unsigned lon=
g ea,
>  				       int psize, int ssize)
>  {
> +	int actual_psize;
>  	unsigned long vpn;
>  	unsigned long vsid;
>  	long slot;
> @@ -327,13 +376,16 @@ static void native_hpte_updateboltedpp(unsigned lon=
g newpp, unsigned long ea,
>  	if (slot =3D=3D -1)
>  		panic("could not find page to bolt\n");
>  	hptep =3D htab_address + slot;
> +	actual_psize =3D hpte_actual_psize(hptep, psize);
> +	if (actual_psize < 0)
> +		return;
> =20
>  	/* Update the HPTE */
>  	hptep->r =3D (hptep->r & ~(HPTE_R_PP | HPTE_R_N)) |
>  		(newpp & (HPTE_R_PP | HPTE_R_N));
> =20
>  	/* Ensure it is out of the tlb too. */
> -	tlbie(vpn, psize, ssize, 0);
> +	tlbie(vpn, psize, actual_psize, ssize, 0);
>  }
> =20
>  static void native_hpte_invalidate(unsigned long slot, unsigned long vpn,
> @@ -343,6 +395,7 @@ static void native_hpte_invalidate(unsigned long slot=
, unsigned long vpn,
>  	unsigned long hpte_v;
>  	unsigned long want_v;
>  	unsigned long flags;
> +	int actual_psize;
> =20
>  	local_irq_save(flags);
> =20
> @@ -352,35 +405,38 @@ static void native_hpte_invalidate(unsigned long sl=
ot, unsigned long vpn,
>  	native_lock_hpte(hptep);
>  	hpte_v =3D hptep->v;
> =20
> +	actual_psize =3D hpte_actual_psize(hptep, psize);
> +	if (actual_psize < 0) {
> +		native_unlock_hpte(hptep);
> +		local_irq_restore(flags);
> +		return;
> +	}
>  	/* Even if we miss, we need to invalidate the TLB */
> -	if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID))
> +	if (!HPTE_V_COMPARE(hpte_v, want_v))
>  		native_unlock_hpte(hptep);
>  	else
>  		/* Invalidate the hpte. NOTE: this also unlocks it */
>  		hptep->v =3D 0;
> =20
>  	/* Invalidate the TLB */
> -	tlbie(vpn, psize, ssize, local);
> +	tlbie(vpn, psize, actual_psize, ssize, local);
> =20
>  	local_irq_restore(flags);
>  }
> =20
> -#define LP_SHIFT	12
> -#define LP_BITS		8
> -#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
> -
>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
> -			int *psize, int *ssize, unsigned long *vpn)
> +			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>  {
>  	unsigned long avpn, pteg, vpi;
>  	unsigned long hpte_r =3D hpte->r;
>  	unsigned long hpte_v =3D hpte->v;
>  	unsigned long vsid, seg_off;
> -	int i, size, shift, penc;
> +	int i, size, a_size, shift, penc;
> =20
> -	if (!(hpte_v & HPTE_V_LARGE))
> -		size =3D MMU_PAGE_4K;
> -	else {
> +	if (!(hpte_v & HPTE_V_LARGE)) {
> +		size   =3D MMU_PAGE_4K;
> +		a_size =3D MMU_PAGE_4K;
> +	} else {
>  		for (i =3D 0; i < LP_BITS; i++) {
>  			if ((hpte_r & LP_MASK(i+1)) =3D=3D LP_MASK(i+1))
>  				break;
> @@ -388,19 +444,26 @@ static void hpte_decode(struct hash_pte *hpte, unsi=
gned long slot,
>  		penc =3D LP_MASK(i+1) >> LP_SHIFT;
>  		for (size =3D 0; size < MMU_PAGE_COUNT; size++) {

> =20
> -			/* 4K pages are not represented by LP */
> -			if (size =3D=3D MMU_PAGE_4K)
> -				continue;
> -
>  			/* valid entries have a shift value */
>  			if (!mmu_psize_defs[size].shift)
>  				continue;
> +			for (a_size =3D 0; a_size < MMU_PAGE_COUNT; a_size++) {

Can't you resize hpte_actual_psize() here instead of recoding the lookup?

> -			if (penc =3D=3D mmu_psize_defs[size].penc)
> -				break;
> +				/* 4K pages are not represented by LP */
> +				if (a_size =3D=3D MMU_PAGE_4K)
> +					continue;
> +
> +				/* valid entries have a shift value */
> +				if (!mmu_psize_defs[a_size].shift)
> +					continue;
> +
> +				if (penc =3D=3D mmu_psize_defs[size].penc[a_size])
> +					goto out;
> +			}
>  		}
>  	}
> =20
> +out:
>  	/* This works for all page sizes, and for 256M and 1T segments */
>  	*ssize =3D hpte_v >> HPTE_V_SSIZE_SHIFT;
>  	shift =3D mmu_psize_defs[size].shift;
> @@ -433,7 +496,8 @@ static void hpte_decode(struct hash_pte *hpte, unsign=
ed long slot,
>  	default:
>  		*vpn =3D size =3D 0;
>  	}
> -	*psize =3D size;
> +	*psize  =3D size;
> +	*apsize =3D a_size;
>  }
> =20
>  /*
> @@ -451,7 +515,7 @@ static void native_hpte_clear(void)
>  	struct hash_pte *hptep =3D htab_address;
>  	unsigned long hpte_v;
>  	unsigned long pteg_count;
> -	int psize, ssize;
> +	int psize, apsize, ssize;
> =20
>  	pteg_count =3D htab_hash_mask + 1;
> =20
> @@ -477,9 +541,9 @@ static void native_hpte_clear(void)
>  		 * already hold the native_tlbie_lock.
>  		 */
>  		if (hpte_v & HPTE_V_VALID) {
> -			hpte_decode(hptep, slot, &psize, &ssize, &vpn);
> +			hpte_decode(hptep, slot, &psize, &apsize, &ssize, &vpn);
>  			hptep->v =3D 0;
> -			__tlbie(vpn, psize, ssize);
> +			__tlbie(vpn, psize, apsize, ssize);
>  		}
>  	}
> =20
> @@ -540,7 +604,7 @@ static void native_flush_hash_range(unsigned long num=
ber, int local)
> =20
>  			pte_iterate_hashed_subpages(pte, psize,
>  						    vpn, index, shift) {
> -				__tlbiel(vpn, psize, ssize);
> +				__tlbiel(vpn, psize, psize, ssize);
>  			} pte_iterate_hashed_end();
>  		}
>  		asm volatile("ptesync":::"memory");
> @@ -557,7 +621,7 @@ static void native_flush_hash_range(unsigned long num=
ber, int local)
> =20
>  			pte_iterate_hashed_subpages(pte, psize,
>  						    vpn, index, shift) {
> -				__tlbie(vpn, psize, ssize);
> +				__tlbie(vpn, psize, psize, ssize);
>  			} pte_iterate_hashed_end();
>  		}
>  		asm volatile("eieio; tlbsync; ptesync":::"memory");
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils=
_64.c
> index bfeab83..a5a5067 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -125,7 +125,7 @@ static struct mmu_psize_def mmu_psize_defaults_old[] =
=3D {
>  	[MMU_PAGE_4K] =3D {
>  		.shift	=3D 12,
>  		.sllp	=3D 0,
> -		.penc	=3D 0,
> +		.penc   =3D {[MMU_PAGE_4K] =3D 0, [1 ... MMU_PAGE_COUNT - 1] =3D -1},
>  		.avpnm	=3D 0,
>  		.tlbiel =3D 0,
>  	},
> @@ -139,14 +139,15 @@ static struct mmu_psize_def mmu_psize_defaults_gp[]=
 =3D {
>  	[MMU_PAGE_4K] =3D {
>  		.shift	=3D 12,
>  		.sllp	=3D 0,
> -		.penc	=3D 0,
> +		.penc   =3D {[MMU_PAGE_4K] =3D 0, [1 ... MMU_PAGE_COUNT - 1] =3D -1},
>  		.avpnm	=3D 0,
>  		.tlbiel =3D 1,
>  	},
>  	[MMU_PAGE_16M] =3D {
>  		.shift	=3D 24,
>  		.sllp	=3D SLB_VSID_L,
> -		.penc	=3D 0,
> +		.penc   =3D {[0 ... MMU_PAGE_16M - 1] =3D -1, [MMU_PAGE_16M] =3D 0,
> +			    [MMU_PAGE_16M + 1 ... MMU_PAGE_COUNT - 1] =3D -1 },
>  		.avpnm	=3D 0x1UL,
>  		.tlbiel =3D 0,
>  	},
> @@ -208,7 +209,7 @@ int htab_bolt_mapping(unsigned long vstart, unsigned =
long vend,
> =20
>  		BUG_ON(!ppc_md.hpte_insert);
>  		ret =3D ppc_md.hpte_insert(hpteg, vpn, paddr, tprot,
> -					 HPTE_V_BOLTED, psize, ssize);
> +					 HPTE_V_BOLTED, psize, psize, ssize);
> =20
>  		if (ret < 0)
>  			break;
> @@ -275,6 +276,30 @@ static void __init htab_init_seg_sizes(void)
>  	of_scan_flat_dt(htab_dt_scan_seg_sizes, NULL);
>  }
> =20
> +static int __init get_idx_from_shift(unsigned int shift)
> +{
> +	int idx =3D -1;
> +
> +	switch (shift) {
> +	case 0xc:
> +		idx =3D MMU_PAGE_4K;
> +		break;
> +	case 0x10:
> +		idx =3D MMU_PAGE_64K;
> +		break;
> +	case 0x14:
> +		idx =3D MMU_PAGE_1M;
> +		break;
> +	case 0x18:
> +		idx =3D MMU_PAGE_16M;
> +		break;
> +	case 0x22:
> +		idx =3D MMU_PAGE_16G;
> +		break;
> +	}
> +	return idx;
> +}
> +
>  static int __init htab_dt_scan_page_sizes(unsigned long node,
>  					  const char *uname, int depth,
>  					  void *data)
> @@ -294,60 +319,61 @@ static int __init htab_dt_scan_page_sizes(unsigned =
long node,
>  		size /=3D 4;
>  		cur_cpu_spec->mmu_features &=3D ~(MMU_FTR_16M_PAGE);
>  		while(size > 0) {
> -			unsigned int shift =3D prop[0];
> +			unsigned int base_shift =3D prop[0];
>  			unsigned int slbenc =3D prop[1];
>  			unsigned int lpnum =3D prop[2];
> -			unsigned int lpenc =3D 0;
>  			struct mmu_psize_def *def;
> -			int idx =3D -1;
> +			int idx, base_idx;
> =20
>  			size -=3D 3; prop +=3D 3;
> -			while(size > 0 && lpnum) {
> -				if (prop[0] =3D=3D shift)
> -					lpenc =3D prop[1];
> -				prop +=3D 2; size -=3D 2;
> -				lpnum--;
> +			base_idx =3D get_idx_from_shift(base_shift);
> +			if (base_idx < 0) {
> +				/*
> +				 * skip the pte encoding also
> +				 */
> +				prop +=3D lpnum * 2; size -=3D lpnum * 2;
> +				continue;
>  			}
> -			switch(shift) {
> -			case 0xc:
> -				idx =3D MMU_PAGE_4K;
> -				break;
> -			case 0x10:
> -				idx =3D MMU_PAGE_64K;
> -				break;
> -			case 0x14:
> -				idx =3D MMU_PAGE_1M;
> -				break;
> -			case 0x18:
> -				idx =3D MMU_PAGE_16M;
> +			def =3D &mmu_psize_defs[base_idx];
> +			if (base_idx =3D=3D MMU_PAGE_16M)
>  				cur_cpu_spec->mmu_features |=3D MMU_FTR_16M_PAGE;
> -				break;
> -			case 0x22:
> -				idx =3D MMU_PAGE_16G;
> -				break;
> -			}
> -			if (idx < 0)
> -				continue;
> -			def =3D &mmu_psize_defs[idx];
> -			def->shift =3D shift;
> -			if (shift <=3D 23)
> +
> +			def->shift =3D base_shift;
> +			if (base_shift <=3D 23)
>  				def->avpnm =3D 0;
>  			else
> -				def->avpnm =3D (1 << (shift - 23)) - 1;
> +				def->avpnm =3D (1 << (base_shift - 23)) - 1;
>  			def->sllp =3D slbenc;
> -			def->penc =3D lpenc;
> -			/* We don't know for sure what's up with tlbiel, so
> +			/*
> +			 * We don't know for sure what's up with tlbiel, so
>  			 * for now we only set it for 4K and 64K pages
>  			 */
> -			if (idx =3D=3D MMU_PAGE_4K || idx =3D=3D MMU_PAGE_64K)
> +			if (base_idx =3D=3D MMU_PAGE_4K || base_idx =3D=3D MMU_PAGE_64K)
>  				def->tlbiel =3D 1;
>  			else
>  				def->tlbiel =3D 0;
> =20
> -			DBG(" %d: shift=3D%02x, sllp=3D%04lx, avpnm=3D%08lx, "
> -			    "tlbiel=3D%d, penc=3D%d\n",
> -			    idx, shift, def->sllp, def->avpnm, def->tlbiel,
> -			    def->penc);
> +			while (size > 0 && lpnum) {
> +				unsigned int shift =3D prop[0];
> +				int penc  =3D prop[1];
> +
> +				prop +=3D 2; size -=3D 2;
> +				lpnum--;
> +
> +				idx =3D get_idx_from_shift(shift);
> +				if (idx < 0)
> +					continue;
> +
> +				if (penc =3D=3D -1)
> +					pr_err("Invalid penc for base_shift=3D%d "
> +					       "shift=3D%d\n", base_shift, shift);
> +
> +				def->penc[idx] =3D penc;
> +				DBG(" %d: shift=3D%02x, sllp=3D%04lx, "
> +				    "avpnm=3D%08lx, tlbiel=3D%d, penc=3D%d\n",
> +				    idx, shift, def->sllp, def->avpnm,
> +				    def->tlbiel, def->penc[idx]);
> +			}
>  		}
>  		return 1;
>  	}
> @@ -396,10 +422,21 @@ static int __init htab_dt_scan_hugepage_blocks(unsi=
gned long node,
>  }
>  #endif /* CONFIG_HUGETLB_PAGE */
> =20
> +static void mmu_psize_set_default_penc(void)
> +{
> +	int bpsize, apsize;
> +	for (bpsize =3D 0; bpsize < MMU_PAGE_COUNT; bpsize++)
> +		for (apsize =3D 0; apsize < MMU_PAGE_COUNT; apsize++)
> +			mmu_psize_defs[bpsize].penc[apsize] =3D -1;
> +}
> +
>  static void __init htab_init_page_sizes(void)
>  {
>  	int rc;
> =20
> +	/* se the invalid penc to -1 */
> +	mmu_psize_set_default_penc();
> +
>  	/* Default to 4K pages only */
>  	memcpy(mmu_psize_defs, mmu_psize_defaults_old,
>  	       sizeof(mmu_psize_defaults_old));
> diff --git a/arch/powerpc/mm/hugetlbpage-hash64.c b/arch/powerpc/mm/huget=
lbpage-hash64.c
> index cecad34..e0d52ee 100644
> --- a/arch/powerpc/mm/hugetlbpage-hash64.c
> +++ b/arch/powerpc/mm/hugetlbpage-hash64.c
> @@ -103,7 +103,7 @@ repeat:
> =20
>  		/* Insert into the hash table, primary slot */
>  		slot =3D ppc_md.hpte_insert(hpte_group, vpn, pa, rflags, 0,
> -					  mmu_psize, ssize);
> +					  mmu_psize, mmu_psize, ssize);
> =20
>  		/* Primary is full, try the secondary */
>  		if (unlikely(slot =3D=3D -1)) {
> @@ -111,7 +111,7 @@ repeat:
>  				      HPTES_PER_GROUP) & ~0x7UL;
>  			slot =3D ppc_md.hpte_insert(hpte_group, vpn, pa, rflags,
>  						  HPTE_V_SECONDARY,
> -						  mmu_psize, ssize);
> +						  mmu_psize, mmu_psize, ssize);
>  			if (slot =3D=3D -1) {
>  				if (mftb() & 0x1)
>  					hpte_group =3D ((hash & htab_hash_mask) *
> diff --git a/arch/powerpc/platforms/cell/beat_htab.c b/arch/powerpc/platf=
orms/cell/beat_htab.c
> index 472f9a7..246e1d8 100644
> --- a/arch/powerpc/platforms/cell/beat_htab.c
> +++ b/arch/powerpc/platforms/cell/beat_htab.c
> @@ -90,7 +90,7 @@ static inline unsigned int beat_read_mask(unsigned hpte=
_group)
>  static long beat_lpar_hpte_insert(unsigned long hpte_group,
>  				  unsigned long vpn, unsigned long pa,
>  				  unsigned long rflags, unsigned long vflags,
> -				  int psize, int ssize)
> +				  int psize, int apsize, int ssize)
>  {
>  	unsigned long lpar_rc;
>  	u64 hpte_v, hpte_r, slot;
> @@ -103,9 +103,9 @@ static long beat_lpar_hpte_insert(unsigned long hpte_=
group,
>  			"rflags=3D%lx, vflags=3D%lx, psize=3D%d)\n",
>  		hpte_group, va, pa, rflags, vflags, psize);
> =20
> -	hpte_v =3D hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M) |
> +	hpte_v =3D hpte_encode_v(vpn, psize, apsize, MMU_SEGSIZE_256M) |
>  		vflags | HPTE_V_VALID;
> -	hpte_r =3D hpte_encode_r(pa, psize) | rflags;
> +	hpte_r =3D hpte_encode_r(pa, psize, apsize) | rflags;
> =20
>  	if (!(vflags & HPTE_V_BOLTED))
>  		DBG_LOW(" hpte_v=3D%016lx, hpte_r=3D%016lx\n", hpte_v, hpte_r);
> @@ -314,7 +314,7 @@ void __init hpte_init_beat(void)
>  static long beat_lpar_hpte_insert_v3(unsigned long hpte_group,
>  				  unsigned long vpn, unsigned long pa,
>  				  unsigned long rflags, unsigned long vflags,
> -				  int psize, int ssize)
> +				  int psize, int apsize, int ssize)
>  {
>  	unsigned long lpar_rc;
>  	u64 hpte_v, hpte_r, slot;
> @@ -327,9 +327,9 @@ static long beat_lpar_hpte_insert_v3(unsigned long hp=
te_group,
>  			"rflags=3D%lx, vflags=3D%lx, psize=3D%d)\n",
>  		hpte_group, vpn, pa, rflags, vflags, psize);
> =20
> -	hpte_v =3D hpte_encode_v(vpn, psize, MMU_SEGSIZE_256M) |
> +	hpte_v =3D hpte_encode_v(vpn, psize, apsize, MMU_SEGSIZE_256M) |
>  		vflags | HPTE_V_VALID;
> -	hpte_r =3D hpte_encode_r(pa, psize) | rflags;
> +	hpte_r =3D hpte_encode_r(pa, psize, apsize) | rflags;
> =20
>  	if (!(vflags & HPTE_V_BOLTED))
>  		DBG_LOW(" hpte_v=3D%016lx, hpte_r=3D%016lx\n", hpte_v, hpte_r);
> @@ -373,7 +373,7 @@ static long beat_lpar_hpte_updatepp_v3(unsigned long =
slot,
>  	unsigned long pss;
> =20
>  	want_v =3D hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
> -	pss =3D (psize =3D=3D MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
> +	pss =3D (psize =3D=3D MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc[=
psize];
> =20
>  	DBG_LOW("    update: "
>  		"avpnv=3D%016lx, slot=3D%016lx, psize: %d, newpp %016lx ... ",
> @@ -403,7 +403,7 @@ static void beat_lpar_hpte_invalidate_v3(unsigned lon=
g slot, unsigned long vpn,
>  	DBG_LOW("    inval : slot=3D%lx, vpn=3D%016lx, psize: %d, local: %d\n",
>  		slot, vpn, psize, local);
>  	want_v =3D hpte_encode_avpn(vpn, psize, MMU_SEGSIZE_256M);
> -	pss =3D (psize =3D=3D MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc;
> +	pss =3D (psize =3D=3D MMU_PAGE_4K) ? -1UL : mmu_psize_defs[psize].penc[=
psize];
> =20
>  	lpar_rc =3D beat_invalidate_htab_entry3(0, slot, want_v, pss);
> =20
> diff --git a/arch/powerpc/platforms/ps3/htab.c b/arch/powerpc/platforms/p=
s3/htab.c
> index 07a4bba..44f06d2 100644
> --- a/arch/powerpc/platforms/ps3/htab.c
> +++ b/arch/powerpc/platforms/ps3/htab.c
> @@ -45,7 +45,7 @@ static DEFINE_SPINLOCK(ps3_htab_lock);
> =20
>  static long ps3_hpte_insert(unsigned long hpte_group, unsigned long vpn,
>  	unsigned long pa, unsigned long rflags, unsigned long vflags,
> -	int psize, int ssize)
> +	int psize, int apsize, int ssize)
>  {
>  	int result;
>  	u64 hpte_v, hpte_r;
> @@ -61,8 +61,8 @@ static long ps3_hpte_insert(unsigned long hpte_group, u=
nsigned long vpn,
>  	 */
>  	vflags &=3D ~HPTE_V_SECONDARY;
> =20
> -	hpte_v =3D hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
> -	hpte_r =3D hpte_encode_r(ps3_mm_phys_to_lpar(pa), psize) | rflags;
> +	hpte_v =3D hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_V=
ALID;
> +	hpte_r =3D hpte_encode_r(ps3_mm_phys_to_lpar(pa), psize, apsize) | rfla=
gs;
> =20
>  	spin_lock_irqsave(&ps3_htab_lock, flags);
> =20
> diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platfor=
ms/pseries/lpar.c
> index a77c35b..3daced3 100644
> --- a/arch/powerpc/platforms/pseries/lpar.c
> +++ b/arch/powerpc/platforms/pseries/lpar.c
> @@ -109,7 +109,7 @@ void vpa_init(int cpu)
>  static long pSeries_lpar_hpte_insert(unsigned long hpte_group,
>  				     unsigned long vpn, unsigned long pa,
>  				     unsigned long rflags, unsigned long vflags,
> -				     int psize, int ssize)
> +				     int psize, int apsize, int ssize)
>  {
>  	unsigned long lpar_rc;
>  	unsigned long flags;
> @@ -121,8 +121,8 @@ static long pSeries_lpar_hpte_insert(unsigned long hp=
te_group,
>  			 "pa=3D%016lx, rflags=3D%lx, vflags=3D%lx, psize=3D%d)\n",
>  			 hpte_group, vpn,  pa, rflags, vflags, psize);
> =20
> -	hpte_v =3D hpte_encode_v(vpn, psize, ssize) | vflags | HPTE_V_VALID;
> -	hpte_r =3D hpte_encode_r(pa, psize) | rflags;
> +	hpte_v =3D hpte_encode_v(vpn, psize, apsize, ssize) | vflags | HPTE_V_V=
ALID;
> +	hpte_r =3D hpte_encode_r(pa, psize, apsize) | rflags;
> =20
>  	if (!(vflags & HPTE_V_BOLTED))
>  		pr_devel(" hpte_v=3D%016lx, hpte_r=3D%016lx\n", hpte_v, hpte_r);

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--q5r20fdKX+PFtYHw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlFlEnMACgkQaILKxv3ab8atTgCeLtYWA062pUFnjD41WrGmVExS
bsUAoI3dDx4JJ57izU7WW6TgL2isYh1I
=ZUcG
-----END PGP SIGNATURE-----

--q5r20fdKX+PFtYHw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
