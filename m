Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CA98C5B57D
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:15:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E842D20673
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 01:15:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UnhOZorS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E842D20673
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65D366B0003; Tue,  2 Jul 2019 21:15:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E6678E0003; Tue,  2 Jul 2019 21:15:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4603A8E0001; Tue,  2 Jul 2019 21:15:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 23C166B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 21:15:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r58so511073qtb.5
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 18:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=liD/9MOuZoViFzGGyLdGUss/Gqo1ol5fJSSMhDITAQY=;
        b=QbFQZlGVZP+kJ1/4eKuOO+jQnK0jSV4mdqQbyygYo7gFvlx7E5t/HwS1CUi81wrCx+
         o5O40Su1o3+cH9k+y8ebIOrlZsN+aMXOcBn92stiWJg4B+fKxxMSCRNxhavKUE9aQau3
         0vsrxDfKYI50HsqTfNK5XLD0zgYSdFCVmh5v4YLBEPlt18flP4lNRF28GT594O1/xv16
         vxT35Z+UNJV/z/5SdywSwApGqHJb/K7dWYCFnM8Gap23R4l0LU2DAZKkutTfHOQhpAXm
         2ZpH+tz+28GNhuaXmS2DqEvsHmY9rEZ3AgVKBvmnOjzKuuOsS5esg4OM+SKgFG53qnOL
         hxIA==
X-Gm-Message-State: APjAAAV3A8/je2CrNxOZs61yqtGWlDAHQEt8Azry/daYOkDO6NNKYOh1
	1yHnZNR/TYLdtK2UVO2RjSAv8OmWbuaw92HW7enqEmWLK7P3aewXvbnm6O8mIBRmFCfrsHk1/P+
	zRebjybAVBxGFfUJNHcUc1KjAZwHqfUU2ENTHCqHa4lZ2IFm1aM8viWPJIb1VvN3pVw==
X-Received: by 2002:ac8:d8:: with SMTP id d24mr28730619qtg.284.1562116524864;
        Tue, 02 Jul 2019 18:15:24 -0700 (PDT)
X-Received: by 2002:ac8:d8:: with SMTP id d24mr28730590qtg.284.1562116524198;
        Tue, 02 Jul 2019 18:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562116524; cv=none;
        d=google.com; s=arc-20160816;
        b=fQozDrEovib8/KO7yRydkjrC9qZoYOglWrcQnG0dX+DwZllIN3d6xOuHDLCt3fV60B
         woG5gxa4uebyqgVyQGjRc5eS51WWRF994EnsNaIschLXRfIY0PwqZ7XFwRW4/s9TMvZo
         WjxPkGKuIHlsTksNoRDyDBlY94WJ+P/r0r0fTZEunTRXH/jdHSxDzRDH/yhidRpnPZJS
         S746KdgkxSDf9mu7h8WuQ27BxoA3WHOQgKD3QJ2GVCRxTa0Bil7M9ruknsg+grjAYH1i
         yYNX0tHIpGioNK6KTRuuaIhe+xw+h3ooWvxeJCrvk0//kNsffFkpLY6SdeDVcb6JGK9j
         mwxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=liD/9MOuZoViFzGGyLdGUss/Gqo1ol5fJSSMhDITAQY=;
        b=bweQ2wh/EoeuOeXmEZ1kO7pakOPXJc9+QNLsY4WwnH8oPlliroboZKo888xj8k+e4j
         wHgr9OQDBPZNZaRwqT76Y1FONGix9k5fiu2i9BOIIEpkvEp1jfviOuj5kC4UpWKEcJoi
         x8wGDAoINQsSGQ3HmCEe6txea8pta1L7olNRPGkBbnidm4fI1jqpWYhqN8oH90iXWvQc
         SV/AoKp+GO/sywqudYmdx5tXkS1o4KFErzBUOva4luIQ0K4QtM7pgN2xjOWaTmc4fXFl
         HxNDIweJbC0iGrGypoKF+bj9X7QaSDwLaIKremp6f7DGySH3syZz0WkRgw4jeckwCa8M
         jd1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UnhOZorS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c51sor599612qvh.56.2019.07.02.18.15.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jul 2019 18:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UnhOZorS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=liD/9MOuZoViFzGGyLdGUss/Gqo1ol5fJSSMhDITAQY=;
        b=UnhOZorS3ucGouUUJ6xafrtEEsrX5ysAkBVI/dg0ZDjAor0OxuBA66FjAsrdJzKZqa
         G3rtRFX3LZwSYqMOBRJdLP9vOEpUJGse5xkqxCgJgkoHH6ZETtC2CglOl4Gz5eFwpqB9
         QzIxbsAgExukM9P5cCYF4G/pWMgFuyXXXJu+u3Y4bLJtZMGGp8agn2dYu+GgusYFkrY0
         DjmP1xdzXz714lNjvE40LvuRv89Cq5LlyEdBR8fPDZmzLsUDw9f5zp7ObEGjtZEXBozS
         GWnd9fyxQj73uY3RTiDeaKO0HgGB35X+h7NDpv4bt5E6fuwbyoqXx5aVYiSemB1oaeTV
         JcBw==
X-Google-Smtp-Source: APXvYqxT1ad2sCuVGtqHLhWSofYS4jtico3ZGFHLaY5pqoKGA8G7OYoBujn1EZbSkY3AoMmJOvEP3A==
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr28714349qvj.236.1562116523841;
        Tue, 02 Jul 2019 18:15:23 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id a21sm255229qkg.47.2019.07.02.18.15.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jul 2019 18:15:23 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hiTrm-0004FU-T2; Tue, 02 Jul 2019 22:15:22 -0300
Date: Tue, 2 Jul 2019 22:15:22 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v4] mm/swap: Fix release_pages() when releasing devmap
 pages
Message-ID: <20190703011522.GA15993@ziepe.ca>
References: <20190605214922.17684-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190605214922.17684-1-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 05, 2019 at 02:49:22PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> release_pages() is an optimized version of a loop around put_page().
> Unfortunately for devmap pages the logic is not entirely correct in
> release_pages().  This is because device pages can be more than type
> MEMORY_DEVICE_PUBLIC.  There are in fact 4 types, private, public, FS
> DAX, and PCI P2PDMA.  Some of these have specific needs to "put" the
> page while others do not.
> 
> This logic to handle any special needs is contained in
> put_devmap_managed_page().  Therefore all devmap pages should be
> processed by this function where we can contain the correct logic for a
> page put.
> 
> Handle all device type pages within release_pages() by calling
> put_devmap_managed_page() on all devmap pages.  If
> put_devmap_managed_page() returns true the page has been put and we
> continue with the next page.  A false return of
> put_devmap_managed_page() means the page did not require special
> processing and should fall to "normal" processing.
> 
> This was found via code inspection while determining if release_pages()
> and the new put_user_pages() could be interchangeable.[1]
> 
> [1] https://lore.kernel.org/lkml/20190523172852.GA27175@iweiny-DESK2.sc.intel.com/
> 
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> 
> ---
> Changes from V3:
> 	Update comment to the one provided by John
> 
> Changes from V2:
> 	Update changelog for more clarity as requested by Michal
> 	Update comment WRT "failing" of put_devmap_managed_page()
> 
> Changes from V1:
> 	Add comment clarifying that put_devmap_managed_page() can still
> 	fail.
> 	Add Reviewed-by tags.
> 
>  mm/swap.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)

Andrew,

As per the discussion on the hmm thread I took this patch into the
hmm.git as the conflict that was created with CH's rework was tricky -
the resolution is simple, but keeping Ira's hunk instead of the delete
is, IMHO, subtle.

Regards, 
Jason

