Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8C33C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:41:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CB342089E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:41:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="pW9Mlh00"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CB342089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18CE36B0007; Thu,  2 May 2019 12:41:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 163716B0008; Thu,  2 May 2019 12:41:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 079E76B000A; Thu,  2 May 2019 12:41:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4EF46B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:41:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j1so1523849pff.1
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:41:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=92karzGId4kTiPxbclHEQu/kjCIMGVKlDvLxWKLPllQ=;
        b=rGxWEJgtqnBrA7JdS+0vTkm6pM7yhRjPJGieNx6ofrvWu+zkcsudgLnPtgO4PQ8E7Z
         mN+nG8i24mNqCndfeffJMQtUHjgaSBoMs8hXn33sYdDGj8+N74RuYGmzY7xcWjchKFqe
         +VYyD0qcgFdH66Dk4DpoZi+NgNCJpoufryRKUBmSW6B8aMsEjxBCqJk/woPIJoBrWfLR
         8caV+JS+tXZi8UI0QTEP5ILDQ7H3g6eD2RqsrW55YFehDJ9zz/W8Nt877IIb4r+FEvJY
         tYQJq62pdZ+J0JutxHAZAUTGUSrzbxFR93mKSAZHr1WKb4hb+yo6gIgLQnfd3sZwOlXS
         7lcA==
X-Gm-Message-State: APjAAAVNDqZECs5lNHCUN+HWByCaO6syaooo1rXluaTxdb6+FvNiqlv/
	G9RirGmjOG56T/lp+Ijmmr4wi2WBhqo+BpHA2s26BvspjJFW0SvnMv2d92Xon2/Ky9HZuNBcRuj
	kmsPwVSbVrjp3sQPnGPsXJgr/FkclUaLxQlZZPFnvtzqWiUhGTdUWomEzRCzAjfM0YQ==
X-Received: by 2002:a17:902:102a:: with SMTP id b39mr4824916pla.188.1556815265396;
        Thu, 02 May 2019 09:41:05 -0700 (PDT)
X-Received: by 2002:a17:902:102a:: with SMTP id b39mr4824861pla.188.1556815264723;
        Thu, 02 May 2019 09:41:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556815264; cv=none;
        d=google.com; s=arc-20160816;
        b=dqLIKbEqY6MtZRVbQUtUx2goHOCoNUzD4liB1Mueq3k+A92R0mmWKiF7y016w8QEPA
         B8LfElt+E0lFF64xO38j/VmbOLRjfaQXlQOAGZq3rmYRPJxb2xzZ9fzGpBC84x6JybFg
         ESOpGz1nX9Xi/cgEsc3U0Iafw9oo+9xDO2l+cU9yizr6Oocv0e743PH7h1dd2JsOcHvD
         uZJipnudj5tDtMeCtGTJINDGbCh82ISKpFDsrO/YOq8rwZzxrVh74PV5EmgE0kYbLQ/f
         Nz+WbjWpv8PPDJ6uXN8DdrLAIZMBax5/3L/VWQAutsbxiIsgh+w1QFHPxptX7Q6Lqp2J
         Chjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=92karzGId4kTiPxbclHEQu/kjCIMGVKlDvLxWKLPllQ=;
        b=02KgwUgXyqUjPMYr5lSu706JmcAbe9BxjqkTIVW0CbFLBUPVHgvd3FF4LwJxVhwq0c
         E7Tz2vdr3IxEML80uDD2O00vGVUGUd6y6tCdFN5OS7a3RTz972/ZN/QG31H14IULIo5L
         GBvOm1aLJp7lsVh01ypadRKyTsw4vqZDRSd2CdNbz8YTbjQ9Ld7hK0o8ZPJntyohxNN3
         IP1Nsq9ZM5OdfIPIHbNBMljWqNu3RI6pOJjjPtvdVcbvl9jcJXptTcJ+NqIhz0CZcNvs
         l3X3h+3ljO8GPuv7e724RO45PB9LaJseGJrFX7f5DzjQPthHO/dG/hb++NE9dHS7GlvG
         eDuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pW9Mlh00;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t4sor5565825pfl.69.2019.05.02.09.41.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 09:41:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=pW9Mlh00;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=92karzGId4kTiPxbclHEQu/kjCIMGVKlDvLxWKLPllQ=;
        b=pW9Mlh00pTbPzKKMewhu5d9r6gm71AyCd5VE3PXTq9/6KeJWTWX9VAdyklQe4wuYb3
         hw6/lCKfgP3MBQuvHSNTnDii93JeoAZ1tz36Ilk1XAnuH2tR8iS45vHy63ek7KeVo8Kv
         pPaZFSX+7KB1/bAO/KXNp2pKUm1C86PLwVWmBVtbE1JqIgA3KIcb1b/b7Ng6bjqelicY
         6DQAN7is5Vz8aCc+ZcoCa9As2irNjbQGXPT3N7cDSP18s23973KvWfDy7jubbL2cvXcF
         9fU8o6qOaaYqh7iOQW85PTkzEhusyPBLF2Ti3wgqhnyl9L/q3tU0Sq/+WyRxSAFHojV5
         aVVQ==
X-Google-Smtp-Source: APXvYqxEpi/34FQTQo/i2+QqbKQVsIw9n+cFj3zq5T2pXhuwK8N3k0YF3vpXL1+twKXJJwXv+Ny1FxDYEUV2ic9nRnQ=
X-Received: by 2002:a62:46c7:: with SMTP id o68mr5390737pfi.54.1556815263742;
 Thu, 02 May 2019 09:41:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190502153538.2326-1-natechancellor@gmail.com> <20190502163057.6603-1-natechancellor@gmail.com>
In-Reply-To: <20190502163057.6603-1-natechancellor@gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 2 May 2019 18:40:52 +0200
Message-ID: <CAAeHK+wzuSKhTE6hjph1SXCUwH8TEd1C+J0cAQN=pRvKw+Wh_w@mail.gmail.com>
Subject: Re: [PATCH v2] kasan: Initialize tag to 0xff in __kasan_kmalloc
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

On Thu, May 2, 2019 at 6:31 PM Nathan Chancellor
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
> (void *)(object) without a use of tag. Initialize tag to 0xff, as it
> removes this warning and doesn't change the meaning of the code.
>
> Link: https://github.com/ClangBuiltLinux/linux/issues/465
> Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>

Reviewed-by: Andrey Konovalov <andreyknvl@google.com>

Thanks!

> ---
>
> v1 -> v2:
>
> * Initialize tag to 0xff at Andrey's request
>
>  mm/kasan/common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> index 36afcf64e016..242fdc01aaa9 100644
> --- a/mm/kasan/common.c
> +++ b/mm/kasan/common.c
> @@ -464,7 +464,7 @@ static void *__kasan_kmalloc(struct kmem_cache *cache, const void *object,
>  {
>         unsigned long redzone_start;
>         unsigned long redzone_end;
> -       u8 tag;
> +       u8 tag = 0xff;
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
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190502163057.6603-1-natechancellor%40gmail.com.
> For more options, visit https://groups.google.com/d/optout.

