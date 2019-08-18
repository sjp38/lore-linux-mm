Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAAFFC3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:51:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82EF22187F
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:51:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SnKaNuRn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82EF22187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E8586B0266; Sun, 18 Aug 2019 15:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172026B0269; Sun, 18 Aug 2019 15:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0117F6B026A; Sun, 18 Aug 2019 15:51:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0055.hostedemail.com [216.40.44.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD8E06B0266
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 15:51:24 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 7DDFA4FF4
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:51:24 +0000 (UTC)
X-FDA: 75836592888.09.gate35_80a475b72543d
X-HE-Tag: gate35_80a475b72543d
X-Filterd-Recvd-Size: 5037
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com [209.85.210.195])
	by imf05.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:51:23 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id g2so5874637pfq.0
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 12:51:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=OOdaQ3Y1UMODtL7IlKujR0VdVVo4BsF1PHOf0vyDCEk=;
        b=SnKaNuRnHt/L6jr+prABwlBFB7rPkwIoFUeGfETvUKgl56MYOBao69wU8gKBM4Zd4H
         kNNVYrtljpMzuoHgZogsfIEU3l0//1Tkz/XFHrRmeXcnNeYjvdeZM4vMNGklqFweHxVs
         s9fLLEfZmtJq81sYYwx9LO66pEWILb6O2KNaqJsCQsYUS2vGqKYvCWwkc/xyC4MEqXTa
         hCnsKmJRph4IpNqO4sbTYpkzTyzM0Pfv55ROJTTRvdrvypDapE+8bPEHi84Ai3v1L2TW
         LQUm6QeAxElBg7mFG0D753dO1qTj8UWdubCjVQmiIAHpIvV68xvNgIkMIUzBnNLuRKad
         jNTQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=OOdaQ3Y1UMODtL7IlKujR0VdVVo4BsF1PHOf0vyDCEk=;
        b=YgoRfNm6KA57RcYgB1pRuwVEaVgLq3KVhA7UvQR/74oG5OFQInfxQW1H55zYia0soA
         h4anAh/Q4gykXuK85UUGJobOyf2qoJ9LmRhbLtzCROxcPyUt/oflsgJGr/z6J9rJ8Ql7
         lL88cM6nXTKzsBffEbwQ9U6GSniXsbgkdPS1NAtGPnHpK8bs0x/GZuV8PA+JzNiB0Dfy
         IRjIRgndrf6jjY5JrzhOakKBgGa/D+Kqmcr83LuLOOzsZTzxcwKk08R/7nvZz/SC7jI3
         hBDrwmQZVXnqELu1SgFfkVC0jo4pbNK6v/BiH88+Rk/0UQ3REaIzHXg/EHRaMnhAtfqh
         SthA==
X-Gm-Message-State: APjAAAWweD+dviNqx6ixmTeeoa12POxdXbdjfI9n9jIC6Q8rzUq0/aou
	H4+a7q8mvAbQ6BU6ddRLHqE=
X-Google-Smtp-Source: APXvYqywsXHVLnsMztcWvA7KqJ8DMmhUpplqYZivz2ti2P2zqYn45dlCq2YJCfnJZLcDP4zxXsZSRw==
X-Received: by 2002:aa7:8202:: with SMTP id k2mr21313582pfi.31.1566157883100;
        Sun, 18 Aug 2019 12:51:23 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id y14sm23518034pfq.85.2019.08.18.12.51.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Aug 2019 12:51:22 -0700 (PDT)
Date: Mon, 19 Aug 2019 01:21:15 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com, jhubbard@nvidia.com
Cc: jglisse@redhat.com, ira.weiny@intel.com, gregkh@linuxfoundation.org,
	arnd@arndb.de, william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page()
 to put_user_page*()
Message-ID: <20190818195115.GB4487@bharath12345-Inspiron-5559>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CC'ing lkml.

On Mon, Aug 19, 2019 at 01:08:54AM +0530, Bharath Vedartham wrote:
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
>=20
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2=
d
> ("mm: introduce put_user_page*(), placeholder versions").
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: William Kucharski <william.kucharski@oracle.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel-mentees@lists.linuxfoundation.org
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/gru=
fault.c
> index 4b713a8..61b3447 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_str=
uct *vma,
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D=
 0)
>  		return -EFAULT;
>  	*paddr =3D page_to_phys(page);
> -	put_page(page);
> +	put_user_page(page);
>  	return 0;
>  }
> =20
> --=20
> 2.7.4
>=20

