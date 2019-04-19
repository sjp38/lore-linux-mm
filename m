Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE0B8C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 06:27:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 991AA217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 06:27:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 991AA217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B8D36B0007; Fri, 19 Apr 2019 02:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 340206B0008; Fri, 19 Apr 2019 02:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20C1B6B000A; Fri, 19 Apr 2019 02:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEF7C6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 02:27:06 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id y64so3643495qka.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 23:27:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IPgl0e5tWbEvS+NmNDRUwoirXJzzHbRf3hweeZmsD2w=;
        b=EO39Rn89nQQMHNvMCjtNPIvgdNPK6mBzD1nzjy7E9UJNdv8RuLSlhhjkvFwqH0KCU7
         Z5PnSIdG9i/+ZUG1wtIpHs26mSvVXM9JWEZfn+qTZrpMQcRIiJ726A0/6vsIamnieZJl
         LdbcUln4jrIzqilpjdsO3LEw6pYB4mxVGNNCkY8Emmqow8Fw7Aqs54NAm8UJdUGWhon3
         RxWxVmM3ppaOQGO3x0BYsATvdfYXXrPaKa8kLk6thkbqnHOxjXD1O+Wdsv9vwzDYd2xD
         zHP33EpfBySbjUCThV9Lm44GQNBdy3o2irSqk8GXxTiwTsEzMI7wnWME/70L4jdORvjg
         cyDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXZREYQbIKjMmX0KRgGhyw2J8vdiT+TYHYsOyY3hnxZFe1wRS9I
	mMS+wfav5aeMga9C8a0WftHVAotfad55Pg1MQDWzXsbd1kWVOTzFF1iNVNuFP7eWKoR155dffap
	U62L0H2dnvlupavkdb8iwL5TxdwHVrBv6FLBFhFKdObEmEiEF0tYLfLkQZgPeGz750g==
X-Received: by 2002:a05:620a:13a5:: with SMTP id m5mr1902111qki.34.1555655226699;
        Thu, 18 Apr 2019 23:27:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJwscFxfYBOaiPKSbA+ij5iTvtKM64WiJpA/on4/xLaj4JXS7VtrzDAc1NMChdLfreSyDp
X-Received: by 2002:a05:620a:13a5:: with SMTP id m5mr1902061qki.34.1555655225554;
        Thu, 18 Apr 2019 23:27:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555655225; cv=none;
        d=google.com; s=arc-20160816;
        b=BC8Ohom/GJbrE3CbL2b0ok7Xn08Aueq/Wg2ySfWlgXb58kk6eQA2cCguDxBuJtoEMc
         eWRvo+wTlUd/fxNPQZmojkAq/lA9YC38uBTUv9TEQMQm5dX6tFl+gCdbU/3+f8JZAuqa
         sTS8+aIVMEPPxNO+RH9Eu0MmdujFt4w4xSVFvbALENnp7I4QKrdPSmvlB35znqQqPlMf
         V4uRzl11n4JfXuoaJC/oh4zF1J3Od/iW5QH+7iWqSxjKhFKFt7wwJw64/sZmKN0lL38q
         NNCrXPLRF+3hNggDhv7H9GXOCKvRJA9EYHsZVxDVNOUuNbnPvfaQFaEwsq2AAyIh8Wj2
         DCLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IPgl0e5tWbEvS+NmNDRUwoirXJzzHbRf3hweeZmsD2w=;
        b=AWLSWp28dcv5UDUR90SU9jM6L36TBHPe+gAjPDAnIJZJGgW6KfHY+oBW32kqZ3oQv+
         Z8VGsCfeyNchcOv19NlIeWWsj+pVBPpPXF+8XVEtgK7E8FSdUyzPo52PBZV0Pe3we7IH
         gbKqE4NUvCclHEIQjwUGssW4/KppE1TnaHrIaw14PylVDt02ZwFgMCZcqRz8f9idvYCp
         x6P5NY+Kfbqf4SqkEk6pkEYfcs6+fWDE6lcs0aIJKCnT/X9vKaGgKMkuEKcdv4N9/Y22
         3zXTLaJuzOL1Jk368fa8RLQTCDB8CCSVeu9EN8uquYhoH8Aiwmtvi/YGnPpqALb3ce1D
         e7Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f42si3006842qta.250.2019.04.18.23.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 23:27:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4C65830BA369;
	Fri, 19 Apr 2019 06:27:04 +0000 (UTC)
Received: from xz-x1 (ovpn-12-224.pek2.redhat.com [10.72.12.224])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 673C41001DCF;
	Fri, 19 Apr 2019 06:26:55 +0000 (UTC)
Date: Fri, 19 Apr 2019 14:26:50 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
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
Message-ID: <20190419062650.GF13323@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190418202558.GK3288@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 19 Apr 2019 06:27:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 04:51:15PM -0400, Jerome Glisse wrote:
> On Wed, Mar 20, 2019 at 10:06:28AM +0800, Peter Xu wrote:
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
> This one has a bug see below.
> 
> 
> > ---
> >  mm/memory.c   |  5 +++-
> >  mm/mprotect.c | 64 ++++++++++++++++++++++++++++++++++++++++++++++++---
> >  2 files changed, 65 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e7a4b9650225..b8a4c0bab461 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2291,7 +2291,10 @@ vm_fault_t wp_page_copy(struct vm_fault *vmf)
> >  		}
> >  		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
> >  		entry = mk_pte(new_page, vma->vm_page_prot);
> > -		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> > +		if (pte_uffd_wp(vmf->orig_pte))
> > +			entry = pte_mkuffd_wp(entry);
> > +		else
> > +			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> >  		/*
> >  		 * Clear the pte entry and flush it first, before updating the
> >  		 * pte with the new entry. This will avoid a race condition
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 9d4433044c21..855dddb07ff2 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -73,18 +73,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >  	flush_tlb_batched_pending(vma->vm_mm);
> >  	arch_enter_lazy_mmu_mode();
> >  	do {
> > +retry_pte:
> >  		oldpte = *pte;
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
> > @@ -114,6 +114,54 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
> 
> This is wrong if ret == 0 you still need to remap the pte before
> continuing as otherwise you will go to next pte without the page
> table lock for the directory. So 0 case must be handled after
> arch_enter_lazy_mmu_mode() below.
> 
> Sorry i should have catch that in previous review.

My fault to not have noticed it since the very beginning... thanks for
spotting that.

I'm squashing below changes into the patch:

diff --git a/mm/mprotect.c b/mm/mprotect.c
index 3cddfd6627b8..13d493b836bb 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -141,22 +141,19 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
                                        arch_leave_lazy_mmu_mode();
                                        pte_unmap_unlock(pte, ptl);
                                        ret = wp_page_copy(&vmf);
-                                       /* PTE is changed, or OOM */
-                                       if (ret == 0)
-                                               /* It's done by others */
-                                               continue;
-                                       else if (WARN_ON(ret != VM_FAULT_WRITE))
+                                       if (ret != VM_FAULT_WRITE && ret != 0)
+                                               /* Probably OOM */
                                                return pages;
                                        pte = pte_offset_map_lock(vma->vm_mm,
                                                                  pmd, addr,
                                                                  &ptl);
                                        arch_enter_lazy_mmu_mode();
-                                       if (!pte_present(*pte))
+                                       if (ret == 0 || !pte_present(*pte))
                                                /*
                                                 * This PTE could have been
-                                                * modified after COW
-                                                * before we have taken the
-                                                * lock; retry this PTE
+                                                * modified during or after
+                                                * COW before take the lock;
+                                                * retry.
                                                 */
                                                goto retry_pte;
                                }

[...]

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
> Just a nit pick can you please add () to next - addr ie:
> if ((next - addr) != HPAGE_PMD_SIZE || uffd_wp_resolve) {
> 
> I know it is not needed but each time i bump into this i
> have to scratch my head for second to remember the operator
> rules :)

Sure, as usual. :) And I tend to agree it's a good habit.  It's just
me that always forgot about it.

Thanks,

-- 
Peter Xu

