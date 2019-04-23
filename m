Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57F0FC10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:14:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1787F217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 19:14:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="YQicmEXJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1787F217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB05A6B0003; Tue, 23 Apr 2019 15:14:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5F206B0005; Tue, 23 Apr 2019 15:14:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 926006B0007; Tue, 23 Apr 2019 15:14:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id 635196B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:14:51 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id b10so7445491vkf.3
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:14:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=32U2dfxVGqorGsN9k10OetrKjC+7ZLylQlERitBS26g=;
        b=cQXtp6EcNgu4HxXN1/7/qbn4wMdm+gkqXC8pTb2EmAmFOD/FV7+GEjeyEn5XSKIJio
         cPItFHw89KgPvwIKyCW6ww4oZ2iR17Z5Bad32ndg/gEwVm7wboP8KlvVCa1NXn+aemnt
         GU5aPQE7HfTXzB9D+Emy5/nJ2fxIpOBVGONrmS6hoEflDUzPujUnz0Rbh3ddS9aGlrmh
         1wbuJ0iFYdEM7eTHPUFstV2yg0g3rpjWWLGgG8PDYJjoJFO3DSDIN7fO2dKZiXkfUBKb
         fQUFJGXNolYfkR9ShXkf7iLtHx1rIrkqZgvMXISNGdUMtIVtpSjLl16c+zPshFt2h7+h
         1D8Q==
X-Gm-Message-State: APjAAAWre0CP71CIElWzZpJWE1pKTzV/U+TVP4G9qNX3RIEMGU32v00h
	omn3CuV3VN90dE83RJSax8O/hW/jBv5RZVty8svpoLYf42CZMCpvhEM2sK/eKk/Je31gU2sB/Ri
	VqfCsjhXpoISgMd+s1dQ+k6aBYJQaQw6L83jlfqKf/2jsDoTkKNuuudKiGPO3qYriPg==
X-Received: by 2002:ab0:6849:: with SMTP id a9mr3457410uas.135.1556046891146;
        Tue, 23 Apr 2019 12:14:51 -0700 (PDT)
X-Received: by 2002:ab0:6849:: with SMTP id a9mr3457369uas.135.1556046890459;
        Tue, 23 Apr 2019 12:14:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556046890; cv=none;
        d=google.com; s=arc-20160816;
        b=wYrnGT7BJijsTCAGbYencOJwOPcrJ7EMhs6X0RP+BqI3I9+hCOJNxLWGAn367Ehnlv
         U+fnlCw6xSLFpsjzcSAPjogJKTigeqrSy1atPgYvRVhSQRVrcFkZ9/nfhu8cNAjt1ePx
         aWs3Gukmb+82REf6XqjPMz6v+P7iR4kvXUsUNOIGfm6t+g07anOCIHpVHpKq9rz41BOk
         7sgM1FFWberdVdipwsBQ8NjFm6z55/iWzfdj1/S0BWHNB5SY/ch9rRYWUz2n1irqM7Hp
         XWTQM/deET1pGHvxEjszlIWPNQGiD6deOT+A3Cy+ocv/mpfGliupxBlKK9Wk7TtGiu7S
         TbkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=32U2dfxVGqorGsN9k10OetrKjC+7ZLylQlERitBS26g=;
        b=DVGHGIPQUZbwdR7CUR64QFH/jxs5LKpabvkgFK5t6oOaZjXT6a5lgcs9YoWhCmyEdp
         HSam6Eb3EcfcO91MjNVXJSalqG1+LhWxvOQ4rf6rRLN89GtJbOr5teUTF6Gq7pNiC1b6
         jKZavKcLtadjneih/8dJt89KOz0Zt7yFfbZE9zhjCjbyEkvRjQXkj3W/n/L93/Dh55G0
         WK7MSQF0WJqbN2mhGirm5t4gFu3T/Mzbye1fk7xj2Kp3qFZQee+nnpnb8oJ4JtLRUGVR
         i5wqg6YfzK5oSw1sr64t8Z19lEV55kNdqAN1ASLyjgZQ+HcMtPN5MDYvfbakRQAwUcGG
         S2wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YQicmEXJ;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s17sor8164599uar.41.2019.04.23.12.14.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 12:14:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=YQicmEXJ;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=32U2dfxVGqorGsN9k10OetrKjC+7ZLylQlERitBS26g=;
        b=YQicmEXJvE7Tow30ovfEeQ7OOnLVp5QOpQuA2Yp/05T8K4KyNMZUwRCEOT7qsv8jUW
         ji6LVmFsFQl5hazahb/dIo7+RTDl77DuX1J/52+4KgqU4FDGj2s/XsiCzYXx0E48D276
         o38sdIgkaDZOG1/7dTK3PqR9YH4+X9a14h5O0=
X-Google-Smtp-Source: APXvYqwL/hGG4sNKDsHrVviTAgeOIAwb6ZaCo16/Y2jwOVVA//oA2x+neALpowK7l+NRG+33eDq0xg==
X-Received: by 2002:ab0:3314:: with SMTP id r20mr4034393uao.69.1556046889534;
        Tue, 23 Apr 2019 12:14:49 -0700 (PDT)
Received: from mail-vk1-f172.google.com (mail-vk1-f172.google.com. [209.85.221.172])
        by smtp.gmail.com with ESMTPSA id a26sm2935951vsq.29.2019.04.23.12.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 12:14:48 -0700 (PDT)
Received: by mail-vk1-f172.google.com with SMTP id x2so3455791vkx.13
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 12:14:48 -0700 (PDT)
X-Received: by 2002:a1f:7d8e:: with SMTP id y136mr8461809vkc.40.1556046888180;
 Tue, 23 Apr 2019 12:14:48 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-3-glider@google.com>
 <7bf6bd62-c8e0-df3d-8e98-70063f2d175a@intel.com>
In-Reply-To: <7bf6bd62-c8e0-df3d-8e98-70063f2d175a@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Apr 2019 12:14:36 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+Lm0ba4ZQ91vZ8nZFvpJSxu_j_bEKMaa0NMsurmyZjjA@mail.gmail.com>
Message-ID: <CAGXu5j+Lm0ba4ZQ91vZ8nZFvpJSxu_j_bEKMaa0NMsurmyZjjA@mail.gmail.com>
Subject: Re: [PATCH 2/3] gfp: mm: introduce __GFP_NOINIT
To: Dave Hansen <dave.hansen@intel.com>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Lameter <cl@linux.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@redhat.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 9:52 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> > diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
> > index be84f5f95c97..f9d1f1236cd0 100644
> > --- a/kernel/kexec_core.c
> > +++ b/kernel/kexec_core.c
> > @@ -302,7 +302,7 @@ static struct page *kimage_alloc_pages(gfp_t gfp_mask, unsigned int order)
> >  {
> >       struct page *pages;
> >
> > -     pages = alloc_pages(gfp_mask & ~__GFP_ZERO, order);
> > +     pages = alloc_pages((gfp_mask & ~__GFP_ZERO) | __GFP_NOINIT, order);
> >       if (pages) {
> >               unsigned int count, i;
>
> While this is probably not super security-sensitive, it's also not
> performance sensitive.

It is, however, a pretty clear case of "and then we immediately zero it".

> These sl*b ones seem like a bad idea.  We already have rules that sl*b
> allocations must be initialized by callers, and we have reasonably
> frequent bugs where the rules are broken.

Hm? No, this is saying that the page allocator can skip the auto-init
because the slab internals will be doing it later.

> Setting __GFP_NOINIT might be reasonable to do, though, for slabs that
> have a constructor.  We have much higher confidence that *those* are
> going to get initialized properly.

That's already handled in patch 1.

-- 
Kees Cook

