Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9ACA3C04A6B
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 03:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C0A420818
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 03:58:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="A2pj2SEK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C0A420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 926186B0003; Mon, 13 May 2019 23:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7016B0005; Mon, 13 May 2019 23:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79FF46B0007; Mon, 13 May 2019 23:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 533056B0003
	for <linux-mm@kvack.org>; Mon, 13 May 2019 23:58:52 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id n21so8509889otq.16
        for <linux-mm@kvack.org>; Mon, 13 May 2019 20:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=cdKct2xWm3ro0UBx8IVBS27dWaO8IEoUZaes/VXIAl4=;
        b=bWbo0ceRh1Bd8lFt4LvEMOCmqfYp6W4Ow/3JIKXyQTxPCT+BtSykYkFjUyHjtEbD2v
         UyOX5c66GgRE4CxpiJkt1R0ENa+M3xlXggdi1yaB9re/kLTnMd7k3TJliZ8BBYwEOIMq
         Yfm2dX7gdK/mwFH9ijSrBt/pWmAQ53X7j8f/c9L2WXCm1iLo6HUm8CFb7Ezy85P+X/J9
         e+Z6bzj/+/Do4qf/9GzD/fVRBv1FDk61pZd6MCvTS4q7uW6FMdIlk3ZF9tNt8kD92DrH
         uhbtGLDWt8djOLQj5eUlEe7BoNWvY7ljECyvhysg6BVsYHAa+bGBZuNMQNZLowYS8gsB
         LkRg==
X-Gm-Message-State: APjAAAV/TytCYp9Ol8AW0r52z1VthQehvJdECaL+vun7oRXNaZLLWHja
	0kp13injdKC3j5+c1n4FXON27YMa5UixfYFoWq7qmrFk2TNXrligTrNqg3v5XUK4wlx4LZSt3O7
	Y730qm5hurIHvj1SsiQGJHXClVFc5eX4QExBhxG2EcwLJdxUGwIJpQBLMS3mZA4HPLg==
X-Received: by 2002:a9d:469e:: with SMTP id z30mr18272724ote.311.1557806331928;
        Mon, 13 May 2019 20:58:51 -0700 (PDT)
X-Received: by 2002:a9d:469e:: with SMTP id z30mr18272704ote.311.1557806331077;
        Mon, 13 May 2019 20:58:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557806331; cv=none;
        d=google.com; s=arc-20160816;
        b=nL8kvTZIiSipB9Hw58aloQHe8nARSW70tJ+ZPv5PqGsghxdtt3oPLxKJifpCqTGbJ7
         ehia9xQqOfEWHqSGR5ZuvUcl2IA4yugbuFBbmGy2Rf6o61Ex2BMYdfVTfTckko4UtnU1
         IuLSr7wQF6fHG/r2a4z6LbEoStP33TifYnlrMuS0c9bqNoiy9weoGQ6vffnM4RLzHKyV
         uFvc0VbXzbH+Unuo3bCVUMo2Yl3PlNWxNNO/XFkqR3HiGWga8M9GKQ2fSiX90TWI3Byr
         XmRd7yV6UY8w2X/TIdW3QFnWL/uRVlwyZM4kWz0JF1N2GnsA/7wU90bnY8nj1MzbvpD7
         aorA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=cdKct2xWm3ro0UBx8IVBS27dWaO8IEoUZaes/VXIAl4=;
        b=x5oiCWMosZwPkClRdOD5hOdEveHYnnHJvlsiVSBbv+rUp3h0WaK9d2mK7ULiXm+TlA
         gKH03fBsRSSvK6ZwG2QGMlwBkDwVdzBCDLbBxMeqdVbsIuzUAljt4V4wi0ieMeKMDUW4
         ml+jqMq383BTa5Q/gcFzeqbp7E0fQFSMtU7dzFNFeKS1d7RHSL1Vy8053noxSTCYAlnn
         BDvQ2v8Mt6MyqXSHk9SBeY9QtWOzkvuTQErt8mpQ5jWVHE8LBSpaPbr44xeCUKZMQSxM
         h8WzWFc0o5Rp6DEaQCuXNWc8YpE1FjeHuqoiJqMs5Llxie42DgdO1oY/aSqi/8VbXaj3
         LBuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=A2pj2SEK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w130sor6687431oif.139.2019.05.13.20.58.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 20:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=A2pj2SEK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=cdKct2xWm3ro0UBx8IVBS27dWaO8IEoUZaes/VXIAl4=;
        b=A2pj2SEKTSfipz0FKt48998bkaQjibSO0LrmPxJdhCviFLeLqezE2NwsTX4vLH0VNN
         7xPjJIoF74QtRsYvEoXUHinuYdzzF5t1YPQzLcoSf1zZyfajYgYJytcipJK5FUl4Mlny
         oviyWw8fv6yYkIB25nhyDFRvcpnhzsjlwirqdt/oOQWZcHncrbGzYhiTtAjHM/VwdoEx
         Z465FZGgCDqTJ0zF4ouRHd18tdhCEBUne41N5akjLyQ8er4GGX4sekH7adfb/pd/UYoX
         0JlPQOYpuryFUc7/W+CvrWhxds7OkTfp/G5tbIeQgp+qUrgpiMmQ0vY4MNA4R4UcIx9f
         VCwg==
X-Google-Smtp-Source: APXvYqyCSekgO8kXJLyc6cL4sAJ4FYAjlvDT7H8G1xatSOxF0udFUauTtFneyF1PCwUl001x8VvXU+z2TeI3qINqNDY=
X-Received: by 2002:aca:ab07:: with SMTP id u7mr1650949oie.73.1557806330382;
 Mon, 13 May 2019 20:58:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 13 May 2019 20:58:38 -0700
Message-ID: <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> The nfpn related change is needed to fix the kernel message
>
> "number of pfns truncated from 2617344 to 163584"
>
> The change makes sure the nfpns stored in the superblock is right value.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
>  drivers/nvdimm/pfn_devs.c    | 6 +++---
>  drivers/nvdimm/region_devs.c | 8 ++++----
>  2 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
> index 347cab166376..6751ff0296ef 100644
> --- a/drivers/nvdimm/pfn_devs.c
> +++ b/drivers/nvdimm/pfn_devs.c
> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>                  * when populating the vmemmap. This *should* be equal to
>                  * PMD_SIZE for most architectures.
>                  */
> -               offset = ALIGN(start + reserve + 64 * npfns,
> -                               max(nd_pfn->align, PMD_SIZE)) - start;
> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
> +                              max(nd_pfn->align, PMD_SIZE)) - start;

No, I think we need to record the page-size into the superblock format
otherwise this breaks in debug builds where the struct-page size is
extended.

>         } else if (nd_pfn->mode == PFN_MODE_RAM)
>                 offset = ALIGN(start + reserve, nd_pfn->align) - start;
>         else
> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>                 return -ENXIO;
>         }
>
> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;

Similar comment, if the page size is variable then the superblock
needs to explicitly account for it.

