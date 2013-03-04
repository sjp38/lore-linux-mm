Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 7CE316B0002
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 06:42:02 -0500 (EST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 17:08:47 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 6F680E004A
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 17:13:07 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r24BfqcE19005692
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 17:11:52 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r24BfrLa002681
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 11:41:54 GMT
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 09/24] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <20130304054848.GE27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304054848.GE27523@drongo>
Date: Mon, 04 Mar 2013 17:11:53 +0530
Message-ID: <87y5e31jem.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Tue, Feb 26, 2013 at 01:34:59PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>=20
>> We look at both the segment base page size and actual page size and store
>> the pte-lp-encodings in an array per base page size.
>>=20
>> We also update all relevant functions to take actual page size argument
>> so that we can use the correct PTE LP encoding in HPTE. This should also
>> get the basic Multiple Page Size per Segment (MPSS) support. This is nee=
ded
>> to enable THP on ppc64.
>
> Mostly looks OK, comments below...
>
>> +/*
>> + * HPTE LP details
>> + */
>> +#define LP_SHIFT	12
>> +#define LP_BITS		8
>> +#define LP_MASK(i)	((0xFF >> (i)) << LP_SHIFT)
>
> The reader might be wondering at this point what "LP" is; be kind and
> make it "large page" in the comment for them.

Fixed.

>
>> diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
>> index 71d0c90..48f6d99 100644
>> --- a/arch/powerpc/kvm/book3s_hv.c
>> +++ b/arch/powerpc/kvm/book3s_hv.c
>> @@ -1515,7 +1515,7 @@ static void kvmppc_add_seg_page_size(struct kvm_pp=
c_one_seg_page_size **sps,
>>  	(*sps)->page_shift =3D def->shift;
>>  	(*sps)->slb_enc =3D def->sllp;
>>  	(*sps)->enc[0].page_shift =3D def->shift;
>> -	(*sps)->enc[0].pte_enc =3D def->penc;
>> +	(*sps)->enc[0].pte_enc =3D def->penc[linux_psize];
>>  	(*sps)++;
>>  }
>
> This will only return the entries where actual page size =3D=3D base page
> size, which basically means that KVM guests won't be able to use
> MPSS.  We will need to return multiple entries in that case.

I did that as a the follow up patch.

[PATCH -V1 10/24] powerpc: Return all the valid pte ecndoing in
KVM_PPC_GET_SMMU_INFO ioct

>
>> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
>> +{
>> +	unsigned int mask;
>> +	int i, penc, shift;
>> +	/* Look at the 8 bit LP value */
>> +	unsigned int lp =3D (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
>> +
>> +	penc =3D 0;
>> +	for (i =3D 0; i < MMU_PAGE_COUNT; i++) {
>> +		/* valid entries have a shift value */
>> +		if (!mmu_psize_defs[i].shift)
>> +			continue;
>> +
>> +		/* encoding bits per actual page size */
>> +		shift =3D mmu_psize_defs[i].shift - 11;
>> +		if (shift > 9)
>> +			shift =3D 9;
>> +		mask =3D (1 << shift) - 1;
>> +		if ((lp & mask) =3D=3D mmu_psize_defs[psize].penc[i])
>> +			return i;
>> +	}
>> +	return -1;
>> +}
>
> This doesn't look right to me.  First, it's not clear what the 11 and
> 9 refer to, and I think the 9 should be LP_BITS (i.e. 8).  Secondly,
> the mask for the comparison needs to depend on the actual page size
> not the base page size.

That 11 should be 12.That depends on the fact that we have below mapping
 rrrr rrrz 	=E2=89=A58KB

Yes, that 9 should be LP_BITs.=20

We are generating mask based on actual page size above (variable i in
the for loop).


>
> I strongly suggest you pull out this code together with
> native_hpte_insert into a little userspace test program that runs
> through all the possible page size combinations, creating an HPTE and
> then decoding it with hpte_actual_psize() to check that you get back
> the correct actual page size.
>

will do.

>>  static void hpte_decode(struct hash_pte *hpte, unsigned long slot,
>> -			int *psize, int *ssize, unsigned long *vpn)
>> +			int *psize, int *apsize, int *ssize, unsigned long *vpn)
>>  {
>>  	unsigned long avpn, pteg, vpi;
>>  	unsigned long hpte_r =3D hpte->r;
>>  	unsigned long hpte_v =3D hpte->v;
>>  	unsigned long vsid, seg_off;
>> -	int i, size, shift, penc;
>> +	int i, size, a_size =3D MMU_PAGE_4K, shift, penc;
>>=20=20
>>  	if (!(hpte_v & HPTE_V_LARGE))
>>  		size =3D MMU_PAGE_4K;
>> @@ -395,12 +422,13 @@ static void hpte_decode(struct hash_pte *hpte, uns=
igned long slot,
>>  			/* valid entries have a shift value */
>>  			if (!mmu_psize_defs[size].shift)
>>  				continue;
>> -
>> -			if (penc =3D=3D mmu_psize_defs[size].penc)
>> -				break;
>> +			for (a_size =3D 0; a_size < MMU_PAGE_COUNT; a_size++)
>> +				if (penc =3D=3D mmu_psize_defs[size].penc[a_size])
>> +					goto out;
>
> Once again I don't think this is correct, since the number of bits in
> the page size encoding depends on the page size.  In fact the
> calculation of penc in that function looks completely bogus to me (not
> that that is code that you have written or modified, but it looks to
> me like it needs fixing).

I am fixing that in the later patch

powerpc: Fix hpte_decode to use the correct decoding for page sizes

But that will also need fixing as you suggested above.

>
>>  static int __init htab_dt_scan_page_sizes(unsigned long node,
>>  					  const char *uname, int depth,
>>  					  void *data)
>> @@ -294,60 +318,57 @@ static int __init htab_dt_scan_page_sizes(unsigned=
 long node,
>>  		size /=3D 4;
>>  		cur_cpu_spec->mmu_features &=3D ~(MMU_FTR_16M_PAGE);
>>  		while(size > 0) {
>> -			unsigned int shift =3D prop[0];
>> +			unsigned int base_shift =3D prop[0];
>>  			unsigned int slbenc =3D prop[1];
>>  			unsigned int lpnum =3D prop[2];
>> -			unsigned int lpenc =3D 0;
>>  			struct mmu_psize_def *def;
>> -			int idx =3D -1;
>> +			int idx, base_idx;
>>=20=20
>>  			size -=3D 3; prop +=3D 3;
>> -			while(size > 0 && lpnum) {
>> -				if (prop[0] =3D=3D shift)
>> -					lpenc =3D prop[1];
>> +			base_idx =3D get_idx_from_shift(base_shift);
>> +			if (base_idx < 0) {
>> +				/*
>> +				 * skip the pte encoding also
>> +				 */
>>  				prop +=3D 2; size -=3D 2;
>> -				lpnum--;
>> +				continue;
>>  			}
>> -			switch(shift) {
>> -			case 0xc:
>> -				idx =3D MMU_PAGE_4K;
>> -				break;
>> -			case 0x10:
>> -				idx =3D MMU_PAGE_64K;
>> -				break;
>> -			case 0x14:
>> -				idx =3D MMU_PAGE_1M;
>> -				break;
>> -			case 0x18:
>> -				idx =3D MMU_PAGE_16M;
>> +			def =3D &mmu_psize_defs[base_idx];
>> +			if (base_idx =3D=3D MMU_PAGE_16M)
>>  				cur_cpu_spec->mmu_features |=3D MMU_FTR_16M_PAGE;
>> -				break;
>> -			case 0x22:
>> -				idx =3D MMU_PAGE_16G;
>> -				break;
>> -			}
>> -			if (idx < 0)
>> -				continue;
>> -			def =3D &mmu_psize_defs[idx];
>> -			def->shift =3D shift;
>> -			if (shift <=3D 23)
>> +
>> +			def->shift =3D base_shift;
>> +			if (base_shift <=3D 23)
>>  				def->avpnm =3D 0;
>>  			else
>> -				def->avpnm =3D (1 << (shift - 23)) - 1;
>> +				def->avpnm =3D (1 << (base_shift - 23)) - 1;
>>  			def->sllp =3D slbenc;
>> -			def->penc =3D lpenc;
>> -			/* We don't know for sure what's up with tlbiel, so
>> +			/*
>> +			 * We don't know for sure what's up with tlbiel, so
>>  			 * for now we only set it for 4K and 64K pages
>>  			 */
>> -			if (idx =3D=3D MMU_PAGE_4K || idx =3D=3D MMU_PAGE_64K)
>> +			if (base_idx =3D=3D MMU_PAGE_4K || base_idx =3D=3D MMU_PAGE_64K)
>>  				def->tlbiel =3D 1;
>>  			else
>>  				def->tlbiel =3D 0;
>>=20=20
>> -			DBG(" %d: shift=3D%02x, sllp=3D%04lx, avpnm=3D%08lx, "
>> -			    "tlbiel=3D%d, penc=3D%d\n",
>> -			    idx, shift, def->sllp, def->avpnm, def->tlbiel,
>> -			    def->penc);
>> +			while (size > 0 && lpnum) {
>> +				unsigned int shift =3D prop[0];
>> +				unsigned int penc  =3D prop[1];
>> +
>> +				prop +=3D 2; size -=3D 2;
>> +				lpnum--;
>> +
>> +				idx =3D get_idx_from_shift(shift);
>> +				if (idx < 0)
>> +					continue;
>> +
>> +				def->penc[idx] =3D penc;
>> +				DBG(" %d: shift=3D%02x, sllp=3D%04lx, "
>> +				    "avpnm=3D%08lx, tlbiel=3D%d, penc=3D%d\n",
>> +				    idx, shift, def->sllp, def->avpnm,
>> +				    def->tlbiel, def->penc[idx]);
>> +			}
>
> I don't see where in this function you set the penc[] elements for
> invalid actual page sizes to -1.

We do the below

--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -125,7 +125,7 @@ static struct mmu_psize_def mmu_psize_defaults_old[] =
=3D {
        [MMU_PAGE_4K] =3D {
                .shift  =3D 12,
                .sllp   =3D 0,
-               .penc   =3D 0,
+               .penc   =3D { [0 ... MMU_PAGE_COUNT - 1] =3D -1 },
                .avpnm  =3D 0,

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
