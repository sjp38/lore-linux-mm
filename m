Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24BBBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C29F82184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 05:42:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C29F82184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DA618E000B; Thu, 14 Mar 2019 01:42:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 561738E0001; Thu, 14 Mar 2019 01:42:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 404B78E000B; Thu, 14 Mar 2019 01:42:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10C9C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:42:14 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i21so4317801qtq.6
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 22:42:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=O77tvQMGu2VDjnUCYjf06ezETKa0Nb7OLSIbEJPmasY=;
        b=H09S83lde1MZq0V6UukcvHLVo6JqLsHZjAUGWNUT8ViIaJynlOu5LFGeVZO+yb92xb
         1NzmGeygDiWMQiaqF3cNv2L6F4/EoPRcuW0nnv7L/829d/AT0dhONxqmcMXWtN9AbOqJ
         DcObTb3nEvUgSpNU8hofmxkvk7Ul76ZcLzKwRdp6cdA/ZR3A36HBpxZULjjS7CcckNFz
         oBF1gODbqZRJp9hjnpPRLYVfbrHyrNAiCSWDYk8oGsCbBx5sGISg8urgQifUdYpaPa+0
         zRaa93xEDZp87Msh7eT8KqKfFyMV+dtWqo9Ew/MdxPYGTOtwb7S2y+V5WA2++0ikUlU4
         D10g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVKHKDkwdXVtGZNW4tOl75b8SkrN5UXsPwVONxCEv4BfzotDF2Y
	4xeV8ITzKcGBFxORZic4kWlBdocXqzgPzdnkH+p9tEfK58SME5NaRSMFwkHK+Xg0NmCGBQqxaCR
	T8R/twPqk+fSTXr96YVVw1aJ0VZpDqHQvSidixjw4cVN8tWOYNEk2N/MjAl7wYwbe8A==
X-Received: by 2002:a0c:fa84:: with SMTP id o4mr4300683qvn.166.1552542133849;
        Wed, 13 Mar 2019 22:42:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyoegDSQqsBuPZlePO6znAxMh80rj1Jaab/JHEP9yzSwcNk8usTcjt+phiWcfOl4/ukW0Bd
X-Received: by 2002:a0c:fa84:: with SMTP id o4mr4300649qvn.166.1552542132942;
        Wed, 13 Mar 2019 22:42:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552542132; cv=none;
        d=google.com; s=arc-20160816;
        b=Sl+VN+K1WdanB6Kko9CATLuwioR+kxiwU0Nw2OG7KZD7gIIQfm3p+SBl1YrRxztEbr
         EQTBJnvYakPAmM+wcQneiM93P1kb4hQA5yAZcd4GbLUQrpYV7vogKZSmlltrqyUDT/Wl
         EAXt9o27uZ8FiKJGGKSCMREtoRo37lseOeHnhK4GhLYgLVgtjrYGA6eIKUhHZRUPObmU
         qRamYxQ7VpvzBAdwbsZ52yE2onJA9KEb8sPHTaUtnL+s3XeOxgb94nVkVMWwLegEQJa/
         TajSmRRC3X92Io0qmtTA7k7MDqSRgUHEFdp7CAGUepff/gWCZ5urK4UTvWTqZjlzj5e8
         4tpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=O77tvQMGu2VDjnUCYjf06ezETKa0Nb7OLSIbEJPmasY=;
        b=gTop8mo+B5nVPiWCLMn6hMmgJ34yE5Ank85p8x+RWv0/JtMzzTN+8vDA7fBBixQf/Y
         nZXxGC7H/icAu8k8vMOs6NP4WVplGI9B5Ka8VP65zkXzWFw7lJrLWf+n921/K8N3UbhX
         kn4xm9JZF3hztZUdIK5j7IUaDlHq/OgR8FtmO3I+wp7v6Hx4vgmN7G8IDdFOz4LmNj7L
         l39kVhbECOEp1fnmod5hYwJyM9YN489zDt2iIsPOmjES6TAZiLTysJ6VQcJee0Iv0QOn
         WCj1XV+NlIz/aSN+wmVN5gRglPz+NmoMcam3Zt+HATjRzE5Upd+Kk+7kIeWvQn/NzidI
         IHww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e17si648282qtr.402.2019.03.13.22.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 22:42:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2E5dDVf018521
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:42:12 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2r7fg93h6t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 01:42:12 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 14 Mar 2019 05:42:09 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Mar 2019 05:42:03 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2E5g2cT35389534
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Mar 2019 05:42:02 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E8E5E11C050;
	Thu, 14 Mar 2019 05:42:01 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2449111C04C;
	Thu, 14 Mar 2019 05:41:57 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.88])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 14 Mar 2019 05:41:56 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Alexandre Ghiti <alex@ghiti.fr>, Andrew Morton <akpm@linux-foundation.org>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: Re: [PATCH v6 3/4] mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
In-Reply-To: <20190307132015.26970-4-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr> <20190307132015.26970-4-alex@ghiti.fr>
Date: Thu, 14 Mar 2019 11:11:55 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19031405-0008-0000-0000-000002CD1746
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031405-0009-0000-0000-0000223917FF
Message-Id: <87y35iovvg.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-14_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903140036
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre Ghiti <alex@ghiti.fr> writes:

> This condition allows to define alloc_contig_range, so simplify
> it into a more accurate naming.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  arch/arm64/Kconfig                     | 2 +-
>  arch/powerpc/platforms/Kconfig.cputype | 2 +-
>  arch/s390/Kconfig                      | 2 +-
>  arch/sh/Kconfig                        | 2 +-
>  arch/sparc/Kconfig                     | 2 +-
>  arch/x86/Kconfig                       | 2 +-
>  arch/x86/mm/hugetlbpage.c              | 2 +-
>  include/linux/gfp.h                    | 2 +-
>  mm/Kconfig                             | 3 +++
>  mm/page_alloc.c                        | 3 +--
>  10 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index a4168d366127..091a513b93e9 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -18,7 +18,7 @@ config ARM64
>  	select ARCH_HAS_FAST_MULTIPLIER
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_MEMBARRIER_SYNC_CORE
>  	select ARCH_HAS_PTE_SPECIAL
> diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
> index 8c7464c3f27f..f677c8974212 100644
> --- a/arch/powerpc/platforms/Kconfig.cputype
> +++ b/arch/powerpc/platforms/Kconfig.cputype
> @@ -319,7 +319,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
>  config PPC_RADIX_MMU
>  	bool "Radix MMU Support"
>  	depends on PPC_BOOK3S_64
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  	default y
>  	help
>  	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
> diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
> index ed554b09eb3f..1c57b83c76f5 100644
> --- a/arch/s390/Kconfig
> +++ b/arch/s390/Kconfig
> @@ -69,7 +69,7 @@ config S390
>  	select ARCH_HAS_ELF_RANDOMIZE
>  	select ARCH_HAS_FORTIFY_SOURCE
>  	select ARCH_HAS_GCOV_PROFILE_ALL
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  	select ARCH_HAS_KCOV
>  	select ARCH_HAS_PTE_SPECIAL
>  	select ARCH_HAS_SET_MEMORY
> diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
> index 299a17bed67c..c7266302691c 100644
> --- a/arch/sh/Kconfig
> +++ b/arch/sh/Kconfig
> @@ -53,7 +53,7 @@ config SUPERH
>  	select HAVE_FUTEX_CMPXCHG if FUTEX
>  	select HAVE_NMI
>  	select NEED_SG_DMA_LENGTH
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  
>  	help
>  	  The SuperH is a RISC processor targeted for use in embedded systems
> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
> index 0b7f0e0fefa5..ca33c80870e2 100644
> --- a/arch/sparc/Kconfig
> +++ b/arch/sparc/Kconfig
> @@ -90,7 +90,7 @@ config SPARC64
>  	select ARCH_CLOCKSOURCE_DATA
>  	select ARCH_HAS_PTE_SPECIAL
>  	select PCI_DOMAINS if PCI
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  
>  config ARCH_DEFCONFIG
>  	string
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 68261430fe6e..8ba90f3e0038 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -23,7 +23,7 @@ config X86_64
>  	def_bool y
>  	depends on 64BIT
>  	# Options that are inherently 64-bit kernel only:
> -	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
> +	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
>  	select ARCH_SUPPORTS_INT128
>  	select ARCH_USE_CMPXCHG_LOCKREF
>  	select HAVE_ARCH_SOFT_DIRTY
> diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> index 92e4c4b85bba..fab095362c50 100644
> --- a/arch/x86/mm/hugetlbpage.c
> +++ b/arch/x86/mm/hugetlbpage.c
> @@ -203,7 +203,7 @@ static __init int setup_hugepagesz(char *opt)
>  }
>  __setup("hugepagesz=", setup_hugepagesz);
>  
> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> +#ifdef CONFIG_CONTIG_ALLOC
>  static __init int gigantic_pages_init(void)
>  {
>  	/* With compaction or CMA we can allocate gigantic pages at runtime */
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 5f5e25fd6149..1f1ad9aeebb9 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -585,7 +585,7 @@ static inline bool pm_suspended_storage(void)
>  }
>  #endif /* CONFIG_PM_SLEEP */
>  
> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> +#ifdef CONFIG_CONTIG_ALLOC
>  /* The below functions must be run on a range from a single zone. */
>  extern int alloc_contig_range(unsigned long start, unsigned long end,
>  			      unsigned migratetype, gfp_t gfp_mask);
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..137eadc18732 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -258,6 +258,9 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>  config ARCH_ENABLE_THP_MIGRATION
>  	bool
>  
> +config CONTIG_ALLOC
> +       def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
> +
>  config PHYS_ADDR_T_64BIT
>  	def_bool 64BIT
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 35fdde041f5c..ac9c45ffb344 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -8024,8 +8024,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  	return true;
>  }
>  
> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> -
> +#ifdef CONFIG_CONTIG_ALLOC
>  static unsigned long pfn_max_align_down(unsigned long pfn)
>  {
>  	return pfn & ~(max_t(unsigned long, MAX_ORDER_NR_PAGES,
> -- 
> 2.20.1

