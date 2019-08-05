Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3493C32754
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:23:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6ADB214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 19:23:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="R/AKCL41"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6ADB214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 282556B0005; Mon,  5 Aug 2019 15:23:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 232EC6B0006; Mon,  5 Aug 2019 15:23:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121606B0007; Mon,  5 Aug 2019 15:23:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE0B76B0005
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 15:23:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w5so53322690pgs.5
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:23:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OYv7G/n6BmXChQklNIbOOx9hrwihc7gguVZ2UT+xD58=;
        b=a180qFWEtF+W2jwnzNPYD1u8hAO4KpH0IO38bVyjSJNK6zcRqFcIy/CCtMEWqLfKcM
         MJZyTXSg7HaV03Fe4p71gluDhI59tT4pHa0/EOW361qrUvW57J73kFEl7uZJpE/uxbb4
         Do3E4oYBnnYSe5VQNE06aLV5ix9pxbYI5llvtMTL7oeb6Antr6V65c7v7RHKTu260rg1
         LReTpcBIrPJFax1roM/rLWI9LEEWWdUXYR2WAkEKKf0e2cQIMGzSvafxJQE58xzANlpU
         8azZCkEkpZbzVsKPuJ7KkbhicaV0ErC03iV3LJG6YeMHlP+rUDP2oUla4n0k17hdVSeH
         eJdA==
X-Gm-Message-State: APjAAAWTtKYGzc4MbrNbkcba9q/4RPYLJRu/5tkl+9jb40q4M8injpnb
	XMCtjgcuTmZu4aaiCznnTS58DHeIKEhb9KZ9fI2NoOowuFxMlhi8vSebar3Dli7wy1ekO2gDEGA
	t1bcEhq8FC4COQMKdf+/oiLq9+Jfw5ql0f05btxC5UAb2gmMVVL48PwZt4gP1CgizBA==
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr145335557pla.308.1565032999420;
        Mon, 05 Aug 2019 12:23:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzhMPX3EP7JIXKE5Kqkll4ho6TxSzBl/58oJYJdXlks9q7hxCOUPJwnEriL3iw96vyjLwzt
X-Received: by 2002:a17:902:4c:: with SMTP id 70mr145335514pla.308.1565032998626;
        Mon, 05 Aug 2019 12:23:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565032998; cv=none;
        d=google.com; s=arc-20160816;
        b=ifGZAslT366JWmmeWB4PBw2nnNJ0oi0M1it6+p3b83pNqN+sQN2ff/5GF19DJlkb6l
         gQy9BPRsJVjt7By54J6VrVEyUCaYttEJE/eQDyIJ1VfbtjuTm19k2oBX4giLhSJfu9g/
         moWen1Bq7vqxc5N0Xsovass1N4Op+drSpLsfQoK2pWPy06ZLWoQ05/xc3uwEnq+n7xn+
         6OUSrHfqM75vvTSaOynwA1xUIF/32FP4vzRpySugCzX8tSCBZTYxmklRJssSg+GEFT9V
         /Gf2wAGuqTGiHovSOvsRmruxuDJxik+Z2v2VJTZs21JfhTDl0/1Cpd+ER9Redh3ln9Ih
         /h0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OYv7G/n6BmXChQklNIbOOx9hrwihc7gguVZ2UT+xD58=;
        b=ZxiBYypQ1eiiZHzkzy6xqApO0EmkXJODGqqSZBU+K8dJdaEvfMvIU0uOFOc9IV/6dG
         WgZHPrb1AuEE2uLh+PdrqM9h9UZuQszvLKSpKKBeKHfkosnyfJFP0lOLMj40AsPhWgj0
         FJrjwZDxonzGAsfMRvJvrK+XghWSmppCxELw7EtPezZOmGHu1oa3PRG6GWr53IWUsh3K
         k/yUL6Yd4FqS2R7RS8xbRAuU2FayK/CdbwYhdDhRusX9QmHVgRNJJJhn/kLJB00cLqkQ
         xyNuCQjQwPmWURWLkkvIsNnjVm6h/CLE70Vz5rPrq2XQP3vZ3HkaU9H3tbrWmZS3WWnG
         s8Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="R/AKCL41";
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v1si44866048plp.264.2019.08.05.12.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 12:23:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="R/AKCL41";
       spf=pass (google.com: domain of robh+dt@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=robh+dt@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-qk1-f174.google.com (mail-qk1-f174.google.com [209.85.222.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id F245621738
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 19:23:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565032998;
	bh=d6p6NWXIzAr/w+L57W8Oyrx5VdZnumUCXtu9FxtaNsc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=R/AKCL41e439d3YyW9Frd8+LqZmY/L/BTeDfKJwCw0IYn+fId94XDv2wn7Pml91f9
	 dnKXgXpHTXeFphyc7/df75+ieHN1KnS+kSCTZqgR9c8Gkj9yb5S930ddLj/+yapLMz
	 2x3mqfxdOrcNQAQnSXJqYUrWF68Oxa6/5KI536WM=
Received: by mail-qk1-f174.google.com with SMTP id d15so60977376qkl.4
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 12:23:17 -0700 (PDT)
X-Received: by 2002:a37:6944:: with SMTP id e65mr95063738qkc.119.1565032997083;
 Mon, 05 Aug 2019 12:23:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
 <20190731154752.16557-4-nsaenzjulienne@suse.de> <CAL_JsqKF5nh3hcdLTG5+6RU3_TnFrNX08vD6qZ8wawoA3WSRpA@mail.gmail.com>
 <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de>
In-Reply-To: <2050374ac07e0330e505c4a1637256428adb10c4.camel@suse.de>
From: Rob Herring <robh+dt@kernel.org>
Date: Mon, 5 Aug 2019 13:23:05 -0600
X-Gmail-Original-Message-ID: <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
Message-ID: <CAL_Jsq+LjsRmFg-xaLgpVx3miXN3hid3aD+mgTW__j0SbEFYjQ@mail.gmail.com>
Subject: Re: [PATCH 3/8] of/fdt: add function to get the SoC wide DMA
 addressable memory size
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, 
	Christoph Hellwig <hch@lst.de>, wahrenst@gmx.net, Marc Zyngier <marc.zyngier@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, 
	"moderated list:ARM/FREESCALE IMX / MXC ARM ARCHITECTURE" <linux-arm-kernel@lists.infradead.org>, devicetree@vger.kernel.org, 
	Linux IOMMU <iommu@lists.linux-foundation.org>, linux-mm@kvack.org, 
	Frank Rowand <frowand.list@gmail.com>, phill@raspberryi.org, 
	Florian Fainelli <f.fainelli@gmail.com>, 
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

On Mon, Aug 5, 2019 at 10:03 AM Nicolas Saenz Julienne
<nsaenzjulienne@suse.de> wrote:
>
> Hi Rob,
> Thanks for the review!
>
> On Fri, 2019-08-02 at 11:17 -0600, Rob Herring wrote:
> > On Wed, Jul 31, 2019 at 9:48 AM Nicolas Saenz Julienne
> > <nsaenzjulienne@suse.de> wrote:
> > > Some SoCs might have multiple interconnects each with their own DMA
> > > addressing limitations. This function parses the 'dma-ranges' on each of
> > > them and tries to guess the maximum SoC wide DMA addressable memory
> > > size.
> > >
> > > This is specially useful for arch code in order to properly setup CMA
> > > and memory zones.
> >
> > We already have a way to setup CMA in reserved-memory, so why is this
> > needed for that?
>
> Correct me if I'm wrong but I got the feeling you got the point of the patch
> later on.

No, for CMA I don't. Can't we already pass a size and location for CMA
region under /reserved-memory. The only advantage here is perhaps the
CMA range could be anywhere in the DMA zone vs. a fixed location.

> > > Signed-off-by: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
> > > ---
> > >
> > >  drivers/of/fdt.c       | 72 ++++++++++++++++++++++++++++++++++++++++++
> > >  include/linux/of_fdt.h |  2 ++
> > >  2 files changed, 74 insertions(+)
> > >
> > > diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
> > > index 9cdf14b9aaab..f2444c61a136 100644
> > > --- a/drivers/of/fdt.c
> > > +++ b/drivers/of/fdt.c
> > > @@ -953,6 +953,78 @@ int __init early_init_dt_scan_chosen_stdout(void)
> > >  }
> > >  #endif
> > >
> > > +/**
> > > + * early_init_dt_dma_zone_size - Look at all 'dma-ranges' and provide the
> > > + * maximum common dmable memory size.
> > > + *
> > > + * Some devices might have multiple interconnects each with their own DMA
> > > + * addressing limitations. For example the Raspberry Pi 4 has the
> > > following:
> > > + *
> > > + * soc {
> > > + *     dma-ranges = <0xc0000000  0x0 0x00000000  0x3c000000>;
> > > + *     [...]
> > > + * }
> > > + *
> > > + * v3dbus {
> > > + *     dma-ranges = <0x00000000  0x0 0x00000000  0x3c000000>;
> > > + *     [...]
> > > + * }
> > > + *
> > > + * scb {
> > > + *     dma-ranges = <0x0 0x00000000  0x0 0x00000000  0xfc000000>;
> > > + *     [...]
> > > + * }
> > > + *
> > > + * Here the area addressable by all devices is [0x00000000-0x3bffffff].
> > > Hence
> > > + * the function will write in 'data' a size of 0x3c000000.
> > > + *
> > > + * Note that the implementation assumes all interconnects have the same
> > > physical
> > > + * memory view and that the mapping always start at the beginning of RAM.
> >
> > Not really a valid assumption for general code.
>
> Fair enough. On my defence I settled on that assumption after grepping all dts
> and being unable to find a board that behaved otherwise.
>
> [...]
>
> > It's possible to have multiple levels of nodes and dma-ranges. You need to
> > handle that case too. Doing that and handling differing address translations
> > will be complicated.
>
> Understood.
>
> > IMO, I'd just do:
> >
> > if (of_fdt_machine_is_compatible(blob, "brcm,bcm2711"))
> >     dma_zone_size = XX;
> >
> > 2 lines of code is much easier to maintain than 10s of incomplete code
> > and is clearer who needs this. Maybe if we have dozens of SoCs with
> > this problem we should start parsing dma-ranges.
>
> FYI that's what arm32 is doing at the moment and was my first instinct. But it
> seems that arm64 has been able to survive so far without any machine specific
> code and I have the feeling Catalin and Will will not be happy about this
> solution. Am I wrong?

No doubt. I'm fine if the 2 lines live in drivers/of/.

Note that I'm trying to reduce the number of early_init_dt_scan_*
calls from arch code into the DT code so there's more commonality
across architectures in the early DT scans. So ideally, this can all
be handled under early_init_dt_scan() call.

Rob

