Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44FD7C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:41:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E53C12085A
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:41:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E53C12085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 861386B0005; Mon, 18 Mar 2019 16:41:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 810E86B0006; Mon, 18 Mar 2019 16:41:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D8466B0007; Mon, 18 Mar 2019 16:41:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4948D6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 16:41:39 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id e25so15665258qkj.12
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:41:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GssqQx+IG8v2oesnaHARoaetdXB2y3Sp81WKKHkp2hg=;
        b=hyQnZNz7mWHftIqaXojiHZXTQeLtXhOJoD5gHx+I52CaEWoCbZs3UUzExL9xUEYpHO
         ObzO9lkxYXbjcS9FpDCHywcT1vwDbc+/NSHg86gKKUB+rIW7NrpFd4pjGOCAQ0D4kRdd
         yqHUpxUj7Z+ALRxGrexea3wQydVstPRVmqySU0kHZ4ff6pmWW8aUG9y7bdn2F3zGG8DI
         0iPTWSU48tSS1Lu2O6pszOa/EErb15dQqIuMPcTP1CPe2SoAaWZedkVA/5ZdHsavSzii
         XLMfhg1YLuQ2d/phy0OXFga5GL2myLs7j5PfXJpu2UnUyM1rw+UaTtsEYsNUntnCVPJp
         0x2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXGaYLHQnGvrKsoxxIP9dvKvkYRKq8rJRyw6ptegNyI9IQUSMKO
	1jtsgTVv38dRxsj+JFGrXNGwYq0bUmdxwTJbOmJjGihvDMaZOD5XcEbo0k53YWNdWjRyAr3pJey
	yKwMpxT1hPGpgq0bvkm0KkBnA6sYaGPyplNCCLS/wg22kplaw/wccalA+Ym+8HH8N6g==
X-Received: by 2002:a05:620a:1533:: with SMTP id n19mr14256447qkk.241.1552941699018;
        Mon, 18 Mar 2019 13:41:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEYtZzGJsLKzt6Hu88FGU9sfZ233EEdJxUyW+bVZ9HnC4sdaRiAQ76IWbuvHoU5FDyKG8O
X-Received: by 2002:a05:620a:1533:: with SMTP id n19mr14256408qkk.241.1552941697946;
        Mon, 18 Mar 2019 13:41:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552941697; cv=none;
        d=google.com; s=arc-20160816;
        b=BOtjb2ktITC3WZlcW01Mm9EGHUhuTHT908KP/FiuHHXNE02PuJN981+Ce+b+Mr0Dg3
         NRZPcseZhqsohU1/8BDdFZdZtGZhHCZmk7AUwySElRcY+jMP6ZhIXAezj9Z9bjDc130m
         MdJTKuKpXxkJdozvGGFl7LG8DUdmrJF1Z9a6nHoFQTCQ0EIcaRGWuPn77jYu7guPdFLj
         n50Cgn2I762mfL8oV20nJdVJS/XVPvVu0Hdzsyrr8AzERGdn6WvkU28AWp+7JlNZ3o6k
         S9fbVeHZpZx56uRCRvytK92Xf0WCRLlPLNvKt9qvm2dNrxpToUMhHj8HHuboulPyC/D6
         D1AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=GssqQx+IG8v2oesnaHARoaetdXB2y3Sp81WKKHkp2hg=;
        b=exwVA1xeVXtBDh0yIbUxcB2xUtvxZNIiNYnUK+p92N5Rxu0Nuf1BzQtfvY0hfNUiWf
         bPvQS4YQpEkVfdkZbWks3wMxUNeEgeZhQB5bUT7BOgoNmp5f/vMYVQkH0U0/jpUHlJik
         qDZKbDVC4Iz3R6RhL7bj2NYG2HuuNnUM1jYJlImCSspIOz1oqsUe6IHw1adOq9cCRRya
         z0TVasFGDl43ReZ6JlJhK3L6gpy3Eq84bsnBg0AtlntgrzVICgfXCfaKgNxHqIjOzmTd
         QrvnjZhPsoNGf1Z+CC6OfiALUypOOGMUZP2xCuRj1Mx5v0nC/LAf5o230gUBMyHzE9ec
         zHjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q6si6380664qvf.130.2019.03.18.13.41.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 13:41:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05F33308FBA9;
	Mon, 18 Mar 2019 20:41:37 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 41D8F5D705;
	Mon, 18 Mar 2019 20:41:36 +0000 (UTC)
Date: Mon, 18 Mar 2019 16:41:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages
 and map them to a device
Message-ID: <20190318204134.GD6786@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-8-jglisse@redhat.com>
 <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 18 Mar 2019 20:41:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 01:21:00PM -0700, Dan Williams wrote:
> On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
> >
> > From: Jérôme Glisse <jglisse@redhat.com>
> >
> > This is a all in one helper that fault pages in a range and map them to
> > a device so that every single device driver do not have to re-implement
> > this common pattern.
> 
> Ok, correct me if I am wrong but these seem effectively be the typical
> "get_user_pages() + dma_map_page()" pattern that non-HMM drivers would
> follow. Could we just teach get_user_pages() to take an HMM shortcut
> based on the range?
> 
> I'm interested in being able to share code across drivers and not have
> to worry about the HMM special case at the api level.
> 
> And to be clear this isn't an anti-HMM critique this is a "yes, let's
> do this, but how about a more fundamental change".

It is a yes and no, HMM have the synchronization with mmu notifier
which is not common to all device driver ie you have device driver
that do not synchronize with mmu notifier and use GUP. For instance
see the range->valid test in below code this is HMM specific and it
would not apply to GUP user.

Nonetheless i want to remove more HMM code and grow GUP to do some
of this too so that HMM and non HMM driver can share the common part
(under GUP). But right now updating GUP is a too big endeavor. I need
to make progress on more driver with HMM before thinking of messing
with GUP code. Making that code HMM only for now will make the GUP
factorization easier and smaller down the road (should only need to
update HMM helper and not each individual driver which use HMM).

FYI here is my todo list:
    - this patchset
    - HMM ODP
    - mmu notifier changes for optimization and device range binding
    - device range binding (amdgpu/nouveau/...)
    - factor out some nouveau deep inner-layer code to outer-layer for
      more code sharing
    - page->mapping endeavor for generic page protection for instance
      KSM with file back page
    - grow GUP to remove HMM code and consolidate with GUP code
    ...

Cheers,
Jérôme

> 
> >
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >  include/linux/hmm.h |   9 +++
> >  mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 161 insertions(+)
> >
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index 4263f8fb32e5..fc3630d0bbfd 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -502,6 +502,15 @@ int hmm_range_register(struct hmm_range *range,
> >  void hmm_range_unregister(struct hmm_range *range);
> >  long hmm_range_snapshot(struct hmm_range *range);
> >  long hmm_range_fault(struct hmm_range *range, bool block);
> > +long hmm_range_dma_map(struct hmm_range *range,
> > +                      struct device *device,
> > +                      dma_addr_t *daddrs,
> > +                      bool block);
> > +long hmm_range_dma_unmap(struct hmm_range *range,
> > +                        struct vm_area_struct *vma,
> > +                        struct device *device,
> > +                        dma_addr_t *daddrs,
> > +                        bool dirty);
> >
> >  /*
> >   * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a range
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 0a4ff31e9d7a..9cd68334a759 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -30,6 +30,7 @@
> >  #include <linux/hugetlb.h>
> >  #include <linux/memremap.h>
> >  #include <linux/jump_label.h>
> > +#include <linux/dma-mapping.h>
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/memory_hotplug.h>
> >
> > @@ -985,6 +986,157 @@ long hmm_range_fault(struct hmm_range *range, bool block)
> >         return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
> >  }
> >  EXPORT_SYMBOL(hmm_range_fault);
> > +
> > +/*
> > + * hmm_range_dma_map() - hmm_range_fault() and dma map page all in one.
> > + * @range: range being faulted
> > + * @device: device against to dma map page to
> > + * @daddrs: dma address of mapped pages
> > + * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
> > + * Returns: number of pages mapped on success, -EAGAIN if mmap_sem have been
> > + *          drop and you need to try again, some other error value otherwise
> > + *
> > + * Note same usage pattern as hmm_range_fault().
> > + */
> > +long hmm_range_dma_map(struct hmm_range *range,
> > +                      struct device *device,
> > +                      dma_addr_t *daddrs,
> > +                      bool block)
> > +{
> > +       unsigned long i, npages, mapped;
> > +       long ret;
> > +
> > +       ret = hmm_range_fault(range, block);
> > +       if (ret <= 0)
> > +               return ret ? ret : -EBUSY;
> > +
> > +       npages = (range->end - range->start) >> PAGE_SHIFT;
> > +       for (i = 0, mapped = 0; i < npages; ++i) {
> > +               enum dma_data_direction dir = DMA_FROM_DEVICE;
> > +               struct page *page;
> > +
> > +               /*
> > +                * FIXME need to update DMA API to provide invalid DMA address
> > +                * value instead of a function to test dma address value. This
> > +                * would remove lot of dumb code duplicated accross many arch.
> > +                *
> > +                * For now setting it to 0 here is good enough as the pfns[]
> > +                * value is what is use to check what is valid and what isn't.
> > +                */
> > +               daddrs[i] = 0;
> > +
> > +               page = hmm_pfn_to_page(range, range->pfns[i]);
> > +               if (page == NULL)
> > +                       continue;
> > +
> > +               /* Check if range is being invalidated */
> > +               if (!range->valid) {
> > +                       ret = -EBUSY;
> > +                       goto unmap;
> > +               }
> > +
> > +               /* If it is read and write than map bi-directional. */
> > +               if (range->pfns[i] & range->values[HMM_PFN_WRITE])
> > +                       dir = DMA_BIDIRECTIONAL;
> > +
> > +               daddrs[i] = dma_map_page(device, page, 0, PAGE_SIZE, dir);
> > +               if (dma_mapping_error(device, daddrs[i])) {
> > +                       ret = -EFAULT;
> > +                       goto unmap;
> > +               }
> > +
> > +               mapped++;
> > +       }
> > +
> > +       return mapped;
> > +
> > +unmap:
> > +       for (npages = i, i = 0; (i < npages) && mapped; ++i) {
> > +               enum dma_data_direction dir = DMA_FROM_DEVICE;
> > +               struct page *page;
> > +
> > +               page = hmm_pfn_to_page(range, range->pfns[i]);
> > +               if (page == NULL)
> > +                       continue;
> > +
> > +               if (dma_mapping_error(device, daddrs[i]))
> > +                       continue;
> > +
> > +               /* If it is read and write than map bi-directional. */
> > +               if (range->pfns[i] & range->values[HMM_PFN_WRITE])
> > +                       dir = DMA_BIDIRECTIONAL;
> > +
> > +               dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
> > +               mapped--;
> > +       }
> > +
> > +       return ret;
> > +}
> > +EXPORT_SYMBOL(hmm_range_dma_map);
> > +
> > +/*
> > + * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dma_map()
> > + * @range: range being unmapped
> > + * @vma: the vma against which the range (optional)
> > + * @device: device against which dma map was done
> > + * @daddrs: dma address of mapped pages
> > + * @dirty: dirty page if it had the write flag set
> > + * Returns: number of page unmapped on success, -EINVAL otherwise
> > + *
> > + * Note that caller MUST abide by mmu notifier or use HMM mirror and abide
> > + * to the sync_cpu_device_pagetables() callback so that it is safe here to
> > + * call set_page_dirty(). Caller must also take appropriate locks to avoid
> > + * concurrent mmu notifier or sync_cpu_device_pagetables() to make progress.
> > + */
> > +long hmm_range_dma_unmap(struct hmm_range *range,
> > +                        struct vm_area_struct *vma,
> > +                        struct device *device,
> > +                        dma_addr_t *daddrs,
> > +                        bool dirty)
> > +{
> > +       unsigned long i, npages;
> > +       long cpages = 0;
> > +
> > +       /* Sanity check. */
> > +       if (range->end <= range->start)
> > +               return -EINVAL;
> > +       if (!daddrs)
> > +               return -EINVAL;
> > +       if (!range->pfns)
> > +               return -EINVAL;
> > +
> > +       npages = (range->end - range->start) >> PAGE_SHIFT;
> > +       for (i = 0; i < npages; ++i) {
> > +               enum dma_data_direction dir = DMA_FROM_DEVICE;
> > +               struct page *page;
> > +
> > +               page = hmm_pfn_to_page(range, range->pfns[i]);
> > +               if (page == NULL)
> > +                       continue;
> > +
> > +               /* If it is read and write than map bi-directional. */
> > +               if (range->pfns[i] & range->values[HMM_PFN_WRITE]) {
> > +                       dir = DMA_BIDIRECTIONAL;
> > +
> > +                       /*
> > +                        * See comments in function description on why it is
> > +                        * safe here to call set_page_dirty()
> > +                        */
> > +                       if (dirty)
> > +                               set_page_dirty(page);
> > +               }
> > +
> > +               /* Unmap and clear pfns/dma address */
> > +               dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
> > +               range->pfns[i] = range->values[HMM_PFN_NONE];
> > +               /* FIXME see comments in hmm_vma_dma_map() */
> > +               daddrs[i] = 0;
> > +               cpages++;
> > +       }
> > +
> > +       return cpages;
> > +}
> > +EXPORT_SYMBOL(hmm_range_dma_unmap);
> >  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> >
> >
> > --
> > 2.17.2
> >

