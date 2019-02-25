Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 633E4C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:49:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B68920651
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 07:49:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B68920651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53C688E0173; Mon, 25 Feb 2019 02:49:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EC1D8E016A; Mon, 25 Feb 2019 02:49:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B2AD8E0173; Mon, 25 Feb 2019 02:49:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1A18E016A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 02:49:02 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id a11so7106032qkk.10
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:49:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=R2x2xfEraIWZZeTSUbx5Rr3En1L2VQB1t3CCq+pfJWI=;
        b=LH9gFXpDiLj5N1D0+Jp9LQfPgrEr/+Ch0OIqamEmZjq+vxy55Ns68LAx2dFJRMNoGR
         9mIyos13d9fMiUSWqvou6Pvc1+Id283mFycbslCiYHoPdoODdFbskW4H762U2zen2zmL
         UvCFz2lzRccTV26Zsib+xaszYEJR98DZ08JiXe4wCxK9xv7LqMBL5QoWwQJ5w2iQrCfA
         ca0vMJ7SpFDbW1BGHqFq/BHfPD7N4uosdq4JILf2VpY3LJWi6ejGJEFNt3a+NxazZ3er
         PHKAat600y0s/2LS5Z/2/YQFMn+NW4Mt3SV3UMVBw1nXyqzpp+hL/7H7TAIx6YsCfu/U
         YMDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZaMlnu4cUjY7Kw/1hGw4eoEVX1ypUgs2c1fw27Po5fKfpyAEPL
	SNtC1Mz1oAAji8WqJVbPN10rsbYjDScOzAbiEuXqmSrjMkhovR7Yk8TQ62k0ru+5ZoRbGHuOlUt
	+ufsbedzY1blUXfHmLHZQEkyNZsjXpHy+a0e+IRfBctNMk2NhI8ue9UJNA5m7DfBIdA==
X-Received: by 2002:ac8:2b17:: with SMTP id 23mr12320806qtu.157.1551080941806;
        Sun, 24 Feb 2019 23:49:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6UQl5brpyT6Kj+uN7lduCuowZrvGhzbY523bv/bnA9VpksOka2YJBlAQdl5XJqYD12NbF
X-Received: by 2002:ac8:2b17:: with SMTP id 23mr12320777qtu.157.1551080940998;
        Sun, 24 Feb 2019 23:49:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551080940; cv=none;
        d=google.com; s=arc-20160816;
        b=qbO15RyC4r4JqaP6GZecx5/e44aZDST3G2u7DtoDkDAr8BKu8A/s6WtlXLOaUiIsVx
         Xdhu9afI8ywvc66XfSGsc5bdksB9yAdVAeuTImD4AbJ1CXkUGwm4zjJHSX8BKO1zWW7/
         0OQYGpS87PaYIdfNHb7hqMXqwmp9B7UwpRzFooeL4iPlwc1pCxrfAnjiqQ+iElF2XxUV
         E9hvPioz4qq+l1LrlI7ebyO6cCXwjMVL6OV3V5bCzlYxNIK/OKbHWTb6F7EkU/4LDAX5
         bAuQtZ1HFLnEW4KkpB/sXnFxCIS5HlniKhX6V5ZM8NgDdc5Vil+4jIiJUdWRtoFMuVI3
         ipLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=R2x2xfEraIWZZeTSUbx5Rr3En1L2VQB1t3CCq+pfJWI=;
        b=GNZvkvsaOsEgXCwMWpkA3SCpzcx4KMoYBSlpiiMumM8A2DQAP+86eAlIPezEAUvOvP
         3Zv6fy0TkIy8WN4Mw3EeNRYxeM26PFYiyfr4WOZpCOQMxY7XPwA3eYESh9kYH1gxjQCP
         oCsbpngzJSrbehsE7QBd6YBm/2lpah835yiCapgXo9GjvOopSXKBED5etk/fhXgNUk/V
         mheIenedJODIZ07fhCP94wQXxutYAw+2z5pDAvYGjjxMzi/unpcWrAVKkWPRo0rIPgUZ
         5du6WetRwHC52DR9jCGiEpMmRiuEt4MNlEkP+wtKprHgY74M110MUoXil8BUbiwH8FWh
         QxOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w12si1031545qth.106.2019.02.24.23.49.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 23:49:00 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D800230833A1;
	Mon, 25 Feb 2019 07:48:58 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 772325D71A;
	Mon, 25 Feb 2019 07:48:47 +0000 (UTC)
Date: Mon, 25 Feb 2019 15:48:44 +0800
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
Subject: Re: [PATCH v2 17/26] userfaultfd: wp: support swap and page migration
Message-ID: <20190225074844.GD28121@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-18-peterx@redhat.com>
 <20190221181619.GQ2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190221181619.GQ2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Mon, 25 Feb 2019 07:49:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:16:19PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:23AM +0800, Peter Xu wrote:
> > For either swap and page migration, we all use the bit 2 of the entry to
> > identify whether this entry is uffd write-protected.  It plays a similar
> > role as the existing soft dirty bit in swap entries but only for keeping
> > the uffd-wp tracking for a specific PTE/PMD.
> > 
> > Something special here is that when we want to recover the uffd-wp bit
> > from a swap/migration entry to the PTE bit we'll also need to take care
> > of the _PAGE_RW bit and make sure it's cleared, otherwise even with the
> > _PAGE_UFFD_WP bit we can't trap it at all.
> > 
> > Note that this patch removed two lines from "userfaultfd: wp: hook
> > userfault handler to write protection fault" where we try to remove the
> > VM_FAULT_WRITE from vmf->flags when uffd-wp is set for the VMA.  This
> > patch will still keep the write flag there.
> 
> That part is confusing, you probably want to remove that code from
> previous patch or at least address my comment in the previous patch
> review.

(please see below...)

> 
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  include/linux/swapops.h | 2 ++
> >  mm/huge_memory.c        | 3 +++
> >  mm/memory.c             | 8 ++++++--
> >  mm/migrate.c            | 7 +++++++
> >  mm/mprotect.c           | 2 ++
> >  mm/rmap.c               | 6 ++++++
> >  6 files changed, 26 insertions(+), 2 deletions(-)
> > 
> 
> [...]
> 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index c2035539e9fd..7cee990d67cf 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -736,6 +736,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> >  				pte = swp_entry_to_pte(entry);
> >  				if (pte_swp_soft_dirty(*src_pte))
> >  					pte = pte_swp_mksoft_dirty(pte);
> > +				if (pte_swp_uffd_wp(*src_pte))
> > +					pte = pte_swp_mkuffd_wp(pte);
> >  				set_pte_at(src_mm, addr, src_pte, pte);
> >  			}
> >  		} else if (is_device_private_entry(entry)) {
> > @@ -2815,8 +2817,6 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> >  	inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
> >  	dec_mm_counter_fast(vma->vm_mm, MM_SWAPENTS);
> >  	pte = mk_pte(page, vma->vm_page_prot);
> > -	if (userfaultfd_wp(vma))
> > -		vmf->flags &= ~FAULT_FLAG_WRITE;
> 
> So this is the confusing part with the previous patch that introduce
> that code. It feels like you should just remove that code entirely
> in the previous patch.

When I wrote the other part I didn't completely understand those two
lines so I kept them to make sure I won't throw away anthing that can
be actually useful.  If you also agree that we can drop these lines
I'll simply do that in the next version (and I'll drop the comments
too in the commit message).  Andrea, please correct me if I am wrong
on that...

> 
> >  	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
> >  		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> >  		vmf->flags &= ~FAULT_FLAG_WRITE;
> > @@ -2826,6 +2826,10 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
> >  	flush_icache_page(vma, page);
> >  	if (pte_swp_soft_dirty(vmf->orig_pte))
> >  		pte = pte_mksoft_dirty(pte);
> > +	if (pte_swp_uffd_wp(vmf->orig_pte)) {
> > +		pte = pte_mkuffd_wp(pte);
> > +		pte = pte_wrprotect(pte);
> > +	}
> >  	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, pte);
> >  	arch_do_swap_page(vma->vm_mm, vma, vmf->address, pte, vmf->orig_pte);
> >  	vmf->orig_pte = pte;
> 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index d4fd680be3b0..605ccd1f5c64 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -242,6 +242,11 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
> >  		if (is_write_migration_entry(entry))
> >  			pte = maybe_mkwrite(pte, vma);
> >  
> > +		if (pte_swp_uffd_wp(*pvmw.pte)) {
> > +			pte = pte_mkuffd_wp(pte);
> > +			pte = pte_wrprotect(pte);
> > +		}
> 
> If the page was write protected prior to migration then it should never
> end up as a write migration entry and thus the above should be something
> like:
> 		if (is_write_migration_entry(entry)) {
> 			pte = maybe_mkwrite(pte, vma);
> 		} else if (pte_swp_uffd_wp(*pvmw.pte)) {
> 			pte = pte_mkuffd_wp(pte);
> 		}

Yeah I agree I can't think of another case that will violate the rule,
so I'm taking your advise assuming it can be cleaner.

Thanks!

-- 
Peter Xu

