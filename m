Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C40EC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:37:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D017F218EA
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 14:37:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cNYsnnjV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D017F218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CD968E0001; Mon, 22 Jul 2019 10:37:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57D966B0008; Mon, 22 Jul 2019 10:37:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 495018E0001; Mon, 22 Jul 2019 10:37:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCC106B0005
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 10:37:47 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id t2so8614716ljj.13
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 07:37:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SUH6arJbp14IVMjbkeZ0K94NO/z20TDutwCqOxsq4Fw=;
        b=duIxf9WfGKzEDpZrbD9rSdFPlkCFULOB1goveMJXCOw6uQvloMHYuisHQBz/t9biZ5
         53cZ8bCsG3qftMOL+DzqfcCUnBEYwqgDCKAuafOdGRocshdxbZYSXDnRUmD/vW1b2P45
         SjuYpnlyrjNhOWSsNNmDdx9Yv+1jTqg9kBum7YklA7N7E3bB6rUfC/Xgliy3HS/ITFwa
         9qSsvhmSFlV6VBUUsYZd3ckq88LeZKKKx/Bg6Zks3lqdt3t3BnDMVF7pd2UJy3OA7MH+
         peqvTKdfbcg8MdYR8N5YNEtQskwJsd6ayudOsqInpcrwxAE+dEUuA8u6ajyY+SXrYXty
         0RVg==
X-Gm-Message-State: APjAAAVkhbljoI0MizQDqSEhKTvtYRi/PgkSy0PCyMP7Ppd+GGPTxUBT
	Amj4cb7HpY3xWeuvo3ZKMYJ3xA5FgUl5K7MEsUNFMVfCSvMCg6TXWyeAhX03yJ/MLbP1nYL5POG
	+8btQr9bJVKHOb3VJwQsMR7xrah599wxDcOE14sC/5jln4B6zGuiZzqFnO1gPRwW2Pw==
X-Received: by 2002:ac2:5b49:: with SMTP id i9mr31790783lfp.116.1563806267075;
        Mon, 22 Jul 2019 07:37:47 -0700 (PDT)
X-Received: by 2002:ac2:5b49:: with SMTP id i9mr31790741lfp.116.1563806265945;
        Mon, 22 Jul 2019 07:37:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563806265; cv=none;
        d=google.com; s=arc-20160816;
        b=oY0dFxS4KMmUuRfGpGQRMcVEIAsJBsl8HU3iGWvs7n5WlLd6bzEPAoZ58YTgdEMlwh
         jbCF8+P3vYsAUdZok5V2WMtSQz4PucDHqRwZ0ywNlLvr+lfrian5k5xkDyVQrQwWnGMK
         rmIIq7bbedLIISKgoI0uyrPWNTCz72CF1mnsmS7DRcWAnMVuO1HPB/algsMJLugbIEV1
         IY6g2OBiIDRa/4MZm9iYJ5hGZgVdAUoI/z7/vp6cpUQD1a+Xv14R1do6ggLi1mvRR4wH
         I2bPxFTw14Q3eISjKBLtmMn0k7m4+/yyqxgY80QIPaye2RwlyjLUW2hjmWZO+9jq/bBb
         FahQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SUH6arJbp14IVMjbkeZ0K94NO/z20TDutwCqOxsq4Fw=;
        b=dgfv7+Kkw99JX2bVUrX6a9O9FmLqcfz8C4sBeL0dlF1omwqRS4WcuZH6/HehZDb1n6
         hy62nqrf6VW1owAMD+dVTgA04Yjcu7AMI+y+7dfFA/YE+vtDJb9bcteuSfCWaNqTViKW
         QXAW8lc9LjmvmfKf2c2uur7jCxlXpNnfgeUG0+4OIwCifBT9CIa9KxQ5jEEkQTAWpLJN
         ams1ZtkyWDxNanYh8J+JlJduDy9v4uzC3PPy4DpTEzWF/0CdfkzOx+PNfQ3BiCtAvvyo
         CQ5BkRQtiELxs3Ar6JEkmR5cVG4peHoGC/2TTw5tQw817yxHY54+U+5WP4ZuLUB1MDZY
         4uXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cNYsnnjV;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor21522772lji.35.2019.07.22.07.37.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 07:37:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cNYsnnjV;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SUH6arJbp14IVMjbkeZ0K94NO/z20TDutwCqOxsq4Fw=;
        b=cNYsnnjVLguyuhcKHqqxp7hSA5M3S1DZvaBoF80d1MZLvyCLSsdsxyzbqp+hAugfqB
         La4mTA+QaSN25eS7kR5jYbs5x37bIW38yuFEe9LoQUhA4BKZbg7G89i02FTdSaoa/LHD
         0/lmUGsZBZhSpFQ3CDG0yu7d0XOEvaaddpieq56zgY56JIdUSioPyWlIQN+Coy+AXBhh
         i8jmWmQqzLzSlVGdTV2hn84KzjVBQl4pbwsL+KCS9KIx6GA7hL+D2ZJUFh8ilWXmzYh/
         dAZFYOljbOddCkc8Zmh16FrOyiTux9Y7iKOyUucQi77FVxvyJCXpJp2vmP1KIUydFgVE
         61bA==
X-Google-Smtp-Source: APXvYqyUuyVhvpPVyaK0EtT6IHNJ3TNJikX6jVZCPNEmd7vcNDjv9sQO2bgfO2wFUz2CiCOMPgV4do0itfHJJ3iI0ko=
X-Received: by 2002:a2e:b009:: with SMTP id y9mr25605680ljk.152.1563806265548;
 Mon, 22 Jul 2019 07:37:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190722094426.18563-1-hch@lst.de> <20190722094426.18563-2-hch@lst.de>
In-Reply-To: <20190722094426.18563-2-hch@lst.de>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 22 Jul 2019 20:07:33 +0530
Message-ID: <CAFqt6zY8zWAmc-VTrZ1KxQPBCdbTxmZy_tq2-OkUi3TVrfp7Og@mail.gmail.com>
Subject: Re: [PATCH 1/6] mm: always return EBUSY for invalid ranges in hmm_range_{fault,snapshot}
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, Linux-MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, 
	Felix Kuehling <Felix.Kuehling@amd.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 3:14 PM Christoph Hellwig <hch@lst.de> wrote:
>
> We should not have two different error codes for the same condition.  In
> addition this really complicates the code due to the special handling of
> EAGAIN that drops the mmap_sem due to the FAULT_FLAG_ALLOW_RETRY logic
> in the core vm.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: Felix Kuehling <Felix.Kuehling@amd.com>
> ---
>  Documentation/vm/hmm.rst |  2 +-
>  mm/hmm.c                 | 10 ++++------
>  2 files changed, 5 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
> index 7d90964abbb0..710ce1c701bf 100644
> --- a/Documentation/vm/hmm.rst
> +++ b/Documentation/vm/hmm.rst
> @@ -237,7 +237,7 @@ The usage pattern is::
>        ret = hmm_range_snapshot(&range);
>        if (ret) {
>            up_read(&mm->mmap_sem);
> -          if (ret == -EAGAIN) {
> +          if (ret == -EBUSY) {
>              /*
>               * No need to check hmm_range_wait_until_valid() return value
>               * on retry we will get proper error with hmm_range_snapshot()
> diff --git a/mm/hmm.c b/mm/hmm.c
> index e1eedef129cf..16b6731a34db 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -946,7 +946,7 @@ EXPORT_SYMBOL(hmm_range_unregister);
>   * @range: range
>   * Return: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
>   *          permission (for instance asking for write and range is read only),
> - *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
> + *          -EBUSY if you need to retry, -EFAULT invalid (ie either no valid
>   *          vma or it is illegal to access that range), number of valid pages
>   *          in range->pfns[] (from range start address).
>   *
> @@ -967,7 +967,7 @@ long hmm_range_snapshot(struct hmm_range *range)
>         do {
>                 /* If range is no longer valid force retry. */
>                 if (!range->valid)
> -                       return -EAGAIN;
> +                       return -EBUSY;
>
>                 vma = find_vma(hmm->mm, start);
>                 if (vma == NULL || (vma->vm_flags & device_vma))
> @@ -1062,10 +1062,8 @@ long hmm_range_fault(struct hmm_range *range, bool block)
>
>         do {
>                 /* If range is no longer valid force retry. */
> -               if (!range->valid) {
> -                       up_read(&hmm->mm->mmap_sem);
> -                       return -EAGAIN;
> -               }
> +               if (!range->valid)
> +                       return -EBUSY;

Is it fine to remove  up_read(&hmm->mm->mmap_sem) ?

>
>                 vma = find_vma(hmm->mm, start);
>                 if (vma == NULL || (vma->vm_flags & device_vma))
> --
> 2.20.1
>

