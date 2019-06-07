Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F6AAC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:10:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC864207E0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 22:10:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XuBNVLdg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC864207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DD236B0272; Fri,  7 Jun 2019 18:10:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58C676B0273; Fri,  7 Jun 2019 18:10:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47C326B0274; Fri,  7 Jun 2019 18:10:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id D60316B0272
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 18:10:57 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id q12so387782ljc.4
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 15:10:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=KJ2BLcajVixF67CJRoLG0re1JrYiYqxErMSXYl0tsRw=;
        b=kPMOCG18nRwtnjX59YNvJNu6ucH4xjdnHwNfICBXtg56/cGf4H4BRtE3UwTDoX7cVQ
         kiHI7q51sQ6u6rQffWV1CAeLQhYSCpEE/Fe4Ud5ed3zgDd2npvdqG/dyI39/31W4x91B
         t1SwWJNN0t1PUcshzQnBbE99/OQ/4gQVupHSviL7ZoIseNFdliPk312dmIqSt6O/GEpr
         phNxJRXs/QqBPe3d1iUWn6pCRgEEpUR9GTUb4dnOgy3if5ZA/UcpgPfVvsyqWXSsok3m
         9uEFY3WmiZ0m9Rw64spckXzNmrqIC63hC6GEuoIxwm5XKIxElyXlouB5kS/yhA3NYcdX
         SAtw==
X-Gm-Message-State: APjAAAWLGNoNh1M7W+g6viruJix9dBs+LOAmDq1g5zOUvzBEDsx62neU
	2PPBtlCLhXa60sI8vErrRnMTUHjo3aBCGJEkJieHjIffsefgEutKjSQi7gx8wcVU7a6QG8EF7vC
	Jguhhx0EwOMhc9SlIGnJtoirt4NUDPO3pvMApV2RWTk1tq/utCpxuSC2afp7f3dieQQ==
X-Received: by 2002:a05:6512:24a:: with SMTP id b10mr25479100lfo.37.1559945457340;
        Fri, 07 Jun 2019 15:10:57 -0700 (PDT)
X-Received: by 2002:a05:6512:24a:: with SMTP id b10mr25479077lfo.37.1559945456634;
        Fri, 07 Jun 2019 15:10:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559945456; cv=none;
        d=google.com; s=arc-20160816;
        b=AI+djxk9Sn7HXCjiVsrvrolvZXpLg6yTsmEFSSBUMVzCXLt1DJM1RMbxFn47TEkCOG
         drW/wvMCxpmpCPKL1rVUo0hO+RIxODKsg57lZ3C76MsZAnvMuYmToRzLOMRp8eac7nFi
         WM65Gj4o61rJf0g8OPfXRej3BGX2de9CjGCieqHQtpTzZ8xDz9i7+PiEEqwtXVU3DjQk
         bB9fX+ud0eLWvzbLmautliivF3bljP27wiwk5njY2M6/kREC3JrcfiSdmfDH+CUWXjFY
         v264Q2fqrGxsH8BISUvwoJIPkcp6XsXRr4BO6HLoGHYzBtxcjfxU7Mk+mW9H9pmvVIGI
         qBdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=KJ2BLcajVixF67CJRoLG0re1JrYiYqxErMSXYl0tsRw=;
        b=Q0cOnJ/47dS5Gpaz1PPZRymGpFa5aSdEqioK+JMgvmaY6c4g5QRnsOJ+Lcrr1vO+ob
         6Zetqi+WW8ACyF4HGGYjPIfSh17pxCvGMTAjNxoLAS7dWEezg2793jqmryBUORtp+e3c
         QaAookX5Dyh4MS2T3CL51UHfrJciz+fwROC/wd2ASOEJ5VJXnd6zCVEIX7aOc8IUa7Va
         pr6xZ9Cit7raJmiSqvKT7EDwD8Kj+jty/ZoIHyqGggJoD3xs+sWquYRqaAbuOzKZwqO4
         yj/ZshQjM7qcu5qnLysuUMexzQpICH8ZFc7UIqc9KCXrCGRlqv5pkaGqQyu2uzmOr3tZ
         0qqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XuBNVLdg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c20sor1328822ljj.7.2019.06.07.15.10.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 15:10:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XuBNVLdg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=KJ2BLcajVixF67CJRoLG0re1JrYiYqxErMSXYl0tsRw=;
        b=XuBNVLdgbcY56Ud4pdH5EXvxmGUKkACohMhQU5klJr5o3160jnTXt0fFBjrUYI8cwP
         qecWlqIvuoz0yWBNmcfBXRagMuyCN57WmUDAmyLBAoGU/vidUSxhCkBsLMXMAH3gz4EM
         tWZ1AvPkv98MPJtshU6r4aCzmSJMbti0XAF/zuBjkobX6oY2h/G+vb0ik5Hw5N96rvpl
         6I3l+tkrVJzURiq0H50JHF2DmIxfH/WItDgvQ/p6+kMn6jvKrdwRXX3GqUJ8EGr+IbP6
         8uKRI0Z+Ms/ak/i4ugiXOgxFVoAHcF4ZSdzDMKgNGJtjX6zHgettmLUAxF9t1zYsva3u
         aXCQ==
X-Google-Smtp-Source: APXvYqziLCb0F1leUAaa1UiZwsg3YnrP4quS0pn+HDEfTbgIMU+w+qLFrO34EBW5m2sppHV711BE8EPBCVYV8kHdz3g=
X-Received: by 2002:a2e:3912:: with SMTP id g18mr20425063lja.38.1559945456292;
 Fri, 07 Jun 2019 15:10:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190606184438.31646-1-jgg@ziepe.ca> <20190606184438.31646-8-jgg@ziepe.ca>
In-Reply-To: <20190606184438.31646-8-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 03:46:00 +0530
Message-ID: <CAFqt6zbPYWiV+2d7-o8EYACKKM2s_M7U=9j3pRux1OWsEqrQAQ@mail.gmail.com>
Subject: Re: [PATCH v2 hmm 07/11] mm/hmm: Use lockdep instead of comments
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, 
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org, 
	Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 7, 2019 at 12:15 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> So we can check locking at runtime.

Little more descriptive change log would be helpful.
Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
> v2
> - Fix missing & in lockdeps (Jason)
> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index f67ba32983d9f1..c702cd72651b53 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -254,11 +254,11 @@ static const struct mmu_notifier_ops hmm_mmu_notifi=
er_ops =3D {
>   *
>   * To start mirroring a process address space, the device driver must re=
gister
>   * an HMM mirror struct.
> - *
> - * THE mm->mmap_sem MUST BE HELD IN WRITE MODE !
>   */
>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm)
>  {
> +       lockdep_assert_held_exclusive(&mm->mmap_sem);
> +
>         /* Sanity check */
>         if (!mm || !mirror || !mirror->ops)
>                 return -EINVAL;
> --
> 2.21.0
>

