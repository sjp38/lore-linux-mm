Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 203F2C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:07:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1AF2216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:07:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1AF2216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 626988E0008; Wed, 31 Jul 2019 13:07:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D4FB8E0001; Wed, 31 Jul 2019 13:07:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 476E78E0008; Wed, 31 Jul 2019 13:07:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F28968E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:07:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so42810964edx.12
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:07:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YJKzXyNmcdeKRoNmNSVLaabrWUVyFB3KnY0m8z+OCUU=;
        b=RAaaCdYpxeyAA6I+8r31jLoohtWXIdJRXuNqtS6mL3iSQFQy9zWTR5p9++1lxGnoKr
         JnOnGkVlovhtTylfiRuAYlnDkp1HadVOmPhrRRyJR4a1a+8xH5mt/LvE2PLWuvf6jG8Z
         kuTX6WSjTd2t9rjLSIff9ODjfduJI1XRZjTrgIwVq84J1muRMyZmtnT7t0UD2gVUcx6z
         LdjbbXgZGjnsTckR3xfJoNTfYVXRdoVD2kPyob2wJ+IXH8SsgDbwzyvFMvOxq8k3JdsJ
         hdEuvozt87iIRL8xhS/7Is4g1TCLOB2ERtxR/x73giEgwdZRXZ1yzJCgIbpKJOdE/9XV
         9nlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAUo2VG47PWhB3QmU64mxQ/iLgHwMoU0tmtr2R8OSZaSueDrN3OD
	nwluHCbGYugWOYMCNSEDgeXlzWVlFoB6UHBdPrMToNf7ZjctrKXN4D6mfXX2yKVGpI3eXkSP2Gh
	/lNvIgNsaCEa9O+jvEsHnpvElYxU1tHUqKRffhX8cFf2VrsgCFNJT6X/Nsh8As+8cQw==
X-Received: by 2002:a17:906:b203:: with SMTP id p3mr94989081ejz.223.1564592868572;
        Wed, 31 Jul 2019 10:07:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiPplz/c01siOXRoTr40FpZufXHTEMw4Ou5QHUYW1Y88QSzmGbRL2K2zl3BLs3evfMgccg
X-Received: by 2002:a17:906:b203:: with SMTP id p3mr94989020ejz.223.1564592867796;
        Wed, 31 Jul 2019 10:07:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564592867; cv=none;
        d=google.com; s=arc-20160816;
        b=voNBgQpfrD6uxnz1rNCReMesNTdhFnrvWZFsh8yFFq7y7vHx5nK1WIHxIY0G/ePeza
         gjdP7Sy3QE+sMG605KBS662ARDZr9rZHKsKyL4oHvDWC0Uz69Ig+SPJXOhiWGl0ZXmMC
         e1VEsZ8HhN2OFPcEvQcI4wBautM7QZrt7CB8dnlooy+tlyoHz2/tLfhar1bvLFwA27Au
         tKPHiLFn3gKP6SX1IieM/in4MioGaUHwi9eMmz8qb5sb5gtSW1BEhqiEVtlJfxz1iB8+
         LDQPvy1HnSyhmL8Zr/hJWncN0YVwXhBotW1Mb1dzcPZHVCuRykn+okyMNSGkOhqkjzNq
         tNfg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YJKzXyNmcdeKRoNmNSVLaabrWUVyFB3KnY0m8z+OCUU=;
        b=QvMlH+N7087WUF/Z1p/1GEiUx5Prnfy8MW1pjA9caPLE99hEUWoFJ6SY9qQEhCBlqq
         kGGYJx49zlSlat5H4/KzfOQuDhL8ilEoyZciCNmtPUAoQAQ6bz2kczRbe8/06DMaF2wg
         BWwcrNvEBpA8g8OK/CNEDD0pBBC8tjT1nYTciSLSTwf2qvLvODr5TZh9iUDUU14hmh82
         JZ/jA0vpFXA46MREUk18BT4oQvJ26/BR54KTkCs3mI65JLhA79rMJBVaVMKcvuc+7WeK
         o6FIJXOYNEFvxM+8AVUn1ELkEThrKe5H08QOvGBxnBGiHPjobDHF9krKUtf8U+7xBjhk
         7mBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id a49si20399263edd.383.2019.07.31.10.07.47
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 10:07:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E2AF6337;
	Wed, 31 Jul 2019 10:07:46 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 72C133F71F;
	Wed, 31 Jul 2019 10:07:44 -0700 (PDT)
Date: Wed, 31 Jul 2019 18:07:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: hch@lst.de, wahrenst@gmx.net, marc.zyngier@arm.com,
	Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-mm@kvack.org,
	Will Deacon <will@kernel.org>, phill@raspberryi.org,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, eric@anholt.net, mbrugger@suse.com,
	akpm@linux-foundation.org, frowand.list@gmail.com,
	m.szyprowski@samsung.com, linux-rpi-kernel@lists.infradead.org
Subject: Re: [PATCH 5/8] arm64: use ZONE_DMA on DMA addressing limited devices
Message-ID: <20190731170742.GC17773@arrakis.emea.arm.com>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
 <20190731154752.16557-6-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731154752.16557-6-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 05:47:48PM +0200, Nicolas Saenz Julienne wrote:
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> index 1c4ffabbe1cb..f5279ef85756 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -50,6 +50,13 @@
>  s64 memstart_addr __ro_after_init = -1;
>  EXPORT_SYMBOL(memstart_addr);
>  
> +/*
> + * We might create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA is needed if there
> + * are periferals unable to address the first naturally aligned 4GB of ram.
> + * ZONE_DMA32 will be expanded to cover the rest of that memory. If such
> + * limitations doesn't exist only ZONE_DMA32 is created.
> + */

Shouldn't we instead only create ZONE_DMA to cover the whole 32-bit
range and leave ZONE_DMA32 empty? Can__GFP_DMA allocations fall back
onto ZONE_DMA32?

-- 
Catalin

