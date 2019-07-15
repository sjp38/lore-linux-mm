Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A83CC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C83FE20861
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 16:00:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="awILUWqn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C83FE20861
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 506FF6B000E; Mon, 15 Jul 2019 12:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DE616B0010; Mon, 15 Jul 2019 12:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CD5A6B0266; Mon, 15 Jul 2019 12:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06BA26B000E
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:00:48 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so10500399pff.8
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:00:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7Q0q/IfCRadymayHol/UUF72+yJ91bYAnFv+xLR30xQ=;
        b=KMCvHL8QAcxKZlQr7Kb6z+vjjUITru6E5e2pxC7VAMmZrXRgdKDoa3vYTMawgI0rnI
         HYX+ex9aQhBUmJ9NHH5HYe6rFZHoayKi5z/2Ce/2heShmdCOtkBz/guaLCEJVId9pwND
         9j2a9aPQ30LE2IYeEkuCquhtkuvGcFDjz6hd8VAZZAOv0Wowkii3DBdhtmeEkUhsE3HA
         fbPDNBdQc1ILVZq3OwjyL2j8ZuXNW3shYwDa0sUaw7zXZNTzVbvEqPBdVWzVW5kQ9y8z
         SpcMtd9ntn1IYAEkDTyYJYm0pcFiA402zb2wPjbu6GTv6HvChIgzGEO6S8IBspOg+At+
         mufA==
X-Gm-Message-State: APjAAAVBuRZPn3D6mG6YFyl2vhj/H1URgHwjNUIS8ZZN1VXlRURtA+Dt
	OeuWLEnlqzozO671OaOgdpFrkbozNwmUOKJb2S5Jab/QY2i+fbq/hggWUOg7wmyWMikSTjRdUb5
	6ZJouhwvUDr4O3tY/U+g2e44mmYg7M3lPR35xhD8ysZWzUWQbWSkqTrmd/DER728B+w==
X-Received: by 2002:a63:1305:: with SMTP id i5mr27978578pgl.211.1563206447455;
        Mon, 15 Jul 2019 09:00:47 -0700 (PDT)
X-Received: by 2002:a63:1305:: with SMTP id i5mr27978503pgl.211.1563206446736;
        Mon, 15 Jul 2019 09:00:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563206446; cv=none;
        d=google.com; s=arc-20160816;
        b=mAovfywbbgAh79qLT32YorO8NuttxFJKDDR9uIqNodEb7uvzaEsVjc+FpSA08vh39V
         K77/K+VblvDPv2DQldZleN6AECEnXOg1Me2lsBO45qbwaQrB43mYBXDw1AwSHJDcaLjy
         CaZ0i7ZHVKRn0fr+jesIAtREl/sT1k5wF1VylRqOoELI4RS0lolDFSOSbuJ71GE3wlgS
         IUCEJ1dFNekh5ZYAt8Y7ZmWodUanwJZBR6gbiy6wXauyL8nPmlW/TsssNbWWg54fBrfP
         3Lo8I5AdiyROdJChwT0hfsS9Oqbfre5PmW2vsMB1PciuhCktuwG2g91b2FYjlAOSkwjD
         aSkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7Q0q/IfCRadymayHol/UUF72+yJ91bYAnFv+xLR30xQ=;
        b=R0Rn7OG+biHRGEGYrPMNUK3k7/Cwikm8vyxEZgInancuGhZeGLeZo9lHv71oIiigUR
         Ud4Iv9yvsK3PWaItqvKeijhaPj+o30JUy5eYor6ZObhrhLPcO5FZuQLhP1iJ5vELgL6d
         TErtH5ygE6jFcCWIGSBpR0g2GBoxZWSrQyxvJmlZxAIT2fD3RrC9A0T74+0gnTDjd83w
         /HSTNhLGwmX28T0Sej/34tvppVJJUGfbG9UDTxxDJ76vyf6lf3y8r8ccLQ32umC8Vscg
         Zmvbtbqyi9yeBaowncaneIP+dD8CqGN4dojCpqsgFlH9SEXzyExx6LbmWIUjc6l6L79o
         SqkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=awILUWqn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o70sor21693711pje.2.2019.07.15.09.00.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 09:00:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=awILUWqn;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7Q0q/IfCRadymayHol/UUF72+yJ91bYAnFv+xLR30xQ=;
        b=awILUWqnOhL8QrLhWTtK3zyGeYzsbGaDmlapw+TJPtpLmDPRw1GP6vt2k8M63kLr39
         ZOpRC9dNiFsjXCuRW9tvX+XJ4TMinqKEg4V9d0/Cohi7g+H0FLJqsymSlujZFTSwFgq+
         HGvo45b5poteQElVP2ylrss//l0SvENb9w0NdEWBIgvpqnNLsaE/1Oq03NG9YiPmMbZi
         8k5Fou1N/CEVlyaSlbvq+wKBgrOUzCIo1B2qg8bQ1mlF2+F/VYvQbx6QNpAS+GS8VYMS
         4d6tYcKUYuIyyU24AI3+kh3w0LS9e+N+YdRnIzCnanxcL1YdF0dX0SOZIdMQqtDbfKe6
         /xuQ==
X-Google-Smtp-Source: APXvYqw+s/Xsm1Inj9c3bcQDg7/b3DVU+zlhxUxxhLhtcMSC55W2OaWJF9iNwAodQ+4dHaGR8RmRVxTzfqDyBCor0Ro=
X-Received: by 2002:a17:90a:25c8:: with SMTP id k66mr30231713pje.129.1563206445986;
 Mon, 15 Jul 2019 09:00:45 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <d8e3b9a819e98d6527e506027b173b128a148d3c.1561386715.git.andreyknvl@google.com>
 <20190624175120.GN29120@arrakis.emea.arm.com>
In-Reply-To: <20190624175120.GN29120@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 15 Jul 2019 18:00:34 +0200
Message-ID: <CAAeHK+w=Hi2OQSBfRGmw2dG15ctiHoP6DpktyFG7Qo3AohBAgA@mail.gmail.com>
Subject: Re: [PATCH v18 08/15] userfaultfd: untag user pointers
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
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

On Mon, Jun 24, 2019 at 7:51 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Jun 24, 2019 at 04:32:53PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends kernel ABI to allow to pass
> > tagged user pointers (with the top byte set to something else other than
> > 0x00) as syscall arguments.
> >
> > userfaultfd code use provided user pointers for vma lookups, which can
> > only by done with untagged pointers.
> >
> > Untag user pointers in validate_range().
> >
> > Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
> > Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  fs/userfaultfd.c | 22 ++++++++++++----------
> >  1 file changed, 12 insertions(+), 10 deletions(-)
>
> Same here, it needs an ack from Al Viro.

Hi Al,

Could you take a look at this one as well and give your acked-by?

Thanks!

>
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index ae0b8b5f69e6..c2be36a168ca 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1261,21 +1261,23 @@ static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
> >  }
> >
> >  static __always_inline int validate_range(struct mm_struct *mm,
> > -                                       __u64 start, __u64 len)
> > +                                       __u64 *start, __u64 len)
> >  {
> >       __u64 task_size = mm->task_size;
> >
> > -     if (start & ~PAGE_MASK)
> > +     *start = untagged_addr(*start);
> > +
> > +     if (*start & ~PAGE_MASK)
> >               return -EINVAL;
> >       if (len & ~PAGE_MASK)
> >               return -EINVAL;
> >       if (!len)
> >               return -EINVAL;
> > -     if (start < mmap_min_addr)
> > +     if (*start < mmap_min_addr)
> >               return -EINVAL;
> > -     if (start >= task_size)
> > +     if (*start >= task_size)
> >               return -EINVAL;
> > -     if (len > task_size - start)
> > +     if (len > task_size - *start)
> >               return -EINVAL;
> >       return 0;
> >  }
> > @@ -1325,7 +1327,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >               goto out;
> >       }
> >
> > -     ret = validate_range(mm, uffdio_register.range.start,
> > +     ret = validate_range(mm, &uffdio_register.range.start,
> >                            uffdio_register.range.len);
> >       if (ret)
> >               goto out;
> > @@ -1514,7 +1516,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >       if (copy_from_user(&uffdio_unregister, buf, sizeof(uffdio_unregister)))
> >               goto out;
> >
> > -     ret = validate_range(mm, uffdio_unregister.start,
> > +     ret = validate_range(mm, &uffdio_unregister.start,
> >                            uffdio_unregister.len);
> >       if (ret)
> >               goto out;
> > @@ -1665,7 +1667,7 @@ static int userfaultfd_wake(struct userfaultfd_ctx *ctx,
> >       if (copy_from_user(&uffdio_wake, buf, sizeof(uffdio_wake)))
> >               goto out;
> >
> > -     ret = validate_range(ctx->mm, uffdio_wake.start, uffdio_wake.len);
> > +     ret = validate_range(ctx->mm, &uffdio_wake.start, uffdio_wake.len);
> >       if (ret)
> >               goto out;
> >
> > @@ -1705,7 +1707,7 @@ static int userfaultfd_copy(struct userfaultfd_ctx *ctx,
> >                          sizeof(uffdio_copy)-sizeof(__s64)))
> >               goto out;
> >
> > -     ret = validate_range(ctx->mm, uffdio_copy.dst, uffdio_copy.len);
> > +     ret = validate_range(ctx->mm, &uffdio_copy.dst, uffdio_copy.len);
> >       if (ret)
> >               goto out;
> >       /*
> > @@ -1761,7 +1763,7 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >                          sizeof(uffdio_zeropage)-sizeof(__s64)))
> >               goto out;
> >
> > -     ret = validate_range(ctx->mm, uffdio_zeropage.range.start,
> > +     ret = validate_range(ctx->mm, &uffdio_zeropage.range.start,
> >                            uffdio_zeropage.range.len);
> >       if (ret)
> >               goto out;
> > --
> > 2.22.0.410.gd8fdbe21b5-goog

