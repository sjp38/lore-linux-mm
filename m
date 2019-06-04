Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76476C46470
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:11:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31750207E0
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 20:11:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ksnPKDAH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31750207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDA806B0271; Tue,  4 Jun 2019 16:11:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B8B1D6B0273; Tue,  4 Jun 2019 16:11:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A56456B0274; Tue,  4 Jun 2019 16:11:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBCB6B0271
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 16:11:52 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b124so786877oii.11
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 13:11:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=F10q0KVTHECot/kJH3bpXBBhMISLUSKtyxb6F/sOWco=;
        b=Z2JnL7jB6CcRdpfagfeRULU6hZYHz9KQ+HFAtQLFakkBOjyc/12kgKQMzYYIDtQ9XR
         nEYojLjzuJTvF+kdF66wG90Ym109zKerMGgu6nZcHendksChyncEVFA4VOcKSCzrq7Xz
         dMc6D2DBVG3vpRlSuvaSdBVVM2221DHg6y2FUWoSEVd3x5JFkv2TtVTizWLcISTtT4mF
         LMGRDIxhuWeB5TgPLJAq4+aD7bWqEw/TF/27VhMn1Rqd6DxAOLqUNrAZwrsjhpfZckWS
         1aaZo2Gsb+FdcxrHlwEHI6KyBtafydLcSQ5G9xjJ9WyxmITfaU+t2CY+2zumzIJrv7Q9
         Yqqw==
X-Gm-Message-State: APjAAAUuqxgGamrcbyqMkCqT9y+IRSB23dZv7tb1cShcos97Nn+1VWsX
	Oxb0x4YLEYS/ZteOmKZLpNQz3fSEU1rtBHZAuU8AHLUDmJ+s87/S0Wov38TZMhwQ/Ik/AfVBZvs
	4m8AmoSgVFoWUTDcZdxZoBFc/DiLoNewj0Af4s8qpY8IpI1nJa7OgYVF8HNv0EnDk0g==
X-Received: by 2002:aca:3fc6:: with SMTP id m189mr3417560oia.124.1559679112030;
        Tue, 04 Jun 2019 13:11:52 -0700 (PDT)
X-Received: by 2002:aca:3fc6:: with SMTP id m189mr3417524oia.124.1559679111186;
        Tue, 04 Jun 2019 13:11:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559679111; cv=none;
        d=google.com; s=arc-20160816;
        b=hD8zELO8+4JcNfBHVB1fXfSQG6olkLheQG4xC+qW6ENuYp/Q4V56Cy2zynAagGn3dv
         EyAA4bcp1wlo/hCq6uUBDz5wvPzbsOUKJ14ENp4kMXNGI8UPvuaJ2QBvHL9M4fAu3HW8
         Go1xJm+R6PCDTf4EDzLSPbgKLH5BLZ8L9lGVSPsZ+TGKykLnCyCyVODMIY1OHnw6Idsl
         3Jv2JVBbmMLZPI8uEENDgIdDwdaBvURBNc27W/HD4UjuZ3qKcjdwUNmKuCLpsLcJZC3S
         95VgyOYSGJXRiGukX1cj6TsCzXMkHowP8IexCU1ZYAS41On9jXB4cROf9/H/dcTXb2P+
         0p8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=F10q0KVTHECot/kJH3bpXBBhMISLUSKtyxb6F/sOWco=;
        b=Z3SudGh5ZakXonfcRaOGS6yIOahSBxK1pXbuH5jEUF6V1XJZWB4lV5pPrRV5UCP19N
         MFtgYLyfTBR15gxOEPj2AvQQaEltE0kb0zj3xDfnX80+LyMhfxQZkrVk7zjaWsxzVp6F
         7igMgEzDFkx+jyrLnQx1zMvEygUiXD0PuU/cOyjZa3pgxpiHNWQ6Xm7eGX0qCTVPhffo
         XLVnbEo+vL8k3gsdRn8lfd/G11FzLNVCLfBW/wStlRttWmokf3H93jL9SYUCVXVMHQJo
         pvvjgyB7SvGuDbmNPlx+7WfmghLUz99fbKn50pFvBd3D1xlPCisBdtRQOpiSGCSACbYr
         s1jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ksnPKDAH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n13sor2781941otf.39.2019.06.04.13.11.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 13:11:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ksnPKDAH;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=F10q0KVTHECot/kJH3bpXBBhMISLUSKtyxb6F/sOWco=;
        b=ksnPKDAH2vpajVlt3FdQ1o79daRSPs4sDyRSGkAnPXDC4guUemOThTNV7g2HkHBxbD
         KXNuYnnQJVPBBlgZeN1qsUEcxDgjW2ufLJB5ApQuUqmY9t5pyOduHXi0i+fyeBUthTPn
         ZHv7ab9rPNIR8AjTnkjHC8Gn4cIxKM8v9syi3dzP+3dc4idH/Xf2WS7hxQ3ULABRAbk8
         p38g/F1LB2o75+qTMh1KrUZSdiZmOydTYQK7Raku7yVUkx6zhYiCplV+oX4oTz5NbSjp
         icXuRtOvbP+XqkZOAYVXIwWyk4CyASDUFH+oB5inG7C5S+4ESpn43x/vw/XWSgOgg7Eh
         uLxw==
X-Google-Smtp-Source: APXvYqyTa8Gbb8IOD8Dh6HgENFAnEfuHPskg2EEGvtw42nEap43nVkmpzXcyUap1w5NLnmmqleclS53nXaf3ZvnOp0U=
X-Received: by 2002:a9d:6e96:: with SMTP id a22mr6416236otr.207.1559679110583;
 Tue, 04 Jun 2019 13:11:50 -0700 (PDT)
MIME-Version: 1.0
References: <20190604164813.31514-1-ira.weiny@intel.com> <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
In-Reply-To: <cfd74a0f-71b5-1ece-80af-7f415321d5c1@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 4 Jun 2019 13:11:38 -0700
Message-ID: <CAPcyv4hmN7M3Y1HzVGSi9JuYKUUmvBRgxmkdYdi_6+H+eZAyHA@mail.gmail.com>
Subject: Re: [PATCH v3] mm/swap: Fix release_pages() when releasing devmap pages
To: John Hubbard <jhubbard@nvidia.com>
Cc: "Weiny, Ira" <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 4, 2019 at 12:48 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 6/4/19 9:48 AM, ira.weiny@intel.com wrote:
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > release_pages() is an optimized version of a loop around put_page().
> > Unfortunately for devmap pages the logic is not entirely correct in
> > release_pages().  This is because device pages can be more than type
> > MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS
> > DAX, and PCI P2PDMA.  Some of these have specific needs to "put" the
> > page while others do not.
> >
> > This logic to handle any special needs is contained in
> > put_devmap_managed_page().  Therefore all devmap pages should be
> > processed by this function where we can contain the correct logic for a
> > page put.
> >
> > Handle all device type pages within release_pages() by calling
> > put_devmap_managed_page() on all devmap pages.  If
> > put_devmap_managed_page() returns true the page has been put and we
> > continue with the next page.  A false return of
> > put_devmap_managed_page() means the page did not require special
> > processing and should fall to "normal" processing.
> >
> > This was found via code inspection while determining if release_pages()
> > and the new put_user_pages() could be interchangeable.[1]
> >
> > [1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc=
.intel.com/
> >
> > Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> >
> > ---
> > Changes from V2:
> >       Update changelog for more clarity as requested by Michal
> >       Update comment WRT "failing" of put_devmap_managed_page()
> >
> > Changes from V1:
> >       Add comment clarifying that put_devmap_managed_page() can still
> >       fail.
> >       Add Reviewed-by tags.
> >
> >  mm/swap.c | 13 +++++++++----
> >  1 file changed, 9 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 7ede3eddc12a..6d153ce4cb8c 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -740,15 +740,20 @@ void release_pages(struct page **pages, int nr)
> >               if (is_huge_zero_page(page))
> >                       continue;
> >
> > -             /* Device public page can not be huge page */
> > -             if (is_device_public_page(page)) {
> > +             if (is_zone_device_page(page)) {
> >                       if (locked_pgdat) {
> >                               spin_unlock_irqrestore(&locked_pgdat->lru=
_lock,
> >                                                      flags);
> >                               locked_pgdat =3D NULL;
> >                       }
> > -                     put_devmap_managed_page(page);
> > -                     continue;
> > +                     /*
> > +                      * Not all zone-device-pages require special
> > +                      * processing.  Those pages return 'false' from
> > +                      * put_devmap_managed_page() expecting a call to
> > +                      * put_page_testzero()
> > +                      */
>
> Just a documentation tweak: how about:
>
>                         /*
>                          * ZONE_DEVICE pages that return 'false' from
>                          * put_devmap_managed_page() do not require speci=
al
>                          * processing, and instead, expect a call to
>                          * put_page_testzero().
>                          */

Looks better to me, but maybe just go ahead and list those
expectations explicitly. Something like:

                        /*
                         * put_devmap_managed_page() only handles
                         * ZONE_DEVICE (struct dev_pagemap managed)
                         * pages when the hosting dev_pagemap has the
                         * ->free() or ->fault() callback handlers
                         *  implemented as indicated by
                         *  dev_pagemap.type. Otherwise the expectation
                         *  is to fall back to a plain decrement /
                         *  put_page_testzero().
                         */

