Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38AC2C46460
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:51:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4EB620833
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 15:51:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Q5IfUkcu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4EB620833
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D8FA6B0003; Fri, 17 May 2019 11:51:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 588F86B0005; Fri, 17 May 2019 11:51:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 478716B0006; Fri, 17 May 2019 11:51:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 264676B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 11:51:30 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id 203so2695329vkj.10
        for <linux-mm@kvack.org>; Fri, 17 May 2019 08:51:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=K3Vrlw7jjRTYTYz1AgzZI4h2eYnMN5BSgG9wzkqpLb0=;
        b=PWL8T7LQjI5F691OqKvj+HoGkKzKw0bzQPV6oO3KtHPP01e73G89Z1AzDKP9YxudOq
         P2wTLINOBJ9eBf+2Aog5IknuW0L2hkXG9540Ds/lzM/iRDWbFv6rn6zHjL5IIiYBoZx5
         0tzNnlmQlD4jGX2HDTrqw2LdDuG6d/rf0qbsPn9ZVxuYJKMe0rB8Nw+jTy0EyXoPlkcK
         05ULoZJ6f8KR0+hRyWHNVBd6x/zc3Q/A008hQ/16NQhIw4R7fG12LMaFrYs0vCyzFM/A
         zPeDVBA3i/iYxu2g21x6mSXFSEFgltSyubrOF6s17J2Mc8vAqiYN8mr/FQs/A+ABs8B3
         /yiw==
X-Gm-Message-State: APjAAAVsBx2Hktv5NtlVAdP7mIHEcMYlfalgWID/z8xd078TJCtfNKFf
	Kjd974bqJeLcL7yK9ISxl4cydvn88ot7t8y+BCCzhhPTyIeojoYg6u7YQnSXjNJ3gcdmjZdwUyY
	n3SX8qeeHbVPTWaM06jZv52XQMpUYn6fq1M98RaKpMGx/HeD7u8BECtKo1qYNF2Q8Kw==
X-Received: by 2002:ab0:44a4:: with SMTP id n33mr4547519uan.17.1558108289847;
        Fri, 17 May 2019 08:51:29 -0700 (PDT)
X-Received: by 2002:ab0:44a4:: with SMTP id n33mr4547474uan.17.1558108289081;
        Fri, 17 May 2019 08:51:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558108289; cv=none;
        d=google.com; s=arc-20160816;
        b=bZ5LYqCLCULkNLvApoSMMcJ1FMjBDgXwYVWKa/RwfV7F/m3keY3qZOXTMl4EfQfZyj
         AJzbUATIUYlQ8vBGb8AZlcKzI7oJ6dwZdeYe0X5Q4qgiSoQj0SfsyR9bNxmHaRGxlVJI
         5IbosyLo3HlImCZEo1kNwEpB1MIFHYoQmFKAPHAXH2bOaG6Ot6IyOACUDVobMo8zNWdv
         DvZ4q0/HnckG9iTmSPXqHJ9QPqH/HRKShd7vPmbxG7RhO7dlGe7fM8KSpylH0AS/7NyL
         iTgLOAPzWzvxD9xpgYvA6Y5aOjA3Xg0yLFZEv4nyHIREo0gtuMyvt3IXcXgl+yfFpPFg
         VNoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=K3Vrlw7jjRTYTYz1AgzZI4h2eYnMN5BSgG9wzkqpLb0=;
        b=WH06t5UBEm7eGtIX/0fh5hy0BcVngYwzo6BgH90eJt3QPZBV4fNZLN5yVpW/p3wHpo
         U2nBeJ5zW8yyWLkTefFLhCH/UAerIa38LchZ/11miWTEKVOBcNN87NNegOT55tY1AKyt
         hHQh/S9B855nZCxlu8EXCpZWo2aRcVrMJYR7FRSJKNcMKNCux0Zq+Fx6YyD7Yju6kk9h
         cCcnbE0HWD8X3Doq/vk22BsCP3SBoWtou6sAnnhVerA9wksZlZRg4UW5ddhhKcw821xB
         yuLjZ4QkmEuNWqCW3m7tA29zABDz5+FLBNZyPeiDmtVpVqD28v4zVlPsniG5lqQNcKBm
         0M8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q5IfUkcu;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g30sor11367078uaj.23.2019.05.17.08.51.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 08:51:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Q5IfUkcu;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=K3Vrlw7jjRTYTYz1AgzZI4h2eYnMN5BSgG9wzkqpLb0=;
        b=Q5IfUkcu0WjvcwlvR433YNjz64oeJCmRNDPkXbu+8hETl16gDKE6zTXpu6p7dkY4N6
         eVDjSXDI68k8ExtJHdN9UzmOP59bD8K8byBeWHXqf412MKC5e9prPRzi3StboEwqSfBQ
         8ZR2HIXUoQdqnMfp5QvDj8NFr5+DgQqGn8+ijVud/bPYdLOjbXeDS2j2K65qMHQbSC5v
         uZqu4G2sBJesTbY1c/9Aw5oiSoi6puEXKeTyG20jFKniAvjJRF/Pt1fqyb5+ev06/pNi
         1COM50IkfipdjLx3eakFwDTxCMtxfKpDbmZrjSvtJNABugPn0s2DEgjjb6XW07fkNBX/
         cpXA==
X-Google-Smtp-Source: APXvYqyHBgjr6zQkV0VRITOnSTFo/Csy6VlzF4/NnOlUkrs7+IUo77Uxkz08YROnpav8K6N0iIzd8ewuExL2rchVXBY=
X-Received: by 2002:ab0:d95:: with SMTP id i21mr22915022uak.110.1558108288339;
 Fri, 17 May 2019 08:51:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190514143537.10435-1-glider@google.com> <20190514143537.10435-3-glider@google.com>
 <201905151752.2BD430A@keescook>
In-Reply-To: <201905151752.2BD430A@keescook>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 17 May 2019 17:51:17 +0200
Message-ID: <CAG_fn=VVZ1FBygbAeTbdo2U2d2Zga6Z7wVitkqZB0YffCKYzag@mail.gmail.com>
Subject: Re: [PATCH v2 2/4] lib: introduce test_meminit module
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Jann Horn <jannh@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 3:02 AM Kees Cook <keescook@chromium.org> wrote:
>
> On Tue, May 14, 2019 at 04:35:35PM +0200, Alexander Potapenko wrote:
> > Add tests for heap and pagealloc initialization.
> > These can be used to check init_on_alloc and init_on_free implementatio=
ns
> > as well as other approaches to initialization.
>
> This is nice! Easy way to test the results. It might be helpful to show
> here what to expect when loading this module:
Do you want me to add the expected output to the patch description?
> with either init_on_alloc=3D1 or init_on_free=3D1, I happily see:
>
>         test_meminit: all 10 tests in test_pages passed
>         test_meminit: all 40 tests in test_kvmalloc passed
>         test_meminit: all 20 tests in test_kmemcache passed
>         test_meminit: all 70 tests passed!
>
> and without:
>
>         test_meminit: test_pages failed 10 out of 10 times
>         test_meminit: test_kvmalloc failed 40 out of 40 times
>         test_meminit: test_kmemcache failed 10 out of 20 times
>         test_meminit: failures: 60 out of 70
>
>
> >
> > Signed-off-by: Alexander Potapenko <glider@google.com>
>
> Reviewed-by: Kees Cook <keescook@chromium.org>
> Tested-by: Kees Cook <keescook@chromium.org>
>
> note below...
>
> > [...]
> > diff --git a/lib/test_meminit.c b/lib/test_meminit.c
> > new file mode 100644
> > index 000000000000..67d759498030
> > --- /dev/null
> > +++ b/lib/test_meminit.c
> > @@ -0,0 +1,205 @@
> > +// SPDX-License-Identifier: GPL-2.0
> > [...]
> > +module_init(test_meminit_init);
>
> I get a warning at build about missing the license:
>
> WARNING: modpost: missing MODULE_LICENSE() in lib/test_meminit.o
>
> So, following the SPDX line, just add:
>
> MODULE_LICENSE("GPL");
Will do, thanks!
> --
> Kees Cook



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

