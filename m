Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB932C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:04:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74DF3214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 14:04:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74DF3214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C9BA8E0017; Thu,  1 Aug 2019 10:04:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02BDC8E0001; Thu,  1 Aug 2019 10:04:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E36888E0017; Thu,  1 Aug 2019 10:04:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 938978E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 10:04:57 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id i6so35407618wre.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 07:04:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YGCp3WnRy55OAoIwvD1C6aZvr5KPp1dJlrn5QrAMEWg=;
        b=r5OCo+IzoSF4dCXrI10/A0AFB5ZKKtlZAtfQo5hHIh6hucsSUDtelWfu60fRQh8k+R
         c9bPIs//oIE0HIKCaTLyPUUYc7XMgo7H0nv4WRgMYgBgRY8MnNAbNRvX7FPqDghPtOni
         F0hCh03EDBL6uTq35S+pIky0bwPKI228ZxLIyVD4bUVyMeaoleszLm1hid8OGO04/uXW
         E4NS/5+UPuI7vhpm7VdVCDF7B3+m4hBIMZyxbm3wp1BBBvELpVGsnjA3o8CgAOj4hg75
         AhvH2cJs1hIs25gob7HxWpeyZld5uJ7S77g2zyQZKmEpoAUsWYlX9a1jF/+r3R/ZsKQN
         EbeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXJQg82MGuy79+l3Yfmmfnx+uTTDOKHaBfa1uAOKsQEPEMtGSbT
	xtvFazryCGopXnCdd6Ft43BPKX7JXpl1KTHf5Y1aRqvm4LNud59YS6XEXnpK8FUpE+Yy8wIs/QR
	IRvpKg4YzZh+V2bZ2SmkuQFsXRF8dQYRQk78ZXAUPVqTj/+U7WQqcZQUhYWSNmjZY/w==
X-Received: by 2002:a1c:9c8a:: with SMTP id f132mr116864568wme.29.1564668297131;
        Thu, 01 Aug 2019 07:04:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzL5mXwMRU7XknBWvZQfBDFFyku9Yd7aC05S8OvMIRdTlM77oY9SZysnDru1PeTQMdDYneO
X-Received: by 2002:a1c:9c8a:: with SMTP id f132mr116864490wme.29.1564668295968;
        Thu, 01 Aug 2019 07:04:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564668295; cv=none;
        d=google.com; s=arc-20160816;
        b=Ejsk9O/LusL/gG6IfI/jlADPKL36KI41lvxPw+3Hsk7fFhZnkMUt687LP5bb2IAauk
         rPre/iVMZHTc+ueGVBLKWSeGTJFeMqlsuJ1losZtNmrs86ChCxFakJcf25eyEZAdW4Cz
         5vZ9KA1BLC8uRCEShAvDB5Ev4BezwGD0f713QE0RoRIV8SqYQpeU21OreEDfW4japl94
         U70vG3/2kebMRZ1xqj+ys3X+UvJY0fa95fs8q6j2cU4yufja9aHdula62SrXK9VrrMPp
         Q/sYRkK5QNBjlpRrexFzWJiZXvgep+5p233P3LUaf9uU5yRS8kABN5wBqAt2PKKiheTn
         Zh5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YGCp3WnRy55OAoIwvD1C6aZvr5KPp1dJlrn5QrAMEWg=;
        b=LN4EOIXfeU+Ng1kwHsnICkBGwldNQSmdQ/+wad6hot0nKZNP49BhNv0Kn1mVZxKT7p
         dhW2rHOG1IbK6koSy1gD8FXFNJnmxAX+NO+6W45sdJI7djz42R7BmDUkQjC2xKMRruFp
         xpmrSxFOhwX1yy/6GE6gUg6Jf0EMFsnibAWlBIOgpoPTd5vpO/5vmQsXMKQVPtJC69my
         aO+NvBVvwyVEaTSMDF3R2g1kJZmrUEL/TNmjEtfIv30X61566/IBT8SdgRR9tEwWprJh
         QPaf67xbW7KPvTlpUuAhtsnrH0PmYocEj3u9BVD5TDOm3Wi9pDIlU8h7wcN3GFAO0EIC
         DcJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s128si55389577wmf.128.2019.08.01.07.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 07:04:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 5620168AFE; Thu,  1 Aug 2019 16:04:52 +0200 (CEST)
Date: Thu, 1 Aug 2019 16:04:52 +0200
From: Christoph Hellwig <hch@lst.de>
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: catalin.marinas@arm.com, hch@lst.de, wahrenst@gmx.net,
	marc.zyngier@arm.com, Robin Murphy <robin.murphy@arm.com>,
	linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	iommu@lists.linux-foundation.org, linux-mm@kvack.org,
	Marek Szyprowski <m.szyprowski@samsung.com>, phill@raspberryi.org,
	f.fainelli@gmail.com, will@kernel.org, linux-kernel@vger.kernel.org,
	robh+dt@kernel.org, eric@anholt.net, mbrugger@suse.com,
	akpm@linux-foundation.org, frowand.list@gmail.com,
	linux-rpi-kernel@lists.infradead.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org
Subject: Re: [PATCH 6/8] dma-direct: turn ARCH_ZONE_DMA_BITS into a variable
Message-ID: <20190801140452.GB23435@lst.de>
References: <20190731154752.16557-1-nsaenzjulienne@suse.de> <20190731154752.16557-7-nsaenzjulienne@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731154752.16557-7-nsaenzjulienne@suse.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A few nitpicks, otherwise this looks great:

> @@ -201,7 +202,7 @@ static int __init mark_nonram_nosave(void)
>   * everything else. GFP_DMA32 page allocations automatically fall back to
>   * ZONE_DMA.
>   *
> - * By using 31-bit unconditionally, we can exploit ARCH_ZONE_DMA_BITS to
> + * By using 31-bit unconditionally, we can exploit arch_zone_dma_bits to
>   * inform the generic DMA mapping code.  32-bit only devices (if not handled
>   * by an IOMMU anyway) will take a first dip into ZONE_NORMAL and get
>   * otherwise served by ZONE_DMA.
> @@ -237,9 +238,18 @@ void __init paging_init(void)
>  	printk(KERN_DEBUG "Memory hole size: %ldMB\n",
>  	       (long int)((top_of_ram - total_ram) >> 20));
>  
> +	/*
> +	 * Allow 30-bit DMA for very limited Broadcom wifi chips on many
> +	 * powerbooks.
> +	 */
> +	if (IS_ENABLED(CONFIG_PPC32))
> +		arch_zone_dma_bits = 30;
> +	else
> +		arch_zone_dma_bits = 31;
> +

So the above unconditionally comment obviously isn't true any more, and
Ben also said for the recent ppc32 hack he'd prefer dynamic detection.

Maybe Ben and or other ppc folks can chime in an add a patch to the series
to sort this out now that we have a dynamic ZONE_DMA threshold?

> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 59bdceea3737..40dfc9b4ee4c 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -19,9 +19,7 @@
>   * Most architectures use ZONE_DMA for the first 16 Megabytes, but
>   * some use it for entirely different regions:
>   */
> -#ifndef ARCH_ZONE_DMA_BITS
> -#define ARCH_ZONE_DMA_BITS 24
> -#endif
> +unsigned int arch_zone_dma_bits __ro_after_init = 24;

I'd prefer to drop the arch_ prefix and just calls this zone_dma_bits.
In the long run we really need to find a way to just automatically set
this from the meminit code, but that is out of scope for this series.
For now can you please just update the comment above to say something
like:

/*
 * Most architectures use ZONE_DMA for the first 16 Megabytes, but some use it
 * it for entirely different regions.  In that case the arch code needs to
 * override the variable below for dma-direct to work properly.
 */

