Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EA57C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:35:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E1262171F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:35:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E1262171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82FC96B0286; Thu, 15 Aug 2019 09:35:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E9766B0288; Thu, 15 Aug 2019 09:35:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D0A06B0289; Thu, 15 Aug 2019 09:35:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE5F6B0286
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:35:13 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id F0EC155FA9
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:35:12 +0000 (UTC)
X-FDA: 75824758464.27.paste25_105946ce7094a
X-HE-Tag: paste25_105946ce7094a
X-Filterd-Recvd-Size: 5433
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf13.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:35:12 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C57B7AE12;
	Thu, 15 Aug 2019 13:35:10 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 357491E4200; Thu, 15 Aug 2019 15:35:10 +0200 (CEST)
Date: Thu, 15 Aug 2019 15:35:10 +0200
From: Jan Kara <jack@suse.cz>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190815133510.GA21302@quack2.suse.cz>
References: <20190812015044.26176-3-jhubbard@nvidia.com>
 <20190812234950.GA6455@iweiny-DESK2.sc.intel.com>
 <38d2ff2f-4a69-e8bd-8f7c-41f1dbd80fae@nvidia.com>
 <20190813210857.GB12695@iweiny-DESK2.sc.intel.com>
 <a1044a0d-059c-f347-bd68-38be8478bf20@nvidia.com>
 <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815132622.GG14313@quack2.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 15-08-19 15:26:22, Jan Kara wrote:
> On Wed 14-08-19 20:01:07, John Hubbard wrote:
> > On 8/14/19 5:02 PM, John Hubbard wrote:
> > > On 8/14/19 4:50 PM, Ira Weiny wrote:
> > > > On Tue, Aug 13, 2019 at 05:56:31PM -0700, John Hubbard wrote:
> > > > > On 8/13/19 5:51 PM, John Hubbard wrote:
> > > > > > On 8/13/19 2:08 PM, Ira Weiny wrote:
> > > > > > > On Mon, Aug 12, 2019 at 05:07:32PM -0700, John Hubbard wrot=
e:
> > > > > > > > On 8/12/19 4:49 PM, Ira Weiny wrote:
> > > > > > > > > On Sun, Aug 11, 2019 at 06:50:44PM -0700, john.hubbard@=
gmail.com wrote:
> > > > > > > > > > From: John Hubbard <jhubbard@nvidia.com>
> > > > > > > > ...
> > > > > > > Finally, I struggle with converting everyone to a new call.=
=A0 It is more
> > > > > > > overhead to use vaddr_pin in the call above because now the=
 GUP code is going
> > > > > > > to associate a file pin object with that file when in ODP w=
e don't need that
> > > > > > > because the pages can move around.
> > > > > >=20
> > > > > > What if the pages in ODP are file-backed?
> > > > > >=20
> > > > >=20
> > > > > oops, strike that, you're right: in that case, even the file sy=
stem case is covered.
> > > > > Don't mind me. :)
> > > >=20
> > > > Ok so are we agreed we will drop the patch to the ODP code?=A0 I'=
m going to keep
> > > > the FOLL_PIN flag and addition in the vaddr_pin_pages.
> > > >=20
> > >=20
> > > Yes. I hope I'm not overlooking anything, but it all seems to make =
sense to
> > > let ODP just rely on the MMU notifiers.
> > >=20
> >=20
> > Hold on, I *was* forgetting something: this was a two part thing, and
> > you're conflating the two points, but they need to remain separate an=
d
> > distinct. There were:
> >=20
> > 1. FOLL_PIN is necessary because the caller is clearly in the use cas=
e that
> > requires it--however briefly they might be there. As Jan described it=
,
> >=20
> > "Anything that gets page reference and then touches page data (e.g.
> > direct IO) needs the new kind of tracking so that filesystem knows
> > someone is messing with the page data." [1]
>=20
> So when the GUP user uses MMU notifiers to stop writing to pages whenev=
er
> they are writeprotected with page_mkclean(), they don't really need pag=
e
> pin - their access is then fully equivalent to any other mmap userspace
> access and filesystem knows how to deal with those. I forgot out this c=
ase
> when I wrote the above sentence.
>=20
> So to sum up there are three cases:
> 1) DIO case - GUP references to pages serving as DIO buffers are needed=
 for
>    relatively short time, no special synchronization with page_mkclean(=
) or
>    munmap() =3D> needs FOLL_PIN
> 2) RDMA case - GUP references to pages serving as DMA buffers needed fo=
r a
>    long time, no special synchronization with page_mkclean() or munmap(=
)
>    =3D> needs FOLL_PIN | FOLL_LONGTERM
>    This case has also a special case when the pages are actually DAX. T=
hen
>    the caller additionally needs file lease and additional file_pin
>    structure is used for tracking this usage.
> 3) ODP case - GUP references to pages serving as DMA buffers, MMU notif=
iers
>    used to synchronize with page_mkclean() and munmap() =3D> normal pag=
e
>    references are fine.

I want to add that I'd like to convert users in cases 1) and 2) from usin=
g
GUP to using differently named function. Users in case 3) can stay as the=
y
are for now although ultimately I'd like to denote such use cases in a
special way as well...

								Honza
--=20
Jan Kara <jack@suse.com>
SUSE Labs, CR

