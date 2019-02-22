Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94585C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 08:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BF9E207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 08:46:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BF9E207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE9418E00F4; Fri, 22 Feb 2019 03:46:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D98998E00F3; Fri, 22 Feb 2019 03:46:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAD6C8E00F4; Fri, 22 Feb 2019 03:46:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A3A108E00F3
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 03:46:19 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id f24so1512041qte.4
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 00:46:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4CJtbH2lfYSI9EN2bF3lCD31+oWXq0MHp6JnXjtGT4k=;
        b=ektCx532I29cqtFxSEdYl5PFrf52TruYrm0a4h4ZrqyONkrkVLaTzzXlOE4ZgBCMHa
         Zcl8MSAulz2OBOGe0lm4p9u+SuvCBUOpQ/jq5vVbn3/v0pqV78q989U/SsJqb9dp/55I
         IYmP+PGOHooE5dPhYAgks4BfrjPxXb4jpYR87XXDWTiha1DstsMWNLz2/574hR/Qtamn
         F4Gx5hBdnMT+rhKZqDUV3NqNSeMABuOW/076LGz5+RYIu1lSMdPEMSnA7pANq+pI72LE
         QHwb6Lu/3RHXGdoRCcDMfIDWPdWv+lTIGf2SNquZ08cSo7kudAqKxRPSbbsPZUmDfNtE
         POxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYP6GzThUasT6m0M7EJBpAHKCZdSAE0dDxQQbhlyIIhajzxJlVO
	ExjPDoPUuCW1kWrpC1jhLwK3NCLuJT2aVCUheOHvyqxSsY4iJkSwPP6fu9jpE5ciFSYkZW5c4QI
	mDKTke5/O+WCZgVip8LW7aW8QZfLULKPywrU7u6Ov28Y61MdpFwNVnV2cOGzpgHVcTw==
X-Received: by 2002:ae9:ee02:: with SMTP id i2mr2090090qkg.179.1550825179386;
        Fri, 22 Feb 2019 00:46:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZe3TnzClpds8s+rhSjGLMcx+nJVR2q9sH6hQUT4OexwqB+7zsGiLiz/yUbVBSPoz4MOn6N
X-Received: by 2002:ae9:ee02:: with SMTP id i2mr2090054qkg.179.1550825178338;
        Fri, 22 Feb 2019 00:46:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550825178; cv=none;
        d=google.com; s=arc-20160816;
        b=CVVztk15LC43YsBO635AUsZ4RqNgV8CcNxWNBgcxXh/xRK35SS2f5OXGCsroNfeuFi
         MwiBPjSQdHrnBXA4R7xiuuNxsjHF5HEryyt8tlvjjhzwLVSljQwesdcjfWf3cnCAxMPk
         pqbv3FWH+ytkrIiciyLOxnB84ViCwJcs/xzg3nEuYpzKRX9btLc/f7CdNgwQGh/IuZ40
         aWz5/bcFLcCvI8kH8ab1PK4EiX+BTd4uljpYnRbUK7tTDwW2gpn0UturRWf5AL2sqP2y
         a50uenpS7eS7A3yFV29Udo9KcY58nJmBtzqXM6y1LBSFpOBpf2u5BoZ8YFSYQ8Wa5waW
         42Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4CJtbH2lfYSI9EN2bF3lCD31+oWXq0MHp6JnXjtGT4k=;
        b=FvF06CGGsbNUbDeKz1gAfQvhhV1hZuO68ggrC7lPw2wnMnM1V4ukhR5u3sMJ3m3+Iu
         n7bbgBYiYsMJCEmAnlUfob99tRnuPwXvsAtc5qxzccNgdq86VDmp/NTLXCAM3bvhRLap
         Sl3HMxbDMRYFY6ZFsSi0D2gIOOwAKhhPX+qbJcH/j58fWkJ55LCiQcJXluKDzt9cD9kE
         /ogBMueIBgzHMIWjapNEHSeEuEQwXiEZGVOcKM/wSREG4lyGbRg/TZGA/4LU7dqCMEzN
         h2CI33tzH6wpEg4aJFKLw3LyXmvrQQ+R2AfSEoV5jx1TfblfgPg1JZIh9Jlu4V4qgkfN
         vYIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n5si570889qtl.401.2019.02.22.00.46.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 00:46:18 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F2C433001D3F;
	Fri, 22 Feb 2019 08:46:16 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0618A19C58;
	Fri, 22 Feb 2019 08:46:07 +0000 (UTC)
Date: Fri, 22 Feb 2019 16:46:03 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 14/26] userfaultfd: wp: handle COW properly for uffd-wp
Message-ID: <20190222084603.GK8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-15-peterx@redhat.com>
 <20190221180423.GN2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190221180423.GN2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 22 Feb 2019 08:46:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:04:24PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:20AM +0800, Peter Xu wrote:
> > This allows uffd-wp to support write-protected pages for COW.
> > 
> > For example, the uffd write-protected PTE could also be write-protected
> > by other usages like COW or zero pages.  When that happens, we can't
> > simply set the write bit in the PTE since otherwise it'll change the
> > content of every single reference to the page.  Instead, we should do
> > the COW first if necessary, then handle the uffd-wp fault.
> > 
> > To correctly copy the page, we'll also need to carry over the
> > _PAGE_UFFD_WP bit if it was set in the original PTE.
> > 
> > For huge PMDs, we just simply split the huge PMDs where we want to
> > resolve an uffd-wp page fault always.  That matches what we do with
> > general huge PMD write protections.  In that way, we resolved the huge
> > PMD copy-on-write issue into PTE copy-on-write.
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Few comments see below.
> 
> > ---
> >  mm/memory.c   |  2 ++
> >  mm/mprotect.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++---
> >  2 files changed, 54 insertions(+), 3 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 32d32b6e6339..b5d67bafae35 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2291,6 +2291,8 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
> >  		}
> >  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> >  		entry = mk_pte(new_page, vma->vm_page_prot);
> > +		if (pte_uffd_wp(vmf->orig_pte))
> > +			entry = pte_mkuffd_wp(entry);
> >  		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> 
> This looks wrong to me, isn't the uffd_wp flag clear on writeable pte ?
> If so it would be clearer to have something like:
> 
>  +		if (pte_uffd_wp(vmf->orig_pte))
>  +			entry = pte_mkuffd_wp(entry);
>  +		else
>  + 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>  -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);

Yeah this seems clearer indeed.  The thing is that no matter whether
we set the write bit or not here we'll always set it again later on
simply because COW of uffd-wp pages only happen when resolving the wp
page fault (when we do want to set the write bit in all cases).
Anyway, I do like your suggestion and I'll fix.

> 
> >  		/*
> >  		 * Clear the pte entry and flush it first, before updating the
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 9d4433044c21..ae93721f3795 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >  		if (pte_present(oldpte)) {
> >  			pte_t ptent;
> >  			bool preserve_write = prot_numa && pte_write(oldpte);
> > +			struct page *page;
> >  
> >  			/*
> >  			 * Avoid trapping faults against the zero or KSM
> >  			 * pages. See similar comment in change_huge_pmd.
> >  			 */
> >  			if (prot_numa) {
> > -				struct page *page;
> > -
> >  				page = vm_normal_page(vma, addr, oldpte);
> >  				if (!page || PageKsm(page))
> >  					continue;
> > @@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >  					continue;
> >  			}
> >  
> > +			/*
> > +			 * Detect whether we'll need to COW before
> > +			 * resolving an uffd-wp fault.  Note that this
> > +			 * includes detection of the zero page (where
> > +			 * page==NULL)
> > +			 */
> > +			if (uffd_wp_resolve) {
> > +				/* If the fault is resolved already, skip */
> > +				if (!pte_uffd_wp(*pte))
> > +					continue;
> > +				page = vm_normal_page(vma, addr, oldpte);
> > +				if (!page || page_mapcount(page) > 1) {
> 
> This is wrong, if you allow page to be NULL then you gonna segfault
> in wp_page_copy() down below. Are you sure you want to test for
> special page ? For anonymous memory this should never happens ie
> anon page always are regular page. So if you allow userfaulfd to
> write protect only anonymous vma then there is no point in testing
> here beside maybe a BUG_ON() just in case ...

It's majorly for zero pages where page can be NULL.  Would this be
clearer:

  if (is_zero_pfn(pte_pfn(old_pte)) || (page && page_mapcount(page)))

?

Now we treat zero pages as normal COW pages so we'll do COW here even
for zero pages.  I think maybe we can do special handling on all over
the places for zero pages (e.g., we don't write protect a PTE if we
detected that this is the zero PFN) but I'm uncertain on whether
that's what we want, so I chose to start with current solution at
least to achieve functionality first.

> 
> > +					struct vm_fault vmf = {
> > +						.vma = vma,
> > +						.address = addr & PAGE_MASK,
> > +						.page = page,
> > +						.orig_pte = oldpte,
> > +						.pmd = pmd,
> > +						/* pte and ptl not needed */
> > +					};
> > +					vm_fault_t ret;
> > +
> > +					if (page)
> > +						get_page(page);
> > +					arch_leave_lazy_mmu_mode();
> > +					pte_unmap_unlock(pte, ptl);
> > +					ret = wp_page_copy(&vmf);
> > +					/* PTE is changed, or OOM */
> > +					if (ret == 0)
> > +						/* It's done by others */
> > +						continue;
> > +					else if (WARN_ON(ret != VM_FAULT_WRITE))
> > +						return pages;
> > +					pte = pte_offset_map_lock(vma->vm_mm,
> > +								  pmd, addr,
> > +								  &ptl);
> 
> Here you remap the pte locked but you are not checking if the pte is
> the one you expect ie is it pointing to the copied page and does it
> have expect uffd_wp flag. Another thread might have raced between the
> time you called wp_page_copy() and the time you pte_offset_map_lock()
> I have not check the mmap_sem so maybe you are protected by it as
> mprotect is taking it in write mode IIRC, if so you should add a
> comments at very least so people do not see this as a bug.

Thanks for spotting this.  With nornal uffd-wp page fault handling
path we're only with read lock held (and I would suspect it's racy
even with write lock...).  I agree that there can be a race right
after the COW has done.

Here IMHO we'll be fine as long as it's still a present PTE, in other
words, we should be able to tolerate PTE changes as long as it's still
present otherwise we'll need to retry this single PTE (e.g., the page
can be quickly marked as migrating swap entry, or even the page could
be freed beneath us).  Do you think below change look good to you to
be squashed into this patch?

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 73a65f07fe41..3423f9692838 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -73,6 +73,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                              
        flush_tlb_batched_pending(vma->vm_mm);
        arch_enter_lazy_mmu_mode();
        do {
+retry_pte:
                oldpte = *pte;
                if (pte_present(oldpte)) {
                        pte_t ptent;
@@ -149,6 +150,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                           
                                        pte = pte_offset_map_lock(vma->vm_mm,
                                                                  pmd, addr,
                                                                  &ptl);
+                                       if (!pte_present(*pte))
+                                               /*
+                                                * This PTE could have
+                                                * been modified when COW;
+                                                * retry it
+                                                */
+                                               goto retry_pte;
                                        arch_enter_lazy_mmu_mode();
                                }
                        }

[...]

> > @@ -202,7 +242,16 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
> >  		}
> >  
> >  		if (is_swap_pmd(*pmd) || pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
> > -			if (next - addr != HPAGE_PMD_SIZE) {
> > +			/*
> > +			 * When resolving an userfaultfd write
> > +			 * protection fault, it's not easy to identify
> > +			 * whether a THP is shared with others and
> > +			 * whether we'll need to do copy-on-write, so
> > +			 * just split it always for now to simply the
> > +			 * procedure.  And that's the policy too for
> > +			 * general THP write-protect in af9e4d5f2de2.
> > +			 */
> > +			if (next - addr != HPAGE_PMD_SIZE || uffd_wp_resolve) {
> 
> Using parenthesis maybe ? :)
>             if ((next - addr != HPAGE_PMD_SIZE) || uffd_wp_resolve) {

Sure, will fix it.

Thanks,

-- 
Peter Xu

