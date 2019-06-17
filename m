Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 243E8C31E5E
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB78E206B7
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 19:02:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GQLW4HsT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB78E206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 769538E0005; Mon, 17 Jun 2019 15:02:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F34F8E0001; Mon, 17 Jun 2019 15:02:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BA4F8E0005; Mon, 17 Jun 2019 15:02:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6818E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:02:22 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p7so5258912otk.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 12:02:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BlHoKzaMfcTndlIUZpaHNLrZG84G4vKyhA8APL9TYlo=;
        b=XWYh/I8+hBD8qqzKEuZjkhfGIX9x/+5VFxxnATzByb796HmaJ44hwnCxbD0J3P4uRL
         W6cZC343AuymN3GtWci4hCCDagkLdKpi0McZiZ/2iyZU5st4NAUs9bGabVbAwfjikHoj
         jXm7uci1QtdO7oBlbpJy9GLfp1bWsZxJccAZdS7gqcPyKu9iJDQ3b1X4Yennob8I3O2a
         NGIWSLVJwj/lwc/372FvgZpqjQHm8Ijeo4EOdTmflPgrJQ+kf3rTqR2RbZJqCfg/NIOP
         N+pxJZUfD7dbUBzYtq1JHXQti07FalOJk2K1TrsBD22Caod/zBwjYSpg0l3+jnr6fkuX
         r6Wg==
X-Gm-Message-State: APjAAAVjTEJYYQgRCU3Y4GlLoz+ETwSMsxC206+2t52n8cZIyZJVNgUj
	QclJzyFSJFYdoLDXtGw2WVtPWy1N3bhFYh+DdNOdjqM0rJ9u2829E5oTlNqPQIstt8k2gQZ+d0R
	gHuZ3HSlpIjlSBStJcXUK+yVxeO96xLZ/pLQ3lohVCQ1xAyHXMhYnIx/Ufh5LRHeemA==
X-Received: by 2002:a9d:174:: with SMTP id 107mr2234018otu.322.1560798141846;
        Mon, 17 Jun 2019 12:02:21 -0700 (PDT)
X-Received: by 2002:a9d:174:: with SMTP id 107mr2233958otu.322.1560798141211;
        Mon, 17 Jun 2019 12:02:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560798141; cv=none;
        d=google.com; s=arc-20160816;
        b=cr4/38H6whnGezkOobhm2h8KWVZYdk08VOII7mByU3FPYAaCxurkRwzsWygex03yRd
         SQ9qAxF+Lp+z6/zYTCeW7uuCq8GwI/ShE+SUWldMxWv7jFs107fdVYsphjzRekDbPWgH
         44ONtpJ+0iA8TBHAFLPZqqXTcVRE/UE1d2S4CrWkvw16+LoOrfxnaWeem50Pey/5Ew5g
         sqomrTqTCM57Avwgpsg4x5h6eHYwsnWo1+PlTnst/PQjDhyqzVY/Jv1dehf2F3+lfBmf
         byNApoYS1UwBU5rYOcvFAUo3Eg+1iooAieMRpCj9BM72MQFltGZ0JELdfXHoU6+D9S3R
         50Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BlHoKzaMfcTndlIUZpaHNLrZG84G4vKyhA8APL9TYlo=;
        b=iy+d7JQJuLD8edERv9iXCgMimXEJ/LyPlCC4U7K09EaxZ8EbytqpNuCcQFMx1gKsPp
         kTdb/bwyog9ayaPaC36+xy1Xd+/ifkOEZQXo99r1FVccOM5J3UiOxjxq6uwdnMMAHBob
         4lmNb0ueNfONmQS4h585R6jj2m5UNRONpGf6dESyA/+A3AnSq5cMD8IUQT4sgD9yxTkd
         vyzvPj0sVvW3u3wTdNHLV260kZcTjAxsQ7dBky1mTyi9DdP0D+V+gxtXA/Onck8pmf1h
         8vCCRBcMSpbVk4L+P8SiP5Eb+1pomZ5iwOjHvsRQrpkqi7Jdow+LTc50yfYHeepK2GpT
         PTAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GQLW4HsT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f16sor5705944oti.56.2019.06.17.12.02.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 12:02:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GQLW4HsT;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BlHoKzaMfcTndlIUZpaHNLrZG84G4vKyhA8APL9TYlo=;
        b=GQLW4HsTHqCZEV9mnOjnMrJWlLsdN8IhjnBoXVeTWqMkmbCxk8sZBD5lQSSBonTJIM
         PQpLqvxmfSU97Mp7ZkXYfzmZvyaftV4da/a21l7cSiFjBd/MqoX/xe2Q1eES5mKJF5Gx
         CjLeVsYnpL1abS+tpATrdwoL8cfv1W46T/pNOxBw8rYqsvqcySs4doJJNlylxXen8sQu
         0tArKmv0hrkikKLc1DMK+s8fkM1rgXKen4eyLlfkzY9W6Wctk+b/3/fC7QVMsGZuOWHr
         vLKx/QLeQzPNSvOdmqkQgk5dMQpH8k73LtoVoK1CABRsAj/MA+31rF03f1vzZFLYB6Mk
         qStg==
X-Google-Smtp-Source: APXvYqzJpQgCLYpd5HiWxDsy1wcz73meBykPfY3oY8gVfhGSrrrXTjfeSfxjaTy4CC9Dtjp1KjOhC26LvRkxDcN1gDI=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr51912079otn.71.1560798140931;
 Mon, 17 Jun 2019 12:02:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-8-hch@lst.de>
In-Reply-To: <20190617122733.22432-8-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 12:02:09 -0700
Message-ID: <CAPcyv4hbGfOawfafqQ-L1CMr6OMFGmnDtdgLTXrgQuPxYNHA2w@mail.gmail.com>
Subject: Re: [PATCH 07/25] memremap: validate the pagemap type passed to devm_memremap_pages
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

On Mon, Jun 17, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> Most pgmap types are only supported when certain config options are
> enabled.  Check for a type that is valid for the current configuration
> before setting up the pagemap.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  kernel/memremap.c | 27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)
>
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index 6e1970719dc2..6a2dd31a6250 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -157,6 +157,33 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>         pgprot_t pgprot = PAGE_KERNEL;
>         int error, nid, is_ram;
>
> +       switch (pgmap->type) {
> +       case MEMORY_DEVICE_PRIVATE:
> +               if (!IS_ENABLED(CONFIG_DEVICE_PRIVATE)) {
> +                       WARN(1, "Device private memory not supported\n");
> +                       return ERR_PTR(-EINVAL);
> +               }
> +               break;
> +       case MEMORY_DEVICE_PUBLIC:
> +               if (!IS_ENABLED(CONFIG_DEVICE_PUBLIC)) {
> +                       WARN(1, "Device public memory not supported\n");
> +                       return ERR_PTR(-EINVAL);
> +               }
> +               break;
> +       case MEMORY_DEVICE_FS_DAX:
> +               if (!IS_ENABLED(CONFIG_ZONE_DEVICE) ||
> +                   IS_ENABLED(CONFIG_FS_DAX_LIMITED)) {
> +                       WARN(1, "File system DAX not supported\n");
> +                       return ERR_PTR(-EINVAL);
> +               }
> +               break;
> +       case MEMORY_DEVICE_PCI_P2PDMA:

Need a lead in patch that introduces MEMORY_DEVICE_DEVDAX, otherwise:

 Invalid pgmap type 0
 WARNING: CPU: 6 PID: 1316 at kernel/memremap.c:183
devm_memremap_pages+0x1d8/0x700
 [..]
 RIP: 0010:devm_memremap_pages+0x1d8/0x700
 [..]
 Call Trace:
  dev_dax_probe+0xc7/0x1e0 [device_dax]
  really_probe+0xef/0x390
  driver_probe_device+0xb4/0x100
  device_driver_attach+0x4f/0x60

