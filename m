Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C10AC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 09:58:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C0152173B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 09:58:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C0152173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBF966B0276; Fri, 10 May 2019 05:58:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E71B16B0278; Fri, 10 May 2019 05:58:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D5FAF6B0279; Fri, 10 May 2019 05:58:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id B76B46B0276
	for <linux-mm@kvack.org>; Fri, 10 May 2019 05:58:45 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h11so4986600qkk.1
        for <linux-mm@kvack.org>; Fri, 10 May 2019 02:58:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gJyo7qZyqsSZZYGumLJpzv11zEG5FXIWMMpzB6aTIdw=;
        b=hTClehc9KOvojUzxHIC8qYyQl6wuNAlOlBmZUZ43PbZ/V5lZNDStPIqlqiNhBYXgJv
         2akgXSuU/jaBA6SUBRzoCvwub0vBmOUPCON2e1c7PFRT3CVNaRju+zoRsS8tZFaSlmyB
         myLocDIR4Zs/OOY7FwJkfh6mt6Wkb/0jXFIdNKZsfAXnlCSLeVOAwmy0jFKr8TupmIy9
         3sMl+8k7GN+E5q/eXMKZeCBb68FQfFoQunmG0xkoaRfMzuWKtrB1QE33ap+27AH2kJZ3
         A6BkSsav78cXWnbZOI47rjisAnSEwfD918XtmuyEKxug/H1foxGHtz/L6nXrahriRoEn
         sXMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXCOHOGB/D5EscvAZQU+AvRjI1roiCOZ/yYujisA801mCoNqoVG
	aqN8LnL6tx4KCkFmWR/OVT2qeRrkJqarEZgz/LUtH/eHY88vyHZ9zFqLUn0LVfnuCduhFzWDMhz
	6YKJtdyH24BtI+G3EcashA+UBjZWKqXIJKxftf0rBs+953hhdaXAimyAidJuO1V4Tdw==
X-Received: by 2002:ac8:97b:: with SMTP id z56mr8296308qth.259.1557482325474;
        Fri, 10 May 2019 02:58:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw6VStODHF10FwA/BTAqE5nqhVmiKqYNZNL45DSx0uL1e5kM2G/UC3idw0z5uSklGY8E4TX
X-Received: by 2002:ac8:97b:: with SMTP id z56mr8296260qth.259.1557482324549;
        Fri, 10 May 2019 02:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557482324; cv=none;
        d=google.com; s=arc-20160816;
        b=jJ1guCrufFIw457YC28pZLQLKyFzknHcfl7K2hL+/Bi0RCT4CC03KRUdOMjgeqW5+3
         XUyfj2QgoEaYPF5OVpbNHlQilFs9WZPs7A/DM3r1T/hmPB4QgdSs2By1hYRyUBGQuoDd
         vIle3UeLW/MiqGihtyAU/kSY9HrNuEpIKjN9ciq9BtaT5fDkYV9sLpLE1Nzr+CAVLzAU
         NyRswoNCZLiMOhxbNwxiqBydO3ZraZWQZojGVh7+m2IT6Kky6XnjlGo4FK4fsstWcJpL
         /Zcqm37WHqPPqZuN36Pqe4sRifOEET7lVrx1oZ/LCpWQD28zYvy51hZHpZxhlyHGgUEy
         5Wmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gJyo7qZyqsSZZYGumLJpzv11zEG5FXIWMMpzB6aTIdw=;
        b=C7fEzmYWZHvjcY5BZyMrO9QMXqdNfByv4bcQqc2k1Y7V4EeuSr3L2r2lSl5qDeg1vg
         80mSnnV1i9AgH0SnNDywMjme56UjmYLykmuPOmlGlsaudD3Z8xlKDO58Y610TOO0358L
         lRoyZpFE6G6gSCklI2KzyuLXjfozCzoJjjz6qx1EvNu4jPjZMeAo3H/UFgegSrjFfBB9
         gSNtZRqBzqVycpW1Ds1DE8Q1GMG7X99G7OadBdSiLVaePOE79MhTkzMBFv7HJpEVSROP
         gVtMXJr/56Vi7nvV9cmcWjY+CCKWVkz77lt4yZER8L5MK9efgTmJvyEeDOoMZ3dP3EIu
         10AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si3156184qvt.11.2019.05.10.02.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 02:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of eric.auger@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=eric.auger@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 959EC3086212;
	Fri, 10 May 2019 09:58:43 +0000 (UTC)
Received: from [10.36.116.17] (ovpn-116-17.ams2.redhat.com [10.36.116.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B185B60CAB;
	Fri, 10 May 2019 09:58:39 +0000 (UTC)
Subject: Re: [Qemu-devel] [Question] Memory hotplug clarification for Qemu
 ARM/virt
To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>,
 Laszlo Ersek <lersek@redhat.com>, Igor Mammedov <imammedo@redhat.com>
Cc: "peter.maydell@linaro.org" <peter.maydell@linaro.org>,
 "xuwei (O)" <xuwei5@huawei.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Catalin Marinas <Catalin.Marinas@arm.com>,
 "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>,
 Linuxarm <linuxarm@huawei.com>, linux-mm <linux-mm@kvack.org>,
 "qemu-arm@nongnu.org" <qemu-arm@nongnu.org>,
 Jonathan Cameron <jonathan.cameron@huawei.com>,
 Robin Murphy <robin.murphy@arm.com>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
References: <5FC3163CFD30C246ABAA99954A238FA83F1B6A66@lhreml524-mbs.china.huawei.com>
 <ca5f7231-6924-0720-73a5-766eb13ee331@arm.com>
 <190831a5-297d-addb-ea56-645afb169efb@redhat.com>
 <20190509183520.6dc47f2e@Igors-MacBook-Pro>
 <cd2aa867-5367-b470-0a2b-33897697c23f@redhat.com>
 <5FC3163CFD30C246ABAA99954A238FA83F1DDFE5@lhreml524-mbs.china.huawei.com>
 <499f2bc5-da85-72b2-4f7b-32f2d25d842b@redhat.com>
 <5FC3163CFD30C246ABAA99954A238FA83F1DE1C0@lhreml524-mbs.china.huawei.com>
From: Auger Eric <eric.auger@redhat.com>
Message-ID: <aacca139-39a7-bdf2-c4dc-75d6a6cc1274@redhat.com>
Date: Fri, 10 May 2019 11:58:38 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <5FC3163CFD30C246ABAA99954A238FA83F1DE1C0@lhreml524-mbs.china.huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 10 May 2019 09:58:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Shameer,

On 5/10/19 11:27 AM, Shameerali Kolothum Thodi wrote:
> Hi Eric,
> 
>> -----Original Message-----
>> From: Auger Eric [mailto:eric.auger@redhat.com]
>> Sent: 10 May 2019 10:16
>> To: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>;
>> Laszlo Ersek <lersek@redhat.com>; Igor Mammedov
>> <imammedo@redhat.com>
>> Cc: peter.maydell@linaro.org; xuwei (O) <xuwei5@huawei.com>; Anshuman
>> Khandual <anshuman.khandual@arm.com>; Catalin Marinas
>> <Catalin.Marinas@arm.com>; ard.biesheuvel@linaro.org;
>> will.deacon@arm.com; qemu-devel@nongnu.org; Linuxarm
>> <linuxarm@huawei.com>; linux-mm <linux-mm@kvack.org>;
>> qemu-arm@nongnu.org; Jonathan Cameron
>> <jonathan.cameron@huawei.com>; Robin Murphy <robin.murphy@arm.com>;
>> linux-arm-kernel@lists.infradead.org
>> Subject: Re: [Qemu-devel] [Question] Memory hotplug clarification for Qemu
>> ARM/virt
>>
>> Hi Shameer,
>>
>> On 5/10/19 10:34 AM, Shameerali Kolothum Thodi wrote:
>>>
>>>
>>>> -----Original Message-----
>>>> From: Laszlo Ersek [mailto:lersek@redhat.com]
>>>> Sent: 09 May 2019 22:48
>>>> To: Igor Mammedov <imammedo@redhat.com>
>>>> Cc: Robin Murphy <robin.murphy@arm.com>; Shameerali Kolothum Thodi
>>>> <shameerali.kolothum.thodi@huawei.com>; will.deacon@arm.com; Catalin
>>>> Marinas <Catalin.Marinas@arm.com>; Anshuman Khandual
>>>> <anshuman.khandual@arm.com>; linux-arm-kernel@lists.infradead.org;
>>>> linux-mm <linux-mm@kvack.org>; qemu-devel@nongnu.org;
>>>> qemu-arm@nongnu.org; eric.auger@redhat.com;
>> peter.maydell@linaro.org;
>>>> Linuxarm <linuxarm@huawei.com>; ard.biesheuvel@linaro.org; Jonathan
>>>> Cameron <jonathan.cameron@huawei.com>; xuwei (O)
>> <xuwei5@huawei.com>
>>>> Subject: Re: [Question] Memory hotplug clarification for Qemu ARM/virt
>>>>
>>>> On 05/09/19 18:35, Igor Mammedov wrote:
>>>>> On Wed, 8 May 2019 22:26:12 +0200
>>>>> Laszlo Ersek <lersek@redhat.com> wrote:
>>>>>
>>>>>> On 05/08/19 14:50, Robin Murphy wrote:
>>>>>>> Hi Shameer,
>>>>>>>
>>>>>>> On 08/05/2019 11:15, Shameerali Kolothum Thodi wrote:
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> This series here[0] attempts to add support for PCDIMM in QEMU for
>>>>>>>> ARM/Virt platform and has stumbled upon an issue as it is not clear(at
>>>>>>>> least
>>>>>>>> from Qemu/EDK2 point of view) how in physical world the hotpluggable
>>>>>>>> memory is handled by kernel.
>>>>>>>>
>>>>>>>> The proposed implementation in Qemu, builds the SRAT and DSDT parts
>>>>>>>> and uses GED device to trigger the hotplug. This works fine.
>>>>>>>>
>>>>>>>> But when we added the DT node corresponding to the PCDIMM(cold
>> plug
>>>>>>>> scenario), we noticed that Guest kernel see this memory during early
>>>> boot
>>>>>>>> even if we are booting with ACPI. Because of this, hotpluggable
>> memory
>>>>>>>> may end up in zone normal and make it non-hot-un-pluggable even if
>>>> Guest
>>>>>>>> boots with ACPI.
>>>>>>>>
>>>>>>>> Further discussions[1] revealed that, EDK2 UEFI has no means to
>>>>>>>> interpret the
>>>>>>>> ACPI content from Qemu(this is designed to do so) and uses DT info to
>>>>>>>> build the GetMemoryMap(). To solve this, introduced "hotpluggable"
>>>>>>>> property
>>>>>>>> to DT memory node(patches #7 & #8 from [0]) so that UEFI can
>>>>>>>> differentiate
>>>>>>>> the nodes and exclude the hotpluggable ones from GetMemoryMap().
>>>>>>>>
>>>>>>>> But then Laszlo rightly pointed out that in order to accommodate the
>>>>>>>> changes
>>>>>>>> into UEFI we need to know how exactly Linux expects/handles all the
>>>>>>>> hotpluggable memory scenarios. Please find the discussion here[2].
>>>>>>>>
>>>>>>>> For ease, I am just copying the relevant comment from Laszlo below,
>>>>>>>>
>>>>>>>> /******
>>>>>>>> "Given patches #7 and #8, as I understand them, the firmware cannot
>>>>>>>> distinguish
>>>>>>>>   hotpluggable & present, from hotpluggable & absent. The firmware
>>>> can
>>>>>>>> only
>>>>>>>>   skip both hotpluggable cases. That's fine in that the firmware will
>>>>>>>> hog neither
>>>>>>>>   type -- but is that OK for the OS as well, for both ACPI boot and DT
>>>>>>>> boot?
>>>>>>>>
>>>>>>>> Consider in particular the "hotpluggable & present, ACPI boot" case.
>>>>>>>> Assuming
>>>>>>>> we modify the firmware to skip "hotpluggable" altogether, the UEFI
>>>> memmap
>>>>>>>> will not include the range despite it being present at boot.
>>>>>>>> Presumably, ACPI
>>>>>>>> will refer to the range somehow, however. Will that not confuse the
>> OS?
>>>>>>>>
>>>>>>>> When Igor raised this earlier, I suggested that
>>>>>>>> hotpluggable-and-present should
>>>>>>>> be added by the firmware, but also allocated immediately, as
>>>>>>>> EfiBootServicesData
>>>>>>>> type memory. This will prevent other drivers in the firmware from
>>>>>>>> allocating AcpiNVS
>>>>>>>> or Reserved chunks from the same memory range, the UEFI memmap
>> will
>>>>>>>> contain
>>>>>>>> the range as EfiBootServicesData, and then the OS can release that
>>>>>>>> allocation in
>>>>>>>> one go early during boot.
>>>>>>>>
>>>>>>>> But this really has to be clarified from the Linux kernel's
>>>>>>>> expectations. Please
>>>>>>>> formalize all of the following cases:
>>>>>>>>
>>>>>>>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should
>> report
>>>>>>>> as  DT/ACPI should report as
>>>>>>>> -----------------  ------------------
>>>>>>>> -------------------------------  ------------------------
>>>>>>>>
>>>> DT                 present             ?
>>>>               ?
>>>>>>>>
>>>> DT                 absent              ?
>>>>                ?
>>>>>>>>
>>>> ACPI               present             ?
>>>>               ?
>>>>>>>>
>>>> ACPI               absent              ?
>>>>               ?
>>>>>>>>
>>>>>>>> Again, this table is dictated by Linux."
>>>>>>>>
>>>>>>>> ******/
>>>>>>>>
>>>>>>>> Could you please take a look at this and let us know what is expected
>>>>>>>> here from
>>>>>>>> a Linux kernel view point.
>>>>>>>
>>>>>>> For arm64, so far we've not even been considering DT-based hotplug - as
>>>>>>> far as I'm aware there would still be a big open question there around
>>>>>>> notification mechanisms and how to describe them. The DT stuff so far
>>>>>>> has come from the PowerPC folks, so it's probably worth seeing what
>>>>>>> their ideas are.
>>>>>>>
>>>>>>> ACPI-wise I've always assumed/hoped that hotplug-related things
>> should
>>>>>>> be sufficiently well-specified in UEFI that "do whatever x86/IA-64 do"
>>>>>>> would be enough for us.
>>>>>>
>>>>>> As far as I can see in UEFI v2.8 -- and I had checked the spec before
>>>>>> dumping the table with the many question marks on Shameer --, all the
>>>>>> hot-plug language in the spec refers to USB and PCI hot-plug in the
>>>>>> preboot environment. There is not a single word about hot-plug at OS
>>>>>> runtime (regarding any device or component type), nor about memory
>>>>>> hot-plug (at any time).
>>>>>>
>>>>>> Looking to x86 appears valid -- so what does the Linux kernel expect on
>>>>>> that architecture, in the "ACPI" rows of the table?
>>>>>
>>>>> I could only answer from QEMU x86 perspective.
>>>>> QEMU for x86 guests currently doesn't add hot-pluggable RAM into E820
>>>>> because of different linux guests tend to cannibalize it, making it non
>>>>> unpluggable. The last culprit I recall was KASLR.
>>>>>
>>>>> So I'd refrain from reporting hotpluggable RAM in GetMemoryMap() if
>>>>> it's possible (it's probably hack (spec deosn't say anything about it)
>>>>> but it mostly works for Linux (plug/unplug) and Windows guest also
>>>>> fine with plug part (no unplug there)).
>>>>
>>>> I can accept this as a perfectly valid design. Which would mean, QEMU
>> should
>>>> mark each hotpluggable RAM range in the DTB for the firmware with the
>>>> special new property, regardless of its initial ("cold") plugged-ness, and then
>>>> the firmware will not expose the range in the GCD memory space map, and
>>>> consequently in the UEFI memmap either.
>>>>
>>>> IOW, our table is, thus far:
>>>>
>>>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as
>>>> DT/ACPI should report as
>>>> -----------------  ------------------  -------------------------------  ------------------------
>>>> DT                 present
>>>> ABSENT                           ?
>>>> DT                 absent
>>>> ABSENT                           ?
>>>> ACPI               present             ABSENT
>>>> PRESENT
>>>> ACPI               absent              ABSENT
>>>> ABSENT
>>>> In the firmware, I only need to care about the GetMemoryMap() column, so
>> I
>>>> can work with this.
>>>
>>> Thank you all for the inputs.
>>>
>>> I assume we will still report the DT cold plug case to kernel(hotpluggable &
>> present).
>>> so the table will be something like this,
>>>
>>> OS boot (DT/ACPI)  hotpluggable & ...  GetMemoryMap() should report as
>> DT/ACPI should report as
>>> -----------------  ------------------  -------------------------------  ------------------------
>>> DT                 present             ABSENT
>> PRESENT
>>> DT                 absent              ABSENT
>> ABSENT
>> With DT boot, how does the OS get to know if thehotpluggable memory is
>> present or absent? Or maybe I misunderstand the last column.
> 
> It doesn't. For hotpluggable & present case it will be just like normal memory and
> for absent case no memory node(hotpluaggble) is populated in DT. Is this acceptable?
OK I get it now. Yes it makes sense.
> 
> On another note, if there are no strong case for DT cold plug for PCDIMM we can drop
> it altogether which will make everything much simpler and no change required for
> UEFI as well.
I don't think we have strong requirements for PCDIMM in DT mode (initial
RAM can be used). As long as we can detect an attempt to use PCDIMM in
DT only mode and reject it (-no-acpi or !firmware_loaded ?), personally
I don't have any objection.

Thanks

Eric
> 
> Thanks,
> Shameer
> 
> 
>> Thanks
>>
>> Eric
>>> ACPI               present             ABSENT
>> PRESENT
>>> ACPI               absent              ABSENT
>> ABSENT
>>>
>>>
>>>  Can someone please file a feature request at
>>>> <https://bugzilla.tianocore.org/>, for the ArmVirtPkg Package, with these
>>>> detais?
>>>
>>> Ok. I will do that.
>>>
>>> Thanks,
>>> Shameer
>>>
>>>> Thanks
>>>> Laszlo
>>>>
>>>>>
>>>>> As for physical systems, there are out there ones that do report
>>>>> hotpluggable RAM in GetMemoryMap().
>>>>>
>>>>>> Shameer: if you (Huawei) are represented on the USWG / ASWG, I
>> suggest
>>>>>> re-raising the question on those lists too; at least the "ACPI" rows of
>>>>>> the table.
>>>>>>
>>>>>> Thanks!
>>>>>> Laszlo
>>>>>>
>>>>>>>
>>>>>>> Robin.
>>>>>>>
>>>>>>>> (Hi Laszlo/Igor/Eric, please feel free to add/change if I have missed
>>>>>>>> any valid
>>>>>>>> points above).
>>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> Shameer
>>>>>>>> [0] https://patchwork.kernel.org/cover/10890919/
>>>>>>>> [1] https://patchwork.kernel.org/patch/10863299/
>>>>>>>> [2] https://patchwork.kernel.org/patch/10890937/
>>>>>>>>
>>>>>>>>
>>>>>>
>>>>>
>>>

