Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06080C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B24F020989
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:13:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B24F020989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4430F8E0172; Mon, 25 Feb 2019 02:13:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41AF68E016A; Mon, 25 Feb 2019 02:13:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 311B68E0172; Mon, 25 Feb 2019 02:13:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02D968E016A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 02:13:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id n197so7140825qke.0
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:13:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2eKUgFjK5ZYkOkzX+huuRct/ANafB391TbLnjk9S1jU=;
        b=jjkYn8k5G5HjOI+tYVDoZm7IzRV+PEwkjjUhPDVl+4dEtJR3GnO7XT5tjCQn2tdyme
         tSfpTsEzddcXYivymld+X8dh8N5ogINWSfMdVukVhTJATFL0lrLWEQzPN+NzWhxZNiKF
         8lCYCmbu0yBw+UbZoeNxCdNEL+fuKqUJQxHI7aZRk7gbFfi61vXJJ7Kwy56HyUHFXzlW
         KfYoifpj26cbWayR5zFZrJzjJQvPkr4ShkVptlek6Ewj2T0zR/PqJTtg0Ttf17t4Pogo
         6oWjIlzIuvoReKfXG+Kjq6tFZNfa7gWIR/gJokmQ/t3jZDFJdINvenkYVf26FDQj36Hq
         Nvag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua0iEB4ywarA6M/BB0A3ZQaM8AYBZLrWaHHGSZ99yCqOawnxYDf
	ZAFprSm1faDqw9KV0glJDNHBJLj0sgMmqXpeHskH5X6dhMvYLtzPrO5n87Z3R5zUjIP/B7HXZ1r
	vhiFs1pEW+b5mxSZzRb+j6sY5VxrvP559IKqFeqc1chjktH1Wn5oJO/ptxYigDAKIww==
X-Received: by 2002:aed:3ef6:: with SMTP id o51mr12645262qtf.183.1551078831752;
        Sun, 24 Feb 2019 23:13:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYAjB6nlRIZ6KYTYEYRAtCEFDmvbkqtaPwm+m5XHX/SIV1BNZWn8iz2ex6eLBJF8I3YE2rM
X-Received: by 2002:aed:3ef6:: with SMTP id o51mr12645231qtf.183.1551078830887;
        Sun, 24 Feb 2019 23:13:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551078830; cv=none;
        d=google.com; s=arc-20160816;
        b=c4puQHP/a3NawqXBGVXB2zgQ0GqCXgfZjmQbwylP5DNCDrNB//wzO1eS2qDa3fiZUl
         DZy+198uO7X6oNbMO0AQ+s7buTWK5lSHVm/RAndT5LBFbsC+X0on2kr5N9b31gaU5rNp
         kc8muQ5IneCLw7JByrgwfUq6+OP3axuMKPP8fW1jwk5Xa/AFiM1oStpTufgGXzyeUwew
         sQHrFpJ5L9mhzzJ9AnCKVtBHMJRbK4hlAI6bY6h9NLF7LzAP26/yCt3bgXAlSUqfOjez
         yKzq0BKT3iGM/T6YQJUIIhZhemHh3jB0R9b2wAP+gWbEDkSyYBvZbmxJQzInymJ9r7cH
         q/Zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2eKUgFjK5ZYkOkzX+huuRct/ANafB391TbLnjk9S1jU=;
        b=kdE5Z3QCIVAdLCr3HvplaUewP+KqNwFWZkK0VDfX0RMqXYXnpzVmmJhxJ99UZsqwR9
         cEE71KYftAL7R6xqcDqcRd9WxwP5yXesp0jEf5C+rbAMu2Gj8tY/+jLWwYKjOgd+H2vH
         VX+i2SKcTGhx31AHh1tRQb1fpmzp40eKUhmFWGf8o1ilZfTlZ5dC5M0hrHbAYID51OJE
         7WnLyG+xx/VB6ieTEDtxE/RByP113Tmy3fT3UGQbxQrx734RqSI5FiIgkOhoN9UzV6c/
         TURbakD3PfChvTvgMmmZqlk6LLH75t1yXKH7KP641ULgSMpr1TDu+dTJycHZGyF4LohR
         fR4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q14si4246355qkl.87.2019.02.24.23.13.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 23:13:50 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EA0F73099F9F;
	Mon, 25 Feb 2019 07:13:49 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 73D6410027D9;
	Mon, 25 Feb 2019 07:13:39 +0000 (UTC)
Date: Mon, 25 Feb 2019 15:13:36 +0800
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
Message-ID: <20190225071336.GC28121@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-15-peterx@redhat.com>
 <20190221180423.GN2813@redhat.com>
 <20190222084603.GK8904@xz-x1>
 <20190222153508.GE7783@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190222153508.GE7783@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 25 Feb 2019 07:13:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:35:09AM -0500, Jerome Glisse wrote:
> On Fri, Feb 22, 2019 at 04:46:03PM +0800, Peter Xu wrote:
> > On Thu, Feb 21, 2019 at 01:04:24PM -0500, Jerome Glisse wrote:
> > > On Tue, Feb 12, 2019 at 10:56:20AM +0800, Peter Xu wrote:
> > > > This allows uffd-wp to support write-protected pages for COW.
> 
> [...]
> 
> > > > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > > > index 9d4433044c21..ae93721f3795 100644
> > > > --- a/mm/mprotect.c
> > > > +++ b/mm/mprotect.c
> > > > @@ -77,14 +77,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > > >  		if (pte_present(oldpte)) {
> > > >  			pte_t ptent;
> > > >  			bool preserve_write = prot_numa && pte_write(oldpte);
> > > > +			struct page *page;
> > > >  
> > > >  			/*
> > > >  			 * Avoid trapping faults against the zero or KSM
> > > >  			 * pages. See similar comment in change_huge_pmd.
> > > >  			 */
> > > >  			if (prot_numa) {
> > > > -				struct page *page;
> > > > -
> > > >  				page = vm_normal_page(vma, addr, oldpte);
> > > >  				if (!page || PageKsm(page))
> > > >  					continue;
> > > > @@ -114,6 +113,46 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> > > >  					continue;
> > > >  			}
> > > >  
> > > > +			/*
> > > > +			 * Detect whether we'll need to COW before
> > > > +			 * resolving an uffd-wp fault.  Note that this
> > > > +			 * includes detection of the zero page (where
> > > > +			 * page==NULL)
> > > > +			 */
> > > > +			if (uffd_wp_resolve) {
> > > > +				/* If the fault is resolved already, skip */
> > > > +				if (!pte_uffd_wp(*pte))
> > > > +					continue;
> > > > +				page = vm_normal_page(vma, addr, oldpte);
> > > > +				if (!page || page_mapcount(page) > 1) {
> > > 
> > > This is wrong, if you allow page to be NULL then you gonna segfault
> > > in wp_page_copy() down below. Are you sure you want to test for
> > > special page ? For anonymous memory this should never happens ie
> > > anon page always are regular page. So if you allow userfaulfd to
> > > write protect only anonymous vma then there is no point in testing
> > > here beside maybe a BUG_ON() just in case ...
> > 
> > It's majorly for zero pages where page can be NULL.  Would this be
> > clearer:
> > 
> >   if (is_zero_pfn(pte_pfn(old_pte)) || (page && page_mapcount(page)))
> > 
> > ?
> > 
> > Now we treat zero pages as normal COW pages so we'll do COW here even
> > for zero pages.  I think maybe we can do special handling on all over
> > the places for zero pages (e.g., we don't write protect a PTE if we
> > detected that this is the zero PFN) but I'm uncertain on whether
> > that's what we want, so I chose to start with current solution at
> > least to achieve functionality first.
> 
> You can keep the vm_normal_page() in that case but split the if
> between page == NULL and page != NULL with mapcount > 1. As other-
> wise you will segfault below.

Could I ask what's the segfault you mentioned?  My understanding is
that below code has taken page==NULL into consideration already, e.g.,
we only do get_page() if page!=NULL, and inside wp_page_copy() it has
similar considerations.

> 
> 
> > 
> > > 
> > > > +					struct vm_fault vmf = {
> > > > +						.vma = vma,
> > > > +						.address = addr & PAGE_MASK,
> > > > +						.page = page,
> > > > +						.orig_pte = oldpte,
> > > > +						.pmd = pmd,
> > > > +						/* pte and ptl not needed */
> > > > +					};
> > > > +					vm_fault_t ret;
> > > > +
> > > > +					if (page)
> > > > +						get_page(page);
> > > > +					arch_leave_lazy_mmu_mode();
> > > > +					pte_unmap_unlock(pte, ptl);
> > > > +					ret = wp_page_copy(&vmf);
> > > > +					/* PTE is changed, or OOM */
> > > > +					if (ret == 0)
> > > > +						/* It's done by others */
> > > > +						continue;
> > > > +					else if (WARN_ON(ret != VM_FAULT_WRITE))
> > > > +						return pages;
> > > > +					pte = pte_offset_map_lock(vma->vm_mm,
> > > > +								  pmd, addr,
> > > > +								  &ptl);
> > > 
> > > Here you remap the pte locked but you are not checking if the pte is
> > > the one you expect ie is it pointing to the copied page and does it
> > > have expect uffd_wp flag. Another thread might have raced between the
> > > time you called wp_page_copy() and the time you pte_offset_map_lock()
> > > I have not check the mmap_sem so maybe you are protected by it as
> > > mprotect is taking it in write mode IIRC, if so you should add a
> > > comments at very least so people do not see this as a bug.
> > 
> > Thanks for spotting this.  With nornal uffd-wp page fault handling
> > path we're only with read lock held (and I would suspect it's racy
> > even with write lock...).  I agree that there can be a race right
> > after the COW has done.
> > 
> > Here IMHO we'll be fine as long as it's still a present PTE, in other
> > words, we should be able to tolerate PTE changes as long as it's still
> > present otherwise we'll need to retry this single PTE (e.g., the page
> > can be quickly marked as migrating swap entry, or even the page could
> > be freed beneath us).  Do you think below change look good to you to
> > be squashed into this patch?
> 
> Ok, but below if must be after arch_enter_lazy_mmu_mode(); not before.

Oops... you are right. :)

Thanks,

> 
> > 
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 73a65f07fe41..3423f9692838 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -73,6 +73,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                              
> >         flush_tlb_batched_pending(vma->vm_mm);
> >         arch_enter_lazy_mmu_mode();
> >         do {
> > +retry_pte:
> >                 oldpte = *pte;
> >                 if (pte_present(oldpte)) {
> >                         pte_t ptent;
> > @@ -149,6 +150,13 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                           
> >                                         pte = pte_offset_map_lock(vma->vm_mm,
> >                                                                   pmd, addr,
> >                                                                   &ptl);
> > +                                       if (!pte_present(*pte))
> > +                                               /*
> > +                                                * This PTE could have
> > +                                                * been modified when COW;
> > +                                                * retry it
> > +                                                */
> > +                                               goto retry_pte;
> >                                         arch_enter_lazy_mmu_mode();
> >                                 }
> >                         }

-- 
Peter Xu

