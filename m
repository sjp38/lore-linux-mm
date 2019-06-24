Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB9DAC48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90B7820656
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 15:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="KQ2654w6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90B7820656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65D146B0005; Mon, 24 Jun 2019 11:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CBB8E0003; Mon, 24 Jun 2019 11:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D47A8E0002; Mon, 24 Jun 2019 11:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 199DC6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:01:01 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f25so9712600pfk.14
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 08:01:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=ZH0KsEpqEXiZL11grL/nW8IzWOxozO/nFecO0TNWzZg=;
        b=KOR2/cqShnW8JeAmXuRpXLsjnnXRsphpPsKGLEihYj7SpsED8CX2sCpSwLl8PC3X8/
         M2yIz/MZJxP4zGPW7XZWtVUDxQZe1aLdpaNmY37WlhKKX6vqXm4nXtcfdWo+sKPJuZM2
         GUvGhSx7KI80dcbIQfrb4ayavY8wnsgTTWyc2AhUh6UvjP02a2Nc4+5uQi92v8DZv7el
         AlSiyX6L+fbG8DzXGHAQ7ivgCgKeTTfqX8vOPqz8M/0oyq5/yvOQ1WOXUKGPT6UPZ48r
         3brVPTXnlj2Dyy+P/PGe8yl9dqGv15kpQlb+/aXHMWthOHqi+VzApF6JVGzp27J8Gf6K
         eI2A==
X-Gm-Message-State: APjAAAVI7de+WX35yu5ULTjIwjlXi2DxL8Jf0nHk5nP22B065QbsSq/S
	YO2WRYS+FNsIRBjuedeQbdDMd7hJQW2TsvoViRaDMR7RwIwwVaPV945aSg/u0+6L8UyR2kxjezl
	Uy2hRvMYSsiDCSbWBHHAxS9Lxwzfx8+JFU8zla0UAL3q1f29SOLJi2b2rXdYd0sHzKg==
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr152738093plr.44.1561388460583;
        Mon, 24 Jun 2019 08:01:00 -0700 (PDT)
X-Received: by 2002:a17:902:b18f:: with SMTP id s15mr152738030plr.44.1561388459925;
        Mon, 24 Jun 2019 08:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561388459; cv=none;
        d=google.com; s=arc-20160816;
        b=cwvdYWi8h39Jg83JVl9FHq8ztzmLgZBobUug522wyzpwlUy2uBGzq1/Ywkjscl63NR
         kqJS26o8U914aSos6S/iOKT991ifAJiuIgLDS311Wj8lEB7vygdizb7aqa3rvK52GV9n
         MSnKi1bUpBwjVWkQ1Mkv2DGUe23Sf+gKrylpJliRAozkNtywga8NBNfO5p17g5qX6oP4
         fEg6dj3VKzj8Tk9ROoU+oxBD1MA2UI/VRRGuNVC/P+6X425N7We0Uflhu11a1YMhejit
         h3Yp5DvY48Vl5pDRTsxio64KCVqf9kvmIOxT/foYLY1NVHyURkWopK/u+16cCRQTUo8R
         PvMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=ZH0KsEpqEXiZL11grL/nW8IzWOxozO/nFecO0TNWzZg=;
        b=XWVF3Tu9V8ewZONmKeZJBzXQoJ+U04cUdIukHqdTebmgN26hjnIiib67SBOxvsoJfm
         k8lQVzogq0V30C+t23VxfzbLaQWJUc1He+QCNpHSvoFUZ7lqyzjhnyq6iOOMTBYKA3Z0
         Hn1t97XTxVHZ/WMbm8bNL/EulsgjPkYKerHKMZ7GePZnBfztZzy0R+DrTfLe7gSTk3qH
         yu8MawrgQ8ytnYdrBb6YBQGUmnS3UmFQwl7qd9qCyLOlRifyNGVMImtRgxfnlxKUKVVz
         lBDyZEdJW9+Vm4648pC3FdZlMqWItTfmfFno1RhHFDbxTk8Fq3t4ITKAhwY0m+7PnMIV
         eBww==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=KQ2654w6;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d3sor14768286pju.22.2019.06.24.08.00.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 08:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=KQ2654w6;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=ZH0KsEpqEXiZL11grL/nW8IzWOxozO/nFecO0TNWzZg=;
        b=KQ2654w6YgnMZs2At+Zd89XQIqIuYR8jlquNCWJJuIXpWD/HlSd4ZBjLxPQsxGeT2n
         QOBGSpQkVzrAWhjdNm3L175i3EwkQyprQmoxs6iyZjw9hV5O7BunNQVJJ3RYGgog4Rsr
         YQVv/8/84su3okC1IPWa+LhVmvUHm4bqUkhyE=
X-Google-Smtp-Source: APXvYqyXA9qWckeMWJ1FYgTNxW3Kl/SaHQcwWPkv+8Ov9g+q8rZ/yCmpPgqZaQwQyexxau4NGmLb3Q==
X-Received: by 2002:a17:90a:338b:: with SMTP id n11mr24999228pjb.21.1561388459522;
        Mon, 24 Jun 2019 08:00:59 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id e188sm1978374pfh.99.2019.06.24.08.00.58
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 24 Jun 2019 08:00:58 -0700 (PDT)
Date: Mon, 24 Jun 2019 08:00:57 -0700
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
Subject: Re: [PATCH v18 09/15] drm/amdgpu: untag user pointers
Message-ID: <201906240800.5677E3CF@keescook>
References: <cover.1561386715.git.andreyknvl@google.com>
 <1d036fc5bec4be059ee7f4f42bf7417dc44651dd.1561386715.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d036fc5bec4be059ee7f4f42bf7417dc44651dd.1561386715.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 04:32:54PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends kernel ABI to allow to pass
> tagged user pointers (with the top byte set to something else other than
> 0x00) as syscall arguments.
> 
> In amdgpu_gem_userptr_ioctl() and amdgpu_amdkfd_gpuvm.c/init_user_pages()
> an MMU notifier is set up with a (tagged) userspace pointer. The untagged
> address should be used so that MMU notifiers for the untagged address get
> correctly matched up with the right BO. This patch untag user pointers in
> amdgpu_gem_userptr_ioctl() for the GEM case and in amdgpu_amdkfd_gpuvm_
> alloc_memory_of_gpu() for the KFD case. This also makes sure that an
> untagged pointer is passed to amdgpu_ttm_tt_get_user_pages(), which uses
> it for vma lookups.
> 
> Suggested-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Acked-by: Felix Kuehling <Felix.Kuehling@amd.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c | 2 +-
>  drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c          | 2 ++
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> index a6e5184d436c..5d476e9bbc43 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_amdkfd_gpuvm.c
> @@ -1108,7 +1108,7 @@ int amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu(
>  		alloc_flags = 0;
>  		if (!offset || !*offset)
>  			return -EINVAL;
> -		user_addr = *offset;
> +		user_addr = untagged_addr(*offset);
>  	} else if (flags & ALLOC_MEM_FLAGS_DOORBELL) {
>  		domain = AMDGPU_GEM_DOMAIN_GTT;
>  		alloc_domain = AMDGPU_GEM_DOMAIN_CPU;
> diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> index d4fcf5475464..e91df1407618 100644
> --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c
> @@ -287,6 +287,8 @@ int amdgpu_gem_userptr_ioctl(struct drm_device *dev, void *data,
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

