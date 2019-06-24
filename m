Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84332C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:02:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40065205ED
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:02:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="e43eFy4u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40065205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFB308E0005; Mon, 24 Jun 2019 11:02:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DABF78E0002; Mon, 24 Jun 2019 11:02:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74AD8E0005; Mon, 24 Jun 2019 11:02:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90EC18E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:02:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k19so9198833pgl.0
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:02:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=V9TzVwaWNoKVkCc+qZuqr9VoO9zo5mxt19x1CIYfqfrkN4KQj7gbm/avm6AzHB+K20
         zJ0yARcFCPzGqn1pHE2fru2yto0AE7R4Q/2lQ6LvoVixTlZSE5sRBtERj5CQehRlAmnd
         z7hSCuCw3GHjyiXuNLjk8HERhERqrOf8Ug7H5VXJfZ9zUNld9RwUqYmgkkoKohk9h0q5
         cxZcPPJUCec/mASSUrHlS6v6nxgm2Ld+FLOErAFxNElnJLC97soeuPcXZkiKHzF+oBiW
         EmLeNjwvNLbBzJNbICa7TdNozGHwC5gML992uowL9HG6HDoacWDJguxJOIpxSlCBhrDb
         0jxg==
X-Gm-Message-State: APjAAAXbVE1wtROlNwucVO3ME+MOm4VieWiVPbRGFIn7aKgMUjP3Sksm
	w1YXfTkyTTonlY1UutRCpg/olgRMKREm9ZdId6n/+T/AGScfn7TioKilrfpJMLuFT6AYRLAAlbv
	o8ALXjde0zYp7OhoePCu11iLMagZeCuNUxKJ25VRD4LlWWU+kuxTWTvImHqC6ldsYIg==
X-Received: by 2002:a17:90a:246f:: with SMTP id h102mr11544994pje.126.1561388567266;
        Mon, 24 Jun 2019 08:02:47 -0700 (PDT)
X-Received: by 2002:a17:90a:246f:: with SMTP id h102mr11544937pje.126.1561388566650;
        Mon, 24 Jun 2019 08:02:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388566; cv=none;
        d=google.com; s=arc-20160816;
        b=serGnmah5v+lqCppmqhdGoualD9kB+trACmvkn41DoJhzbonP/LX5qPCeQykqdeW6I
         qvT0lntTZ0Pgcmsvg2a4F+6e9mtXHoT9zOnGIMUrtB/wJCIO/pWOsAva8tUeGjR1lrJB
         s9HOtIws5OuSfj6zmBJkHe3eYPAMjtg7c6pBeyxu6gsW1wx1CUlOYZeQgKuj6zaITI7W
         qwk3snnzmFKmIVKvrri5rq9uoC/7c182omyAOxACfpu5KrHMOs5XzTNSfVLjkhKrU0Rk
         erjZbWCqhx/Xqh6c4vKo4j/dAfP/zOwVWHX4Xjzu2K70f5Pm2wyrpQGPqhLUzzYnzD4S
         RBnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=x3tRa1Ip79qekE1+cMfgxeCy/sKEC1qPGJ7L3D86TclegwrMVOc873NLonHVwT/NDj
         rHlRx87oAGRtVCTdTB6AGKiUOSQvQFixgBS13f9O02vsm6MlydOXCrVdAGC89zC5AXbI
         Z9PB0EybXOyH9YPLVAZbCSyPQUGqb9bLVIanNnU2Py/Eb/PbGlDOdYbHLBfmvlrMipHS
         Yq0S3cc+hHZVuet4hjTq37wvuTz00jXJJQ8S3Ne8xaeiUZc9AKH3Jgz0LHauXwLTLkLc
         Kfh1xmS5liuAsjnXaEMPiGF0DTdWCQbX7UMDaS8JTLCZRq5zgqwhcJZwSv+IOFuQryQj
         BJYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=e43eFy4u;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v13sor6220418pgr.24.2019.06.24.08.02.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:02:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=e43eFy4u;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=wtUCrmBvvtcTuAx+h8NVUvwzdIMNqCWWz94+pOdbySM=;
        b=e43eFy4uvro/u8g8OpaaLl6Rs0FW7SVQaUyRp7V2h5UXAJx5vDQq+s1gB9TZQuKsNt
         b4xMpJfn+9rwJ2wcampbkbNuD3kDE/KEYUEeVoAoarpxyF2ozWjPuoNnonjrArQW0IHL
         YwvsDeGKK9G/YnAhcFhuSat9a+4MSjjnix9W4=
X-Google-Smtp-Source: APXvYqy4hQCrjSrRM7hi0X8gFT7Wh+JsuaL6AoOZPMb6KqSaIYh6bUPxpgpfjIoTWPj+3t8Nf6ik+g==
X-Received: by 2002:a63:1d5:: with SMTP id 204mr34459271pgb.207.1561388566306;
        Mon, 24 Jun 2019 08:02:46 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id j1sm13025385pfe.101.2019.06.24.08.02.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:02:45 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:02:44 -0700
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
Message-ID: <201906240802.23FD5401@keescook>
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

