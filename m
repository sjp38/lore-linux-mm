Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id C9C2E6B02BE
	for <linux-mm@kvack.org>; Fri,  3 May 2013 01:30:54 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dwg@au1.ibm.com>;
	Fri, 3 May 2013 15:22:40 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 2EC662BB004F
	for <linux-mm@kvack.org>; Fri,  3 May 2013 15:30:36 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r435USpV18219022
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:29 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r435UXCc029235
	for <linux-mm@kvack.org>; Fri, 3 May 2013 15:30:34 +1000
Date: Fri, 3 May 2013 15:28:46 +1000
From: David Gibson <dwg@au1.ibm.com>
Subject: Re: [PATCH -V7 09/10] powerpc: Optimize hugepage invalidate
Message-ID: <20130503052846.GU13041@truffula.fritz.box>
References: <1367178711-8232-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1367178711-8232-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="A47bNRIYjYQgpFVi"
Content-Disposition: inline
In-Reply-To: <1367178711-8232-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

--A47bNRIYjYQgpFVi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 29, 2013 at 01:21:50AM +0530, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> Hugepage invalidate involves invalidating multiple hpte entries.
> Optimize the operation using H_BULK_REMOVE on lpar platforms.
> On native, reduce the number of tlb flush.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Since this is purely an optimization, have you tried reproducing the
bugs you're chasing with this patch not included?

> ---
>  arch/powerpc/include/asm/machdep.h    |   3 +
>  arch/powerpc/mm/hash_native_64.c      |  78 +++++++++++++++++++++
>  arch/powerpc/mm/pgtable_64.c          |  13 +++-
>  arch/powerpc/platforms/pseries/lpar.c | 126 ++++++++++++++++++++++++++++=
++++--
>  4 files changed, 210 insertions(+), 10 deletions(-)
>=20
> diff --git a/arch/powerpc/include/asm/machdep.h b/arch/powerpc/include/as=
m/machdep.h
> index 3f3f691..5d1e7d2 100644
> --- a/arch/powerpc/include/asm/machdep.h
> +++ b/arch/powerpc/include/asm/machdep.h
> @@ -56,6 +56,9 @@ struct machdep_calls {
>  	void            (*hpte_removebolted)(unsigned long ea,
>  					     int psize, int ssize);
>  	void		(*flush_hash_range)(unsigned long number, int local);
> +	void		(*hugepage_invalidate)(struct mm_struct *mm,
> +					       unsigned char *hpte_slot_array,
> +					       unsigned long addr, int psize);
> =20
>  	/* special for kexec, to be called in real mode, linear mapping is
>  	 * destroyed as well */
> diff --git a/arch/powerpc/mm/hash_native_64.c b/arch/powerpc/mm/hash_nati=
ve_64.c
> index 6a2aead..8ca178d 100644
> --- a/arch/powerpc/mm/hash_native_64.c
> +++ b/arch/powerpc/mm/hash_native_64.c
> @@ -455,6 +455,83 @@ static void native_hpte_invalidate(unsigned long slo=
t, unsigned long vpn,
>  	local_irq_restore(flags);
>  }
> =20
> +static void native_hugepage_invalidate(struct mm_struct *mm,
> +				       unsigned char *hpte_slot_array,
> +				       unsigned long addr, int psize)
> +{
> +	int ssize =3D 0, i;
> +	int lock_tlbie;
> +	struct hash_pte *hptep;
> +	int actual_psize =3D MMU_PAGE_16M;
> +	unsigned int max_hpte_count, valid;
> +	unsigned long flags, s_addr =3D addr;
> +	unsigned long hpte_v, want_v, shift;
> +	unsigned long hidx, vpn =3D 0, vsid, hash, slot;
> +
> +	shift =3D mmu_psize_defs[psize].shift;
> +	max_hpte_count =3D HUGE_PAGE_SIZE >> shift;
> +
> +	local_irq_save(flags);
> +	for (i =3D 0; i < max_hpte_count; i++) {
> +		/*
> +		 * 8 bits per each hpte entries
> +		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
> +		 */
> +		valid =3D hpte_slot_array[i] & 0x1;
> +		if (!valid)
> +			continue;
> +		hidx =3D  hpte_slot_array[i]  >> 1;
> +
> +		/* get the vpn */
> +		addr =3D s_addr + (i * (1ul << shift));
> +		if (!is_kernel_addr(addr)) {
> +			ssize =3D user_segment_size(addr);
> +			vsid =3D get_vsid(mm->context.id, addr, ssize);
> +			WARN_ON(vsid =3D=3D 0);
> +		} else {
> +			vsid =3D get_kernel_vsid(addr, mmu_kernel_ssize);
> +			ssize =3D mmu_kernel_ssize;
> +		}
> +
> +		vpn =3D hpt_vpn(addr, vsid, ssize);
> +		hash =3D hpt_hash(vpn, shift, ssize);
> +		if (hidx & _PTEIDX_SECONDARY)
> +			hash =3D ~hash;
> +
> +		slot =3D (hash & htab_hash_mask) * HPTES_PER_GROUP;
> +		slot +=3D hidx & _PTEIDX_GROUP_IX;
> +
> +		hptep =3D htab_address + slot;
> +		want_v =3D hpte_encode_avpn(vpn, psize, ssize);
> +		native_lock_hpte(hptep);
> +		hpte_v =3D hptep->v;
> +
> +		/* Even if we miss, we need to invalidate the TLB */
> +		if (!HPTE_V_COMPARE(hpte_v, want_v) || !(hpte_v & HPTE_V_VALID))
> +			native_unlock_hpte(hptep);
> +		else
> +			/* Invalidate the hpte. NOTE: this also unlocks it */
> +			hptep->v =3D 0;
> +	}
> +	/*
> +	 * Since this is a hugepage, we just need a single tlbie.
> +	 * use the last vpn.
> +	 */
> +	lock_tlbie =3D !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
> +	if (lock_tlbie)
> +		raw_spin_lock(&native_tlbie_lock);
> +
> +	asm volatile("ptesync":::"memory");
> +	__tlbie(vpn, psize, actual_psize, ssize);
> +	asm volatile("eieio; tlbsync; ptesync":::"memory");
> +
> +	if (lock_tlbie)
> +		raw_spin_unlock(&native_tlbie_lock);
> +
> +	local_irq_restore(flags);
> +}
> +
> +
>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>  			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>  {
> @@ -658,4 +735,5 @@ void __init hpte_init_native(void)
>  	ppc_md.hpte_remove	=3D native_hpte_remove;
>  	ppc_md.hpte_clear_all	=3D native_hpte_clear;
>  	ppc_md.flush_hash_range =3D native_flush_hash_range;
> +	ppc_md.hugepage_invalidate   =3D native_hugepage_invalidate;
>  }
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index b742d6f..504952f 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -659,6 +659,7 @@ void hpte_need_hugepage_flush(struct mm_struct *mm, u=
nsigned long addr,
>  {
>  	int ssize, i;
>  	unsigned long s_addr;
> +	int max_hpte_count;
>  	unsigned int psize, valid;
>  	unsigned char *hpte_slot_array;
>  	unsigned long hidx, vpn, vsid, hash, shift, slot;
> @@ -672,12 +673,18 @@ void hpte_need_hugepage_flush(struct mm_struct *mm,=
 unsigned long addr,
>  	 * second half of the PMD
>  	 */
>  	hpte_slot_array =3D *(char **)(pmdp + PTRS_PER_PMD);
> -
>  	/* get the base page size */
>  	psize =3D get_slice_psize(mm, s_addr);
> -	shift =3D mmu_psize_defs[psize].shift;
> =20
> -	for (i =3D 0; i < (HUGE_PAGE_SIZE >> shift); i++) {
> +	if (ppc_md.hugepage_invalidate)
> +		return ppc_md.hugepage_invalidate(mm, hpte_slot_array,
> +						  s_addr, psize);
> +	/*
> +	 * No bluk hpte removal support, invalidate each entry
> +	 */
> +	shift =3D mmu_psize_defs[psize].shift;
> +	max_hpte_count =3D HUGE_PAGE_SIZE >> shift;
> +	for (i =3D 0; i < max_hpte_count; i++) {
>  		/*
>  		 * 8 bits per each hpte entries
>  		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
> diff --git a/arch/powerpc/platforms/pseries/lpar.c b/arch/powerpc/platfor=
ms/pseries/lpar.c
> index 6d62072..58a31db 100644
> --- a/arch/powerpc/platforms/pseries/lpar.c
> +++ b/arch/powerpc/platforms/pseries/lpar.c
> @@ -45,6 +45,13 @@
>  #include "plpar_wrappers.h"
>  #include "pseries.h"
> =20
> +/* Flag bits for H_BULK_REMOVE */
> +#define HBR_REQUEST	0x4000000000000000UL
> +#define HBR_RESPONSE	0x8000000000000000UL
> +#define HBR_END		0xc000000000000000UL
> +#define HBR_AVPN	0x0200000000000000UL
> +#define HBR_ANDCOND	0x0100000000000000UL
> +
> =20
>  /* in hvCall.S */
>  EXPORT_SYMBOL(plpar_hcall);
> @@ -345,6 +352,117 @@ static void pSeries_lpar_hpte_invalidate(unsigned l=
ong slot, unsigned long vpn,
>  	BUG_ON(lpar_rc !=3D H_SUCCESS);
>  }
> =20
> +/*
> + * Limit iterations holding pSeries_lpar_tlbie_lock to 3. We also need
> + * to make sure that we avoid bouncing the hypervisor tlbie lock.
> + */
> +#define PPC64_HUGE_HPTE_BATCH 12
> +
> +static void __pSeries_lpar_hugepage_invalidate(unsigned long *slot,
> +					     unsigned long *vpn, int count,
> +					     int psize, int ssize)
> +{
> +	unsigned long param[9];

[9]?  I only see 8 elements being used.

> +	int i =3D 0, pix =3D 0, rc;
> +	unsigned long flags =3D 0;
> +	int lock_tlbie =3D !mmu_has_feature(MMU_FTR_LOCKLESS_TLBIE);
> +
> +	if (lock_tlbie)
> +		spin_lock_irqsave(&pSeries_lpar_tlbie_lock, flags);

Why are these hash operations being called with the tlbie lock held?

> +
> +	for (i =3D 0; i < count; i++) {
> +
> +		if (!firmware_has_feature(FW_FEATURE_BULK_REMOVE)) {
> +			pSeries_lpar_hpte_invalidate(slot[i], vpn[i], psize,
> +						     ssize, 0);

Couldn't you set the ppc_md hook based on the firmware request to
avoid this test in the inner loop?  I don't see any tlbie operations
at all.

> +		} else {
> +			param[pix] =3D HBR_REQUEST | HBR_AVPN | slot[i];
> +			param[pix+1] =3D hpte_encode_avpn(vpn[i], psize, ssize);
> +			pix +=3D 2;
> +			if (pix =3D=3D 8) {
> +				rc =3D plpar_hcall9(H_BULK_REMOVE, param,
> +						  param[0], param[1], param[2],
> +						  param[3], param[4], param[5],
> +						  param[6], param[7]);
> +				BUG_ON(rc !=3D H_SUCCESS);
> +				pix =3D 0;
> +			}
> +		}
> +	}
> +	if (pix) {
> +		param[pix] =3D HBR_END;
> +		rc =3D plpar_hcall9(H_BULK_REMOVE, param, param[0], param[1],
> +				  param[2], param[3], param[4], param[5],
> +				  param[6], param[7]);
> +		BUG_ON(rc !=3D H_SUCCESS);
> +	}
> +
> +	if (lock_tlbie)
> +		spin_unlock_irqrestore(&pSeries_lpar_tlbie_lock, flags);
> +}
> +
> +static void pSeries_lpar_hugepage_invalidate(struct mm_struct *mm,
> +				       unsigned char *hpte_slot_array,
> +				       unsigned long addr, int psize)
> +{
> +	int ssize =3D 0, i, index =3D 0;
> +	unsigned long s_addr =3D addr;
> +	unsigned int max_hpte_count, valid;
> +	unsigned long vpn_array[PPC64_HUGE_HPTE_BATCH];
> +	unsigned long slot_array[PPC64_HUGE_HPTE_BATCH];
> +	unsigned long shift, hidx, vpn =3D 0, vsid, hash, slot;
> +
> +	shift =3D mmu_psize_defs[psize].shift;
> +	max_hpte_count =3D HUGE_PAGE_SIZE >> shift;
> +
> +	for (i =3D 0; i < max_hpte_count; i++) {
> +		/*
> +		 * 8 bits per each hpte entries
> +		 * 000| [ secondary group (one bit) | hidx (3 bits) | valid bit]
> +		 */
> +		valid =3D hpte_slot_array[i] & 0x1;
> +		if (!valid)
> +			continue;
> +		hidx =3D  hpte_slot_array[i]  >> 1;
> +
> +		/* get the vpn */
> +		addr =3D s_addr + (i * (1ul << shift));
> +		if (!is_kernel_addr(addr)) {
> +			ssize =3D user_segment_size(addr);
> +			vsid =3D get_vsid(mm->context.id, addr, ssize);
> +			WARN_ON(vsid =3D=3D 0);
> +		} else {
> +			vsid =3D get_kernel_vsid(addr, mmu_kernel_ssize);
> +			ssize =3D mmu_kernel_ssize;
> +		}
> +
> +		vpn =3D hpt_vpn(addr, vsid, ssize);
> +		hash =3D hpt_hash(vpn, shift, ssize);
> +		if (hidx & _PTEIDX_SECONDARY)
> +			hash =3D ~hash;
> +
> +		slot =3D (hash & htab_hash_mask) * HPTES_PER_GROUP;
> +		slot +=3D hidx & _PTEIDX_GROUP_IX;
> +
> +		slot_array[index] =3D slot;
> +		vpn_array[index] =3D vpn;
> +		if (index =3D=3D PPC64_HUGE_HPTE_BATCH - 1) {
> +			/*
> +			 * Now do a bluk invalidate
> +			 */
> +			__pSeries_lpar_hugepage_invalidate(slot_array,
> +							   vpn_array,
> +							   PPC64_HUGE_HPTE_BATCH,
> +							   psize, ssize);

I don't really understand why you have one loop in this function, then
another in the __ function.

> +			index =3D 0;
> +		} else
> +			index++;
> +	}
> +	if (index)
> +		__pSeries_lpar_hugepage_invalidate(slot_array, vpn_array,
> +						   index, psize, ssize);
> +}
> +
>  static void pSeries_lpar_hpte_removebolted(unsigned long ea,
>  					   int psize, int ssize)
>  {
> @@ -360,13 +478,6 @@ static void pSeries_lpar_hpte_removebolted(unsigned =
long ea,
>  	pSeries_lpar_hpte_invalidate(slot, vpn, psize, ssize, 0);
>  }
> =20
> -/* Flag bits for H_BULK_REMOVE */
> -#define HBR_REQUEST	0x4000000000000000UL
> -#define HBR_RESPONSE	0x8000000000000000UL
> -#define HBR_END		0xc000000000000000UL
> -#define HBR_AVPN	0x0200000000000000UL
> -#define HBR_ANDCOND	0x0100000000000000UL
> -
>  /*
>   * Take a spinlock around flushes to avoid bouncing the hypervisor tlbie
>   * lock.
> @@ -452,6 +563,7 @@ void __init hpte_init_lpar(void)
>  	ppc_md.hpte_removebolted =3D pSeries_lpar_hpte_removebolted;
>  	ppc_md.flush_hash_range	=3D pSeries_lpar_flush_hash_range;
>  	ppc_md.hpte_clear_all   =3D pSeries_lpar_hptab_clear;
> +	ppc_md.hugepage_invalidate =3D pSeries_lpar_hugepage_invalidate;
>  }
> =20
>  #ifdef CONFIG_PPC_SMLPAR

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--A47bNRIYjYQgpFVi
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAlGDSw4ACgkQaILKxv3ab8ZUFwCeNPruSEzLIC2FaHvNJ0EAN57g
c0UAn39yTyiD/SnirFt/fCbIpbyncmbi
=Rk73
-----END PGP SIGNATURE-----

--A47bNRIYjYQgpFVi--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
