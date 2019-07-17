Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FD0DC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 13:36:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AA4C20818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 13:36:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jU/Zat9i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AA4C20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58DE76B0003; Wed, 17 Jul 2019 09:36:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53F3C8E0001; Wed, 17 Jul 2019 09:36:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42E3C6B0006; Wed, 17 Jul 2019 09:36:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9B36B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 09:36:51 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id k9so12057761pls.13
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 06:36:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=upJur9hX33jRa5ZDAABYWCcVNIU4OKrA323sUj0kiJ0=;
        b=oaQ4xIy0K1pfJTCoXrEDSGfwdLKeJp0Wv9NhShBT03i78QXS9qlxRYBoa7AEg3UjcS
         Cy4myHmNXL4EaSKVcn69zoQT9re3XHEdGH/X8t+VtSBNWbCjXerzXj+5Xvcw9EYyg/ko
         +1XJEY5N8rPNx+uKBF6ef+HyAP/rKs7Act3e9XtJvtW7uIb2JVL2NomNasZ3YbVQTXiA
         MHeGZH5yVInOhaXRweUNdqFgXxxf099Lo6HMdsZ9rRQowDBwU7oUK9/RU9CaHibLuc+6
         SDUlqJFFgJ7N1M1X4AS3Xpp2E30tsaP/g+GLz2N+GH40IkUDAmF/17MoMan50RHeu4bj
         8sNw==
X-Gm-Message-State: APjAAAWDyWEqh/u++Cb5atPNJT7uguCPpi8nNVUA0RyPeNZh8WUObWij
	xsDmd3Jv8H0NZkMh157Tc6vesddTGUg6NmMuoH6c0QUNNybfjm5gMgR7sMOSfwnpmKYw8PxEeGP
	0CABXtePjuUbl3HsWh2sgcuEXP+Vc9QsV3ipIh/1OcSjWTbTlJED0kb4wBCejYGIbkg==
X-Received: by 2002:a63:5860:: with SMTP id i32mr14039903pgm.124.1563370610408;
        Wed, 17 Jul 2019 06:36:50 -0700 (PDT)
X-Received: by 2002:a63:5860:: with SMTP id i32mr14039829pgm.124.1563370609593;
        Wed, 17 Jul 2019 06:36:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563370609; cv=none;
        d=google.com; s=arc-20160816;
        b=HceSxVjZv0SZcNYkrpcx5bR78kkDcnjNqd3hct1wdylIrBJhvZZQu+zQpuE+QgKIMv
         ZYlNnjJ2YAxFoWaheyFJwIydkVX+aUcHasVQ4sUamVGg95OrxddqDcoal9kTkwhYpAzY
         6gU5e6oNSKDIgMtjrVtNQhGEJPbFjnegLrRMUqOwumsPcCgHXajAhDw/hDYkUe5/bLIK
         aOL74gPoDG20NMuQ1/aA+Da1Z16G8xBuNBMOthpP3FRpxCWuzQmo+TEa8BFF4/awGa/P
         R8DJ7lge6ayv49xJ1jT0jnerctBY+M5zIa23bPxT5S6pq8FPupvZEQpEKshV+xLa7/MX
         jYlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=upJur9hX33jRa5ZDAABYWCcVNIU4OKrA323sUj0kiJ0=;
        b=KjcP5Xyx21zOazHwTb4VCC24BAhxlcdEYaXg9I6UlhT70kzjVwnz0QbI/LfFiIM1ZC
         Sygeq8M7yHx2J+rCW+wP1QjLfSd8i+sSYzgx2bS5ma0PBA1vezALW1fuMkAwOLWaOih7
         uhJFJKwdB+1+CTgDHxQIYKwEZRY334DUyDO1bKPGattLgHTdqhZWILoyEu0dPnYZGlYf
         3McMFRcDlTcX900lTnThWtHDYRMH17GD7awi72M1PVLi0uEq1RJcrul87ZGSNNpQSk2d
         ZR1aNmEH5I8znd3O7dNHJSZtERTk3NbpVARcSnq2tAFKzL+BEyiovp5lPqsWz69nofmo
         ufjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jU/Zat9i";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d1sor29317208pju.23.2019.07.17.06.36.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jul 2019 06:36:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jU/Zat9i";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=upJur9hX33jRa5ZDAABYWCcVNIU4OKrA323sUj0kiJ0=;
        b=jU/Zat9i+mrs8cSnCYXrBiEONUz0WXxyKyOECIIPiTvG8WEhtGZGjK61290IX8o36U
         OrHTHQ7Woyg/qn3+sukX8RWKFmT/Ab3vSFlM0FM2BRuiucJNWXV94DF4e2NhGQgdA44A
         dT08TPfZUZgkz0of54cXYItyNEHlQbHBkArsYbqcDoUXDHAB+kz50O9ewS939NtAQV8u
         N3pg+MG4dZM9J1oQTBELA9KEuGXZuE94dTh2nx4VJ6oW11nUXuKKdq/o5lVXbnas7dEB
         7eGFT9GZTTNoP+bU6YviC4h7qnZidfElkMDjIpsDOMoPQb/nzifgWXLs7MlD24BgMlQq
         Xslw==
X-Google-Smtp-Source: APXvYqz7m/UfmCxQEvGyEZmLKWfGDEQqrP2qzxF/oMVv3Ek5NDX+f4ncbRdtOgqzhkxO4Lp3vwbZe7MPyGJ1vZM4Wx0=
X-Received: by 2002:a17:90a:2488:: with SMTP id i8mr43162554pje.123.1563370608796;
 Wed, 17 Jul 2019 06:36:48 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com> <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca> <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
 <20190716120624.GA29727@ziepe.ca> <CAAeHK+xPPQ9QjAksbfWG-Zmnawt-cdw9eO_6GVxjEYcaDGvaRA@mail.gmail.com>
 <20190717115828.GE12119@ziepe.ca>
In-Reply-To: <20190717115828.GE12119@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Wed, 17 Jul 2019 15:36:37 +0200
Message-ID: <CAAeHK+yyQpc6cxyVeUUWUwiQYy8iAgVXmOVO=EQYSNzy9G8Q0A@mail.gmail.com>
Subject: Re: [PATCH v18 11/15] IB/mlx4: untag user pointers in mlx4_get_umem_mr
To: Jason Gunthorpe <jgg@ziepe.ca>
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
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 1:58 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Jul 17, 2019 at 01:44:07PM +0200, Andrey Konovalov wrote:
> > On Tue, Jul 16, 2019 at 2:06 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Tue, Jul 16, 2019 at 12:42:07PM +0200, Andrey Konovalov wrote:
> > > > On Mon, Jul 15, 2019 at 8:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > > >
> > > > > On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> > > > > > On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > > > > >
> > > > > > > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > > > > > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > > > > > > tagged user pointers (with the top byte set to something else other than
> > > > > > > > 0x00) as syscall arguments.
> > > > > > > >
> > > > > > > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > > > > > > only by done with untagged pointers.
> > > > > > > >
> > > > > > > > Untag user pointers in this function.
> > > > > > > >
> > > > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > > > > > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > > > > > >
> > > > > > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > > > > > >
> > > > > > > This patch also needs an ack from the infiniband maintainers (Jason).
> > > > > >
> > > > > > Hi Jason,
> > > > > >
> > > > > > Could you take a look and give your acked-by?
> > > > >
> > > > > Oh, I think I did this a long time ago. Still looks OK.
> > > >
> > > > Hm, maybe that was we who lost it. Thanks!
> > > >
> > > > > You will send it?
> > > >
> > > > I will resend the patchset once the merge window is closed, if that's
> > > > what you mean.
> > >
> > > No.. I mean who send it to Linus's tree? ie do you want me to take
> > > this patch into rdma?
> >
> > I think the plan was to merge the whole series through the mm tree.
> > But I don't mind if you want to take this patch into your tree. It's
> > just that this patch doesn't make much sense without the rest of the
> > series.
>
> Generally I prefer if subsystem changes stay in subsystem trees. If
> the patch is good standalone, and the untag API has already been
> merged, this is a better strategy.

OK, feel free to take this into your tree, this works for me.

>
> Jason

