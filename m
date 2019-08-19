Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A99AC3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:07:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D6C0E214DA
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:07:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H5vnuhw5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D6C0E214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6FAE86B0005; Mon, 19 Aug 2019 15:07:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6812D6B0006; Mon, 19 Aug 2019 15:07:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 549686B0007; Mon, 19 Aug 2019 15:07:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0225.hostedemail.com [216.40.44.225])
	by kanga.kvack.org (Postfix) with ESMTP id 2DE696B0005
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:07:00 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D2138180AD7C1
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:06:59 +0000 (UTC)
X-FDA: 75840109758.25.lift64_5a1e2efc90210
X-HE-Tag: lift64_5a1e2efc90210
X-Filterd-Recvd-Size: 5411
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:06:59 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id 129so1718912pfa.4
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:06:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=XKxoNzwl2f7tdJUzSZBy+zHR43qV/Sy81NVyGH0mZAY=;
        b=H5vnuhw53+NFqjevMuItdNGkvMQO3oybGlnseLaTzRUYFaQqAmlEiFwe3cgkLC155a
         ffXc8jnVqNbeU7F0wO+ZFXomSROUm9d2loD/1r7jpAcGJ7uCJxSj01gt9hsheZreh/Dt
         F7fRPSfIJwfXpH+llgxQpv/PVq/xko9VYTeXdw8Js2Ll5eA1OqoCnXxwwpgNkv+ZSCdL
         dv7tYLjQ/DZXlWPEsE8lnaC3OyaGGwkoxyhyYWehk98rgkUJJwv7gE8gBT6stez3kqrz
         1LKBaF+MZk4hoMH+BctaBbtPU1pPwOe0og8f29wb68PGbdNgorYdgEumGMPrFGr2hY10
         yXEw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=XKxoNzwl2f7tdJUzSZBy+zHR43qV/Sy81NVyGH0mZAY=;
        b=aagzQoJcFiKO4m4s96HbAj7GIlHv5G9bCX9r+I+0keYSRPSRzOJ3J1bcAS5P1KGyH/
         y4P2Pdwz5zM3ZYE46J723YUx3X2NysP7ahyZpT1i4aPwqj2iW75oRebW0MMUzjQIh4m1
         Mpi6sfcpq0EbG0XxHLA6BWBdh2agrWOnUSbZgJ04wOxoTmOBm1JeOSu8vAo6+HnZ0j9L
         eAchlyLy6DPXzxPwjLONLLjpBdDGuDiTRmRqtlMqUkS4NPgF4sCqQCnzQcKW+EKYOPY6
         9GAHyCKYw6V6xRbyug1EmAu0U6CZRwnyou2s7ldsU7ry+xuvXqAlgscZP8SaJYwSeEZc
         1hFg==
X-Gm-Message-State: APjAAAVbzjjbJnYU4X5oQNaQc3N5hPbI+bppFB8dpYoz3pA0I6tnpR6M
	3Oh8AJJB88Q/9OAwYF2+a4M=
X-Google-Smtp-Source: APXvYqznze8pzlJmKpgW/Tcy7NikGDCleK4bKxe5cEVOB63r5vKAXucpjQhiJk1v0YBDhTmB1jbcBQ==
X-Received: by 2002:a63:4612:: with SMTP id t18mr21505996pga.85.1566241617995;
        Mon, 19 Aug 2019 12:06:57 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id k3sm28690589pfg.23.2019.08.19.12.06.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Aug 2019 12:06:57 -0700 (PDT)
Date: Tue, 20 Aug 2019 00:36:47 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Dimitri Sivanich <sivanich@hpe.com>
Cc: jhubbard@nvidia.com, jglisse@redhat.com, ira.weiny@intel.com,
	gregkh@linuxfoundation.org, arnd@arndb.de,
	william.kucharski@oracle.com, hch@lst.de,
	inux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [Linux-kernel-mentees][PATCH v6 1/2] sgi-gru: Convert put_page()
 to put_user_page*()
Message-ID: <20190819190647.GA6261@bharath12345-Inspiron-5559>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-2-git-send-email-linux.bhar@gmail.com>
 <20190819125611.GA5808@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190819125611.GA5808@hpe.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 07:56:11AM -0500, Dimitri Sivanich wrote:
> Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>
Thanks!

John, would you like to take this patch into your miscellaneous
conversions patch set?

Thank you
Bharath
> On Mon, Aug 19, 2019 at 01:08:54AM +0530, Bharath Vedartham wrote:
> > For pages that were retained via get_user_pages*(), release those pag=
es
> > via the new put_user_page*() routines, instead of via put_page() or
> > release_pages().
> >=20
> > This is part a tree-wide conversion, as described in commit fc1d8e7cc=
a2d
> > ("mm: introduce put_user_page*(), placeholder versions").
> >=20
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Dimitri Sivanich <sivanich@sgi.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: William Kucharski <william.kucharski@oracle.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel-mentees@lists.linuxfoundation.org
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> >  drivers/misc/sgi-gru/grufault.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >=20
> > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/g=
rufault.c
> > index 4b713a8..61b3447 100644
> > --- a/drivers/misc/sgi-gru/grufault.c
> > +++ b/drivers/misc/sgi-gru/grufault.c
> > @@ -188,7 +188,7 @@ static int non_atomic_pte_lookup(struct vm_area_s=
truct *vma,
> >  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=
=3D 0)
> >  		return -EFAULT;
> >  	*paddr =3D page_to_phys(page);
> > -	put_page(page);
> > +	put_user_page(page);
> >  	return 0;
> >  }
> > =20
> > --=20
> > 2.7.4
> >=20

