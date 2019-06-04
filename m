Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7269C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6383323CBA
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cx9qF2Xo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6383323CBA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F15376B026B; Tue,  4 Jun 2019 12:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC5906B026C; Tue,  4 Jun 2019 12:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDBC86B026E; Tue,  4 Jun 2019 12:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id BB5726B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:33:41 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v187so16833358ioe.9
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NFDCs9ixPwmop20pIDVV+hNZcExzVIIYIAvpTPqNIqM=;
        b=Vo7Bfaft7MeUkY+7DLznrGBaS2gIf5qEl+E6vdKOB5Ehg8U5p98sadNz70LOernc/e
         GKYDFD1NgNVphex/9nL8+PPWSMzsGRkCpHbTI3ki/GGk/alSy7WKKU2hpvXd31FEcYJP
         2coFjeR2U9MKyJX5dRlcHLaauY/ry21giaqmE/EacEnGpnS8myjb87GyX8dxcscBFLp6
         AogH6sOosKuG22Fdlzh/siRN4XVc9U0IZKmicYi5tZE6NiKFXZhVg63CUnWT0tUyiL3Y
         Rlwmp4Xjna4JhUgM/kpDJyqUl+dhoAGUQlZbNLBNPyq+zsy1UwBdWk13TMPqwVV0ykLv
         o/vQ==
X-Gm-Message-State: APjAAAVt3EzNnRdvvn8N1h1fKWFXTu4fQH6OmAe9JGoZHbBOylbfcwsU
	jDNT0dPt98k+1UtO37Edw+bLh1oH0AzyKHDX8W/HLN0coDK10TRVBu4EbHf0rVyYSVUfmF6BIz2
	Mm8G0N1KeXALMJN9N8iGXrWgT7PXySQ5Ifd/5EeTKnO4WWmhE2yJgRrJH4WkIMf4uYA==
X-Received: by 2002:a6b:b256:: with SMTP id b83mr20994239iof.48.1559666021498;
        Tue, 04 Jun 2019 09:33:41 -0700 (PDT)
X-Received: by 2002:a6b:b256:: with SMTP id b83mr20994156iof.48.1559666020169;
        Tue, 04 Jun 2019 09:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559666020; cv=none;
        d=google.com; s=arc-20160816;
        b=Wc3HRRr+XkJL3HoTQAzfwxzgTiKjrwOcSdEXKQy6izhWdvwp/VYBX5wqj6z2cTtIIm
         /dKfQWxAjx3gLAqxBeLuW0gVCfsVD5yIzXYAOWMQWCL5DrN/e+3sFt/EcDEICXpXw0KV
         PC3tIrp/gtjmVbDmA+L1l9Qt4ShqGtOMbZjpDNzm2e3C6afoXoJOiVXwbYMMPfmYqX6D
         hACTckHgkOLJOb1PFeHxXG54B4DHEvKuqlyA4jtTMvOcLW3UvLYRAE6Kem+TWArmG0VQ
         FJVZhvS8kXUj59Jf91DhZuzG1FjW44X20227nFWikFOLds4EU+gEDjQeQj5uQa3G0hCW
         fW/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NFDCs9ixPwmop20pIDVV+hNZcExzVIIYIAvpTPqNIqM=;
        b=dcue8UJm44srSgKV9U8UtuoH8wdBaCUl67FmkiKos6tNAweZd1JsPvlP1kC5guiP1e
         TIvPE3h39rhcTIOa9+1oAvR4DcoUZpblv4d7GMvgVKPycjQfpyjZeqSXS5Aei6wtk9cE
         RJIWjaValOo/CM8NN+uzSgNnpM3PFI+r4WQc5s18rsWCJSkjcNI+pjyw6dgoY2X47vH6
         uV3hrIi04sK63zBTYnX+pRoqxeKcH0WvpKlkiS2+24ueHFFZTVTzBACFzm9MX6zw7boW
         o8PVT1C/zrDT2aqGPsGop2hmQXotMKhuxRWaGyRF3YA64qtME5xsMsMrPR2CHJNiHZQu
         BkHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cx9qF2Xo;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor2974431ion.88.2019.06.04.09.33.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 09:33:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cx9qF2Xo;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NFDCs9ixPwmop20pIDVV+hNZcExzVIIYIAvpTPqNIqM=;
        b=cx9qF2XoM0ItvPLKYrfQK/oiAqbik/wsSMBvAMrHL8fu8Fx/K523FWLP62Taq5dCW+
         GeVE1uM0MXw54dG4FfQpsBSSfIqJt+BeDwEtP+TaTJsYOGWnVZaxK6WHMMZEiIQCr7c1
         29YRdE5YPlokMDEIYL8ZBSnQ9QFPiJckpS2Wm8iIFdCBR0HfTI2T0TOimv6v4CP1imSF
         sOro/P3hwPspStkLZljA33Ma0X+9ae5JeNqKCeX5SHWY6K1oJDWZaC3n5E0+gY6UeDRI
         PFhuNkiD8tQcLaUt1Hocggi8IY4A2cYLgXOSolXgPJu2RHVtQPEIXlj/1p468yO7GvqA
         grtg==
X-Google-Smtp-Source: APXvYqwJ2HUxS4FKK1XU93wJyd+x/7qURmSpYcNyYnkbHrNeudxQf8vE6jo+0sLFKE/Co6I3WhWb6ZA1CNw3cpjacA4=
X-Received: by 2002:a6b:901:: with SMTP id t1mr14703305ioi.42.1559666019686;
 Tue, 04 Jun 2019 09:33:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603170306.49099-3-nitesh@redhat.com>
In-Reply-To: <20190603170306.49099-3-nitesh@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 4 Jun 2019 09:33:28 -0700
Message-ID: <CAKgT0UeRkG0FyESjjQQWeOs3x2O=BUzFYZAdDkjjLyXRiJMnCQ@mail.gmail.com>
Subject: Re: [RFC][Patch v10 2/2] virtio-balloon: page_hinting: reporting to
 the host
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, 
	pagupta@redhat.com, wei.w.wang@intel.com, 
	Yang Zhang <yang.zhang.wz@gmail.com>, Rik van Riel <riel@surriel.com>, 
	David Hildenbrand <david@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 10:04 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> Enables the kernel to negotiate VIRTIO_BALLOON_F_HINTING feature with the
> host. If it is available and page_hinting_flag is set to true, page_hinting
> is enabled and its callbacks are configured along with the max_pages count
> which indicates the maximum number of pages that can be isolated and hinted
> at a time. Currently, only free pages of order >= (MAX_ORDER - 2) are
> reported. To prevent any false OOM max_pages count is set to 16.
>
> By default page_hinting feature is enabled and gets loaded as soon
> as the virtio-balloon driver is loaded. However, it could be disabled
> by writing the page_hinting_flag which is a virtio-balloon parameter.
>
> Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
> ---
>  drivers/virtio/virtio_balloon.c     | 112 +++++++++++++++++++++++++++-
>  include/uapi/linux/virtio_balloon.h |  14 ++++
>  2 files changed, 125 insertions(+), 1 deletion(-)

<snip>

> diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
> index a1966cd7b677..25e4f817c660 100644
> --- a/include/uapi/linux/virtio_balloon.h
> +++ b/include/uapi/linux/virtio_balloon.h
> @@ -29,6 +29,7 @@
>  #include <linux/virtio_types.h>
>  #include <linux/virtio_ids.h>
>  #include <linux/virtio_config.h>
> +#include <linux/page_hinting.h>

So this include breaks the build and from what I can tell it isn't
really needed. I deleted it in order to be able to build without
warnings about the file not being included in UAPI.

>  /* The feature bitmap for virtio balloon */
>  #define VIRTIO_BALLOON_F_MUST_TELL_HOST        0 /* Tell before reclaiming pages */
> @@ -36,6 +37,7 @@
>  #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM        2 /* Deflate balloon on OOM */
>  #define VIRTIO_BALLOON_F_FREE_PAGE_HINT        3 /* VQ to report free pages */
>  #define VIRTIO_BALLOON_F_PAGE_POISON   4 /* Guest is using page poisoning */
> +#define VIRTIO_BALLOON_F_HINTING       5 /* Page hinting virtqueue */
>
>  /* Size of a PFN in the balloon interface. */
>  #define VIRTIO_BALLOON_PFN_SHIFT 12
> @@ -108,4 +110,16 @@ struct virtio_balloon_stat {
>         __virtio64 val;
>  } __attribute__((packed));
>
> +#ifdef CONFIG_PAGE_HINTING
> +/*
> + * struct hinting_data- holds the information associated with hinting.
> + * @phys_add:  physical address associated with a page or the array holding
> + *             the array of isolated pages.
> + * @size:      total size associated with the phys_addr.
> + */
> +struct hinting_data {
> +       __virtio64 phys_addr;
> +       __virtio32 size;
> +};
> +#endif
>  #endif /* _LINUX_VIRTIO_BALLOON_H */
> --
> 2.21.0
>

