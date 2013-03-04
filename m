Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 621436B0007
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 13:11:09 -0500 (EST)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 23:37:26 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id EF9A23940023
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 23:41:01 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r24IAxA528180708
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 23:40:59 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r24IB1jN000924
	for <linux-mm@kvack.org>; Tue, 5 Mar 2013 05:11:02 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 09/24] powerpc: Decode the pte-lp-encoding bits correctly.
In-Reply-To: <87vc971iwd.fsf@linux.vnet.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304054848.GE27523@drongo> <87vc971iwd.fsf@linux.vnet.ibm.com>
Date: Mon, 04 Mar 2013 23:41:01 +0530
Message-ID: <87txor828a.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Paul Mackerras <paulus@samba.org> writes:
>
>> On Tue, Feb 26, 2013 at 01:34:59PM +0530, Aneesh Kumar K.V wrote:
>>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>>>=20
>>> +static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
>>> +{
>>> +	unsigned int mask;
>>> +	int i, penc, shift;
>>> +	/* Look at the 8 bit LP value */
>>> +	unsigned int lp =3D (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);
>>> +
>>> +	penc =3D 0;
>>> +	for (i =3D 0; i < MMU_PAGE_COUNT; i++) {
>>> +		/* valid entries have a shift value */
>>> +		if (!mmu_psize_defs[i].shift)
>>> +			continue;
>>> +
>>> +		/* encoding bits per actual page size */
>>> +		shift =3D mmu_psize_defs[i].shift - 11;
>>> +		if (shift > 9)
>>> +			shift =3D 9;
>>> +		mask =3D (1 << shift) - 1;
>>> +		if ((lp & mask) =3D=3D mmu_psize_defs[psize].penc[i])
>>> +			return i;
>>> +	}
>>> +	return -1;
>>> +}
>>
>> This doesn't look right to me.  First, it's not clear what the 11 and
>> 9 refer to, and I think the 9 should be LP_BITS (i.e. 8).  Secondly,
>> the mask for the comparison needs to depend on the actual page size
>> not the base page size.
>
> How about the below. I am yet to test this in user space.=20

I needed to special case 4K case. This seems to work fine with the test.

static inline int hpte_actual_psize(struct hash_pte *hptep, int psize)
{
	unsigned int mask;
	int i, penc, shift;
	/* Look at the 8 bit LP value */
	unsigned int lp =3D (hptep->r >> LP_SHIFT) & ((1 << LP_BITS) - 1);

	/* First check if it is large page */
	if (!(hptep->v & HPTE_V_LARGE))
		return MMU_PAGE_4K;

	penc =3D 0;
	for (i =3D 1; i < MMU_PAGE_COUNT; i++) {
		/* valid entries have a shift value */
		if (!mmu_psize_defs[i].shift)
			continue;
		/*
		 * encoding bits per actual page size
		 *        PTE LP     actual page size
		 *    rrrr rrrz		=E2=89=A58KB
		 *    rrrr rrzz		=E2=89=A516KB
		 *    rrrr rzzz		=E2=89=A532KB
		 *    rrrr zzzz		=E2=89=A564KB
		 * .......
		 */
		shift =3D mmu_psize_defs[i].shift -
				mmu_psize_defs[MMU_PAGE_4K].shift;
		if (shift > LP_BITS)
			shift =3D LP_BITS;
		mask =3D (1 << shift) - 1;
		if ((lp & mask) =3D=3D mmu_psize_defs[psize].penc[i])
			return i;
	}
	return -1;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
