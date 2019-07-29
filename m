Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6AB2C76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:23:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B7A120679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 23:23:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="NnhEWDfT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B7A120679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05B758E0003; Mon, 29 Jul 2019 19:23:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B468E0002; Mon, 29 Jul 2019 19:23:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E3E5F8E0003; Mon, 29 Jul 2019 19:23:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id C45D78E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 19:23:23 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id w200so37568365ybg.11
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 16:23:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=IyoLCbDcsQakqt7A6+W1y7A2qFkbkRJjy2RWDtkVLUI=;
        b=sGIQM/9OaOb9X7TKVVcI/7NvI+6Ss7Ns2WrDA0lIz03I06UzWNcke6rg6yARe0Tyhw
         Qw+haegNK6iE7G/pS6H6seWNk/XEK8uxefx1XA+5hv3FO7TcfiDwRlKLmd6boxKqJKMN
         if2N/B3LOD+UUsbCKjFzcFcM30tE4Ca9kiXVIRiKtD3C26eJf4D0HcrtgEIsMgtEXAW4
         qSNfcbq+a96WaC4C42H6bijMZG4r4IjvnLGicAv0Er6sriybgQnOwwH4DT/hzYMLkd+C
         jXZfb4Nkgwp0MZKBvuHqHocGK6wLPUa5trBR00RkjiSZeK8hn+cPwTqOaZ+FsdnApxQO
         HRbQ==
X-Gm-Message-State: APjAAAXkZIhBHSY88tqGInzHzCuJ/Nuo4Gb1hdJ92zlRiSyhrkhop5QX
	Y1/KEstCZ9P9QJZ/wW/U5npsizNS4SyIzz6mhynyI2FBZVDijX1MVTy4ylZdvnnXRdgxRCxx8wa
	CG5qUDMJZ5KvrH/EjSoXyrJiupA38IBGlQ/ARocD9Omd/48tIdO2/dVfcWGv6eEvGOA==
X-Received: by 2002:a25:df13:: with SMTP id w19mr74483572ybg.71.1564442603552;
        Mon, 29 Jul 2019 16:23:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy74zNmTAxeLPxJRMiidbSv8G1aG6lqC8y9Vtz+p2K0yktGco/3Fs/mpz74Uknxt6fl6398
X-Received: by 2002:a25:df13:: with SMTP id w19mr74483557ybg.71.1564442603046;
        Mon, 29 Jul 2019 16:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564442603; cv=none;
        d=google.com; s=arc-20160816;
        b=Qrot6crfwxou3vpsZwA8c+3QP6d5BBYrIYu8d5hm7jetDv9e+oqC4x5EsbJ2/jVV97
         bxOAFgXZBwrlGsbpShZLo0lmNKfaFKDBw9qAHzV3QABBWYm11/iG77MW/bGQBuo6EhaQ
         OlNZgbVXhq92/fx4z6yVLK9zu+Dl6DkQHfWF+lobJb/swSVMhuEOf7TmNVZKi9IBR7rX
         iuUSl+YISbxYCRYLKJvRPV7hHaEzyDSQX+i9+NLrUUDwN2vKAEs3lynp5F5q2iBHxluD
         E2nGg2K3pwpRVa5vf3r9vECcNWZv2rlhgHmFMMoz0Vwt/AxEBLJWWT8gqLG1QHyjbQV9
         jJHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=IyoLCbDcsQakqt7A6+W1y7A2qFkbkRJjy2RWDtkVLUI=;
        b=HhoNTq3psUAlH+qgCliJeqrl9kcyj8FrlcLvBJXmqKLniXqu8TFdrw6HFl/a07cAtk
         gE5+39ojzTWsoUzaolaoTPrZ0B482UNIBgFE92mDuQ4sFawPVlVkflIYeZt1C1BS5WQ/
         sUIFaXn8VQD/s+DLdWVhACaJ8jKHbSjIwFw2ffyD47AlbuMjs6DPPJIthBBaVNQ+DFmu
         WYN0HuYJNlsvuLa6d35l5dqJz8qYwqu4yBjbI5Wgn2KDs9zY2Pb+GfXKvsXBh/NrOYch
         6Ijlk5eE77+VdFYjbTFkkzWP8TuwDPwrUCeXM3RoFPdEetDJ3WNv8rOqrGeivTKqRC7t
         amYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NnhEWDfT;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id u21si22060799ywc.96.2019.07.29.16.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 16:23:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=NnhEWDfT;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3f7feb0000>; Mon, 29 Jul 2019 16:23:23 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 29 Jul 2019 16:23:22 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 29 Jul 2019 16:23:22 -0700
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 29 Jul
 2019 23:23:18 +0000
Subject: Re: [PATCH 4/9] nouveau: factor out dmem fence completion
To: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs
	<bskeggs@redhat.com>
CC: Bharata B Rao <bharata@linux.ibm.com>, Andrew Morton
	<akpm@linux-foundation.org>, <linux-mm@kvack.org>,
	<nouveau@lists.freedesktop.org>, <dri-devel@lists.freedesktop.org>,
	<linux-kernel@vger.kernel.org>
References: <20190729142843.22320-1-hch@lst.de>
 <20190729142843.22320-5-hch@lst.de>
X-Nvconfidentiality: public
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <f2af6247-c935-12de-fb12-e418101efdfa@nvidia.com>
Date: Mon, 29 Jul 2019 16:23:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190729142843.22320-5-hch@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564442603; bh=IyoLCbDcsQakqt7A6+W1y7A2qFkbkRJjy2RWDtkVLUI=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=NnhEWDfT1JRU+yGkNl7isRXL14uONAN+nufQA88N/0WVIGrrXe2VPqIZreLa/iM58
	 rrsdH0JGvyxCRjxz6XDeOPcGsuqp6VptCocClcF1kIwsJAO2D/NW+YCRhXkKRipLWH
	 botVKAowNZ8G7vOFHGBaKmiBYWS1vuuThPema3w2Ff252O84tPPld7ORsNwKXIEt5A
	 gy8P/4HuT/jTrKaPQhTu13ZkYDnUvoPnsagy2yRGHgm6DOUlXGql+9UP9Sm4gEKhVK
	 NDxlPJ7YZ/ogVkIam9GCXsqywqwYliQ/7clBqKCCjHiZXNN49ipCt3w4wGcTwD6dAu
	 svSbpqgfcVg3A==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/29/19 7:28 AM, Christoph Hellwig wrote:
> Factor out the end of fencing logic from the two migration routines.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>

> ---
>   drivers/gpu/drm/nouveau/nouveau_dmem.c | 33 ++++++++++++--------------
>   1 file changed, 15 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/gpu/drm/nouveau/nouveau_dmem.c b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> index d469bc334438..21052a4aaf69 100644
> --- a/drivers/gpu/drm/nouveau/nouveau_dmem.c
> +++ b/drivers/gpu/drm/nouveau/nouveau_dmem.c
> @@ -133,6 +133,19 @@ static void nouveau_dmem_page_free(struct page *page)
>   	spin_unlock(&chunk->lock);
>   }
>   
> +static void nouveau_dmem_fence_done(struct nouveau_fence **fence)
> +{
> +	if (fence) {
> +		nouveau_fence_wait(*fence, true, false);
> +		nouveau_fence_unref(fence);
> +	} else {
> +		/*
> +		 * FIXME wait for channel to be IDLE before calling finalizing
> +		 * the hmem object.
> +		 */
> +	}
> +}
> +
>   static void
>   nouveau_dmem_fault_alloc_and_copy(struct vm_area_struct *vma,
>   				  const unsigned long *src_pfns,
> @@ -236,15 +249,7 @@ nouveau_dmem_fault_finalize_and_map(struct nouveau_dmem_fault *fault)
>   {
>   	struct nouveau_drm *drm = fault->drm;
>   
> -	if (fault->fence) {
> -		nouveau_fence_wait(fault->fence, true, false);
> -		nouveau_fence_unref(&fault->fence);
> -	} else {
> -		/*
> -		 * FIXME wait for channel to be IDLE before calling finalizing
> -		 * the hmem object below (nouveau_migrate_hmem_fini()).
> -		 */
> -	}
> +	nouveau_dmem_fence_done(&fault->fence);
>   
>   	while (fault->npages--) {
>   		dma_unmap_page(drm->dev->dev, fault->dma[fault->npages],
> @@ -748,15 +753,7 @@ nouveau_dmem_migrate_finalize_and_map(struct nouveau_migrate *migrate)
>   {
>   	struct nouveau_drm *drm = migrate->drm;
>   
> -	if (migrate->fence) {
> -		nouveau_fence_wait(migrate->fence, true, false);
> -		nouveau_fence_unref(&migrate->fence);
> -	} else {
> -		/*
> -		 * FIXME wait for channel to be IDLE before finalizing
> -		 * the hmem object below (nouveau_migrate_hmem_fini()) ?
> -		 */
> -	}
> +	nouveau_dmem_fence_done(&migrate->fence);
>   
>   	while (migrate->dma_nr--) {
>   		dma_unmap_page(drm->dev->dev, migrate->dma[migrate->dma_nr],
> 

