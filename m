Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C07EDC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:01:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 855FE218BB
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 16:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FEqk4Ayq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 855FE218BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB0B18E000E; Wed, 26 Jun 2019 12:01:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5F988E0002; Wed, 26 Jun 2019 12:01:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D504F8E000E; Wed, 26 Jun 2019 12:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF6E88E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 12:01:00 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id t198so1229085oih.20
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 09:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=r/963AMc32TjFW8pz2sb81LGtvemWumKWmOSWi/w+uo=;
        b=Fy4ALvAWTQAvQ3SeaSR6Cg+9x0ecZCqUpTvkpOoD8EyVEQ+emRIYsWjRCxs+ikVz0v
         XhHkdc0VxDdvwICdIJNi4fLXdJ0auMeIj7xOi8d0bluxB9MNnX0VNDdUhHf/MFuZr/rO
         9VYjlrX9vObOMz2Aw7ymF0zADx5rK0IdP3I3pX7u2HuAR2rOWnKMiNcT5r17V8Tb4Fwn
         xkbGDmWoQ8x3ZnAJE3cVvhp8nSB8ywlyzRuuTslW0VJvOq9/IG4ro8NPf5S6DH83VXQn
         tpUBOmQohaMIMBo6MVxEyFp1+AQ0QYu0lS+qQJR9xmw/8eSvuO0UcMxiZu5Fc3a7Lvn1
         dyTA==
X-Gm-Message-State: APjAAAUDTNJwHP8oQRkY2dThirlGPkZRI66mlJQRGOPCgbOODNsp8V/3
	bnK7PPuLwq1j2InvynwDa6g5P1M5ACER0tIOHNcmqbsOuMf66bRQOCSPbg+q79YYD5lLejUfPw9
	W9B35GhX/E2FLwXBNFC0gtl5CYc4uqGKuty8ldaykyl+jQ6w8MDDbQVrUdIHbgnVeyw==
X-Received: by 2002:a05:6830:10e:: with SMTP id i14mr3911866otp.32.1561564860044;
        Wed, 26 Jun 2019 09:01:00 -0700 (PDT)
X-Received: by 2002:a05:6830:10e:: with SMTP id i14mr3911796otp.32.1561564859182;
        Wed, 26 Jun 2019 09:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561564859; cv=none;
        d=google.com; s=arc-20160816;
        b=jbqEDjcnzuecBBhmukWOhcH6vlDifpEa6x1PviV4SKtJeHUMFth18OkQYVhFlp5VlB
         KYj9kxAAD2vqJVXunqJR/I4WvkFMJbOsskPsUoGuGx953pH6wi1l4Vb9LFxEddwP1DI9
         jzIMaTT6tuDRJOONhPtMrnRkFAo4H764qVznWK4MhlkqzWOQifXVLxBiUguh/f06q6kK
         ZDj/GAQyEn37qxtmB4veRahcoQ8yIw2KK/92bqZzHZO9y1ZKT3Mz5jj4xwKQTFMzrQzm
         Vq5MuJ1TyHiaULZcH9BES4v5xKF79CZGBrS9xWha42nFBnD4VY+AHwrswZTK11pDkIVG
         SGUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=r/963AMc32TjFW8pz2sb81LGtvemWumKWmOSWi/w+uo=;
        b=vXZmfInoX3OycU7YLZavJ0PGXpQA4Q3ZOJ4ZVwtcxl9+NnqPqNbV5IchnWbuQVy4zz
         dro8C718LaTPbiUCXas+nkgw0WJIDHVTxCtILf2pZrscSQjMbUavqFv98CXPFq0OjDCy
         ShNMcNa2u4//FFsu581tMKzAnONkw/7H1btc1yQI7W3zTJTWA+jwVFuid6VnoylVROCg
         3EbweqiGhTX5VhBG18ExAF7fVpoqJHHwwW9q7+WOPp5qB6Ma4AOTcR8z2ffnG9b6KzEW
         DHg9KfL8zPl3OlUx6Ax2VSx2cJuRrv9yMy3qmd/qeMzdtD6aR51Betk/73jo1bw7nivK
         UaSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FEqk4Ayq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v84sor8179188oib.101.2019.06.26.09.00.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 26 Jun 2019 09:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FEqk4Ayq;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=r/963AMc32TjFW8pz2sb81LGtvemWumKWmOSWi/w+uo=;
        b=FEqk4AyqvI2SzCotbI6w47r7lIg1pbMai4XViymaBkOSAtj0NfKwJKshzu/N8BPJFi
         PPN0xns9/GQ3UjW0F9OUD+lLQxT0bLvpRO6rEeExsKdp48k3oiJcMS1RfpUHWI3YgQSe
         P3swXsvQ9fmeXBT6oobBozcpVgRGWN23FavhhN4cCEGhqIdsUZ+QWbmxpT1xgQhmYaLI
         wRlJBZOCxG1HxsggNiXJVMbdqx15uDTKnIMPx8OZYBLCprh9CGs/eCgDPe7/TAMtVU5d
         oafpIZj3xnh4RTWYjvBCXah4DbVlLssHna403/2Qrtq8aZqQJ+EBDW0IKrQkvHB1zCgf
         +PXw==
X-Google-Smtp-Source: APXvYqw+HKEk3o1E4qvsumKbcYL8DeGoSSUg6kQouoUdfkWJuiZCSiMJzuF3+UevbQqRwbob+TxTsET5oJi5oxrpxxs=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr2276731oii.0.1561564858765;
 Wed, 26 Jun 2019 09:00:58 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-5-hch@lst.de>
In-Reply-To: <20190626122724.13313-5-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 26 Jun 2019 09:00:47 -0700
Message-ID: <CAPcyv4gTOf+EWzSGrFrh2GrTZt5HVR=e+xicUKEpiy57px8J+w@mail.gmail.com>
Subject: Re: [PATCH 04/25] mm: remove MEMORY_DEVICE_PUBLIC support
To: Christoph Hellwig <hch@lst.de>
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, 
	"Weiny, Ira" <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ add Ira ]

On Wed, Jun 26, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
>
> The code hasn't been used since it was added to the tree, and doesn't
> appear to actually be usable.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
[..]
> diff --git a/mm/swap.c b/mm/swap.c
> index 7ede3eddc12a..83107410d29f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -740,17 +740,6 @@ void release_pages(struct page **pages, int nr)
>                 if (is_huge_zero_page(page))
>                         continue;
>
> -               /* Device public page can not be huge page */
> -               if (is_device_public_page(page)) {
> -                       if (locked_pgdat) {
> -                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> -                                                      flags);
> -                               locked_pgdat = NULL;
> -                       }
> -                       put_devmap_managed_page(page);
> -                       continue;
> -               }
> -

This collides with Ira's bug fix [1]. The MEMORY_DEVICE_FSDAX case
needs this to be converted to be independent of "public" pages.
Perhaps it should be pulled out of -mm and incorporated in this
series.

[1]: https://lore.kernel.org/lkml/20190605214922.17684-1-ira.weiny@intel.com/

