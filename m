Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5ADC0C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:08:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F19DC206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 16:08:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F19DC206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AC5F8E0030; Thu,  1 Aug 2019 12:08:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 634B18E0001; Thu,  1 Aug 2019 12:08:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D6C88E0030; Thu,  1 Aug 2019 12:08:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F10528E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:08:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f3so45174939edx.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 09:08:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=FshrkZ2Nb29G3AHALWiniqRqRIv/uvPJJY2TxMrQthQ=;
        b=V5t5cy3izi6raEpudG7svXBtAogqcB8XZfx4Ao+7mrtao5oYtDKpcDViP/wlHzmk5W
         KJiUH2+Hz69C2oPR64rv/AMIMTqKZlrd4nknsjhWoDY+JBIEyc6110kRIJtV1P+fysb3
         3J+HOor/sV34YUkAHCxyEBFqeO5GAgdQz3rtJhZkHm/pN/iSiNaGluNeOtRsBGAinYdO
         C+8LgUUSAZ8lL1dQHovcumK8CaTaLOutvuIpiTMZV8ulrhXH18cdEZ+VmkWe0L5TPs0w
         lNqhHFOdKdYZfstzSIfxcfJD7yC8lENiDDPTozRQdAOnYdHpvzn5vJh9bf9Hxx3DB3/x
         mxpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAXzAsqy07EASvC9uanuokUYvsB+Gw6J4rBJV8x81bnuOiTjdLrZ
	mjqLD6ycjfN1rgymCm3yaObEew6bkxoQV02QI4znRiBvn4Psz5KinDGQBvAwW3bRZeFIETQWWiJ
	bsNEbVcXAJU82MKqqz9yag57e5Y5RDICF8nJNwMYRYSpyODM1Ycg3K60XDodSRRo14g==
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr97650902ejd.99.1564675680538;
        Thu, 01 Aug 2019 09:08:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNOTloX5WgGVMfOHZw0+Pyawg6z9HTDBshQgONjkE6QFV7B5rs2KkVFqCdYpVezsGztF3E
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr97650833ejd.99.1564675679817;
        Thu, 01 Aug 2019 09:07:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564675679; cv=none;
        d=google.com; s=arc-20160816;
        b=eaZDM3s5CRhx8nVJvlHQRao6FeIKDDDOsRRRL7J60xXn7Qbigj5CNQYaauKf3V4QCO
         YZw1WvPNDxbsa2LnIP4TPkJ0L2gagbOcwd2bW36HysEbYBTExNRlgfzwCGxAaSscHVqu
         E2zATmBbzKTENXLmQNBTG1kNEaDg6/A93eDS/EwOXFTeZiR4G4h2fH6Fsh4r76LegPTi
         DRzj/DXJyjJS+1G0RNpgMX0sPIDBIfu5XIBPjvrwVHqu9mXaMB/mjMDONnWK087yPC1/
         4+ASZ77Ms5IRb3TOFA2q/tYJjdUicrydzZCxMYPMz4UEQGDrXHhCmJvq7EPI8YPpoc9+
         pfaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=FshrkZ2Nb29G3AHALWiniqRqRIv/uvPJJY2TxMrQthQ=;
        b=Y9SfqPxnRIbVZn86PedstFWL7h0Oa8LvLn4uY5ExOuLVI82lMOBAZSV1OsX7odw2WV
         s9dgCXnXUnVP/K3aba/evyrqLKtIPMgKfKa1RS+0PjpL4NgT1a2rkhQiCCEBqnoaHoVr
         ZZK6iLutTQx5LFHpWX9UgXuw6plSJfBOGgixInE4R7u+4W/7/rz0BFRCbYbF1d5aZ4sF
         AQWItmUJJReJD4YQ8DVR/nM1Lu9+oB6Ou2eMkb3UYIqdmasqoqrB6QBgaMwV0DL9djJg
         GvURmdib9qa28OoFUli+Cm7WBW/pPNai9c3lTY8Plq99AUpExS8oqoS6SG3a73I5NEqj
         kJLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i44si23687249ede.407.2019.08.01.09.07.59
        for <linux-mm@kvack.org>;
        Thu, 01 Aug 2019 09:07:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BEF84337;
	Thu,  1 Aug 2019 09:07:58 -0700 (PDT)
Received: from [10.32.8.205] (unknown [10.32.8.205])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0B6A23F694;
	Thu,  1 Aug 2019 09:07:55 -0700 (PDT)
Subject: Re: [PATCH 5/8] arm64: use ZONE_DMA on DMA addressing limited devices
To: Nicolas Saenz Julienne <nsaenzjulienne@suse.de>,
 Catalin Marinas <catalin.marinas@arm.com>
Cc: phill@raspberryi.org, devicetree@vger.kernel.org,
 linux-rpi-kernel@lists.infradead.org, f.fainelli@gmail.com,
 frowand.list@gmail.com, eric@anholt.net, marc.zyngier@arm.com,
 Will Deacon <will@kernel.org>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, iommu@lists.linux-foundation.org, robh+dt@kernel.org,
 wahrenst@gmx.net, mbrugger@suse.com, akpm@linux-foundation.org, hch@lst.de,
 linux-arm-kernel@lists.infradead.org, m.szyprowski@samsung.com
References: <20190731154752.16557-1-nsaenzjulienne@suse.de>
 <20190731154752.16557-6-nsaenzjulienne@suse.de>
 <20190731170742.GC17773@arrakis.emea.arm.com>
 <d8b4a7cb9c06824ca88a0602a5bf38b6324b43c0.camel@suse.de>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <e35dd4a5-281b-d281-59c9-3fc7108eb8be@arm.com>
Date: Thu, 1 Aug 2019 17:07:54 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <d8b4a7cb9c06824ca88a0602a5bf38b6324b43c0.camel@suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-08-01 4:44 pm, Nicolas Saenz Julienne wrote:
> On Wed, 2019-07-31 at 18:07 +0100, Catalin Marinas wrote:
>> On Wed, Jul 31, 2019 at 05:47:48PM +0200, Nicolas Saenz Julienne wrote:
>>> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
>>> index 1c4ffabbe1cb..f5279ef85756 100644
>>> --- a/arch/arm64/mm/init.c
>>> +++ b/arch/arm64/mm/init.c
>>> @@ -50,6 +50,13 @@
>>>   s64 memstart_addr __ro_after_init = -1;
>>>   EXPORT_SYMBOL(memstart_addr);
>>>   
>>> +/*
>>> + * We might create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA is needed if
>>> there
>>> + * are periferals unable to address the first naturally aligned 4GB of ram.
>>> + * ZONE_DMA32 will be expanded to cover the rest of that memory. If such
>>> + * limitations doesn't exist only ZONE_DMA32 is created.
>>> + */
>>
>> Shouldn't we instead only create ZONE_DMA to cover the whole 32-bit
>> range and leave ZONE_DMA32 empty? Can__GFP_DMA allocations fall back
>> onto ZONE_DMA32?
> 
> Hi Catalin, thanks for the review.
> 
> You're right, the GFP_DMA page allocation will fail with a nasty dmesg error if
> ZONE_DMA is configured but empty. Unsurprisingly the opposite situation is fine
> (GFP_DMA32 with an empty ZONE_DMA32).

Was that tested on something other than RPi4 with more than 4GB of RAM? 
(i.e. with a non-empty ZONE_NORMAL either way)

Robin.

> I switched to the scheme you're suggesting for the next version of the series.
> The comment will be something the likes of this:
> 
> /*
>   * We create both a ZONE_DMA and ZONE_DMA32. ZONE_DMA's size is decided based
>   * on whether the SoC's peripherals are able to address the first naturally
>   * aligned 4 GB of ram.
>   *
>   * If limited, ZONE_DMA covers that area and ZONE_DMA32 the rest of that 32 bit
>   * addressable memory.
>   *
>   * If not ZONE_DMA is expanded to cover the whole 32 bit addressable memory and
>   * ZONE_DMA32 is left empty.
>   */
> 
>   Regards,
>   Nicolas
> 
> 

