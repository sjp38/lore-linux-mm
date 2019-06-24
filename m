Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F7AEC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAEC220656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="SgtXb1Zo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAEC220656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 746158E0003; Mon, 24 Jun 2019 11:01:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F7748E0002; Mon, 24 Jun 2019 11:01:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BF1A8E0003; Mon, 24 Jun 2019 11:01:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25F7D8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:01:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id 91so7477422pla.7
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:01:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=quuvyWI/tH8PB/1YozE8XRxbNNjX8bre6YQ9EYuNRwYjC8svbM0RPCpUpXVe+k8E+0
         3qHnshcYjIe9M/K+0hz7Zh9FxRJnX/UJ3PAJonk0kQLHJqqT6NvU4LEovCszePnYZvQo
         XfmjMZ/iu1RSjeFj+oZXgcMq70/SgQbp8jMoTa6TRG2IDicnXr6W1eWVWu2Olr5CmUba
         NaeH81KDYg1PhuuDozFYSit/W5Om5m4tZunQk0rpK0HdB715F8MMsvR8ztk726WXNekP
         jfTBFdW8fHcguZGWKT67rXc+o4ezcdtyphxj/CLS7Hgiin2aK7lwVoKsfJsMKC3fFsU7
         uwDA==
X-Gm-Message-State: APjAAAWhresYj1MohnGe+yS+JJnYal7cFmGA9kFU2jMygSMxl+oTnLOz
	CSVk5X4ymph0ryA57Tv5W8aHp2ZPOLM9igjsaMFHkZDPJFr6G5TxxLkSXv2zaEx41RWdSqAEbnx
	ai3x1GY5R33giIotQUyiEeJI8wUzXwrNxvIiE9T9bz6Y5SzEXzM34GYuLBc0ldliCMQ==
X-Received: by 2002:a17:902:2926:: with SMTP id g35mr102914866plb.269.1561388473734;
        Mon, 24 Jun 2019 08:01:13 -0700 (PDT)
X-Received: by 2002:a17:902:2926:: with SMTP id g35mr102914789plb.269.1561388472962;
        Mon, 24 Jun 2019 08:01:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388472; cv=none;
        d=google.com; s=arc-20160816;
        b=NdazlW6Zo/s5sD4lGh+MJCzFWAWJBXSd3vREwTiStcJUf6QArSh5OoBPECYLJju8Zq
         dZs1SYGP26Jf6Xnsme16pndDDZ0gNPRPIGbBx4nMnmdYjnAAVf7f4uW1umflFUUng+nm
         I1+wHo2UX9o/R63fI/jAH5okk22OnDMeqDVjlQap6h+U1M38im2R/NFy835a1EXJNYgo
         2MkWPgHGbgG7RgNITS+zlpWQaVFQHsEWatDggctuc4ls42N91KzOILKlDAZlo/ycUz0F
         6Ef8Sqah1BaM+12cnORRgI0j/AkrtTM+DsGPELEgrjdGcJYDFmJoCqMoiELZkFkb4+XK
         9hAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=a1OkSqI2VQ85FFGCRGHLrj47Kf0VDVAN7YPaDJTNusI0/7YmnOv9gAqxudLF86AUk4
         LxI6Vv9YTBXttflS2GM618j1sgVR+Yx/PeBFjje7iSuICM3VtegGvREcwhUdLSN2cMwg
         Xtdv1bUBmCRiQzZbify7gRT1/QTox+RN8tDP/N8opcSrJUeR4a6zbUhPYZkMDdOwtjcA
         p9ACFu8Jpyib2Q7zdnQLh02AAP/O3cj214U+bTblnU1vmSn9xTaBinPa3qUj3Y6OCd3Q
         XzwTMkufbanamurgagQDS5BSw2DU/7fWf+HLu7ULkx74L/ksxI128f6NRJgAnHgu1BrE
         i6Mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SgtXb1Zo;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i22sor7246832pfr.4.2019.06.24.08.01.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:01:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=SgtXb1Zo;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=SgtXb1ZoPYVGoTEFnr3Dke5H/wW1XINfDlxvUxMEVKLscJVqYESlzT6pTs1qtGKsP3
         VeuBN2URvFVWTMNeAoodZlrCQwZUc/5Z9xlB5RTSjoVcpo/SiTZgkaWRm8NhK88ImAdg
         pZTI13ZgoVTCMMEv5hkuIuzOLGORBtQ5+y4c8=
X-Google-Smtp-Source: APXvYqzelK/vNHxou/EQMWEPlS7Rae3sUcNTxG5Oed/VwPMQT+QfUbDH1pcZmoGQxd0g0HPzOMRX5A==
X-Received: by 2002:a63:f349:: with SMTP id t9mr32144143pgj.296.1561388472617;
        Mon, 24 Jun 2019 08:01:12 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id v5sm14367158pgq.66.2019.06.24.08.01.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:01:11 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:01:10 -0700
From: Kees Cook <keescook@chromium.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v18 10/15] drm/radeon: untag user pointers in
 radeon_gem_userptr_ioctl
Message-ID: <201906240801.F35CE2641@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <61d800c35a4f391218fbca6f05ec458557d8d097.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <61d800c35a4f391218fbca6f05ec458557d8d097.1561386715.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:55PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> In radeon_gem_userptr_ioctl() an MMU notifier is set up with a (tagged)
> userspace pointer. The untagged address should be used so that MMU
> notifiers for the untagged address get correctly matched up with the right
> BO. This funcation also calls radeon_ttm_tt_pin_userptr(), which uses
> provided user pointers for vma lookups, which can only by done with
> untagged pointers.
> 
> This patch untags user pointers in radeon_gem_userptr_ioctl().
> 
> Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  drivers/gpu/drm/radeon/radeon_gem.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/gpu/drm/radeon/radeon_gem.c b/drivers/gpu/drm/radeon/radeon_gem.c
> index 44617dec8183..90eb78fb5eb2 100644
> --- a/drivers/gpu/drm/radeon/radeon_gem.c
> +++ b/drivers/gpu/drm/radeon/radeon_gem.c
> @@ -291,6 +291,8 @@ int radeon_gem_userptr_ioctl(struct drm_device *dev, void *data,
>  	uint32_t handle;
>  	int r;
>  
> +	args->addr = untagged_addr(args->addr);
> +
>  	if (offset_in_page(args->addr | args->size))
>  		return -EINVAL;
>  
> -- 
> 2.22.0.410.gd8fdbe21b5-goog
> 

-- 
Kees Cook

