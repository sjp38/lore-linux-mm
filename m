Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 464ABC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:54:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC9D9223A0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:54:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC9D9223A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5189B6B0008; Tue, 23 Jul 2019 01:54:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C9CA8E0003; Tue, 23 Jul 2019 01:54:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 392FB8E0001; Tue, 23 Jul 2019 01:54:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1070F6B0008
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:54:18 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id e66so25179492ybe.19
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:54:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/lQla5hN7G0EFTPPVuLwSKgxOrccHybeDiZlzLtzmds=;
        b=S/upc23xFXCDRN3NNtvPQn/1glU3wBv/+PL8x58CKn7THqovvR2Ghl9hAegDanL2AF
         zq+h7+g46yriD2Uq3+yxr0hFWi2IyB8VBj29vfVuzArSxBfdNvKAkz0ZNzw71RlPac5g
         eXRX00q5FXntIUoISkEzeFKpKS19nSn9E0u6ITQ3bxbmDNMa9wnJZwo/fvPSjkCB+6ZH
         yfseW/27wdBkjiziMrA2l98JXtVz8VZ8/NZ6/oCWJCD/El86U7HPTtrwm2rQuQnW3OX7
         FJP7TVeLbPbl3yCSCO+Sl1hl/fENqqpAXKjR/j6FrOiRC2zjwiGGpOrhfh8Y4aJm5ZLw
         bPyw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVkbTeey2zjyIiGtzvt3xIrH8t0EbwChihTL58uE/pAhXPb9lY8
	L7uFpiAjHgw4LV6uzGcuFOi820a8MNfV1/gsFHcDAY1CtrJ60hlqXVN4r73sKtaDRxYjLXpLU55
	FbH5qwNghzQk+7LcStSwtm4D4391UYK+mXBeyCAVfqhP8+jJijGP19l1Y8IN7ui5/Kw==
X-Received: by 2002:a81:6355:: with SMTP id x82mr47148546ywb.396.1563861257720;
        Mon, 22 Jul 2019 22:54:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuentSgb5gSD0ST5wWdugz1B5dA8sxysjPHwcYrE7aAC9xo6rV7aTYzogkI6Xgk8MeWj5+
X-Received: by 2002:a81:6355:: with SMTP id x82mr47148523ywb.396.1563861256733;
        Mon, 22 Jul 2019 22:54:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563861256; cv=none;
        d=google.com; s=arc-20160816;
        b=ZO/qxJjzKFmiIupTySdN8AilIWpOSvZOh3ZbSDMvHloTSJkFnIH74dRlbwySSgPJNH
         7oeXJuyLXAOsIlCOpfyyDll/RaOpwZbFcPnta1tZSmp/JaSK0CjekUAFtiYS6qcpWCL9
         OAZ6SS4HfFZGuuvMpV0QbbuTKnVmsUVwe2aysZur3GyIM1ISpVd5TV3pRU+pXrXF5zaa
         3A7yU9jrC+Prd35LeloRpE26sNHdG2WSKvfG2c/iJUcJEPxk+vn/ovbXMR3KO+VdbRLY
         CueaIcaPw4OR+bPvQlUsMpnpy7mVE9yPjBviZ9OrLoFh/aUCnEBm7TLrQ/xbUcHSVtIZ
         fKPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/lQla5hN7G0EFTPPVuLwSKgxOrccHybeDiZlzLtzmds=;
        b=tk2o5v/0ru/32ba3sp4jx4j0mCWuYT0EEii0VRo+exDFgrsZejGKihnZY/JILQDc0v
         O6/KAzyKzLOoSQP9Xa96jwlV+mEbn2AQdN7fbdlEGGTsdRiOgIhcuWQoIVsxxZEW4gQl
         Rwk5E5HHZBGd4S9iQMkqB9W24FWAp4hdu0V8jBk6OlF9idfqHZhb+HyXwboZwQnBovdA
         G6VMk71hBUrD5KmnrwZOs509Fu+QN80s+sbxc7QmSwsYPq03qtnVv52e5YznwIYw3KAB
         upNpqGwz26jJro34SxBF427PP+HUxdupfyvGci7QmQLSDvSzwWaMCEl6L3dZF/erK7Br
         Hslg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 207si16407882ywf.439.2019.07.22.22.54.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 22:54:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6N5q7AO047920
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:54:16 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2twva38e7r-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:54:15 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 23 Jul 2019 06:54:14 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Jul 2019 06:54:09 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6N5rsW937290250
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Jul 2019 05:53:54 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 02090A405C;
	Tue, 23 Jul 2019 05:54:09 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3CDA0A4054;
	Tue, 23 Jul 2019 05:54:08 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 23 Jul 2019 05:54:08 +0000 (GMT)
Date: Tue, 23 Jul 2019 08:54:06 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        Anshuman Khandual <anshuman.khandual@arm.com>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        Yu Zhao <yuzhao@google.com>, linux-mm@kvack.org
Subject: Re: [PATCHv2] mm: treewide: Clarify pgtable_page_{ctor,dtor}() naming
References: <20190722141133.3116-1-mark.rutland@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190722141133.3116-1-mark.rutland@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19072305-0012-0000-0000-0000033556F1
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19072305-0013-0000-0000-0000216EE5A4
Message-Id: <20190723055405.GA4896@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-23_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907230055
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 03:11:33PM +0100, Mark Rutland wrote:
> The naming of pgtable_page_{ctor,dtor}() seems to have confused a few
> people, and until recently arm64 used these erroneously/pointlessly for
> other levels of page table.
> 
> To make it incredibly clear that these only apply to the PTE level, and
> to align with the naming of pgtable_pmd_page_{ctor,dtor}(), let's rename
> them to pgtable_pte_page_{ctor,dtor}().
> 
> These changes were generated with the following shell script:
> 
> ----
> git grep -lw 'pgtable_page_.tor' | while read FILE; do
>     sed -i '{s/pgtable_page_ctor/pgtable_pte_page_ctor/}' $FILE;
>     sed -i '{s/pgtable_page_dtor/pgtable_pte_page_dtor/}' $FILE;
> done
> ----
> 
> ... with the documentation re-flowed to remain under 80 columns, and
> whitespace fixed up in macros to keep backslashes aligned.
> 
> There should be no functional change as a result of this patch.
> 
> Signed-off-by: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Yu Zhao <yuzhao@google.com>
> Cc: linux-mm@kvack.org

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  Documentation/vm/split_page_table_lock.rst | 10 +++++-----
>  arch/arc/include/asm/pgalloc.h             |  4 ++--
>  arch/arm/include/asm/tlb.h                 |  2 +-
>  arch/arm/mm/mmu.c                          |  2 +-
>  arch/arm64/include/asm/tlb.h               |  2 +-
>  arch/arm64/mm/mmu.c                        |  2 +-
>  arch/csky/include/asm/pgalloc.h            |  2 +-
>  arch/hexagon/include/asm/pgalloc.h         |  2 +-
>  arch/ia64/include/asm/pgalloc.h            |  4 ++--
>  arch/m68k/include/asm/mcf_pgalloc.h        |  6 +++---
>  arch/m68k/include/asm/motorola_pgalloc.h   |  6 +++---
>  arch/m68k/include/asm/sun3_pgalloc.h       |  2 +-
>  arch/microblaze/include/asm/pgalloc.h      |  4 ++--
>  arch/mips/include/asm/pgalloc.h            |  2 +-
>  arch/nios2/include/asm/pgalloc.h           |  2 +-
>  arch/openrisc/include/asm/pgalloc.h        |  6 +++---
>  arch/powerpc/mm/pgtable-frag.c             |  6 +++---
>  arch/riscv/include/asm/pgalloc.h           |  2 +-
>  arch/s390/mm/pgalloc.c                     |  6 +++---
>  arch/sh/include/asm/pgalloc.h              |  6 +++---
>  arch/sparc/mm/init_64.c                    |  4 ++--
>  arch/sparc/mm/srmmu.c                      |  4 ++--
>  arch/um/include/asm/pgalloc.h              |  2 +-
>  arch/unicore32/include/asm/tlb.h           |  2 +-
>  arch/x86/mm/pgtable.c                      |  2 +-
>  arch/xtensa/include/asm/pgalloc.h          |  4 ++--
>  include/asm-generic/pgalloc.h              |  8 ++++----
>  include/linux/mm.h                         |  4 ++--
>  28 files changed, 54 insertions(+), 54 deletions(-)
> 
> Since v1 [1]:
> * Rebase to v5.3-rc1
> * Use shell rather than coccinelle
> 
> [1] https://lore.kernel.org/r/20190610163354.24835-1-mark.rutland@arm.com
> 
> diff --git a/Documentation/vm/split_page_table_lock.rst b/Documentation/vm/split_page_table_lock.rst
> index 889b00be469f..ff51f4a5494d 100644
> --- a/Documentation/vm/split_page_table_lock.rst
> +++ b/Documentation/vm/split_page_table_lock.rst
> @@ -54,9 +54,9 @@ Hugetlb-specific helpers:
>  Support of split page table lock by an architecture
>  ===================================================
> 
> -There's no need in special enabling of PTE split page table lock:
> -everything required is done by pgtable_page_ctor() and pgtable_page_dtor(),
> -which must be called on PTE table allocation / freeing.
> +There's no need in special enabling of PTE split page table lock: everything
> +required is done by pgtable_pte_page_ctor() and pgtable_pte_page_dtor(), which
> +must be called on PTE table allocation / freeing.
> 
>  Make sure the architecture doesn't use slab allocator for page table
>  allocation: slab uses page->slab_cache for its pages.
> @@ -74,7 +74,7 @@ paths: i.e X86_PAE preallocate few PMDs on pgd_alloc().
> 
>  With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
> 
> -NOTE: pgtable_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
> +NOTE: pgtable_pte_page_ctor() and pgtable_pmd_page_ctor() can fail -- it must
>  be handled properly.
> 
>  page->ptl
> @@ -94,7 +94,7 @@ trick:
>     split lock with enabled DEBUG_SPINLOCK or DEBUG_LOCK_ALLOC, but costs
>     one more cache line for indirect access;
> 
> -The spinlock_t allocated in pgtable_page_ctor() for PTE table and in
> +The spinlock_t allocated in pgtable_pte_page_ctor() for PTE table and in
>  pgtable_pmd_page_ctor() for PMD table.
> 
>  Please, never access page->ptl directly -- use appropriate helper.
> diff --git a/arch/arc/include/asm/pgalloc.h b/arch/arc/include/asm/pgalloc.h
> index 9bdb8ed5b0db..c2b754b63846 100644
> --- a/arch/arc/include/asm/pgalloc.h
> +++ b/arch/arc/include/asm/pgalloc.h
> @@ -108,7 +108,7 @@ pte_alloc_one(struct mm_struct *mm)
>  		return 0;
>  	memzero((void *)pte_pg, PTRS_PER_PTE * sizeof(pte_t));
>  	page = virt_to_page(pte_pg);
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return 0;
>  	}
> @@ -123,7 +123,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> 
>  static inline void pte_free(struct mm_struct *mm, pgtable_t ptep)
>  {
> -	pgtable_page_dtor(virt_to_page(ptep));
> +	pgtable_pte_page_dtor(virt_to_page(ptep));
>  	free_pages((unsigned long)ptep, __get_order_pte());
>  }
> 
> diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
> index b75ea15b85c0..669474add486 100644
> --- a/arch/arm/include/asm/tlb.h
> +++ b/arch/arm/include/asm/tlb.h
> @@ -44,7 +44,7 @@ static inline void __tlb_remove_table(void *_table)
>  static inline void
>  __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
> 
>  #ifndef CONFIG_ARM_LPAE
>  	/*
> diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
> index d9a0038774a6..426d9085396b 100644
> --- a/arch/arm/mm/mmu.c
> +++ b/arch/arm/mm/mmu.c
> @@ -731,7 +731,7 @@ static void *__init late_alloc(unsigned long sz)
>  {
>  	void *ptr = (void *)__get_free_pages(GFP_PGTABLE_KERNEL, get_order(sz));
> 
> -	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
> +	if (!ptr || !pgtable_pte_page_ctor(virt_to_page(ptr)))
>  		BUG();
>  	return ptr;
>  }
> diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> index a95d1fcb7e21..b76df828e6b7 100644
> --- a/arch/arm64/include/asm/tlb.h
> +++ b/arch/arm64/include/asm/tlb.h
> @@ -44,7 +44,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
>  static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
>  				  unsigned long addr)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	tlb_remove_table(tlb, pte);
>  }
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index 750a69dde39b..63d730c5b7a9 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -383,7 +383,7 @@ static phys_addr_t pgd_pgtable_alloc(int shift)
>  	 * folded, and if so pgtable_pmd_page_ctor() becomes nop.
>  	 */
>  	if (shift == PAGE_SHIFT)
> -		BUG_ON(!pgtable_page_ctor(phys_to_page(pa)));
> +		BUG_ON(!pgtable_pte_page_ctor(phys_to_page(pa)));
>  	else if (shift == PMD_SHIFT)
>  		BUG_ON(!pgtable_pmd_page_ctor(phys_to_page(pa)));
> 
> diff --git a/arch/csky/include/asm/pgalloc.h b/arch/csky/include/asm/pgalloc.h
> index 98c5716708d6..6bfd5dcf04e1 100644
> --- a/arch/csky/include/asm/pgalloc.h
> +++ b/arch/csky/include/asm/pgalloc.h
> @@ -71,7 +71,7 @@ static inline pgd_t *pgd_alloc(struct mm_struct *mm)
> 
>  #define __pte_free_tlb(tlb, pte, address)		\
>  do {							\
> -	pgtable_page_dtor(pte);				\
> +	pgtable_pte_page_dtor(pte);			\
>  	tlb_remove_page(tlb, pte);			\
>  } while (0)
> 
> diff --git a/arch/hexagon/include/asm/pgalloc.h b/arch/hexagon/include/asm/pgalloc.h
> index d6544dc71258..d82a83d0b436 100644
> --- a/arch/hexagon/include/asm/pgalloc.h
> +++ b/arch/hexagon/include/asm/pgalloc.h
> @@ -96,7 +96,7 @@ static inline void pmd_populate_kernel(struct mm_struct *mm, pmd_t *pmd,
> 
>  #define __pte_free_tlb(tlb, pte, addr)		\
>  do {						\
> -	pgtable_page_dtor((pte));		\
> +	pgtable_pte_page_dtor((pte));		\
>  	tlb_remove_page((tlb), (pte));		\
>  } while (0)
> 
> diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
> index c9e481023c25..70db524b75a6 100644
> --- a/arch/ia64/include/asm/pgalloc.h
> +++ b/arch/ia64/include/asm/pgalloc.h
> @@ -92,7 +92,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	if (!pg)
>  		return NULL;
>  	page = virt_to_page(pg);
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		quicklist_free(0, NULL, pg);
>  		return NULL;
>  	}
> @@ -106,7 +106,7 @@ static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
> 
>  static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	quicklist_free_page(0, NULL, pte);
>  }
> 
> diff --git a/arch/m68k/include/asm/mcf_pgalloc.h b/arch/m68k/include/asm/mcf_pgalloc.h
> index 4399d712f6db..b34d44d666a4 100644
> --- a/arch/m68k/include/asm/mcf_pgalloc.h
> +++ b/arch/m68k/include/asm/mcf_pgalloc.h
> @@ -41,7 +41,7 @@ extern inline pmd_t *pmd_alloc_kernel(pgd_t *pgd, unsigned long address)
>  static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
>  				  unsigned long address)
>  {
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	__free_page(page);
>  }
> 
> @@ -54,7 +54,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
> 
>  	if (!page)
>  		return NULL;
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return NULL;
>  	}
> @@ -73,7 +73,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
> 
>  static inline void pte_free(struct mm_struct *mm, struct page *page)
>  {
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	__free_page(page);
>  }
> 
> diff --git a/arch/m68k/include/asm/motorola_pgalloc.h b/arch/m68k/include/asm/motorola_pgalloc.h
> index d04d9ba9b976..acab315c851f 100644
> --- a/arch/m68k/include/asm/motorola_pgalloc.h
> +++ b/arch/m68k/include/asm/motorola_pgalloc.h
> @@ -36,7 +36,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	page = alloc_pages(GFP_KERNEL|__GFP_ZERO, 0);
>  	if(!page)
>  		return NULL;
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return NULL;
>  	}
> @@ -51,7 +51,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
> 
>  static inline void pte_free(struct mm_struct *mm, pgtable_t page)
>  {
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	cache_page(kmap(page));
>  	kunmap(page);
>  	__free_page(page);
> @@ -60,7 +60,7 @@ static inline void pte_free(struct mm_struct *mm, pgtable_t page)
>  static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t page,
>  				  unsigned long address)
>  {
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	cache_page(kmap(page));
>  	kunmap(page);
>  	__free_page(page);
> diff --git a/arch/m68k/include/asm/sun3_pgalloc.h b/arch/m68k/include/asm/sun3_pgalloc.h
> index 1a8ddbd0d23c..856121122b91 100644
> --- a/arch/m68k/include/asm/sun3_pgalloc.h
> +++ b/arch/m68k/include/asm/sun3_pgalloc.h
> @@ -21,7 +21,7 @@ extern const char bad_pmd_string[];
> 
>  #define __pte_free_tlb(tlb,pte,addr)			\
>  do {							\
> -	pgtable_page_dtor(pte);				\
> +	pgtable_pte_page_dtor(pte);			\
>  	tlb_remove_page((tlb), pte);			\
>  } while (0)
> 
> diff --git a/arch/microblaze/include/asm/pgalloc.h b/arch/microblaze/include/asm/pgalloc.h
> index f4cc9ffc449e..4676ad76ff03 100644
> --- a/arch/microblaze/include/asm/pgalloc.h
> +++ b/arch/microblaze/include/asm/pgalloc.h
> @@ -124,7 +124,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
>  	if (!ptepage)
>  		return NULL;
>  	clear_highpage(ptepage);
> -	if (!pgtable_page_ctor(ptepage)) {
> +	if (!pgtable_pte_page_ctor(ptepage)) {
>  		__free_page(ptepage);
>  		return NULL;
>  	}
> @@ -150,7 +150,7 @@ static inline void pte_free_slow(struct page *ptepage)
> 
>  static inline void pte_free(struct mm_struct *mm, struct page *ptepage)
>  {
> -	pgtable_page_dtor(ptepage);
> +	pgtable_pte_page_dtor(ptepage);
>  	__free_page(ptepage);
>  }
> 
> diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
> index aa16b85ddffc..ff9c3cf87363 100644
> --- a/arch/mips/include/asm/pgalloc.h
> +++ b/arch/mips/include/asm/pgalloc.h
> @@ -54,7 +54,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> 
>  #define __pte_free_tlb(tlb,pte,address)			\
>  do {							\
> -	pgtable_page_dtor(pte);				\
> +	pgtable_pte_page_dtor(pte);			\
>  	tlb_remove_page((tlb), pte);			\
>  } while (0)
> 
> diff --git a/arch/nios2/include/asm/pgalloc.h b/arch/nios2/include/asm/pgalloc.h
> index 4bc8cf72067e..7dd264c3c539 100644
> --- a/arch/nios2/include/asm/pgalloc.h
> +++ b/arch/nios2/include/asm/pgalloc.h
> @@ -41,7 +41,7 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> 
>  #define __pte_free_tlb(tlb, pte, addr)				\
>  	do {							\
> -		pgtable_page_dtor(pte);				\
> +		pgtable_pte_page_dtor(pte);			\
>  		tlb_remove_page((tlb), (pte));			\
>  	} while (0)
> 
> diff --git a/arch/openrisc/include/asm/pgalloc.h b/arch/openrisc/include/asm/pgalloc.h
> index 3d4b397c2d06..7a3185d87935 100644
> --- a/arch/openrisc/include/asm/pgalloc.h
> +++ b/arch/openrisc/include/asm/pgalloc.h
> @@ -75,7 +75,7 @@ static inline struct page *pte_alloc_one(struct mm_struct *mm)
>  	if (!pte)
>  		return NULL;
>  	clear_page(page_address(pte));
> -	if (!pgtable_page_ctor(pte)) {
> +	if (!pgtable_pte_page_ctor(pte)) {
>  		__free_page(pte);
>  		return NULL;
>  	}
> @@ -89,13 +89,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> 
>  static inline void pte_free(struct mm_struct *mm, struct page *pte)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	__free_page(pte);
>  }
> 
>  #define __pte_free_tlb(tlb, pte, addr)	\
>  do {					\
> -	pgtable_page_dtor(pte);		\
> +	pgtable_pte_page_dtor(pte);	\
>  	tlb_remove_page((tlb), (pte));	\
>  } while (0)
> 
> diff --git a/arch/powerpc/mm/pgtable-frag.c b/arch/powerpc/mm/pgtable-frag.c
> index a7b05214760c..ee4bd6d38602 100644
> --- a/arch/powerpc/mm/pgtable-frag.c
> +++ b/arch/powerpc/mm/pgtable-frag.c
> @@ -25,7 +25,7 @@ void pte_frag_destroy(void *pte_frag)
>  	count = ((unsigned long)pte_frag & ~PAGE_MASK) >> PTE_FRAG_SIZE_SHIFT;
>  	/* We allow PTE_FRAG_NR fragments from a PTE page */
>  	if (atomic_sub_and_test(PTE_FRAG_NR - count, &page->pt_frag_refcount)) {
> -		pgtable_page_dtor(page);
> +		pgtable_pte_page_dtor(page);
>  		__free_page(page);
>  	}
>  }
> @@ -61,7 +61,7 @@ static pte_t *__alloc_for_ptecache(struct mm_struct *mm, int kernel)
>  		page = alloc_page(PGALLOC_GFP | __GFP_ACCOUNT);
>  		if (!page)
>  			return NULL;
> -		if (!pgtable_page_ctor(page)) {
> +		if (!pgtable_pte_page_ctor(page)) {
>  			__free_page(page);
>  			return NULL;
>  		}
> @@ -113,7 +113,7 @@ void pte_fragment_free(unsigned long *table, int kernel)
>  	BUG_ON(atomic_read(&page->pt_frag_refcount) <= 0);
>  	if (atomic_dec_and_test(&page->pt_frag_refcount)) {
>  		if (!kernel)
> -			pgtable_page_dtor(page);
> +			pgtable_pte_page_dtor(page);
>  		__free_page(page);
>  	}
>  }
> diff --git a/arch/riscv/include/asm/pgalloc.h b/arch/riscv/include/asm/pgalloc.h
> index 56a67d66f72f..c1e2780f7352 100644
> --- a/arch/riscv/include/asm/pgalloc.h
> +++ b/arch/riscv/include/asm/pgalloc.h
> @@ -78,7 +78,7 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
> 
>  #define __pte_free_tlb(tlb, pte, buf)   \
>  do {                                    \
> -	pgtable_page_dtor(pte);         \
> +	pgtable_pte_page_dtor(pte);     \
>  	tlb_remove_page((tlb), pte);    \
>  } while (0)
> 
> diff --git a/arch/s390/mm/pgalloc.c b/arch/s390/mm/pgalloc.c
> index 99e06213a22b..962d32497912 100644
> --- a/arch/s390/mm/pgalloc.c
> +++ b/arch/s390/mm/pgalloc.c
> @@ -212,7 +212,7 @@ unsigned long *page_table_alloc(struct mm_struct *mm)
>  	page = alloc_page(GFP_KERNEL);
>  	if (!page)
>  		return NULL;
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return NULL;
>  	}
> @@ -258,7 +258,7 @@ void page_table_free(struct mm_struct *mm, unsigned long *table)
>  		atomic_xor_bits(&page->_refcount, 3U << 24);
>  	}
> 
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	__free_page(page);
>  }
> 
> @@ -310,7 +310,7 @@ void __tlb_remove_table(void *_table)
>  	case 3:		/* 4K page table with pgstes */
>  		if (mask & 3)
>  			atomic_xor_bits(&page->_refcount, 3 << 24);
> -		pgtable_page_dtor(page);
> +		pgtable_pte_page_dtor(page);
>  		__free_page(page);
>  		break;
>  	}
> diff --git a/arch/sh/include/asm/pgalloc.h b/arch/sh/include/asm/pgalloc.h
> index b56f908b1395..473a46fb78fe 100644
> --- a/arch/sh/include/asm/pgalloc.h
> +++ b/arch/sh/include/asm/pgalloc.h
> @@ -46,7 +46,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	if (!pg)
>  		return NULL;
>  	page = virt_to_page(pg);
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		quicklist_free(QUICK_PT, NULL, pg);
>  		return NULL;
>  	}
> @@ -60,13 +60,13 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> 
>  static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	quicklist_free_page(QUICK_PT, NULL, pte);
>  }
> 
>  #define __pte_free_tlb(tlb,pte,addr)			\
>  do {							\
> -	pgtable_page_dtor(pte);				\
> +	pgtable_pte_page_dtor(pte);			\
>  	tlb_remove_page((tlb), (pte));			\
>  } while (0)
> 
> diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
> index 4b099dd7a767..e6d91819da92 100644
> --- a/arch/sparc/mm/init_64.c
> +++ b/arch/sparc/mm/init_64.c
> @@ -2903,7 +2903,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	struct page *page = alloc_page(GFP_KERNEL | __GFP_ZERO);
>  	if (!page)
>  		return NULL;
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		free_unref_page(page);
>  		return NULL;
>  	}
> @@ -2919,7 +2919,7 @@ static void __pte_free(pgtable_t pte)
>  {
>  	struct page *page = virt_to_page(pte);
> 
> -	pgtable_page_dtor(page);
> +	pgtable_pte_page_dtor(page);
>  	__free_page(page);
>  }
> 
> diff --git a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
> index aaebbc00d262..cc3ad64479ac 100644
> --- a/arch/sparc/mm/srmmu.c
> +++ b/arch/sparc/mm/srmmu.c
> @@ -378,7 +378,7 @@ pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	if ((pte = (unsigned long)pte_alloc_one_kernel(mm)) == 0)
>  		return NULL;
>  	page = pfn_to_page(__nocache_pa(pte) >> PAGE_SHIFT);
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return NULL;
>  	}
> @@ -389,7 +389,7 @@ void pte_free(struct mm_struct *mm, pgtable_t pte)
>  {
>  	unsigned long p;
> 
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	p = (unsigned long)page_address(pte);	/* Cached address (for test) */
>  	if (p == 0)
>  		BUG();
> diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.h
> index d7b282e9c4d5..f70df6f5626d 100644
> --- a/arch/um/include/asm/pgalloc.h
> +++ b/arch/um/include/asm/pgalloc.h
> @@ -29,7 +29,7 @@ extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
> 
>  #define __pte_free_tlb(tlb,pte, address)		\
>  do {							\
> -	pgtable_page_dtor(pte);				\
> +	pgtable_pte_page_dtor(pte);			\
>  	tlb_remove_page((tlb),(pte));			\
>  } while (0)
> 
> diff --git a/arch/unicore32/include/asm/tlb.h b/arch/unicore32/include/asm/tlb.h
> index 10d2356bfddd..4663d8cc80ef 100644
> --- a/arch/unicore32/include/asm/tlb.h
> +++ b/arch/unicore32/include/asm/tlb.h
> @@ -15,7 +15,7 @@
> 
>  #define __pte_free_tlb(tlb, pte, addr)				\
>  	do {							\
> -		pgtable_page_dtor(pte);				\
> +		pgtable_pte_page_dtor(pte);			\
>  		tlb_remove_page((tlb), (pte));			\
>  	} while (0)
> 
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 44816ff6411f..73757bc0eb87 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -45,7 +45,7 @@ early_param("userpte", setup_userpte);
> 
>  void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	paravirt_release_pte(page_to_pfn(pte));
>  	paravirt_tlb_remove_table(tlb, pte);
>  }
> diff --git a/arch/xtensa/include/asm/pgalloc.h b/arch/xtensa/include/asm/pgalloc.h
> index dd744aa450fa..1d38f0e755ba 100644
> --- a/arch/xtensa/include/asm/pgalloc.h
> +++ b/arch/xtensa/include/asm/pgalloc.h
> @@ -55,7 +55,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
>  	if (!pte)
>  		return NULL;
>  	page = virt_to_page(pte);
> -	if (!pgtable_page_ctor(page)) {
> +	if (!pgtable_pte_page_ctor(page)) {
>  		__free_page(page);
>  		return NULL;
>  	}
> @@ -69,7 +69,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> 
>  static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
>  {
> -	pgtable_page_dtor(pte);
> +	pgtable_pte_page_dtor(pte);
>  	__free_page(pte);
>  }
>  #define pmd_pgtable(pmd) pmd_page(pmd)
> diff --git a/include/asm-generic/pgalloc.h b/include/asm-generic/pgalloc.h
> index 8476175c07e7..ef7ece04a336 100644
> --- a/include/asm-generic/pgalloc.h
> +++ b/include/asm-generic/pgalloc.h
> @@ -49,7 +49,7 @@ static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
>   * @mm: the mm_struct of the current context
>   * @gfp: GFP flags to use for the allocation
>   *
> - * Allocates a page and runs the pgtable_page_ctor().
> + * Allocates a page and runs the pgtable_pte_page_ctor().
>   *
>   * This function is intended for architectures that need
>   * anything beyond simple page allocation or must have custom GFP flags.
> @@ -63,7 +63,7 @@ static inline pgtable_t __pte_alloc_one(struct mm_struct *mm, gfp_t gfp)
>  	pte = alloc_page(gfp);
>  	if (!pte)
>  		return NULL;
> -	if (!pgtable_page_ctor(pte)) {
> +	if (!pgtable_pte_page_ctor(pte)) {
>  		__free_page(pte);
>  		return NULL;
>  	}
> @@ -76,7 +76,7 @@ static inline pgtable_t __pte_alloc_one(struct mm_struct *mm, gfp_t gfp)
>   * pte_alloc_one - allocate a page for PTE-level user page table
>   * @mm: the mm_struct of the current context
>   *
> - * Allocates a page and runs the pgtable_page_ctor().
> + * Allocates a page and runs the pgtable_pte_page_ctor().
>   *
>   * Return: `struct page` initialized as page table or %NULL on error
>   */
> @@ -98,7 +98,7 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm)
>   */
>  static inline void pte_free(struct mm_struct *mm, struct page *pte_page)
>  {
> -	pgtable_page_dtor(pte_page);
> +	pgtable_pte_page_dtor(pte_page);
>  	__free_page(pte_page);
>  }
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..662230704a05 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1972,7 +1972,7 @@ static inline void pgtable_init(void)
>  	pgtable_cache_init();
>  }
> 
> -static inline bool pgtable_page_ctor(struct page *page)
> +static inline bool pgtable_pte_page_ctor(struct page *page)
>  {
>  	if (!ptlock_init(page))
>  		return false;
> @@ -1981,7 +1981,7 @@ static inline bool pgtable_page_ctor(struct page *page)
>  	return true;
>  }
> 
> -static inline void pgtable_page_dtor(struct page *page)
> +static inline void pgtable_pte_page_dtor(struct page *page)
>  {
>  	ptlock_free(page);
>  	__ClearPageTable(page);
> -- 
> 2.11.0
> 

-- 
Sincerely yours,
Mike.

