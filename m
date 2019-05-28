Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61883C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:27:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 304FF2075B
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 09:27:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 304FF2075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAFF06B0270; Tue, 28 May 2019 05:27:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B60A16B0272; Tue, 28 May 2019 05:27:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A77216B0273; Tue, 28 May 2019 05:27:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3E56B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 05:27:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y22so32179577eds.14
        for <linux-mm@kvack.org>; Tue, 28 May 2019 02:27:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bIUYCEpvnwlp8C9UTznLrS590xo1AYseDVaxhpikfkM=;
        b=ndmhbu5bBfMajzPAnZUwXKuKksO9lIQrecvsQsXz/TOnJM1p7XAkXSnkQE1f8EuTUi
         d9IuVFQrmHC+fd3IjIO1ixpiIzrCIQ80jlRt9V7dqWXHidq+rrZ9+XwrHIchJZViTzpK
         8m3d7CtRtMp9bg6YGxdgEhk3PEh3mqLbn+EGzrkjGi1Y6dL7oSYQSj8zkzoRTt4ASWop
         5UyvlGZhfsJY6LlNNN9WW/k25YftpU+tYFyYRb5LQLfg4uZE5Y4uzs4Qh0zhKJXhh/FK
         4+R1KpeBpDSdHcQACM9hqM7kERLwW8WUdLWE4VdJvlghgTT3xAmR2E9i9gixfWOp2vr0
         oHUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAWgSKGTgVGaXQiYBP9kK+CsHjFyO5T6s6XD5nGWAxT5k0lO2tpz
	Dwuj8A+qayAh2ONIduf7PTTlJlK3AntjDPWf3QnqnlOr1z5IsdDu9WG8bzvS/5Z+PFV+5NfeJ5q
	2Ea9J0wruqGYsQTTRjMYgzDNLPK8hjS46L55/SRIvhyi5VUWNhFU4fCxaTaKwX74ufw==
X-Received: by 2002:a17:906:5a08:: with SMTP id p8mr83800380ejq.276.1559035670946;
        Tue, 28 May 2019 02:27:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQFXDkBRWn0k9eIZmrSq3Lc8DjLe+yProUPFwS80H2Nq9LrZGgOxQA4CFK9oMfp/XXLjrz
X-Received: by 2002:a17:906:5a08:: with SMTP id p8mr83800327ejq.276.1559035670208;
        Tue, 28 May 2019 02:27:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559035670; cv=none;
        d=google.com; s=arc-20160816;
        b=fA7Mzyce1dJs7Ml+Yg0GyLG965366vLflBgAIx7VL2JPE8aBBkGyuUnT+0lGQ9W86i
         cPvVHdr+E9w7neMNTL2tSbkpYt6LbxTNw+kGmHkerCcP47zk1zr22f/ANnVI7WfT9Siy
         kB9aeBzHsyrdaFrYYoZz5a3wnfZlp+QdmV54OrUgB6V2BdtTWbbMK35OUe1zrxyRfGUt
         ycVahhJvLXWxNfYaxINrrLCdjq0kaxGqNtVFeV2R0gpTDi6KGVIjRAKrEeSKJK5C0sul
         UABi0+x8aO/N8GJGqDN3QCtTWFekUCi3jLiqcMgXFTz+7qLWPebQk8wSR3h1hG2hUrFz
         6scA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bIUYCEpvnwlp8C9UTznLrS590xo1AYseDVaxhpikfkM=;
        b=f5UvSFpmFM97MjESmbtDScyZckflCMoG+zvT1aBXyUxpOXeCOsb4oDfgKoUfT8Y6d+
         UEEvaVZKyqSR/+MTBkpWph28m5AW5J5x9kNll7ZruvX12PUi5blpMUVpZ6zYqR1pneXy
         wbUIQAVbPDlvALElcb9V8W7OWTCITbARAT7jO7bMc1ekMS8vOD2qqepbofDPFzJy+LV7
         bwAnz09UNGtgmS3Jw1uQPA804Tj6igYeHvOkPoWWyhCa5C+gGqjWjCZ3S3MnGIT78/b6
         Q3cwA93rMESGSuKtineOtfdqV4WSwOh/e/T5JzaptEvRe9v/DyNCBo8SFa0nuDtSZ3a8
         L/Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e18si3356743ejk.32.2019.05.28.02.27.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 02:27:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77336AE44;
	Tue, 28 May 2019 09:27:49 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 056F51E3F53; Tue, 28 May 2019 11:27:49 +0200 (CEST)
Date: Tue, 28 May 2019 11:27:48 +0200
From: Jan Kara <jack@suse.cz>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, jack@suse.cz, mpe@ellerman.id.au,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] mm: Move MAP_SYNC to asm-generic/mman-common.h
Message-ID: <20190528092748.GE9607@quack2.suse.cz>
References: <20190528091120.13322-1-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190528091120.13322-1-aneesh.kumar@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 28-05-19 14:41:20, Aneesh Kumar K.V wrote:
> This enables support for synchronous DAX fault on powerpc
> 
> The generic changes are added as part of
> commit b6fb293f2497 ("mm: Define MAP_SYNC and VM_SYNC flags")
> 
> Without this, mmap returns EOPNOTSUPP for MAP_SYNC with MAP_SHARED_VALIDATE
> 
> Instead of adding MAP_SYNC with same value to
> arch/powerpc/include/uapi/asm/mman.h, I am moving the #define to
> asm-generic/mman-common.h. Two architectures using mman-common.h directly are
> sparc and powerpc. We should be able to consloidate more #defines to
> mman-common.h. That can be done as a separate patch.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Looks good to me FWIW (I don't have much experience with mmap flags and
their peculirarities). So feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
> Changes from V1:
> * Move #define to mman-common.h instead of powerpc specific mman.h change
> 
> 
>  include/uapi/asm-generic/mman-common.h | 3 ++-
>  include/uapi/asm-generic/mman.h        | 1 -
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
> index abd238d0f7a4..bea0278f65ab 100644
> --- a/include/uapi/asm-generic/mman-common.h
> +++ b/include/uapi/asm-generic/mman-common.h
> @@ -25,7 +25,8 @@
>  # define MAP_UNINITIALIZED 0x0		/* Don't support this flag */
>  #endif
>  
> -/* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
> +/* 0x0100 - 0x40000 flags are defined in asm-generic/mman.h */
> +#define MAP_SYNC		0x080000 /* perform synchronous page faults for the mapping */
>  #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
>  
>  /*
> diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic/mman.h
> index 653687d9771b..2dffcbf705b3 100644
> --- a/include/uapi/asm-generic/mman.h
> +++ b/include/uapi/asm-generic/mman.h
> @@ -13,7 +13,6 @@
>  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
>  #define MAP_STACK	0x20000		/* give out an address that is best suited for process/thread stacks */
>  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> -#define MAP_SYNC	0x80000		/* perform synchronous page faults for the mapping */
>  
>  /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage */
>  
> -- 
> 2.21.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

