Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FFAEC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:46:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15C222081B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:46:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="velcbiV1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15C222081B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A10258E0048; Thu, 25 Jul 2019 03:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C11C8E0031; Thu, 25 Jul 2019 03:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D70B8E0048; Thu, 25 Jul 2019 03:46:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5688A8E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:46:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m19so15685373pgv.7
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:46:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=klRhFLpte1KchUs1v6ORtOt2UGfuuoLAokCZh07v6dk=;
        b=R7OKe4CEjekkKtKwfpqx8jy7yAw7FdK06qDwxsS1pKqxcSslEmwRvBU3YSvqd61Hps
         5uDUZ6fueJlLSEnwSIHaswBX5cr0z0V2JTttRPRscnvOyhaClpdCaAg4b/vRojIC1zzH
         aMs+wnl9OypskwUS4u+ZsOqLOuHogOqyh9FstO7q5pkYQrrV9c3JktLpB5zGf5n0n9Th
         uj7+y/HJogtUwGs9rW0bIDJtlG8xlMlZXZEQ1iqtKkR9+N6As5zOimjj+Zy4AY5TM03P
         svJRrS/dAmHc0+1e4Xk6+EK9obj+YoSWiOQjPQju7IFmsk3aj85wap3C7bawogE/ZEd9
         JatQ==
X-Gm-Message-State: APjAAAXtpwBXFrqUqufq2FDDhPAfPbHuttJ+0hJrZRy4q1j2tSMbhKwJ
	GP/bJo0zMOmwrQbVwebH/hk77norx3/d+tahHfuM+mhQhA/uXwRYYjkYfZmBgNoRgcirtEzgigJ
	SdeGX0xWidmmjkX9rbLZCsqPMxGJQJR+qOfV74S0hujgUaVCemgrcAcdqYNBl8K2kDQ==
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr92982157pjb.42.1564040798882;
        Thu, 25 Jul 2019 00:46:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0nZPWa+y1V2vedq/XSBbgGfh49+8bKwN++YzNdVe8lo0eQFT0PiAqczg+UWpQaqO+GFaN
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr92982123pjb.42.1564040798246;
        Thu, 25 Jul 2019 00:46:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564040798; cv=none;
        d=google.com; s=arc-20160816;
        b=GyODtcqMA5I7+y4yC3f+DvLD7uHgXOYptzgEIHR4+ii3P1b008wnJrnd/PluwNSEg7
         j/1G8PtRK12arVew3dTIwl9xeVcsjuk1sYpf2JO1mvkl1cdRo2t4sUj2ITMh69QN+2Bn
         I2YTpHqQWCvq2yg2dNcG7t+1dPP2h7IKdDdm+SztsjOLNYJ7DAtandtoEKxa6mIJDg2O
         1bEoIdo1fLXuyH+aTywfKG0+uNlXWQoVvYsresPD0KzEAkiRvib65jfsVT31OTd93+nl
         5i7PCMFOaIHLrwQPxfY4FECGuH1gHoFA0x4ZdAu2MkUWNbSSDYI2OpQTFcHetq2cjm80
         Rv3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=klRhFLpte1KchUs1v6ORtOt2UGfuuoLAokCZh07v6dk=;
        b=o9R/dtucfd11GasXEUzaVFkNZj41see7lUTYPsxMYDB+In7auShvYj31LNlKUqeelZ
         KJEjngGh0dhfqPQxz1hFaaEYSR5s3xnvT7F25AMYFz0mC3KpEd/54qvf2FHrR+7VzPCS
         qDPTXEoDdgVi3RY8oBIyedsvdVnGNsJ2fn30MQzMtdCc23pQGf3JqOyQ6YV03toesDqg
         0KiR4ucreULAVsmfe4mR99g8j6sRS58nK3tJ5qRStLT2ihnFm6KZiQr99YUujpGwBacg
         NKdyVLbQgbzURUDschKRb9u/cRw6yYZ9djxs0VMv3K1bcy/KIJ4Y9UBeE4vyfv2G/36y
         KVFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=velcbiV1;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s8si16604074pgq.538.2019.07.25.00.46.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 00:46:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=velcbiV1;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 727952081B;
	Thu, 25 Jul 2019 07:46:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1564040797;
	bh=4UcEQNmlJvi9gGhfQJufu+mVSE9Yfv6XMx4Zl1E3xJc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=velcbiV1Wy/WrI//kr6s+Z4iop+NiwHmNkPl/NPAOSBXjfLXcnUF03lIE5FQ+nGOl
	 Zm1qmFvGNR0CqIiByLLBJjaGlw86qt4T/3foSXAIO80HGhsLDLYxragd68iJeRVWg0
	 e/VP1qAQVs9nypLg06ZnCBFTK5hbGnoJo/MMwtS8=
Date: Thu, 25 Jul 2019 09:46:34 +0200
From: Greg KH <gregkh@linuxfoundation.org>
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: ira.weiny@intel.com, jglisse@redhat.com, Matt.Sickler@daktronics.com,
	jhubbard@nvidia.com, devel@driverdev.osuosl.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190725074634.GB15090@kroah.com>
References: <20190720173214.GA4250@bharath12345-Inspiron-5559>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190720173214.GA4250@bharath12345-Inspiron-5559>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 20, 2019 at 11:02:14PM +0530, Bharath Vedartham wrote:
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d ("mm: introduce put_user_page*(), placeholder versions").

Please line-wrap this line.

> 
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Matt Sickler <Matt.Sickler@daktronics.com>
> Cc: devel@driverdev.osuosl.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
> Changes since v1
>        - Improved changelog by John's suggestion.
>        - Moved logic to dirty pages below sg_dma_unmap
>        and removed PageReserved check.
> Changes since v2
>        - Added back PageResevered check as suggested by John Hubbard.
> Changes since v3
>        - Changed the commit log as suggested by John.
>        - Added John's Reviewed-By tag
> 
> ---
>  drivers/staging/kpc2000/kpc_dma/fileops.c | 17 ++++++-----------
>  1 file changed, 6 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/staging/kpc2000/kpc_dma/fileops.c b/drivers/staging/kpc2000/kpc_dma/fileops.c
> index 6166587..75ad263 100644
> --- a/drivers/staging/kpc2000/kpc_dma/fileops.c
> +++ b/drivers/staging/kpc2000/kpc_dma/fileops.c
> @@ -198,9 +198,7 @@ int  kpc_dma_transfer(struct dev_private_data *priv, struct kiocb *kcb, unsigned
>  	sg_free_table(&acd->sgt);
>   err_dma_map_sg:
>   err_alloc_sg_table:
> -	for (i = 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> -	}
> +	put_user_pages(acd->user_pages, acd->page_count);
>   err_get_user_pages:
>  	kfree(acd->user_pages);
>   err_alloc_userpages:
> @@ -221,16 +219,13 @@ void  transfer_complete_cb(struct aio_cb_data *acd, size_t xfr_count, u32 flags)
>  	
>  	dev_dbg(&acd->ldev->pldev->dev, "transfer_complete_cb(acd = [%p])\n", acd);
>  	
> -	for (i = 0 ; i < acd->page_count ; i++){
> -		if (!PageReserved(acd->user_pages[i])){
> -			set_page_dirty(acd->user_pages[i]);
> -		}
> -	}
> -	
>  	dma_unmap_sg(&acd->ldev->pldev->dev, acd->sgt.sgl, acd->sgt.nents, acd->ldev->dir);
>  	
> -	for (i = 0 ; i < acd->page_count ; i++){
> -		put_page(acd->user_pages[i]);
> +	for (i = 0; i < acd->page_count; i++) {
> +		if (!PageReserved(acd->user_pages[i]))
> +			put_user_pages_dirty(&acd->user_pages[i], 1);
> +		else
> +			put_user_page(acd->user_pages[i]);
>  	}
>  	
>  	sg_free_table(&acd->sgt);
> -- 
> 2.7.4

This patch can not be applied at all :(

Can you redo it against the latest staging-next branch and resend?

thanks,

greg k-h

