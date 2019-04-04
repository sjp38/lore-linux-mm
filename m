Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1F10C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:42:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E8182064A
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:42:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E8182064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4230E6B0008; Thu,  4 Apr 2019 00:42:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D2826B000E; Thu,  4 Apr 2019 00:42:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2EA286B0266; Thu,  4 Apr 2019 00:42:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D69E36B0008
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 00:42:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f2so701381edv.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:42:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=QKQaQ3ZcJ0m1Leh/O1F0XNahoODATne3HUZCJoGTfLQ=;
        b=WC2qWe760GxP6xX5XmkBv/NIgNzdVOMZ5G4jyOX5hoWfob1fq55lG/o4FfC6szSqcy
         xx6Zs09e3JTvFA0oa4N/Q41w4Oca7VPg+MGHOabr6FlO/LWUaYSYBIe8DqTmu43UuzLd
         1bWhRpqPd+34+zwJDVunPeUKhBDi7l553YILaHZ6UrR3RtHzs5O7/AU9kWLx4gqRB9qT
         OSiGW5hS3o9q1OgupDnvHy/WgrWkenW2o1+WzpDXseDx80s3bHGta9TCzfPLk5+iW2IW
         TZgti2Dj/a4S1c7CiFsOvPCrPx9cpx9sZ05CfYXpKrNsilr4dgxfM8K9rloyk8ksjTVG
         ZsgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXNZ0J2yfDQByxC6aeE/wzEp1AZOPl660qClM0YYRM2gGjnS6yV
	ZT3wfHgmnMpMyTbCITvwtvWHbRNdlpQThZw+TbnK39Q726dQ9o/+UNAFPc94TwA73ZbZMo2dLb6
	1KSIIoJJvkgASs0sqgupH+PJH6QbNdlVX4p4d3ZOaqZ40/xJH54DjqnFHFz53vHdJaQ==
X-Received: by 2002:a05:6402:8c7:: with SMTP id d7mr2282400edz.122.1554352942404;
        Wed, 03 Apr 2019 21:42:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxo13envsZ/KJX+wRoIm1mUsEm6xcoBK0QzoAFfPuTi8UUoa5X1gl5Mvcs76ZvPs9EDufZO
X-Received: by 2002:a05:6402:8c7:: with SMTP id d7mr2282362edz.122.1554352941392;
        Wed, 03 Apr 2019 21:42:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554352941; cv=none;
        d=google.com; s=arc-20160816;
        b=ctHmXFhT2AHHiwkfl6g5Yd5sZ2bOopWd7OsnbfBzOA0jHCVcVdlnjqSItkemWzVU19
         ph4iHFmD9HAFEoO2yjBZZynEVVxCpGFHD+/j1162Eu6s8QcOJx7XW+tr4zn+Wg8b1/2k
         2DklY84zE7SCKPLhctuKgZLAHOzMSNDMy9lgsP+KKK4QI7jDCSmnnsLuUq7WrbJ5qOYM
         RKA1iNQ99bjbblfu8lZKy6vhzbsbGg7hSQ7N+JlxrE3LLwaLVYsDZ56QuxdhVMW//0+k
         NmbOOiE78CmP1D6lVbcs2x943dv1gY/Q0RuVbHI75fPaTz67PsAg5LzA381kV4o22Qrd
         bTAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=QKQaQ3ZcJ0m1Leh/O1F0XNahoODATne3HUZCJoGTfLQ=;
        b=J7+68HuoReiVMFX9quLy/8codJtoSWF8sUi5Kbr2xhT2wwrbvvNwNh3V91BpETLKsy
         40vj+OvsWFcu5NPAdyM2erFzraznTpBmjyiNYZYyeU9uKGoeGKIeWwHP7gki3b+b1oyO
         dCm/XoFJUIA/SjjxqBYw3Rzw2mOArGjMKI1JH7lgBp5qQ5JR3MHOVc9m/bafYjnbZwRr
         P488IW550yE1CMqFGY5Xr3QNIkJZDLfkjfUhp/TQfgDQ8tmCylPeYpV+x3C2i6IN975V
         fM7lv73O8jOO4N4Vnater3wuBGvw3HVYsw3ntKk4ifu6CFu3+rIDVMZDAxeCRgXWcrHh
         y6wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b48si1681289edd.316.2019.04.03.21.42.20
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 21:42:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 24EFCA78;
	Wed,  3 Apr 2019 21:42:20 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 525703F557;
	Wed,  3 Apr 2019 21:42:14 -0700 (PDT)
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
To: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
 david@redhat.com, cai@lca.pw, jglisse@redhat.com
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
 <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <0d72db39-e20d-1cbd-368e-74dda9b6c936@arm.com>
Date: Thu, 4 Apr 2019 10:12:15 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/03/2019 07:28 PM, Robin Murphy wrote:
> [ +Dan, Jerome ]
> 
> On 03/04/2019 05:30, Anshuman Khandual wrote:
>> Arch implementation for functions which create or destroy vmemmap mapping
>> (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
>> device memory range through driver provided vmem_altmap structure which
>> fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
> 
> ZONE_DEVICE is about more than just altmap support, no?

Hot plugging the memory into a dev->numa_node's ZONE_DEVICE and initializing the
struct pages for it has stand alone and self contained use case. The driver could
just want to manage the memory itself but with struct pages either in the RAM or
in the device memory range through struct vmem_altmap. The driver may not choose
to opt for HMM, FS DAX, P2PDMA (use cases of ZONE_DEVICE) where it may have to
map these pages into any user pagetable which would necessitate support for
pte|pmd|pud_devmap.

Though I am still working towards getting HMM, FS DAX, P2PDMA enabled on arm64,
IMHO ZONE_DEVICE is self contained and can be evaluated in itself.

> 
>> enable ZONE_DEVICE by subscribing to ARCH_HAS_ZONE_DEVICE. But this is only
>> applicable for ARM64_4K_PAGES (ARM64_SWAPPER_USES_SECTION_MAPS) only which
>> creates vmemmap section mappings and utilize vmem_altmap structure.
> 
> What prevents it from working with other page sizes? One of the foremost use-cases for our 52-bit VA/PA support is to enable mapping large quantities of persistent memory, so we really do need this for 64K pages too. FWIW, it appears not to be an issue for PowerPC.


On !AR64_4K_PAGES vmemmap_populate() calls vmemmap_populate_basepages() which
does not support struct vmem_altmap right now. Originally was planning to send
the vmemmap_populate_basepages() enablement patches separately but will post it
here for review.

> 
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>   arch/arm64/Kconfig | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index db3e625..b5d8cf5 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -31,6 +31,7 @@ config ARM64
>>       select ARCH_HAS_SYSCALL_WRAPPER
>>       select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
>>       select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
>> +    select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES
> 
> IIRC certain configurations (HMM?) don't even build if you just turn this on alone (although of course things may have changed elsewhere in the meantime) - crucially, though, from previous discussions[1] it seems fundamentally unsafe, since I don't think we can guarantee that nobody will touch the corners of ZONE_DEVICE that also require pte_devmap in order not to go subtly wrong. I did get as far as cooking up some patches to sort that out [2][3] which I never got round to posting for their own sake, so please consider picking those up as part of this series.

In the previous discussion mentioned here [1] it sort of indicates that we
cannot have a viable (ARCH_HAS_ZONE_DEVICE=y but !__HAVE_ARCH_PTE_DEVMAP). I
dont understand why ! The driver can just hotplug the range into ZONE_DEVICE,
manage the memory itself without mapping them to user page table ever. IIUC
ZONE_DEVICE must not need user mapped device PFN support. All the corner case
problems discussed previously come in once these new 'device PFN' memory which
is now in ZONE_DEVICE get mapped into user page table.

> 
> Robin.
> 
>>       select ARCH_HAVE_NMI_SAFE_CMPXCHG
>>       select ARCH_INLINE_READ_LOCK if !PREEMPT
>>       select ARCH_INLINE_READ_LOCK_BH if !PREEMPT
>>
> 
> 
> [1] https://lore.kernel.org/linux-mm/CAA9_cmfA9GS+1M1aSyv1ty5jKY3iho3CERhnRAruWJW3PfmpgA@mail.gmail.com/#t
> [2] http://linux-arm.org/git?p=linux-rm.git;a=commitdiff;h=61816b833afdb56b49c2e58f5289ae18809e5d67
> [3] http://linux-arm.org/git?p=linux-rm.git;a=commitdiff;h=a5a16560eb1becf9a1d4cc0d03d6b5e76da4f4e1
> (apologies to anyone if the linux-arm.org server is being flaky as usual and requires a few tries to respond properly)

I have not evaluated pte_devmap(). Will consider [3] when enabling it. But
I still dont understand why ZONE_DEVICE can not be enabled and used from a
driver which never requires user mapping or pte|pmd|pud_devmap() support.

