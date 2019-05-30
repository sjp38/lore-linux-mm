Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E887C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:31:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AF7E25CB6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 15:31:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AF7E25CB6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A93A46B0270; Thu, 30 May 2019 11:31:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A445F6B0272; Thu, 30 May 2019 11:31:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 933716B0273; Thu, 30 May 2019 11:31:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A93D6B0270
	for <linux-mm@kvack.org>; Thu, 30 May 2019 11:31:23 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e3so2984603otk.1
        for <linux-mm@kvack.org>; Thu, 30 May 2019 08:31:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding;
        bh=dbDV6bc1zJz4CRu5/vu+qvrcU3EI0H2cWCtFXW0Tezg=;
        b=NjfYvLir/ALqZDP6mmtnWsXE/cZUeuWUcQURMZwzLqs+TYyeWegxIN65bbfJWTHuCf
         Z91t/5noWCUyz8snGlZKQz794lP5aSrIdAQDD5xZDwbmK2m8o7k38WONGCiyT8SL8j0H
         TdXk9sqfrRgazalcWk9H1INrRoGQIoikSGNnYmYIzufPlYISjR0HYVln8eA6JNfjusIg
         VoDNBfY5nzJlaQro/czWz3VOmiil7cxGoTbpXo5B0grC5eVbwykahdo3WFckcatK8iVd
         XBFxxkmsIuf/jGPXfUyk8G8zOCFP77/b4U8e0YMq1IZnrUP9/r9BICEGBU9t0Lr6AWVj
         GCOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
X-Gm-Message-State: APjAAAWZ8wafEmocTv0KcYsoaI1wolOpqV55iVk/RWYVosu6qljWbZ/m
	1GDwudVRMfJKPdUnFnHRH+8WY6GQKqEyOPtA1IzhWFuT/1HfNZfHLt2ki1CW06No1BiVd11G2r+
	8TUbjEe5WeCOOGZV4u3NQzrW5MnmIEkcIf1dhRUYXshXuo5qLGJse2ttxT4VqTAKoLQ==
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr3060473ota.145.1559230283098;
        Thu, 30 May 2019 08:31:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkOVtmQFDkm+TM1jNP0Cb37gCurSl9GGY8pJ/bbK0MW9grRV8It5/1R4DT9nfiDlQK4oHU
X-Received: by 2002:a05:6830:199:: with SMTP id q25mr3060397ota.145.1559230281969;
        Thu, 30 May 2019 08:31:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559230281; cv=none;
        d=google.com; s=arc-20160816;
        b=PvObj8/8TZMD+Mh4ZUEWKLqmmG6K64+Cur52VSUejJFeRBqYoUFDnE/opxjkpnCLH+
         4DZwaF3GLoUAcONfdZEo1mF47Wam/4OMKl0oEXDiQY1U8cT1nCnp1bnSfvGLX78cGfC3
         9KShXFFFbwQz8F67NmqxLwOMPcYE2a6o+x6Jg3F9PkXZKwrdluvsKYA7noTAM+dG/UWX
         VLUfLORyA97cUEvwie+m4UTiODvy3rPlkIehsVDoAHHdtGJIOVqu1OINLrtTOjtUComy
         xGyJBKNMREh/gcmbZ2k5wwbXy++grUwyKZMKwWPTwFqQIOHYkuiC7pB8nP7PWC2h8gvr
         P/vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject;
        bh=dbDV6bc1zJz4CRu5/vu+qvrcU3EI0H2cWCtFXW0Tezg=;
        b=Gz+IRJdPK5HJDDanM7Nu4wqI7Ll6gshrPTI41cY+BTTz80UHddZZ65xgZB4Cz1S6Tk
         v2ilWS1zW7LcnmhuUxim+nKDvJRrStKqzih3tlYwwh0k4RlhclgTBJiQa7gOl8O7EZR7
         KTP65cwDN4L6w7b08L46/IalMnCVJnYrnNJKIuho1f9+cE3aWRU0/FMpAS52tpd7rGFZ
         uFFAwWRrWGfEUYovuxEfJ/4oY7orp5c3k8UOTTgry23VNpiMiEjo95IsWLreO41ID4/u
         ntnORE9W9ke85pJ/+g0rdp7rKNP5LznWhV0dlekmpg/rc6QQiEoeKlb9ztQ3IoT2lAc8
         6J7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id e60si1700881otb.293.2019.05.30.08.31.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 08:31:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yuehaibing@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=yuehaibing@huawei.com
Received: from DGGEMS414-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 780E2B06B6B9790FDA8F;
	Thu, 30 May 2019 23:31:16 +0800 (CST)
Received: from [127.0.0.1] (10.133.213.239) by DGGEMS414-HUB.china.huawei.com
 (10.3.19.214) with Microsoft SMTP Server id 14.3.439.0; Thu, 30 May 2019
 23:31:14 +0800
Subject: Re: [PATCH] drm/nouveau: Fix DEVICE_PRIVATE dependencies
To: <bskeggs@redhat.com>, <airlied@linux.ie>, <daniel@ffwll.ch>,
	<jglisse@redhat.com>, <jgg@mellanox.com>, <rcampbell@nvidia.com>,
	<leonro@mellanox.com>, <akpm@linux-foundation.org>, <sfr@canb.auug.org.au>,
	<gregkh@linuxfoundation.org>, <b.zolnierkie@samsung.com>
References: <20190417142632.12992-1-yuehaibing@huawei.com>
CC: <linux-kernel@vger.kernel.org>, <nouveau@lists.freedesktop.org>,
	<dri-devel@lists.freedesktop.org>, <linux-mm@kvack.org>
From: Yuehaibing <yuehaibing@huawei.com>
Message-ID: <583de550-d816-f619-d402-688c87c86fe3@huawei.com>
Date: Thu, 30 May 2019 23:31:12 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:45.0) Gecko/20100101
 Thunderbird/45.2.0
MIME-Version: 1.0
In-Reply-To: <20190417142632.12992-1-yuehaibing@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.133.213.239]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Friendly ping:

Who can take this?

On 2019/4/17 22:26, Yue Haibing wrote:
> From: YueHaibing <yuehaibing@huawei.com>
> 
> During randconfig builds, I occasionally run into an invalid configuration
> 
> WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
>   Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
>   Selected by [y]:
>   - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=y] && STAGING [=y]
> 
> mm/memory.o: In function `do_swap_page':
> memory.c:(.text+0x2754): undefined reference to `device_private_entry_fault'
> 
> commit 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
> split CONFIG_DEVICE_PRIVATE dependencies from
> ARCH_HAS_HMM to ARCH_HAS_HMM_DEVICE and ZONE_DEVICE,
> so enable DRM_NOUVEAU_SVM will trigger this warning,
> cause building failed.
> 
> Reported-by: Hulk Robot <hulkci@huawei.com>
> Fixes: 5da25090ab04 ("mm/hmm: kconfig split HMM address space mirroring from device memory")
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>
> ---
>  drivers/gpu/drm/nouveau/Kconfig | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/Kconfig b/drivers/gpu/drm/nouveau/Kconfig
> index 00cd9ab..99e30c1 100644
> --- a/drivers/gpu/drm/nouveau/Kconfig
> +++ b/drivers/gpu/drm/nouveau/Kconfig
> @@ -74,7 +74,8 @@ config DRM_NOUVEAU_BACKLIGHT
>  
>  config DRM_NOUVEAU_SVM
>  	bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
> -	depends on ARCH_HAS_HMM
> +	depends on ARCH_HAS_HMM_DEVICE
> +	depends on ZONE_DEVICE
>  	depends on DRM_NOUVEAU
>  	depends on STAGING
>  	select HMM_MIRROR
> 

