Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E07AC46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:25:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0031C2085A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:25:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="zsU6x4/n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0031C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E37A8E0004; Mon, 17 Jun 2019 15:25:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 692FE8E0001; Mon, 17 Jun 2019 15:25:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55A428E0004; Mon, 17 Jun 2019 15:25:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4DB8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:25:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id q16so1013080otn.11
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:25:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HNxPoXz08Bkv6XLKAsIWbiHb1gnesryRGgT+tAFHLoc=;
        b=aATPM0ORh824nZL41g/rJB23/FmusDEdkmLUXvnbcV2AXT1ggzegngfC4ufJq45wy7
         Nc08d8GCmVx0lHHmU+6Nfv4CR+CRUZMRkqjFg4Zl4Nrpw8Yd8PgfnO87Hi2UtBKA/GrR
         5a3zu9t3EGktPG0hqWLK6AXJ8jv6x0sczJfLgFGLLgVwOiCLQ6me5E1B8/R8jFOGdANS
         Lhn00rOQFY8ACrYJUuqEkVXPKPKJMm0C3sjSRpq417YUfLetofFiHII4SVDOXuCAXJAC
         KOI80pX+33AR9w2kvxjfy5Zfii4c5ViokHSyX3s9EkD+P9v/yDIWYkoHyYUy2zNyoYV2
         sUNw==
X-Gm-Message-State: APjAAAU5TTfLgbiLik5LfkY94+IJX4GdoCDMVAyghxww7ju88W8l7Fej
	5nr97AAfUkdTYQcgB1d1cFXD+5PSEcFpxu3hP056umURWs1k2MDBeIaHtvU2ULwGu22b+EZ1H3k
	5ZvRvmwkDffSMk5HWZQILDqb+kKd5CGNF9DxQOW8DmDyswbUTF6lH8CocxbFrKhN2nw==
X-Received: by 2002:a9d:6548:: with SMTP id q8mr35438570otl.132.1560799529855;
        Mon, 17 Jun 2019 12:25:29 -0700 (PDT)
X-Received: by 2002:a9d:6548:: with SMTP id q8mr35438518otl.132.1560799529173;
        Mon, 17 Jun 2019 12:25:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560799529; cv=none;
        d=google.com; s=arc-20160816;
        b=xFLWdM/95HpkYYlyi2RiRSvceDOAARQjBZB7p7qthzWOaviIsesFaYhgdPJU9rJXME
         3ntpIea45zOTC/UxG/W08P8mPG8BkKY3PbAo7Y1nT8fRBoUnrtHPJhCf6i1pm9g0Qgc6
         HrPWGwH6mZdIJDd/tc/JSmwLoOLk4axclvAyIpbKMaSAm7mHj9QOiTHzdSe0KmOMiukO
         J3Gl/rw9RnYkevJkKp9rYSNkYwILyY4OP1Yea+I6y0QBOFU0pXPTk9c38DBYkSzbwq+b
         Z3zy21KqB+Jw0KgpCyDMNDQALdLmH/I/Hp+uOWgA0k0D8T4GxvLxSC2euTfjQna0aS0B
         AcmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HNxPoXz08Bkv6XLKAsIWbiHb1gnesryRGgT+tAFHLoc=;
        b=qJuI9TIhadtA7KtHIp0o9WAItbgQ6mb66LiM44xlw+Y4W7BPGg9AU57FR6v/aYcPpW
         wUkCl+942e6WCXZUgl7jBGtTqUYfTov5aZlwhmUq+soKpiyIFARPQUuVjz0Hjfxmxm+l
         5XW+Vwwgdbi+vB2SB3In7xioBhhMSKCw4iHh4iue639yaongA8ZKUQWUk8l7ow/zWbF9
         lEhbRXL+8ijnjRV+OZ1Ek7GJlrVldVc6YHXQ3+SOUuKrirY/0DYCQ7BenKYtQhajPAFc
         KRBKopDFXFoyorHvz0WlAA9LvTiSMFJw+iHzBB4tfx4Dhj4YjVrbGbPs5y794OhzzvtU
         h65Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="zsU6x4/n";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e17sor44496otf.139.2019.06.17.12.25.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 12:25:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="zsU6x4/n";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HNxPoXz08Bkv6XLKAsIWbiHb1gnesryRGgT+tAFHLoc=;
        b=zsU6x4/n004yGk33kbKQd/6ii5ctCApqWKr2xXu2QHfi+ncPf+6aOer/hnDk2UAkcB
         jGunUn0he2nTR0uU2859WbUUtlv6pvLc41AXK2T6AWHriY76vgq0YRD//La6/nHXzo1Z
         YPIa/GBGOk0VXAfuIX+0DmRt+mlbZWG/S7zDJ2J1W8prL2gnJon9QkcM3fcOMMdwSo4e
         4OrGQSbgcfUmMeefb3e2ZPd0f7T54UdNfjjuNpUJ/GMYEaMNtkVI6YVgubTvq1/bIgZo
         qVrNws/T9AqY75DGEixSkuSqStvevZuszwTUzd/rSGi9BdsaPARyVCoYryGFhOd3HmF5
         Pgcg==
X-Google-Smtp-Source: APXvYqyQusXzMIvOnOSDlzozCSKeY3iIGkQ0PmM8jIAxg1c9m+Lhh4LXmnIB3y6iM6i/y/0k5RVphJmN2SXJiVLtpbU=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr55333952otn.247.1560799528939;
 Mon, 17 Jun 2019 12:25:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-11-hch@lst.de>
In-Reply-To: <20190617122733.22432-11-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 12:25:17 -0700
Message-ID: <CAPcyv4jtZSK7bgQX_Sm1E-Thqmyhs30SrZKoSApjghRLL12Ngg@mail.gmail.com>
Subject: Re: [PATCH 10/25] memremap: lift the devmap_enable manipulation into devm_memremap_pages
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 5:28 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Just check if there is a ->page_free operation set and take care of the
> static key enable, as well as the put using device managed resources.
> Also check that a ->page_free is provided for the pgmaps types that
> require it, and check for a valid type as well while we are at it.
>
> Note that this also fixes the fact that hmm never called
> dev_pagemap_put_ops and thus would leave the slow path enabled forever,
> even after a device driver unload or disable.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/nvdimm/pmem.c | 23 +++--------------
>  include/linux/mm.h    | 10 --------
>  kernel/memremap.c     | 57 ++++++++++++++++++++++++++-----------------
>  mm/hmm.c              |  2 --
>  4 files changed, 39 insertions(+), 53 deletions(-)
>
[..]
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index ba7156bd52d1..7272027fbdd7 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
[..]
> @@ -190,6 +219,12 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>                 return ERR_PTR(-EINVAL);
>         }
>
> +       if (pgmap->type != MEMORY_DEVICE_PCI_P2PDMA) {

Once we have MEMORY_DEVICE_DEVDAX then this check needs to be fixed up
to skip that case as well, otherwise:

 Missing page_free method
 WARNING: CPU: 19 PID: 1518 at kernel/memremap.c:33
devm_memremap_pages+0x745/0x7d0
 RIP: 0010:devm_memremap_pages+0x745/0x7d0
 Call Trace:
  dev_dax_probe+0xc6/0x1e0 [device_dax]
  really_probe+0xef/0x390
  ? driver_allows_async_probing+0x50/0x50
  driver_probe_device+0xb4/0x100

