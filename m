Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D1C366B02F4
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:58:30 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c184so1250190wmd.6
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 22:58:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 199si1099803wmx.207.2017.07.19.22.58.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 22:58:29 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K5umNE050015
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:58:28 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btpsg03gv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:58:28 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 15:58:25 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K5wLrx10813484
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:58:21 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K5wKHg020201
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:58:21 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 06/62] powerpc: use helper functions in __hash_page_64K() for 64K PTE
In-Reply-To: <1500177424-13695-7-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-7-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 11:28:13 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87y3rjps3u.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> replace redundant code in __hash_page_64K() with helper
> functions pte_get_hash_gslot() and pte_set_hash_slot()
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/mm/hash64_64k.c |   24 ++++--------------------
>  1 files changed, 4 insertions(+), 20 deletions(-)
>
> diff --git a/arch/powerpc/mm/hash64_64k.c b/arch/powerpc/mm/hash64_64k.c
> index 0012618..645f621 100644
> --- a/arch/powerpc/mm/hash64_64k.c
> +++ b/arch/powerpc/mm/hash64_64k.c
> @@ -244,7 +244,6 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
>  		    unsigned long flags, int ssize)
>  {
>  	real_pte_t rpte;
> -	unsigned long *hidxp;
>  	unsigned long hpte_group;
>  	unsigned long rflags, pa;
>  	unsigned long old_pte, new_pte;
> @@ -289,18 +288,12 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
>
>  	vpn  = hpt_vpn(ea, vsid, ssize);
>  	if (unlikely(old_pte & H_PAGE_HASHPTE)) {
> -		unsigned long hash, slot, hidx;
> -
> -		hash = hpt_hash(vpn, shift, ssize);
> -		hidx = __rpte_to_hidx(rpte, 0);
> -		if (hidx & _PTEIDX_SECONDARY)
> -			hash = ~hash;
> -		slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
> -		slot += hidx & _PTEIDX_GROUP_IX;
> +		unsigned long gslot;
>  		/*
>  		 * There MIGHT be an HPTE for this pte
>  		 */
> -		if (mmu_hash_ops.hpte_updatepp(slot, rflags, vpn, MMU_PAGE_64K,
> +		gslot = pte_get_hash_gslot(vpn, shift, ssize, rpte, 0);
> +		if (mmu_hash_ops.hpte_updatepp(gslot, rflags, vpn, MMU_PAGE_64K,
>  					       MMU_PAGE_64K, ssize,
>  					       flags) == -1)
>  			old_pte &= ~_PAGE_HPTEFLAGS;
> @@ -350,17 +343,8 @@ int __hash_page_64K(unsigned long ea, unsigned long access,
>  			return -1;
>  		}
>
> -		/*
> -		 * Insert slot number & secondary bit in PTE second half.
> -		 */
> -		hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
> -		rpte.hidx &= ~(0xfUL);
> -		*hidxp = rpte.hidx  | (slot & 0xfUL);
> -		/*
> -		 * check __real_pte for details on matching smp_rmb()
> -		 */
> -		smp_wmb();
>  		new_pte = (new_pte & ~_PAGE_HPTEFLAGS) | H_PAGE_HASHPTE;
> +		new_pte |= pte_set_hash_slot(ptep, rpte, 0, slot);
>  	}
>  	*ptep = __pte(new_pte & ~H_PAGE_BUSY);
>  	return 0;
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
