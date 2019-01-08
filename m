Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01E35C43444
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 04:51:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF7DA2089F
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 04:51:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="CGcrzugW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF7DA2089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 578308E0052; Mon,  7 Jan 2019 23:51:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FDB58E0038; Mon,  7 Jan 2019 23:51:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39F158E0052; Mon,  7 Jan 2019 23:51:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC498E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 23:51:33 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id h7so2269074iof.19
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 20:51:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WzLE1kl1n8qfTCuciv1x7YgTzmk4xHvqyK6zizNAsLQ=;
        b=fIXsaZm/pHPweLaBPClyEUjCi2xRLrmNJXlw7dcTjSRXBOH8hVDN4T8cAzg14Tz/0l
         WEAcvxDKEyw7C3Dc7aWKFo8dyL77oM3H8f1RCh8j/L6vwyiWzqCgl7x5DWfjfFr4ZeZu
         7xlx+wodsUr8hQ/JaZ95kD1YzFt5eH9vs7QUDBeH4V6ryGBWfeFMt6OWGDJd/kdKNFh2
         pP4W+jgNlKCBGruv/HHzuGkr6uvTLOIftK6ZgYZxRRSHq4KbaR339DfSwUqArQhslmiQ
         BPtm93PYBsdJnnBk3mW44NTxgodnQZzGQ9SUsJyGdKarFSnjGzJrJfZ9aC9hx+JHTej8
         eaMg==
X-Gm-Message-State: AJcUukf330LJbprXQ/TNO0gN3MxFIN9PxcLB7HvxTaWUSEePwHHomNp8
	TgK963DYTA3tkh0z7gjXO27GF7JVO+uDx+/0p7T21kvjhPidRSFDA4sHD7dSedIGq0JoLk58fxJ
	RunTDWBgTZx7ib0PoMWVyS5OfQxMATN+y6fBbiJihtvF5KWoMKZEoi7a5vdliNOAxsc8hS0mLSd
	oTWdG/BA1BWefGCE8+BbLwbwuamUt1QmJw54vUeKE9g6NOprnNRrJpnJVv0c07wyg+OgpaTXlQ1
	rtB84/MDkBkSb42lwSWTnKAj4PjZfOpYDofGlUnEr6uAbpaYo75L4ffpP8PwUH2rn0SGuweQe4X
	btuhCQtw2SUZnm3kA3BJ/YgPbDdq7Ykek7suw9Ikq3srmVKw9XFWSTTacqqPLsSC/iseMRrHW9G
	g
X-Received: by 2002:a02:5c0e:: with SMTP id q14mr151531jab.13.1546923092759;
        Mon, 07 Jan 2019 20:51:32 -0800 (PST)
X-Received: by 2002:a02:5c0e:: with SMTP id q14mr151521jab.13.1546923092036;
        Mon, 07 Jan 2019 20:51:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546923092; cv=none;
        d=google.com; s=arc-20160816;
        b=OHux4iJ7CkaTYoNBV2T7871zAVr50WLYiSQLGeMcpzQmjNf0anIn5TipAHp5e2S1jg
         iHVCuvZH4t0WqyocMLfi1scGuLidyR1/kJ3iA4qL3Zlxdt3Pwsnc0eXLv6GZHFQv796k
         eUI6GuSaMRGTMGvyugFMrBWXWN34jjgNtbuuySsb9Ugbl8EIke2bcZMXoUbFIbsvVWQ3
         42uaswTbKKibE2YdWcpK/QVzI1v4nFDyP5OLCgctuJNaAtArgDqBmI+/KtjzaG3xX4pG
         /CiPw1OsHF+fMnGh5XoknEd7lifzV4lyPNAkx+EGFHw7QWr0zrzsfMs/eOoa6c683Z9b
         QVtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WzLE1kl1n8qfTCuciv1x7YgTzmk4xHvqyK6zizNAsLQ=;
        b=sylVhtV0F77tglHhp9OEje5NjD4apy9KwgQjPO5bBqbVO3Hv3OJCthcZbfRmqmDFWQ
         ohnw0LBUWm0vjC4n4/mdvsJ71FVjqZcnKesTEAM4nm97BSzsOUzlBOsDi9PsMDuCNws6
         xbK6DPWU0rmQMVVcOIMMcZ3rLpejqDByNyie0jflXdVGlVJ5e8KrWJLOpfCiJWpVqsEN
         A1OHSrOvaIPC/2w861DuFjIHulbvytGE6HEnzX9xRwkghJvw8WJVPZwxyUwdzLT+VP3h
         TQj1LxppaebNwbmlbpVaR7BhS8e2BQIfz2NokNFE6/f8sZKXDsWl+/vfCM8P7yCbrWTS
         Z9Bw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CGcrzugW;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i138sor28804053ioa.32.2019.01.07.20.51.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 Jan 2019 20:51:32 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=CGcrzugW;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WzLE1kl1n8qfTCuciv1x7YgTzmk4xHvqyK6zizNAsLQ=;
        b=CGcrzugWjzCZw5wd+yyC/qHn/OxPNIIQOiOTLkty4jiVxNtNQ/28SXXw4A8++QUkoL
         k0CuF1r7v7NqlMBT6FdTAxNCkHKOZ1RvyWPqHU4QG0gnVd13dEfA/GnK0LnmmyWg29I4
         a1BQpJAhruVWnN7bKqTly7Y1ac3/sx305nUFhx1POGxUWdqXSyRcS0QFCosJHXucsydC
         +cYHGH0AvvI8lklaXlpaPd1vHRZA1dZ75stD8RsknCTJHkFfISX4GTgLvSHSdRVKinzI
         FAsgm1D5fMjy9NvkoZMoC2Qv2vigf1vi8jY+fkVcBGQ7USC4JuSEiPnK5QYvWvSgo4Az
         sTXg==
X-Google-Smtp-Source: ALg8bN4sBBSAdKbPLoQEdQAzvStAUHALlV+Km6a/VTB/m4SrK593H6R74AvEFkxCfwGJ0vmLKRWcGWxRpMPH62W+Fy4=
X-Received: by 2002:a6b:fa0e:: with SMTP id p14mr118472ioh.271.1546923091512;
 Mon, 07 Jan 2019 20:51:31 -0800 (PST)
MIME-Version: 1.0
References: <20181211133453.2835077-1-arnd@arndb.de> <20190108022659.GA13470@flashbox>
In-Reply-To: <20190108022659.GA13470@flashbox>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 8 Jan 2019 05:51:20 +0100
Message-ID:
 <CACT4Y+a_LB6aVoLEcFVJhP40D9E4MM3T=7-0aBhFvBffXgNZmw@mail.gmail.com>
Subject: Re: [PATCH] kasan: fix kasan_check_read/write definitions
To: Alexander Potapenko <glider@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Anders Roxell <anders.roxell@linaro.org>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, kasan-dev <kasan-dev@googlegroups.com>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Nathan Chancellor <natechancellor@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108045120.5MHZRwYHc7tSqGFIPmoTn4Eb-_lgp69RfkHK-qNlc6E@z>

On Tue, Jan 8, 2019 at 3:27 AM Nathan Chancellor
<natechancellor@gmail.com> wrote:
>
> On Tue, Dec 11, 2018 at 02:34:35PM +0100, Arnd Bergmann wrote:
> > Building little-endian allmodconfig kernels on arm64 started failing
> > with the generated atomic.h implementation, since we now try to call
> > kasan helpers from the EFI stub:
> >
> > aarch64-linux-gnu-ld: drivers/firmware/efi/libstub/arm-stub.stub.o: in function `atomic_set':
> > include/generated/atomic-instrumented.h:44: undefined reference to `__efistub_kasan_check_write'
> >
> > I suspect that we get similar problems in other files that explicitly
> > disable KASAN for some reason but call atomic_t based helper functions.
> >
> > We can fix this by checking the predefined __SANITIZE_ADDRESS__ macro
> > that the compiler sets instead of checking CONFIG_KASAN, but this in turn
> > requires a small hack in mm/kasan/common.c so we do see the extern
> > declaration there instead of the inline function.
> >
> > Fixes: b1864b828644 ("locking/atomics: build atomic headers as required")
> > Reported-by: Anders Roxell <anders.roxell@linaro.org>
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > ---
> >  include/linux/kasan-checks.h | 2 +-
> >  mm/kasan/common.c            | 2 ++
> >  2 files changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/kasan-checks.h b/include/linux/kasan-checks.h
> > index d314150658a4..a61dc075e2ce 100644
> > --- a/include/linux/kasan-checks.h
> > +++ b/include/linux/kasan-checks.h
> > @@ -2,7 +2,7 @@
> >  #ifndef _LINUX_KASAN_CHECKS_H
> >  #define _LINUX_KASAN_CHECKS_H
> >
> > -#ifdef CONFIG_KASAN
> > +#if defined(__SANITIZE_ADDRESS__) || defined(__KASAN_INTERNAL)
> >  void kasan_check_read(const volatile void *p, unsigned int size);
> >  void kasan_check_write(const volatile void *p, unsigned int size);
> >  #else
> > diff --git a/mm/kasan/common.c b/mm/kasan/common.c
> > index 03d5d1374ca7..51a7932c33a3 100644
> > --- a/mm/kasan/common.c
> > +++ b/mm/kasan/common.c
> > @@ -14,6 +14,8 @@
> >   *
> >   */
> >
> > +#define __KASAN_INTERNAL
> > +
> >  #include <linux/export.h>
> >  #include <linux/interrupt.h>
> >  #include <linux/init.h>
> > --
> > 2.20.0
> >
>
> Hi all,
>
> Was there any other movement on this patch? I am noticing this fail as
> well and I have applied this patch in the meantime; it would be nice for
> it to be merged so I could drop it from my stack.

Alexander, ping, you wanted to double-check re KMSAN asm
instrumentation and then decide on a common approach for KASAN and
KMSAN.

