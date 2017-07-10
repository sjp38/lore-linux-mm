Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD9296B039F
	for <linux-mm@kvack.org>; Sun,  9 Jul 2017 23:12:32 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so21212147wrd.3
        for <linux-mm@kvack.org>; Sun, 09 Jul 2017 20:12:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q80si148333wmb.0.2017.07.09.20.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jul 2017 20:12:31 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6A39GTj074189
	for <linux-mm@kvack.org>; Sun, 9 Jul 2017 23:12:30 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bjuhhkt2x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 09 Jul 2017 23:12:30 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 10 Jul 2017 13:12:27 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6A3CGoC20119788
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:12:24 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6A3Bpxb025615
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 13:11:52 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC v5 31/38] powerpc: introduce get_pte_pkey() helper
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-32-git-send-email-linuxram@us.ibm.com>
Date: Mon, 10 Jul 2017 08:41:30 +0530
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-32-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <58e0d9ff-727f-c960-5c5f-16d19a89e181@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/06/2017 02:52 AM, Ram Pai wrote:
> get_pte_pkey() helper returns the pkey associated with
> a address corresponding to a given mm_struct.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/mmu-hash.h |    5 ++++
>  arch/powerpc/mm/hash_utils_64.c               |   28 +++++++++++++++++++++++++
>  2 files changed, 33 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> index f7a6ed3..369f9ff 100644
> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
> @@ -450,6 +450,11 @@ extern int hash_page(unsigned long ea, unsigned long access, unsigned long trap,
>  int __hash_page_huge(unsigned long ea, unsigned long access, unsigned long vsid,
>  		     pte_t *ptep, unsigned long trap, unsigned long flags,
>  		     int ssize, unsigned int shift, unsigned int mmu_psize);
> +
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +u16 get_pte_pkey(struct mm_struct *mm, unsigned long address);
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> +
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern int __hash_page_thp(unsigned long ea, unsigned long access,
>  			   unsigned long vsid, pmd_t *pmdp, unsigned long trap,
> diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
> index 1e74529..591990c 100644
> --- a/arch/powerpc/mm/hash_utils_64.c
> +++ b/arch/powerpc/mm/hash_utils_64.c
> @@ -1573,6 +1573,34 @@ void hash_preload(struct mm_struct *mm, unsigned long ea,
>  	local_irq_restore(flags);
>  }
>  
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +/*
> + * return the protection key associated with the given address
> + * and the mm_struct.
> + */
> +u16 get_pte_pkey(struct mm_struct *mm, unsigned long address)
> +{
> +	pte_t *ptep;
> +	u16 pkey = 0;
> +	unsigned long flags;
> +
> +	if (REGION_ID(address) == VMALLOC_REGION_ID)
> +		mm = &init_mm;

IIUC, protection keys are only applicable for user space. This
function is getting used to populate siginfo structure. Then how
can we ever request this for any address in VMALLOC region.

> +
> +	if (!mm || !mm->pgd)
> +		return 0;

Is this really required at this stage ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
