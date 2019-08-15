Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E472C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:51:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CBAA220578
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 20:51:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBAA220578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 699C36B000A; Thu, 15 Aug 2019 16:51:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64A896B000C; Thu, 15 Aug 2019 16:51:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53A836B000D; Thu, 15 Aug 2019 16:51:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0087.hostedemail.com [216.40.44.87])
	by kanga.kvack.org (Postfix) with ESMTP id 3830C6B000A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:51:38 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id B0A378248ABF
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:51:37 +0000 (UTC)
X-FDA: 75825858234.08.cloth04_2b465caaa6020
X-HE-Tag: cloth04_2b465caaa6020
X-Filterd-Recvd-Size: 3660
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 20:51:37 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CD57286663;
	Thu, 15 Aug 2019 20:51:35 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C77D017B64;
	Thu, 15 Aug 2019 20:51:34 +0000 (UTC)
Date: Thu, 15 Aug 2019 16:51:33 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Message-ID: <20190815205132.GC25517@redhat.com>
References: <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com>
 <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com>
 <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com>
 <20190815204128.GI22970@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815204128.GI22970@mellanox.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 15 Aug 2019 20:51:36 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 08:41:33PM +0000, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 04:33:06PM -0400, Jerome Glisse wrote:
>=20
> > So nor HMM nor driver should dereference the struct page (i do not
> > think any iommu driver would either),
>=20
> Er, they do technically deref the struct page:
>=20
> nouveau_dmem_convert_pfn(struct nouveau_drm *drm,
> 			 struct hmm_range *range)
> 		struct page *page;
> 		page =3D hmm_pfn_to_page(range, range->pfns[i]);
> 		if (!nouveau_dmem_page(drm, page)) {
>=20
>=20
> nouveau_dmem_page(struct nouveau_drm *drm, struct page *page)
> {
> 	return is_device_private_page(page) && drm->dmem =3D=3D page_to_dmem(p=
age)
>=20
>=20
> Which does touch 'page->pgmap'
>=20
> Is this OK without having a get_dev_pagemap() ?
>
> Noting that the collision-retry scheme doesn't protect anything here
> as we can have a concurrent invalidation while doing the above deref.

Uh ? How so ? We are not reading the same code i think.

My read is that function is call when holding the device
lock which exclude any racing mmu notifier from making
forward progress and it is also protected by the range so
at the time this happens it is safe to dereference the
struct page. In this case any way we can update the
nouveau_dmem_page() to check that page page->pgmap =3D=3D the
expected pgmap.

Cheers,
J=E9r=F4me

