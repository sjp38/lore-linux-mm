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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 275CEC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:17:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC71A208C0
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 20:17:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FQqTRrXg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC71A208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E31B6B026B; Fri,  7 Jun 2019 16:17:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 594696B026C; Fri,  7 Jun 2019 16:17:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AB216B026E; Fri,  7 Jun 2019 16:17:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id D87F56B026B
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 16:17:29 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id e13so725809lfb.18
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 13:17:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=eB+zLVLfAFyykufn/XC4ip2S/T+nSU9Oi0mJz6C4cpk=;
        b=p2wUSOJLHUFYUTDiQDxJrT0xrOivmBITNPIfHD1Gt98gH2ol/IA/5r1ylTSpLVcNHP
         yrRTCuzW99jq464HOEZGfSw3mvYM9PAuFvquhsYuWjJNrE7v3gsCDKwGslTx7D0K/wLn
         84Y9Sq4E++gLIKdr9oVBvYPFTgewVVgEC435zKfNh+GUGyElg38KWVPOcLwjGUgbhCA2
         dZLHRJdCpc7hVXvsdV8qy5sINYp74uwdnhGyWyOmoiXr88csh8h9ZaEbjC/l5hf2Ak0T
         Dwt4wG2vXMkiL/253FFcjqZPVuvelGJxtft1wuJYkW8V2ZOw2g/k79/E676hRygW0Led
         aozg==
X-Gm-Message-State: APjAAAUJzOyzw/ICMDRT2SfDNjQ/iOeY3RPdo9O3pt2/IJxXDlmlWhM7
	Bi6m2puSHmRx5IAqbZT3FhRMzfSLOLrf1XoYL5YKpYggwhZ7lWLHzIq2T10Y8bJyP8B61zEMXP3
	pkX8B2VBV3widG1tl1lSghKClMO0zG3c8nGEWC4zhwx7ty56pIEEKtBJl+8ibXViM0g==
X-Received: by 2002:a2e:5d9c:: with SMTP id v28mr28390892lje.32.1559938649272;
        Fri, 07 Jun 2019 13:17:29 -0700 (PDT)
X-Received: by 2002:a2e:5d9c:: with SMTP id v28mr28390870lje.32.1559938648566;
        Fri, 07 Jun 2019 13:17:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559938648; cv=none;
        d=google.com; s=arc-20160816;
        b=nmZ000K3q7J63iforn2XiQKcLinqXL/iEdrStovCrVHYOheAoWO1+r5F+5vzeb07Wx
         GPdN5EnXnwW1NP0LLGc3pWgdAJsEquGI9U3f/SvsHO0iMs+yOk726qp4gIaOgg8saDIQ
         wzWIQK4FvyjCE100fRJXV75sbhbG8/zCyQU4OrgP5/CqO1Gnk7HMgQa+hRnFzQhBcGJ8
         hAk+vwJIo4zn2iEAJUPxRmWp1wYGJ/61XxLyAqYpYrBS9P9kOtUq3sX/wz6/aJXDuSBI
         LZVftuZWL0X7IZzezF36z77Z8Mr9mck8IuXIk5orQZ4NKyWtUJ427suO9zQ70o0suEW4
         YHkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=eB+zLVLfAFyykufn/XC4ip2S/T+nSU9Oi0mJz6C4cpk=;
        b=n7Hx4ilMreFJuh5mWrvOTNbnJtm+6Of975JoCJ7FiKay+1dnyiFXGlTRr49yJkRkpo
         fnGtYCPgDJTrzJvvQQbeD9VbRKz6DmYU5k0Iz3iL1ea421O7FF8B76kshiQ4y1iW6hRe
         hqgmQE/hufvhqp1q4bh/6BL3qunXhD/XMnA6AHARq1KmHyyh5LDgE2E+k8ngSqqwUgAM
         VGE6Myp7OXIl2al/158d7oPLvO7FHs+Ly/ebjuIxYj1xwgP4wRlH8EGePTcRvk5s8Ue+
         t8s/MhkgYuLx4Tx4O7EMazdGr0yWWe79brlmMih9fMKc2ufCxaU9/G9qlgeeHV4GP2g4
         71aw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FQqTRrXg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m28sor1064464lfp.37.2019.06.07.13.17.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Jun 2019 13:17:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=FQqTRrXg;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=eB+zLVLfAFyykufn/XC4ip2S/T+nSU9Oi0mJz6C4cpk=;
        b=FQqTRrXgGS2jrJ8I3nnXEyz2J4J11YDw6Eag8y7l5BvDnfSjpG1M4GmyfNT5sGdpoD
         sgC36jHnS3Kftnrz495NnejxTN2ls148Epcko/zcjwy9K1EHa50DWUuX2a1xSerz/iIl
         yoZ/8N/+HT/+IKU8ghKoUJzRCokbG13Qv/KxiGrekQF766ps+91rNWtpBKwmIFV0IMyk
         8gi1d9GmB1AiVLMDIqq1LjL9Hzy9OSXEGX9NUcrDInpXqQjQSvmk/j3CJmb5J2/sHXBo
         XGWKnQVPZN6czIVgNxg2kjczorGxN3bjRSv1zS8Ys+3+f/LCxNuRn8jrIoTnvnw58pjZ
         dtFA==
X-Google-Smtp-Source: APXvYqwNbS5okzmn/wvJQhaWtqRFW+VpDLbfpOAnq+OdiQj/sI6qsKbd8tQnL6UsJJdy6cQHjAVmjxfhz9/5+/oHQpA=
X-Received: by 2002:ac2:5212:: with SMTP id a18mr20962797lfl.50.1559938648148;
 Fri, 07 Jun 2019 13:17:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190523153436.19102-1-jgg@ziepe.ca> <20190523153436.19102-12-jgg@ziepe.ca>
In-Reply-To: <20190523153436.19102-12-jgg@ziepe.ca>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 8 Jun 2019 01:52:32 +0530
Message-ID: <CAFqt6zado2ZFTuXbbp4WZDqJ5cXe1LJGb+rAa4SvsF23jY4aWQ@mail.gmail.com>
Subject: Re: [RFC PATCH 11/11] mm/hmm: Do not use list*_rcu() for hmm->ranges
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: linux-rdma@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, 
	Jerome Glisse <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 9:05 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> From: Jason Gunthorpe <jgg@mellanox.com>
>
> This list is always read and written while holding hmm->lock so there is
> no need for the confusing _rcu annotations.
>
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>

Acked-by: Souptick Joarder <jrdr.linux@gmail.com>

> ---
>  mm/hmm.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 02752d3ef2ed92..b4aafa90a109a5 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -912,7 +912,7 @@ int hmm_range_register(struct hmm_range *range,
>         /* Initialize range to track CPU page table update */
>         mutex_lock(&range->hmm->lock);
>
> -       list_add_rcu(&range->list, &range->hmm->ranges);
> +       list_add(&range->list, &range->hmm->ranges);
>
>         /*
>          * If there are any concurrent notifiers we have to wait for them for
> @@ -940,7 +940,7 @@ void hmm_range_unregister(struct hmm_range *range)
>                 return;
>
>         mutex_lock(&range->hmm->lock);
> -       list_del_rcu(&range->list);
> +       list_del(&range->list);
>         mutex_unlock(&range->hmm->lock);
>
>         /* Drop reference taken by hmm_range_register() */
> --
> 2.21.0
>

