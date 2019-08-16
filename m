Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA9F1C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 04:44:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 870C1206C1
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 04:44:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 870C1206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3622E6B0007; Fri, 16 Aug 2019 00:44:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2EBCF6B0008; Fri, 16 Aug 2019 00:44:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DA346B000A; Fri, 16 Aug 2019 00:44:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0125.hostedemail.com [216.40.44.125])
	by kanga.kvack.org (Postfix) with ESMTP id EC18E6B0007
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 00:44:52 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9FF936109
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:44:52 +0000 (UTC)
X-FDA: 75827050824.26.scale76_64c0e37f40460
X-HE-Tag: scale76_64c0e37f40460
X-Filterd-Recvd-Size: 2722
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf30.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 04:44:52 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id B1DD368AFE; Fri, 16 Aug 2019 06:44:48 +0200 (CEST)
Date: Fri, 16 Aug 2019 06:44:48 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Christoph Hellwig <hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Message-ID: <20190816044448.GB4093@lst.de>
References: <20190814132746.GE13756@mellanox.com> <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com> <20190815180325.GA4920@redhat.com> <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com> <20190815194339.GC9253@redhat.com> <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com> <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com> <20190815205132.GC25517@redhat.com> <20190816004303.GC9929@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816004303.GC9929@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 12:43:07AM +0000, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 04:51:33PM -0400, Jerome Glisse wrote:
> 
> > struct page. In this case any way we can update the
> > nouveau_dmem_page() to check that page page->pgmap == the
> > expected pgmap.
> 
> I was also wondering if that is a problem.. just blindly doing a
> container_of on the page->pgmap does seem like it assumes that only
> this driver is using DEVICE_PRIVATE.
> 
> It seems like something missing in hmm_range_fault, it should be told
> what DEVICE_PRIVATE is acceptable to trigger HMM_PFN_DEVICE_PRIVATE
> and fault all others?

The whole device private handling in hmm and migrate_vma seems pretty
broken as far as I can tell, and I have some WIP patches.  Basically we
should not touch (or possibly eventually call migrate to ram eventually
in the future) device private pages not owned by the caller, where I
try to defined the caller by the dev_pagemap_ops instance.  

