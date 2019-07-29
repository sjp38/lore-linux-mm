Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB161C41514
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:18:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B68E206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:18:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="qJYB6wAP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B68E206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05F418E0003; Mon, 29 Jul 2019 19:18:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00F778E0002; Mon, 29 Jul 2019 19:18:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF16E8E0003; Mon, 29 Jul 2019 19:18:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA6E98E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:18:18 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id w6so47933467ybe.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:18:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=wffttBld7HfMmTsUtcVoraIE8ihlJ8+LyvWPe1N6NlM=;
        b=YSvsDQX34NRF5nMruxTrlmMTurBOfNYDa0o4vteRUxw2EquD8S57G09q8O2NwTg6wC
         X3H/iasDUAJdm7y2/NAJKDT0Se9EctDQHskg7OEBhHeXbZU2Jol7Xp7GWAy6J5OX/VyL
         1sDRjO4pqYBoraiY+GyjPmD+Ng6jY/cHL9PEWKmWvrSQ1LVztBu8ymaIAJkLs3mMoRsD
         rmcXhwxefS3KY+jOeO4yb1E48rOL8h1HgIpGdIw5qSjhSs3EVrHXeS9bU30L3E0WxYQk
         foEc2S2LUIPD4tgQVIpId3zmVTExXoPqTlawMD/sZzMBghQqR476LoERFIazoHtXn2Zl
         sNXw==
X-Gm-Message-State: APjAAAXTgrkedTNVSiHU+WVTRN76E7l7e8LZfmSGJhQiL4vhpDegZjRN
	JJs/qRPDAqqvx/mxb6C/XdTpH8IG5qncUz8LN8hn29JM/kFRiVK4b8788ya92et7ayiROHiGKRG
	f17rAPIzt0+3mA5wXKNp/EtfWgbQayS8clPly4DpZ2NLgApkMco+VXkwMKWYxTY/TEQ==
X-Received: by 2002:a25:5c45:: with SMTP id q66mr71864761ybb.227.1564442298481;
        Mon, 29 Jul 2019 16:18:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypEf7x0MzqZ0Vni7Tqw3RSqsOt0WCWbW3A7NPHl8rOLu3WZNj2cvNkymtPpozQ5K5SS2ue
X-Received: by 2002:a25:5c45:: with SMTP id q66mr71864734ybb.227.1564442297919;
        Mon, 29 Jul 2019 16:18:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442297; cv=none;
        d=google.com; s=arc-20160816;
        b=V1zoWe33uOrN/iJnJ54wgGHQudEQwsBVH7ZxW3RinT/K1awf5sa5u5pir1sVqBPCBt
         2m+huhMOqGh4bDefipaFojkQOqKVTXce/jpMOOChywloRdGyWdVaslhVPsU+xP0YBa8q
         dFPBakUe1iBiR7X2J+xm4lfSxd6pj9OuuEq5sjJVYfVRWtYGX9MupE7p2XMQDw5yEjmz
         X6KZmaVLtEGekAm2ej4muCIfGU43X/sMuHCbd42kLbUmxjZTji/RCo1/ksKLqjxG052n
         rccZdud1oTle6kEabsgH7T7HWgjYoDKn6G0rV3GOo8Qo4S1EeG/P0ncRXsWXoaSA5nbv
         yqIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=wffttBld7HfMmTsUtcVoraIE8ihlJ8+LyvWPe1N6NlM=;
        b=okTW7YE1V2Iq06QUFOSpxGy0e2O5RD0WQkZ0aIzjyZuyFMerFyDFLVxFU1hRgMX0ST
         0uw/i+FDts4+MksG6kcMmbsSCYYINYBkEW+tgu2NHk3T4/ZIsXXXA6jHrTjVab4m5LEh
         Ro6HWVgWg//gzGsNzbc0aKCY1l6UTlUPb5I7neRe+/nLEqw7CbDf3xjniSoKw3N6qMKE
         bqnlZc5dQv/b7nsbY1In17YxHzoRw5bIqkCrSRM0Ntb4L9oAiBsRuKkezxgJ6mekWD+k
         XphMI8SPwXwW6O61wIXH379qmTJou+YhHK3/obsm59hMd7Uxx4YZrfltFm/t+eYRat8x
         75hg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qJYB6wAP;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id i69si21698655ywg.316.2019.07.29.16.18.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:18:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qJYB6wAP;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f7eba0000>; Mon, 29 Jul 2019 16:18:18 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:18:17 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 29 Jul 2019 16:18:17 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:18:13 +0000
Subject: Re: [PATCH 2/9] nouveau: reset dma_nr in
 nouveau_dmem_migrate_alloc_and_copy
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-3-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <26260dd4-f28d-f962-9e38-8bde45335099@nvidia.com>
Date: Mon, 29 Jul 2019 16:18:12 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-3-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442298; bh=wffttBld7HfMmTsUtcVoraIE8ihlJ8+LyvWPe1N6NlM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=qJYB6wAPLve6SzMmp5MpWUWQdHoVK+fKim4roGerZZ+H77Co/BQ9+sH3W3tA6tGo6
	 Qw/ilm9/0g7HpgRfqMM+KqB6PldKNV2/X0EkW+vFmEjKH+/0MNIWB6wXrj1YRUXzwL
	 RCt1HZmcafUvz8j6lns2XXyvcNxg18HpUEpVLEIFOxdtlbLEFvJd6EcuvIHmAssuwk
	 Cu4w6L02s0iaeg0/0OBAUj/7DCbe0uWiSDRevgQpB8N02P0daSKT5OUL6ZfFrUxc/w
	 HIneiuZFGw8uM87zuhdk7izVmIFJFBcoLp4P1KO4Qcu2x+7vZZLRIMwj2jxvykh/K3
	 cvQCTOyBkvhYA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> When we start a new batch of dma_map operations we need to reset dma_nr,
> as we start filling a newly allocated array.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index 38416798abd4..e696157f771e 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -682,6 +682,7 @@ nouveau_dmem_migrate_alloc_and_copy(struct vm_area_struct *vma,
>   	migrate->dma = kmalloc(sizeof(*migrate->dma) * npages, GFP_KERNEL);
>   	if (!migrate->dma)
>   		goto error;
> +	migrate->dma_nr = 0;
>   
>   	/* Copy things over */
>   	copy = drm->dmem->migrate.copy_func;
> 

