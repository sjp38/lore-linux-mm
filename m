Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A28A2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:21:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18B6A2064C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 20:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="UEz+1FGf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18B6A2064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E51C6B0005; Mon, 18 Mar 2019 16:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86DCF6B0006; Mon, 18 Mar 2019 16:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70DF06B0007; Mon, 18 Mar 2019 16:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6F86B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 16:21:14 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id c2so14329565ioh.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 13:21:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=JZMNzWrZePXHcuhdEZbp7VrvshpOH0hZtYHcijCFh9g=;
        b=UU/Evjoqg38QHeH4rqHEnjCpwy4qlyw+6uzY56hQWRmydUrCnHi1Ngf8kCf+hUSqos
         mBTeVhgT5RTT+nrE5NrN4ijLshg/c4fY5kUrTeaFfNKaiihtsZIIEjDrYJvIjBzwk/Hy
         /A3d8SzFaDkwKKtUAFU2t32qtGC3LhXbvz/iHqj21jgKrh59wgNhGstSHnq7jD7Zo9AE
         gApsn6yyP/zxV4rWaprgs2/hkM7LcMQpSaLaScfb6lekFfex/CHbyhd8iaApyD1csI5n
         B5HgCIHqL/G9FhqrdGFzlLTLsYYsntNrkKRe+8BKC6W7c7a2qOCRykG77XScOsWP2Axr
         x8FA==
X-Gm-Message-State: APjAAAV+l3bG1fgAOf+UOdPEGSKs7b8F0sDxohCxCOtEqiliUPCTPZfF
	9VrOWdLyE+fSQ0kqL88rtG+7ul9OKMFvEYcnXNlWDvKcxztBU1ioEQ7S67m9tvh7rLdn/x24ZxB
	WdiA9UN9IxH4nvC2N3fNwU24k7hiUgfJrMUZl96PZBH2iAnfvS+5Cg/A50mFx9Vo=
X-Received: by 2002:a6b:e202:: with SMTP id z2mr12722023ioc.6.1552940474028;
        Mon, 18 Mar 2019 13:21:14 -0700 (PDT)
X-Received: by 2002:a6b:e202:: with SMTP id z2mr12721981ioc.6.1552940473132;
        Mon, 18 Mar 2019 13:21:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552940473; cv=none;
        d=google.com; s=arc-20160816;
        b=ph/ZCnDb3tAzZdrpntGKEKhnAoBG/7sWQUhajFhEyo6wPoLBfZdwxUNN4JwKUNDOB0
         /LLDIrVCj0FNMW+Al7h1DbicuQJrffPDEvmGmiCY6otAGw+jYoceKOURqczjwT1QJoqj
         +kFAMtcjQVprSELR8g4bdHgBnzcVFMy+fRvq+kJiCzmZ9vWcPjD4HCFZCjHNTrVXlA+6
         DCgxZgcZiaOZxn0piUiyOEl1FfG0f0rCSoIm1dWBC5KiiTSltUOrRMSjO9GypjTJUOU9
         jRSu6sOH8gDTUwK0KcpJy2dUmLzBsQu53FnuqydKheochiZZxaDS6XpX2QrV8iTMEDn9
         dOtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JZMNzWrZePXHcuhdEZbp7VrvshpOH0hZtYHcijCFh9g=;
        b=RV548sSKt4Oxw71GuMiXf2eEtyXir/Lvpmj8JFztEycwHKXgiRGwvUbizNQQOaTsYL
         TKN7MWrv2+mP21rvLQAMdbXT7O0UsLYUH4AimxPPGggdnzbHZR5rsomm3WEm/cerxF2X
         /TOU4C+pkW6jJ+5J+w6Pd0+SboQkbFdYt5Z/RShP85sVhccUQ5DHEAV5dGa5gxEvHE4I
         GwQN8NNYw9B5uY7WmXwhPO5vmW+uN9dURmczVKuGJWpvMMlc7YuSnZxaQRVt2GRFQXlg
         /G69hWoBaD2N50ul51pVuf+ZsVtjMWjj00skjR8/rOdx7XlmPyY5H2tMFkpZ2CWlEkGO
         9HrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UEz+1FGf;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m39sor711754iti.33.2019.03.18.13.21.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 13:21:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=UEz+1FGf;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=JZMNzWrZePXHcuhdEZbp7VrvshpOH0hZtYHcijCFh9g=;
        b=UEz+1FGffERfZCRWZGenVSAihHBICGIFw3c4KSLYF7YSDwuXL8veDOjxmOSTVnEBzs
         WfVPtp0yDwVmNdu+IfXq62VZdq5PsolnRakEwcHcqcxK99Nw1A2+o9vw9JoNVGd6HykS
         U7qdNRQAtym1QHoovhe5ov53A+uZTrBs3gFUdnPBJJqsWyJGx7CiEFYw9oSRGH+JW5o+
         637sX0AsSORwqf5kpBLeSXkLTQPCEmp1+wj2i03Euz7jHo5MuJBqUawsPmaraZ76KfIW
         UW6cAG8cSk9Km/9TW+rXthTS5dmIkZ1nADG1hvf+Lgxo1nkZwMBpq8W6vCC4hxFlFbUN
         GcyA==
X-Google-Smtp-Source: APXvYqzJuPSks0GAP1oqUsIZfg/wphNwHE+ndlZ4w1hRuPeOs0Y4dUDfZupA1QMq2KGmFGka1++8mRxRVE+oALnzzxY=
X-Received: by 2002:a24:21d5:: with SMTP id e204mr479827ita.56.1552940472503;
 Mon, 18 Mar 2019 13:21:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-8-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-8-jglisse@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 18 Mar 2019 13:21:00 -0700
Message-ID: <CAA9_cmcN+8B_tyrxRy5MMr-AybcaDEEWB4J8dstY6h0cmFxi3g@mail.gmail.com>
Subject: Re: [PATCH 07/10] mm/hmm: add an helper function that fault pages and
 map them to a device
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 8:55 AM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> This is a all in one helper that fault pages in a range and map them to
> a device so that every single device driver do not have to re-implement
> this common pattern.

Ok, correct me if I am wrong but these seem effectively be the typical
"get_user_pages() + dma_map_page()" pattern that non-HMM drivers would
follow. Could we just teach get_user_pages() to take an HMM shortcut
based on the range?

I'm interested in being able to share code across drivers and not have
to worry about the HMM special case at the api level.

And to be clear this isn't an anti-HMM critique this is a "yes, let's
do this, but how about a more fundamental change".

>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h |   9 +++
>  mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 161 insertions(+)
>
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 4263f8fb32e5..fc3630d0bbfd 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -502,6 +502,15 @@ int hmm_range_register(struct hmm_range *range,
>  void hmm_range_unregister(struct hmm_range *range);
>  long hmm_range_snapshot(struct hmm_range *range);
>  long hmm_range_fault(struct hmm_range *range, bool block);
> +long hmm_range_dma_map(struct hmm_range *range,
> +                      struct device *device,
> +                      dma_addr_t *daddrs,
> +                      bool block);
> +long hmm_range_dma_unmap(struct hmm_range *range,
> +                        struct vm_area_struct *vma,
> +                        struct device *device,
> +                        dma_addr_t *daddrs,
> +                        bool dirty);
>
>  /*
>   * HMM_RANGE_DEFAULT_TIMEOUT - default timeout (ms) when waiting for a r=
ange
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 0a4ff31e9d7a..9cd68334a759 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -30,6 +30,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/memremap.h>
>  #include <linux/jump_label.h>
> +#include <linux/dma-mapping.h>
>  #include <linux/mmu_notifier.h>
>  #include <linux/memory_hotplug.h>
>
> @@ -985,6 +986,157 @@ long hmm_range_fault(struct hmm_range *range, bool =
block)
>         return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>  }
>  EXPORT_SYMBOL(hmm_range_fault);
> +
> +/*
> + * hmm_range_dma_map() - hmm_range_fault() and dma map page all in one.
> + * @range: range being faulted
> + * @device: device against to dma map page to
> + * @daddrs: dma address of mapped pages
> + * @block: allow blocking on fault (if true it sleeps and do not drop mm=
ap_sem)
> + * Returns: number of pages mapped on success, -EAGAIN if mmap_sem have =
been
> + *          drop and you need to try again, some other error value other=
wise
> + *
> + * Note same usage pattern as hmm_range_fault().
> + */
> +long hmm_range_dma_map(struct hmm_range *range,
> +                      struct device *device,
> +                      dma_addr_t *daddrs,
> +                      bool block)
> +{
> +       unsigned long i, npages, mapped;
> +       long ret;
> +
> +       ret =3D hmm_range_fault(range, block);
> +       if (ret <=3D 0)
> +               return ret ? ret : -EBUSY;
> +
> +       npages =3D (range->end - range->start) >> PAGE_SHIFT;
> +       for (i =3D 0, mapped =3D 0; i < npages; ++i) {
> +               enum dma_data_direction dir =3D DMA_FROM_DEVICE;
> +               struct page *page;
> +
> +               /*
> +                * FIXME need to update DMA API to provide invalid DMA ad=
dress
> +                * value instead of a function to test dma address value.=
 This
> +                * would remove lot of dumb code duplicated accross many =
arch.
> +                *
> +                * For now setting it to 0 here is good enough as the pfn=
s[]
> +                * value is what is use to check what is valid and what i=
sn't.
> +                */
> +               daddrs[i] =3D 0;
> +
> +               page =3D hmm_pfn_to_page(range, range->pfns[i]);
> +               if (page =3D=3D NULL)
> +                       continue;
> +
> +               /* Check if range is being invalidated */
> +               if (!range->valid) {
> +                       ret =3D -EBUSY;
> +                       goto unmap;
> +               }
> +
> +               /* If it is read and write than map bi-directional. */
> +               if (range->pfns[i] & range->values[HMM_PFN_WRITE])
> +                       dir =3D DMA_BIDIRECTIONAL;
> +
> +               daddrs[i] =3D dma_map_page(device, page, 0, PAGE_SIZE, di=
r);
> +               if (dma_mapping_error(device, daddrs[i])) {
> +                       ret =3D -EFAULT;
> +                       goto unmap;
> +               }
> +
> +               mapped++;
> +       }
> +
> +       return mapped;
> +
> +unmap:
> +       for (npages =3D i, i =3D 0; (i < npages) && mapped; ++i) {
> +               enum dma_data_direction dir =3D DMA_FROM_DEVICE;
> +               struct page *page;
> +
> +               page =3D hmm_pfn_to_page(range, range->pfns[i]);
> +               if (page =3D=3D NULL)
> +                       continue;
> +
> +               if (dma_mapping_error(device, daddrs[i]))
> +                       continue;
> +
> +               /* If it is read and write than map bi-directional. */
> +               if (range->pfns[i] & range->values[HMM_PFN_WRITE])
> +                       dir =3D DMA_BIDIRECTIONAL;
> +
> +               dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
> +               mapped--;
> +       }
> +
> +       return ret;
> +}
> +EXPORT_SYMBOL(hmm_range_dma_map);
> +
> +/*
> + * hmm_range_dma_unmap() - unmap range of that was map with hmm_range_dm=
a_map()
> + * @range: range being unmapped
> + * @vma: the vma against which the range (optional)
> + * @device: device against which dma map was done
> + * @daddrs: dma address of mapped pages
> + * @dirty: dirty page if it had the write flag set
> + * Returns: number of page unmapped on success, -EINVAL otherwise
> + *
> + * Note that caller MUST abide by mmu notifier or use HMM mirror and abi=
de
> + * to the sync_cpu_device_pagetables() callback so that it is safe here =
to
> + * call set_page_dirty(). Caller must also take appropriate locks to avo=
id
> + * concurrent mmu notifier or sync_cpu_device_pagetables() to make progr=
ess.
> + */
> +long hmm_range_dma_unmap(struct hmm_range *range,
> +                        struct vm_area_struct *vma,
> +                        struct device *device,
> +                        dma_addr_t *daddrs,
> +                        bool dirty)
> +{
> +       unsigned long i, npages;
> +       long cpages =3D 0;
> +
> +       /* Sanity check. */
> +       if (range->end <=3D range->start)
> +               return -EINVAL;
> +       if (!daddrs)
> +               return -EINVAL;
> +       if (!range->pfns)
> +               return -EINVAL;
> +
> +       npages =3D (range->end - range->start) >> PAGE_SHIFT;
> +       for (i =3D 0; i < npages; ++i) {
> +               enum dma_data_direction dir =3D DMA_FROM_DEVICE;
> +               struct page *page;
> +
> +               page =3D hmm_pfn_to_page(range, range->pfns[i]);
> +               if (page =3D=3D NULL)
> +                       continue;
> +
> +               /* If it is read and write than map bi-directional. */
> +               if (range->pfns[i] & range->values[HMM_PFN_WRITE]) {
> +                       dir =3D DMA_BIDIRECTIONAL;
> +
> +                       /*
> +                        * See comments in function description on why it=
 is
> +                        * safe here to call set_page_dirty()
> +                        */
> +                       if (dirty)
> +                               set_page_dirty(page);
> +               }
> +
> +               /* Unmap and clear pfns/dma address */
> +               dma_unmap_page(device, daddrs[i], PAGE_SIZE, dir);
> +               range->pfns[i] =3D range->values[HMM_PFN_NONE];
> +               /* FIXME see comments in hmm_vma_dma_map() */
> +               daddrs[i] =3D 0;
> +               cpages++;
> +       }
> +
> +       return cpages;
> +}
> +EXPORT_SYMBOL(hmm_range_dma_unmap);
>  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
>
>
> --
> 2.17.2
>

