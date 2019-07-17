Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252BFC76196
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:47:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C77AB205ED
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:47:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="q9rg5oP+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C77AB205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 657926B0008; Wed, 17 Jul 2019 07:47:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 62E928E0001; Wed, 17 Jul 2019 07:47:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5445D6B000C; Wed, 17 Jul 2019 07:47:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2D66B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:47:05 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so11935518plp.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:47:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XH7pgHFzkwihJR5psn/ZNzGH7d1Hcpwg4ypt2aGmLUk=;
        b=NJkmcXH4u1ASzanW5/mcDlUNlJRL7A4DnPvbctS2eJk1QXQUYGVZuimuG2q1Z4Bb9B
         mnjUVosuQc1w/cMdqIpmvvsH+AbnlQoJuODqbX384rOG2afhLgqpYmMyBgMvEIPcDCFW
         hcqEkrl0xngSzv7EVWsJ5zpj5GcmPtBtjuE/AzvPqdMBH64r1e0aVJ2FsYFuGGiOr3vn
         IEefE6C7KIIoJ2wHNXK76e9N57qg+OGAzCp0XswTGmJ0Aa3nXNYUyYR2UCPF2ULP03YA
         T2vdwyo/YpJzdKOP1Mffn8Bvjl3+f1OCY155vbyuW9R3QYYvCR/ot1kvPw9/a9AhJxF6
         VwRA==
X-Gm-Message-State: APjAAAUNbxzfZqF895tEEp41AgoS+ECig3+uaW26s+0Nf7wc8ztuIQ8G
	Tecb0k/zQGx1ZCiZabxR6cZvnET0opEFXbvlk+yT4kGPL3/bcdBozMJ3BSgkrfWbviwVnK7pyDP
	CtNmKcOPJJx6yhNBeUuFoOZUyg3K67eBGN8BJASdqqemDCOxmdFlcgvOuAoL7pnblyQ==
X-Received: by 2002:a65:534c:: with SMTP id w12mr40694829pgr.51.1563364024640;
        Wed, 17 Jul 2019 04:47:04 -0700 (PDT)
X-Received: by 2002:a65:534c:: with SMTP id w12mr40694780pgr.51.1563364023876;
        Wed, 17 Jul 2019 04:47:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563364023; cv=none;
        d=google.com; s=arc-20160816;
        b=LAViULZLzLEAnWDFa33uOjsNj1yUxHculh4F+/+54O0DDPPMqWY88/809i0eObasJH
         LA8lYL9VwxNwGqoqeSV6NxMu8PBPJoNkmZC4L3fyYOvxs7zZ3MfhvjTd9VncEmtfCDzj
         3fUR1hq/2bxCrBkd1ec+J5J4i5VhOQySrBdc6OMhoh8F2u2lvubpJ1ZOgF0SkVCEl0oj
         r8gN+1o3kD77BicKluxSp0MTK0Ya49LDMkFy63IiJg92jG+9Y2lapdd8WB4wHv3uvPTo
         rvN4VWIUW0adZSiPk0FnQroswfSvha5d4JDye3HgEJoCEBMWASfiT262mJBMZ1IvG/qg
         yNPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XH7pgHFzkwihJR5psn/ZNzGH7d1Hcpwg4ypt2aGmLUk=;
        b=Qrr79P3ZTpwyrvyldSU4OdJSjUAOg4+Fqcd9pI+9cTRbcK9a3ZZABJt/m5a3FiDjbM
         jhDExD3x+P6hJBCT2Gd5LETn9D4y4/RpSZb81hCtGzu/YE8B4lcK/W58yPjzTrHjNgN+
         U9u4gb8pgmjk3QOcWISItFJLZWshMCD54ngpk54hKcI3FMeeJE8/OdQvaQXyHYk8N8/7
         SGB/IS8R45wqFHekpGjZuc/VZyzfwhkcZ27aEZ5niD/LzBGtqwWSji8HNENRM1LuQC/W
         t1RabYI4DYjUMyfj2lAHQvkWpyqiRIY9bChv3yciiMg0X5gy7rwmF0opAKSKaTikiITn
         bpMg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=q9rg5oP+;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r4sor28445118plo.57.2019.07.17.04.47.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 04:47:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=q9rg5oP+;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XH7pgHFzkwihJR5psn/ZNzGH7d1Hcpwg4ypt2aGmLUk=;
        b=q9rg5oP+7QfRryee4CQfI+zTuO8vcNkAU+Zb8S/XX5gbQKX1OYbsUUbB3B8KK9hFmU
         UHgvh4Mz+Kyv0D5E5zvwH3nJNYoE2P1kzcK2Rg1yMoExsViP4+PURLjfYPF2WZhrd0MF
         a+zGI8yxCxdvE8nZGITXCK8/RaYQDCnkR7z8XELwz+GgVBZndcqvcfCaF4ihTHl0HyVo
         bFY7Esho++ViErb2avPSuS/M58xcsz7oUebcD6xLNGIpCphqGpuQ31GuhoMHpSqGmldC
         ZKZZNvAff0cBNn4NnOvQXzgW64bJR2BOmy7dIGzstZ5vq+Xgsj3OiBdAV2LIo/WRsiLm
         aMOQ==
X-Google-Smtp-Source: APXvYqz8S3jyPxed+oPtsIDmi9g4NsD5ItlfcVysZ7+qze2pU/edo+3e3aBEztJRj4XnLTpHjY2eNg/431rKCehxHqk=
X-Received: by 2002:a17:902:8689:: with SMTP id g9mr39736837plo.252.1563364023206;
 Wed, 17 Jul 2019 04:47:03 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
 <20190624175120.GN29120@arrakis.emea.arm.com> <20190717110910.GA12017@rapoport-lnx>
In-Reply-To: <20190717110910.GA12017@rapoport-lnx>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 17 Jul 2019 13:46:52 +0200
Message-ID: <CAAeHK+yB=d_oXOVZ2TuVe2UkBAx-GM_f+mu88JeVWqPO95xVHQ@mail.gmail.com>
Subject: Re: [PATCH v18 08/15] userfaultfd: untag user pointers
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Al Viro <viro@zeniv.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 1:09 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Mon, Jun 24, 2019 at 06:51:21PM +0100, Catalin Marinas wrote:
> > On Mon, Jun 24, 2019 at 04:32:53PM +0200, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > tagged user pointers (with the top byte set to something else other than
> > > 0x00) as syscall arguments.
> > >
> > > userfaultfd code use provided user pointers for vma lookups, which can
> > > only by done with untagged pointers.
> > >
> > > Untag user pointers in validate_range().
> > >
> > > Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > > Reviewed-by: Kees Cook <keescook@chromium.org>
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > ---
> > >  fs/userfaultfd.c | 22 ++++++++++++----------
> > >  1 file changed, 12 insertions(+), 10 deletions(-)
> >
> > Same here, it needs an ack from Al Viro.
>
> The userfault patches usually go via -mm tree, not sure if Al looks at them :)

Ah, OK, I guess than Andrew will take a look at them when merging.

>
> FWIW, you can add
>
> Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

I will, thanks!

>
> > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > index ae0b8b5f69e6..c2be36a168ca 100644
> > > --- a/fs/userfaultfd.c
> > > +++ b/fs/userfaultfd.c
> > > @@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
> > >  }
> > >
> > >  static __always_inline int validate_range(struct mm_struct *mm,
> > > -                                     __u64 start, __u64 len)
> > > +                                     __u64 *start, __u64 len)
> > >  {
> > >     __u64 task_size = mm->task_size;
> > >
> > > -   if (start & ~PAGE_MASK)
> > > +   *start = untagged_addr(*start);
> > > +
> > > +   if (*start & ~PAGE_MASK)
> > >             return -EINVAL;
> > >     if (len & ~PAGE_MASK)
> > >             return -EINVAL;
> > >     if (!len)
> > >             return -EINVAL;
> > > -   if (start < mmap_min_addr)
> > > +   if (*start < mmap_min_addr)
> > >             return -EINVAL;
> > > -   if (start >= task_size)
> > > +   if (*start >= task_size)
> > >             return -EINVAL;
> > > -   if (len > task_size - start)
> > > +   if (len > task_size - *start)
> > >             return -EINVAL;
> > >     return 0;
> > >  }
> > > @@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> > >             goto out;
> > >     }
> > >
> > > -   ret = validate_range(mm, uffdio_register.range.start,
> > > +   ret = validate_range(mm, &uffdio_register.range.start,
> > >                          uffdio_register.range.len);
> > >     if (ret)
> > >             goto out;
> > > @@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> > >     if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
> > >             goto out;
> > >
> > > -   ret = validate_range(mm, uffdio_unregister.start,
> > > +   ret = validate_range(mm, &uffdio_unregister.start,
> > >                          uffdio_unregister.len);
> > >     if (ret)
> > >             goto out;
> > > @@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
> > >     if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
> > >             goto out;
> > >
> > > -   ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
> > > +   ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
> > >     if (ret)
> > >             goto out;
> > >
> > > @@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
> > >                        sizeof(uffdio_copy)-sizeof(__s64)))
> > >             goto out;
> > >
> > > -   ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
> > > +   ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
> > >     if (ret)
> > >             goto out;
> > >     /*
> > > @@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> > >                        sizeof(uffdio_zeropage)-sizeof(__s64)))
> > >             goto out;
> > >
> > > -   ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
> > > +   ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
> > >                          uffdio_zeropage.range.len);
> > >     if (ret)
> > >             goto out;
> > > --
> > > 2.22.0.410.gd8fdbe21b5-goog
>
> --
> Sincerely yours,
> Mike.
>

