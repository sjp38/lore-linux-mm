Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19DBCC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:46:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD2982073F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:46:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD2982073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E678E0005; Mon, 29 Jul 2019 19:46:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74D928E0002; Mon, 29 Jul 2019 19:46:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 63BBC8E0005; Mon, 29 Jul 2019 19:46:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 433BA8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:46:20 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so56754267qtb.5
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:46:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1y6+cxe1+RNrodMF9jUOrX2MHzxh6cBBd/7O9uEVj0Y=;
        b=QswqTfiNHs9Q3w8gkD0oOUSq76Pin649Uc+WNKZNw0qpZni3mj+J6Gz58YZdykUpFm
         NDdILfDeaz79wzTJMPznAMbdakt2+EE5mTWy/VCbj32Vh2rcDZlV3fEp/0PUgmJEpYsp
         y0j9k0MXU+pvjde4F2M27L42zv/zGiLYmJwxEncf/NxpJYt/u/6uZiOU+Sh2aGVBv1i9
         RdIdK9vkeB120I5fXDFAwQ6IRaB+aucyhg/Mb42lWgoa+Yby4V4If/Dn6wZ5MDaHdWRW
         XQD2kVvaeiIzZ/2gYBg5Ew/K6YdpgAq6MmqkDHoMvLQsHVY6Aphg4gttwiLDoaF9O/Gl
         +2oA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIyDRcRTmaWT1HDyeZECjilPvt1hrpQsRwmiAxD29q7umAl97j
	I3szFf4mxPFaMpKR0NM+wMX56uKnMijlHcXT4DKdBkAtKC98+t73VFbNFGGKrbixTO1gUhq4lMC
	M7NLT+KlkrEl970Q6Wvkzi4taslnBHXw19HXxaofb09aCzV2n17XANqOsMncz25enwQ==
X-Received: by 2002:ac8:7402:: with SMTP id p2mr77326086qtq.250.1564443980026;
        Mon, 29 Jul 2019 16:46:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMXx1w+loNjHusO3WA2G1WN0AmysbjYppeebS7CEtFW+3qUFs7QROhw8xzjaXKePRdz1/2
X-Received: by 2002:ac8:7402:: with SMTP id p2mr77326051qtq.250.1564443979509;
        Mon, 29 Jul 2019 16:46:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564443979; cv=none;
        d=google.com; s=arc-20160816;
        b=wwEnx5lGQ293RHQ1HV5Qkg1o5S2l7vG+3WP+q+9A8I+DG3pNuresNF3+ik7SUCwtLw
         wXYBkx604AHnTWaebDavyFruqQGUgBwy682nSp8wQHmDi7sNXFQQDxLqEbHoA+HO66Gb
         vx/id2lSHqipRhxE+jcJiTzI835AzoGH94aml8h4MxKkJu/OSg8+V8M7sagLwJYnX7UN
         bSA/YCeGmYyVhYS+QmEDQ8HVm5mjUncTntRkcj+ZB0KiFw8ATmmM2XASeqhbx6NAvit2
         oj7EcGfpoAmC9JMziyrSAlbdBiI8UgoDdCStbu4KrNuWSaQmaZsUqhwTKLELgfeE8eZk
         vxzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1y6+cxe1+RNrodMF9jUOrX2MHzxh6cBBd/7O9uEVj0Y=;
        b=W0GTUb0Q4G4/jjrNeTT5O1NaSKYHDNqXa9j5vdDsz/hCZuBzxEvILWBkaHiU3pOnMs
         B2za7Y1HW5XcajEAFGZGOJqfs/h/PYjufJFcox7qnfRxdjD50PJcGhVNYDOFeDdrnrt8
         aZBRYNlU1mCXCsmOT+3dfQYE0WJt08YZNHKrCye+RMfC2HICFTn0zbMZRQdZVXegcZk9
         UKamIL7VXfiSpkT5r1N4GCmq+QRqnYM/vOwUslOWDEyRqTbYNPYuWXg7bHwRg6U9aFX3
         g8OKOacgblWE1p8zZT1MLKdiRoa/Mt+KbkEU+dhi+6x8r8cc7+yf1xifffcxGJnvZvZC
         DyBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f12si41221498qvf.37.2019.07.29.16.46.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:46:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 91FA74627A;
	Mon, 29 Jul 2019 23:46:18 +0000 (UTC)
Received: from redhat.com (ovpn-112-31.rdu2.redhat.com [10.10.112.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4798C19C58;
	Mon, 29 Jul 2019 23:46:14 +0000 (UTC)
Date: Mon, 29 Jul 2019 19:46:11 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
Message-ID: <20190729234611.GC7171@redhat.com>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-10-hch@lst.de>
 <1f0ef337-6ca5-54fa-e627-41a46be73f2b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1f0ef337-6ca5-54fa-e627-41a46be73f2b@nvidia.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 29 Jul 2019 23:46:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 04:42:01PM -0700, Ralph Campbell wrote:
> 
> On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> > The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
> > where it can be replaced with a simple boolean local variable.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> 
> > ---
> >   include/linux/migrate.h | 1 -
> >   mm/migrate.c            | 9 +++++----
> >   2 files changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 8b46cfdb1a0e..ba74ef5a7702 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -165,7 +165,6 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
> >   #define MIGRATE_PFN_VALID	(1UL << 0)
> >   #define MIGRATE_PFN_MIGRATE	(1UL << 1)
> >   #define MIGRATE_PFN_LOCKED	(1UL << 2)
> > -#define MIGRATE_PFN_WRITE	(1UL << 3)
> >   #define MIGRATE_PFN_SHIFT	6
> >   static inline struct page *migrate_pfn_to_page(unsigned long mpfn)
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 74735256e260..724f92dcc31b 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -2212,6 +2212,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> >   		unsigned long mpfn, pfn;
> >   		struct page *page;
> >   		swp_entry_t entry;
> > +		bool writable = false;
> >   		pte_t pte;
> >   		pte = *ptep;
> > @@ -2240,7 +2241,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> >   			mpfn = migrate_pfn(page_to_pfn(page)) |
> >   					MIGRATE_PFN_MIGRATE;
> >   			if (is_write_device_private_entry(entry))
> > -				mpfn |= MIGRATE_PFN_WRITE;
> > +				writable = true;
> >   		} else {
> >   			if (is_zero_pfn(pfn)) {
> >   				mpfn = MIGRATE_PFN_MIGRATE;
> > @@ -2250,7 +2251,8 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> >   			}
> >   			page = vm_normal_page(migrate->vma, addr, pte);
> >   			mpfn = migrate_pfn(pfn) | MIGRATE_PFN_MIGRATE;
> > -			mpfn |= pte_write(pte) ? MIGRATE_PFN_WRITE : 0;
> > +			if (pte_write(pte))
> > +				writable = true;
> >   		}
> >   		/* FIXME support THP */
> > @@ -2284,8 +2286,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> >   			ptep_get_and_clear(mm, addr, ptep);
> >   			/* Setup special migration page table entry */
> > -			entry = make_migration_entry(page, mpfn &
> > -						     MIGRATE_PFN_WRITE);
> > +			entry = make_migration_entry(page, writable);
> >   			swp_pte = swp_entry_to_pte(entry);
> >   			if (pte_soft_dirty(pte))
> >   				swp_pte = pte_swp_mksoft_dirty(swp_pte);
> > 
> 
> MIGRATE_PFN_WRITE may mot being used but that seems like a bug to me.
> If a page is migrated to device memory, it could be mapped at the same
> time to avoid a device page fault but it would need the flag to know
> whether to map it RW or RO. But I suppose that could be inferred from
> the vma->vm_flags.

It is a bug that it is not being use right now. I will have to dig my
git repo to see when that got kill. Will look into it once i get back.

The vma->vm_flags is of no use here. A page can be write protected
inside a writable vma for various reasons.

Cheers,
Jérôme

