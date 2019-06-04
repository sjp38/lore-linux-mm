Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9549C28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:48:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7153024922
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:48:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="M0DMlRQ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7153024922
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05CFC6B0272; Tue,  4 Jun 2019 07:48:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00D956B0273; Tue,  4 Jun 2019 07:48:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF17B6B0274; Tue,  4 Jun 2019 07:48:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A48266B0272
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:48:16 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 91so13831508pla.7
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:48:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=l2lS9VXn0JOV0lrkvQPMmgSCO4r5DeMFb6G5blm/uF4=;
        b=JEcvVuBk5gl67p65dgZDAJ9DHfEycY8YmRSEu1UXv3iZrZUtE4sXatODmxn+B+++2W
         cBk+/1/bVi4uDc68Rnru7LtufS6iM5NA9HcwsPzXuWxzI4loI4i20Ml+M2gjVZL7xa2k
         YEmdm0OUFVxbQxPA/c7eG2Fb98D5+OFqXU/ihQZijP3FDf0y/l6C8S4WV2Hw4AirxAp1
         uZfkKiKXJR2gmelHlxPTOb8rof1KKHrwiDG6qkMB4TZbj3GdGHKujQpKscx7rGZ7y5t2
         8Yrg2Ehe0xYnvpS307L31yJIllshgiO8HgMKqJKssF9gLg/m9gwq1k3uSFLCHD6ilH4S
         frMQ==
X-Gm-Message-State: APjAAAXhmOerfUVdrx3BjBTgsacuRFd0kNsq/a06hNn0o2bq3fOgjjwW
	gRi9rcpb189Q7otD4nUn6jBwsdj3l3W/jUnqlNFdUJRMQ4UTmIOQRzLmz81VrW4Od6DTBs5rQ3G
	1sA4XlG0vXyuk1N52cBNpYJhitItvEWe9YrR6c2Jdi1GPD+Q7QCFSKLUInDW4m/pSzA==
X-Received: by 2002:aa7:80ce:: with SMTP id a14mr6244503pfn.249.1559648896295;
        Tue, 04 Jun 2019 04:48:16 -0700 (PDT)
X-Received: by 2002:aa7:80ce:: with SMTP id a14mr6244445pfn.249.1559648895767;
        Tue, 04 Jun 2019 04:48:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559648895; cv=none;
        d=google.com; s=arc-20160816;
        b=w310GRs4WGHeCk2nApSvixc7tlJl0p9fa27utbq+PW3nAUhKVq7bu4PGbEkj68WX9l
         C8RSsyHFWeL7oh8ZK5b6B4zftoeT4sgNN7pZ3/izvcJoYCbzWasHPcvLYJEPMF7Jw+9p
         aO3LSux+P0yWDf2pK7fQmW1w6sGIf6B4ks+2gIXdn6faVt70iS8rEEmBEHsJOoBS9Wc8
         lH2WPbsw8h2jyvCkNUw8PzNnNlpy+zzLrI7wOKHGCOtmEXTWhZuU0KlzdrMZItD2zJGO
         z8bZ3meQA5yndWM0J+hK88SL2B0fxB6Z7m9Qv14EvCUvaB9TiUGZn94LaARCSL7Pmxny
         bJiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=l2lS9VXn0JOV0lrkvQPMmgSCO4r5DeMFb6G5blm/uF4=;
        b=IUqgvNKWc8o02w7gzePF2x2Ecl4rxwpx2tpjszPw1DFE+cyqaX7mTNFCkFJDkXf+aP
         HGisPP5l+pxAl46Od1nm9HKhJmKWD3lAKME35hfCsqJuKPJaoxDMlc++a7uWZh8qMl0Q
         dglsUuS1Px0sBWXZKp02TgK1b+INZOToFFRix1AFYns0zedPjEjSJQ80OJ0Awz19uSSG
         MD6bKhg/MG0wSDT4oAFbYYZJFwPAHkh2IWuorphQVC/i0bPcqSCp36+/2hlbtp4p3cvX
         3KulQVz191yawe2lMZgG8OqKFm/wDUIMxC0Pgx3tXTVqAAXqRfEqdc2ughxvg2yTtcGB
         6kQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M0DMlRQ1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g95sor20190034plb.67.2019.06.04.04.48.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 04:48:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=M0DMlRQ1;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=l2lS9VXn0JOV0lrkvQPMmgSCO4r5DeMFb6G5blm/uF4=;
        b=M0DMlRQ1HKA6D9NAO0V2sm9/zYZWP+1XOjmn59ytz8n46FHwdaWXM0RmDqecELc0CD
         TyAtpGjsaLf78y28sMV5XpDdzqWkQFoLrG4JmKyB20v3AEUSZ84vFCfbahAnJbBWXTDe
         lxvooM2Tt/ajz9LaLc0YFyhDIwwZ9gPW/77cWnoFBFeW1WjBXUTE7GfRa1ThVQOHuo3s
         shP14wPYTEXFgEfcuub9qa9DcYA4fCTl4CLVznhqf/cR8S79aYCO7GCHb7p1YqEQltrO
         AQzjJKwTGzxdh+F0Gnq7lZoTrHue4pLf6ckipB1C17pl/cPtDze5tQgEM9+9n2jZCGGY
         dHSQ==
X-Google-Smtp-Source: APXvYqx7WlqCkdGPKLutoMBA66Kuwfxftr7iVGYrBeMeyQalyPFL29VhCLInmdVTRNyRVDkjn2/lP008/BVA4p3Szd8=
X-Received: by 2002:a17:902:bc47:: with SMTP id t7mr24049646plz.336.1559648895074;
 Tue, 04 Jun 2019 04:48:15 -0700 (PDT)
MIME-Version: 1.0
References: <8ab5cd1813b0890f8780018e9784838456ace49e.1559648669.git.andreyknvl@google.com>
 <d74b1621-70a2-94a0-e24b-dae32adc457d@amd.com>
In-Reply-To: <d74b1621-70a2-94a0-e24b-dae32adc457d@amd.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 4 Jun 2019 13:48:03 +0200
Message-ID: <CAAeHK+w0_9QdxCJXEf=6nMgZpsb8NyrAaMO010Hh86TW75jJvw@mail.gmail.com>
Subject: Re: [PATCH] uaccess: add noop untagged_addr definition
To: "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, "Kuehling, Felix" <Felix.Kuehling@amd.com>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 1:46 PM Koenig, Christian
<Christian.Koenig@amd.com> wrote:
>
> Am 04.06.19 um 13:44 schrieb Andrey Konovalov:
> > Architectures that support memory tagging have a need to perform untagging
> > (stripping the tag) in various parts of the kernel. This patch adds an
> > untagged_addr() macro, which is defined as noop for architectures that do
> > not support memory tagging. The oncoming patch series will define it at
> > least for sparc64 and arm64.
> >
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   include/linux/mm.h | 4 ++++
> >   1 file changed, 4 insertions(+)
> >
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0e8834ac32b7..949d43e9c0b6 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >   #include <asm/pgtable.h>
> >   #include <asm/processor.h>
> >
> > +#ifndef untagged_addr
> > +#define untagged_addr(addr) (addr)
> > +#endif
> > +
>
> Maybe add a comment what tagging actually is? Cause that is not really
> obvious from the context.

Hi,

Do you mean a comment in the code or an explanation in the patch description?

Thanks!

>
> Christian.
>
> >   #ifndef __pa_symbol
> >   #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
> >   #endif
>

