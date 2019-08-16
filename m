Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6ECC3A59D
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:54:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 071B421783
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:54:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 071B421783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F50B6B0003; Fri, 16 Aug 2019 12:54:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A53F6B0005; Fri, 16 Aug 2019 12:54:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BA926B0006; Fri, 16 Aug 2019 12:54:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0222.hostedemail.com [216.40.44.222])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7C06B0003
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:54:51 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id D486F181AC9C4
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:54:50 +0000 (UTC)
X-FDA: 75828890340.29.ray61_474e6bb46a602
X-HE-Tag: ray61_474e6bb46a602
X-Filterd-Recvd-Size: 5375
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf03.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:54:49 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CF1BE3001895;
	Fri, 16 Aug 2019 16:54:48 +0000 (UTC)
Received: from redhat.com (ovpn-123-168.rdu2.redhat.com [10.10.123.168])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6CAC884256;
	Fri, 16 Aug 2019 16:54:47 +0000 (UTC)
Date: Fri, 16 Aug 2019 12:54:45 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>, John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [RFC PATCH 2/2] mm/gup: introduce vaddr_pin_pages_remote()
Message-ID: <20190816165445.GD3149@redhat.com>
References: <90e5cd11-fb34-6913-351b-a5cc6e24d85d@nvidia.com>
 <20190814234959.GA463@iweiny-DESK2.sc.intel.com>
 <2cbdf599-2226-99ae-b4d5-8909a0a1eadf@nvidia.com>
 <ac834ac6-39bd-6df9-fca4-70b9520b6c34@nvidia.com>
 <20190815132622.GG14313@quack2.suse.cz>
 <20190815133510.GA21302@quack2.suse.cz>
 <0d6797d8-1e04-1ebe-80a7-3d6895fe71b0@suse.cz>
 <20190816154404.GF3041@quack2.suse.cz>
 <20190816155220.GC3149@redhat.com>
 <20190816161355.GL3041@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190816161355.GL3041@quack2.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 16 Aug 2019 16:54:48 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 06:13:55PM +0200, Jan Kara wrote:
> On Fri 16-08-19 11:52:20, Jerome Glisse wrote:
> > On Fri, Aug 16, 2019 at 05:44:04PM +0200, Jan Kara wrote:
> > > On Fri 16-08-19 10:47:21, Vlastimil Babka wrote:
> > > > On 8/15/19 3:35 PM, Jan Kara wrote:
> > > > >>=20
> > > > >> So when the GUP user uses MMU notifiers to stop writing to pag=
es whenever
> > > > >> they are writeprotected with page_mkclean(), they don't really=
 need page
> > > > >> pin - their access is then fully equivalent to any other mmap =
userspace
> > > > >> access and filesystem knows how to deal with those. I forgot o=
ut this case
> > > > >> when I wrote the above sentence.
> > > > >>=20
> > > > >> So to sum up there are three cases:
> > > > >> 1) DIO case - GUP references to pages serving as DIO buffers a=
re needed for
> > > > >>    relatively short time, no special synchronization with page=
_mkclean() or
> > > > >>    munmap() =3D> needs FOLL_PIN
> > > > >> 2) RDMA case - GUP references to pages serving as DMA buffers =
needed for a
> > > > >>    long time, no special synchronization with page_mkclean() o=
r munmap()
> > > > >>    =3D> needs FOLL_PIN | FOLL_LONGTERM
> > > > >>    This case has also a special case when the pages are actual=
ly DAX. Then
> > > > >>    the caller additionally needs file lease and additional fil=
e_pin
> > > > >>    structure is used for tracking this usage.
> > > > >> 3) ODP case - GUP references to pages serving as DMA buffers, =
MMU notifiers
> > > > >>    used to synchronize with page_mkclean() and munmap() =3D> n=
ormal page
> > > > >>    references are fine.
> > > >=20
> > > > IMHO the munlock lesson told us about another one, that's in the =
end equivalent
> > > > to 3)
> > > >=20
> > > > 4) pinning for struct page manipulation only =3D> normal page ref=
erences
> > > > are fine
> > >=20
> > > Right, it's good to have this for clarity.
> > >=20
> > > > > I want to add that I'd like to convert users in cases 1) and 2)=
 from using
> > > > > GUP to using differently named function. Users in case 3) can s=
tay as they
> > > > > are for now although ultimately I'd like to denote such use cas=
es in a
> > > > > special way as well...
> > > >=20
> > > > So after 1/2/3 is renamed/specially denoted, only 4) keeps the cu=
rrent
> > > > interface?
> > >=20
> > > Well, munlock() code doesn't even use GUP, just follow_page(). I'd =
wait to
> > > see what's left after handling cases 1), 2), and 3) to decide about=
 the
> > > interface for the remainder.
> > >=20
> >=20
> > For 3 we do not need to take a reference at all :) So just forget abo=
ut 3
> > it does not exist. For 3 the reference is the reference the CPU page =
table
> > has on the page and that's it. GUP is no longer involve in ODP or any=
thing
> > like that.
>=20
> Yes, I understand. But the fact is that GUP calls are currently still t=
here
> e.g. in ODP code. If you can make the code work without taking a page
> reference at all, I'm only happy :)

Already in rdma next AFAIK so in 5.4 it will be gone :) i have been
removing all GUP users that do not need reference. Intel i915 driver
is a left over i will work some more with them to get rid of it too.

Cheers,
J=E9r=F4me

