Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27791C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:41:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4FDB20850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:41:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4FDB20850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 809806B000D; Thu, 13 Jun 2019 20:41:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BB326B000E; Thu, 13 Jun 2019 20:41:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A95A6B0266; Thu, 13 Jun 2019 20:41:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 35F2E6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:41:56 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i2so496947pfe.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:41:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=69J4FFfbrC31+HWFoMK0mw0m3/BuOAUjh7nUkMNIN2k=;
        b=d1aTEHMjvChDZ2sp6RtGP83wAXRp0mjcXvbM5aeC8O2jn9SRpt7224bZELexVFWsyZ
         aMu9d9LSBCXiALOzEGNT06c9GiS/Nnf8YjgxQ9dMDZ2bfhCcaKq1+8P/a0FLUUUYcPTR
         qNAehpjz8udKQA6d4/vWX0n74Iz9nxjr7FymbwispvDDweRS4RnZJreMvAeAF9hREdlg
         VmX3zM782TPYnAnDkBWDpc/JXny/GMm/iGGjarz40wMw9wdxwMacB5AST0d1YYU0NOum
         cmWcqAdWaA26YRCqgzlrfPzWoQcX3ShVU9d+g3R32qK70UEtu15AoLnty9Q/qRHqdPoQ
         nulg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVJG2LvXkMmAaW1S7CoQE04x7nFYjUCMd0acTmxQmeZAGjQBvA6
	wNXal3IeQDjG7XRLztxkZQyKkmPyCkX2HkmXCBR5iz8doNZ9BPgcJZK72FID8H97jI2DA+wKrjQ
	i+NoBzuxe+XCqvP+zAjZS7yhOsNKrGrz3TIk0k9N1CjRjboO7x+hHX5dkWQycXogEKQ==
X-Received: by 2002:a17:902:e211:: with SMTP id ce17mr9016677plb.193.1560472915873;
        Thu, 13 Jun 2019 17:41:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrzfm26l/RI5YvKo62ycu9dyRtSMfMPeQYao6hfUfOOoLqYqndAEOC3z1VocDmO91C2jd8
X-Received: by 2002:a17:902:e211:: with SMTP id ce17mr9016629plb.193.1560472915114;
        Thu, 13 Jun 2019 17:41:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560472915; cv=none;
        d=google.com; s=arc-20160816;
        b=rreh3G4zxgQOj/U4x3rPoilENRNq3oMiOkCJ+nImnRhgz5LNnOhwuxFUS9X29kH/99
         fwElM9NjGYxqTuTuSder/vFyyGqkV/8MV05yUJgpme9WNMMX4M3iQrXEqPYLslFyhKge
         K/qwLbpDMKYGchTeYuFUcHXb+f6bTkBSJdu+aIWWmeq4epwXKnkcnjLce9nlNtvt0hDu
         xsteJiP35P3V3EDJpOQOgSay+T2HrsztKDIuIYh9kogjdElwDalZgxXOA6k09n7iPAuF
         wmzRDaafSr7/9aXrKebZc1tRWeCysvq8Klpx61HeyDroK/SA70BVFVqd0JGG0HX4gr5/
         6tDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=69J4FFfbrC31+HWFoMK0mw0m3/BuOAUjh7nUkMNIN2k=;
        b=mHFP1yGH2MYBMWFr3LR8rhYtehG5dbV0KeVxm1BgTpI44xTXkEcD0p/0tMKBS6kh2G
         OhSRAHMEpwvDjwiZjmuE2zcZvzHgH8uq41/3ul1mxU1Hh/lt0f8+aMFXDKKWmeaFTEeI
         dkJGOKf/P0HVo2DVK0gUyKkE4nI9g37VuRMtC6n5LBkhwCw/7NduKG39WDC27COO7STi
         RgW8xnv7jSN9ResL1VV1B3cMUyP6psE9F7kldi3L82OSzoJaLSWw798w/8bwEvC6LlH1
         rdsnwFI/EWZB1lZ9BZha88qV4Rb1mt2dEYae3ZpSyhsm2yGpxETAlIHRM7l+yYyNQYn6
         9cBA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 129si890371pfe.140.2019.06.13.17.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:41:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 17:41:54 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga002.jf.intel.com with ESMTP; 13 Jun 2019 17:41:53 -0700
Date: Thu, 13 Jun 2019 17:43:15 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
Message-ID: <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-19-hch@lst.de>
 <20190613194430.GY22062@mellanox.com>
 <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613195819.GA22062@mellanox.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
> > 
> > On 6/13/19 12:44 PM, Jason Gunthorpe wrote:
> > > On Thu, Jun 13, 2019 at 11:43:21AM +0200, Christoph Hellwig wrote:
> > > > The code hasn't been used since it was added to the tree, and doesn't
> > > > appear to actually be usable.  Mark it as BROKEN until either a user
> > > > comes along or we finally give up on it.
> > > > 
> > > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > >   mm/Kconfig | 1 +
> > > >   1 file changed, 1 insertion(+)
> > > > 
> > > > diff --git a/mm/Kconfig b/mm/Kconfig
> > > > index 0d2ba7e1f43e..406fa45e9ecc 100644
> > > > +++ b/mm/Kconfig
> > > > @@ -721,6 +721,7 @@ config DEVICE_PRIVATE
> > > >   config DEVICE_PUBLIC
> > > >   	bool "Addressable device memory (like GPU memory)"
> > > >   	depends on ARCH_HAS_HMM
> > > > +	depends on BROKEN
> > > >   	select HMM
> > > >   	select DEV_PAGEMAP_OPS
> > > 
> > > This seems a bit harsh, we do have another kconfig that selects this
> > > one today:
> > > 
> > > config DRM_NOUVEAU_SVM
> > >          bool "(EXPERIMENTAL) Enable SVM (Shared Virtual Memory) support"
> > >          depends on ARCH_HAS_HMM
> > >          depends on DRM_NOUVEAU
> > >          depends on STAGING
> > >          select HMM_MIRROR
> > >          select DEVICE_PRIVATE
> > >          default n
> > >          help
> > >            Say Y here if you want to enable experimental support for
> > >            Shared Virtual Memory (SVM).
> > > 
> > > Maybe it should be depends on STAGING not broken?
> > > 
> > > or maybe nouveau_svm doesn't actually need DEVICE_PRIVATE?
> > > 
> > > Jason
> > 
> > I think you are confusing DEVICE_PRIVATE for DEVICE_PUBLIC.
> > DRM_NOUVEAU_SVM does use DEVICE_PRIVATE but not DEVICE_PUBLIC.
> 
> Indeed you are correct, never mind
> 
> Hum, so the only thing this config does is short circuit here:
> 
> static inline bool is_device_public_page(const struct page *page)
> {
>         return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
>                 IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
>                 is_zone_device_page(page) &&
>                 page->pgmap->type == MEMORY_DEVICE_PUBLIC;
> }
> 
> Which is called all over the place.. 

<sigh>  yes but the earlier patch:

[PATCH 03/22] mm: remove hmm_devmem_add_resource

Removes the only place type is set to MEMORY_DEVICE_PUBLIC.

So I think it is ok.  Frankly I was wondering if we should remove the public
type altogether but conceptually it seems ok.  But I don't see any users of it
so...  should we get rid of it in the code rather than turning the config off?

Ira

> 
> So, yes, we really don't want any distro or something to turn this on
> until it has a use.
> 
> Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
> 
> Jason
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

