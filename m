Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C271C31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:09:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E18E320861
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:09:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="1CPoHsv8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E18E320861
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F47F6B0003; Mon, 17 Jun 2019 17:09:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A4FB8E0002; Mon, 17 Jun 2019 17:09:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6936D8E0001; Mon, 17 Jun 2019 17:09:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8A16B0003
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:09:37 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so2328490otf.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:09:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=WJY8mRWNKYbMrxiqtcC6On1cSl2WUj/ZIwS4ootoQak=;
        b=Us1wkUsz1Z4ZyxLqcoNqRf23Ys05t6PawU3obO607KxS5TGIJ+zKvARA4sy2IN3BMa
         kAXLBNtxJhNFzRiPTP2F2V5Jmff+zjx3FjfJBHGcb37vn8Zh/QFaTbsqvlCtA1KiPjEa
         Y5ODXZmJIH2rkGANawp3TBf4AuxdEqRZIUrd5ljCGeL9Jn60HZN1HeqSLoPdg8/mkojG
         1WP5ZQNtgGuZB/neuM9plxU4+/Y/dkg1QMSib6DyyoU31VfJZP4BrDlIf3vFNwYpU9dU
         2LfzgqS52nKqH+vGwrQPMyT6Afv3qsrurfL1quDLjIY+vLdk71w7OP6yP+Xjo1cn+OzY
         AvUQ==
X-Gm-Message-State: APjAAAWYTDb22FZGyb8lRN1jh6BzOliwR2qxKP5XbS2GMasyf6Qy5xQV
	tdLiPW+eRhpN5vQIXKddL8CDMdwi+FPBJB2gwILrSr/AyA1jKhWylEmPdR2oQOUGfWRsKEU+Nm+
	TO+3AtyL6xG16Xu8575z9rhmAeJ0ln214h9w6Js0yC6ozio5jw/+D9acdUXPBJRreUg==
X-Received: by 2002:a9d:6194:: with SMTP id g20mr972240otk.149.1560805776897;
        Mon, 17 Jun 2019 14:09:36 -0700 (PDT)
X-Received: by 2002:a9d:6194:: with SMTP id g20mr972194otk.149.1560805776273;
        Mon, 17 Jun 2019 14:09:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560805776; cv=none;
        d=google.com; s=arc-20160816;
        b=mD1Nua3Gl9kC4G2KjCZeetwZMU7DMWyTYwR+5PJ3gHw3XGs2yBk7EJpzh+vYKjeujq
         ZxiNyQLrXmQEChEoxVGV5uHqtUb1y6x74cOgaQxCUClTrWn+AVmgIHb4G9rLKC8LDzXf
         0x+xTK1CdUkgcp1rSc0J9k/fz/p1OtBd8ob8vVJ+J726bIMZ9I0GL08wKDqzK4ilyb0I
         JGjrT6A6DFene/JWIOqvdj7lfyt8cYEpOvYhTm9M0F2Jx6g0p42IsVSEYZqPvbvX1cVD
         0TJ1lf64QcL16kaR8QIkPYHtbIiSCXWCsYpjQBFifhb6EAXkMxTwpUJCvwXP8zmTIkAX
         y+BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=WJY8mRWNKYbMrxiqtcC6On1cSl2WUj/ZIwS4ootoQak=;
        b=Z4lK+i7r7mluBiO8guFSp2WDEOFoP7Nz4ErtXxzuGqpV7sTI/coqBNvxCEzf+VI5RG
         l26j6XgiS/AZ2JUI1T3Hi4m1SrA7s/rRmIPRQbiSGtQIXvKYQmu4CDuAFzlacUTvhRNE
         Ulv/N6jP9DEKDVVXnO9E02S7ykUcIJom1DOaujnWGJB1mXeXu6DbJX/HJUxtnAvWm7KT
         6JmEy445SnfMm4cP1w57VTsY0bJ1qUMnz/AGwIjPh+NIRQpZkOzpNTJGIvQHM6RVle76
         ClXMOeJWvRdF+xCf6KesseoHClAC5AG1iC9bcHy4a8LipUBFuR/IZQyRHGXMkcGZiNPe
         PfKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1CPoHsv8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c15sor6229445otr.178.2019.06.17.14.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 14:09:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=1CPoHsv8;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=WJY8mRWNKYbMrxiqtcC6On1cSl2WUj/ZIwS4ootoQak=;
        b=1CPoHsv8eJYyjii0r2v+tpwEGCkSWwSYtZacx/AqtzGMRs3fZPgZrV7RbEeA45KDwP
         lsJvq7QgmiqEwVzp5wdQHibzWroOdc9btguH5MJ/BTdcEtQKRrkY2A644oJ5v1entk28
         jQX1i10dz7Bzaag9WMXeIi4g9aL/drgYMGhz0EwOOdHkXNcNmVY9Lux9aw2TbX6HsoFA
         rgd+c/SR//qS9xH7huYep7vdqcSElSiqUL7CnczUCly0wMqqGAQdyboSJvis9joomSOv
         KyK08LiIatM0igaxt5Yo3ksIlA7sTKvevIo1tgB6DFbvKhgZgBfO8B1hLUl5bdDehAB/
         2KGw==
X-Google-Smtp-Source: APXvYqyAU1TcMvPiGYVYhBbyC0eVXwwhkAqKTWqXoLyuFCBz8f0kthsk9jFJXToSNfs33gSFBQCmV/94ID8R2le9oJQ=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr55835238otn.247.1560805775819;
 Mon, 17 Jun 2019 14:09:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-9-hch@lst.de>
 <CAPcyv4i_0wUJHDqY91R=x5M2o_De+_QKZxPyob5=E9CCv8rM7A@mail.gmail.com> <20190617195526.GB20275@lst.de>
In-Reply-To: <20190617195526.GB20275@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 17 Jun 2019 14:09:24 -0700
Message-ID: <CAPcyv4iYP-7QtO7hDkAeaxJsfUCrCTBSJi3bK6e5v-VVAKQz-w@mail.gmail.com>
Subject: Re: [PATCH 08/25] memremap: move dev_pagemap callbacks into a
 separate structure
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Logan Gunthorpe <logang@deltatee.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 12:59 PM Christoph Hellwig <hch@lst.de> wrote:
>
> On Mon, Jun 17, 2019 at 10:51:35AM -0700, Dan Williams wrote:
> > > -       struct dev_pagemap *pgmap =3D _pgmap;
> >
> > Whoops, needed to keep this line to avoid:
> >
> > tools/testing/nvdimm/test/iomap.c:109:11: error: =E2=80=98pgmap=E2=80=
=99 undeclared
> > (first use in this function); did you mean =E2=80=98_pgmap=E2=80=99?
>
> So I really shouldn't be tripping over this anymore, but can we somehow
> this mess?
>
>  - at least add it to the normal build system and kconfig deps instead
>    of stashing it away so that things like buildbot can build it?
>  - at least allow building it (under COMPILE_TEST) if needed even when
>    pmem.ko and friends are built in the kernel?

Done: https://patchwork.kernel.org/patch/11000477/

