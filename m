Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2439FC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:31:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5C7720989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:31:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5C7720989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 75C7A8E0002; Tue, 29 Jan 2019 14:31:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70C4D8E0001; Tue, 29 Jan 2019 14:31:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D49D8E0002; Tue, 29 Jan 2019 14:31:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3578E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:31:30 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so26039807qtl.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:31:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=hnoE6R27bf7fMhkbv6VIaKpKZF+546bVBXc0TFevWrI=;
        b=T7ORpXQVyfF++nkLWAOMII1LgynX8YUPsI+1F8iEdW6n9Hkhm5pVWGT40BHruuCjkM
         CkLXWQdNdZDj5eOl5IIKgeBOvJYOn8T6ligFKrSlukjcSWCmx7OSKJEkcA4eaP/3fA6C
         lpmGMvdlpLOuFyd/jYukOseOj6gCyf4Oa42/CVR0Fh3+JAQcB2utR9jK46MYOhm1E2u9
         AmL7Y0XBcYCw40CEY084bCoBTnNW6ROV3Vf6EFiF9HbXGPAJe7I4RQ+u69XLCsYM5K6U
         2aASz8Hj7ZhGVXY2hSiF9wDWNw2OhCJxQAcdBJ4HpDs8rTOF3mtt8/2rWuHnsENd6awn
         C/iA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukePlUQxsHGErAc5vAX9o3CXS7RlBPhFHr/9sqsTmx5dF5wzzLUw
	2/rsJKoJ1qPtvJvv4g/lupN5iseK5ZSFSvSd7H7DSSjNRRLnueULLkSDlwTC/0TrWTjxar+9S65
	E1Qr9Oi+Tcry4scuu7e4aL7w8i27HHaxknlQ2AZes3SyBUkMyoM61+SdJOXXpJuTkDQ==
X-Received: by 2002:aed:30c4:: with SMTP id 62mr26092610qtf.290.1548790289908;
        Tue, 29 Jan 2019 11:31:29 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6wukWq1uT9dKWmiEEyb/4DZJrjttndeP5Aiy+FgOASfi++NcnDhRp0IA3EcLmbQsHRGRfx
X-Received: by 2002:aed:30c4:: with SMTP id 62mr26092573qtf.290.1548790289160;
        Tue, 29 Jan 2019 11:31:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548790289; cv=none;
        d=google.com; s=arc-20160816;
        b=jzt9WkK90UwMJ602W8bwXS2/W8+0j1E0ugVxg7W3a+38wMYdydpN8FOHM2Z1U+kMX/
         rCvZlIVwF6kaFHZnGOLDM/TNgq3muQTbQtso0tmwK7dCahgwLg9fG2Bzk362QcXXBccT
         FBWvU5t6y7H9sIXQqquWK0e9XHnOxFJvP8AQBuaNAYba2HinrySOcb6pFgiGjdl/9Itv
         MS2/QS4wbbTBxNtlaJTbw57gP7X7r0rUwHD56pIk9fvw4wlyPS38k/Zn90Ibka44Cvy0
         xwROCVPw4loK1dxgQFYgj+aG6/OFWbENAUK6m7ahogUpIdEzNX+PFPI6yu05KbrTlzCs
         27FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=hnoE6R27bf7fMhkbv6VIaKpKZF+546bVBXc0TFevWrI=;
        b=0c3TIvIhAZ5wQ0D+Io606aZSS8HJA9cSEqyWVKDHJhqAYHgXCQfrXjexIBuQsOvId5
         CidreCYAtlj+nl02XYhCaBGf3bIo8GMcFpEp9IUnmlIrHvZ+F0U5xATJ31e7mUNFwH2R
         tNu42l/m9QzFoiEMSTf4J+RHFUgwmzUcxCqj5xT0bX5EKom8/7ijVjfjWhNzwS2HANIy
         waAPFJv0vQ1CFl1/fNERKw5AK417/fmcK5E/dv0GRe0mB9uVZV4HsqgcuTz/eyzjiCGN
         IhOZaTdqJL4mUuw0S8Qi5w4wVuCp1u5MQ0bUnnuz32c+GxhVARFsPiC9MWQQ7st3Nngm
         f7Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g51si492375qtc.224.2019.01.29.11.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 11:31:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 182872CD7E2;
	Tue, 29 Jan 2019 19:31:28 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A5F40600D7;
	Tue, 29 Jan 2019 19:31:26 +0000 (UTC)
Date: Tue, 29 Jan 2019 14:31:24 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190129193123.GF3176@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 29 Jan 2019 19:31:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:41:23AM -0800, Dan Williams wrote:
> On Tue, Jan 29, 2019 at 8:54 AM <jglisse@redhat.com> wrote:
> >
> > From: Jérôme Glisse <jglisse@redhat.com>
> >
> > This add support to mirror vma which is an mmap of a file which is on
> > a filesystem that using a DAX block device. There is no reason not to
> > support that case.
> >
> 
> The reason not to support it would be if it gets in the way of future
> DAX development. How does this interact with MAP_SYNC? I'm also
> concerned if this complicates DAX reflink support. In general I'd
> rather prioritize fixing the places where DAX is broken today before
> adding more cross-subsystem entanglements. The unit tests for
> filesystems (xfstests) are readily accessible. How would I go about
> regression testing DAX + HMM interactions?

HMM mirror CPU page table so anything you do to CPU page table will
be reflected to all HMM mirror user. So MAP_SYNC has no bearing here
whatsoever as all HMM mirror user must do cache coherent access to
range they mirror so from DAX point of view this is just _exactly_
the same as CPU access.

Note that you can not migrate DAX memory to GPU memory and thus for a
mmap of a file on a filesystem that use a DAX block device then you can
not do migration to device memory. Also at this time migration of file
back page is only supported for cache coherent device memory so for
instance on OpenCAPI platform.

Bottom line is you just have to worry about the CPU page table. What
ever you do there will be reflected properly. It does not add any
burden to people working on DAX. Unless you want to modify CPU page
table without calling mmu notifier but in that case you would not
only break HMM mirror user but other thing like KVM ...


For testing the issue is what do you want to test ? Do you want to test
that a device properly mirror some mmap of a file back by DAX ? ie
device driver which use HMM mirror keep working after changes made to
DAX.

Or do you want to run filesystem test suite using the GPU to access
mmap of the file (read or write) instead of the CPU ? In that case any
such test suite would need to be updated to be able to use something
like OpenCL for. At this time i do not see much need for that but maybe
this is something people would like to see.

Cheers,
Jérôme


> 
> > Note that unlike GUP code we do not take page reference hence when we
> > back-off we have nothing to undo.
> >
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  mm/hmm.c | 133 ++++++++++++++++++++++++++++++++++++++++++++++---------
> >  1 file changed, 112 insertions(+), 21 deletions(-)
> >
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 8b87e1813313..1a444885404e 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -334,6 +334,7 @@ EXPORT_SYMBOL(hmm_mirror_unregister);
> >
> >  struct hmm_vma_walk {
> >         struct hmm_range        *range;
> > +       struct dev_pagemap      *pgmap;
> >         unsigned long           last;
> >         bool                    fault;
> >         bool                    block;
> > @@ -508,6 +509,15 @@ static inline uint64_t pmd_to_hmm_pfn_flags(struct hmm_range *range, pmd_t pmd)
> >                                 range->flags[HMM_PFN_VALID];
> >  }
> >
> > +static inline uint64_t pud_to_hmm_pfn_flags(struct hmm_range *range, pud_t pud)
> > +{
> > +       if (!pud_present(pud))
> > +               return 0;
> > +       return pud_write(pud) ? range->flags[HMM_PFN_VALID] |
> > +                               range->flags[HMM_PFN_WRITE] :
> > +                               range->flags[HMM_PFN_VALID];
> > +}
> > +
> >  static int hmm_vma_handle_pmd(struct mm_walk *walk,
> >                               unsigned long addr,
> >                               unsigned long end,
> > @@ -529,8 +539,19 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
> >                 return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> >
> >         pfn = pmd_pfn(pmd) + pte_index(addr);
> > -       for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++)
> > +       for (i = 0; addr < end; addr += PAGE_SIZE, i++, pfn++) {
> > +               if (pmd_devmap(pmd)) {
> > +                       hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
> > +                                             hmm_vma_walk->pgmap);
> > +                       if (unlikely(!hmm_vma_walk->pgmap))
> > +                               return -EBUSY;
> > +               }
> >                 pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> > +       }
> > +       if (hmm_vma_walk->pgmap) {
> > +               put_dev_pagemap(hmm_vma_walk->pgmap);
> > +               hmm_vma_walk->pgmap = NULL;
> > +       }
> >         hmm_vma_walk->last = end;
> >         return 0;
> >  }
> > @@ -617,10 +638,24 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
> >         if (fault || write_fault)
> >                 goto fault;
> >
> > +       if (pte_devmap(pte)) {
> > +               hmm_vma_walk->pgmap = get_dev_pagemap(pte_pfn(pte),
> > +                                             hmm_vma_walk->pgmap);
> > +               if (unlikely(!hmm_vma_walk->pgmap))
> > +                       return -EBUSY;
> > +       } else if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) && pte_special(pte)) {
> > +               *pfn = range->values[HMM_PFN_SPECIAL];
> > +               return -EFAULT;
> > +       }
> > +
> >         *pfn = hmm_pfn_from_pfn(range, pte_pfn(pte)) | cpu_flags;
> >         return 0;
> >
> >  fault:
> > +       if (hmm_vma_walk->pgmap) {
> > +               put_dev_pagemap(hmm_vma_walk->pgmap);
> > +               hmm_vma_walk->pgmap = NULL;
> > +       }
> >         pte_unmap(ptep);
> >         /* Fault any virtual address we were asked to fault */
> >         return hmm_vma_walk_hole_(addr, end, fault, write_fault, walk);
> > @@ -708,12 +743,84 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
> >                         return r;
> >                 }
> >         }
> > +       if (hmm_vma_walk->pgmap) {
> > +               put_dev_pagemap(hmm_vma_walk->pgmap);
> > +               hmm_vma_walk->pgmap = NULL;
> > +       }
> >         pte_unmap(ptep - 1);
> >
> >         hmm_vma_walk->last = addr;
> >         return 0;
> >  }
> >
> > +static int hmm_vma_walk_pud(pud_t *pudp,
> > +                           unsigned long start,
> > +                           unsigned long end,
> > +                           struct mm_walk *walk)
> > +{
> > +       struct hmm_vma_walk *hmm_vma_walk = walk->private;
> > +       struct hmm_range *range = hmm_vma_walk->range;
> > +       struct vm_area_struct *vma = walk->vma;
> > +       unsigned long addr = start, next;
> > +       pmd_t *pmdp;
> > +       pud_t pud;
> > +       int ret;
> > +
> > +again:
> > +       pud = READ_ONCE(*pudp);
> > +       if (pud_none(pud))
> > +               return hmm_vma_walk_hole(start, end, walk);
> > +
> > +       if (pud_huge(pud) && pud_devmap(pud)) {
> > +               unsigned long i, npages, pfn;
> > +               uint64_t *pfns, cpu_flags;
> > +               bool fault, write_fault;
> > +
> > +               if (!pud_present(pud))
> > +                       return hmm_vma_walk_hole(start, end, walk);
> > +
> > +               i = (addr - range->start) >> PAGE_SHIFT;
> > +               npages = (end - addr) >> PAGE_SHIFT;
> > +               pfns = &range->pfns[i];
> > +
> > +               cpu_flags = pud_to_hmm_pfn_flags(range, pud);
> > +               hmm_range_need_fault(hmm_vma_walk, pfns, npages,
> > +                                    cpu_flags, &fault, &write_fault);
> > +               if (fault || write_fault)
> > +                       return hmm_vma_walk_hole_(addr, end, fault,
> > +                                               write_fault, walk);
> > +
> > +               pfn = pud_pfn(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> > +               for (i = 0; i < npages; ++i, ++pfn) {
> > +                       hmm_vma_walk->pgmap = get_dev_pagemap(pfn,
> > +                                             hmm_vma_walk->pgmap);
> > +                       if (unlikely(!hmm_vma_walk->pgmap))
> > +                               return -EBUSY;
> > +                       pfns[i] = hmm_pfn_from_pfn(range, pfn) | cpu_flags;
> > +               }
> > +               if (hmm_vma_walk->pgmap) {
> > +                       put_dev_pagemap(hmm_vma_walk->pgmap);
> > +                       hmm_vma_walk->pgmap = NULL;
> > +               }
> > +               hmm_vma_walk->last = end;
> > +               return 0;
> > +       }
> > +
> > +       split_huge_pud(vma, pudp, addr);
> > +       if (pud_none(*pudp))
> > +               goto again;
> > +
> > +       pmdp = pmd_offset(pudp, addr);
> > +       do {
> > +               next = pmd_addr_end(addr, end);
> > +               ret = hmm_vma_walk_pmd(pmdp, addr, next, walk);
> > +               if (ret)
> > +                       return ret;
> > +       } while (pmdp++, addr = next, addr != end);
> > +
> > +       return 0;
> > +}
> > +
> >  static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
> >                                       unsigned long start, unsigned long end,
> >                                       struct mm_walk *walk)
> > @@ -786,14 +893,6 @@ static void hmm_pfns_clear(struct hmm_range *range,
> >                 *pfns = range->values[HMM_PFN_NONE];
> >  }
> >
> > -static void hmm_pfns_special(struct hmm_range *range)
> > -{
> > -       unsigned long addr = range->start, i = 0;
> > -
> > -       for (; addr < range->end; addr += PAGE_SIZE, i++)
> > -               range->pfns[i] = range->values[HMM_PFN_SPECIAL];
> > -}
> > -
> >  /*
> >   * hmm_range_register() - start tracking change to CPU page table over a range
> >   * @range: range
> > @@ -911,12 +1010,6 @@ long hmm_range_snapshot(struct hmm_range *range)
> >                 if (vma == NULL || (vma->vm_flags & device_vma))
> >                         return -EFAULT;
> >
> > -               /* FIXME support dax */
> > -               if (vma_is_dax(vma)) {
> > -                       hmm_pfns_special(range);
> > -                       return -EINVAL;
> > -               }
> > -
> >                 if (is_vm_hugetlb_page(vma)) {
> >                         struct hstate *h = hstate_vma(vma);
> >
> > @@ -940,6 +1033,7 @@ long hmm_range_snapshot(struct hmm_range *range)
> >                 }
> >
> >                 range->vma = vma;
> > +               hmm_vma_walk.pgmap = NULL;
> >                 hmm_vma_walk.last = start;
> >                 hmm_vma_walk.fault = false;
> >                 hmm_vma_walk.range = range;
> > @@ -951,6 +1045,7 @@ long hmm_range_snapshot(struct hmm_range *range)
> >                 mm_walk.pte_entry = NULL;
> >                 mm_walk.test_walk = NULL;
> >                 mm_walk.hugetlb_entry = NULL;
> > +               mm_walk.pud_entry = hmm_vma_walk_pud;
> >                 mm_walk.pmd_entry = hmm_vma_walk_pmd;
> >                 mm_walk.pte_hole = hmm_vma_walk_hole;
> >                 mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
> > @@ -1018,12 +1113,6 @@ long hmm_range_fault(struct hmm_range *range, bool block)
> >                 if (vma == NULL || (vma->vm_flags & device_vma))
> >                         return -EFAULT;
> >
> > -               /* FIXME support dax */
> > -               if (vma_is_dax(vma)) {
> > -                       hmm_pfns_special(range);
> > -                       return -EINVAL;
> > -               }
> > -
> >                 if (is_vm_hugetlb_page(vma)) {
> >                         struct hstate *h = hstate_vma(vma);
> >
> > @@ -1047,6 +1136,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
> >                 }
> >
> >                 range->vma = vma;
> > +               hmm_vma_walk.pgmap = NULL;
> >                 hmm_vma_walk.last = start;
> >                 hmm_vma_walk.fault = true;
> >                 hmm_vma_walk.block = block;
> > @@ -1059,6 +1149,7 @@ long hmm_range_fault(struct hmm_range *range, bool block)
> >                 mm_walk.pte_entry = NULL;
> >                 mm_walk.test_walk = NULL;
> >                 mm_walk.hugetlb_entry = NULL;
> > +               mm_walk.pud_entry = hmm_vma_walk_pud;
> >                 mm_walk.pmd_entry = hmm_vma_walk_pmd;
> >                 mm_walk.pte_hole = hmm_vma_walk_hole;
> >                 mm_walk.hugetlb_entry = hmm_vma_walk_hugetlb_entry;
> > --
> > 2.17.2
> >

