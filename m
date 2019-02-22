Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E365C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:35:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 476802075A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 15:35:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 476802075A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4FF18E0113; Fri, 22 Feb 2019 10:35:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CFE408E0109; Fri, 22 Feb 2019 10:35:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEF998E0113; Fri, 22 Feb 2019 10:35:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 96E508E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:35:24 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f24so2399924qte.4
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 07:35:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=z1uaZdzbmCdisUKKTRVrayIJTJbg4U1wgjeyRvedFC0=;
        b=Y5iYN//DCmV0E1IJLSzdB0ZhuMEJS/7H34Fk6Q/ApaaEX35r+enKF3UJuOrI89i4jC
         dSJLd2X6zDvY80TDbOrsNgB7a0R83/fUsCKE2Mo6KlsNvP+xhsYkKlpW4W7At8M5aNGz
         Eeufkm06jVAJ/uGDGNYUPKvpzT5B8PvDISagmHAVfxS7AloKhH9we97oOsaTV3wZmUQO
         e8unYlaB+cSlW+KeblyyWqCXmUmc/qutLDHGVekyCopXufuJuYum3z9W/4cCOk1hZkx8
         WVVzzdz5cCUGVL56SudsAgPQGPg1z3ItVF2HpfPmfj0wj9HckKv0er50X2bCp53G29U8
         cC2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubAkOJXOa/zPTvZzkCOfEsYIlfgF9/wMHpFuNqPPUI2BSlAkwxG
	Ev2ZeunTvTLtWMWhNoIYK0VwqR5yXWKQ+sqNw3VsfJqUR3Ssmn8uwdf8l3pdvuyG4AB6cfWeyS2
	rvRGVlReqnAMLcaLpD6SmdwBTtcP62HWsTWZ8PC+IYbydSMkOK7rKNNdPepV0pHhRug==
X-Received: by 2002:ac8:385a:: with SMTP id r26mr3598334qtb.239.1550849724365;
        Fri, 22 Feb 2019 07:35:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaAT0Z9Z8EAbCQ4oiZ/9fOK2tpVSJrb1WLPytjMiINjuvL/qw9Nm+ve2+35SI0AK6BXydIN
X-Received: by 2002:ac8:385a:: with SMTP id r26mr3598270qtb.239.1550849723305;
        Fri, 22 Feb 2019 07:35:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550849723; cv=none;
        d=google.com; s=arc-20160816;
        b=K+NiG9qoDFZqSxPGa4US+dIpMbFhiPZYXbCTgzQCXYBUXXuyxL4bha8wjZb5pIfGyj
         ETY920Vr3n3YjpnvQr1vMf9gm2i4NJ1dhjboUy2G97hHbBkdn+qGlNflu3F6AcoW7C9B
         ihvW8vnXEBbIB61PTl3L/lxK3b5i42oF9k9Q0uLM9r8OsvTS4lU3UsuUuiOHNWYvIEZ7
         NiR+wtXnwFExfJNpaHjvlCkb4Qxf4EjnOAyPBU1Z9YSNiD3ylNj+o8Hfd+3TsgElmKgg
         18hhUlGZAge03Poq2kygiuvd/88ewfdfcyNQS6Oq6NnstB+Ppm8ADKx9H3OpCn4Cch9P
         NLCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=z1uaZdzbmCdisUKKTRVrayIJTJbg4U1wgjeyRvedFC0=;
        b=A6MA635PVQvo5gw5mICQGowCISQO0GYfVY+d+UeLG49DkUMt8BYHBHFgxqPh6WQ861
         eqaZZAq0rNZWTVUkIPsxZ9/l3pV+ATPubaOspowchGxPo5Ie0sI7OE7GjRU68awtzZyd
         DE2//eI6Tq94w8RNwh6G7nM3xFr9/1jip+0zYF2nVs6Yaf/jnxnLd/PGZPybM2OEteSm
         wXgQjks77iVZGB4r9OQFTbP0DORrA+Ad2epDaW4ApxJ6iJSp6U0kWGHeomU24P7rj3p7
         gwa/3vSCxO0k4dTevhVRrDa+ihrvOyHaHuc1fyCyGAG048Sw4SYjDCsg8Y7O3o6j3ggu
         j9Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x3si1111273qvp.211.2019.02.22.07.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 07:35:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 04F2E7EBAE;
	Fri, 22 Feb 2019 15:35:22 +0000 (UTC)
Received: from redhat.com (ovpn-126-14.rdu2.redhat.com [10.10.126.14])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C9F2F5D704;
	Fri, 22 Feb 2019 15:35:11 +0000 (UTC)
Date: Fri, 22 Feb 2019 10:35:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
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
Message-ID: <20190222153508.GE7783@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-15-peterx@redhat.com>
 <20190221180423.GN2813@redhat.com>
 <20190222084603.GK8904@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222084603.GK8904@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Fri, 22 Feb 2019 15:35:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 04:46:03PM +0800, Peter Xu wrote:
> On Thu, Feb 21, 2019 at 01:04:24PM -0500, Jerome Glisse wrote:
> > On Tue, Feb 12, 2019 at 10:56:20AM +0800, Peter Xu wrote:
> > > This allows uffd-wp to support write-protected pages for COW.

[...]

> > > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > > index 9d4433044c21..ae93721f3795 100644
> > > --- a/mm/mprotect.c
> > > +++ b/mm/mprotect.c
> > > @@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
> > > @@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
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
> > 
> > This is wrong, if you allow page to be NULL then you gonna segfault
> > in wp_page_copy() down below. Are you sure you want to test for
> > special page ? For anonymous memory this should never happens ie
> > anon page always are regular page. So if you allow userfaulfd to
> > write protect only anonymous vma then there is no point in testing
> > here beside maybe a BUG_ON() just in case ...
> 
> It's majorly for zero pages where page can be NULL.  Would this be
> clearer:
> 
>   if (is_zero_pfn(pte_pfn(old_pte)) || (page && page_mapcount(page)))
> 
> ?
> 
> Now we treat zero pages as normal COW pages so we'll do COW here even
> for zero pages.  I think maybe we can do special handling on all over
> the places for zero pages (e.g., we don't write protect a PTE if we
> detected that this is the zero PFN) but I'm uncertain on whether
> that's what we want, so I chose to start with current solution at
> least to achieve functionality first.

You can keep the vm_normal_page() in that case but split the if
between page == NULL and page != NULL with mapcount > 1. As other-
wise you will segfault below.


> 
> > 
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
> > > +					else if (WARN_ON(ret != VM_FAULT_WRITE))
> > > +						return pages;
> > > +					pte = pte_offset_map_lock(vma->vm_mm,
> > > +								  pmd, addr,
> > > +								  &ptl);
> > 
> > Here you remap the pte locked but you are not checking if the pte is
> > the one you expect ie is it pointing to the copied page and does it
> > have expect uffd_wp flag. Another thread might have raced between the
> > time you called wp_page_copy() and the time you pte_offset_map_lock()
> > I have not check the mmap_sem so maybe you are protected by it as
> > mprotect is taking it in write mode IIRC, if so you should add a
> > comments at very least so people do not see this as a bug.
> 
> Thanks for spotting this.  With nornal uffd-wp page fault handling
> path we're only with read lock held (and I would suspect it's racy
> even with write lock...).  I agree that there can be a race right
> after the COW has done.
> 
> Here IMHO we'll be fine as long as it's still a present PTE, in other
> words, we should be able to tolerate PTE changes as long as it's still
> present otherwise we'll need to retry this single PTE (e.g., the page
> can be quickly marked as migrating swap entry, or even the page could
> be freed beneath us).  Do you think below change look good to you to
> be squashed into this patch?

Ok, but below if must be after arch_enter_lazy_mmu_mode(); not before.

> 
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 73a65f07fe41..3423f9692838 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -73,6 +73,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                              
>         flush_tlb_batched_pending(vma->vm_mm);
>         arch_enter_lazy_mmu_mode();
>         do {
> +retry_pte:
>                 oldpte = *pte;
>                 if (pte_present(oldpte)) {
>                         pte_t ptent;
> @@ -149,6 +150,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                           
>                                         pte = pte_offset_map_lock(vma->vm_mm,
>                                                                   pmd, addr,
>                                                                   &ptl);
> +                                       if (!pte_present(*pte))
> +                                               /*
> +                                                * This PTE could have
> +                                                * been modified when COW;
> +                                                * retry it
> +                                                */
> +                                               goto retry_pte;
>                                         arch_enter_lazy_mmu_mode();
>                                 }
>                         }

