Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61148C43613
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:41:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 191882084B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 23:41:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r5JIdJ/o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 191882084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FEBF6B0003; Wed, 19 Jun 2019 19:41:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 887AF8E0002; Wed, 19 Jun 2019 19:41:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74E558E0001; Wed, 19 Jun 2019 19:41:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CBAD6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:41:18 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id j77so206163vsd.3
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 16:41:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4S6wJji0gcgl4NBCnpFCHSOLG2rN/9LzvZSGruzYoLc=;
        b=Kxuj5TNyiZD4rJbtvj+FGnidcfz4ujWbnxDgfDvfKwbKTkSvS1IAJ2tHIdlJsGx7FS
         uVkgJsYABPNnVWRizfuMqNiN36SAUImL2yJ0LwWuZYnLqKZfeW5Rdb4P82T199e6Z6/E
         V+RG6ACfXcVlhomY0f6iLf7Ok1dGiVxA1QU8eWAGqc/vRnz86Pci/FuqYIotqUO/6pz9
         riLgPCCbG5w6uSjb8kjmkeJJx/T15xJgnhTxZC0WBJSfDqbcpbxcBesUwWz3BwrynHZw
         23tMS20ZK1IpJfyrbBcHnvQgr/GBaqrBQSyvbmRzIrGmc6gWdIJxEd2WQMgTSdjILBEN
         D1SQ==
X-Gm-Message-State: APjAAAUNHEYh/HwUf+KltolnB3Q/ALpxLYNTW1zgHiqf2QYZxt6c53AA
	9AclotIxbmZwRQw0zY2GKC40k1GI0kdYzFYJe1eth749nIVvSVrof/TwG5oQn7XkayVpdUNmiy1
	fQZCsqf4bbRkWkHABmjObPn35rvMS2sBcT9wyj3cJx8ss38CpPJL6pz7SYA7bVB854g==
X-Received: by 2002:a67:d386:: with SMTP id b6mr45947048vsj.170.1560987677937;
        Wed, 19 Jun 2019 16:41:17 -0700 (PDT)
X-Received: by 2002:a67:d386:: with SMTP id b6mr45947020vsj.170.1560987677408;
        Wed, 19 Jun 2019 16:41:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560987677; cv=none;
        d=google.com; s=arc-20160816;
        b=WxBko0MKNyefxHSHbO+gxyzi/XrnBN16hqtde5CuS4896HRe/wZHe5heLrU99iFYwC
         bBx9xO6Vq278ftE0DjpuxYgeIzfVHietQVYM0YqTvY+hRJ8Z3P7AP6lWm7l5zaUQF0DD
         h/b12lGqSpKp56AX3yt1guM26h/qlGG6gj15KkCLfdpK9naUWW4TRlAjHYrA8G2qBReK
         6JRUSaqk0RwTdsiPonrfQ3Tb0Vedt8OPRimLu4GEHvWAavGcFr8c2U08ub/9+YzrJ+jL
         3oBP52BZfTGw6okX+gfE9V+zev53bsSyRD7YJhS2ooeuhNnmnxpJ+uGXsrS0XF+s1UWy
         RLbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4S6wJji0gcgl4NBCnpFCHSOLG2rN/9LzvZSGruzYoLc=;
        b=dPiqPOO3k/bcHDj44JipUWFuI4DUtZ4yiDouOaVGDVnklC7BEPMTgHOcYYJi3XcdFV
         Z1SLMFnQIBsPxOecMFG32Yw+TVaoFIEqJ8TfbMWP2nhTjHkrkdA/GgP08S62ZZd5alrk
         /DxYFAw0bssQNAZnaHztHKoUOwsH5ErQ14zozzbOD+j1Av7G6vXtq1H07944HjnxX881
         +r+n5zqX/HxhUvGF1EXnm1ji70npalqk3LxG1oWR7VqbLhlNT6OlF9PyK4EMLcK+eEXM
         q9e4SByB2xJzQu043KwcKE+dYtilhuR/TVciqAzvbneuXHrkGZTb0MM93TvZ3+A88Mu0
         hE/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r5JIdJ/o";
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o10sor9563217uad.53.2019.06.19.16.41.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 16:41:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="r5JIdJ/o";
       spf=pass (google.com: domain of avagin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=avagin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4S6wJji0gcgl4NBCnpFCHSOLG2rN/9LzvZSGruzYoLc=;
        b=r5JIdJ/o1v4aHKdBEsLJTiu4d+96pIOJxiREE80wIMMhx2zCAzIdp+sdWBjaDrpYLx
         c0LufpT7cH4pBTFYNDLtW4Q9YcyaRzHZsURNDnp/RPtmj8jWqIm8+k8YKYYSE4lZMGL9
         1pFV9INgFjRfr2In6DA+ZLYqqBGNJi6+vlCdKdNq1THOIPICj22AQQ6OOi8BwyOAean/
         CJs5cKCkkEb7bYtHKmpCGeXvJ9docD87Hr288YJOpIPWC9LhNny3XmcViaYDyfbuMCUZ
         ttPZhmEkn74IUURCB+B3mq/vYq7NaUGBI5S7atVVsHWK0aakMC2lwmvtwax69KVby6M+
         SlEQ==
X-Google-Smtp-Source: APXvYqzTN1QVq0nmJ/eFFi2lKKlVvQvvm5zDD8gMwepUhPUOrL24jy3n5SQWGE238fRGh9vz7CvAdKhInCkFk7PaaBA=
X-Received: by 2002:a9f:3871:: with SMTP id q46mr12695329uad.50.1560987676823;
 Wed, 19 Jun 2019 16:41:16 -0700 (PDT)
MIME-Version: 1.0
References: <CANaxB-xz6-uCYbSsSEXn3OScYCfpPwP_DxWdh63d9PuLNkeV5g@mail.gmail.com>
 <20190619211909.GA20860@castle.DHCP.thefacebook.com>
In-Reply-To: <20190619211909.GA20860@castle.DHCP.thefacebook.com>
From: Andrei Vagin <avagin@gmail.com>
Date: Wed, 19 Jun 2019 16:41:05 -0700
Message-ID: <CANaxB-xAjfpmLSVLMWb2EETQR5zroizJ9xjTNmTTARnJBSEYvA@mail.gmail.com>
Subject: Re: WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
To: Roman Gushchin <guro@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 2:19 PM Roman Gushchin <guro@fb.com> wrote:
>
> On Tue, Jun 18, 2019 at 07:08:26PM -0700, Andrei Vagin wrote:
> > Hello,
> >
> > We run CRIU tests on linux-next kernels and today we found this
> > warning in the kernel log:
>
> Hello, Andrei!
>
> Can you, please, check if the following patch fixes the problem?

All my tests passed: https://travis-ci.org/avagin/linux/builds/547940031

Tested-by: Andrei Vagin <avagin@gmail.com>

Thanks,
Andrei

>
> Thanks a lot!
>
> --
>
> diff --git a/mm/slab.h b/mm/slab.h
> index a4c9b9d042de..7667dddb6492 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -326,7 +326,8 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
>         memcg = READ_ONCE(s->memcg_params.memcg);
>         lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
>         mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
> -       memcg_kmem_uncharge_memcg(page, order, memcg);
> +       if (!mem_cgroup_is_root(memcg))
> +               memcg_kmem_uncharge_memcg(page, order, memcg);
>         rcu_read_unlock();
>
>         percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
>

