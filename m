Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96FEDC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FFF02175B
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 15:57:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FFF02175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D83116B0007; Fri,  5 Apr 2019 11:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D32C86B0008; Fri,  5 Apr 2019 11:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD7596B000D; Fri,  5 Apr 2019 11:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D22E6B0008
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 11:57:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p90so3440287edp.11
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 08:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=TMExXfMIIcUlhhKoMJXC4m5FbXBbrHfh3IcqrYDUJhE=;
        b=rVe4MjVXJDfPwrXf9cfmfMIyT4i1vHu09p45Qlb6ZJ3TraNcDVjiTOTxeRZCXBZ5UN
         m0C8tprWb3hw0HXeqG/gnP39n59uzdsC62FWdAFv0ncjizQTBH53NC76QbnpA0AM9NlA
         +7O8wmvShBdY6Q+OS5fLkqQSS9wPDwFiSI7BgkBrYaLW9v99YRkERnucf5hW852udMab
         qJb7CDqWlEvw6pCwZ/dSaQwkLbL/4p9F/tRXNID7qDKLh1ULu4x6aRWbwlNrY5pa2VEs
         nveZYTsYOcJ6bkyybUyV6DvCQKSpSs+ssq6j4ig7aPNLcaZS/JB+sRTCpMFZ8NSodGwu
         l3Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAUrHKNvz9rNwALnJarwWTRruD4XPEiusAIQ/12sb0s3Yo//YJjd
	UciQ4GuqhJL8HAlm2mYQK19qoX1tKCpkJnCR8oStTtHkXOo3RZl/ZDpuheCuaWS8UMCEiRC/4uJ
	h0KJzzhIIb7SlLuny69hZra2wsUWdDW7Bk6mQR5pBjcpe9uka2SQHElynkmo1LGhSjA==
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr7696087ejj.161.1554479834969;
        Fri, 05 Apr 2019 08:57:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrYg9B7HoZh1v/WHPWDgKYli0s8rONf+ylBbCUS3iJDoZNuGWH+jYZ0n+ZxeWeTzsCEEPh
X-Received: by 2002:a17:906:1e89:: with SMTP id e9mr7696045ejj.161.1554479834042;
        Fri, 05 Apr 2019 08:57:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554479834; cv=none;
        d=google.com; s=arc-20160816;
        b=TO7eeoJoOank/fB3LFThSsJFQhxWhy4Ri5tQ/oyiZ07khy1X0CgTyLx6r0B+28qYC5
         ti5iZkiK0XELSUrXvniygWU1Xy1DTZMclDg7RKaZBKCghBLx3DFPdp5wSQW3A64WxEWx
         G+kqUnwTXRCAo85vTPf4G711ZMu6XgmLM2r38/xjafVYDJhfAcJ9pPJGaKJUcOyRBYrn
         OSvLIEsp/9Kb+DYuS09WN7m8QDRvjTC+5H02mQUy3DvNWxk0PqjMQNBtbGL1O59hshv7
         5Zvi1gbbPuhlT2X8eRx7pB1yRWAY3VfzojUYk9xb3vzgAAuIRcLlXymgEiwJz5TpYgLo
         eU7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=TMExXfMIIcUlhhKoMJXC4m5FbXBbrHfh3IcqrYDUJhE=;
        b=XP5bnVCTTYWFfjM9+hODEIZ46Q7xzRnW02wR75wV7gvfp7WnT4DnXV82h16a5hxIAb
         YwrT/pWx9Cn/Zo1uAqjuw2P0ckdJ7TNRbyspSB+Q8zKWVr44d7kXaNxYZXDikyODcuLi
         gecblayGd60lMA8DwY9I+DorRe7TccC9XAs/DknD4lnGBf5OCXXzXf3pfF5Iybxn26A9
         76T0n0/oyUut7YilPBLqbVKDRwbHUA4qYcN4ChTiMO4lFwVZnWqxQSJfnlMfWXjFO7eP
         XpKO4VbQRfWqHlzfSxZmmTFFDo6oxbgQJIBCvTnEXZ8lD9fRWwvNrsdYbDpdoUHsTUFg
         vCUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o20si6877877edv.449.2019.04.05.08.57.13
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 08:57:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A7F3A168F;
	Fri,  5 Apr 2019 08:57:12 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 63EEE3F68F;
	Fri,  5 Apr 2019 08:57:11 -0700 (PDT)
Subject: Re: struct dev_pagemap corruption
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
 <5b18e1c2-4ec5-8c61-a658-fb91996b95d0@arm.com>
 <60d1c5b7-7f85-7658-00f3-a3e5c6edc302@arm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <32e92df5-40b8-b4e7-afcc-897819a0af86@arm.com>
Date: Fri, 5 Apr 2019 16:57:09 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <60d1c5b7-7f85-7658-00f3-a3e5c6edc302@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/04/2019 15:54, Anshuman Khandual wrote:
> 
> 
> On 04/05/2019 07:07 PM, Robin Murphy wrote:
>> On 05/04/2019 05:40, Anshuman Khandual wrote:
>>> Hello,
>>>
>>> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
>>> unmapping path through device_destroy(). Its device memory range end address
>>> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
>>> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
>>> should retain it's values during the unmapping path as well. Is this assumption
>>> right ?
>>>
>>> [   62.779412] Call trace:
>>> [   62.779808]  dump_backtrace+0x0/0x118
>>> [   62.780460]  show_stack+0x14/0x20
>>> [   62.781204]  dump_stack+0xa8/0xcc
>>> [   62.781941]  devm_memremap_pages_release+0x24/0x1d8
>>> [   62.783021]  devm_action_release+0x10/0x18
>>> [   62.783911]  release_nodes+0x1b0/0x220
>>> [   62.784732]  devres_release_all+0x34/0x50
>>> [   62.785623]  device_release+0x24/0x90
>>> [   62.786454]  kobject_put+0x74/0xe8
>>> [   62.787214]  device_destroy+0x48/0x58
>>> [   62.788041]  zone_device_public_altmap_init+0x404/0x42c [zone_device_public_altmap]
>>> [   62.789675]  do_one_initcall+0x74/0x190
>>> [   62.790528]  do_init_module+0x50/0x1c0
>>> [   62.791346]  load_module+0x1be4/0x2140
>>> [   62.792192]  __se_sys_finit_module+0xb8/0xc8
>>> [   62.793128]  __arm64_sys_finit_module+0x18/0x20
>>> [   62.794128]  el0_svc_handler+0x88/0x100
>>> [   62.794989]  el0_svc+0x8/0xc
>>>
>>> The problem can be traced down here.
>>>
>>> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
>>> index e038e2b3b7ea..2a410c88c596 100644
>>> --- a/drivers/base/devres.c
>>> +++ b/drivers/base/devres.c
>>> @@ -33,7 +33,7 @@ struct devres {
>>>            * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>>>            * buffer alignment as if it was allocated by plain kmalloc().
>>>            */
>>> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
>>> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>>>    };
>>>
>>> On arm64 ARCH_KMALLOC_MINALIGN -> ARCH_DMA_MINALIGN -> 128
>>>
>>> dev_pagemap being added:
>>>
>>> #define ZONE_DEVICE_PHYS_START 0x680000000UL
>>> #define ZONE_DEVICE_PHYS_END   0x6BFFFFFFFUL
>>> #define ALTMAP_FREE 4096
>>> #define ALTMAP_RESV 1024
>>>
>>>      pgmap->type = MEMORY_DEVICE_PUBLIC;
>>
>> Given that what seems to ultimately get corrupted is the memory pointed to by pgmap here, how is *that* being allocated?
> 
> struct dev_pagemap *pgmap;
> 
> pgmap = devm_kzalloc(dev, sizeof(struct dev_pagemap), GFP_KERNEL);
> 
> Is it problematic to use dev_kzalloc here instead of generic kmalloc/kzalloc
> functions ? kzalloc() seems to solve the problem. Will do some more testing
> tomorrow.

The important point is that your pgmap is a devres allocation itself, 
thus changing the alignment of devres::data is moving the thing which 
was getting corrupted to a different relative location:

(gdb) p sizeof(struct devres) + sizeof(struct dev_pagemap)
$1 = 296
(gdb) p sizeof(struct devres) + (size_t)&(((struct dev_pagemap*)0)->res.end)
$2 = 192

vs.

(gdb) p sizeof(struct devres_node) + sizeof(struct dev_pagemap)
$3 = 192
(gdb) p sizeof(struct devres_node) + (size_t)&(((struct 
dev_pagemap*)0)->res.end)
$4 = 88

The fact that the corruption of the 128-byte-aligned devres::data occurs 
exactly where the 8-byte-aligned devres::data would have ended is 
particularly suspicious...

Robin.

