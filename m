Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85C84C76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:42:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CC4F20665
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 10:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="s+OFL3WX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CC4F20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D09536B0003; Tue, 16 Jul 2019 06:42:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C942A6B0005; Tue, 16 Jul 2019 06:42:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5A958E0001; Tue, 16 Jul 2019 06:42:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8496B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 06:42:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 6so12138906pfi.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 03:42:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pcaSKUptakKKj3J2cwfnG8UjZ2PIKf/cDSDsIedAL2o=;
        b=HxkhM070FAbfC0aEnZEmChRNv4aT3rJBYOWCUA7th4VLq8FUlhSb9KbwTfrzUEd4ib
         +TO8hW5TJXJqHWqrl4+Hb5s4/aTcklDobfuF3aA+ppcP1xSIdfjHflPxTuMUSe77ubeG
         24374SGf4uC5rt30wRXxPNJwGeLLt2HfqJDhOWiV5gYSxDTGDxzbTwqDHd3hj5KB6Euo
         eFoZx/Fbvo5/+5C259CrqZC3leXoJPurxzHGzy+ztASVKCNVK/7vDNNxt/SSKyk4rEIs
         nYcBhnbkoghtLYA2NQydd+UMwImfYsCPPQBE9+2SpMOJVJImCEdrX9cyKRGTVQmKIHsy
         uOTw==
X-Gm-Message-State: APjAAAW4BQ9q7i9ond2mUmmWI0Rf130sLAz4qTNusw7AjLo2YoC5p3cc
	B3xchH73cIgGaJrLKBuCf8vXtr5gKWf8tKJ2qpvXPl7QflqeG8vktiQmf0IDWNjPa8vT1QWctzO
	6zkbA8Ylpj+YAsgROfz1ip4upxzMdttivg+BPWp5zRy2gAqa60Ek5heTDwpAw+Rn7FQ==
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr34685319plo.211.1563273741013;
        Tue, 16 Jul 2019 03:42:21 -0700 (PDT)
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr34685221plo.211.1563273739675;
        Tue, 16 Jul 2019 03:42:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563273739; cv=none;
        d=google.com; s=arc-20160816;
        b=x0t9Mx16M99gHnE5PJNXW9p2uTywd37APyvmzGy2QbvB8N8R8VPzuv84h+nVvacqLx
         /NX+bEHdEhlpBuKbNCpGqKcE7W79VaQ0cVja8Pk/Z0UAOo7S9eh13a77CTZcjYKMQd2c
         6E+8eu7sB6k5W1A8Eo+2YyyJ80SJybC3PIQ2B3b29b1QeQhHCTEXWx4cmH/AQs7qnvPS
         YDvcep4zNTZjIg2nlE3Myc2LtYQ5xLGUFg20daVk/obRoxfhFBPB8+zLIMq40H4ljmBt
         zVjnQAtl+L+c2lBTCTKg61/rQ7QdldYGYfzLFkqQun0WXHjKAEBtA5YVjweJgzayMICF
         ZrCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pcaSKUptakKKj3J2cwfnG8UjZ2PIKf/cDSDsIedAL2o=;
        b=H5THw1c4/ajdNFb5YlmU7+JhAuvYTfIetDeHaAyk4fsoxTZkzyTzn7ghL4va56m5A9
         DkSfKH3LHtMNIljpTJgRwJsjmf1mBNOjIZgD8+cAqpUqbJvHW/GCt2eOiWJzuxHZ+kxB
         GyRZIIHuS1uzJwhYVDElVxHYZ7r21bQ6pqZGcTT1yDQ8msPfimSyAceY2oQgARCPKmsu
         pNkwSt11MLrkoMHJfCssV6Dz24OS5KU1Us2NLjdoySIHGpSiK6m5erzoQ9p2ti7QGI1J
         nb/adgXrby+kFCxKiJQ5ir3NPvxEfMyZCojGBjx6Ho9mMnW1UhjqUWaUDAqDJyKyXqDw
         cG6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=s+OFL3WX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v32sor6315319pgl.63.2019.07.16.03.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 03:42:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=s+OFL3WX;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pcaSKUptakKKj3J2cwfnG8UjZ2PIKf/cDSDsIedAL2o=;
        b=s+OFL3WXkvuRlzxrd5bE1Ngy+XgzRf65DCow2JPQVmoncUwZbVCqMBlaegEFH9OjoE
         hGCT+agVZt6o7c1dpbisMO2uuxLS4ocd2/ZDN7N4RlgjJBFJVqurL7o3Ajgq9RawIe5i
         iUUC4MErBeuJi9C5qq1rXWHueETWBI6Hzy/jstfQMgqGCotgu8bx7AIz25MV6uvB/uMd
         AEZz6pOzM1SLevN2MhBCQnN+Ls0p0A8Ke9oO9L3/oytDbjyhFG4BNaIQGs6zmciV6uIC
         B6Z1DPnQPaMXlwFS2CsRvlNBpOj4ZTVcwcFW3en9/NlOTRMUXcMVVd3220XqOCAD3ZI0
         4G+A==
X-Google-Smtp-Source: APXvYqxbAU3TJ3lRd6aOUwZ5wuALN9pC6/wjaLV/0rVHNmhI9zipeP18fROsGNN7fnnNJ7wIdpoSB0T+fWzH5C49P+M=
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr32488026pgq.130.1563273738850;
 Tue, 16 Jul 2019 03:42:18 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com> <ea0ff94ef2b8af12ea6c222c5ebd970e0849b6dd.1561386715.git.andreyknvl@google.com>
 <20190624174015.GL29120@arrakis.emea.arm.com> <CAAeHK+y8vE=G_odK6KH=H064nSQcVgkQkNwb2zQD9swXxKSyUQ@mail.gmail.com>
 <20190715180510.GC4970@ziepe.ca>
In-Reply-To: <20190715180510.GC4970@ziepe.ca>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 16 Jul 2019 12:42:07 +0200
Message-ID: <CAAeHK+xPQqJP7p_JFxc4jrx9k7N0TpBWEuB8Px7XHvrfDU1_gw@mail.gmail.com>
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

On Mon, Jul 15, 2019 at 8:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Mon, Jul 15, 2019 at 06:01:29PM +0200, Andrey Konovalov wrote:
> > On Mon, Jun 24, 2019 at 7:40 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > >
> > > On Mon, Jun 24, 2019 at 04:32:56PM +0200, Andrey Konovalov wrote:
> > > > This patch is a part of a series that extends kernel ABI to allow to pass
> > > > tagged user pointers (with the top byte set to something else other than
> > > > 0x00) as syscall arguments.
> > > >
> > > > mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
> > > > only by done with untagged pointers.
> > > >
> > > > Untag user pointers in this function.
> > > >
> > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > >  drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
> > > >  1 file changed, 4 insertions(+), 3 deletions(-)
> > >
> > > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > >
> > > This patch also needs an ack from the infiniband maintainers (Jason).
> >
> > Hi Jason,
> >
> > Could you take a look and give your acked-by?
>
> Oh, I think I did this a long time ago. Still looks OK.

Hm, maybe that was we who lost it. Thanks!

> You will send it?

I will resend the patchset once the merge window is closed, if that's
what you mean.

>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
>
> Jason

