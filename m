Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6A7AC10F00
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 14:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 820B92186A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 14:58:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 820B92186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 217EB6B0269; Fri,  5 Apr 2019 10:58:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C5D76B026A; Fri,  5 Apr 2019 10:58:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0B61A6B026B; Fri,  5 Apr 2019 10:58:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B35686B0269
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 10:58:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p90so3352510edp.11
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 07:58:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5rCIpsfIpy5BAvhU0U8DQBl3PiS0Eblt96RL0y0Fiw4=;
        b=TvwchKeCn2G7m5e5xz4FBgfLSOu3Y3/V8+ZP7Qc3HVal9KqSNsnGDVUsbbwYotvSqW
         iPDHs8Dbahd2sJPtgNmzcuiNu04ZtLvvaVd2fZj0JqpEOJw6ItKyvtxnTiOjPHLLyA81
         B3spVb6kKxcj6wzN0sz4cCkajB2VEuYOl9+AcrFBvsohhn1f94RHizV/JF6WcOzNMUSi
         AcB+oFcoSeMU/RfgRhQ8exgu5g+xq2Kpm7bQAYUUgLXjV59YH89JVm3wRSDXzxf/voBU
         z10cNm7Hxhe4hRACKIiNjw9Yqmt9p6adIywSQYKpjEomKQWHjXwFrP4Q7TBZHa3PRNJK
         3pig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVVCsiOd9kk1t18w+YydrQ34FlscwKSXQhJ/9CoaBKsfS8/+Emv
	/bbfUZL/QIcmC5FLUfcsUCfzLztBalbwUkHkAMUuespdDtNUS6xDKO+ZJwHmC61dpPmFlSu2ngM
	AW0Am7YYv1v2hUaKBdrfDOw8yiwq61RA3xjayUeneR8HDnEUAXK01/QTvWLLYd2tk6A==
X-Received: by 2002:a50:b4af:: with SMTP id w44mr8590547edd.179.1554476298267;
        Fri, 05 Apr 2019 07:58:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ1WEGrqkgWj0Io9i2oNu8wm97gA7GvctDAYmqiAVWWLSqErfD/7dcviYySm1lQPtn2N3V
X-Received: by 2002:a50:b4af:: with SMTP id w44mr8590498edd.179.1554476297349;
        Fri, 05 Apr 2019 07:58:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554476297; cv=none;
        d=google.com; s=arc-20160816;
        b=qCj0fF5o/GoiJranIxlRI0Owzp88OIxH7QBrA85OELLQxWbvhW7uNLXcDEh4GM73Tl
         1muH4NlKqAYMSVC3NYBfRMvh8Yr8nrTy7bFSYmXelZ+MeCDbs91n/F+ldT0Tvy+tm8yZ
         6xIaVYzeiOHdIsbmKDHAEeaEvL7QyySpEZYgT1CgUnXM24sS6lHpYEYfjdPs9cRZrB7P
         wCJWAd7KxszKURZZAOftQOFCCGmJbEsue/Qu0C4B1eilVhuoD5hv8jb5qbZilbhIJ+Jb
         QYGChVgtfEbm5TTwFjFFHd6M2caRJXuzmp8+7qozMYE04LJ8Q1bsla7n+54fNnjHDIj5
         R05Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=5rCIpsfIpy5BAvhU0U8DQBl3PiS0Eblt96RL0y0Fiw4=;
        b=JtlnsXuxt2Uo8J+MIIb+gVEV755HcCO9xdf+bpvPE0llSZ6g4ewa+bcqBzN3HE/w1E
         PA10RFFet95L0iku5U4Dk6eekXkkgaTJMoilPM4yby5rsz4s49s+wbeJeC3KcY5Phe5C
         8d/7XlF3OGj0fEX5fPjpl5fJj5Dvmlv66RXkoGSRT0w3JBd3+yOwWefBtPFtHt4FvFqx
         AaCvKtfbQBLzmM88/ZQvsVsjwBIv29pOoIzNfTTTGoHCYGUWW5rzJRntuoafdxqQQKHJ
         NLh0ZuiTY187b8qs3SeIounaM5WOuWeTcQkupOm51rBPa18IZVkbi+g2zX/hJmScbzsC
         7gdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ce3si2556698ejb.400.2019.04.05.07.58.17
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 07:58:17 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 55CFF16A3;
	Fri,  5 Apr 2019 07:58:16 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 09D0B3F68F;
	Fri,  5 Apr 2019 07:58:13 -0700 (PDT)
Subject: Re: struct dev_pagemap corruption
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Will Deacon <will.deacon@arm.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
 <20190405134210.GH4906@arrakis.emea.arm.com>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <d361c34e-36da-ab1c-dd18-30dd94cac3e1@arm.com>
Date: Fri, 5 Apr 2019 20:28:15 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190405134210.GH4906@arrakis.emea.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/05/2019 07:12 PM, Catalin Marinas wrote:
> Hi Anshuman,
> 
> On Fri, Apr 05, 2019 at 10:10:22AM +0530, Anshuman Khandual wrote:
>> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
>> unmapping path through device_destroy(). Its device memory range end address
>> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
>> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
>> should retain it's values during the unmapping path as well. Is this assumption
>> right ?
> [...]
>> The problem can be traced down here.
>>
>> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
>> index e038e2b3b7ea..2a410c88c596 100644
>> --- a/drivers/base/devres.c
>> +++ b/drivers/base/devres.c
>> @@ -33,7 +33,7 @@ struct devres {
>>          * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>>          * buffer alignment as if it was allocated by plain kmalloc().
>>          */
>> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
>> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>>  };
> [...]
>> With the patch:
>>
>> [   53.027865] XXX: zone_device_public_altmap_init pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
>> [   53.029840] XXX: devm_memremap_pages_release pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
>>
>> Without the patch:
>>
>> [   34.326066] XXX: zone_device_public_altmap_init pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 6bfffffff size 40000000
>> [   34.328063] XXX: devm_memremap_pages_release pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 0 size fffffff980000001
> 
> OK, so without this patch pgmap->res.end becomes 0 while it should stay
> at 0x6bfffffff. Is it easy to reproduce with mainline?

Yeah but with some ZONE_DEVICE series patches.

> 
> What's zone_device_public_altmap_init? I couldn't grep it in mainline.

Test module inti function (should have mentioned it clearly).

> How's the pgmap allocated?

devm_kzalloc() but the problem seems to be gone with kzalloc().

> 
> I'd suggest you enable kasan and see if it spots anything.
> 

Sure.

