Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07C17C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:49:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4780208E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 18:49:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4780208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C2E26B0005; Wed, 26 Jun 2019 14:49:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 075518E0003; Wed, 26 Jun 2019 14:49:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECCC88E0002; Wed, 26 Jun 2019 14:49:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B844D6B0005
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 14:49:55 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id y9so1926308plp.12
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=s323sdmVsCWXbdsJLT3PPGNysqsCnvnQZ6CWp6aUiZ0=;
        b=mcayBlQZXD6KWZqzA7MBEkWbg5/kovLPnnRwKpXV1a2/YA7JWOKOk8GUqPdtxJ0WRi
         WUymvmQ5P+4PvvGlgwoV0/KEjoU6g/N/im0IEwlq74IWarWt5nDiUndOisojmG35CTC1
         71WyYgGpi0jijmeYn2X5o4oK/C9bxmGNVQLW0TCYranmjLC/Unqf2jy0nGxUoK+rSg0O
         Ukkml9ost6vMzwOEnUxJQeiDYE1c1wISPp4Zqqr7JDTJ7B0CBeW8jBehz0DMWtYwg/kU
         KQNsK3bvevziGNmAJT43RZVmyab2eUEGjYoTxEUX1LRdLBruRGy0PXpt1JRd5VXoZEwN
         9enw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXokZEt7p/egbLoXztcC/nz0H74UCbyzgTCHbwjDkRulo6jK/UC
	MGY2Ix4vaaFCA7eCS6fBkDwLSqilzcD8sGw7CktnUahaz8Wp9KNG8MOxpeRO7Y4kRFzKzmTzXDE
	HYhIntaY90tGXQQbOBUhY6wJ3k4tqlywDSGs5LCBz+bfW6gzaZH4ERAxTatb1y4g+qw==
X-Received: by 2002:a63:4e5f:: with SMTP id o31mr4470522pgl.49.1561574995289;
        Wed, 26 Jun 2019 11:49:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY2OxnzKWhqP2JNHo089Q6NI39egbYRIeVBQrtihZpoiZPFGVi/neJtqTS+10V99r6pDAl
X-Received: by 2002:a63:4e5f:: with SMTP id o31mr4470446pgl.49.1561574994272;
        Wed, 26 Jun 2019 11:49:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561574994; cv=none;
        d=google.com; s=arc-20160816;
        b=KSrxnYhXHONG2SbL4W1/J0XWrkkdZU8UpWNAqzWppgKGa2Hium61kAAyaBRHVJrbYn
         5hEp0eHxy2h+FIuoc+8mvLWJuEnNhWd5G+x1b1HZoqxqaWabHLZzpZOF+LR0amTEQQnf
         Naxoj6b2slR9WEbBLGsWExRjG6WIFiwnUg03uhep2vg0guVntZd/NjEEu2VziOOB0We3
         PB852l4m/7gWCPpzWpLqRTd5cHFE1wPTx01WvZXzAf+IRS6eSeWTJIY+EVbXrCszaMF/
         YrVT8mzlpPK82u3cZCdkvo22+95PgJP1/d/BxugCl0QGmIAy1teCUCajqou1OYVqzOrO
         Fg+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=s323sdmVsCWXbdsJLT3PPGNysqsCnvnQZ6CWp6aUiZ0=;
        b=JRamjZGohAcvTSjSGOmo2d3isDeJLXLzDEPU4UmvCJUR10TEYTFiVRiKJPh7nNLjG6
         3bCx26fia/x2d9WGxDu3LioKlF+KbIKHNoFKsT7wn/JZSosArUJUVLJ9HCwYuM+1UNOd
         5RMlyW2c5nkfDehV2ohP1TLXwGJZPV2JrcGyNn5g14mnjtrkmdU+6q+1gYXN9cyIOPOu
         VKnuMQYTJtDPa+2DP/pEmRZnymD4r8CTx0f1a5+D3Fz/Y042iQdoe7HwFZBCKfaSXO5Q
         zTJiH1Pm9xzhwl/7hopMOXeQN3xNg5t1zVnMgGS1cdU2cYDT/vYSiRVuFlSYoL/jd6XM
         sMNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t14si3924334plr.53.2019.06.26.11.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 11:49:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Jun 2019 11:49:53 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,420,1557212400"; 
   d="scan'208";a="164046367"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga007.fm.intel.com with ESMTP; 26 Jun 2019 11:49:53 -0700
Date: Wed, 26 Jun 2019 11:49:53 -0700
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
Message-ID: <20190626184953.GC4605@iweiny-DESK2.sc.intel.com>
References: <20190626122724.13313-1-hch@lst.de>
 <20190626122724.13313-5-hch@lst.de>
 <CAPcyv4gTOf+EWzSGrFrh2GrTZt5HVR=e+xicUKEpiy57px8J+w@mail.gmail.com>
 <20190626171445.GA4605@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626171445.GA4605@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 10:14:45AM -0700, 'Ira Weiny' wrote:
> On Wed, Jun 26, 2019 at 09:00:47AM -0700, Dan Williams wrote:
> > [ add Ira ]
> > 
> > On Wed, Jun 26, 2019 at 5:27 AM Christoph Hellwig <hch@lst.de> wrote:
> > >
> > > The code hasn't been used since it was added to the tree, and doesn't
> > > appear to actually be usable.
> > >
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> > > Acked-by: Michal Hocko <mhocko@suse.com>
> > [..]
> > > diff --git a/mm/swap.c b/mm/swap.c
> > > index 7ede3eddc12a..83107410d29f 100644
> > > --- a/mm/swap.c
> > > +++ b/mm/swap.c
> > > @@ -740,17 +740,6 @@ void release_pages(struct page **pages, int nr)
> > >                 if (is_huge_zero_page(page))
> > >                         continue;
> > >
> > > -               /* Device public page can not be huge page */
> > > -               if (is_device_public_page(page)) {
> > > -                       if (locked_pgdat) {
> > > -                               spin_unlock_irqrestore(&locked_pgdat->lru_lock,
> > > -                                                      flags);
> > > -                               locked_pgdat = NULL;
> > > -                       }
> > > -                       put_devmap_managed_page(page);
> > > -                       continue;
> > > -               }
> > > -
> > 
> > This collides with Ira's bug fix [1]. The MEMORY_DEVICE_FSDAX case
> > needs this to be converted to be independent of "public" pages.
> > Perhaps it should be pulled out of -mm and incorporated in this
> > series.
> > 
> > [1]: https://lore.kernel.org/lkml/20190605214922.17684-1-ira.weiny@intel.com/
> 
> Agreed and Andrew picked the first 2 versions of it, mmotm commits:
> 
> 3eed114b5b6b mm-swap-fix-release_pages-when-releasing-devmap-pages-v2
> 9b7d8d0f572f mm/swap.c: fix release_pages() when releasing devmap pages
> 
> I don't see v3 but there were no objections...

Ok somehow I can't fetch mmotm right now...

Dan had and updated mmotm tree and it does have my v4 patch.

Does anyone else have issues with git://git.cmpxchg.org/linux-mmotm.git or is
it just me?  FWIW I have checked proxies etc... and can get to linus and other
sites just fine, so it looks like an issue there.  Although the web page is
fine...

Sorry,
Ira

