Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55214C282E5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 21:04:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB6492175B
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 21:04:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="SVznC4KC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB6492175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B37D6B0008; Fri, 24 May 2019 17:04:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4648F6B000A; Fri, 24 May 2019 17:04:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37A106B000C; Fri, 24 May 2019 17:04:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0E6666B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 17:04:06 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id y14so4105092oia.9
        for <linux-mm@kvack.org>; Fri, 24 May 2019 14:04:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=TZLUTKJ3F2aogiV4hxpY25KLHdygnyYYVAPTh5EB7PA=;
        b=SDXC7BxF9GpV4gaIx7HHFSwDDguK3D2VFz4096nkyPSbgcj3lGcV+l7mtXjghp6Hng
         Ts7erSpeCgKdfJPjkAw3JxFSTDSdROIklT9tyjN2r8VKYwZK5JX/eNKaNXv/9+tFpR+A
         hdoDqV/13izIEtiSnSDJQnHDhnNejjGEfSg/BthMF3KkU5qxeY+fZ3N87VsCFapwqmz/
         GRShPPn22xIxi3/DBRfJaSekArKTKLqWH1dR1Hl8LJEb2aXRJjbVECPnXfbI+Ve+HkJe
         40y1RfGl5flseWy8AmlOBLOH18cGJFMGiUycpI54E5SchcWogCIPC9No6rNOzOBuWyq9
         rUeA==
X-Gm-Message-State: APjAAAVEeK2Y7/BfXs+LBVWzzi/YmPwPNjLLsOYnJtYAfpTDYaXhyiu4
	BWdbzKyG2fUofWPElO/CyasV4FRpbFLYDkqzV/BX6eCQ9uODfnyqRJolaae5RoKbsGZMn31vjk2
	krqjH4GZCl35f8m/2Zp95LN6dC8LkxDClcsiQ1qVeVDBAhYLsne3SC+B31FjyseQ3kA==
X-Received: by 2002:aca:40c1:: with SMTP id n184mr6409632oia.73.1558731845661;
        Fri, 24 May 2019 14:04:05 -0700 (PDT)
X-Received: by 2002:aca:40c1:: with SMTP id n184mr6409596oia.73.1558731844926;
        Fri, 24 May 2019 14:04:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558731844; cv=none;
        d=google.com; s=arc-20160816;
        b=gt1K4WEDC0beRkBJAZboTJvE9eEFJ/wufx/7moybnWk6DqRjHVEeoGmDXMhz4itaUi
         AY6/XZ9ibqvjkRKJarQRZRJZkclj33LTp2uf0jZEPsG8guHCJ6pUcOiOe3rIuUVIN02u
         cIYPG5mjfh7fEF9b77OAHq7XmH5zKDiFPh7eFxhvnhQJzdPfECEicbYrJK+9gjP+qgDJ
         7cpGGO6KoRHR2r9OGQBXIj6OiPC7lNo2rnztobXZ49Jl7ioSG5aAV+vq9x08c/oH3nsN
         s+f616HXbqIPnmVV8W5gDhcVmFwbTaFC7Mzp0PARtUGXKB/gQS0ewOIBIKnCruClPuro
         eAXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=TZLUTKJ3F2aogiV4hxpY25KLHdygnyYYVAPTh5EB7PA=;
        b=voj8W2pWup28Vs++lbeN+G8tQuIJ3Bh2IGuhVSTbTbHUGTBRPmsuS60OjAAzV2a4R/
         Kj+22dpfRanaj1YNq2ok5MSErg47GSq8MRILR7YaCf+ldk9t3f/9kkNZBOsIf246MLd1
         LgovQp+z/4429Vz5w7JT+4JXh8TlJf12RSxIkhal9g2LqSrzm+K+v3ARXRsdeixKXno6
         c6+zRgfl5KkeJBHQ9Q4dXlzYMPn8F1a6n+VLpnZ64rBPPH/G0EG9T2fRuxK47iL3r71f
         /AmNTEQOUkV+OUuDsynyqc0i64jn3XTud0xx4jno0rhzYYlPiRZDCTXZhZ9XttAuEGF7
         c5ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SVznC4KC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u135sor1506944oif.18.2019.05.24.14.04.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 14:04:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=SVznC4KC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=TZLUTKJ3F2aogiV4hxpY25KLHdygnyYYVAPTh5EB7PA=;
        b=SVznC4KCLx7YSAx2b6fQ+ZtJiZ6ujYdV9mSMxY84cZ56j+I/vr7lCZ/TTMGPqIrmG2
         n+MXhfhPC5SPlCZeuF2ieZOIOLtAiTxsv8dTJ3LY+T++Gx1kU0nnyQjXCoaVyIRN2139
         bNjLSLTnsM4vNLAE53uhz0BWJ5+IUfLiAbY/s+oxqkfDD+60ZakSOC4NcjsVb/AdikkC
         Ep3lJuX0jO9ltkpAJ7esLFb6M7WD0hEd9tkFPAhX3J2Jbb5HOcty+jYUuRdcBSREf+Rw
         JqYkgRMAVIy/x+dJaSnpwbW1LDzz1JAl9eng+iVqHCNf+jFOWorG+cxdGn6taPp9T4ya
         Clvg==
X-Google-Smtp-Source: APXvYqxZIFyFGsR/pXREy00mCK+6RQ0bxehaezcZvJguGqHs6hXw7JjGal55rGe16XzZYEOCHBpbDovT+9fdeN+vXHk=
X-Received: by 2002:aca:b641:: with SMTP id g62mr7861089oif.149.1558731844633;
 Fri, 24 May 2019 14:04:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190523223746.4982-1-ira.weiny@intel.com> <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
In-Reply-To: <CAPcyv4gYxyoX5U+Fg0LhwqDkMRb-NRvPShOh+nXp-r_HTwhbyA@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 24 May 2019 14:03:52 -0700
Message-ID: <CAPcyv4i7+AVR9_U+g8npO_ixJFz=5kEUJ9RaiD2aKBmBOo-PJA@mail.gmail.com>
Subject: Re: [PATCH] mm/swap: Fix release_pages() when releasing devmap pages
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 8:58 PM Dan Williams <dan.j.williams@intel.com> wro=
te:
>
> On Thu, May 23, 2019 at 3:37 PM <ira.weiny@intel.com> wrote:
> >
> > From: Ira Weiny <ira.weiny@intel.com>
> >
> > Device pages can be more than type MEMORY_DEVICE_PUBLIC.
> >
> > Handle all device pages within release_pages()
> >
> > This was found via code inspection while determining if release_pages()
> > and the new put_user_pages() could be interchangeable.
> >
> > Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  mm/swap.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 3a75722e68a9..d1e8122568d0 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -739,15 +739,14 @@ void release_pages(struct page **pages, int nr)
> >                 if (is_huge_zero_page(page))
> >                         continue;
> >
> > -               /* Device public page can not be huge page */
> > -               if (is_device_public_page(page)) {
> > +               if (is_zone_device_page(page)) {
> >                         if (locked_pgdat) {
> >                                 spin_unlock_irqrestore(&locked_pgdat->l=
ru_lock,
> >                                                        flags);
> >                                 locked_pgdat =3D NULL;
> >                         }
> > -                       put_devmap_managed_page(page);
> > -                       continue;
> > +                       if (put_devmap_managed_page(page))
>
> This "shouldn't" fail, and if it does the code that follows might get
> confused by a ZONE_DEVICE page. If anything I would make this a
> WARN_ON_ONCE(!put_devmap_managed_page(page)), but always continue
> unconditionally.

As discussed offline, I'm wrong here. It needs to fall through to
put_page_testzero() for the device-dax case, but perhaps a comment for
the next time I forget that subtlety.

