Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6559DC0650F
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:37:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1582A21871
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 15:37:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="aZHdw82y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1582A21871
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A10506B0007; Mon,  5 Aug 2019 11:37:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BB7F6B0008; Mon,  5 Aug 2019 11:37:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AA9B6B000A; Mon,  5 Aug 2019 11:37:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57CF16B0007
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 11:37:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id z1so53688217pfb.7
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 08:37:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BRP6laDcYsaagqowX6PM5vV1ql9YojC3f98ieQbfibw=;
        b=JNJkxhvstjI0Q2W5LiEBc2/27mSlC1o7/a5SkV7LpsNLz6nnoPtM95t+eSkBBH2SBR
         0hyH95NT08bC/zqDC1oE8eFQSSqiK3F685roWwN4JWRJoPzvaWItQR/WPtHKJdiC5xfl
         sELutstEKgt9eP94ZHI14su0HIRbRaw20tJCI52GchMjwSEjRxXqfWQKCgqONoGjkUoI
         B2UPVyw3KOQ7IOMhv1IISHtsyvhz0w1xdgSHLCYvbRSFBwA8ogp8qw9G/M3fZHZ5ERt7
         PTkUiMA8PEN2i0y0iYFfo9iUxhjgeStd7nJ6rxOUkfHmAQ2L9lyBCnny+6w/3LQH5WoA
         WNHw==
X-Gm-Message-State: APjAAAWhbmbjykfhrqg+CuCt1If8dJF8gxZbE0oJrrYwoR70t7hxTL94
	UjGq0bR+ZPdvwYT+1DkW7LtRhYLVcPKjfN5bjkxXMOMy2i/zwUt53vz/kynJqtEIBffjMESbTiy
	aMRt3YN/tvly6K2nYkKTsWGIkWKyqNSlnxoJLbnqngk+kp1RBHcQALPMbk6Lbi1Aikw==
X-Received: by 2002:a63:f857:: with SMTP id v23mr111840394pgj.228.1565019439653;
        Mon, 05 Aug 2019 08:37:19 -0700 (PDT)
X-Received: by 2002:a63:f857:: with SMTP id v23mr111840356pgj.228.1565019438886;
        Mon, 05 Aug 2019 08:37:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565019438; cv=none;
        d=google.com; s=arc-20160816;
        b=0ifH/k+Pz13YmnNnXHh0kNHA8ezH202VGbZ/LDzdKNd72U8kgIg2uHeOo4aR4h5UOl
         vH+vrLIMf2HHERSxLHCccZIYWVQV6+9j3Z1mF/MqGYa5FQx/tkzWsMupjWVfwZNbTOu+
         20UNKON8FN90b84cqXUcWcaKkHcQ2xz0SEN995D2DiLL6kwaoO+gxZNWMeGrjIKHo0vA
         qjHdPqurKZK2UW4Dz1bQTJtWhZUn5JBroxQ7w+V15Zjifuw0xi/jec98FnPTD4ihesSV
         9OiXRe3QprIPypX7bJp41puzPDa4kE0jXHkEoA6Ag+i5hROznhQKffnofmPrN7rmdNWQ
         aSPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BRP6laDcYsaagqowX6PM5vV1ql9YojC3f98ieQbfibw=;
        b=bTDeiXNpUAp63GJditQ9gm+mBIcIU1Xad6IqYFzPQUransldqQG16UvFbH2E1LaC0V
         1f43qGSVfHfayCsIJvCkXiiALpd/r+jddz1cH1+OTB0qzClhrkWUxPEU+oGopB/7EJWl
         5gkwshsobe7SZS8kcW4BtXI8aDqs8CCrJEUAs7veeYB3V5RLTL9iIvzebE3tslbwGNTZ
         lVH0kgByzsn2PK+hxgbxoSRGj2/iYa6/3QXzvv8ekIiF0sCVQ6trquiIU6gSS+9wrK3P
         UGXVINbJEUw46t5IlhTjxAYVMXOp3/C5jI1DCEoXQ33f763Op3n8UlxvaOo5IyZ6o9hP
         42Rw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aZHdw82y;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 75sor64590816pfv.11.2019.08.05.08.37.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Aug 2019 08:37:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=aZHdw82y;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BRP6laDcYsaagqowX6PM5vV1ql9YojC3f98ieQbfibw=;
        b=aZHdw82yWFty3hQVAzsHs2fUhyQvuwpZlVYSYWBLTB/8rupDAl0wKOFCYdmT2AVyM3
         bU4fhnvSzDKnLtiQ3rS7cijZ1Vv3IIZe4rRpc4rEibhv0ZDXZ9WOzma5OQlcS+kYc8Mt
         3aq2tOS5hdDp99Y8bIwoTjEQB80+ErgcnzBts/1QhdymZ2BjAdCta1VZ5xzoMpm6V2x1
         DZCYNyCjuRGW+uCHqJqV4KCP0MbZCeI9Yg5elIeOIapd0UtWSDxj7AOKYYjvTfNTK9V9
         yb22NKB3Py0XgnjBPYBGPZ2hy6herMOmpnsmUtGcyAepI5Z7zt4WR2w/bewU8Zp5+oIw
         3psA==
X-Google-Smtp-Source: APXvYqyQR0D20P/mnpoLOPlzIBaHmjQ7w8XW8u+YMSrUQUo8L+f9shx/FCzhOS5dVIpqRT8luECGQsvMeWq4moJNLGA=
X-Received: by 2002:aa7:97bb:: with SMTP id d27mr73075178pfq.93.1565019438226;
 Mon, 05 Aug 2019 08:37:18 -0700 (PDT)
MIME-Version: 1.0
References: <1564670825-4050-1-git-send-email-cai@lca.pw>
In-Reply-To: <1564670825-4050-1-git-send-email-cai@lca.pw>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 5 Aug 2019 17:37:06 +0200
Message-ID: <CAAeHK+xMQ5m-_eeQUPM2DoN=6OV-1uC6NX3dVnSKcmEqwSM5ZA@mail.gmail.com>
Subject: Re: [PATCH v2] arm64/mm: fix variable 'tag' set but not used
To: Qian Cai <cai@lca.pw>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 1, 2019 at 4:47 PM Qian Cai <cai@lca.pw> wrote:
>
> When CONFIG_KASAN_SW_TAGS=n, set_tag() is compiled away. GCC throws a
> warning,
>
> mm/kasan/common.c: In function '__kasan_kmalloc':
> mm/kasan/common.c:464:5: warning: variable 'tag' set but not used
> [-Wunused-but-set-variable]
>   u8 tag = 0xff;
>      ^~~
>
> Fix it by making __tag_set() a static inline function the same as
> arch_kasan_set_tag() in mm/kasan/kasan.h for consistency because there
> is a macro in arch/arm64/include/asm/kasan.h,
>
>  #define arch_kasan_set_tag(addr, tag) __tag_set(addr, tag)
>
> However, when CONFIG_DEBUG_VIRTUAL=n and CONFIG_SPARSEMEM_VMEMMAP=y,
> page_to_virt() will call __tag_set() with incorrect type of a
> parameter, so fix that as well. Also, still let page_to_virt() return
> "void *" instead of "const void *", so will not need to add a similar
> cast in lowmem_page_address().
>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>
> v2: Fix compilation warnings of CONFIG_DEBUG_VIRTUAL=n spotted by Will.
>
>  arch/arm64/include/asm/memory.h | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> index b7ba75809751..fb04f10a78ab 100644
> --- a/arch/arm64/include/asm/memory.h
> +++ b/arch/arm64/include/asm/memory.h
> @@ -210,7 +210,11 @@ static inline unsigned long kaslr_offset(void)
>  #define __tag_reset(addr)      untagged_addr(addr)
>  #define __tag_get(addr)                (__u8)((u64)(addr) >> 56)
>  #else
> -#define __tag_set(addr, tag)   (addr)
> +static inline const void *__tag_set(const void *addr, u8 tag)
> +{
> +       return addr;
> +}
> +
>  #define __tag_reset(addr)      (addr)
>  #define __tag_get(addr)                0
>  #endif
> @@ -301,8 +305,8 @@ static inline void *phys_to_virt(phys_addr_t x)
>  #define page_to_virt(page)     ({                                      \
>         unsigned long __addr =                                          \
>                 ((__page_to_voff(page)) | PAGE_OFFSET);                 \
> -       unsigned long __addr_tag =                                      \
> -                __tag_set(__addr, page_kasan_tag(page));               \
> +       const void *__addr_tag =                                        \
> +               __tag_set((void *)__addr, page_kasan_tag(page));        \
>         ((void *)__addr_tag);                                           \
>  })
>
> --
> 1.8.3.1
>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

