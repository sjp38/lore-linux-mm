Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FCC4C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E988820B7C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 17:17:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="lhaum2PD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E988820B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 834596B000D; Fri,  2 Aug 2019 13:17:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BFB36B000E; Fri,  2 Aug 2019 13:17:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6381D6B0010; Fri,  2 Aug 2019 13:17:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0886B000D
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 13:17:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 8so42504088pgl.3
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:17:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=djjrE6lfphI+2uZtSPLUJz7QIApveAhJ1PmPLeRGB14=;
        b=rQJd9QLNL7UI3FP60ebZZ/z+zo1q1ccJK3ytvKFwYQeNz9fuHQwQJzLAqIg4BhputG
         6CoE/F+MLCep4uEVa9v3wa9gQb1Fb87OzoEuvz6xiWLmkLb0iabO3p+/kZIqi5xKdoxE
         A4VjATKD8ZeC2JUThXtFY2kpHzylsqjOaKB7KQ1lQlvTYlg3kL9wr1I8Vtgpn5kU/K1n
         wKKnTOOacZdAdxhKIhVDCrtXQ1GEJ42realI0Eofy381MYBw8qNDz5z+9FcATvG1Qnaw
         z1UPeNk2iztKF2z1jQD9ValPO3BZxHjmPtBFzZKWO8FQ0GbaaZeqH8iOIf3nngjKOlmm
         TzsA==
X-Gm-Message-State: APjAAAWLc6QlbW3H+d+leA8jHGqbx7cBhZN0034fOO0PZBiSrSfNriF6
	e/DGZ6ByehpcjfD3crfyI08APDcMuZEIr4dAhqgsifWj/0Lq7tYuzjEOgKAjYIOY4wwIhlT/nTk
	H+TNDKM5D71rRl0mQrpjLF2q7WUf6U/5OWckSFPC2C/nv0rcs91GVm6aVhH3esk/xwQ==
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr130182619plb.292.1564766260785;
        Fri, 02 Aug 2019 10:17:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvjHaWtdErdHd5p+2LJGJOKxPuN57naaxVHVF294RMczyI/xYsKAvWOZcs8GNETN+OIi7A
X-Received: by 2002:a17:902:f301:: with SMTP id gb1mr130182541plb.292.1564766259918;
        Fri, 02 Aug 2019 10:17:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564766259; cv=none;
        d=google.com; s=arc-20160816;
        b=iXbEN9p+3BYqoySkfzANIt2IbwJ7lWWTYkfuRVMR9XJq23bcrNhpHhLBI8+GEu1nvV
         7mgWhPrbsm3zqwJeeewkr+kw6ggvBZoAbOisSPIGZzglya6YFys473+UkwvwNroi0I++
         HezdNQvCRiM7rWR8HCkY9duUi0Wbk1/GvKtto+vmPyfFU9RdLn7EAMNjjNtlDZn8TQJK
         9wnAgP2LTCz4/u76GNiMnGf3rYuAQBD/RB3H4Lry2S0tfToYQNIVwXqiZOQFYjd8i+eI
         tY/NX8EJwpxMK7Vg9MuCkZBUJEdr0WGWhQYZCfccaeZOLlZY14mBdUflMwG+EgnpfC2h
         4HQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=djjrE6lfphI+2uZtSPLUJz7QIApveAhJ1PmPLeRGB14=;
        b=yL8DYiMZS4ce4jOk8CPZKxjX8dmsrl7VcZd4RymJOLMWdn7cDwZUEbe4c4ckpPbBT1
         Pd4g4atxbStB6s0cOtR0vXwvj8Wf1fiDCLFObBTyUGlNnnvOOErjGdl5eNJQAh9HkAYC
         VeEx780vQa52cIDLi9XA6I0FDGbL7y8sOJWgcLjAdSSXSU2Z6xXQtSWPMAbSAZLQTEiZ
         6RLYoxTy0SNDPCulnHnfspahiIYcjo7d0NtGOaHNifaR/UCc/IFWZDMoUelDuW9bLX19
         fn+BiptgLUSPQMWIcs+M2RQCKjK6liYEvLNMJz4c6e2kDwqrH4tP73PUJfy7KURzATtz
         d5Tw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lhaum2PD;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d37si34233702pla.288.2019.08.02.10.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 10:17:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=lhaum2PD;
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-qk1-f170.google.com (mail-qk1-f170.google.com [209.85.222.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 64955217F4
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 17:17:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564766259;
	bh=5vmjMpiDWDoHbfIEjw2l5ptTIfiiyZTgBi7QK8QIoHM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=lhaum2PDzZjeWUO+WsAPOwKR/YgoXWAR0RXVBZYh5t5+PfmXONrVeQpGaqPVUFLNV
	 zeDEVI0jHfexKJbsQD+EJtDab3k6iGED56EBhGxGJaIwBy9kSo1dYlZn9j/4qmkL4a
	 R3PlUQKqZUXTeiEG8RYoleZ6v44K+IO5A8+pUoig=
Received: by mail-qk1-f170.google.com with SMTP id m14so29663091qka.10
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 10:17:39 -0700 (PDT)
X-Received: by 2002:a37:a48e:: with SMTP id n136mr93644586qke.223.1564766258476;
 Fri, 02 Aug 2019 10:17:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190731154752.16557-1-nsaenzjulienne@suse.de> <20190731154752.16557-4-nsaenzjulienne@suse.de>
In-Reply-To: <20190731154752.16557-4-nsaenzjulienne@suse.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Fri, 2 Aug 2019 11:17:26 -0600
X-Gmail-Original-Message-ID: <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
Message-ID: <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Christoph Hellwig <hch@lst.de>, wahrenst@gmx.net, 
	Marc Zyngier <marc.zyngier@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, 
	Linux IOMMU <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, 
	Frank Rowand <frowand.list@gmail.com>, phill@raspberryi.org, 
	Florian Fainelli <f.fainelli@gmail.com>, Will Deacon <will@kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric Anholt <eric@anholt.net>, 
	Matthias Brugger <mbrugger@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, 
	"moderated list:BROADCOM BCM2835 ARM ARCHITECTURE" <linux-rpi-kernel@lists.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
<nsaenzjulienne@suse.de> wrote:
>
> Some SoCs might have multiple interconnects each with their own DMA
> addressing limitations. This function parses the 'dma-ranges' on each of
> them and tries to guess the maximum SoC wide DMA addressable memory
> size.
>
> This is specially useful for arch code in order to properly setup CMA
> and memory zones.

We already have a way to setup CMA in reserved-memory, so why is this
needed for that?

I have doubts this can really be generic...

>
> Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> ---
>
>  drivers/of/fdt.c       | 72 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/of_fdt.h |  2 ++
>  2 files changed, 74 insertions(+)
>
> diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> index 9cdf14b9aaab..f2444c61a136 100644
> --- a/drivers/of/fdt.c
> +++ b/drivers/of/fdt.c
> @@ -953,6 +953,78 @@ int __init early_init_dt_scan_chosen_stdout(void)
>  }
>  #endif
>
> +/**
> + * early_init_dt_dma_zone_size - Look at all 'dma-ranges' and provide the
> + * maximum common dmable memory size.
> + *
> + * Some devices might have multiple interconnects each with their own DMA
> + * addressing limitations. For example the Raspberry Pi 4 has the following:
> + *
> + * soc {
> + *     dma-ranges = <0xc0000000  0x0 0x00000000  0x3c000000>;
> + *     [...]
> + * }
> + *
> + * v3dbus {
> + *     dma-ranges = <0x00000000  0x0 0x00000000  0x3c000000>;
> + *     [...]
> + * }
> + *
> + * scb {
> + *     dma-ranges = <0x0 0x00000000  0x0 0x00000000  0xfc000000>;
> + *     [...]
> + * }
> + *
> + * Here the area addressable by all devices is [0x00000000-0x3bffffff]. Hence
> + * the function will write in 'data' a size of 0x3c000000.
> + *
> + * Note that the implementation assumes all interconnects have the same physical
> + * memory view and that the mapping always start at the beginning of RAM.

Not really a valid assumption for general code.

> + */
> +int __init early_init_dt_dma_zone_size(unsigned long node, const char *uname,
> +                                      int depth, void *data)

Don't use the old fdt scanning interface with depth/data. It's not
really needed now because you can just use libfdt calls.

> +{
> +       const char *type = of_get_flat_dt_prop(node, "device_type", NULL);
> +       u64 phys_addr, dma_addr, size;
> +       u64 *dma_zone_size = data;
> +       int dma_addr_cells;
> +       const __be32 *reg;
> +       const void *prop;
> +       int len;
> +
> +       if (depth == 0)
> +               *dma_zone_size = 0;
> +
> +       /*
> +        * We avoid pci host controllers as they have their own way of using
> +        * 'dma-ranges'.
> +        */
> +       if (type && !strcmp(type, "pci"))
> +               return 0;
> +
> +       reg = of_get_flat_dt_prop(node, "dma-ranges", &len);
> +       if (!reg)
> +               return 0;
> +
> +       prop = of_get_flat_dt_prop(node, "#address-cells", NULL);
> +       if (prop)
> +               dma_addr_cells = be32_to_cpup(prop);
> +       else
> +               dma_addr_cells = 1; /* arm64's default addr_cell size */

Relying on the defaults has been a dtc error longer than arm64 has
existed. If they are missing, just bail.

> +
> +       if (len < (dma_addr_cells + dt_root_addr_cells + dt_root_size_cells))
> +               return 0;
> +
> +       dma_addr = dt_mem_next_cell(dma_addr_cells, &reg);
> +       phys_addr = dt_mem_next_cell(dt_root_addr_cells, &reg);
> +       size = dt_mem_next_cell(dt_root_size_cells, &reg);
> +
> +       if (!*dma_zone_size || *dma_zone_size > size)
> +               *dma_zone_size = size;
> +
> +       return 0;
> +}

It's possible to have multiple levels of nodes and dma-ranges. You
need to handle that case too.

Doing that and handling differing address translations will be
complicated. IMO, I'd just do:

if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
    dma_zone_size = XX;

2 lines of code is much easier to maintain than 10s of incomplete code
and is clearer who needs this. Maybe if we have dozens of SoCs with
this problem we should start parsing dma-ranges.

Rob

