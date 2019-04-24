Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7A26C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:39:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76E882148D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:39:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76E882148D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0C256B000A; Wed, 24 Apr 2019 04:39:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBC8E6B000C; Wed, 24 Apr 2019 04:39:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DABB56B000D; Wed, 24 Apr 2019 04:39:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B62066B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:39:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c44so9035476qtb.9
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:39:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RFMQ7I316MLh5LbetACASsy6aRwTr0p1oTHnohY3lSg=;
        b=AWX9smKISlQD+zkDtT8abea3Teq6ARAVDDrHcC4BNVY62OUVDslrQNZUW/T93sCruQ
         fNTQiTAPXbKGy7QcncBrEboGczVP+Br05SPKaGdGiqWDdtU30wyXkbzA8dHNfuwx30YQ
         k6CgkvkdsF84TaQMGGRrC85jkPA14cg/bNQ5YU0YFeKipIoH+0ur/Q1DQ3z/H1YS9FtC
         TDZB6OS516R/e0RODjfl/0822tbiJvEY4N1KaOVcw9MZSEp5+2NZtLpTp20o7DW7dP0q
         1A3h7iFB1ytBoOy4H8GNYvCkil89mJ5fhYw5H66W1i4BOQ4h8OgJ7x2Ugmn2tBfiCPMa
         ifNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXX3zLWAntCu9mjPRpJbzjaHfiiGAZifeNuxEtMgbq4Pht+TVa6
	3VxnvtsrqI5WuffcJxhihqhZpdpPvJyc58Icu86VClVU4nIt11iI5oEmpv/GYQ18BRalBNrJZsB
	HL4jJbJgKzWmGncsaL1sRNmyXHFAGYFJgvEeYZafto4sc0GPoNcSJt99zV9JhPvF5aw==
X-Received: by 2002:a0c:b523:: with SMTP id d35mr24955186qve.104.1556095147480;
        Wed, 24 Apr 2019 01:39:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRdmRmTGApBVoi7O+Fs7515lZcz6Ci4q3NoWF6qfMhTmXUiWElhAf/brWbls+Yc+LgV5Xk
X-Received: by 2002:a0c:b523:: with SMTP id d35mr24955153qve.104.1556095146733;
        Wed, 24 Apr 2019 01:39:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556095146; cv=none;
        d=google.com; s=arc-20160816;
        b=Kc14Bz4FGueko7aPMPTNYjvDViZ12MD857Ch+2a6hoLD40kJVBWsZyB7muiR2LVP5B
         nktmMKkMikV0zdOttbP1wdPeKzZeqTFQ2b+Zv6bCh9P2m11daXO0DJlXexNtmj7Au1tL
         2PY7kFw2wpH00adCZ9QtfiRZxZMRCBYDv/wBmCPkRkFSKYmf4UgOobPXDVwdy6I7uQeL
         yJ8S7yKnFEuSdya2XPbiSZhqC0Sxcx6IN60685R9llQ+k51DA6qQnlxnEuj08OGg5jH8
         KM0r9mpYGmlpWdXy0hut2rqkF+yLa/t6xUTzrNbhAxa6Zg9n3k5JHg1rXmVCFJmCliXm
         cx5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RFMQ7I316MLh5LbetACASsy6aRwTr0p1oTHnohY3lSg=;
        b=RXPPBkV9HselheYqZIDxIifzSGMcO2J0Ut3Tqd5tqCotggizxG9p5dpSoC98reke3L
         2tt/OU5OgH5iYBjgHAwVERmfePaVmR8xa6uyP/xroOY3abiaunthhPG2S2VdlalOLt8O
         o7TA32g3jUwe5NWehCHf2NMrPDry810BYIBy3kjJ+lzNn69eCVXGMeXyCFb8XJVfJsu4
         izfOJPDK/n1yi73zDzRq1IVF8s8BTaOsKWdEW7qCWOVQm1eQCfQI0hhqVo/xsHJFB1m3
         +/jOHsflqB0MveFL6mM21Z7Q27qH74w6//AoDfS6xJ0QgBxGl/L+amsU4j01wdVXm+cp
         WyDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s20si2261401qte.386.2019.04.24.01.39.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 01:39:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E6A203082B02;
	Wed, 24 Apr 2019 08:39:04 +0000 (UTC)
Received: from xz-x1 (ovpn-12-167.pek2.redhat.com [10.72.12.167])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A39FC5C239;
	Wed, 24 Apr 2019 08:38:52 +0000 (UTC)
Date: Wed, 24 Apr 2019 16:38:49 +0800
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
Message-ID: <20190424083849.GE2753@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-15-peterx@redhat.com>
 <20190418202558.GK3288@redhat.com>
 <20190419062650.GF13323@xz-x1>
 <20190419150253.GA3311@redhat.com>
 <20190422122010.GA25896@xz-x1>
 <20190422145402.GB3450@redhat.com>
 <20190423030030.GA21301@xz-x1>
 <20190423153456.GA3288@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190423153456.GA3288@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 24 Apr 2019 08:39:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 11:34:56AM -0400, Jerome Glisse wrote:
> On Tue, Apr 23, 2019 at 11:00:30AM +0800, Peter Xu wrote:
> > On Mon, Apr 22, 2019 at 10:54:02AM -0400, Jerome Glisse wrote:
> > > On Mon, Apr 22, 2019 at 08:20:10PM +0800, Peter Xu wrote:
> > > > On Fri, Apr 19, 2019 at 11:02:53AM -0400, Jerome Glisse wrote:
> > > > 
> > > > [...]
> > > > 
> > > > > > > > +			if (uffd_wp_resolve) {
> > > > > > > > +				/* If the fault is resolved already, skip */
> > > > > > > > +				if (!pte_uffd_wp(*pte))
> > > > > > > > +					continue;
> > > > > > > > +				page = vm_normal_page(vma, addr, oldpte);
> > > > > > > > +				if (!page || page_mapcount(page) > 1) {
> > > > > > > > +					struct vm_fault vmf = {
> > > > > > > > +						.vma = vma,
> > > > > > > > +						.address = addr & PAGE_MASK,
> > > > > > > > +						.page = page,
> > > > > > > > +						.orig_pte = oldpte,
> > > > > > > > +						.pmd = pmd,
> > > > > > > > +						/* pte and ptl not needed */
> > > > > > > > +					};
> > > > > > > > +					vm_fault_t ret;
> > > > > > > > +
> > > > > > > > +					if (page)
> > > > > > > > +						get_page(page);
> > > > > > > > +					arch_leave_lazy_mmu_mode();
> > > > > > > > +					pte_unmap_unlock(pte, ptl);
> > > > > > > > +					ret = wp_page_copy(&vmf);
> > > > > > > > +					/* PTE is changed, or OOM */
> > > > > > > > +					if (ret == 0)
> > > > > > > > +						/* It's done by others */
> > > > > > > > +						continue;
> > > > > > > 
> > > > > > > This is wrong if ret == 0 you still need to remap the pte before
> > > > > > > continuing as otherwise you will go to next pte without the page
> > > > > > > table lock for the directory. So 0 case must be handled after
> > > > > > > arch_enter_lazy_mmu_mode() below.
> > > > > > > 
> > > > > > > Sorry i should have catch that in previous review.
> > > > > > 
> > > > > > My fault to not have noticed it since the very beginning... thanks for
> > > > > > spotting that.
> > > > > > 
> > > > > > I'm squashing below changes into the patch:
> > > > > 
> > > > > 
> > > > > Well thinking of this some more i think you should use do_wp_page() and
> > > > > not wp_page_copy() it would avoid bunch of code above and also you are
> > > > > not properly handling KSM page or page in the swap cache. Instead of
> > > > > duplicating same code that is in do_wp_page() it would be better to call
> > > > > it here.
> > > > 
> > > > Yeah it makes sense to me.  Then here's my plan:
> > > > 
> > > > - I'll need to drop previous patch "export wp_page_copy" since then
> > > >   it'll be not needed
> > > > 
> > > > - I'll introduce another patch to split current do_wp_page() and
> > > >   introduce function "wp_page_copy_cont" (better suggestion on the
> > > >   naming would be welcomed) which contains most of the wp handling
> > > >   that'll be needed for change_pte_range() in this patch and isolate
> > > >   the uffd handling:
> > > > 
> > > > static vm_fault_t do_wp_page(struct vm_fault *vmf)
> > > > 	__releases(vmf->ptl)
> > > > {
> > > > 	struct vm_area_struct *vma = vmf->vma;
> > > > 
> > > > 	if (userfaultfd_pte_wp(vma, *vmf->pte)) {
> > > > 		pte_unmap_unlock(vmf->pte, vmf->ptl);
> > > > 		return handle_userfault(vmf, VM_UFFD_WP);
> > > > 	}
> > > > 
> > > > 	return do_wp_page_cont(vmf);
> > > > }
> > > > 
> > > > Then I can probably use do_wp_page_cont() in this patch.
> > > 
> > > Instead i would keep the do_wp_page name and do:
> > >     static vm_fault_t do_userfaultfd_wp_page(struct vm_fault *vmf) {
> > >         ... // what you have above
> > >         return do_wp_page(vmf);
> > >     }
> > > 
> > > Naming wise i think it would be better to keep do_wp_page() as
> > > is.
> > 
> > In case I misunderstood... what I've proposed will be simply:
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 64bd8075f054..ab98a1eb4702 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2497,6 +2497,14 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
> >                 return handle_userfault(vmf, VM_UFFD_WP);
> >         }
> > 
> > +       return do_wp_page_cont(vmf);
> > +}
> > +
> > +vm_fault_t do_wp_page_cont(struct vm_fault *vmf)
> > +       __releases(vmf->ptl)
> > +{
> > +       struct vm_area_struct *vma = vmf->vma;
> > +
> >         vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
> >         if (!vmf->page) {
> >                 /*
> > 
> > And the other proposal is:
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 64bd8075f054..a73792127553 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2469,6 +2469,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
> >         return VM_FAULT_WRITE;
> >  }
> > 
> > +static vm_fault_t do_wp_page(struct vm_fault *vmf);
> > +
> >  /*
> >   * This routine handles present pages, when users try to write
> >   * to a shared page. It is done by copying the page to a new address
> > @@ -2487,7 +2489,7 @@ static vm_fault_t wp_page_shared(struct vm_fault *vmf)
> >   * but allow concurrent faults), with pte both mapped and locked.
> >   * We return with mmap_sem still held, but pte unmapped and unlocked.
> >   */
> > -static vm_fault_t do_wp_page(struct vm_fault *vmf)
> > +static vm_fault_t do_userfaultfd_wp_page(struct vm_fault *vmf)
> >         __releases(vmf->ptl)
> >  {
> >         struct vm_area_struct *vma = vmf->vma;
> > @@ -2497,6 +2499,14 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
> >                 return handle_userfault(vmf, VM_UFFD_WP);
> >         }
> > 
> > +       return do_wp_page(vmf);
> > +}
> > +
> > +static vm_fault_t do_wp_page(struct vm_fault *vmf)
> > +       __releases(vmf->ptl)
> > +{
> > +       struct vm_area_struct *vma = vmf->vma;
> > +
> >         vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
> >         if (!vmf->page) {
> >                 /*
> > @@ -2869,7 +2879,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> >         }
> > 
> >         if (vmf->flags & FAULT_FLAG_WRITE) {
> > -               ret |= do_wp_page(vmf);
> > +               ret |= do_userfaultfd_wp_page(vmf);
> >                 if (ret & VM_FAULT_ERROR)
> >                         ret &= VM_FAULT_ERROR;
> >                 goto out;
> > @@ -3831,7 +3841,7 @@ static vm_fault_t handle_pte_fault(struct vm_fault *vmf)
> >                 goto unlock;
> >         if (vmf->flags & FAULT_FLAG_WRITE) {
> >                 if (!pte_write(entry))
> > -                       return do_wp_page(vmf);
> > +                       return do_userfaultfd_wp_page(vmf);
> >                 entry = pte_mkdirty(entry);
> >         }
> >         entry = pte_mkyoung(entry);
> > 
> > I would prefer the 1st approach since it not only contains fewer lines
> > of changes because it does not touch callers, and also the naming in
> > the 2nd approach can be a bit confusing (calling
> > do_userfaultfd_wp_page in handle_pte_fault may let people think of an
> > userfault-only path but actually it covers the general path).  But if
> > you really like the 2nd one I can use that too.
> 
> Maybe move the userfaultfd code to a small helper, call it first in
> call site of do_wp_page() and do_wp_page() if it does not fire ie:
> 
> bool do_userfaultfd_wp(struct vm_fault *vmf, int ret)
> {
>     if (handleuserfault) return true;
>     return false;
> }
> 
> then
>      if (vmf->flags & FAULT_FLAG_WRITE) {
>             if (do_userfaultfd_wp(vmf, tmp)) {
>                 ret |= tmp;
>             } else
>                 ret |= do_wp_page(vmf);
>             if (ret & VM_FAULT_ERROR)
>                 ret &= VM_FAULT_ERROR;
>             goto out;
> 
> and:
>     if (vmf->flags & FAULT_FLAG_WRITE) {
>         if (!pte_write(entry)) {
>             if (do_userfaultfd_wp(vmf, ret))
>                 return ret;
>             else
>                 return do_wp_page(vmf);
>         }

But then we will be duplicating the code patterns somehow? :-/

I'll think them over...  Thanks for all these suggestions!

-- 
Peter Xu

