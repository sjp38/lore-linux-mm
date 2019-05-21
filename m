Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B19CC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:54:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 315192173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:54:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="KmrwjgH5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 315192173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D35676B0003; Tue, 21 May 2019 12:54:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE6BD6B0006; Tue, 21 May 2019 12:54:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87166B0007; Tue, 21 May 2019 12:54:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD516B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:54:15 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v13so6318353oie.12
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:54:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oHyxxdCulthGGKCbcuDYU1DyzLMsf7EAoBxw15HJNqA=;
        b=A+c4HbnZ6SMICj03NXzaJwxKQJTqyIWMYula7JHWFcH2EPUQmitpqcHLN6l9f7dp8+
         xn1siFMMHIQPw89Mzsg7eWHSFcf6jnxeoo/dPRY4Zn63mkOb+/LtgJNJlle8HQ854Lma
         1jT78J67DJo1I+cpcbIfx6rWaqEHbByw8yJLlX0Kb9R9Vs3x+rTiMqUjuP5vF4xx9mPP
         8B38ny7agAoiPCgZ7JQktC7dr7m3tmv3KtpwXO7sKEeJizLXCTD6aAasFsUhPYXrnfkc
         /g7HkdtjTLYeH1m13ijJJwNkrBherCjjuE50fv/B7ZaQbLoYOzdeo7dDxU0umqkKZ1yI
         gS7A==
X-Gm-Message-State: APjAAAU9m+NWTuEqpavUF1G3jPMDz8MbaNDZG2ZizzzFGWgt1nKAYLNi
	/G7ZEIm+thPIwYKouUrBp9fCfVrMXAyHoitnROk3pu6D6ZlgSExd9oDFGC+6Zr5PiWZeVmsepsc
	7q9h7oHHm/zCfgqS42mfguWJs9PYIsbc1oe8Hw9jIfCCbkgYjmN8P/p6p5XHC9YrCBA==
X-Received: by 2002:a9d:7207:: with SMTP id u7mr20552699otj.339.1558457655147;
        Tue, 21 May 2019 09:54:15 -0700 (PDT)
X-Received: by 2002:a9d:7207:: with SMTP id u7mr20552671otj.339.1558457654501;
        Tue, 21 May 2019 09:54:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558457654; cv=none;
        d=google.com; s=arc-20160816;
        b=TKfFbE2UeQhDdaflhXLHNIhhv/GTUL+xH1FfoIuSerX2+QVbsYaESC/bc8kYVu7qph
         Vm/wSAGGest8f2g2/7G3wN8ZosWABVoj4G0r9DyXFrozP+5r32QUSSM7RZocjRxmNqz7
         xIbnSXccjyA4jZVlXZX8XACyiHa0kGNcPy2rV9Gqpes2K8/gZhOUPC1dg0xvGyKP4WIk
         mvrbyimRlMbV6WKfmBEu9By68BRXcFuQMg+3zee5rh0pbCDECgMnLIspD3xQ3QCoUcQS
         gFxXI26ObicZj4Xk+upM7tDU2mSTDOkISOPYYN4+9LlXa++K4DUf0cqDJ10uO43SX4pM
         G8fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oHyxxdCulthGGKCbcuDYU1DyzLMsf7EAoBxw15HJNqA=;
        b=b0A2PBup68gELd8ehfyV//fQXWyz/zQabNYpPOhZ1skViYCMj2IHGu7eXcc6/vAI3Z
         nemoF3Nc1L8tqnkh5IUwzj9ip2HddyJ/AnUeTpVyZsUh98U+3IXWWKYBDa+BR39YSDEW
         pxFAB0chY1Wd8f7J/Mv43VPmuFNEBno9eelLEnr2RzglyOee2nKZ+L4wUWoRefJ8yX3D
         t8fwq7YWlRz6THmLjZD9l16JeZ16/7IUlVI1jT1OHKX/UbH/Uxvspb9GZ92aiaYUAW0K
         nIArv9WbPjeLft9pBtgrfucOW2aFHiFlESWT52NYzEB8RY+I0U7RJ0zd3qxgKFIS4t/I
         /CFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KmrwjgH5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k19sor9834008otr.47.2019.05.21.09.54.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:54:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=KmrwjgH5;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oHyxxdCulthGGKCbcuDYU1DyzLMsf7EAoBxw15HJNqA=;
        b=KmrwjgH55rKUw5bqIvpvFnD07PXHH7SJsCt1oTLDYR+Ngbo95qTBMiDayK/T72vXZN
         Avx47DGuOuF1vapQph16LlsXG1juDYSt9PIzVC+ClWmLndroDTHzFUWCacgdagkgOfKB
         RZNUEEoUbhaWH5kvICIk9zR+I59+NAep489TP336aGQG6FqPf2MTL+jNJ2GMoHDKTGUR
         t3Xc4Wf6A+/2QtsYp3wdSbw8oTBXMmxpJA4v3cI7HA5pT9zYwL6ebm8BLJuLsAKMmYzZ
         qZQmGLZqAMLzcj0iPF8/V6TgDHh0HnEDyIlIpVTw/SlnvwzNv+at8W4uxA6DmyOMLZMe
         TRoQ==
X-Google-Smtp-Source: APXvYqwIKt/XH22CjB9xbefxXBJf+2suHAPutL2reWSQeS/hGSPLUhtpc4EiRbPj70y29pq/8uIl/yv2T9ANELNfFz0=
X-Received: by 2002:a9d:6e96:: with SMTP id a22mr3999902otr.207.1558457654221;
 Tue, 21 May 2019 09:54:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190517215438.6487-1-pasha.tatashin@soleen.com> <20190517215438.6487-4-pasha.tatashin@soleen.com>
In-Reply-To: <20190517215438.6487-4-pasha.tatashin@soleen.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 21 May 2019 09:54:03 -0700
Message-ID: <CAPcyv4iZ7sx6L+3yDKSXth6b+qdtCmVrLxmCvCuRAYBMbSM+Bw@mail.gmail.com>
Subject: Re: [v6 3/3] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 2:54 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> It is now allowed to use persistent memory like a regular RAM, but
> currently there is no way to remove this memory until machine is
> rebooted.
>
> This work expands the functionality to also allows hotremoving
> previously hotplugged persistent memory, and recover the device for use
> for other purposes.
>
> To hotremove persistent memory, the management software must first
> offline all memory blocks of dax region, and than unbind it from
> device-dax/kmem driver. So, operations should look like this:
>
> echo offline > /sys/devices/system/memory/memoryN/state
> ...
> echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
>
> Note: if unbind is done without offlining memory beforehand, it won't be
> possible to do dax0.0 hotremove, and dax's memory is going to be part of
> System RAM until reboot.
>
> Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Reviewed-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/dax/dax-private.h |  2 ++
>  drivers/dax/kmem.c        | 41 +++++++++++++++++++++++++++++++++++----
>  2 files changed, 39 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> index a45612148ca0..999aaf3a29b3 100644
> --- a/drivers/dax/dax-private.h
> +++ b/drivers/dax/dax-private.h
> @@ -53,6 +53,7 @@ struct dax_region {
>   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
>   * @ref: pgmap reference count (driver owned)
>   * @cmp: @ref final put completion (driver owned)
> + * @dax_mem_res: physical address range of hotadded DAX memory
>   */
>  struct dev_dax {
>         struct dax_region *region;
> @@ -62,6 +63,7 @@ struct dev_dax {
>         struct dev_pagemap pgmap;
>         struct percpu_ref ref;
>         struct completion cmp;
> +       struct resource *dax_kmem_res;
>  };
>
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 4c0131857133..3d0a7e702c94 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -71,21 +71,54 @@ int dev_dax_kmem_probe(struct device *dev)
>                 kfree(new_res);
>                 return rc;
>         }
> +       dev_dax->dax_kmem_res = new_res;
>
>         return 0;
>  }
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +static int dev_dax_kmem_remove(struct device *dev)
> +{
> +       struct dev_dax *dev_dax = to_dev_dax(dev);
> +       struct resource *res = dev_dax->dax_kmem_res;
> +       resource_size_t kmem_start = res->start;
> +       resource_size_t kmem_size = resource_size(res);
> +       int rc;
> +
> +       /*
> +        * We have one shot for removing memory, if some memory blocks were not
> +        * offline prior to calling this function remove_memory() will fail, and
> +        * there is no way to hotremove this memory until reboot because device
> +        * unbind will succeed even if we return failure.
> +        */
> +       rc = remove_memory(dev_dax->target_node, kmem_start, kmem_size);
> +       if (rc) {
> +               dev_err(dev,
> +                       "DAX region %pR cannot be hotremoved until the next reboot\n",
> +                       res);

Small quibbles with this error message... "DAX" is redundant since the
device name is printed by dev_err(). I'd suggest dropping "until the
next reboot" since there is no guarantee it will work then either and
the surefire mechanism to recover the memory from the kmem driver is
to not add it in the first place. Perhaps also print out the error
code in case it might specify a finer grained reason the memory is
pinned.

Other than that you can add

   Reviewed-by: Dan Williams <dan.j.williams@intel.com>

...as it looks like Andrew will take this through -mm.

