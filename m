Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A5DAC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:38:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7C2520811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 08:38:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7C2520811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 734048E0004; Fri,  8 Mar 2019 03:38:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E3318E0002; Fri,  8 Mar 2019 03:38:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 586408E0004; Fri,  8 Mar 2019 03:38:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28E2A8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 03:38:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u66so4014620qkf.17
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 00:38:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=ePhRCP/1RbXIVh3HvW2KjFjjpUVfZZoUSVe3o/osuz8=;
        b=GS+hibjtAgX+wCCrjoAupEr6qJ0+Pf9stdvh4J29sL3Qdb2o+Eu2A0hTkLlGPD85rp
         qEg+iQixiNnQiJ71WQGk3IyW2SkbfrFFcohCVL58yXZ547TlSI5xpVdtynk7rDQ4vydZ
         sA+GToBBFMit+ToIJAEr8rcM61U/6MgyVCH8AnnNfKmDeXK0Sp5g1HAls47nWBFbijhC
         S0EbAw4XNb3FOXd2MnTMyzf/sejvP3ytDfGMYs/xAy0Y7yNuF0w1ev4s3i0MLMuoDPOo
         6nROD5EA09dKHJvLWWZeTrHOYt+wCsik8dfYH7cC1sCmlSaF6DodzigL1TJR/+LL9qBR
         E8dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV3dZalwsZ6fJbtpsiVyyVLmzSK9UDn1mVmqDCkAPez13pXtF7W
	zMMtHWtOck8SmOf/sStMo6g7wE3EHDJxhf3/s1tAtaW6iH+tsPp+ryCYNTcVtssfFLt3HtdClGn
	K1fiKbZPk8pTDC7oFq2AGoqN3Z/fKmMLyF/+jEBKYEyFb34VMm9eTVTEQRoZxvy079g==
X-Received: by 2002:a37:5f85:: with SMTP id t127mr13415408qkb.268.1552034280905;
        Fri, 08 Mar 2019 00:38:00 -0800 (PST)
X-Google-Smtp-Source: APXvYqwr9hkVeCK4JJ3XrnSzf7W1pA72NxX/bbL9zgGD1rb7HAXhIFcPolgpwllW6LsQZT5zAv5C
X-Received: by 2002:a37:5f85:: with SMTP id t127mr13415377qkb.268.1552034280242;
        Fri, 08 Mar 2019 00:38:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552034280; cv=none;
        d=google.com; s=arc-20160816;
        b=Wgeng7PkLSyZCUmbjlpasTJlXaXCz7ZUN4HqMzXw8vNzxGaEGaCO04Gr6AKS/Ruc6z
         ot8mOPNbnj7fxgMDRpv6xAo23S4YhMQoIq6i6yQiw9RIlV+W0ePsgbCtlULy3pDlAk7k
         e8qQOaDjj8gRVfO1c0vyTz9f9hxj2gx4WsmQ7m6jjEMbxDCdzKELgM9pe6maVSo2G8VO
         nolnmVWR7/ordtj5hSOTycGlzng6CmdKlhVPCI0KxG+EmwbLe4DXkx5zM1YM5Zzw3G4c
         TDaQSX8hb43bkoSvTjJiGR53Loc3CBbFtmC/7Mblr6/vt1H7T37amRuQPB2m7ZNe2h5k
         s20Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=ePhRCP/1RbXIVh3HvW2KjFjjpUVfZZoUSVe3o/osuz8=;
        b=vpM38c/b7/+L6O4SU5bgfbfH0g0fJ7QLt0t6/mqAZd49M3jQWY1qPrjbIlhRWVOtLf
         caDjJHmLcNlfki+7XuX6y3MQODTgdNtL2IMMWomRmuBYzXB7mpYBdYAcqxufT/O885cA
         2EB+UJO857Xls1q2w6AldrDL3Zmrozpj59AndkAf4KC5BArPvif8EQcITEhIWxpCYix0
         tUMIGNkyV0Z8A4wiWtVfcNEbxbn+GsEP7aR8ThiPdRI0LyqyIbzxIMksq6CwFm3WTzGU
         IC4w0SnspD5fP5GGaZeM/G4a+IUO95LCbI8OeqqYr4fBPor3Qja61cZ0j1FpO8tENBk1
         MKJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x19si3790744qkf.241.2019.03.08.00.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 00:37:59 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x288XnnN067536
	for <linux-mm@kvack.org>; Fri, 8 Mar 2019 03:37:59 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r3krsu90k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 08 Mar 2019 03:37:59 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 8 Mar 2019 08:37:57 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 8 Mar 2019 08:37:50 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x288bnKj60686356
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 8 Mar 2019 08:37:49 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 281C15204F;
	Fri,  8 Mar 2019 08:37:49 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.28])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id EF93D52052;
	Fri,  8 Mar 2019 08:37:46 +0000 (GMT)
Date: Fri, 8 Mar 2019 10:37:45 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Steven Price <steven.price@arm.com>
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>,
        Ard Biesheuvel <ard.biesheuvel@linaro.org>,
        Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Will Deacon <will.deacon@arm.com>, x86@kernel.org,
        "H. Peter Anvin" <hpa@zytor.com>, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org, Mark Rutland <Mark.Rutland@arm.com>,
        "Liang, Kan" <kan.liang@linux.intel.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org,
        kvm-ppc@vger.kernel.org
Subject: Re: [PATCH v4 04/19] powerpc: mm: Add p?d_large() definitions
References: <20190306155031.4291-1-steven.price@arm.com>
 <20190306155031.4291-5-steven.price@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190306155031.4291-5-steven.price@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19030808-0028-0000-0000-0000035189F9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030808-0029-0000-0000-0000240FFED7
Message-Id: <20190308083744.GA6592@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-08_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903080062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 03:50:16PM +0000, Steven Price wrote:
> walk_page_range() is going to be allowed to walk page tables other than
> those of user space. For this it needs to know when it has reached a
> 'leaf' entry in the page tables. This information is provided by the
> p?d_large() functions/macros.
> 
> For powerpc pmd_large() was already implemented, so hoist it out of the
> CONFIG_TRANSPARENT_HUGEPAGE condition and implement the other levels.
> 
> Also since we now have a pmd_large always implemented we can drop the
> pmd_is_leaf() function.
> 
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Michael Ellerman <mpe@ellerman.id.au>
> CC: linuxppc-dev@lists.ozlabs.org
> CC: kvm-ppc@vger.kernel.org
> Signed-off-by: Steven Price <steven.price@arm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/pgtable.h | 30 ++++++++++++++------

There is one more definition of pmd_large() in
arch/powerpc/include/asm/pgtable.h

>  arch/powerpc/kvm/book3s_64_mmu_radix.c       | 12 ++------
>  2 files changed, 24 insertions(+), 18 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index c9bfe526ca9d..c4b29caf2a3b 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -907,6 +907,12 @@ static inline int pud_present(pud_t pud)
>  	return (pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
>  }
> 
> +#define pud_large	pud_large
> +static inline int pud_large(pud_t pud)
> +{
> +	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
> +}
> +
>  extern struct page *pud_page(pud_t pud);
>  extern struct page *pmd_page(pmd_t pmd);
>  static inline pte_t pud_pte(pud_t pud)
> @@ -954,6 +960,12 @@ static inline int pgd_present(pgd_t pgd)
>  	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
>  }
> 
> +#define pgd_large	pgd_large
> +static inline int pgd_large(pgd_t pgd)
> +{
> +	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
> +}
> +
>  static inline pte_t pgd_pte(pgd_t pgd)
>  {
>  	return __pte_raw(pgd_raw(pgd));
> @@ -1107,6 +1119,15 @@ static inline bool pmd_access_permitted(pmd_t pmd, bool write)
>  	return pte_access_permitted(pmd_pte(pmd), write);
>  }
> 
> +#define pmd_large	pmd_large
> +/*
> + * returns true for pmd migration entries, THP, devmap, hugetlb
> + */
> +static inline int pmd_large(pmd_t pmd)
> +{
> +	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
> +}
> +
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  extern pmd_t pfn_pmd(unsigned long pfn, pgprot_t pgprot);
>  extern pmd_t mk_pmd(struct page *page, pgprot_t pgprot);
> @@ -1133,15 +1154,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
>  	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
>  }
> 
> -/*
> - * returns true for pmd migration entries, THP, devmap, hugetlb
> - * But compile time dependent on THP config
> - */
> -static inline int pmd_large(pmd_t pmd)
> -{
> -	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
> -}
> -
>  static inline pmd_t pmd_mknotpresent(pmd_t pmd)
>  {
>  	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_radix.c b/arch/powerpc/kvm/book3s_64_mmu_radix.c
> index 1b821c6efdef..040db20ac2ab 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_radix.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_radix.c
> @@ -363,12 +363,6 @@ static void kvmppc_pte_free(pte_t *ptep)
>  	kmem_cache_free(kvm_pte_cache, ptep);
>  }
> 
> -/* Like pmd_huge() and pmd_large(), but works regardless of config options */
> -static inline int pmd_is_leaf(pmd_t pmd)
> -{
> -	return !!(pmd_val(pmd) & _PAGE_PTE);
> -}
> -
>  static pmd_t *kvmppc_pmd_alloc(void)
>  {
>  	return kmem_cache_alloc(kvm_pmd_cache, GFP_KERNEL);
> @@ -455,7 +449,7 @@ static void kvmppc_unmap_free_pmd(struct kvm *kvm, pmd_t *pmd, bool full,
>  	for (im = 0; im < PTRS_PER_PMD; ++im, ++p) {
>  		if (!pmd_present(*p))
>  			continue;
> -		if (pmd_is_leaf(*p)) {
> +		if (pmd_large(*p)) {
>  			if (full) {
>  				pmd_clear(p);
>  			} else {
> @@ -588,7 +582,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
>  	else if (level <= 1)
>  		new_pmd = kvmppc_pmd_alloc();
> 
> -	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_is_leaf(*pmd)))
> +	if (level == 0 && !(pmd && pmd_present(*pmd) && !pmd_large(*pmd)))
>  		new_ptep = kvmppc_pte_alloc();
> 
>  	/* Check if we might have been invalidated; let the guest retry if so */
> @@ -657,7 +651,7 @@ int kvmppc_create_pte(struct kvm *kvm, pgd_t *pgtable, pte_t pte,
>  		new_pmd = NULL;
>  	}
>  	pmd = pmd_offset(pud, gpa);
> -	if (pmd_is_leaf(*pmd)) {
> +	if (pmd_large(*pmd)) {
>  		unsigned long lgpa = gpa & PMD_MASK;
> 
>  		/* Check if we raced and someone else has set the same thing */
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

