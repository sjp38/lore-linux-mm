Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DDB1C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04A2D206C0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 05:03:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04A2D206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76F726B0266; Thu,  4 Apr 2019 01:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71F556B0269; Thu,  4 Apr 2019 01:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60DC46B026A; Thu,  4 Apr 2019 01:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 125B06B0266
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 01:03:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so711921eda.8
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 22:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=m3Y6/1LnK1HOBlJ/0+ct3Oc4LjcXYC43z9zmvxs+QAE=;
        b=dlLYH4sawHXSqasqVR5ovR3GWfRdDGK0EcOLewmaZ5fzcmMSD61cbMGdDmGVeaaqvA
         Zvzoa9BzJWnLZKt8jhIxM/ywFQEt89SJRKqA6pcbR+Hl8xVlNMFP4eMtRJK0y7hV3cnt
         Tn8Bh/fi6Yu88mOFRaXNUNu9z8szJBs/KLy2TyfwWX+d7Y/qZlbqWR/t4f+yAkIfwBPm
         XBu/noRzBAHPvRtArkMfXEj9Bgtspnx9PI2Mbsr9vd8jQn737lpK9tTRK6VyOsitOcn0
         Y1EkQIkBhAngWty3xmggWaVcWDsStdD5EfnRDfGPmOSYCB8b/preHxPs9HoZc1NooQeL
         XRFA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAUd/awQshOFeVVqO1u8aOo5turb4lysB4UGWcmzNc6Nq0XcH3LG
	hCFgODJVWk6j7FSgEhOJ5vOho/8sp4ika4cuOuul0TS4LQfiHN3qVm0ltgxxCjv4aSAs3ehu9fG
	5EtcBplw9yI2w3WHxtXDlgDiG78iI+yp8VLj6W7fdv/P45IqiCEtfnWMCHVVlT5MU7Q==
X-Received: by 2002:a50:ad58:: with SMTP id z24mr2216982edc.75.1554354206625;
        Wed, 03 Apr 2019 22:03:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTrtziLOsZ3jB32C12gTOQu4K4rvW/y+QMJGVLNdN7UHFFLBnTVO8Ln6ZhQvyh2+jvYykU
X-Received: by 2002:a50:ad58:: with SMTP id z24mr2216946edc.75.1554354205697;
        Wed, 03 Apr 2019 22:03:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554354205; cv=none;
        d=google.com; s=arc-20160816;
        b=jBzqByKjW/xtXUZwlh9ngA5GoC4yw9kftepgJmbQlU4j5+3ovSnRlk7lTscXBGMi7n
         rQ/nUOcGVwe+UvZQJvRsuB+Jv51M0Sl8z+7Xgids9jLMwSPPIojwa1W429rXo/6xkr+K
         WRCIEnoDONbOalu9nuuP6dKMQtkNtQo3JyN4NP5JahhHQ89DPKAAvBRt5LNSgDKdmYxj
         oBZKd+264Hpptc0P2r5KrZMphjNv+Pk7OAXqb5KX0hm3i8HCK1iEKnrfgWcacQkUysfT
         16TU8M6sdPsYKInqUm00b6myb3chVWidL06WhOLhSZUYgWRHllkasayMiWEgzMg36AFq
         Swdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=m3Y6/1LnK1HOBlJ/0+ct3Oc4LjcXYC43z9zmvxs+QAE=;
        b=kVi3q87MwTviL26JENXUQ9VQNz/6I1H+1IM3YrTUYyFKiqmsSChSfzjEkU8PX0sRov
         25KWDgFvaFQVFNfGvCMNPG+JuSHBbAvWWHUKnVeTLKlABCJTQ3BtsIPFWSB3bXCylEHf
         VCDTdLyEKp1cTHiaNUIIV9tEWB2lceaU4PlZuh5lb4OVXgDvvgUc8gjHpAboP7J+axZZ
         r9GKfyI/3pEn+5evbyj9/iXydM/dVfcwuOw1FAAn0jABqeVBboM8LE92jI0ZhjAI4hvj
         SQzAoTElQ+wkP8ThST7OVo4AvbNMfJzJ478vrLi0MRqxzT4mhUFwjKy85FVCGwHooQKz
         nitQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x9si1325810edq.226.2019.04.03.22.03.25
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 22:03:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 496C7A78;
	Wed,  3 Apr 2019 22:03:24 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 182453F557;
	Wed,  3 Apr 2019 22:03:17 -0700 (PDT)
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
To: Jerome Glisse <jglisse@redhat.com>, Robin Murphy <robin.murphy@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com, mhocko@suse.com, mgorman@techsingularity.net,
 james.morse@arm.com, mark.rutland@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, david@redhat.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
 <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
 <20190403160722.GB12818@redhat.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <4507c5b0-0a96-6e28-d98c-06e3a696551c@arm.com>
Date: Thu, 4 Apr 2019 10:33:19 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190403160722.GB12818@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 09:37 PM, Jerome Glisse wrote:
> On Wed, Apr 03, 2019 at 02:58:28PM +0100, Robin Murphy wrote:
>> [ +Dan, Jerome ]
>>
>> On 03/04/2019 05:30, Anshuman Khandual wrote:
>>> Arch implementation for functions which create or destroy vmemmap mapping
>>> (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
>>> device memory range through driver provided vmem_altmap structure which
>>> fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
>>
>> ZONE_DEVICE is about more than just altmap support, no?
>>
>>> enable ZONE_DEVICE by subscribing to ARCH_HAS_ZONE_DEVICE. But this is only
>>> applicable for ARM64_4K_PAGES (ARM64_SWAPPER_USES_SECTION_MAPS) only which
>>> creates vmemmap section mappings and utilize vmem_altmap structure.
>>
>> What prevents it from working with other page sizes? One of the foremost
>> use-cases for our 52-bit VA/PA support is to enable mapping large quantities
>> of persistent memory, so we really do need this for 64K pages too. FWIW, it
>> appears not to be an issue for PowerPC.
>>
>>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>>> ---
>>>   arch/arm64/Kconfig | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>>> index db3e625..b5d8cf5 100644
>>> --- a/arch/arm64/Kconfig
>>> +++ b/arch/arm64/Kconfig
>>> @@ -31,6 +31,7 @@ config ARM64
>>>   	select ARCH_HAS_SYSCALL_WRAPPER
>>>   	select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
>>>   	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
>>> +	select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES
>>
>> IIRC certain configurations (HMM?) don't even build if you just turn this on
>> alone (although of course things may have changed elsewhere in the meantime)
>> - crucially, though, from previous discussions[1] it seems fundamentally
>> unsafe, since I don't think we can guarantee that nobody will touch the
>> corners of ZONE_DEVICE that also require pte_devmap in order not to go
>> subtly wrong. I did get as far as cooking up some patches to sort that out
>> [2][3] which I never got round to posting for their own sake, so please
>> consider picking those up as part of this series.
> 
> Correct _do not_ enable ZONE_DEVICE without support for pte_devmap detection.

Driver managed ZONE_DEVICE memory which never maps into user page table is not
a valid use case for ZONE_DEVICE ? Also what about MEMORY_DEVICE_PRIVATE ? That
can never be mapped into user page table. A driver can still manage these non
coherent memory through it's struct pages (which will be allocated inside RAM)

> If you want some feature of ZONE_DEVICE. Like HMM as while DAX does require
> pte_devmap, HMM device private does not. So you would first have to split
> ZONE_DEVICE into more sub-features kconfig option.

CONFIG_ZONE_DEVICE does not do that already ! All it says is that a device
memory range can be plugged into ZONE_DEVICE either as PRIVATE (non-coherent)
or PUBLIC/PCI_P2PDMA (coherent) memory without mandating anything about how
these memory will be further used.

> 
> What is the end use case you are looking for ? Persistent memory ?

Persistent memory is one of the primary use cases.

