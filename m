Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34294C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:37:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7CAC21852
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:37:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7CAC21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 118F76B0269; Fri,  5 Apr 2019 09:37:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C94E6B026A; Fri,  5 Apr 2019 09:37:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAD186B026B; Fri,  5 Apr 2019 09:37:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AEFB6B0269
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:37:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so3267296edd.6
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:37:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=q8jZOJzUjh4xecTG5NW/zbVw8iQgo/hsoO//hEdsacU=;
        b=GIRWSrXdTdhFMnvISbnvcsZk4dSvg1L0SHnyxN4MXXdrL34sX24lOvh5RKRfxmQqhI
         96YCJ4+LYT8CqGB4Mk9KJET6OPrQa8ycGJb7DQNgXFuUrqt7+jQJE6ItaLbD6RVgVFwp
         lBsC/yI8Ib/uMQApBHPGjwMRAOIN0tW6pEyUOqnIO+fWAmYYDglPF05tXIhXreMlvxEi
         dB0D9ZYcl885k4WidvtJ/9AX7yapTOqfwthhRPJAaVrgdhO+s9DNqiLt2QKWZH+wMBHQ
         unLXEUxp2YsyBC6bIeQQnfqaZjltS/RLpohWC0rDi/gbJpj7fh/zPlZm+W4DTRX4cHo2
         YhPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAUo2bjXioL0kt14qQwOVNWIJDk94upVV3AJEJ1ediNy/DMnGgqS
	SFwSr0y3CxkzLrHrqjTwVDKWeK9tVMUjoBVdXrMIwFYhyuO+nswpPPtX4ovEOrzpcILQc9kGn86
	ln4lB9iCpvTb0LwJ22sUnpqzP1REGPcgjulss56HKJypAttrrqw7vfQQqOgGHOPI0xw==
X-Received: by 2002:a50:b4e2:: with SMTP id x31mr8023940edd.210.1554471447189;
        Fri, 05 Apr 2019 06:37:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxctkcW5WraToCRVQLRGwqfw/0ca9e8495QVCQe77u8nuG1kpUi7RJL8zO8TWW7WyweL3lL
X-Received: by 2002:a50:b4e2:: with SMTP id x31mr8023873edd.210.1554471446046;
        Fri, 05 Apr 2019 06:37:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554471446; cv=none;
        d=google.com; s=arc-20160816;
        b=YpYMfQPYEmcWmE0Iqhlymj/8YJq5JroNz3CyR1Wj5rDoBChcbZ8bAMOEUHqhsZDUbE
         roagrtpMvPj9IjzNAYopbHt3g7sPF7ntEU6+RRkBvDA4O0+bkLsQgxS2El2v3/jb2PA0
         NfByTaTPV8K+FQ7/oxJYAliFOpsBS0+pvt1sWDHpaPcrpwMhfikRvh2ykvRmgGIjnOsk
         fS5wSdxGBEMGIDQ2TXQGJjXUyKgTJxU6a9qV0HhnmmhuVlRPDQBF8RaGG2RmWDsxa4jD
         wTrJX6AkjgPdR0dEvsvLK9chhSmsvlch53W2+Cb4VHLFJpAmn6lFkOaHYGbKVpcMD2QS
         jUkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=q8jZOJzUjh4xecTG5NW/zbVw8iQgo/hsoO//hEdsacU=;
        b=QPfMZrqQQdsT6BHcAsBUOpz/ztcfs3HSBDKS6UZLTtZyjqMjMitLyWmCluizu75a/E
         HZM1IwKw0jzUHWodq5IWQfslGewTiUIfwlR9ACN2+gQnJyjqDXgUG/d0zFcP2NDLoiFO
         Bh8AvcE/gKeLEA1y6OQcbK+MNTQubw1RSkWLBI19TxNEIOG4ifON95E93VqK7JcC8I98
         TD2Q6IFLGJL/yI3sBWyvSbusnZmmF4SWoskpeXsMIxni9meoJA0VF39ZI611DeNen3+g
         XyV+AKaNwfEXI7ABeWY6lDQtaMf9ehAmCyZRzfXOCoIPnuwftX+Av+TWOIJvQlLmRe+0
         cDcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c55si5515893edb.180.2019.04.05.06.37.25
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 06:37:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 49C0416A3;
	Fri,  5 Apr 2019 06:37:24 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 158383F68F;
	Fri,  5 Apr 2019 06:37:22 -0700 (PDT)
Subject: Re: struct dev_pagemap corruption
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Will Deacon <will.deacon@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <5b18e1c2-4ec5-8c61-a658-fb91996b95d0@arm.com>
Date: Fri, 5 Apr 2019 14:37:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/04/2019 05:40, Anshuman Khandual wrote:
> Hello,
> 
> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
> unmapping path through device_destroy(). Its device memory range end address
> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
> should retain it's values during the unmapping path as well. Is this assumption
> right ?
> 
> [   62.779412] Call trace:
> [   62.779808]  dump_backtrace+0x0/0x118
> [   62.780460]  show_stack+0x14/0x20
> [   62.781204]  dump_stack+0xa8/0xcc
> [   62.781941]  devm_memremap_pages_release+0x24/0x1d8
> [   62.783021]  devm_action_release+0x10/0x18
> [   62.783911]  release_nodes+0x1b0/0x220
> [   62.784732]  devres_release_all+0x34/0x50
> [   62.785623]  device_release+0x24/0x90
> [   62.786454]  kobject_put+0x74/0xe8
> [   62.787214]  device_destroy+0x48/0x58
> [   62.788041]  zone_device_public_altmap_init+0x404/0x42c [zone_device_public_altmap]
> [   62.789675]  do_one_initcall+0x74/0x190
> [   62.790528]  do_init_module+0x50/0x1c0
> [   62.791346]  load_module+0x1be4/0x2140
> [   62.792192]  __se_sys_finit_module+0xb8/0xc8
> [   62.793128]  __arm64_sys_finit_module+0x18/0x20
> [   62.794128]  el0_svc_handler+0x88/0x100
> [   62.794989]  el0_svc+0x8/0xc
> 
> The problem can be traced down here.
> 
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index e038e2b3b7ea..2a410c88c596 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -33,7 +33,7 @@ struct devres {
>           * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>           * buffer alignment as if it was allocated by plain kmalloc().
>           */
> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>   };
> 
> On arm64 ARCH_KMALLOC_MINALIGN -> ARCH_DMA_MINALIGN -> 128
> 
> dev_pagemap being added:
> 
> #define ZONE_DEVICE_PHYS_START 0x680000000UL
> #define ZONE_DEVICE_PHYS_END   0x6BFFFFFFFUL
> #define ALTMAP_FREE 4096
> #define ALTMAP_RESV 1024
> 
> 	pgmap->type = MEMORY_DEVICE_PUBLIC;

Given that what seems to ultimately get corrupted is the memory pointed 
to by pgmap here, how is *that* being allocated?

Robin.

> 	pgmap->res.start = ZONE_DEVICE_PHYS_START;
> 	pgmap->res.end = ZONE_DEVICE_PHYS_END;
> 	pgmap->ref = ref;
> 	pgmap->kill = zone_device_percpu_kill;
> 	pgmap->dev = dev;
> 
> 	memset(&pgmap->altmap, 0, sizeof(struct vmem_altmap));
> 	pgmap->altmap.free = ALTMAP_FREE;
> 	pgmap->altmap.alloc = 0;
> 	pgmap->altmap.align = 0;
> 	pgmap->altmap_valid = 1;
> 
> 	tmp = (unsigned long *)&pgmap->altmap.base_pfn;
> 	tmp1 = (unsigned long *)&pgmap->altmap.reserve;
> 
> 	*tmp = pgmap->res.start >> PAGE_SHIFT;
> 	*tmp1 = ALTMAP_RESV;
> 
> With the patch:
> 
> [   53.027865] XXX: zone_device_public_altmap_init pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
> [   53.029840] XXX: devm_memremap_pages_release pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
> 
> Without the patch:
> 
> [   34.326066] XXX: zone_device_public_altmap_init pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 6bfffffff size 40000000
> [   34.328063] XXX: devm_memremap_pages_release pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 0 size fffffff980000001
> 
> Though this prevents the above corruption I wonder what was causing it in the
> first place and how we can address the problem.
> 
> - Anshuman
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

