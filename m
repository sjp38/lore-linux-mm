Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B37D1C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:28:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C1E6208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 19:28:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yx6/1xCl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C1E6208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3A4C6B0007; Fri,  7 Jun 2019 15:28:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE9856B0008; Fri,  7 Jun 2019 15:28:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A260D6B000A; Fri,  7 Jun 2019 15:28:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3F43C6B0007
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 15:28:47 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id m8so702202lfl.23
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 12:28:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jlRPeDHi0azRjVmRRuBjAHPXJeSQOwNdzPjbtxE4i9M=;
        b=QgG7SF6//bTR2oXyB84VFfq9JCT0e2gd6RMjkUYnIWIqXsdIZ51HfGAA75njfy+jE0
         k7tmoyymOt2ACyzDwHMD6JTeMSVD5EjPY5EZ0DyojAg2MttCo/3JFdacaijYw/daNgmc
         O2Ns5iWnB3VLyOW0pl0tylZckwhxhShZ06A6H0xqbdDnp/6vfSJiO0YzaQCl4XMOJcP0
         9BENj3tuKQmzGcIyxd0QA3gqgDoRTasURtt/ioAx7DJqViTG5JR3NZHgxXVq0INYEfTq
         tRzQTB+IdiXIpLEeS2sFTrWdn+2qe3ZySFMebWd12SMeE6Ip3SVCuf/goR9IX02ko0OQ
         UhDg==
X-Gm-Message-State: APjAAAXyd7LhwOcoHhxjNAtlueQTfMue/jhmmCs4uz8su3TskG+/G/Pt
	hdU2ZwtclfbXjdfOZi4sp5iTDmEOeT0dhxyAQDW6E4KqzSg8+NicxygMV+1gTBwhahmvIF57Zod
	u4zPyvAr8325T7whaINpYi5MGxHMI5n1wwjsghAmqhy+Mds3zLXReYUJccwKBOIctjA==
X-Received: by 2002:a19:c14f:: with SMTP id r76mr17570145lff.70.1559935726416;
        Fri, 07 Jun 2019 12:28:46 -0700 (PDT)
X-Received: by 2002:a19:c14f:: with SMTP id r76mr17570109lff.70.1559935725290;
        Fri, 07 Jun 2019 12:28:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559935725; cv=none;
        d=google.com; s=arc-20160816;
        b=v7GlN9r6O/wlecPokZCwD6jI/GRlbYbrtBlHt1yx3K9N6H5L5yQG+k9YYPKOZe9ajZ
         DQXD7vwoB+UOY5VHV79Hr2gtGdrO/G7KHdXPvywUJyXICGoVK+HwNnK7uuMHmrVe32oY
         LlChSHHuWhJp862VzlfzzXeyPW9rupaJzrgN1TGRAQwAmoe5dh4IEYkZQRYBGPImVKvz
         wm03CkaRN97w3L9+1/x1uoN+agHBVSwTbF5hXnphdiUGGxyJk2MRETYe0nqYGbMs3XE/
         yRiuzTZu3RFXdZA4K0jq+wPDmf7RUgyDeUKD4cjbilgiHowdNlCNlW80SF4ZW2LgNh4O
         Eg0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jlRPeDHi0azRjVmRRuBjAHPXJeSQOwNdzPjbtxE4i9M=;
        b=i3b3VP4VcHdbycCgk3hKMok3NTT72oSjZDfuXmJhd/vorhduLJ21E+3HsTDlHE4GHx
         qQmVgqjrxec5Wa7CZWTO+Rcub6sYZSNsnQbDBs58eaC+4LAVfkj754qcSqlSc+4fZ6JK
         LkS/lL7KwCF95OP116Ut05ubg3m1HKOom+C9zM0KtuoD57CdC7QK7GYEPV5DzDDJJVJO
         TzQC6IiytvLnu11DYfFX2WrmPgUolO/P+DrpxMtyPL6RSMHoPTGniuVfbY8x1vj0UD2t
         BzuQiSFT4zSmjH01hWmQjHboQqpyj8kDQY/Jqj7biDbd7VopIYsfL0y3w26zaN6tpRiq
         xErQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Yx6/1xCl";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g20sor1875239ljk.28.2019.06.07.12.28.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 12:28:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Yx6/1xCl";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jlRPeDHi0azRjVmRRuBjAHPXJeSQOwNdzPjbtxE4i9M=;
        b=Yx6/1xClyrNGnGwCp4vb40gTIiQEiT7t05SlLTqVZcMEQhYlLSI8rZkhaccouoWuKt
         3KTwRnenBAzMekmve3HaSZM1Xxhy1STO3OyDhj3uxF+wjNs8B7DJMTYfTkqju+4RKqh+
         xS0GZHyZIdPcosGREWWk4ZAguMzFHhg8ogolkfeX/XsdavqASaLQVF6WxJahTwwU9SPO
         ovDhj5ekAjKE0M/nJ/eC4dTZueY1h1oaCt2Dd2lCEHM47gqwel4ftYl8BhG9TgmQIHNt
         51fuNGW4m1K513Xd4gzA0q4C9VpoetO6p5VPZ5VkW1b2UdijJhit9lw9g1psUWCXcYGs
         lFng==
X-Google-Smtp-Source: APXvYqx0qKprLQ87qlAbjtmXQEdXhJ8KkH2DSH0IxBEmNEYteKaq5Dm3xiR623NTFVEHjgmvhg0VhLekU5O8P34Ripw=
X-Received: by 2002:a2e:9747:: with SMTP id f7mr27943424ljj.34.1559935724712;
 Fri, 07 Jun 2019 12:28:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-9-jgg@ziepe.ca>
In-Reply-To: <20190523153436.19102-9-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 01:03:48 +0530
Message-ID: <CAFqt6zakL282X2SMh7E9kHDLnT9nW5ifbN2p1OKTXY4gaU=qkA@mail.gmail.com>
Subject: Re: [RFC PATCH 08/11] mm/hmm: Use lockdep instead of comments
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> So we can check locking at runtime.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 2695925c0c5927..46872306f922bb 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -256,11 +256,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifier_ops = {
>   *
>   * To start mirroring a process address space, the device driver must register
>   * an HMM mirror struct.
> - *
> - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
>   */
>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
>  {
> +       lockdep_assert_held_exclusive(mm->mmap_sem);
> +

Gentle query, does the same required in hmm_mirror_unregister() ?

>         /* Sanity check */
>         if (!mm || !mirror || !mirror->ops)
>                 return -EINVAL;
> --
> 2.21.0
>

