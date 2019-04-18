Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4D1AC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6145F214DA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 20:51:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6145F214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDFED6B026D; Thu, 18 Apr 2019 16:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8F7C6B026E; Thu, 18 Apr 2019 16:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D579F6B026F; Thu, 18 Apr 2019 16:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AFAD96B026D
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:51:25 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id x18so2713223qkf.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 13:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=emfOYHs9HowdZh8bc6w6D6s/HR3MXIdxJdO6xhEVkXA=;
        b=igcfmvdu1RlvuVMiEq+/if4CKQL4qU4ire6Bi96y8EiLPbQu+Vy9ydULXg8cFz8jhm
         cWz568VmSd2AzwggEAE+wSIT40oPjpErLR5HAm/DP+Dh58Yo3Wnts02EJzziCd/LHNQC
         4rkLY1lT29Q7xWtH8T9Hqr4whI3DDK46cjHRHL48djdk3Y92+hqbgjqAzQibxLSSaPA7
         y3Nal1sN+I62Afd/fY8AtL9rrZTL+48FUAlSYCZ3qnwvh0bzPsBfKPhr01QZ5DBE2Y6F
         uqQL6iMc1sLll/S4B1UScqFH3a+Aw3Ru3QqCdW5bpV0xaM6jV8uyzvvygBLH51hYkhWu
         +nlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXc8uk4pv7ZLuKoz1kygTrsJ+zC8rv/b74vasiOr81zdkisoCmw
	5xeVcZhHUQq6p3DLIQg7shj6Xgw1c9ZzLq9ZRRjHTwW6cmvHnODU9h4T7FdR9d4F9dvHJ7ycRVU
	JdX7kxhTpLIvlz/vEgrC/b02TffjnNeVIvHtY3910p8DWzPJZyFcYtJ/nz+lDic9mlw==
X-Received: by 2002:ae9:f44a:: with SMTP id z10mr57076qkl.223.1555620685434;
        Thu, 18 Apr 2019 13:51:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxI1cm+SCTG3x3MCtOkpA7XQ4/YWNuJQb4yk2NXHFZjhHWviht2U3Jb3VysaGSkAOCaKDB9
X-Received: by 2002:ae9:f44a:: with SMTP id z10mr57034qkl.223.1555620684564;
        Thu, 18 Apr 2019 13:51:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555620684; cv=none;
        d=google.com; s=arc-20160816;
        b=NtP2Jrfj8qCpT9KxtLR5wFtkiKCYVAXggSpz/O+ckmOJSWB7MyV89NG1CLgbjDbBGe
         yDxsf9XUMBSOPCNB2WZqRwzuh2oUpLP8tPauMmSiMWis1DwhgYGXUcf01PJX0deB+JIs
         aOe+C6BrTUgF/crASZ/KWklCxNmyTVbg2AbwcdD8aI4hB+gBgoi28cMKDFE5+cU9BLgT
         4EEfkl9+Ep5GE3V2Oz6DBrKMeavT4YeBxnzXnHcJtPzLj+yRoVPtONyaThzyIwsorVlW
         kUHB4RJlS+2u1M/GdBP2JTxWGjkViEk6VkHN6EPaQdnnslVhj+heZfUBfEC7aP0PUP84
         Cg8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=emfOYHs9HowdZh8bc6w6D6s/HR3MXIdxJdO6xhEVkXA=;
        b=FE5b9k4FhUYQmJu18OjUAdiEGN68G06nImpPWicFlH0NoOQsHTix0aldX45Zr19Mf2
         7Wa6sY4KXD+2HJJJsBhn+qWdcG1HsLDRm2qyFyHafwvgRns7bdbvr2/KEoEKr9tkMJZ2
         K2w7FmV6v9fvBHteQtINjMSlQLAqQSuApXlv7PkIPrksFIxVTZQCZo+2Dj+v/mmLJ06x
         WmuX5o+6BpRAVJK1o0t14Y0TM+s+eYA9NbUsTH53M6Y20ty9zfz8S47FtE5kJb10xD3G
         8vR2FuMh8OjTXqKWZFEZMmVJSwTeSY7+18BbmFv+0ADPorrUNTnkAyd2QaYGLchmzgjA
         lTiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l27si1679735qtl.125.2019.04.18.13.51.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 13:51:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 78C61C04AC4B;
	Thu, 18 Apr 2019 20:51:23 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1926419C58;
	Thu, 18 Apr 2019 20:51:16 +0000 (UTC)
Date: Thu, 18 Apr 2019 16:51:15 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 14/28] userfaultfd: wp: handle COW properly for uffd-wp
Message-ID: <20190418202558.GK3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190320020642.4000-15-peterx@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 18 Apr 2019 20:51:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 10:06:28AM +0800, Peter Xu wrote:
> This allows uffd-wp to support write-protected pages for COW.
> 
> For example, the uffd write-protected PTE could also be write-protected
> by other usages like COW or zero pages.  When that happens, we can't
> simply set the write bit in the PTE since otherwise it'll change the
> content of every single reference to the page.  Instead, we should do
> the COW first if necessary, then handle the uffd-wp fault.
> 
> To correctly copy the page, we'll also need to carry over the
> _PAGE_UFFD_WP bit if it was set in the original PTE.
> 
> For huge PMDs, we just simply split the huge PMDs where we want to
> resolve an uffd-wp page fault always.  That matches what we do with
> general huge PMD write protections.  In that way, we resolved the huge
> PMD copy-on-write issue into PTE copy-on-write.
> 
> Signed-off-by: Peter Xu <peterx@redhat.com>

This one has a bug see below.


> ---
>  mm/memory.c   |  5 +++-
>  mm/mprotect.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 65 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index e7a4b9650225..b8a4c0bab461 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2291,7 +2291,10 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
>  		}
>  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  		entry = mk_pte(new_page, vma->vm_page_prot);
> -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +		if (pte_uffd_wp(vmf->orig_pte))
> +			entry = pte_mkuffd_wp(entry);
> +		else
> +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  		/*
>  		 * Clear the pte entry and flush it first, before updating the
>  		 * pte with the new entry. This will avoid a race condition
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 9d4433044c21..855dddb07ff2 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -73,18 +73,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  	flush_tlb_batched_pending(vma->vm_mm);
>  	arch_enter_lazy_mmu_mode();
>  	do {
> +retry_pte:
>  		oldpte = *pte;
>  		if (pte_present(oldpte)) {
>  			pte_t ptent;
>  			bool preserve_write = prot_numa && pte_write(oldpte);
> +			struct page *page;
>  
>  			/*
>  			 * Avoid trapping faults against the zero or KSM
>  			 * pages. See similar comment in change_huge_pmd.
>  			 */
>  			if (prot_numa) {
> -				struct page *page;
> -
>  				page = vm_normal_page(vma, addr, oldpte);
>  				if (!page || PageKsm(page))
>  					continue;
> @@ -114,6 +114,54 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  					continue;
>  			}
>  
> +			/*
> +			 * Detect whether we'll need to COW before
> +			 * resolving an uffd-wp fault.  Note that this
> +			 * includes detection of the zero page (where
> +			 * page==NULL)
> +			 */
> +			if (uffd_wp_resolve) {
> +				/* If the fault is resolved already, skip */
> +				if (!pte_uffd_wp(*pte))
> +					continue;
> +				page = vm_normal_page(vma, addr, oldpte);
> +				if (!page || page_mapcount(page) > 1) {
> +					struct vm_fault vmf = {
> +						.vma = vma,
> +						.address = addr & PAGE_MASK,
> +						.page = page,
> +						.orig_pte = oldpte,
> +						.pmd = pmd,
> +						/* pte and ptl not needed */
> +					};
> +					vm_fault_t ret;
> +
> +					if (page)
> +						get_page(page);
> +					arch_leave_lazy_mmu_mode();
> +					pte_unmap_unlock(pte, ptl);
> +					ret = wp_page_copy(&vmf);
> +					/* PTE is changed, or OOM */
> +					if (ret == 0)
> +						/* It's done by others */
> +						continue;

This is wrong if ret == 0 you still need to remap the pte before
continuing as otherwise you will go to next pte without the page
table lock for the directory. So 0 case must be handled after
arch_enter_lazy_mmu_mode() below.

Sorry i should have catch that in previous review.


> +					else if (WARN_ON(ret != VM_FAULT_WRITE))
> +						return pages;
> +					pte = pte_offset_map_lock(vma->vm_mm,
> +								  pmd, addr,
> +								  &ptl);
> +					arch_enter_lazy_mmu_mode();
> +					if (!pte_present(*pte))
> +						/*
> +						 * This PTE could have been
> +						 * modified after COW
> +						 * before we have taken the
> +						 * lock; retry this PTE
> +						 */
> +						goto retry_pte;
> +				}
> +			}
> +
>  			ptent = ptep_modify_prot_start(mm, addr, pte);
>  			ptent = pte_modify(ptent, newprot);
>  			if (preserve_write)

>  	unsigned long pages = 0;
>  	unsigned long nr_huge_updates = 0;
>  	struct mmu_notifier_range range;
> +	bool uffd_wp_resolve = cp_flags & MM_CP_UFFD_WP_RESOLVE;
>  
>  	range.start = 0;
>  
> @@ -202,7 +251,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		}
>  
>  		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> -			if (next - addr != HPAGE_PMD_SIZE) {
> +			/*
> +			 * When resolving an userfaultfd write
> +			 * protection fault, it's not easy to identify
> +			 * whether a THP is shared with others and
> +			 * whether we'll need to do copy-on-write, so
> +			 * just split it always for now to simply the
> +			 * procedure.  And that's the policy too for
> +			 * general THP write-protect in af9e4d5f2de2.
> +			 */
> +			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {

Just a nit pick can you please add () to next - addr ie:
if ((next - addr) != HPAGE_PMD_SIZE || uffd_wp_resolve) {

I know it is not needed but each time i bump into this i
have to scratch my head for second to remember the operator
rules :)

>  				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  			} else {
>  				int nr_ptes = change_huge_pmd(vma, pmd, addr,
> -- 
> 2.17.1
> 

