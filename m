Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46202C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6F1821971
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6F1821971
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67AFB6B0003; Fri, 19 Apr 2019 11:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62B746B0006; Fri, 19 Apr 2019 11:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519606B0007; Fri, 19 Apr 2019 11:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1EC6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:03:07 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 54so5039514qtn.15
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 08:03:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=qylEVom0l+bKTWkQi0OOKOrFTTNxJj2JfwjTHdMU3n0=;
        b=NSl0OOcYYubGH8Vlak7jT9LhtkP18ocLgKKYU0053qDe0Ek7iVHozUUtFc29JE3HUU
         72UkzXAtsBjpCNlyqKDVkdjR2eNKkxhtqCfqGYWg1Lms22/FIAwGS7hPM3fomL6t8ltA
         jgCm/DkzgfZKwMSttsGABUNhf4+tWdd/4dROYf+zLwm+Ai55vRoti0Rxuu18Awn76amL
         zWz+zVPQHys+V7QX8eDljAFYaAFN1oG0hyNQzQpNrCiP9ua/wcpADpzYDdhbMxw5akQc
         ZfHD3fY6ZpTe1OvhGZTn3OFdI/0aaxMWCydJOQsFCduZxPhmW+G9XYQtwML821jwO/ru
         2fYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWlXzvLfoVQJ3xVaBmy/nDLVRsGsoIHXXdKAftrBkMQ4EmMJPkw
	UT8ER/jHA6kNWp8UAxqKhY94gvrRG2Cixg1lFVnb5kt9w3rDmHItlFAy9PXWNUTa8esG/4D6x5e
	G+vX2J6WNV6x6PIoNxL5BexTM3/lBSmneHeR5XiI3+2UYCFeAB/eKcId8DUMoZcNjJA==
X-Received: by 2002:a37:4c04:: with SMTP id z4mr3549009qka.312.1555686186888;
        Fri, 19 Apr 2019 08:03:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPyBK5RyykmhvMWCVlKPbCZ70c1tzA9PJ8zgWlV8rUSkSpsc1l/ZsK9bGbhgYOpFkhyrmY
X-Received: by 2002:a37:4c04:: with SMTP id z4mr3548905qka.312.1555686185808;
        Fri, 19 Apr 2019 08:03:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555686185; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAqN8FtHwPa7HVFPOUYSSreic7VE6A/vp0h5tESsBQUJjgwg69iIpe5U6zC1fwdUGj
         Rx2gW8uBvdb1boPyYIDTSoNPMFvCqICUQE4TXamrSMvSaaK87gmQco8kJqYf1Tv2bLzB
         8hGo24VqmELM6GgyMm8fz+RofYK7IfLk6rNo63RTDP386QinYhrst9JgNWL6eC8401My
         lUrZUeodMxUciv0AwLc5vk8WkK/Jvnnke77rjPsTi9DtKx/E90Gn1iOfZU/PWulUzvT8
         8iNNl1ZpR2r1qmLGycfJT2Uaf0v5833N7eJwqamzdysyaNgRtd9+kgeW724nWNTSTDxN
         /OuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=qylEVom0l+bKTWkQi0OOKOrFTTNxJj2JfwjTHdMU3n0=;
        b=FEmwWnm5NZs7QX6B/nJRci2vKhbdiX54vFCAObb0pGbbNhIH2rZiyh6C5g1t3lC1ee
         d+F1Tmu2tj9SddcGuyItfc3hW314om3J9bU71HZdhsmXSqVkoJtSNG6i8H1KnCQluNDH
         qwj8HR1qY0gZHB51dBhzAaGPkf9h7FjPpSzyLL0EK/pBsH8XlBEVmpFINHImyAL21UrW
         ij5Xn2qFMAZqimJajQ2ho5u6pvc9IY8maPw+KrvIiNg0vvLnXo4FBmlNrqoBb60lKQWs
         0YNDlvBTOLQF1kiTZ/LQi6xFwHXiGw6E6hAJghVOTHag8EGFHAgM0mt6bC+LNHJXaYpi
         3+8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h24si621053qkl.260.2019.04.19.08.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 08:03:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4400188E48;
	Fri, 19 Apr 2019 15:03:04 +0000 (UTC)
Received: from redhat.com (ovpn-121-136.rdu2.redhat.com [10.10.121.136])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 933BA1001DEB;
	Fri, 19 Apr 2019 15:02:55 +0000 (UTC)
Date: Fri, 19 Apr 2019 11:02:53 -0400
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
Message-ID: <20190419150253.GA3311@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
 <20190419062650.GF13323@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190419062650.GF13323@xz-x1>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 19 Apr 2019 15:03:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 02:26:50PM +0800, Peter Xu wrote:
> On Thu, Apr 18, 2019 at 04:51:15PM -0400, Jerome Glisse wrote:
> > On Wed, Mar 20, 2019 at 10:06:28AM +0800, Peter Xu wrote:
> > > This allows uffd-wp to support write-protected pages for COW.
> > > 
> > > For example, the uffd write-protected PTE could also be write-protected
> > > by other usages like COW or zero pages.  When that happens, we can't
> > > simply set the write bit in the PTE since otherwise it'll change the
> > > content of every single reference to the page.  Instead, we should do
> > > the COW first if necessary, then handle the uffd-wp fault.
> > > 
> > > To correctly copy the page, we'll also need to carry over the
> > > _PAGE_UFFD_WP bit if it was set in the original PTE.
> > > 
> > > For huge PMDs, we just simply split the huge PMDs where we want to
> > > resolve an uffd-wp page fault always.  That matches what we do with
> > > general huge PMD write protections.  In that way, we resolved the huge
> > > PMD copy-on-write issue into PTE copy-on-write.
> > > 
> > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > 
> > This one has a bug see below.
> > 
> > 
> > > ---
> > >  mm/memory.c   |  5 +++-
> > >  mm/mprotect.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++---
> > >  2 files changed, 65 insertions(+), 4 deletions(-)
> > > 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index e7a4b9650225..b8a4c0bab461 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2291,7 +2291,10 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
> > >  		}
> > >  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> > >  		entry = mk_pte(new_page, vma->vm_page_prot);
> > > -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > > +		if (pte_uffd_wp(vmf->orig_pte))
> > > +			entry = pte_mkuffd_wp(entry);
> > > +		else
> > > +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > >  		/*
> > >  		 * Clear the pte entry and flush it first, before updating the
> > >  		 * pte with the new entry. This will avoid a race condition
> > > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > > index 9d4433044c21..855dddb07ff2 100644
> > > --- a/mm/mprotect.c
> > > +++ b/mm/mprotect.c
> > > @@ -73,18 +73,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >  	flush_tlb_batched_pending(vma->vm_mm);
> > >  	arch_enter_lazy_mmu_mode();
> > >  	do {
> > > +retry_pte:
> > >  		oldpte = *pte;
> > >  		if (pte_present(oldpte)) {
> > >  			pte_t ptent;
> > >  			bool preserve_write = prot_numa && pte_write(oldpte);
> > > +			struct page *page;
> > >  
> > >  			/*
> > >  			 * Avoid trapping faults against the zero or KSM
> > >  			 * pages. See similar comment in change_huge_pmd.
> > >  			 */
> > >  			if (prot_numa) {
> > > -				struct page *page;
> > > -
> > >  				page = vm_normal_page(vma, addr, oldpte);
> > >  				if (!page || PageKsm(page))
> > >  					continue;
> > > @@ -114,6 +114,54 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > >  					continue;
> > >  			}
> > >  
> > > +			/*
> > > +			 * Detect whether we'll need to COW before
> > > +			 * resolving an uffd-wp fault.  Note that this
> > > +			 * includes detection of the zero page (where
> > > +			 * page==NULL)
> > > +			 */
> > > +			if (uffd_wp_resolve) {
> > > +				/* If the fault is resolved already, skip */
> > > +				if (!pte_uffd_wp(*pte))
> > > +					continue;
> > > +				page = vm_normal_page(vma, addr, oldpte);
> > > +				if (!page || page_mapcount(page) > 1) {
> > > +					struct vm_fault vmf = {
> > > +						.vma = vma,
> > > +						.address = addr & PAGE_MASK,
> > > +						.page = page,
> > > +						.orig_pte = oldpte,
> > > +						.pmd = pmd,
> > > +						/* pte and ptl not needed */
> > > +					};
> > > +					vm_fault_t ret;
> > > +
> > > +					if (page)
> > > +						get_page(page);
> > > +					arch_leave_lazy_mmu_mode();
> > > +					pte_unmap_unlock(pte, ptl);
> > > +					ret = wp_page_copy(&vmf);
> > > +					/* PTE is changed, or OOM */
> > > +					if (ret == 0)
> > > +						/* It's done by others */
> > > +						continue;
> > 
> > This is wrong if ret == 0 you still need to remap the pte before
> > continuing as otherwise you will go to next pte without the page
> > table lock for the directory. So 0 case must be handled after
> > arch_enter_lazy_mmu_mode() below.
> > 
> > Sorry i should have catch that in previous review.
> 
> My fault to not have noticed it since the very beginning... thanks for
> spotting that.
> 
> I'm squashing below changes into the patch:


Well thinking of this some more i think you should use do_wp_page() and
not wp_page_copy() it would avoid bunch of code above and also you are
not properly handling KSM page or page in the swap cache. Instead of
duplicating same code that is in do_wp_page() it would be better to call
it here.


> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 3cddfd6627b8..13d493b836bb 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -141,22 +141,19 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>                                         arch_leave_lazy_mmu_mode();
>                                         pte_unmap_unlock(pte, ptl);
>                                         ret = wp_page_copy(&vmf);
> -                                       /* PTE is changed, or OOM */
> -                                       if (ret == 0)
> -                                               /* It's done by others */
> -                                               continue;
> -                                       else if (WARN_ON(ret != VM_FAULT_WRITE))
> +                                       if (ret != VM_FAULT_WRITE && ret != 0)
> +                                               /* Probably OOM */
>                                                 return pages;
>                                         pte = pte_offset_map_lock(vma->vm_mm,
>                                                                   pmd, addr,
>                                                                   &ptl);
>                                         arch_enter_lazy_mmu_mode();
> -                                       if (!pte_present(*pte))
> +                                       if (ret == 0 || !pte_present(*pte))
>                                                 /*
>                                                  * This PTE could have been
> -                                                * modified after COW
> -                                                * before we have taken the
> -                                                * lock; retry this PTE
> +                                                * modified during or after
> +                                                * COW before take the lock;
> +                                                * retry.
>                                                  */
>                                                 goto retry_pte;
>                                 }
> 
> [...]
> 
> > >  		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> > > -			if (next - addr != HPAGE_PMD_SIZE) {
> > > +			/*
> > > +			 * When resolving an userfaultfd write
> > > +			 * protection fault, it's not easy to identify
> > > +			 * whether a THP is shared with others and
> > > +			 * whether we'll need to do copy-on-write, so
> > > +			 * just split it always for now to simply the
> > > +			 * procedure.  And that's the policy too for
> > > +			 * general THP write-protect in af9e4d5f2de2.
> > > +			 */
> > > +			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {
> > 
> > Just a nit pick can you please add () to next - addr ie:
> > if ((next - addr) != HPAGE_PMD_SIZE || uffd_wp_resolve) {
> > 
> > I know it is not needed but each time i bump into this i
> > have to scratch my head for second to remember the operator
> > rules :)
> 
> Sure, as usual. :) And I tend to agree it's a good habit.  It's just
> me that always forgot about it.
> 
> Thanks,
> 
> -- 
> Peter Xu

