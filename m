Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4697FC43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 12:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB8832086C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 12:00:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SIlQwFHQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB8832086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC8F6B000D; Mon,  1 Apr 2019 08:00:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 742DA6B000E; Mon,  1 Apr 2019 08:00:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E4D66B0010; Mon,  1 Apr 2019 08:00:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E33226B000D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 08:00:09 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id j8so2351441lja.11
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 05:00:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=lONlQLaEvJFultSO5a8NUBSr+5P5+0uVNlPDaqTG73w=;
        b=edhOdcAlwyQSCgmE9FzNcFaaAR2zTdqu8S1ZcBMlaM706oUkyO/6gO+4bJ6bnoEeJ+
         xJ5KFdgHN1pkpWUM0yNjy/MiwxvEK9NlIbVsURUldC+oPqTywFAORYtTwDqxD8/kpbNY
         DaBWW42tbLnORBNQIfBxeq9v5TAZ4SeVZuI3Ck+wyDJ4YfuYZ/ezz2BNapaQ12rlCRYo
         V4uJw1GB89VjSagrMnvhOBUHhEW2LABDXXAL4DAIafFY3kmlDbKetx1+TYxRtOdNt9Ws
         2NjpzNSXKvyGPOkv02TYGB9F13k8Yge1etYWD7yuN/VnCLRny327IxQA+IPWtzR1Pvl9
         +Thw==
X-Gm-Message-State: APjAAAW7fqFqr5ClHyXKhcxf4Oki/KhIlh89StUQxNFikHuWdObm2t6J
	3JsEgnKtLCA1lhRNyZsMq5etly5R12geexLqyyhrUdUBx6dHVE0DJOPQ9zCCg9fdTB7cqdWn68V
	m/tb9BFG+bN7VfsCmjP0TqakbNKH3WAKLIUAaOMt+2dcsECjOXJ5G0NHXzYtcq4kyyA==
X-Received: by 2002:a19:9e0d:: with SMTP id h13mr31796546lfe.51.1554120009137;
        Mon, 01 Apr 2019 05:00:09 -0700 (PDT)
X-Received: by 2002:a19:9e0d:: with SMTP id h13mr31796488lfe.51.1554120007995;
        Mon, 01 Apr 2019 05:00:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554120007; cv=none;
        d=google.com; s=arc-20160816;
        b=j+jE/XwCryoIGiig6xwoLcbubvDa50vkNrtL4/rJPvBmIBB2oLGzcK1Hc4GwqA5Z9X
         xk5LuU6Hq6RSy9CLboXg3btDtI4Pojwp8gY96HLjBlPnzx0oe2qM6XBV3OO56itWRa8c
         +kw7oEv88t44VTCmORtvaP3QXwmBIisqysc15gep93rslQQRkz/NV/nt4prCgrgp6KxU
         zJTxrLctuYBksUGR4rVEFlp113QLxwl/8cR6e2XIKH2Oo3S6hfe+2jp87zVHbZBHX07e
         aZMOEUooT4UgyN5nGBYdxE3+WDBX+XCCVTnqPHauXL8wWLnvaiS2PyzNOUCHYeCjhMv3
         POFw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=lONlQLaEvJFultSO5a8NUBSr+5P5+0uVNlPDaqTG73w=;
        b=0CcybHvViyraBHpii0rnP+NTutvH8zvbf8r09gu6CHDt9Q0qvbpw8ruAfJa1zPMroe
         +XtsTmKdz1st6nlpooK8TkBRO2P8X62fdTL6DT6sdlwHWROxWosrYWnOgVlGu3wW99q8
         SGRStKIgIDu3xsjhMoCsxEnzkMNeQca1uSS/WDsyYgdlhr8FyWzYJB4aKUsvv7Ad8ioM
         uqsb0lqIRaIUcMF2Ke3ztjWyIJn886f2chmBatG20i+garSK4Aznl8GzfQ0yiM4e8A2P
         L0d9FVmOLe7L8IEIDqpRDj8fQ05uJIkjJEikzXWFLliP2BQPpgeQRXTAPReJPpbHJACV
         uafw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SIlQwFHQ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor5233829ljj.27.2019.04.01.05.00.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 05:00:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SIlQwFHQ;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=lONlQLaEvJFultSO5a8NUBSr+5P5+0uVNlPDaqTG73w=;
        b=SIlQwFHQZvwbKWh1gXNbMAsQCDe1RPYDmv5JQpb1qXgh8tAieDYIZ+KG/wLs9zRAib
         XNvzW8s6DNMBFTOoWj8OqJ6DEU7ITmcMlutzyb6Ry8nMSPKjwzw4MNknUjzccjnHBVmO
         +UTDFo3HyyDKCT9gVwNPw9cUwrRe7qWUIQdpO3OY7FUJevtI4xHv9Q7F3zC7bMzwDBgj
         e66i2SMdqseC83T6UbuvODLerrR2i9/4+uvB5eNtzjtvGn4qr5ftNn52mCB0xCn4MLnU
         u/zIpjh0PzmI1wNgduTyNqLOiAr721XBGSLzFYcZUNZEhM2SUsTENqWNW2etB25/iFoJ
         h4tA==
X-Google-Smtp-Source: APXvYqzy4/fWp4TYhA9MtAZpxY4sRxXpk/Awh75ofm/avT6FmdX9b1svh0Y1z9IMRIWq9nqTz12MOjFYlkpAdsc8BBU=
X-Received: by 2002:a2e:8888:: with SMTP id k8mr15485928lji.43.1554120007575;
 Mon, 01 Apr 2019 05:00:07 -0700 (PDT)
MIME-Version: 1.0
References: <20190325144011.10560-1-jglisse@redhat.com> <20190325144011.10560-12-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-12-jglisse@redhat.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 1 Apr 2019 17:29:54 +0530
Message-ID: <CAFqt6zau2+Z-D1noF4VeWW6Fa3=xZ8WGbaKpkAdPJcB70dGZjQ@mail.gmail.com>
Subject: Re: [PATCH v2 11/11] mm/hmm: add an helper function that fault pages
 and map them to a device v2
To: jglisse@redhat.com
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	Andrew Morton <akpm@linux-foundation.org>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 8:11 PM <jglisse@redhat.com> wrote:
>
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> This is a all in one helper that fault pages in a range and map them to
> a device so that every single device driver do not have to re-implement
> this common pattern.
>
> This is taken from ODP RDMA in preparation of ODP RDMA convertion. It
> will be use by nouveau and other drivers.
>
> Changes since v1:
>     - improved commit message
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/hmm.h |   9 +++
>  mm/hmm.c            | 152 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 161 insertions(+)
>
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 5f9deaeb9d77..7aadf18b29cb 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -568,6 +568,15 @@ int hmm_range_register(struct hmm_range *range,
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
> index ce33151c6832..fd143251b157 100644
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
> @@ -1163,6 +1164,157 @@ long hmm_range_fault(struct hmm_range *range, boo=
l block)
>         return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
>  }
>  EXPORT_SYMBOL(hmm_range_fault);
> +
> +/*

Adding extra * might be helpful here for documentation.

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

Same here.

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

