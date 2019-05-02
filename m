Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CA9DC04AAA
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:25:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 174A620652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:25:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LjkcsxEi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 174A620652
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4B1B6B0003; Thu,  2 May 2019 12:25:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D40D6B0006; Thu,  2 May 2019 12:25:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89C096B0007; Thu,  2 May 2019 12:25:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 514F76B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:25:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d12so1490046pfn.9
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:25:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rEKMwcrb+5WeSacp64Kz5FEoKnzrouBIBJCgUjJL8pw=;
        b=FAzXtpCt7Vr1QcnVzWQy1XYLImo0yYMaxpN2VTvr1g9vwSAK1MuzgB/0WaJcl51lB0
         XS4qADqWWdJAmrbYqLVkQPTjHLaNxXEfX+OJO7aQ1UYXyKVJW7USjvr6hmF8QBzoHLV6
         I5n5zgPKEUHx9ULre7E5djd5SgHT2gtEYGPyr9q21sP80KnMwoEsBChjrNMAD4BCMwZC
         NK8TlimHRfDCtFAPEJnSCwzhgX/uCS2ZP0c9BHjCNF8OaEQ+FV2lF5O5IPd7AmEw89Fv
         JXKG8qKHCdWVlrmS2vo5Rl0QyUGqBmaYqQT62Wix71SOduaaX/lkvcu8k0nhesUyYGZ+
         ADIg==
X-Gm-Message-State: APjAAAVWdg0usYJ+A7OHiuve0Dl8iMjYxg/zGmutLcsS2UUpjqicP60u
	1kiUw0HE2wf6Lz3gsoLb9Y2jZWlCqB3PKhHn0DCpNNGWnK2+0VJH8HQWWdycq57WjGx9s0HX+4U
	/rt375/ZPr3jK6Al8bgy3wIHvDwNqkW+bQcTPUP62zTaxxdS9Y2O+d0ZfdJzptCxSng==
X-Received: by 2002:a63:c145:: with SMTP id p5mr4770179pgi.339.1556814299941;
        Thu, 02 May 2019 09:24:59 -0700 (PDT)
X-Received: by 2002:a63:c145:: with SMTP id p5mr4770107pgi.339.1556814299069;
        Thu, 02 May 2019 09:24:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556814299; cv=none;
        d=google.com; s=arc-20160816;
        b=PBIOPstWlHBXLX3Je/xHuZmJihSGHiI3I64jA4LfpSZAZuU1ra/X9S1q3tSIbGhBde
         t4grXnpvUcSL/tDWDr3xKbblZ3BHcohMe4g0g2MLaosqeTnh+NFyERxI0UOCEJgeMei1
         gIXsUzD1DeRbnepYZA4o5cVsJ6cJz8nH1gg/V4BBhz6yfwIboLN0v7YbL+uNp6yB4RTE
         TUhNfU4KPGCP1qaQvepr3MHMvHi72SIbrgAMr6/enGZMCLzQoUcWcHuhjB4/gQsgaMra
         j5DxHdqN5v7dLBYWr+XJp/hP2wpqk/QFyU98o37/4GR1rbLh2zE1i8iTk2qo85Fb6Nkj
         Gwxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rEKMwcrb+5WeSacp64Kz5FEoKnzrouBIBJCgUjJL8pw=;
        b=vvWXtdcpTnPVvZV9sCTLO+3amqv9S8iy+pi/Z6WwO/xJ2tA8enzYDToyA2lwENpCcw
         gp5MCw2OBzfBAeaoV+0oJ2a6q/uDcWV7DWpPUMOv7pyOxXg7qM/+QbEEM3RWzpVO1i67
         G66UCd5rWQQjGSGDK6qAL8BvYr+6svCsMW1dgbedNtd7RyY+JYd4pTiMcWWRcY3dRWGP
         UdEW3Ubre3HUtOHdwABXlG1rIJASyZLeeCiqpNW5r42kdKyW7LlplteA9Q0wjo4rrt53
         TfAN0iiw1S+uP5Ru5QFENRBP9j/asQiqklSPwLm53ZnsjN0NUbVOgRQDCX8gr2iVG6Sp
         W92w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LjkcsxEi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19sor8302995plr.68.2019.05.02.09.24.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 09:24:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LjkcsxEi;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rEKMwcrb+5WeSacp64Kz5FEoKnzrouBIBJCgUjJL8pw=;
        b=LjkcsxEigQRyF9OlwvXAi/j2a8iR0fHL5qiD6sBguYmhHkAwawMycCLskwUcIIVTez
         CARFExgvCLEQQCTf2E6r+e/meuaODxpr49RcPwVp/36qPFt1+sx/X1LnGMKdEJqDhoTt
         Fu6/5vIrBNQOofwhZEXvdJ14D4CTnasVx2JM5ifN5CyQsm31ZeWd696LBSmDM9RzQGQJ
         guhg0kow6boUf322o8sKzF7b0iL4J5xuKIjbTMQ54M1M+7mQ226GtBNEuJFBXykGgk9O
         dDy2mzG25rY1ChIRqqe+crGrlLlOel5BrkV7w9iYOIwiX+ULaQY5Q/sieG6s2iPjtIPT
         WKdw==
X-Google-Smtp-Source: APXvYqwQ47Ewt1KF1SgJkAi9tpyduw0g1Ut08HvBNe2zOaZpXpsTNjFCl7vVftdeSPPrkrdgyQP/QgozrrqKX6+qO+o=
X-Received: by 2002:a17:902:56d:: with SMTP id 100mr1090671plf.246.1556814298380;
 Thu, 02 May 2019 09:24:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190502153538.2326-1-natechancellor@gmail.com>
In-Reply-To: <20190502153538.2326-1-natechancellor@gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 2 May 2019 18:24:47 +0200
Message-ID: <CAAeHK+xb8oV_YuVHJivW9c1R0h=AWA_-G1K28GPiZmF9LO_FAw@mail.gmail.com>
Subject: Re: [PATCH] kasan: Zero initialize tag in __kasan_kmalloc
To: Nathan Chancellor <natechancellor@gmail.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Nick Desaulniers <ndesaulniers@google.com>, clang-built-linux@googlegroups.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 2, 2019 at 5:36 PM Nathan Chancellor
<natechancellor@gmail.com> wrote:
>
> When building with -Wuninitialized and CONFIG_KASAN_SW_TAGS unset, Clang
> warns:
>
> mm/kasan/common.c:484:40: warning: variable 'tag' is uninitialized when
> used here [-Wuninitialized]
>         kasan_unpoison_shadow(set_tag(object, tag), size);
>                                               ^~~
>
> set_tag ignores tag in this configuration but clang doesn't realize it
> at this point in its pipeline, as it points to arch_kasan_set_tag as
> being the point where it is used, which will later be expanded to
> (void *)(object) without a use of tag. Just zero initialize tag, as it
> removes this warning and doesn't change the meaning of the code.
>
> Link: https://github.com/ClangBuiltLinux/linux/issues/465
> Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
> ---
>  mm/kasan/common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 36afcf64e016..4c5af68f2a8b 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -464,7 +464,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
>  {
>         unsigned long redzone_start;
>         unsigned long redzone_end;
> -       u8 tag;
> +       u8 tag = 0;

Hi Nathan,

Could you change this value to 0xff? This doesn't make any difference,
since set_tag() ignores the tag anyway, but is less confusing, as all
the non-tagged kernel pointers have 0xff in the top byte.

Thanks!

>
>         if (gfpflags_allow_blocking(flags))
>                 quarantine_reduce();
> --
> 2.21.0
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190502153538.2326-1-natechancellor%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.

