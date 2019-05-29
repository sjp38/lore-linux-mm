Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B04CC04AB3
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E76921670
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 08:20:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arm-com.20150623.gappssmtp.com header.i=@arm-com.20150623.gappssmtp.com header.b="cfjTgrme"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E76921670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04CC6B000C; Wed, 29 May 2019 04:20:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8E1F6B0266; Wed, 29 May 2019 04:20:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2EE46B026A; Wed, 29 May 2019 04:20:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 759FA6B000C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 04:20:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u7so1305927pfh.17
        for <linux-mm@kvack.org>; Wed, 29 May 2019 01:20:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Vv80Z7VGeE+yY87s35ZtbvL9SuF+bx88wizFFl2ddXk=;
        b=nl7DpHkzeTtaQO9y5LzXH6lx1KeyPVdhkOtxM0vQfc97em2fMmtHPUINRdA6GuzMJW
         JpszOX487gQcsJzJSW7ajJn+aUxXEmfA0ek9kuyTQvXLVbToLtQjDAk/mJsxLS/ESc2p
         xPf6++ZTg9l/GoHGcCMc3zxMx6rgUoIBR4jzvdBI9IKAl54nwswoHs2WE3s5c0PkszgV
         oxpQBm5tQATwzqFUZZMidXDKo9CB7f8b9V2PGhyQNUQbq7YeEtms8O7VFaNOnKoHh2Dy
         tqlRCMUGL0p6+3qTm5hKcyR4Q84V7dgI03wnHJlsFoJIIyxPV+6IZWPzbvhqTmCAbDWK
         7Btg==
X-Gm-Message-State: APjAAAU9USvBPxKWjCAtA0sqrySHYXu/5aY16KJ9Csb5KHHTUg9J03zM
	4pNNiJsA4Y7Tu1xikFc6s6yZiSbiAomlvHmVNzZgGh5LIoJKAzVKITHFjhViRiSMMDBjUtaxY9P
	AsZtUt4PSfcr2fcLkSgX7K8XfK70+URhs9EMJystIP4YTr4Dc1YeWu4hGWRwgrJ4=
X-Received: by 2002:a17:90a:6fc5:: with SMTP id e63mr1495549pjk.29.1559118010032;
        Wed, 29 May 2019 01:20:10 -0700 (PDT)
X-Received: by 2002:a17:90a:6fc5:: with SMTP id e63mr1495478pjk.29.1559118009085;
        Wed, 29 May 2019 01:20:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559118009; cv=none;
        d=google.com; s=arc-20160816;
        b=ghHTt4Cu4qUlxHqnglPBhT2eJp44cJ588Yig3f+q4l2Yp+Qxxq3srRqq0dek/Tvar6
         BxkpZEb3XMF8Ld87I2wm8TizaWLldckvXp4gN+Ss9rnjq4wFAzCVI/hkOpMxJ1UWgWsb
         lR8pY4iiIwfUI2pHgbhCMYqXl9aOiFhxFawOjL0EgaKFp3b3UBr+Qb0KPYWBKl8dNU+p
         dg3yxs0hwoNrKZxrzdF63gkeJe4auc6LT3q9Xj62Ev0LkBFqDBuV3IbuCeUkhvGQGh+5
         zm1KScAblXuaE5KsrZKqFCN+GpNiYKOHG4molyQCvaCFOJnfVGS5XToJvSNuCL7dgGJi
         3KeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Vv80Z7VGeE+yY87s35ZtbvL9SuF+bx88wizFFl2ddXk=;
        b=bAhf8oNqAFAhCj1eFDwU+8kUPpXwn29Mh9uZy5Mnx1ToR4fCXcxtjNZMjCS7WL75Qj
         1AGfv7smFov2D0xg+vE1CFEv7Y22zK4gNODUcGOmeszMXzVrTozNpHk082wKKYmotftV
         h1mT/O+dMnCoIT2RBVaHV4mUcSzy07dXgStpJuHsn1JYyBQMlHnYbvDj7ndI3CkiEaiQ
         C0LVp8DfyyUzN+hMNni0Q28+Hm0XnRW9BSew/UgYU3F58kP0OAf7uD2wtqQIImdgOAxc
         E+vIPWmeCTwUWtZsZymXHv24Oy62Asc9KO3JfWj3S8p6RILE+fq8J2HF3DwzR+fcd+i9
         AKAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@arm-com.20150623.gappssmtp.com header.s=20150623 header.b=cfjTgrme;
       spf=pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=catalin.marinas@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor20496609pls.45.2019.05.29.01.20.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 01:20:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@arm-com.20150623.gappssmtp.com header.s=20150623 header.b=cfjTgrme;
       spf=pass (google.com: domain of catalin.marinas@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=catalin.marinas@gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arm-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Vv80Z7VGeE+yY87s35ZtbvL9SuF+bx88wizFFl2ddXk=;
        b=cfjTgrmeffoPCrJhI+97W6QXKk6Oei6h+EWkEb+bEn4yMKwe1KRVmiSAlBitS3OzO/
         c/tyEKG5QaY9H27ocjqX9ClL17ehovMVcUt7YhQ8kf3rHXp6B9XpCCN0CcU6Si2UD4Nx
         WTLuuegGgJAghoxgukLP6Y9Wo0E6kJgeW38YPyxyZyjfe338LiEpC3p45UFWQN4O+BvI
         P8+xUi1O2II741hiIEFGS/WMLl/cV3IqvAqIQUVDdyV/KjU3XqOhV1WuYOFjyQW8PnY/
         amayHly2wRjC94U3jpS4czeAB54sIQF3S61+sOcP7srQnXtmIyeJXkceyyWrL1wlHCJt
         tFhw==
X-Google-Smtp-Source: APXvYqyfzUdsfOOybUfGF3T6xUuaMylLIfCMpBmv0G9MpnimsL2Jd8Uf2ws2u/OjSpGvnVZhNKSbhFpqsv/52XGO+Xg=
X-Received: by 2002:a17:902:f212:: with SMTP id gn18mr78134706plb.106.1559118008568;
 Wed, 29 May 2019 01:20:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190525133203.25853-1-hch@lst.de> <20190525133203.25853-5-hch@lst.de>
In-Reply-To: <20190525133203.25853-5-hch@lst.de>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Wed, 29 May 2019 09:19:56 +0100
Message-ID: <CAHkRjk5ChgbYGXCRG3ob3iCuggC3MVYqeJNNm+nnt6rCqo+b0Q@mail.gmail.com>
Subject: Re: [PATCH 4/6] mm: add a gup_fixup_start_addr hook
To: Christoph Hellwig <hch@lst.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Paul Burton <paul.burton@mips.com>, 
	James Hogan <jhogan@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, 
	Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, 
	Nicholas Piggin <npiggin@gmail.com>, linux-mips@vger.kernel.org, linux-sh@vger.kernel.org, 
	sparclinux@vger.kernel.org, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Sat, 25 May 2019 at 14:33, Christoph Hellwig <hch@lst.de> wrote:
> diff --git a/mm/gup.c b/mm/gup.c
> index f173fcbaf1b2..1c21ecfbf38b 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2117,6 +2117,10 @@ static void gup_pgd_range(unsigned long addr, unsigned long end,
>         } while (pgdp++, addr = next, addr != end);
>  }
>
> +#ifndef gup_fixup_start_addr
> +#define gup_fixup_start_addr(start)    (start)
> +#endif

As you pointed out in a subsequent reply, we could use the
untagged_addr() macro from Andrey (or a shorter "untag_addr" if you
want it to look like a verb).

>  #ifndef gup_fast_permitted
>  /*
>   * Check if it's allowed to use __get_user_pages_fast() for the range, or
> @@ -2145,7 +2149,7 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
>         unsigned long flags;
>         int nr = 0;
>
> -       start &= PAGE_MASK;
> +       start = gup_fixup_start_addr(start) & PAGE_MASK;
>         len = (unsigned long) nr_pages << PAGE_SHIFT;
>         end = start + len;
>
> @@ -2218,7 +2222,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>         unsigned long addr, len, end;
>         int nr = 0, ret = 0;
>
> -       start &= PAGE_MASK;
> +       start = gup_fixup_start_addr(start) & PAGE_MASK;
>         addr = start;
>         len = (unsigned long) nr_pages << PAGE_SHIFT;
>         end = start + len;

In Andrey's patch [1] we don't fix __get_user_pages_fast(), only
__get_user_pages() as it needs to do a find_vma() search. I wonder
whether this is actually necessary for the *_fast() versions. If the
top byte is non-zero (i.e. tagged address), 'end' would also have the
same tag. The page table macros like pgd_index() and pgd_addr_end()
already take care of masking out the top bits (at least for arm64)
since they need to work on kernel address with the top bits all 1. So
gup_pgd_range() should cope with tagged addresses already.

[1] https://lore.kernel.org/lkml/d234cd71774f35229bdfc0a793c34d6712b73093.1557160186.git.andreyknvl@google.com/

-- 
Catalin

