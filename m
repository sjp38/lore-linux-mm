Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C78FDC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:14:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98D9C208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 17:14:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98D9C208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CA316B0007; Wed, 26 Jun 2019 13:14:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37AC68E0003; Wed, 26 Jun 2019 13:14:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26A328E0002; Wed, 26 Jun 2019 13:14:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2E6E6B0007
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 13:14:49 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s195so1950311pgs.13
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 10:14:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YTySEaIj2YYHedNWzyyvSQnHTXQl6dnsmldE2x9OG9A=;
        b=ZLZaNrILxOziyaTUCB+VkQV1hiLXUr3+jZzfT89z3uQeYjjHsUTQRGzOFNo9CrBr7F
         WDHZlRGbd2Z92NAdy7OZXmJy29SP1EAiKJu/420Br0vcC9C0nzdvCqXCgUVmSm2DrQR+
         CdiU/91hWdLKy+keRq8bdIZeXjvxWNV7a6RlDKZPQIVxoATKKJFXQb33Lvan7TZUakCY
         UOn5CB2EzGmEu8UkYji2eHbTtWRM6J50e1sYZRt4bxgxABdGS8BYfAW2Vgqib0O5aJ9+
         vpm1RRbbFdfCgojHZgITd1hpAzJHnmXddlZ/+e8BOmnEBDPeFmg8SVoe3V0r/bux+qX7
         M8rA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUfKKysgZkfkLloxL8FAEwO4bB4aP27Ihb7Ylbm3S90cgiry54J
	ZqRa5uAzVJWHDsuQk8xfhCwdja9VxGXhJ+CJQRc0hpNwI+9qu0XshULA3EO5NUKi7t07C8BtkTu
	/HgLWV9XWSyF9twWXz+rJKfQPqwz/C4cAYSIW+fOfVZrBrb3JRXYG0mc18ciKyu25cw==
X-Received: by 2002:a63:e018:: with SMTP id e24mr3919918pgh.361.1561569289530;
        Wed, 26 Jun 2019 10:14:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzif19FN8fF7ksha0VHiZ/ScIPl4Aj0JjcWP56XJcbPUrDkltUQ9Hi6JNFV4Yu31DI5TtH0
X-Received: by 2002:a63:e018:: with SMTP id e24mr3919784pgh.361.1561569287688;
        Wed, 26 Jun 2019 10:14:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561569287; cv=none;
        d=google.com; s=arc-20160816;
        b=F0rVII37gU1orxvQr6/8ZPauLSxkuj409+a5QIjRwIgRA0xnZUOeArO7pyOa7vcXLM
         3pM53aUWZXfk3YPlqX0fGYzoT/WFKljDgvOHnVoY1Gjx8FOOnhndA18PuMkVp83jiXSp
         8zbyJfiApXhmpzfyps7eVHsBo4cEaJ0r180PVPFnCHSSah7IAbiPIF8Uhk3keRD1VIdp
         VUt6AYDykOsXBSzN9b9+0SlxNKSad9Nf9kxhxk8gAL9pKufwEFh5HpCopDD6D0VAuuA7
         2O+WrWQpHJQodQuUtafhPtZuutqr9KAHXDl52ngv2Wa3cYa9wK+zPAzDxbcgGFk+2M66
         3wtw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YTySEaIj2YYHedNWzyyvSQnHTXQl6dnsmldE2x9OG9A=;
        b=E/kZoL61dwcDGN80utMCQ3a4dA8hseA4Ik6eAJeCAVO7UnQNyjQY3HnvYWaxEt+4/T
         X5m9wyunTpkst++wLYLnYpALP0B1mqozP5g15dnEh4b5pgYH23shU/pUCOEmOaSaWBuK
         p7SOO5w3ASW78XVHiADyy1SYHzoq5/+YcCuQWdTY4y8RJEb7ND37dipM+R6R2avObkJT
         q3tF8ELztujSlID4zbpvfgaOP5oCjkI6qogmihuYFiHf5iG8cP2+WyOPfG0FFTL3NaYi
         axt166XAGc5Drc2OPsgUSRQd0b+EgbzZ3CUZPK7OCoR8XmXF2sPruQa4PkmGoYE/nQKO
         7DUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id v13si16048388pgr.282.2019.06.26.10.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 10:14:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 10:14:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="172793484"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 26 Jun 2019 10:14:46 -0700
Date: Wed, 26 Jun 2019 10:14:45 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 04/25] mm: remove MEMORY_DEVICE_PUBLIC support
Message-ID: <20190626171445.GA4605@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-5-hch@lst.de>
 <CAPcyv4gTOf+EWzSGrFrh2GrTZt5HVR=e+xicUKEpiy57px8J+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gTOf+EWzSGrFrh2GrTZt5HVR=e+xicUKEpiy57px8J+w@mail.gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 09:00:47AM -0700, Dan Williams wrote:
> [ add Ira ]
> 
> On Wed, Jun 26, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
> >
> > The code hasn't been used since it was added to the tree, and doesn't
> > appear to actually be usable.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> [..]
> > diff --git a/mm/swap.c b/mm/swap.c
> > index 7ede3eddc12a..83107410d29f 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -740,17 +740,6 @@ void release_pages(struct page **pages, int nr)
> >                 if (is_huge_zero_page(page))
> >                         continue;
> >
> > -               /* Device public page can not be huge page */
> > -               if (is_device_public_page(page)) {
> > -                       if (locked_pgdat) {
> > -                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> > -                                                      flags);
> > -                               locked_pgdat = NULL;
> > -                       }
> > -                       put_devmap_managed_page(page);
> > -                       continue;
> > -               }
> > -
> 
> This collides with Ira's bug fix [1]. The MEMORY_DEVICE_FSDAX case
> needs this to be converted to be independent of "public" pages.
> Perhaps it should be pulled out of -mm and incorporated in this
> series.
> 
> [1]: https://lore.kernel.org/lkml/20190605214922.17684-1-ira.weiny@intel.com/

Agreed and Andrew picked the first 2 versions of it, mmotm commits:

3eed114b5b6b mm-swap-fix-release_pages-when-releasing-devmap-pages-v2
9b7d8d0f572f mm/swap.c: fix release_pages() when releasing devmap pages

I don't see v3 but there were no objections...

Ira

