Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 480CCC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 06:21:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F166620818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 06:21:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aWKQb3fH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F166620818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8A9A86B0008; Wed, 17 Jul 2019 02:21:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85AD96B000A; Wed, 17 Jul 2019 02:21:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 721B68E0001; Wed, 17 Jul 2019 02:21:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38D196B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 02:21:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i26so13825587pfo.22
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 23:21:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8acWEJVKozUDgbpRsbTOTilbmLjq4nOryNdKnvI3qyI=;
        b=TlEo7dJ+oaJHIakAMuwfZIQ4r/srtW5iF854HeAL+i8B3Mxj1GWXQFwoO6kw5FCR6z
         r2tNlB31Kh4jtVyXpOpW4Gc0vAD1Ov+ma2t6/ihp5RplhNyzDQ9TnAXXh97UwWNBrgu0
         b0+JM/CI097KbnJe2vs50qGJGvInBRtk1WNTqdd52Sg1N5UiEm/9a+QcELcy553jJSAG
         7lXOi0vBsA29SE+FFerE+SEWwzWOz+D0JWI23lp628UklsAq5QH1tx/FDP2Rt9l1Wdxf
         ww/RpKlB0OgYABuaqiRWaCZIQLpVWZLl42/hIu2WUI7Ko18WJbOMmkNXOG7pw3SkIZWT
         2zaw==
X-Gm-Message-State: APjAAAVCn83WAcTq786I5fl3El7ae5lw8JlZbCoKk/y8vJZJZTXd+pwc
	UaZYO0tbQtlbRU52ZLVy4SlBbHroPwelaUIz77TSLFYRa6a0tli7k2RBCnlXwJaFFUKLJH683Lb
	twKMfFP1UZfcLJlpN9y1vX+R5DRq5stlbATmbnrFROIBxjuSN4WfaUZzMAJ0600wPGQ==
X-Received: by 2002:a17:902:b68f:: with SMTP id c15mr41545509pls.104.1563344509731;
        Tue, 16 Jul 2019 23:21:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwukdMZd2+FkmvE7jaqVwwcxU6zTFqycu/eB9Hr+VyRMOkfCZflfwW+COjPpLzlYtplKq9g
X-Received: by 2002:a17:902:b68f:: with SMTP id c15mr41545461pls.104.1563344509089;
        Tue, 16 Jul 2019 23:21:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563344509; cv=none;
        d=google.com; s=arc-20160816;
        b=zkdncE5c5k7ZXi1sucFNDvDvhxRMSUOG24e9+iVf0cAt7uedOTuDKGCZYJODB1ToQy
         uwtIjIROspyZUOzgv+chMl+z8LN+OyWbE20ncR3DDSuMoZGyGdOn3vAl5Hzhg9EhWhIC
         bLJw7IceaKraocBfqOw37mPnpi2oWGT3+LR6OS5s7nuU1WVKIPWSXJMW5dS4Gg6gKmBL
         Yv91H0p9CWEZUVecSLLp26AwFcpsPnBybzewAQ4wtCVvKsgma/gte3rd7tG4v5ZRfvtH
         reWt+nHDvDX2dU6AUpVyKlysL+Gdou2GSAkE9r8nrSKj1w4l/l9buu8pvWvWss5C1XIP
         iH3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=8acWEJVKozUDgbpRsbTOTilbmLjq4nOryNdKnvI3qyI=;
        b=CNvBM4pE4To676mI0qpJOqP/4BrgNpFk7ltRzO8czXI+ZXZ66Xcsb0rLv7Z9p0VcoW
         vXwn5oLipJV1Eb1V8WlIzpqAENE/SMBTxoDP9iRAOQBrdadFTZL+2LrXV0gfmOpDVVDT
         g4KJSr/BlwuC3I/I08dVm5G4kHTkZk8K2XXe+jLY5ehlZSvcK7ufzKdI3MXI3oggwAcA
         agZy96LjOYehgDwRQGEEGHaF0B0GUXuK84Fjq6KD7CxUVFfQ76oV1w+GdXc2E3fXWDZV
         y4sxwGNX3G8q6dHil6mzHjhU4nN4UBhYWHRflUob9HCqS7cUSjNpTJr5zEXkorUPUFYq
         fv4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aWKQb3fH;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r14si23832199pfc.134.2019.07.16.23.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 23:21:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aWKQb3fH;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:References:Cc:To:From:
	Subject:Sender:Reply-To:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=8acWEJVKozUDgbpRsbTOTilbmLjq4nOryNdKnvI3qyI=; b=aWKQb3fHRk6FMee1FGDNwMLKe
	M4Nqa+LepSV7tm+3LRwMfSbx4YMi0yKJm++e0dwlPzvuu27wTU55lV/eOOee2V9w5Vp22S11zU+Fv
	eMfWoMv0NtG0DCNW/L6kHVbz6lV70XsOcbLToJCrwjYX6DcM7MQeUw75slz52UzQrL7e1rjxcFo71
	FW9uqsmTIxpBvyyI78MZqW93YZ9orfltYRCirJ60GcYxMc45MGbelUJeOeuEu/dDYvmrgHf3w90QH
	FZxAzZhM1jOBFIVXjMmm+BLRmYL4cBf+fQCT07AS8xT87dMHt9OeDHAsQUU2rZ2Nx4uW3c6Ubfv8U
	Ed+H3mQ3w==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=dragon.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hndK0-0007nf-Mj; Wed, 17 Jul 2019 06:21:48 +0000
Subject: Re: mmotm 2019-07-16-17-14 uploaded
From: Randy Dunlap <rdunlap@infradead.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190717001534.83sL1%akpm@linux-foundation.org>
 <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
 <20190717143830.7f7c3097@canb.auug.org.au>
 <a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
Message-ID: <072ca048-493c-a079-f931-17517663bc09@infradead.org>
Date: Tue, 16 Jul 2019 23:21:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <a9d0f937-ef61-1d25-f539-96a20b7f8037@infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 11:19 PM, Randy Dunlap wrote:
> On 7/16/19 9:38 PM, Stephen Rothwell wrote:
>> Hi Randy,
>>
>> On Tue, 16 Jul 2019 20:50:11 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:
>>>
>>> drivers/gpu/drm/amd/amdgpu/Kconfig contains this (from linux-next.patch):
>>>
>>> --- a/drivers/gpu/drm/amd/amdgpu/Kconfig~linux-next
>>> +++ a/drivers/gpu/drm/amd/amdgpu/Kconfig
>>> @@ -27,7 +27,12 @@ config DRM_AMDGPU_CIK
>>>  config DRM_AMDGPU_USERPTR
>>>  	bool "Always enable userptr write support"
>>>  	depends on DRM_AMDGPU
>>> +<<<<<<< HEAD
>>>  	depends on HMM_MIRROR
>>> +=======
>>> +	depends on ARCH_HAS_HMM
>>> +	select HMM_MIRROR
>>> +>>>>>>> linux-next/akpm-base  
>>>  	help
>>>  	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
>>>  	  isn't already selected to enabled full userptr support.
>>>
>>> which causes a lot of problems.
>>
>> Luckily, I don't apply that patch (I instead merge the actual
>> linux-next tree at that point) so this does not affect the linux-next
>> included version of mmotm.
>>
> 
> for the record:  drivers/gpio/Makefile:
> 
> <<<<<<< HEAD
> obj-$(CONFIG_GPIO_BD70528)              += gpio-bd70528.o
> =======
> obj-$(CONFIG_GPIO_BD70528)              += gpio-bd70528.o
>>>>>>>> linux-next/akpm-base
> 
> 
> 

drivers/dma-buf/dma-buf.c:
<<<<<<< HEAD
=======
#include <linux/pseudo_fs.h>
>>>>>>> linux-next/akpm-base



-- 
~Randy

