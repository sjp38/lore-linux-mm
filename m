Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DD1FC31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:44:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 713452147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:44:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 713452147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AC356B026F; Thu, 13 Jun 2019 08:44:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05E6A6B0270; Thu, 13 Jun 2019 08:44:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5766B0271; Thu, 13 Jun 2019 08:44:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFC66B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:44:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id o13so5827778edt.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:44:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LDzHsITbSygtqp7A2owYkiEC/rrO33c+0yJUYCUO57s=;
        b=OKQUAt4meIzdKgTBfAx8kA8Semm3xd0fUbGH110DIm38ozNlfS3fzrgVqprLoeWs3s
         IR6WYVnkqwxR/Z7JC3LnGJJ5vSqm0ao3Bz2/sM8lYRs49vnxCgFBSM5ZWBDg+x4fT56M
         d+xTV8X/LTMTxjkwVQVLm1NjYyCpGJrQs9yZ69feERNyNJEdRO/JPZDk++knTVVqaWFL
         bG7ExTuzKdvmNixJl+DhNUq7/age2MTltX5MlYItnvNAcd6vW6kESN2pf+rcZhT+9c1+
         0Yz4lvVqpAVTOj6YLPzoo4klT9AN7ECGDvFWM0E9wnetk4n1AXfb0Yyq8dZApDwEmDOn
         gJUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: APjAAAW3GVtkl9teANAg0aOU/vt2G/r523PzgWgezbpDe3VDwYuViTiS
	klvDPNvx0MEHKbPkdEmLoGZBtkUuQhN05N83rJnOWSxJM3ObtjMOM9hfztostRrNhA0/2TEItFg
	rHIL8lETCpYPBLMK3lDK6ee43OeDOjMOFEKB2c/01GQGtkI2Fz1kYnBNhQAGRfglOvg==
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr74095508ejb.86.1560429874190;
        Thu, 13 Jun 2019 05:44:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxPjhPOrIhb37GZiVzA8ClbLVM/g/RmBePHa3cGSu+PpiqLv/gLbNT1YDZeYV95v/UF4eWm
X-Received: by 2002:a17:906:d053:: with SMTP id bo19mr74095458ejb.86.1560429873191;
        Thu, 13 Jun 2019 05:44:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560429873; cv=none;
        d=google.com; s=arc-20160816;
        b=iYp9SNY2d7/GGSA6zXL3M8wKVjPzBN1/j82XU3hqK/I8U5LsGTAss98zPRfFPFDTkC
         s7usIy1FF8+gPp3ESfIrI3OKmeKMzbpewT7UvTrIppKIj4BKOb2Buxc83XqeNM5WNE6S
         AuimT4G6bdi7Pa9YVRQJNyKJEHTE3KjkhY1jiZn35YVQhrJWPB8B1krADz07h/IfzurP
         G+QL5thsYECVbZgwVXpKZYAX5YbFyAbU47JtTe+Z58kL64zzSwXIsUiuYjepeipKL4Ib
         vG0DhQjyQmawiGurB5fS0/Tfhyx1R0bnNETNTgQJ/xqjBj0WHtK2dO1pjnXsFT3AdFKt
         L/2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LDzHsITbSygtqp7A2owYkiEC/rrO33c+0yJUYCUO57s=;
        b=KKVJGOh+zRw3UjizZk4URSk9Azv069gVX4JgkFFYwWp81mL8qpCx063LHDYD4JeL3g
         SC435RdZ1FRUhzq+NzSVHFsBLN9dDGA2kmeh4LVH3vpcWf7fDSWPGBR49dYhtL1z9z4f
         lLYFib32C4fJBiCDXsm1ySRkUlwipoSK3JWzS+d7jT0H8opKLpf8HB7UyDVaGmdLeTaR
         xVvINLijSWeWoT2Mgb0yjdBuw2hjOsXX4MzkumZ7GR5yIc7cR+a65u7xPVR8Pstf5hxU
         kyGJ9RYLgXm5jO3MOoXRUXPHQ8lm3RYB12k2hX6j7Vk+Br59VANr7uMxmZd0e5nUx0Wg
         G/fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id z39si2344859edd.331.2019.06.13.05.44.32
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 05:44:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 36E163EF;
	Thu, 13 Jun 2019 05:44:32 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0F5113F694;
	Thu, 13 Jun 2019 05:44:29 -0700 (PDT)
Subject: Re: [PATCH 2/4] arm64: kdump: support reserving crashkernel above 4G
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
 ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com, horms@verge.net.au,
 takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org,
 wangkefeng.wang@huawei.com
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <20190507035058.63992-3-chenzhou10@huawei.com>
 <df2b659d-7406-fbfd-597d-be3a3f69abcb@arm.com>
 <d15f334c-90cd-7c09-5e54-6501e822e7f1@huawei.com>
From: James Morse <james.morse@arm.com>
Message-ID: <b04f5578-4422-319c-da1f-62f7b465c9f6@arm.com>
Date: Thu, 13 Jun 2019 13:44:28 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <d15f334c-90cd-7c09-5e54-6501e822e7f1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chen Zhou,

On 13/06/2019 12:27, Chen Zhou wrote:
> On 2019/6/6 0:29, James Morse wrote:
>> On 07/05/2019 04:50, Chen Zhou wrote:
>>> When crashkernel is reserved above 4G in memory, kernel should
>>> reserve some amount of low memory for swiotlb and some DMA buffers.
>>
>>> Meanwhile, support crashkernel=X,[high,low] in arm64. When use
>>> crashkernel=X parameter, try low memory first and fall back to high
>>> memory unless "crashkernel=X,high" is specified.
>>
>> What is the 'unless crashkernel=...,high' for? I think it would be simpler to relax the
>> ARCH_LOW_ADDRESS_LIMIT if reserve_crashkernel_low() allocated something.
>>
>> This way "crashkernel=1G" tries to allocate 1G below 4G, but fails if there isn't enough
>> memory. "crashkernel=1G crashkernel=16M,low" allocates 16M below 4G, which is more likely
>> to succeed, if it does it can then place the 1G block anywhere.
>>
> Yeah, this is much simpler.

>>> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
>>> index 413d566..82cd9a0 100644
>>> --- a/arch/arm64/kernel/setup.c
>>> +++ b/arch/arm64/kernel/setup.c
>>> @@ -243,6 +243,9 @@ static void __init request_standard_resources(void)
>>>  			request_resource(res, &kernel_data);
>>>  #ifdef CONFIG_KEXEC_CORE
>>>  		/* Userspace will find "Crash kernel" region in /proc/iomem. */
>>> +		if (crashk_low_res.end && crashk_low_res.start >= res->start &&
>>> +		    crashk_low_res.end <= res->end)
>>> +			request_resource(res, &crashk_low_res);
>>>  		if (crashk_res.end && crashk_res.start >= res->start &&
>>>  		    crashk_res.end <= res->end)
>>>  			request_resource(res, &crashk_res);
>>
>> With both crashk_low_res and crashk_res, we end up with two entries in /proc/iomem called
>> "Crash kernel". Because its sorted by address, and kexec-tools stops searching when it
>> find "Crash kernel", you are always going to get the kernel placed in the lower portion.
>>
>> I suspect this isn't what you want, can we rename crashk_low_res for arm64 so that
>> existing kexec-tools doesn't use it?

> In my patchset, in addition to the kernel patches, i also modify the kexec-tools.
>   arm64: support more than one crash kernel regions(http://lists.infradead.org/pipermail/kexec/2019-April/022792.html).
> In kexec-tools patch, we read all the "Crash kernel" entry and load crash kernel high.

But we can't rely on people updating user-space when they update the kernel!

[...]


>> I'm afraid you've missed the ugly bit of the crashkernel reservation...
>>
>> arch/arm64/mm/mmu.c::map_mem() marks the crashkernel as 'nomap' during the first pass of
>> page-table generation. This means it isn't mapped in the linear map. It then maps it with
>> page-size mappings, and removes the nomap flag.
>>
>> This is done so that arch_kexec_protect_crashkres() and
>> arch_kexec_unprotect_crashkres() can remove the valid bits of the crashkernel mapping.
>> This way the old-kernel can't accidentally overwrite the crashkernel. It also saves us if
>> the old-kernel and the crashkernel use different memory attributes for the mapping.
>>
>> As your low-memory reservation is intended to be used for devices, having it mapped by the
>> old-kernel as cacheable memory is going to cause problems if those CPUs aren't taken
>> offline and go corrupting this memory. (we did crash for a reason after all)
>>
>>
>> I think the simplest thing to do is mark the low region as 'nomap' in
>> reserve_crashkernel() and always leave it unmapped. We can then describe it via a
>> different string in /proc/iomem, something like "Crash kernel (low)". Older kexec-tools
>> shouldn't use it, (I assume its not using strncmp() in a way that would do this by
>> accident), and newer kexec-tools can know to describe it in the DT, but it can't write to it.

> I did miss the bit of the crashkernel reservation.
> I will fix this in next version.

I think all that is needed is to make the low-region nmap, and describe it via /proc/iomem
with a name where nothing will try and use it by accident.


Thanks,

James

