Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D37EBC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DB3D2171F
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DB3D2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C546B0005; Fri,  9 Aug 2019 04:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21E6A6B0006; Fri,  9 Aug 2019 04:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10CD46B0008; Fri,  9 Aug 2019 04:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B57AB6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:57:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y24so59971057edb.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:57:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wt7OavJ93EtvrTb8n4MfirECOa5MzqiMFcE9+KCS/7o=;
        b=nqAJafIwveuKs3Fo6oMBqh12SHmj8O4D5zxj7gqYWPtvCioMq9Z59aYSbmgPAhMfnn
         U89UDBc6y2QakPTQHe6Cd+08w7cPDV1hagOCZBlYNUMdwhSgdWABFRWEvSvyVA0kpeRt
         Luh3YxfF8jL1YLovln+AlZWg/nbHjBz1/ERfICn/lMOMgdNKEGDjI4bqRJO4Sv4OsL8U
         UIPm++cnRWuXfq5F534DkJjtTnslfWUJD5Od3c7+1QgEcvnKzbIfywppcO+pDmmN0IvJ
         OwZb72zRVeabNedklD8i9nMjAf9oVau0W2Q9T8xGzhYvVcl6oypmxLrd9jo4SvFPzKdx
         CprQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWan7mWpj7ARGfo0bmPWcVZKY9S3C7tEI7ve95kYV0Gz6SZC1/G
	USE3uo/W0IVZP+3JiLbedFKFrXn7dyxnzt8eh7a0i6fxea/XVDdRSgJQHok48dTTsUeKf5XWl2v
	FcXF8gmT4T8hrSAPe0tXngBGxpaKwpvqqm/mYyQ3aWoa/T87H7Ele7+/RJxHvplIE1w==
X-Received: by 2002:a50:92a5:: with SMTP id k34mr20698927eda.90.1565341041273;
        Fri, 09 Aug 2019 01:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5VUGnnJ8ROpADBoFDLwVXV8cq3uYm26Z5H7Mou8yDf+2NfOo+rATRpyFbmdUp+J1E4iGD
X-Received: by 2002:a50:92a5:: with SMTP id k34mr20698869eda.90.1565341040417;
        Fri, 09 Aug 2019 01:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565341040; cv=none;
        d=google.com; s=arc-20160816;
        b=Axwynd4iSqX1hE2B5ShDIaYzmB5GJzy68A35G3oR27qELAnWdkyn12OYuA3Qa/nW6/
         6miYIyRpUot7HPf2iiRBOjF8pU2QLTpGh5wCBCg5Bu8fbROpVf1zEZKNSDAA+72fUVHI
         NfyoniY0R7p7uIeazINfazNrDllDX3OJl/XiJfkwudsl1PrWEzboLQUSfKiQj6hk34Q6
         dl19k2M2NoEUN7DMBJ5EINDd7ZweWQ3h/aWebeJLUMDAk7okLLODH6XWABc4A0BglLcg
         F/Qvhv/lEMd2b6XmolLhjfcaLBFe5KwtXV9myQfjdS2YbEQOPHvDSOBltbS2gokKUIsr
         JVGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=wt7OavJ93EtvrTb8n4MfirECOa5MzqiMFcE9+KCS/7o=;
        b=jAzG0G4peQ1nxZBaOMtUdsxeWQTdc0uOjqc9ep3C3IhOptMyZmVN2qeD+Y3u/wd6cf
         kbxDzMcSU+q6eJTB8l9lrfnSBXxzwi2Evf74OX7jnYcJ3TzQ65eQQsgkwHz0d1LDhL0k
         rk/n7flbdmUywH6zNwBm6KlNmlh7mW/hTZQp4tzR/YVeW7P88WwJ74QkcMU7vvEdwgQ8
         UAuBsZywE6qzoUsTd2gShkuVj6SdaHF4hnO2Og6mbE2gwHATyLozX0aJhocWHm/tR+2u
         PJkV+u8i5FaizEsYkdKZ1gfTtOERfmAaPcGq8GZUcLokgAZpvCf2HFpdxKKActGpEIZ0
         pZug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h4si37543637edb.133.2019.08.09.01.57.20
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 01:57:20 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D0F5344;
	Fri,  9 Aug 2019 01:57:19 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 680393F706;
	Fri,  9 Aug 2019 01:57:18 -0700 (PDT)
Subject: Re: [PATCH 2/3] pagewalk: seperate function pointers from iterator
 data
To: Christoph Hellwig <hch@lst.de>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?Q?Thomas_Hellstr=c3=b6m?= <thomas@shipmail.org>,
 Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190808154240.9384-1-hch@lst.de>
 <20190808154240.9384-3-hch@lst.de>
From: Steven Price <steven.price@arm.com>
Message-ID: <e418faa0-49bf-1bc6-8f77-2849c1b6ae70@arm.com>
Date: Fri, 9 Aug 2019 09:57:17 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808154240.9384-3-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Subject: s/seperate/separate/

On 08/08/2019 16:42, Christoph Hellwig wrote:
> The mm_walk structure currently mixed data and code.  Split out the
> operations vectors into a new mm_walk_ops structure, and while we
> are changing the API also declare the mm_walk structure inside the
> walk_page_range and walk_page_vma functions.
> 
> Based on patch from Linus Torvalds.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  arch/openrisc/kernel/dma.c              |  22 +++--
>  arch/powerpc/mm/book3s64/subpage_prot.c |  10 +-
>  arch/s390/mm/gmap.c                     |  33 +++----
>  fs/proc/task_mmu.c                      |  74 +++++++--------
>  include/linux/pagewalk.h                |  64 +++++++------
>  mm/hmm.c                                |  40 +++-----
>  mm/madvise.c                            |  41 +++-----
>  mm/memcontrol.c                         |  23 +++--
>  mm/mempolicy.c                          |  15 ++-
>  mm/migrate.c                            |  15 ++-
>  mm/mincore.c                            |  15 ++-
>  mm/mprotect.c                           |  24 ++---
>  mm/pagewalk.c                           | 118 ++++++++++++++----------
>  13 files changed, 245 insertions(+), 249 deletions(-)
> 

[...]
> diff --git a/mm/pagewalk.c b/mm/pagewalk.c
> index 8a92a961a2ee..28510fc0dde1 100644
> --- a/mm/pagewalk.c
> +++ b/mm/pagewalk.c
> @@ -9,10 +9,11 @@ static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  {
>  	pte_t *pte;
>  	int err = 0;
> +	const struct mm_walk_ops *ops = walk->ops;
>  
>  	pte = pte_offset_map(pmd, addr);
>  	for (;;) {
> -		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
> +		err = ops->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
>  		if (err)
>  		       break;
>  		addr += PAGE_SIZE;
> @@ -30,6 +31,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pmd = pmd_offset(pud, addr);
> @@ -37,8 +39,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  again:
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_none(*pmd) || !walk->vma) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
> @@ -47,8 +49,8 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  		 * This implies that each ->pmd_entry() handler
>  		 * needs to know about pmd_trans_huge() pmds
>  		 */
> -		if (walk->pmd_entry)
> -			err = walk->pmd_entry(pmd, addr, next, walk);
> +		if (ops->pmd_entry)
> +			err = ops->pmd_entry(pmd, addr, next, walk);
>  		if (err)
>  			break;
>  
> @@ -56,7 +58,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  		 * Check this here so we only break down trans_huge
>  		 * pages when we _need_ to
>  		 */
> -		if (!walk->pte_entry)
> +		if (!ops->pte_entry)
>  			continue;
>  
>  		split_huge_pmd(walk->vma, pmd, addr);
> @@ -75,6 +77,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  {
>  	pud_t *pud;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pud = pud_offset(p4d, addr);
> @@ -82,18 +85,18 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>   again:
>  		next = pud_addr_end(addr, end);
>  		if (pud_none(*pud) || !walk->vma) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
>  
> -		if (walk->pud_entry) {
> +		if (ops->pud_entry) {
>  			spinlock_t *ptl = pud_trans_huge_lock(pud, walk->vma);
>  
>  			if (ptl) {
> -				err = walk->pud_entry(pud, addr, next, walk);
> +				err = ops->pud_entry(pud, addr, next, walk);
>  				spin_unlock(ptl);
>  				if (err)
>  					break;
> @@ -105,7 +108,7 @@ static int walk_pud_range(p4d_t *p4d, unsigned long addr, unsigned long end,
>  		if (pud_none(*pud))
>  			goto again;
>  
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_pmd_range(pud, addr, next, walk);
>  		if (err)
>  			break;
> @@ -119,19 +122,20 @@ static int walk_p4d_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  {
>  	p4d_t *p4d;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	p4d = p4d_offset(pgd, addr);
>  	do {
>  		next = p4d_addr_end(addr, end);
>  		if (p4d_none_or_clear_bad(p4d)) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_pud_range(p4d, addr, next, walk);
>  		if (err)
>  			break;
> @@ -145,19 +149,20 @@ static int walk_pgd_range(unsigned long addr, unsigned long end,
>  {
>  	pgd_t *pgd;
>  	unsigned long next;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	pgd = pgd_offset(walk->mm, addr);
>  	do {
>  		next = pgd_addr_end(addr, end);
>  		if (pgd_none_or_clear_bad(pgd)) {
> -			if (walk->pte_hole)
> -				err = walk->pte_hole(addr, next, walk);
> +			if (ops->pte_hole)
> +				err = ops->pte_hole(addr, next, walk);
>  			if (err)
>  				break;
>  			continue;
>  		}
> -		if (walk->pmd_entry || walk->pte_entry)
> +		if (ops->pmd_entry || ops->pte_entry)
>  			err = walk_p4d_range(pgd, addr, next, walk);
>  		if (err)
>  			break;
> @@ -183,6 +188,7 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
>  	unsigned long hmask = huge_page_mask(h);
>  	unsigned long sz = huge_page_size(h);
>  	pte_t *pte;
> +	const struct mm_walk_ops *ops = walk->ops;
>  	int err = 0;
>  
>  	do {
> @@ -190,9 +196,9 @@ static int walk_hugetlb_range(unsigned long addr, unsigned long end,
>  		pte = huge_pte_offset(walk->mm, addr & hmask, sz);
>  
>  		if (pte)
> -			err = walk->hugetlb_entry(pte, hmask, addr, next, walk);
> -		else if (walk->pte_hole)
> -			err = walk->pte_hole(addr, next, walk);
> +			err = ops->hugetlb_entry(pte, hmask, addr, next, walk);
> +		else if (ops->pte_hole)
> +			err = ops->pte_hole(addr, next, walk);
>  
>  		if (err)
>  			break;
> @@ -220,9 +226,10 @@ static int walk_page_test(unsigned long start, unsigned long end,
>  			struct mm_walk *walk)
>  {
>  	struct vm_area_struct *vma = walk->vma;
> +	const struct mm_walk_ops *ops = walk->ops;
>  
> -	if (walk->test_walk)
> -		return walk->test_walk(start, end, walk);
> +	if (ops->test_walk)
> +		return ops->test_walk(start, end, walk);
>  
>  	/*
>  	 * vma(VM_PFNMAP) doesn't have any valid struct pages behind VM_PFNMAP
> @@ -234,8 +241,8 @@ static int walk_page_test(unsigned long start, unsigned long end,
>  	 */
>  	if (vma->vm_flags & VM_PFNMAP) {
>  		int err = 1;
> -		if (walk->pte_hole)
> -			err = walk->pte_hole(start, end, walk);
> +		if (ops->pte_hole)
> +			err = ops->pte_hole(start, end, walk);
>  		return err ? err : 1;
>  	}
>  	return 0;
> @@ -248,7 +255,8 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>  	struct vm_area_struct *vma = walk->vma;
>  
>  	if (vma && is_vm_hugetlb_page(vma)) {
> -		if (walk->hugetlb_entry)
> +		const struct mm_walk_ops *ops = walk->ops;

NIT: checkpatch would like a blank line here

> +		if (ops->hugetlb_entry)
>  			err = walk_hugetlb_range(start, end, walk);
>  	} else
>  		err = walk_pgd_range(start, end, walk);
> @@ -258,11 +266,13 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>  
>  /**
>   * walk_page_range - walk page table with caller specific callbacks
> - * @start: start address of the virtual address range
> - * @end: end address of the virtual address range
> - * @walk: mm_walk structure defining the callbacks and the target address space
> + * @mm:		mm_struct representing the target process of page table walk
> + * @start:	start address of the virtual address range
> + * @end:	end address of the virtual address range
> + * @ops:	operation to call during the walk
> + * @private:	private data for callbacks' usage
>   *
> - * Recursively walk the page table tree of the process represented by @walk->mm
> + * Recursively walk the page table tree of the process represented by @mm
>   * within the virtual address range [@start, @end). During walking, we can do
>   * some caller-specific works for each entry, by setting up pmd_entry(),
>   * pte_entry(), and/or hugetlb_entry(). If you don't set up for some of these

Missing context:
>  *
>  * Before starting to walk page table, some callers want to check whether
>  * they really want to walk over the current vma, typically by checking
>  * its vm_flags. walk_page_test() and @walk->test_walk() are used for this
>  * purpose.

@walk->test_walk() should now be @ops->test_walk()

> @@ -283,42 +293,48 @@ static int __walk_page_range(unsigned long start, unsigned long end,
>   *
>   * struct mm_walk keeps current values of some common data like vma and pmd,
>   * which are useful for the access from callbacks. If you want to pass some
> - * caller-specific data to callbacks, @walk->private should be helpful.
> + * caller-specific data to callbacks, @private should be helpful.
>   *
>   * Locking:
>   *   Callers of walk_page_range() and walk_page_vma() should hold
>   *   @walk->mm->mmap_sem, because these function traverse vma list and/or

s/walk->//

Otherwise looks good - I've rebased my series on it and the initial
testing is fine. So for the series:

Reviewed-by: Steven Price <steven.price@arm.com>

Thanks,

Steve

