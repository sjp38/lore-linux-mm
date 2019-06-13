Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C1BEC31E49
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:13:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1608020B7C
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 20:13:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="OSBqGRX5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1608020B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3B06B000A; Thu, 13 Jun 2019 16:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2DA46B000C; Thu, 13 Jun 2019 16:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91C088E0002; Thu, 13 Jun 2019 16:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 618086B000A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:13:53 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id n20so47533otl.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DdSbzBj3GN9lmFE97uLhhDp9bhFpPD/Ri2wBNX09PfQ=;
        b=tqS8yBP2DtWgwUk/gVkGBve4bQi8OMPfnYmNqSa+7Q45xByY7taIZlH19097PXY/2e
         ueoXO8Sau6JgMiTV64NDCkIdnPA2jl/LfQ1BzgZj20zeQYHzMqE7qzBbOFbvyhbQIHUU
         9eTyCcuzW36+tUYsRx9U3V8tWR0pT8+nfBAA7qaYbwsWci6GxrJRjNfg1yArSXli9d4B
         01bXb9fpcl/NTYZdoDu2gJERvfR00ffH4xavwJUynn6N3a0zfQIxT065CrDlKa/7vNAq
         VlEDn5pWs8srsSKWpVBrZIHPjBPi2MyYf/4fq1K2bbkFlVodKCqbouzJOnUWFYU2cqz2
         z06Q==
X-Gm-Message-State: APjAAAXqVnqdq63dTiFnLTtVHzua/NdXSXrlwupkGiHANer2ZxgDMaK1
	YWx+ktX0fY2/zew9o1ruCz28+penrT4UEXmUBjR+qKLIg/1AmZ4wpeXjtMBqfJKr9Cwm/2EsCpP
	+v3Rk526Yt3+yBbSet9lNnwup8dpERi/tOkvbX/TsEp7/gSmrbemmxKw4GaPheMqE3Q==
X-Received: by 2002:a9d:7d16:: with SMTP id v22mr37995062otn.124.1560456833031;
        Thu, 13 Jun 2019 13:13:53 -0700 (PDT)
X-Received: by 2002:a9d:7d16:: with SMTP id v22mr37995025otn.124.1560456832490;
        Thu, 13 Jun 2019 13:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560456832; cv=none;
        d=google.com; s=arc-20160816;
        b=V3ObxDypyR7/Qcl3T+lMFM+KUkg0RzzhMhBJgJKDqTzm/Hi9U6n3CoCbfm5Dt70C7s
         iRQ8aN1TNSwLQgSvgBlfSe7KQpC6zgIzjYkG4e9KRGHJhZLId+cuGxbaGTteA9gp3yGB
         qCLxZNWFxUqENgY+puc62gk6GSKTuJlUMNRKQkKaysG7lt4O/PA1m3bzdfTIVtPpmr6r
         wnr0VCIZZHNJ6QGKJJ12xXS/OdkYr56OauPWeyN4+c+sL5y/4aD4X4KVB7BjjYbqcGN5
         dPhseb8n5vfqor60ZJKgTPHpetnHkvqR9hCHxfI9zAvOy/1Ky8saQDdn3MO7ftiGdyO1
         MWNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DdSbzBj3GN9lmFE97uLhhDp9bhFpPD/Ri2wBNX09PfQ=;
        b=PJqF2jJh3acUeCYRrZF4gAh8j3KlwRixpeFeWYJFj5uio2osmmbNtiU1D1qPx3IxTd
         9DvhB3yhEbIvq/hUCgEw0Hi8omDnWPZLKlZgj4bXgGgAfVFXVEQJ8T4TJLcKs+CDfzUZ
         Um99sBlxpVLDAAhPegcfNuldhSAMUsmU+K6JDU37d7p026cyud9pAdsFfRO4hJ51Xsea
         706kRIaWTzvtukXaFWO4W0KSPiZfLGuoMzU/Xp8CtoxzIkoDuoFeOzGXdl6YaImZ6Cmc
         zjaHNVv/yjMAy8iDVrZ1uUINz3CRoaV4On7GPG8m83eKE3OzziVRIrXUnx+lt71b9It3
         fPaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=OSBqGRX5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p10sor519321oto.46.2019.06.13.13.13.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 13:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=OSBqGRX5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DdSbzBj3GN9lmFE97uLhhDp9bhFpPD/Ri2wBNX09PfQ=;
        b=OSBqGRX5/KZ8rtnYLy8/+VzWXJoy8dOkJHihIoyUXY2eP7FoiV7nziOVkOw4+nZKoB
         8BX3vQfUbWi26DrxuPJOZQTkwLvG8bcvI5bR3K46S8XaTPV6uYDB19u7pEoWDIMGVXIT
         76Gat4HdmnE0UfZtW6tDnTRkZMx/UjOMIIhYc/M0re4EVEJMI//Xgzy79OcW2RngZAFY
         Ex/a+k84aj46psorP2SyODhm0RWUknVG0v09x5bcP8Nl31V8edNccp6WpICo1yfvAEqk
         4PlHWylrgwZOgDTADWj7FVO4iX7LA9uouJaVlZvN2+vo54OtBLhCAxLVmuocFehTb/fy
         IX0Q==
X-Google-Smtp-Source: APXvYqykaGayuOdeZmPun6lqMah28WqyaWO5bFenPtOzBFg0qXVTvO/T6gfkniMpvZVUXEcVxeJc+t1pW1I4QrwLh2Q=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr37784514otn.71.1560456832159;
 Thu, 13 Jun 2019 13:13:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-10-hch@lst.de>
 <20190613193427.GU22062@mellanox.com>
In-Reply-To: <20190613193427.GU22062@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 13:13:41 -0700
Message-ID: <CAPcyv4iwVPm2XBviR8E32VJG+ZZTHZLGxDdXS3et22CTT_3qNA@mail.gmail.com>
Subject: Re: [PATCH 09/22] memremap: lift the devmap_enable manipulation into devm_memremap_pages
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 12:35 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Thu, Jun 13, 2019 at 11:43:12AM +0200, Christoph Hellwig wrote:
> > Just check if there is a ->page_free operation set and take care of the
> > static key enable, as well as the put using device managed resources.
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index c76a1b5defda..6dc769feb2e1 100644
> > +++ b/mm/hmm.c
> > @@ -1378,8 +1378,6 @@ struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
> >       void *result;
> >       int ret;
> >
> > -     dev_pagemap_get_ops();
> > -
>
> Where was the matching dev_pagemap_put_ops() for this hmm case? This
> is a bug fix too?
>

It never existed. HMM turned on the facility and made everyone's
put_page() operations slower regardless of whether HMM was in active
use.

> The nouveau driver is the only one to actually call this hmm function
> and it does it as part of a probe function.
>
> Seems reasonable, however, in the unlikely event that it fails to init
> 'dmem' the driver will retain a dev_pagemap_get_ops until it unloads.
> This imbalance doesn't seem worth worrying about.

Right, unless/until the overhead of checking for put_page() callbacks
starts to hurt leaving pagemap_ops tied to lifetime of the driver load
seems acceptable because who unbinds their GPU device at runtime? On
the other hand it was simple enough for the pmem driver to drop the
reference each time a device was unbound just to close the loop.

>
> Reviewed-by: Christoph Hellwig <hch@lst.de>

...minor typo.

