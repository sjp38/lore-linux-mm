Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 76AC06B02FD
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:38 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g7so24591204pgp.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 22:57:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b8si1064364pli.24.2017.07.19.22.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 22:57:37 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K5s3fJ062890
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:37 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btjhmgcy8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:36 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 15:57:34 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K5vW5h22610086
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:57:32 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K5vNoM019546
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:57:24 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 04/62] powerpc: introduce pte_get_hash_gslot() helper
In-Reply-To: <1500177424-13695-5-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-5-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 11:27:24 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <871spbr6pn.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> Introduce pte_get_hash_gslot()() which returns the slot number of the
> HPTE in the global hash table.
>
> This function will come in handy as we work towards re-arranging the
> PTE bits in the later patches.
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hash.h |    3 +++
>  arch/powerpc/mm/hash_utils_64.c           |   18 ++++++++++++++++++
>  2 files changed, 21 insertions(+), 0 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/hash.h b/arch/powerpc/include/asm/book3s/64/hash.h
> index d27f885..277158c 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash.h
> @@ -156,6 +156,9 @@ static inline int hash__pte_none(pte_t pte)
>  	return (pte_val(pte) & ~H_PTE_NONE_MASK) == 0;
>  }
>
> +unsigned long pte_get_hash_gslot(unsigned long vpn, unsigned long shift,
> +		int ssize, real_pte_t rpte, unsigned int subpg_index);
> +
>  /* This low level function performs the actual PTE insertion
>   * Setting the PTE depends on the MMU type and other factors. It's
>   * an horrible mess that I'm not going to try to clean up now but
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> index 1b494d0..d3604da 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -1591,6 +1591,24 @@ static inline void tm_flush_hash_page(int local)
>  }
>  #endif
>
> +/*
> + * return the global hash slot, corresponding to the given
> + * pte, which contains the hpte.
> + */
> +unsigned long pte_get_hash_gslot(unsigned long vpn, unsigned long shift,
> +		int ssize, real_pte_t rpte, unsigned int subpg_index)
> +{
> +	unsigned long hash, slot, hidx;
> +
> +	hash = hpt_hash(vpn, shift, ssize);
> +	hidx = __rpte_to_hidx(rpte, subpg_index);
> +	if (hidx & _PTEIDX_SECONDARY)
> +		hash = ~hash;
> +	slot = (hash & htab_hash_mask) * HPTES_PER_GROUP;
> +	slot += hidx & _PTEIDX_GROUP_IX;
> +	return slot;
> +}
> +
>  /* WARNING: This is called from hash_low_64.S, if you change this prototype,
>   *          do not forget to update the assembly call site !
>   */
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
