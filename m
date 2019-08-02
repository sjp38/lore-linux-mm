Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE7C6C41514
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:29:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F5342073D
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:29:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="RjyjBD2o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F5342073D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 145A06B0008; Fri,  2 Aug 2019 02:29:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F69F6B000A; Fri,  2 Aug 2019 02:29:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25EB6B000C; Fri,  2 Aug 2019 02:29:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id D48146B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 02:29:20 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id y13so81979848iol.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 23:29:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8J0CG6n/mGE9VY7Tzl2V8r1MEJfljCPCP1w3kMFb7gU=;
        b=IlzCQmziG5tL9+bIlxfnH4kMLddY4bilRYGcA7SqR3PnNIY4OQHINPNHprueoLex1O
         5Pb8aKygx32PHSU+pIgQ9M13kCvNNGrVyRQpyFkacVB747tCCnP7cHtjvs0m1+ZpQrAJ
         mZET9vY1RclIv6+wUvZLq/YVN4VYc9HgwHQlGN7bAtkH4IWywpzBZr1QqlcxgW2pxsAY
         bLxFdiwb1OAGZsPfUnzLEI5ZJ8bOo0PbgPxm7WhSWmHrZncjtEfhUUtJpoQIPUBn+6Rq
         fqebaV03hJcS9dau2DX6bPVzEm1Agkn0Mc9Ur6TxYlsrPoTfjLvCUAuU8euytNImkm2w
         oxKA==
X-Gm-Message-State: APjAAAU3y7RbTmkNh9m1HywwS08hi5++48dIgXrU7IzfbOi2pKusgoKy
	GYtOlbX3eIWAHeifbu2o8O1xlPInNcmrDEAApzCXVvYBaQVcvUEnJiJzbriByVxSqUixEpAgc2U
	5dhAjqsKZ/H2yni1GuE69npZuhLQKKTj0CJGxzjRpPa5r6kDg0LjOgcG+ikBfa4edkw==
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr109475215jap.17.1564727360623;
        Thu, 01 Aug 2019 23:29:20 -0700 (PDT)
X-Received: by 2002:a05:6638:40c:: with SMTP id q12mr109475101jap.17.1564727358896;
        Thu, 01 Aug 2019 23:29:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564727358; cv=none;
        d=google.com; s=arc-20160816;
        b=HstT+HQ3FvHF+hkBLcrsNrjihJ9E2mdxhZpwU9xlJ1RTQ/T2poJGcMyDphYD68xBM9
         Gs0+12aMA4vd/8ENPXKVxItyd40jvYosldS4OAe8BT0HD5GNM98cseHUYt3sqo1xSOi0
         L7jIncOqUZZupWk/O+sBETNNqsqxmU4D8unEua5Bmsz5ftpd7bvybpTKxG8pjGZjmZ9u
         6TQJP3b+eoXDrzYtCLglyyjmsESoXCanYpo8Vf5XSGNI9v6zpl9JMQWAm61aSlA0ijhG
         2B4IQMNLkp7KoxsGyvmPiQ5MZMtc9DLTSgabP1K84Ob0/ca27N444yS5MIf0BtQL0pV3
         jQEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8J0CG6n/mGE9VY7Tzl2V8r1MEJfljCPCP1w3kMFb7gU=;
        b=npLxgH6nRIV8DzegCxuj21kB2IDjrmVUq2v7T2rdSwvL4Uh13JgYPdeVgrGWzkpow+
         WH8KxErOJZysHXv1FUBKQC5z3kqR4RW4MzeOBp0/ZD4SsWTbooLKfvNH62/vgw2BQIfp
         DqV7OXnWMLXf7L8/uBZjDD6sAWW2fQVLrOo532jQGuPpruhZNa3L8un5ULsYsHKGtrNR
         Ejm577M02feAftOpOyE+/W/3+I+mOz7gI5dF1yxRndiZs1QcMR6eMiC8caV9ZBj5qw8W
         Uvwt3+XExh/TQqmZbV6ziRWRtcJz9i/rnkkd+isUTU/Df0GAmsBzuxFyCTszSwiTYFYH
         CvmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=RjyjBD2o;
       spf=pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=jens.wiklander@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q25sor34064265iot.121.2019.08.01.23.29.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 23:29:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=RjyjBD2o;
       spf=pass (google.com: domain of jens.wiklander@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=jens.wiklander@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8J0CG6n/mGE9VY7Tzl2V8r1MEJfljCPCP1w3kMFb7gU=;
        b=RjyjBD2oGv8Yelvkiciev/lZ+Q3xXx8QFqdYzdY4aCHOlugQGM86oI6FqZDvirisZ5
         VJ+QLkBMLnRka6ltoYGD5wyPSjpGXQPHFctjuGwd1+UFurx0yvKt9ushEUj8EZV9ix2W
         01tKC6Gaz3MS8M+0E+YLTPk1gYgnaZnSfnfDmi+UFK25mv5gEzSDgABsBJUiG+nhSsUl
         RKT5eQ9kRkeBcJ7gT+NzJThlFQ8TbWheTrXZG+kEcBrFAA6KQockx50ATbHKRl86DAya
         RCLedopliZ67rTczSP3iIMKDggIEdiJgpUtX8J4w3apFv4UIzEajhXW7aw51MfImXOri
         CFCw==
X-Google-Smtp-Source: APXvYqyCEEQjF5gUAqe0Jy7lkgRv7S109dxiMqY3y1rXR3KgTUxyI68+/GDAwhKmPjZXNLxgfhvOgGBjK0GGgCuPqfQ=
X-Received: by 2002:a6b:3b89:: with SMTP id i131mr71226796ioa.33.1564727358352;
 Thu, 01 Aug 2019 23:29:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190802022005.5117-1-jhubbard@nvidia.com> <20190802022005.5117-17-jhubbard@nvidia.com>
In-Reply-To: <20190802022005.5117-17-jhubbard@nvidia.com>
From: Jens Wiklander <jens.wiklander@linaro.org>
Date: Fri, 2 Aug 2019 08:29:07 +0200
Message-ID: <CAHUa44G++iiwU62jj7QH=V3sr4z26sf007xrwWLPw6AAeMLAEw@mail.gmail.com>
Subject: Re: [PATCH 16/34] drivers/tee: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, 
	Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, 
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org, 
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org, 
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org, 
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-block@vger.kernel.org, 
	"open list:HARDWARE RANDOM NUMBER GENERATOR CORE" <linux-crypto@vger.kernel.org>, linux-fbdev@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org, 
	linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org, 
	linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org, 
	netdev@vger.kernel.org, rds-devel@oss.oracle.com, sparclinux@vger.kernel.org, 
	x86@kernel.org, xen-devel@lists.xenproject.org, 
	John Hubbard <jhubbard@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 2, 2019 at 4:20 AM <john.hubbard@gmail.com> wrote:
>
> From: John Hubbard <jhubbard@nvidia.com>
>
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
>
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
>
> Cc: Jens Wiklander <jens.wiklander@linaro.org>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/tee/tee_shm.c | 10 ++--------
>  1 file changed, 2 insertions(+), 8 deletions(-)

Acked-by: Jens Wiklander <jens.wiklander@linaro.org>

I suppose you're taking this via your own tree or such.

Thanks,
Jens

>
> diff --git a/drivers/tee/tee_shm.c b/drivers/tee/tee_shm.c
> index 2da026fd12c9..c967d0420b67 100644
> --- a/drivers/tee/tee_shm.c
> +++ b/drivers/tee/tee_shm.c
> @@ -31,16 +31,13 @@ static void tee_shm_release(struct tee_shm *shm)
>
>                 poolm->ops->free(poolm, shm);
>         } else if (shm->flags & TEE_SHM_REGISTER) {
> -               size_t n;
>                 int rc = teedev->desc->ops->shm_unregister(shm->ctx, shm);
>
>                 if (rc)
>                         dev_err(teedev->dev.parent,
>                                 "unregister shm %p failed: %d", shm, rc);
>
> -               for (n = 0; n < shm->num_pages; n++)
> -                       put_page(shm->pages[n]);
> -
> +               put_user_pages(shm->pages, shm->num_pages);
>                 kfree(shm->pages);
>         }
>
> @@ -313,16 +310,13 @@ struct tee_shm *tee_shm_register(struct tee_context *ctx, unsigned long addr,
>         return shm;
>  err:
>         if (shm) {
> -               size_t n;
> -
>                 if (shm->id >= 0) {
>                         mutex_lock(&teedev->mutex);
>                         idr_remove(&teedev->idr, shm->id);
>                         mutex_unlock(&teedev->mutex);
>                 }
>                 if (shm->pages) {
> -                       for (n = 0; n < shm->num_pages; n++)
> -                               put_page(shm->pages[n]);
> +                       put_user_pages(shm->pages, shm->num_pages);
>                         kfree(shm->pages);
>                 }
>         }
> --
> 2.22.0
>

