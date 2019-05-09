Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DE97C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:48:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3761A217D7
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 21:48:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3761A217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B66356B0003; Thu,  9 May 2019 17:48:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B16596B0006; Thu,  9 May 2019 17:48:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DE356B0007; Thu,  9 May 2019 17:48:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE676B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 17:48:24 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f82so3507092qkb.9
        for <linux-mm@kvack.org>; Thu, 09 May 2019 14:48:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=b14ETQ08BDpJ+XbGo1kDctCFcuvTcql9PWqCtdcbh9k=;
        b=kltLCmt0hnn0Dl5/LVoZS/aXxcw3p/0RNiZjRcRVvJFblDktIAgHNF1uUshh/vKfuN
         DEjTSlOrZ+NabLplpwAtrbOpdx/Wz92tzEYVjcMPi8XCBKiS7C62e+o4Ay4bqMGXbFrX
         vOu9Rd9PLlkYV+P/COix97kQRP6GW1neiSYRwGjVmH6WgmixKTpMzdtZlAwkJSlJE4Ia
         gPItNCrPDp2u9bnxcv6IoRY2Kvwy0IvJM1MIhXhBvELVDd8VINfj3y1eK9+OwOEiq+qJ
         Z6fC61Oxu3aT66XdmDFf3K3IrUSX+a20kIxeOomofvUQ23fEIB1DOyYw2F6TIHT3MeB8
         VxVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVWoxG5IT9AJiUW9w1w0P6T1rMl41eaQ6cF25JKe/pp4qPINLla
	4gfHLbjpkvC3mG0Iyo5wZ+HlvJ+DP02Bkj3z8Im8OPosPw1Jkea5lF31w6EpQVwIa+5FJBRJUE2
	0fqe1LqpRNWNDmCLHII8AFdRT56yrKu9wvT5nzQLeI2V2YHdoajVR/YVj/3A58n1cJA==
X-Received: by 2002:ac8:1c59:: with SMTP id j25mr2069008qtk.358.1557438504245;
        Thu, 09 May 2019 14:48:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTVjutQtTl6EzFnwukJ9kX9Gm8n7275emcFYxkmuVAiG6HgJeaVwraAZCqLVGyeNLznNkh
X-Received: by 2002:ac8:1c59:: with SMTP id j25mr2068946qtk.358.1557438503135;
        Thu, 09 May 2019 14:48:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557438503; cv=none;
        d=google.com; s=arc-20160816;
        b=pRNAjL542r6tV225irG6oY6YxlEYQstFczBNewY+g8YoSSlYAsQ+isR9WHZr4kzwpY
         9nHqWtmZfER7G/Ud34SUk4rw8rjrWKY+Jpp/BN3L4ifYUEt26OilHxZEsOuLZWSMDa2T
         ox6jFHH6gMMs5wfJG/2kA/9PXOitaH5pm/Gy/Y6D/QnJapRWmTGZJHtS4y0fw0JFZ8Ow
         LxXLaF0H7adma298YoWwtBWXYxYUh2CjoUltPgRzXvKq22nkZFnY+vRPG/TaJe/3tJ7A
         7Od2LMAE4b+G2bd8jspzmRNucDFjv6QZk1a9qnEN1ZtKZBKav4Z9ESzQul/H5x5+r9Js
         FCQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=b14ETQ08BDpJ+XbGo1kDctCFcuvTcql9PWqCtdcbh9k=;
        b=NxatoApbHoRxUimYb6YjvM0TJ5r06CuePmBCS4rct2+086BIeGHuATRErkKkZdqviv
         TGhtnxkvR4soC82ctR+RMEZo7FoMG/ETgXBEzY2At4Q8onPO7eZejz6JdoUQAMoqq56j
         9zM0hBMzqCu6RR865I7qFPyJsImHi5xfDOpYLPbqVo0Mjcuftk8moLG9g0ax69VUGMHr
         U2RSnlHpsbz5UXbYkKaioH5tX/TehOtyc1v3eX/3Q3PcL8yXRJCmcswwK5yvBbzqUCm7
         zh1ClW/U+hXLBvCMlzQ3AQxBS4I0Y1/KF+4mG/YyeVMiNzFYuaHE/NZAmUft/ATqaHw/
         FK0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a18si329346qtm.379.2019.05.09.14.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 14:48:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lersek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=lersek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1E63A81112;
	Thu,  9 May 2019 21:48:22 +0000 (UTC)
Received: from lacos-laptop-7.usersys.redhat.com (ovpn-120-234.rdu2.redhat.com [10.10.120.234])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 14BC65DF49;
	Thu,  9 May 2019 21:48:15 +0000 (UTC)
Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
To: Igor Mammedov <imammedo@redhat.com>
Cc: Robin Murphy <robin.murphy@arm.com>,
 Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>, linux-mm <linux-mm@kvack.org>,
 "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
 "qemu-arm@nongnu.org" <qemu-arm@nongnu.org>,
 "eric.auger@redhat.com" <eric.auger@redhat.com>,
 "peter.maydell@linaro.org" <peter.maydell@linaro.org>,
 Linuxarm <linuxarm@huawei.com>,
 "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
 Jonathan Cameron <jonathan.cameron@huawei.com>, "xuwei (O)"
 <xuwei5@huawei.com>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
 <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
 <190831a5-297d-addb-ea56-645afb169efb@redhat.com>
 <20190509183520.6dc47f2e@Igors-MacBook-Pro>
From: Laszlo Ersek <lersek@redhat.com>
Message-ID: <cd2aa867-5367-b470-0a2b-33897697c23f@redhat.com>
Date: Thu, 9 May 2019 23:48:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190509183520.6dc47f2e@Igors-MacBook-Pro>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 09 May 2019 21:48:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/09/19 18:35, Igor Mammedov wrote:
> On Wed, 8 May 2019 22:26:12 +0200
> Laszlo Ersek <lersek@redhat.com> wrote:
> 
>> On 05/08/19 14:50, Robin Murphy wrote:
>>> Hi Shameer,
>>>
>>> On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
>>>> Hi,
>>>>
>>>> This series here[0] attempts to add support for PCDIMM in QEMU for
>>>> ARM/Virt platform and has stumbled upon an issue as it is not clear(at
>>>> least
>>>> from Qemu/EDK2 point of view) how in physical world the hotpluggable
>>>> memory is handled by kernel.
>>>>
>>>> The proposed implementation in Qemu, builds the SRAT and DSDT parts
>>>> and uses GED device to trigger the hotplug. This works fine.
>>>>
>>>> But when we added the DT node corresponding to the PCDIMM(cold plug
>>>> scenario), we noticed that Guest kernel see this memory during early boot
>>>> even if we are booting with ACPI. Because of this, hotpluggable memory
>>>> may end up in zone normal and make it non-hot-un-pluggable even if Guest
>>>> boots with ACPI.
>>>>
>>>> Further discussions[1] revealed that, EDK2 UEFI has no means to
>>>> interpret the
>>>> ACPI content from Qemu(this is designed to do so) and uses DT info to
>>>> build the GetMemoryMap(). To solve this, introduced "hotpluggable"
>>>> property
>>>> to DT memory node(patches #7 & #8 from [0]) so that UEFI can
>>>> differentiate
>>>> the nodes and exclude the hotpluggable ones from GetMemoryMap().
>>>>
>>>> But then Laszlo rightly pointed out that in order to accommodate the
>>>> changes
>>>> into UEFI we need to know how exactly Linux expects/handles all the
>>>> hotpluggable memory scenarios. Please find the discussion here[2].
>>>>
>>>> For ease, I am just copying the relevant comment from Laszlo below,
>>>>
>>>> /******
>>>> "Given patches #7 and #8, as I understand them, the firmware cannot
>>>> distinguish
>>>>   hotpluggable & present, from hotpluggable & absent. The firmware can
>>>> only
>>>>   skip both hotpluggable cases. That's fine in that the firmware will
>>>> hog neither
>>>>   type -- but is that OK for the OS as well, for both ACPI boot and DT
>>>> boot?
>>>>
>>>> Consider in particular the "hotpluggable & present, ACPI boot" case.
>>>> Assuming
>>>> we modify the firmware to skip "hotpluggable" altogether, the UEFI memmap
>>>> will not include the range despite it being present at boot.
>>>> Presumably, ACPI
>>>> will refer to the range somehow, however. Will that not confuse the OS?
>>>>
>>>> When Igor raised this earlier, I suggested that
>>>> hotpluggable-and-present should
>>>> be added by the firmware, but also allocated immediately, as
>>>> EfiBootServicesData
>>>> type memory. This will prevent other drivers in the firmware from
>>>> allocating AcpiNVS
>>>> or Reserved chunks from the same memory range, the UEFI memmap will
>>>> contain
>>>> the range as EfiBootServicesData, and then the OS can release that
>>>> allocation in
>>>> one go early during boot.
>>>>
>>>> But this really has to be clarified from the Linux kernel's
>>>> expectations. Please
>>>> formalize all of the following cases:
>>>>
>>>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report
>>>> as  DT/ACPI should report as
>>>> -----------------  ------------------ 
>>>> -------------------------------  ------------------------
>>>> DT                 present             ?                                ?
>>>> DT                 absent              ?                                ?
>>>> ACPI               present             ?                                ?
>>>> ACPI               absent              ?                                ?
>>>>
>>>> Again, this table is dictated by Linux."
>>>>
>>>> ******/
>>>>
>>>> Could you please take a look at this and let us know what is expected
>>>> here from
>>>> a Linux kernel view point.
>>>
>>> For arm64, so far we've not even been considering DT-based hotplug - as
>>> far as I'm aware there would still be a big open question there around
>>> notification mechanisms and how to describe them. The DT stuff so far
>>> has come from the PowerPC folks, so it's probably worth seeing what
>>> their ideas are.
>>>
>>> ACPI-wise I've always assumed/hoped that hotplug-related things should
>>> be sufficiently well-specified in UEFI that "do whatever x86/IA-64 do"
>>> would be enough for us.
>>
>> As far as I can see in UEFI v2.8 -- and I had checked the spec before
>> dumping the table with the many question marks on Shameer --, all the
>> hot-plug language in the spec refers to USB and PCI hot-plug in the
>> preboot environment. There is not a single word about hot-plug at OS
>> runtime (regarding any device or component type), nor about memory
>> hot-plug (at any time).
>>
>> Looking to x86 appears valid -- so what does the Linux kernel expect on
>> that architecture, in the "ACPI" rows of the table?
> 
> I could only answer from QEMU x86 perspective.
> QEMU for x86 guests currently doesn't add hot-pluggable RAM into E820
> because of different linux guests tend to cannibalize it, making it non
> unpluggable. The last culprit I recall was KASLR.
> 
> So I'd refrain from reporting hotpluggable RAM in GetMemoryMap() if
> it's possible (it's probably hack (spec deosn't say anything about it)
> but it mostly works for Linux (plug/unplug) and Windows guest also
> fine with plug part (no unplug there)).

I can accept this as a perfectly valid design. Which would mean, QEMU should mark each hotpluggable RAM range in the DTB for the firmware with the special new property, regardless of its initial ("cold") plugged-ness, and then the firmware will not expose the range in the GCD memory space map, and consequently in the UEFI memmap either.

IOW, our table is, thus far:

OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as  DT/ACPI should report as
-----------------  ------------------  -------------------------------  ------------------------
DT                 present             ABSENT                           ?
DT                 absent              ABSENT                           ?
ACPI               present             ABSENT                           PRESENT
ACPI               absent              ABSENT                           ABSENT

In the firmware, I only need to care about the GetMemoryMap() column, so I can work with this. Can someone please file a feature request at <https://bugzilla.tianocore.org/>, for the ArmVirtPkg Package, with these detais?

Thanks
Laszlo

> 
> As for physical systems, there are out there ones that do report
> hotpluggable RAM in GetMemoryMap().
> 
>> Shameer: if you (Huawei) are represented on the USWG / ASWG, I suggest
>> re-raising the question on those lists too; at least the "ACPI" rows of
>> the table.
>>
>> Thanks!
>> Laszlo
>>
>>>
>>> Robin.
>>>
>>>> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed
>>>> any valid
>>>> points above).
>>>>
>>>> Thanks,
>>>> Shameer
>>>> [0] https://patchwork.kernel.org/cover/10890919/
>>>> [1] https://patchwork.kernel.org/patch/10863299/
>>>> [2] https://patchwork.kernel.org/patch/10890937/
>>>>
>>>>
>>
> 

