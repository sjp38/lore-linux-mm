Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D44AC468BD
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:48:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B566820833
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 03:48:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="D3MmOWnY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B566820833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 270E76B026F; Fri,  7 Jun 2019 23:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 220FE6B0271; Fri,  7 Jun 2019 23:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E97E6B0273; Fri,  7 Jun 2019 23:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id C7EA46B026F
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 23:48:11 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n1so2523138plk.11
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 20:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=RNlIE7RpVdU5f0iicQk2k5+1DUNsXJMHiELoWiOeeG4=;
        b=E3X8ruTg3z7tdJgkneFnBzCByd+Aw8wy1ut5SPXvXJTxG4XFAG0yv3vk6F4aYiW8ZL
         ovC7TlcC1TWcDf8wVbuaLEDv7qrMlhoM/SXozdH8GYk65xJnjPpg9fBjr10UqM4kEr/B
         QiMFlgfqbHuJcm7qQ381kU/fB/YEYANEXFJLWVS3Lh0AlHGXzVLy00vmFNiZUhG96b7N
         WNr4CNmOc/UDycwMuaQwCwu+Fdq4Ax0tL7dRc2lXg5W7hrsx5bJpWRAcp+snkQzcY58N
         rYrYZJueXPwYPQsMdbbckRrEJl+i6nBffD/PUj50E+gkaIKw4AMW7Tb5qVSbvNnUJSUU
         wMvw==
X-Gm-Message-State: APjAAAVCcJqXxzBvyfBk3YZS11apIksPXxPGLIw2msOXCIeZ+GWhxjTz
	U3M5uGPqG4vG0LDLfdvKllwHUGVtmWBtQv7GYn47SlNnMtHRxZcPR7oTOxgJLt34X5jF4wIRv7Y
	8+Tbo21gejzBS2bm5LnmMJfCccOsRcRpoEpPVdQSj4gR3z7bXfBewUhzBulDe0eNBsg==
X-Received: by 2002:a17:90a:62c8:: with SMTP id k8mr9095242pjs.21.1559965691348;
        Fri, 07 Jun 2019 20:48:11 -0700 (PDT)
X-Received: by 2002:a17:90a:62c8:: with SMTP id k8mr9095192pjs.21.1559965690193;
        Fri, 07 Jun 2019 20:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559965690; cv=none;
        d=google.com; s=arc-20160816;
        b=on2j663r/N0iypZ2BdnG7bGemOIvXTGxml/gq16eQkoFEqJe48qS0UZ7+7k7KTl4yg
         RKB3M2QT5I7OfrIC1K8ENdu5GhXJaZTlGkLUMTTLJxV0OQCzUvYJ67LWGx4qDps+LvnX
         LgqlohI89znnrAiwbBU5UWkqomqYk/h8seovmzEPXSHmsJ9rkZ1ntBGu+VtyJaqZmoTh
         412dtaz8bZjNkgArf+ctR0mVi6tG4wNuHnAWWWAKM7OgwmNIGseTT8V24/lnlCYWcXV2
         cEtIeV3JcQZ+r1qqKSnG7+1hDf6VOTyBcW7K4g93dCQmeYx+2UemDQjOyXs42dHTOr7Q
         v2WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=RNlIE7RpVdU5f0iicQk2k5+1DUNsXJMHiELoWiOeeG4=;
        b=evox5gKzzrgDVehuz4KPyWA6kYWJFi3Wd14VpXKEZPixFyuwXu4EC65vY/wyME9C6R
         WH+nvOMEzKdUdXG3Ss5P8h5jsrSUCMxIb2FL2fBD1jwsIN5Ams/3OyD5a2ZyLJkpON1a
         qBPZQpAZMOpzDZleLL+qO5SJXBAvUPjHEv5jc2bHgIP16xzGEwI+KIjVHqcRp4MSjt1f
         obZ3UEXJbCpTDywEht9xSo+EFf6rjl8kRfDU9ya/4Gf8JjIFJU+b/09yQ4Un698tgveA
         xfgS5c2p7qi9xcwXGOwfn1TEwpHhDyrxF8uGRHOyt4yi3hm5uZtYRfKJ8XElczRQLLFf
         ZY7A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=D3MmOWnY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8sor4845155plk.18.2019.06.07.20.48.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 20:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=D3MmOWnY;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=RNlIE7RpVdU5f0iicQk2k5+1DUNsXJMHiELoWiOeeG4=;
        b=D3MmOWnYob5UGtglFoMh75eVVkGVzLzcVT66trF4Vmsjdvy86taKH6QFas2mfzRzwj
         M8+OanNKrPI4fOGoGPo9/Uo5q+LH1LQX0K1IVkP72ijXTjagsPaUUaKA337dIrVp0dDF
         lHdVQs6LUPfUrx+oo7yXpxf993QJ3yfDpOh+8=
X-Google-Smtp-Source: APXvYqzUHOb4VtJencGcx41aqOHHoNwcDiffGcfqaDDdYTWrPV9XhElqMpS0fUjS81CjEO5luRHFeQ==
X-Received: by 2002:a17:902:d916:: with SMTP id c22mr34327398plz.195.1559965689632;
        Fri, 07 Jun 2019 20:48:09 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id l13sm3156889pjq.20.2019.06.07.20.48.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 20:48:08 -0700 (PDT)
Date: Fri, 7 Jun 2019 20:48:07 -0700
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
Subject: Re: [PATCH v16 03/16] lib, arm64: untag user pointers in strn*_user
Message-ID: <201906072047.50371DBE2@keescook>
References: <cover.1559580831.git.andreyknvl@google.com>
 <14f17ef1902aa4f07a39f96879394e718a1f5dc1.1559580831.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14f17ef1902aa4f07a39f96879394e718a1f5dc1.1559580831.git.andreyknvl@google.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 06:55:05PM +0200, Andrey Konovalov wrote:
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
> 
> strncpy_from_user and strnlen_user accept user addresses as arguments, and
> do not go through the same path as copy_from_user and others, so here we
> need to handle the case of tagged user addresses separately.
> 
> Untag user pointers passed to these functions.
> 
> Note, that this patch only temporarily untags the pointers to perform
> validity checks, but then uses them as is to perform user memory accesses.
> 
> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Kees Cook <keescook@chromium.org>

-Kees

> ---
>  lib/strncpy_from_user.c | 3 ++-
>  lib/strnlen_user.c      | 3 ++-
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
> index 023ba9f3b99f..dccb95af6003 100644
> --- a/lib/strncpy_from_user.c
> +++ b/lib/strncpy_from_user.c
> @@ -6,6 +6,7 @@
>  #include <linux/uaccess.h>
>  #include <linux/kernel.h>
>  #include <linux/errno.h>
> +#include <linux/mm.h>
>  
>  #include <asm/byteorder.h>
>  #include <asm/word-at-a-time.h>
> @@ -108,7 +109,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
>  		return 0;
>  
>  	max_addr = user_addr_max();
> -	src_addr = (unsigned long)src;
> +	src_addr = (unsigned long)untagged_addr(src);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max = max_addr - src_addr;
>  		long retval;
> diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
> index 7f2db3fe311f..28ff554a1be8 100644
> --- a/lib/strnlen_user.c
> +++ b/lib/strnlen_user.c
> @@ -2,6 +2,7 @@
>  #include <linux/kernel.h>
>  #include <linux/export.h>
>  #include <linux/uaccess.h>
> +#include <linux/mm.h>
>  
>  #include <asm/word-at-a-time.h>
>  
> @@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
>  		return 0;
>  
>  	max_addr = user_addr_max();
> -	src_addr = (unsigned long)str;
> +	src_addr = (unsigned long)untagged_addr(str);
>  	if (likely(src_addr < max_addr)) {
>  		unsigned long max = max_addr - src_addr;
>  		long retval;
> -- 
> 2.22.0.rc1.311.g5d7573a151-goog
> 

-- 
Kees Cook

