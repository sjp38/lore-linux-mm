Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84A52C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:00:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D95020673
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 22:00:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D95020673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC0C98E0004; Mon, 17 Jun 2019 18:00:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D718A8E0001; Mon, 17 Jun 2019 18:00:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C39AD8E0004; Mon, 17 Jun 2019 18:00:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id A30688E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:00:12 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so13647389ioh.22
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:00:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=sycZdmOU9qTE9/EqEGohOGSK1tdA7T/UGbnjmyU5J8Y=;
        b=h7SnOm0wftb6Q3UPv1+Kjn3lScUBg1OHiBskRUxBWkjjfMXjD0KqLpM282ocmL1Zvf
         GfskKd6RH/Vy26umfW1lmDYujA28KCgCnhuAhi3wSq4+6usbYl//FYeDLLroAnukRxAl
         DH+J6hsPPSxexvlinNnlAeAx1h31wGvVjr9yw3uXPSljXE9jz4gGR8QL8qQrsDTKwh0o
         NSzMGFUzte/Vr85Dx+TKMfzj1/uMlAhxemm200IAdtw0DL9Va7sv6DkGb/Z5PiZYsciK
         dmmRV/P5s7JBYS0p8UduRzfDdrzzvwSZd9zU6JJMa1dzTy8/Kb8U6VYfVpbDrcSwPebu
         7vpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: APjAAAXEPf/i/ab4bEJ1PA0aS/7/xzmEhr2JjdhqxF1JTKnrKaLn5XDA
	slnnCJk/nVwKvFYf1QBJfIjwgzitWgWQO4wMH0o1OC+28a4PDYDmv5EecPD7A26qrLP8u6aL+lM
	YbdT0sVYF54lUQYa0csB/Vh1t3yTLBRQNuPcisYXM/I6LqOcoZle7UI5q2pSprDjz2w==
X-Received: by 2002:a02:ce92:: with SMTP id y18mr7635jaq.40.1560808812373;
        Mon, 17 Jun 2019 15:00:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSUaXJvJMwz8I7HUA+Prl8PNnsSEYs0tFnQIiVf6HgSE7GUI2G2U45F/5WWYXugNbUobaZ
X-Received: by 2002:a02:ce92:: with SMTP id y18mr1455844jaq.40.1560802099485;
        Mon, 17 Jun 2019 13:08:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560802099; cv=none;
        d=google.com; s=arc-20160816;
        b=mwZAmqW1q3MkrPJUOE1gPH+tPAqmgKTO8VM0CxrLTTs2XzbXNDgrCvrL8G/CP9qCOy
         FMJXdA6Ywu/+NUDsFaWJUL/6cfiY4Z8bjciIbgbJx+B8OV6Qj07VzObiZjTQE5tVWam0
         SnATsmHpJirQDmtR+kB2WX6yNxMiTxAspSvsrpTAbAd2h90EhL64FZqDailkAnbtGnug
         QP+DlcH7YhgthNZ4PbuzwJ7oCR1DYOUeWPvqobHbIkxy3hGIUPrWsCfsUzDHCSbe+o/c
         csxN+pY4zmiqcG8b56wlAhQBSAkLE2hztvcFXJJOnuxlW+TW1AOK3R+K61UJx0MFZTgH
         9ePA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=sycZdmOU9qTE9/EqEGohOGSK1tdA7T/UGbnjmyU5J8Y=;
        b=ozHHBRGkrI1U2VlI5Z9cYknENYyrLZGaCsORFknDCcEcqt+dHWc/YKfE581/uGNGBa
         2TP/c6koY6zM1pk0mjBlBdicf+J4FY+d22UuK8oUiLE9Oa3iIHWro30Erb0k7c7gscg8
         sieNCWf+wL7Auy5wYlK6/dAq0vKsxDKeTkBMsUqdCkx5oA6jk94VnH2ZAneiei09FyWc
         imZyiM6Qpru1s3mAZTJdgmp18ZqYX0raXm1QmK92jfALkj6lmdPSWOTvDdWq/zv8TMsv
         iIbxlZUujOEsd1dAc4G+68B+Kqh7p+6V/3mb62e8xcWZDG99HjY5u8eICPdX/Uf0C+SO
         OeWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id i26si18592589jac.14.2019.06.17.13.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Jun 2019 13:08:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1hcxvM-0004o2-QE; Mon, 17 Jun 2019 14:08:17 -0600
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>
Cc: linux-mm@kvack.org, nouveau@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
 linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190617122733.22432-1-hch@lst.de>
 <20190617122733.22432-9-hch@lst.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <d68c5e4c-b2de-95c3-0b75-1f2391b25a34@deltatee.com>
Date: Mon, 17 Jun 2019 14:08:14 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190617122733.22432-9-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-nvdimm@lists.01.org, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, linux-mm@kvack.org, bskeggs@redhat.com, jgg@mellanox.com, jglisse@redhat.com, dan.j.williams@intel.com, hch@lst.de
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [PATCH 08/25] memremap: move dev_pagemap callbacks into a
 separate structure
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-06-17 6:27 a.m., Christoph Hellwig wrote:
> diff --git a/drivers/pci/p2pdma.c b/drivers/pci/p2pdma.c
> index a98126ad9c3a..e083567d26ef 100644
> --- a/drivers/pci/p2pdma.c
> +++ b/drivers/pci/p2pdma.c
> @@ -100,7 +100,7 @@ static void pci_p2pdma_percpu_cleanup(struct percpu_ref *ref)
>  	struct p2pdma_pagemap *p2p_pgmap = to_p2p_pgmap(ref);
>  
>  	wait_for_completion(&p2p_pgmap->ref_done);
> -	percpu_ref_exit(&p2p_pgmap->ref);
> +	percpu_ref_exit(ref);
>  }
>  
>  static void pci_p2pdma_release(void *data)
> @@ -152,6 +152,11 @@ static int pci_p2pdma_setup(struct pci_dev *pdev)
>  	return error;
>  }
>  
> +static const struct dev_pagemap_ops pci_p2pdma_pagemap_ops = {
> +	.kill		= pci_p2pdma_percpu_kill,
> +	.cleanup	= pci_p2pdma_percpu_cleanup,
> +};
> +
>  /**
>   * pci_p2pdma_add_resource - add memory for use as p2p memory
>   * @pdev: the device to add the memory to
> @@ -207,8 +212,6 @@ int pci_p2pdma_add_resource(struct pci_dev *pdev, int bar, size_t size,
>  	pgmap->type = MEMORY_DEVICE_PCI_P2PDMA;
>  	pgmap->pci_p2pdma_bus_offset = pci_bus_address(pdev, bar) -
>  		pci_resource_start(pdev, bar);
> -	pgmap->kill = pci_p2pdma_percpu_kill;
> -	pgmap->cleanup = pci_p2pdma_percpu_cleanup;

I just noticed this is missing a line to set pgmap->ops to
pci_p2pdma_pagemap_ops. I must have gotten confused by the other users
in my original review. Though I'm not sure how this compiles as the new
struct is static and unused. However, it is rendered moot in Patch 16
when this is all removed.

Logan

