Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22AD7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA1DA2147A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 12:43:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA1DA2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 715696B026F; Thu, 13 Jun 2019 08:43:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6C6986B0270; Thu, 13 Jun 2019 08:43:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DE3A8E0001; Thu, 13 Jun 2019 08:43:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E8136B026F
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:43:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so30683889edc.17
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 05:43:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8PkC0EBapHR12vT+h7Pbh+cIwdQ0xmtvjDkx2GTUDxE=;
        b=eNnHfy6f/42GtopJtVBzKACLf0Hea4HrazUHuvhzBFrExukhnEVs7mZoeuNVRUKXt6
         oKacWCvbu7q0yyzYJN263Wxf02pbJgPPZg0f08WezMFyTSFYi/pZmGDLwNxqKLkEt2/B
         IUSqlOrHqqskXpYTmyfL6+11gfk5kvfz+E8G9bSyP57GM6oDzgOfeWdGJto6E0rF+vbJ
         NLpRBQ7P7AYvmVIyn9LjjKlmSXZtxZzofx8ofEkvYEwLnslj1pu1bs0x4KeE4oIwMnZN
         OsrgqIEEYG53fF7ST5Tnze1La6X0TKUlKnAGCiKQFypZQEhaPJ5tpxUUV927bKedh24G
         MVMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: APjAAAUxANdzV/6bB5XfFJyLwz3HdMhMcWaEL6q+evh3JbM2PPpyrk7K
	LEgpSvNp21VkNabvu4Y5AXH0K9qX+8AEWzoyahbUhYtysMnE+PIiQFhV60DCusPMPJltXRgAxXQ
	s+xll78dBDpjaX9CroZV9oZJSweJfyFB8/LZ7MQhceHwREzIU1ZqsRqKi/PwSNn5Rdw==
X-Received: by 2002:a17:906:924c:: with SMTP id c12mr12742984ejx.60.1560429802611;
        Thu, 13 Jun 2019 05:43:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydx31w8DI+E7S7aqKQ8irid3iQAuAoz8R6exYP10r7+VEMitKYY4rk9XPaXO67yFZ3FC8E
X-Received: by 2002:a17:906:924c:: with SMTP id c12mr12742944ejx.60.1560429801877;
        Thu, 13 Jun 2019 05:43:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560429801; cv=none;
        d=google.com; s=arc-20160816;
        b=vVGWffKBp+4GOJH6JNLkJvmGJig8bgGWCBalBjrxp6NPjP3NacW9kcbHN5FaVhF7Is
         rpXFgEHEbFhNSeBltFtmvly1cwBxJIIkYQ4qUU5WVBJLWffAPqPdZTmXvOoGNTyJToKA
         Ry0lV8/RsFRni7f2TP9msbapMaRw518j1Efq9R8iEO5d4i/dalQB9EpoklD0NNXXxNyY
         2k5lB/snmGwif2YCiuCXdEY4P1HC7YBMjWCqm7yeGVzhZdJ0sAkMsDjqAyCJEOyPY6UM
         vP6xuec3LOUX4jT72uHbVN4qaV/oGPW6HwbeAqvgLWTxoudeYuMIC/qzOUFRdH69tS74
         PKEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8PkC0EBapHR12vT+h7Pbh+cIwdQ0xmtvjDkx2GTUDxE=;
        b=rVqaUBZmN6Vweh5f/vBZ594+LLr/bFaF35Xmxt5yUxBFW+lSAEDEhXbkyEj7rmYdhj
         xbPyn+POGakAUnweC79HDaPU8pK6IpMCFtGwrYfgeJVY9OT75JKvjq7Q0kj12+gaNHzb
         4v+Z4dO+V+EU26Bo8195eBdjyKvwT8hPXAYLAks3AYIHJIP8kxO/uld61pcH+7TWi7x7
         vJBHgt1o1Ii3VsSS/x+cMK3lF3ubESOC7+/hp/8UmnL771yarFYGQ9wDoAe/6Xf+C/lr
         HY+tVwqUNMrawI0w7/VbBO5o8O1f1wQkBvT8FqLb5EHMZfWIu/mDgMguaMI2Pexvfoy9
         olGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o2si1976626ejd.64.2019.06.13.05.43.21
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 05:43:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E04BE2B;
	Thu, 13 Jun 2019 05:43:20 -0700 (PDT)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 76DA33F694;
	Thu, 13 Jun 2019 05:43:18 -0700 (PDT)
Subject: Re: [PATCH 0/4] support reserving crashkernel above 4G on arm64 kdump
To: Chen Zhou <chenzhou10@huawei.com>
Cc: catalin.marinas@arm.com, will.deacon@arm.com, akpm@linux-foundation.org,
 ard.biesheuvel@linaro.org, rppt@linux.ibm.com, tglx@linutronix.de,
 mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com, horms@verge.net.au,
 takahiro.akashi@linaro.org, linux-arm-kernel@lists.infradead.org,
 linux-kernel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org,
 wangkefeng.wang@huawei.com
References: <20190507035058.63992-1-chenzhou10@huawei.com>
 <51995efd-8469-7c15-0d5e-935b63fe2d9f@arm.com>
 <638a5d22-8d51-8d63-2d8a-a38bbb8fb1d6@huawei.com>
From: James Morse <james.morse@arm.com>
Message-ID: <72a9c52b-1b24-57e8-e29f-b5a53524744b@arm.com>
Date: Thu, 13 Jun 2019 13:43:16 +0100
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <638a5d22-8d51-8d63-2d8a-a38bbb8fb1d6@huawei.com>
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
> On 2019/6/6 0:32, James Morse wrote:
>> On 07/05/2019 04:50, Chen Zhou wrote:
>>> We use crashkernel=X to reserve crashkernel below 4G, which will fail
>>> when there is no enough memory. Currently, crashkernel=Y@X can be used
>>> to reserve crashkernel above 4G, in this case, if swiotlb or DMA buffers
>>> are requierd, capture kernel will boot failure because of no low memory.
>>
>>> When crashkernel is reserved above 4G in memory, kernel should reserve
>>> some amount of low memory for swiotlb and some DMA buffers. So there may
>>> be two crash kernel regions, one is below 4G, the other is above 4G.
>>
>> This is a good argument for supporting the 'crashkernel=...,low' version.
>> What is the 'crashkernel=...,high' version for?
>>
>> Wouldn't it be simpler to relax the ARCH_LOW_ADDRESS_LIMIT if we see 'crashkernel=...,low'
>> in the kernel cmdline?
>>
>> I don't see what the 'crashkernel=...,high' variant is giving us, it just complicates the
>> flow of reserve_crashkernel().
>>
>> If we called reserve_crashkernel_low() at the beginning of reserve_crashkernel() we could
>> use crashk_low_res.end to change some limit variable from ARCH_LOW_ADDRESS_LIMIT to
>> memblock_end_of_DRAM().
>> I think this is a simpler change that gives you what you want.
> 
> According to your suggestions, we should do like this:
> 1. call reserve_crashkernel_low() at the beginning of reserve_crashkernel()
> 2. mark the low region as 'nomap'
> 3. use crashk_low_res.end to change some limit variable from ARCH_LOW_ADDRESS_LIMIT to
> memblock_end_of_DRAM()
> 4. rename crashk_low_res as "Crash kernel (low)" for arm64

> 5. add an 'linux,low-memory-range' node in DT

(This bit would happen in kexec-tools)


> Do i understand correctly?

Yes, I think this is simpler and still gives you what you want.
It also leaves the existing behaviour unchanged, which helps with keeping compatibility
with existing user-space and older kdump kernels.


Thanks,

James

