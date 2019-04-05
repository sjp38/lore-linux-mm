Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E400C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 14:54:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1802721852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 14:54:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1802721852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D2366B0008; Fri,  5 Apr 2019 10:54:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87EFD6B000D; Fri,  5 Apr 2019 10:54:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 748B06B0269; Fri,  5 Apr 2019 10:54:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 224D96B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 10:54:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m32so3394907edd.9
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 07:54:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=v0AH1oBsiANvbLFf199gvLW5ZbhSwcIdalTu8YVEQU8=;
        b=sys85askqFL4RX7yKF4IeqIw+ML1AADQtYnPWnviBdVhnMJhkZw+k+8TloP3jwRC3I
         gYa/K2a6Q/16ZbLQ70iiKiI5IFvHqPUwNrmhWIAWwDw5gsr6X00NvayFGp9qGc3PZl/F
         jceFXxCLgYJswP7oVWLokjaTj6+766iuTzYZEth3y9LUssi4coH4xqnRBD6tCyDZWqf9
         qbTr5c7oWkNJxnWYs4R507iuwa0rGHQ11J9hdY5uG0DmAZ25hNS+sPJHaS6frzT374mZ
         /EGoDDgoRSEa9A8uLzcUHPU/OrODMIWRchRDicYVCWmHdNqyIoVUEotFM9AAtW/1/yqy
         1fjg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVw1gBsvHHfxNG8pQOZkJt6a+RosKcusKEgn3VVxPjLeLtmb5zc
	dTs7tObcxm2ektFv5Ksv5lw582E5fr9ZoY9S6Diq2a6OfGeXWWyQVAa058BcgbB5O4vGu4zIPLk
	rfa4yEyG7ym0IilBmu1FcAUsGoGhjrBnjAZeu/N4SWRnqddSPTFKnJL2+I9/5m09w3A==
X-Received: by 2002:a17:906:4058:: with SMTP id y24mr7760400ejj.20.1554476082574;
        Fri, 05 Apr 2019 07:54:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPxsRTN2HCE2JXRPEwc3sJQO5SR+tHtYmFBB2RP8FQRnXTVLPGLSGXahaAnrkzV7OCyfDU
X-Received: by 2002:a17:906:4058:: with SMTP id y24mr7760353ejj.20.1554476081503;
        Fri, 05 Apr 2019 07:54:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554476081; cv=none;
        d=google.com; s=arc-20160816;
        b=aLiHovXd3SHFkgBuCq01iefOXr90BoBd/Tp+no+/oYQdCEfhJV9lgun/KlEpPmxdGc
         RPmZdgW7Iov5zZ3Y0fYo41TOjtduTZLC0CqsHKz+hUJcL2m2iIwvnjVSovP9SdvxtHQc
         Jli2JnBNkivoNm+2IiS0xaqcuid5HMjMYyhkWwqkrN3xKpPcaWw1HujPVnjLGLhOweq4
         3RrDjpKLxLjAEKYFn2qdNMOKDHzBxGyCHIPkTI3Sxde/ZZ5n3CZQ0fDZ+WcIrJ25Sp2X
         K6fcIqJBhpPeZCg5LteqQXc6X7pXgTQfTCt554ANO+2AqxRMBUSXS93BAaj3j6V9Xd4w
         6kvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=v0AH1oBsiANvbLFf199gvLW5ZbhSwcIdalTu8YVEQU8=;
        b=exJeBkBRLRfOyo5AAYorNJ0Ab+MZihKSp9EGZLK9/jBUQvGHdOOZSk+2m0lZBVLqX1
         x+vPP5pSr4jPSb/TDhrig4DJ4etEiC872WZiAUibuQdl6OAzENhq8ut6uZxfiO7LpaJS
         LLwUWB5LrLjMljkuMoewHcQcrchNH89LyFwVeOGu3jtWSh8RknEy/kaRUubWNac4ApJ0
         G4B52e6tCfkNeSRXbAmeTdJftsC6NyX79CG6mNMgngO9jts13JwirjLqd5ZjtDiYRoKl
         qZf/WyOLRe6qN80JNollAfuTy2emcIfX0f4bjamur+07sjMMPYyoj6ZWkwv7bcOG65ND
         EkIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t51si4992470eda.445.2019.04.05.07.54.41
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 07:54:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 41BA816A3;
	Fri,  5 Apr 2019 07:54:40 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B8CAF3F68F;
	Fri,  5 Apr 2019 07:54:37 -0700 (PDT)
Subject: Re: struct dev_pagemap corruption
To: Robin Murphy <robin.murphy@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
 <5b18e1c2-4ec5-8c61-a658-fb91996b95d0@arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <60d1c5b7-7f85-7658-00f3-a3e5c6edc302@arm.com>
Date: Fri, 5 Apr 2019 20:24:38 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <5b18e1c2-4ec5-8c61-a658-fb91996b95d0@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/05/2019 07:07 PM, Robin Murphy wrote:
> On 05/04/2019 05:40, Anshuman Khandual wrote:
>> Hello,
>>
>> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
>> unmapping path through device_destroy(). Its device memory range end address
>> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
>> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
>> should retain it's values during the unmapping path as well. Is this assumption
>> right ?
>>
>> [   62.779412] Call trace:
>> [   62.779808]  dump_backtrace+0x0/0x118
>> [   62.780460]  show_stack+0x14/0x20
>> [   62.781204]  dump_stack+0xa8/0xcc
>> [   62.781941]  devm_memremap_pages_release+0x24/0x1d8
>> [   62.783021]  devm_action_release+0x10/0x18
>> [   62.783911]  release_nodes+0x1b0/0x220
>> [   62.784732]  devres_release_all+0x34/0x50
>> [   62.785623]  device_release+0x24/0x90
>> [   62.786454]  kobject_put+0x74/0xe8
>> [   62.787214]  device_destroy+0x48/0x58
>> [   62.788041]  zone_device_public_altmap_init+0x404/0x42c [zone_device_public_altmap]
>> [   62.789675]  do_one_initcall+0x74/0x190
>> [   62.790528]  do_init_module+0x50/0x1c0
>> [   62.791346]  load_module+0x1be4/0x2140
>> [   62.792192]  __se_sys_finit_module+0xb8/0xc8
>> [   62.793128]  __arm64_sys_finit_module+0x18/0x20
>> [   62.794128]  el0_svc_handler+0x88/0x100
>> [   62.794989]  el0_svc+0x8/0xc
>>
>> The problem can be traced down here.
>>
>> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
>> index e038e2b3b7ea..2a410c88c596 100644
>> --- a/drivers/base/devres.c
>> +++ b/drivers/base/devres.c
>> @@ -33,7 +33,7 @@ struct devres {
>>           * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>>           * buffer alignment as if it was allocated by plain kmalloc().
>>           */
>> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
>> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>>   };
>>
>> On arm64 ARCH_KMALLOC_MINALIGN -> ARCH_DMA_MINALIGN -> 128
>>
>> dev_pagemap being added:
>>
>> #define ZONE_DEVICE_PHYS_START 0x680000000UL
>> #define ZONE_DEVICE_PHYS_END   0x6BFFFFFFFUL
>> #define ALTMAP_FREE 4096
>> #define ALTMAP_RESV 1024
>>
>>     pgmap->type = MEMORY_DEVICE_PUBLIC;
> 
> Given that what seems to ultimately get corrupted is the memory pointed to by pgmap here, how is *that* being allocated?

struct dev_pagemap *pgmap;

pgmap = devm_kzalloc(dev, sizeof(struct dev_pagemap), GFP_KERNEL);

Is it problematic to use dev_kzalloc here instead of generic kmalloc/kzalloc
functions ? kzalloc() seems to solve the problem. Will do some more testing
tomorrow.

