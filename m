Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66C97C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:08:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F12642084F
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:08:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=gmx.net header.i=@gmx.net header.b="DR8OfQ2U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F12642084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=gmx.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85C326B0005; Fri, 13 Sep 2019 06:08:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80BDA6B0006; Fri, 13 Sep 2019 06:08:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB4D6B0007; Fri, 13 Sep 2019 06:08:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5048E6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:08:58 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 009F7440B
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:08:58 +0000 (UTC)
X-FDA: 75929473956.13.point60_311614a0a2826
X-HE-Tag: point60_311614a0a2826
X-Filterd-Recvd-Size: 11586
Received: from mout.gmx.net (mout.gmx.net [212.227.17.21])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:08:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=gmx.net;
	s=badeba3b8450; t=1568369330;
	bh=9bA09uyPUsa4rSDaO/r8LV/sYb6PDtbXgwK11PIuxMQ=;
	h=X-UI-Sender-Class:Subject:To:Cc:References:From:Date:In-Reply-To;
	b=DR8OfQ2UBNtmgTQptPR6wuLP3LJv9z3EqklzF7PaipEJmCIvPr3kfswNKfO3MEBak
	 i/rSMFEN9myvLIr+GE8J4iNj2pdMLwsnJbBUDDZMW8Z5DPLyRq5DHDMo/MX8Al/+d8
	 NbtiTyOJlRWfPRSqT7R6t82NtsdfER4EHMC8PdGQ=
X-UI-Sender-Class: 01bb95c1-4bf8-414a-932a-4f6e2808ef9c
Received: from [192.168.1.162] ([37.4.249.90]) by mail.gmx.com (mrgmx105
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1MGhyc-1huwqm24Xq-00Dlwi; Fri, 13
 Sep 2019 12:08:50 +0200
Subject: Re: [PATCH v5 0/4] Raspberry Pi 4 DMA addressing support
To: Matthias Brugger <mbrugger@suse.com>, catalin.marinas@arm.com,
 marc.zyngier@arm.com, Matthias Brugger <matthias.bgg@gmail.com>,
 robh+dt@kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org,
 hch@lst.de, Nicolas Saenz Julienne <nsaenzjulienne@suse.de>
Cc: robin.murphy@arm.com, f.fainelli@gmail.com, will@kernel.org,
 linux-rpi-kernel@lists.infradead.org, phil@raspberrypi.org,
 m.szyprowski@samsung.com, linux-kernel@vger.kernel.org
References: <20190909095807.18709-1-nsaenzjulienne@suse.de>
 <5a8af6e9-6b90-ce26-ebd7-9ee626c9fa0e@gmx.net>
 <3f9af46e-2e1a-771f-57f2-86a53caaf94a@suse.com>
 <09f82f88-a13a-b441-b723-7bb061a2f1e3@gmail.com>
 <2c3e1ef3-0dba-9f79-52e2-314b6b500e14@gmx.net>
 <4a6f965b-c988-5839-169f-9f24a0e7a567@suse.com>
 <48a6b72d-d554-b563-5ed6-9a79db5fb4ab@gmx.net>
 <2fcc5ad6-fa90-6565-e75c-d20b46965733@suse.com>
From: Stefan Wahren <wahrenst@gmx.net>
Message-ID: <3163f80b-72e5-5da8-0909-a8950d3669f7@gmx.net>
Date: Fri, 13 Sep 2019 12:08:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <2fcc5ad6-fa90-6565-e75c-d20b46965733@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Provags-ID: V03:K1:5/92jOSBvjomzH7Yzels/hq0griHPnSHYlpVXEOGI5T0CE7VL29
 3nej+bDE18/HtpA4fg7IZzRuzLyOgf/la7KsOoNDP2u/RjnvbW+mtrmZq9CMqcwOTn6pVfF
 pl73uISF1GXn9ngpe5YQtJMHxp8tHOsgNa0roIlFaXvT4y0k4j219c4oHLdj0+p95uTVB/1
 8BHrT5O5pn5ZRadsa5fzw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:HaDKMkz8fog=:UcGhBcytZldS09Vbi1n/nP
 zmmEcPDfw8LTZiIegCxldLuMj2r3SCzkEgZtTmC6v6IcarZKQ9v7UGOZfI6sIpEyz+J7qux5d
 ss/eui8zl97QX0AKcWEw/ge1GFSepsj0UybSdSjbq3fH/f3rlVfeEvcwO1eR7Uf4iLFr6Im02
 fByc4g/6cMyPnKqw9A/C0K3HeGyhN9PQ354saoL0fcN3rwmBkmTqHaMOpgBWNE0FFfqjtarh8
 H7kNwYzMdkqLoVJPZVyZkG9+ncDs6Mnxb6q29uokPXsyTd4nPNPEuh7R0xGqE+YdNh723KQsu
 ZWDKUgNgF5S1HH7bkP0aRZAo9wiw/6r8wfGujvRiZNd4tjgC0cKgLFezxJ00FkIjWyLYUz+Yx
 Oh88Vxgdb/6B6hxCRmRZ9qxljD7sWQyjLVWXpPFEtO6V1R8DoO9Y2OIXUs4x1TKFxEAH6WZ8i
 13eCUR6EMZ/ID0/qop3b5QVNz/ZsEGd+Va6uRI8fMBRqx2j5ZpDaxeWTc2CoZcax2R/5rCmVn
 onuqZcjM/zueGc6nc9mCtCckufLoTKRPkWyPupRUvzs1ZlnWHIdKuLx/5Dexwa74YoCHS61zP
 wMgV+9htXzfbTvRKS0gYFR/pNAezzsBK/ieQqxf3MNbhb9hPhguu4WxgLuN+P5aDBc4WNYrRn
 Te3o3bAwKmpZmPlw3q8EFynlOXmNqwxyyNmjoCJhrxxbm5m8at6L8lCiPmIKdGeYjHJ3kojle
 jSfgKKIYcb6+YIC0JNwBkdK9SZtqqZ7T7qWqaLdGaO1i/V2DqvNcinF1xsvSBWUCR/xsab9Ab
 LC4tjLNBTltZZFdUSX50dyPIYbMhNBxircBjPFNXLtylSyL4w8b99SJeBLKBT2/GpGxRWc35u
 gvjJdRrSAfgbz87iHG+wRy2HAW4B1h2LZUrGeEktLHLcCLSdqMmSFKf17fVMCWkHsATcft8CB
 otyFf1gMOsF0kK1IsdMUp18HXwNCcEU8twf/4mNuxLp44t3VmxTyii2Y/32lpq/yAR/b4Ra9U
 3P/edLrDdSnz5JC+jjg89+5f1DJpYMWTHo/SCiJk6ELnLzH0KMO+lKwAOi5KY0iVlLXTlEebc
 7uvTPQ/J5RfL1XmZvKPLaPbn3D1Lyqb4EbJmOtBkl31asla7038piOKgMXHMYtIUhO6By2acW
 FJelLD+wI1jK+S+xCIPUXOaefWTTlOawi1qRnrCLHQk/5Ep1pK5k0R1cLe+OPUOE06rNjmSf+
 VfGnSL65lLYSyPxbPohEQpu7QM8rrqcsSElE1rif2B44CX0gSOSwo9mmKQfk=
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am 13.09.19 um 11:25 schrieb Matthias Brugger:
>
> On 13/09/2019 10:50, Stefan Wahren wrote:
>> Am 13.09.19 um 10:09 schrieb Matthias Brugger:
>>> On 12/09/2019 21:32, Stefan Wahren wrote:
>>>> Am 12.09.19 um 19:18 schrieb Matthias Brugger:
>>>>> On 10/09/2019 11:27, Matthias Brugger wrote:
>>>>>> On 09/09/2019 21:33, Stefan Wahren wrote:
>>>>>>> Hi Nicolas,
>>>>>>>
>>>>>>> Am 09.09.19 um 11:58 schrieb Nicolas Saenz Julienne:
>>>>>>>> Hi all,
>>>>>>>> this series attempts to address some issues we found while bringing up
>>>>>>>> the new Raspberry Pi 4 in arm64 and it's intended to serve as a follow
>>>>>>>> up of these discussions:
>>>>>>>> v4: https://lkml.org/lkml/2019/9/6/352
>>>>>>>> v3: https://lkml.org/lkml/2019/9/2/589
>>>>>>>> v2: https://lkml.org/lkml/2019/8/20/767
>>>>>>>> v1: https://lkml.org/lkml/2019/7/31/922
>>>>>>>> RFC: https://lkml.org/lkml/2019/7/17/476
>>>>>>>>
>>>>>>>> The new Raspberry Pi 4 has up to 4GB of memory but most peripherals can
>>>>>>>> only address the first GB: their DMA address range is
>>>>>>>> 0xc0000000-0xfc000000 which is aliased to the first GB of physical
>>>>>>>> memory 0x00000000-0x3c000000. Note that only some peripherals have these
>>>>>>>> limitations: the PCIe, V3D, GENET, and 40-bit DMA channels have a wider
>>>>>>>> view of the address space by virtue of being hooked up trough a second
>>>>>>>> interconnect.
>>>>>>>>
>>>>>>>> Part of this is solved on arm32 by setting up the machine specific
>>>>>>>> '.dma_zone_size = SZ_1G', which takes care of reserving the coherent
>>>>>>>> memory area at the right spot. That said no buffer bouncing (needed for
>>>>>>>> dma streaming) is available at the moment, but that's a story for
>>>>>>>> another series.
>>>>>>>>
>>>>>>>> Unfortunately there is no such thing as 'dma_zone_size' in arm64. Only
>>>>>>>> ZONE_DMA32 is created which is interpreted by dma-direct and the arm64
>>>>>>>> arch code as if all peripherals where be able to address the first 4GB
>>>>>>>> of memory.
>>>>>>>>
>>>>>>>> In the light of this, the series implements the following changes:
>>>>>>>>
>>>>>>>> - Create both DMA zones in arm64, ZONE_DMA will contain the first 1G
>>>>>>>>   area and ZONE_DMA32 the rest of the 32 bit addressable memory. So far
>>>>>>>>   the RPi4 is the only arm64 device with such DMA addressing limitations
>>>>>>>>   so this hardcoded solution was deemed preferable.
>>>>>>>>
>>>>>>>> - Properly set ARCH_ZONE_DMA_BITS.
>>>>>>>>
>>>>>>>> - Reserve the CMA area in a place suitable for all peripherals.
>>>>>>>>
>>>>>>>> This series has been tested on multiple devices both by checking the
>>>>>>>> zones setup matches the expectations and by double-checking physical
>>>>>>>> addresses on pages allocated on the three relevant areas GFP_DMA,
>>>>>>>> GFP_DMA32, GFP_KERNEL:
>>>>>>>>
>>>>>>>> - On an RPi4 with variations on the ram memory size. But also forcing
>>>>>>>>   the situation where all three memory zones are nonempty by setting a 3G
>>>>>>>>   ZONE_DMA32 ceiling on a 4G setup. Both with and without NUMA support.
>>>>>>>>
>>>>>>> i like to test this series on Raspberry Pi 4 and i have some questions
>>>>>>> to get arm64 running:
>>>>>>>
>>>>>>> Do you use U-Boot? Which tree?
>>>>>> If you want to use U-Boot, try v2019.10-rc4, it should have everything you need
>>>>>> to boot your kernel.
>>>>>>
>>>>> Ok, here is a thing. In the linux kernel we now use bcm2711 as SoC name, but the
>>>>> RPi4 devicetree provided by the FW uses mostly bcm2838.
>>>> Do you mean the DTB provided at runtime?
>>>>
>>>> You mean the merged U-Boot changes, doesn't work with my Raspberry Pi
>>>> series?
>>>>
>>>>>  U-Boot in its default
>>>>> config uses the devicetree provided by the FW, mostly because this way you don't
>>>>> have to do anything to find out how many RAM you really have. Secondly because
>>>>> this will allow us, in the near future, to have one U-boot binary for both RPi3
>>>>> and RPi4 (and as a side effect one binary for RPi1 and RPi2).
>>>>>
>>>>> Anyway, I found at least, that the following compatibles need to be added:
>>>>>
>>>>> "brcm,bcm2838-cprman"
>>>>> "brcm,bcm2838-gpio"
>>>>>
>>>>> Without at least the cprman driver update, you won't see anything.
>>>>>
>>>>> "brcm,bcm2838-rng200" is also a candidate.
>>>>>
>>>>> I also suppose we will need to add "brcm,bcm2838" to
>>>>> arch/arm/mach-bcm/bcm2711.c, but I haven't verified this.
>>>> How about changing this in the downstream kernel? Which is much easier.
>>> I'm not sure I understand what you want to say. My goal is to use the upstream
>>> kernel with the device tree blob provided by the FW.
>> The device tree blob you are talking is defined in this repository:
>>
>> https://github.com/raspberrypi/linux
>>
>> So the word FW is misleading to me.
>>
> No, it's part of
> https://github.com/raspberrypi/firmware.git
> file boot/bcm2711-rpi-4-b.dtb
The compiled DT blobs incl. the kernel image are stored in this artifact
repository. But the sources for the kernel and the DT are in the Linux
repo. This is necessary to be compliant to the GPL.
>
>>>  If you talk about the
>>> downstream kernel, I suppose you mean we should change this in the FW DT blob
>>> and in the downstream kernel. That would work for me.
>>>
>>> Did I understand you correctly?
>> Yes
>>
>> So i suggest to add the upstream compatibles into the repo mentioned above.
>>
>> Sorry, but in case you decided as a U-Boot developer to be compatible
>> with a unreviewed DT, we also need to make U-Boot compatible with
>> upstream and downstream DT blobs.
>>
> Well RPi3 is working with the DT blob provided by the FW, as I mentioned earlier
> if we can use this DTB we can work towards one binary that can boot both RPi3
> and RPi4. On the other hand we can rely on the FW to detect the amount of memory
> our RPi4 has.
>
> That said, I agree that we should make sure that U-Boot can boot with both DTBs,
> the upstream one and the downstream. Now the question is how to get to this. I'm
> a bit puzzled that by talking about "unreviewed DT" you insinuate that bcm2711
> compatible is already reviewed and can't be changed. From what I can see none of
> these compatibles got merged for now, so we are still at time to change them.

Stephen Boyd was okay with clk changes except of a small nit. So i fixed
this is as he suggested in a separate series. Unfortunately this hasn't
be applied yet [1].

The i2c, pinctrl and the sdhci changes has been applied yet.

In my opinion it isn't the job of the mainline kernel to adapt to a
vendor device tree. It's the vendor device tree which needs to be fixed.

Sorry, but this is my holiday. I will back after the weekend.

Best regards
Stefan

[1] - https://www.spinics.net/lists/linux-clk/msg40534.html

>
> Apart from the point Florian made, to stay consistent with the RPi SoC naming,
> it will save us work, both in the kernel and in U-Boot, as we would need to add
> both compatibles to the code-base.
>
> Regards,
> Matthias
>
>>>>> Regards,
>>>>> Matthias
>>>>>
>>>>>> Regards,
>>>>>> Matthias
>>>>>>
>>>>>>> Are there any config.txt tweaks necessary?
>>>>>>>
>>>>>>>
>>>>>> _______________________________________________
>>>>>> linux-arm-kernel mailing list
>>>>>> linux-arm-kernel@lists.infradead.org
>>>>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>>>>>
>>>>> _______________________________________________
>>>>> linux-arm-kernel mailing list
>>>>> linux-arm-kernel@lists.infradead.org
>>>>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

