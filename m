Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F57C10F0F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:42:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C2402186A
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 13:42:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C2402186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D24036B026B; Fri,  5 Apr 2019 09:42:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD3666B026C; Fri,  5 Apr 2019 09:42:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9ABA6B026D; Fri,  5 Apr 2019 09:42:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA436B026B
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 09:42:17 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p88so3220184edd.17
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 06:42:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nOVLKPMhicrsHVuH11A/ri87i3/+82LxV/U8vx9I0rM=;
        b=qwiMhWqO/rT6cQ63aTy95MlP1fgzPAjNTaiqtM2YNOrB2/cIqG66Vs4PzASWPn9tgi
         r88YuR/NHhj1yk81BKTVCx1AlpOZZlu4gzvmAESS9WuxPUz+0BiXUdKu9+gCJxuTr6Ln
         1MAq7m2MIOOmI74CDuBxipwh7z5mablYVvyYfu/fZ0hpi4dprK9fsOPFOWXiYa025r2P
         3iBO8XmR1aqxqLWlBMAgXs2JkyMJUwJK6b37N06MShj9Id6Ppal6B+vaV2ABmqsJ8ipQ
         sQUqQqZ+F/2B4AmX/v03zTnuG48FSkyqOyGcf94715hba4yfI+mJQeDGFdSyh+YfVQsS
         hzXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWj0XcqHrMYLpxLX4XE/Stxq4+JdsJKRL9oOpojyrPYyp+JoiOy
	N9lsJMGgOoBnMBlUWd28y0Ar1NvV7VK3JyUbuE1FX8gpieXfnpVOXhZ3PF7ZXRnw+8dSBfxnE7E
	bVTjSir+rRYPTlbAo9rj3XPQjQWN2XQ4ji1PvS7NahqLziMIrWy4RjRWsfMqXUHtbQw==
X-Received: by 2002:a17:906:90d3:: with SMTP id v19mr7386498ejw.268.1554471736964;
        Fri, 05 Apr 2019 06:42:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIUc2hpD3prxb9BVlmxsAZzGQ4e3HQNFlzNaJgSchfpQzf08G7KBGMh+DZL/8f3Prp3zi4
X-Received: by 2002:a17:906:90d3:: with SMTP id v19mr7386466ejw.268.1554471736136;
        Fri, 05 Apr 2019 06:42:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554471736; cv=none;
        d=google.com; s=arc-20160816;
        b=vflYqr/AwEATCjpquSoysSro8YLVymaNHje5ZmWH6y3Jxw4QQg4JE7xOJI4w38FaKh
         ztK/CxME0vUGwlUDnlSzzCqcOIPnyhl0hSqDaLCql3LQqxclZtF5SfG22Pj9vK7N9uso
         ki+IyjlnDZQxOJurYN9kuIagd8KFqGXIXQ7NHshx/MhL/20+iG9Joi7QfR2emEXFotaY
         O00ypxMeNv26wbrMClF1BDaj+Jt8d06BS9HfZrX32tK8EZoX59eEgaIWgEo1pAqp86RP
         gqXzeFLsB5PjnGFwf3SEAc1Qu9vvp00URMj2n6HXRhBtT9kPtmVeEpl1XBinqo6Z6fPJ
         gR4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nOVLKPMhicrsHVuH11A/ri87i3/+82LxV/U8vx9I0rM=;
        b=BYTb0ozSQIvCu1NNK9XCs90BWI66HEExlb6zZ5+bfltfBV9t9o3vAunj+Lja41Lc64
         iZ1QADZuU4xXS7I2Or2tF24rSE0tUksKsr93XrDouPO63JW8mP41ALbStpJIzb2SbN3C
         Gw034x95ncfAWdba6CxWmfIIn2vS0d1BtciQLPx4zwBP/Wcep1TywGIyjyBgvH77FyVz
         PJbEnEvq1ki+eU5aXcS0sa2jcZ2O6XTwVWnM6offYO3R6w3FiaIUS1/+I2tzNQdGwaX2
         6sWuHjA+ujcPsaxpXVSLmmL22nnTHb+dLJwtL/GnnCfISx6DWjVjXJVRxxvA12ZJ+7QV
         c4Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e6si5969486ejb.264.2019.04.05.06.42.15
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 06:42:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id F280B16A3;
	Fri,  5 Apr 2019 06:42:14 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BD70B3F68F;
	Fri,  5 Apr 2019 06:42:13 -0700 (PDT)
Date: Fri, 5 Apr 2019 14:42:11 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Will Deacon <will.deacon@arm.com>
Subject: Re: struct dev_pagemap corruption
Message-ID: <20190405134210.GH4906@arrakis.emea.arm.com>
References: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7885dce0-edbe-db04-b5ec-bd271c9a0612@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Fri, Apr 05, 2019 at 10:10:22AM +0530, Anshuman Khandual wrote:
> On arm64 platform "struct dev_pagemap" is getting corrupted during ZONE_DEVICE
> unmapping path through device_destroy(). Its device memory range end address
> (pgmap->res.end) which is getting corrupted in this particular case. AFAICS
> pgmap which gets initialized by the driver and mapped with devm_memremap_pages()
> should retain it's values during the unmapping path as well. Is this assumption
> right ?
[...]
> The problem can be traced down here.
> 
> diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> index e038e2b3b7ea..2a410c88c596 100644
> --- a/drivers/base/devres.c
> +++ b/drivers/base/devres.c
> @@ -33,7 +33,7 @@ struct devres {
>          * Thus we use ARCH_KMALLOC_MINALIGN here and get exactly the same
>          * buffer alignment as if it was allocated by plain kmalloc().
>          */
> -       u8 __aligned(ARCH_KMALLOC_MINALIGN) data[];
> +       u8 __aligned(__alignof__(unsigned long long)) data[];
>  };
[...]
> With the patch:
> 
> [   53.027865] XXX: zone_device_public_altmap_init pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
> [   53.029840] XXX: devm_memremap_pages_release pgmap ffff8005de634218 resource ffff8005de634250 res->start 680000000 res->end 6bfffffff size 40000000
> 
> Without the patch:
> 
> [   34.326066] XXX: zone_device_public_altmap_init pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 6bfffffff size 40000000
> [   34.328063] XXX: devm_memremap_pages_release pgmap ffff8005de530a80 resource ffff8005de530ab8 res->start 680000000 res->end 0 size fffffff980000001

OK, so without this patch pgmap->res.end becomes 0 while it should stay
at 0x6bfffffff. Is it easy to reproduce with mainline?

What's zone_device_public_altmap_init? I couldn't grep it in mainline.
How's the pgmap allocated?

I'd suggest you enable kasan and see if it spots anything.

-- 
Catalin

