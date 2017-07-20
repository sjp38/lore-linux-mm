Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B64396B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:42:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d18so21184975pfe.8
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:42:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b8si1197959pgr.457.2017.07.19.23.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 23:42:58 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K6gpSa093008
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:42:58 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btp4ju0cx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:42:58 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 16:42:55 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K6gqsr27000844
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:42:52 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K6ghMb028156
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:42:44 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 27/62] powerpc: helper to validate key-access permissions of a pte
In-Reply-To: <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 12:12:47 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87mv7zpq1k.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> helper function that checks if the read/write/execute is allowed
> on the pte.
>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h |    4 +++
>  arch/powerpc/include/asm/pkeys.h             |   12 +++++++++
>  arch/powerpc/mm/pkeys.c                      |   33 ++++++++++++++++++++++++++
>  3 files changed, 49 insertions(+), 0 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index 30d7f55..0056e58 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -472,6 +472,10 @@ static inline void write_uamor(u64 value)
>  	mtspr(SPRN_UAMOR, value);
>  }
>
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> +
>  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
>  static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
>  				       unsigned long addr, pte_t *ptep)
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index bbb5d85..7a9aade 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -53,6 +53,18 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
>  		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
>  }
>
> +static inline u16 pte_to_pkey_bits(u64 pteflags)
> +{
> +	if (!pkey_inited)
> +		return 0x0UL;

Do we really need that above check ? We should always find it
peky_inited to be set. 

> +
> +	return (((pteflags & H_PAGE_PKEY_BIT0) ? 0x10 : 0x0UL) |
> +		((pteflags & H_PAGE_PKEY_BIT1) ? 0x8 : 0x0UL) |
> +		((pteflags & H_PAGE_PKEY_BIT2) ? 0x4 : 0x0UL) |
> +		((pteflags & H_PAGE_PKEY_BIT3) ? 0x2 : 0x0UL) |
> +		((pteflags & H_PAGE_PKEY_BIT4) ? 0x1 : 0x0UL));
> +}
> +


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
