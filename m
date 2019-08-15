Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B678C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:03:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57C432083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:03:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57C432083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6A706B0302; Thu, 15 Aug 2019 14:03:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1C0E6B0304; Thu, 15 Aug 2019 14:03:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D32A56B0305; Thu, 15 Aug 2019 14:03:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0231.hostedemail.com [216.40.44.231])
	by kanga.kvack.org (Postfix) with ESMTP id B216F6B0302
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:03:29 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 57948180AD802
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:03:29 +0000 (UTC)
X-FDA: 75825434538.19.laugh30_1e6ba7497001f
X-HE-Tag: laugh30_1e6ba7497001f
X-Filterd-Recvd-Size: 3911
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:03:28 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 161762A09AF;
	Thu, 15 Aug 2019 18:03:28 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F1A13600CD;
	Thu, 15 Aug 2019 18:03:26 +0000 (UTC)
Date: Thu, 15 Aug 2019 14:03:25 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
Message-ID: <20190815180325.GA4920@redhat.com>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-5-hch@lst.de>
 <20190807174548.GJ1571@mellanox.com>
 <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
 <20190808065933.GA29382@lst.de>
 <CAPcyv4hMUzw8vyXFRPe2pdwef0npbMm9tx9wiZ9MWkHGhH1V6w@mail.gmail.com>
 <20190814073854.GA27249@lst.de>
 <20190814132746.GE13756@mellanox.com>
 <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 15 Aug 2019 18:03:28 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 07:48:28AM -0700, Dan Williams wrote:
> On Wed, Aug 14, 2019 at 6:28 AM Jason Gunthorpe <jgg@mellanox.com> wrot=
e:
> >
> > On Wed, Aug 14, 2019 at 09:38:54AM +0200, Christoph Hellwig wrote:
> > > On Tue, Aug 13, 2019 at 06:36:33PM -0700, Dan Williams wrote:
> > > > Section alignment constraints somewhat save us here. The only exa=
mple
> > > > I can think of a PMD not containing a uniform pgmap association f=
or
> > > > each pte is the case when the pgmap overlaps normal dram, i.e. sh=
ares
> > > > the same 'struct memory_section' for a given span. Otherwise, dis=
tinct
> > > > pgmaps arrange to manage their own exclusive sections (and now
> > > > subsections as of v5.3). Otherwise the implementation could not
> > > > guarantee different mapping lifetimes.
> > > >
> > > > That said, this seems to want a better mechanism to determine "pf=
n is
> > > > ZONE_DEVICE".
> > >
> > > So I guess this patch is fine for now, and once you provide a bette=
r
> > > mechanism we can switch over to it?
> >
> > What about the version I sent to just get rid of all the strange
> > put_dev_pagemaps while scanning? Odds are good we will work with only
> > a single pagemap, so it makes some sense to cache it once we find it?
>=20
> Yes, if the scan is over a single pmd then caching it makes sense.

Quite frankly an easier an better solution is to remove the pagemap
lookup as HMM user abide by mmu notifier it means we will not make
use or dereference the struct page so that we are safe from any
racing hotunplug of dax memory (as long as device driver using hmm
do not have a bug).

Cheers,
J=E9r=F4me

