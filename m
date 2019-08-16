Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35AA3C3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01FA720644
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 12:34:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01FA720644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8DAE6B0003; Fri, 16 Aug 2019 08:34:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3DF96B000A; Fri, 16 Aug 2019 08:34:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 954EB6B000C; Fri, 16 Aug 2019 08:34:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0164.hostedemail.com [216.40.44.164])
	by kanga.kvack.org (Postfix) with ESMTP id 759AD6B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:34:17 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 3248B52C5
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:34:17 +0000 (UTC)
X-FDA: 75828233754.25.straw97_7cac761e7c148
X-HE-Tag: straw97_7cac761e7c148
X-Filterd-Recvd-Size: 2705
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:34:16 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id E3D2B68B05; Fri, 16 Aug 2019 14:34:12 +0200 (CEST)
Date: Fri, 16 Aug 2019 14:34:12 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Message-ID: <20190816123412.GB22140@lst.de>
References: <20190815180325.GA4920@redhat.com> <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com> <20190815194339.GC9253@redhat.com> <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com> <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com> <20190815205132.GC25517@redhat.com> <20190816004303.GC9929@mellanox.com> <20190816044448.GB4093@lst.de> <20190816123036.GD5412@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816123036.GD5412@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 12:30:41PM +0000, Jason Gunthorpe wrote:
> 
> For instance, a system may have multiple DEVICE_PRIVATE map's owned by
> the same driver - but multiple physical devices using that driver.
> 
> Each physical device's driver should only ever get DEVICE_PRIVATE
> pages for it's own on-device memory. Never a DEVICE_PRIVATE for
> another device's memory.
> 
> The dev_pagemap_ops would not be unique enough, right?

True.

> 
> Probably also clusters of same-driver struct device can share a
> DEVICE_PRIVATE, at least high end GPU's now have private memory
> coherency busses between their devices.
> 
> Since we want to trigger migration to CPU on incompatible
> DEVICE_PRIVATE pages, it seems best to sort this out in the
> hmm_range_fault?
> 
> Maybe some sort of unique ID inside the page->pgmap and passed as
> input?

Yes, we'll probably need an owner field.  And it's not just
hmm_range_fault, the migrate_vma_* routines as affected in the same
way.

