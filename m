Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACA40C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 05:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 454A6212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 05:33:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="k/GR7joJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 454A6212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98D766B000C; Fri,  7 Jun 2019 01:33:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 917CC6B000E; Fri,  7 Jun 2019 01:33:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B8946B0266; Fri,  7 Jun 2019 01:33:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF326B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 01:33:51 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id h18so941633itl.8
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 22:33:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=I1Ohgac363EioDxzXpyXf7UN1ZgVyShBjggu94kceQ8=;
        b=IqRXL4FPzSZJo7DiucCDYnh9tw6yZu8RMZxkgGyNz/A+efIcrSFVKfidITWil3U1Ry
         IzXXhYKeGM0NFMUG0M8GGUzM8PVhR+m6FVNsCoVQSQ4/cXvP+ZOSLuhF8P4nazFunzJ1
         Or4c4wUxGDsuUNabLqWpmjpJEzXphirDWAEqqNgc1J6bhnvRilO4k5arCnUxSEj1PFP1
         migpNyy2NzbatynbCgN4HPva8toMWaGF/D1xa8jFMPZYbkfO1Z1wYY4HiZRtUMauaAXG
         ASp+LxsPflNY5zpqpnLUzoiNDhzX2YD9dH31a8pFQ3HvT7zslxYk+FTleehyAz/Uud3E
         pqgg==
X-Gm-Message-State: APjAAAWdH5UpBY/f4Bqozh3abyMs3Db8tzrbQK1spAVz7JP9gToQ2wY+
	oNB1nDpe7AgvA7F+u7uNi0F/mFg/S9tyFWpCNB9+PYTeyW8IS9DVcNmAeYZgIdAgFzLFvqyIJbB
	Ak4CWX3ug8JEADJ14tm9c6uyOuqUDH8lUr03BocYXd5jC40X3KmqoyaMiH7ec6j+gjw==
X-Received: by 2002:a24:e53:: with SMTP id 80mr2829529ite.45.1559885631122;
        Thu, 06 Jun 2019 22:33:51 -0700 (PDT)
X-Received: by 2002:a24:e53:: with SMTP id 80mr2829499ite.45.1559885630156;
        Thu, 06 Jun 2019 22:33:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559885630; cv=none;
        d=google.com; s=arc-20160816;
        b=vWzNZiDYwS2Pyn0bpfZbqbairG6di7BHJPPoHWVn1G02vFb38t/K7KITrxrPgKyNbA
         Pqekij/f9pH1CYWkB6Uzs30AQpQO7B9+q4j7jVtF2D5e1NbivgYq/2Nzj2xfNekeWA17
         hfT70vXK231UQ8OtyfTHxmXvE3geT5mlVmF3iAyT6FKIbWYO8ybKLLfWnv2RGNLpT7cZ
         lIImGS3XOt1fFbDN52/cRm8EwiPxfjsmQS6s9dA7HVnHTFlrBVFKmmlqThEpnldCka/a
         g63noAEJylEwpJPnHm6nlQPzQ4f1T7hPAgO6MKQFnZ9LoptRcQlZrh6g3dfzkXDs+Iu9
         DNqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=I1Ohgac363EioDxzXpyXf7UN1ZgVyShBjggu94kceQ8=;
        b=QLo5Q8KzTLx8HvbECMf39xPv9bDtPbL/XMdFJkxfBcnk/mOhjn7I/yw6iyBjQsUmYj
         A7OJDYljxbqHVS6a7PLUAASYfddImsc4X+R8mShGXfnlOjSUw3VieyIUjfECExDQs0BR
         zq8o/qFq93f5e2Gs2WMuLC79lYGY5KoN3bvUsRVdLNEFEhibENBxzm62hDYcf4rPTyaI
         Igg5+6yMJa3MAQ5KLHW547yp1KlQpqpNydcgy6tDW5M5rD68vO5bvoNkl/59GAn2iWed
         RiPDu5yzEq/2147w1EJ40lPgfS3cdacUrISeHFXbnIoHPfH0khUmdKk78+9xUk2vSbQQ
         1NVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="k/GR7joJ";
       spf=pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=jens.wiklander@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 203sor1081104itl.24.2019.06.06.22.33.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 22:33:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="k/GR7joJ";
       spf=pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=jens.wiklander@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=I1Ohgac363EioDxzXpyXf7UN1ZgVyShBjggu94kceQ8=;
        b=k/GR7joJNJJ6Ve9R/aFsDJRsptZAid18wqkAKiXzRB6NlE5r0KsuMRDWBQiDjQE71p
         daD8j4DSrVfI6HVAkD5vCpZj39PQaq9fApbZACjRC0RDDKZIBpn7/PLmAhGU1uSNjV36
         ZPpnk1tioX9M+1EYWJoeTvWylBd+vbf5sKkC6jEafyQKFEFkOanMnEF7whEz4Nqwt4hG
         bE4l9bBTG0ogocOQzuioUmmPSF5w+Ho92/o1cceuVe444tHP69yQxu8DSewMXHLCqg4l
         Ja6TZAP9vQDDI+y+jUJx9i8y337VPVjbLYX5aoIkmB6O4W9ByhkvQ0wvmaFU4t1VIu/d
         h8DQ==
X-Google-Smtp-Source: APXvYqzO76FNbL4lc2mT5nAI8664+vPAEC2qxggUSScGxp/b2eT89TkEwyH+hzeEqr8qRCV6LZQ9VkHcX6jY2/9nElY=
X-Received: by 2002:a05:660c:752:: with SMTP id a18mr2789419itl.63.1559885629583;
 Thu, 06 Jun 2019 22:33:49 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com> <dc3f3092abbc0d48e51b2e2a2ca8f4c4f69fa0f4.1559580831.git.andreyknvl@google.com>
In-Reply-To: <dc3f3092abbc0d48e51b2e2a2ca8f4c4f69fa0f4.1559580831.git.andreyknvl@google.com>
From: Jens Wiklander <jens.wiklander@linaro.org>
Date: Fri, 7 Jun 2019 07:33:38 +0200
Message-ID: <CAHUa44E+g3YTcja+7qgx+iABVd48DbrMMOm0sbyMwf0U6F5NPw@mail.gmail.com>
Subject: Re: [PATCH v16 14/16] tee, arm64: untag user pointers in tee_shm_register
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Alex Williamson <alex.williamson@redhat.com>, 
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

On Mon, Jun 3, 2019 at 6:56 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> This patch is a part of a series that extends arm64 kernel ABI to allow to
> pass tagged user pointers (with the top byte set to something else other
> than 0x00) as syscall arguments.
>
> tee_shm_register()->optee_shm_unregister()->check_mem_type() uses provided
> user pointers for vma lookups (via __check_mem_type()), which can only by
> done with untagged pointers.
>
> Untag user pointers in this function.
>
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

Acked-by: Jens Wiklander <jens.wiklander@linaro.org>

> ---
>  drivers/tee/tee_shm.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
> index 49fd7312e2aa..96945f4cefb8 100644
> --- a/drivers/tee/tee_shm.c
> +++ b/drivers/tee/tee_shm.c
> @@ -263,6 +263,7 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
>         shm->teedev = teedev;
>         shm->ctx = ctx;
>         shm->id = -1;
> +       addr = untagged_addr(addr);
>         start = rounddown(addr, PAGE_SIZE);
>         shm->offset = addr - start;
>         shm->size = length;
> --
> 2.22.0.rc1.311.g5d7573a151-goog
>

