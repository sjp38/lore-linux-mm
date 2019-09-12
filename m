Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 834D3C49ED6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 01:31:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F63A2085B
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 01:31:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F63A2085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40976B000D; Wed, 11 Sep 2019 21:31:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E187F6B000E; Wed, 11 Sep 2019 21:31:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D2EA96B0010; Wed, 11 Sep 2019 21:31:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id B422E6B000D
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 21:31:39 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4191B181AC9BA
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 01:31:39 +0000 (UTC)
X-FDA: 75924541518.29.tank29_82c43eae05422
X-HE-Tag: tank29_82c43eae05422
X-Filterd-Recvd-Size: 4931
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 01:31:38 +0000 (UTC)
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8C1VWfY031379
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 12 Sep 2019 10:31:32 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8C1VWC7020932;
	Thu, 12 Sep 2019 10:31:32 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8C1TB9E032226;
	Thu, 12 Sep 2019 10:31:32 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.148] [10.38.151.148]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-8390835; Thu, 12 Sep 2019 10:28:32 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC20GP.gisp.nec.co.jp ([10.38.151.148]) with mapi id 14.03.0439.000; Thu,
 12 Sep 2019 10:28:32 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: David Hildenbrand <david@redhat.com>
CC: Oscar Salvador <osalvador@suse.de>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 02/10] mm,madvise: call soft_offline_page() without
 MF_COUNT_INCREASED
Thread-Topic: [PATCH 02/10] mm,madvise: call soft_offline_page() without
 MF_COUNT_INCREASED
Thread-Index: AQHVZ8LT5A97dnADeEaaRGKxuElT0aclr30AgAD844A=
Date: Thu, 12 Sep 2019 01:28:31 +0000
Message-ID: <20190912012831.GA15418@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190910103016.14290-3-osalvador@suse.de>
 <c17c8bac-c443-046f-e622-78ed713517c9@redhat.com>
In-Reply-To: <c17c8bac-c443-046f-e622-78ed713517c9@redhat.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <2C3D6FF6B1233443AE3234BB1559EB0B@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

On Wed, Sep 11, 2019 at 12:23:24PM +0200, David Hildenbrand wrote:
> On 10.09.19 12:30, Oscar Salvador wrote:
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >=20
> > Currently madvise_inject_error() pins the target via get_user_pages_fas=
t.
> > The call to get_user_pages_fast is only to get the respective page
> > of a given address, but it is the job of the memory-poisoning handler
> > to deal with races, so drop the refcount grabbed by get_user_pages_fast=
.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > ---
> >  mm/madvise.c | 25 +++++++++++--------------
> >  1 file changed, 11 insertions(+), 14 deletions(-)
> >=20
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 6e023414f5c1..fbe6d402232c 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -883,6 +883,16 @@ static int madvise_inject_error(int behavior,
> >  		ret =3D get_user_pages_fast(start, 1, 0, &page);
> >  		if (ret !=3D 1)
> >  			return ret;
> > +		/*
> > +		 * The get_user_pages_fast() is just to get the pfn of the
> > +		 * given address, and the refcount has nothing to do with
> > +		 * what we try to test, so it should be released immediately.
> > +		 * This is racy but it's intended because the real hardware
> > +		 * errors could happen at any moment and memory error handlers
> > +		 * must properly handle the race.
> > +		 */
> > +		put_page(page);
> > +
>=20
> I wonder if it would be clearer to do that after the page has been fully
> used  - e.g. after getting the pfn and the order (and then e.g.,
> symbolically setting the page pointer to 0).

Yes, this could be called just after page_to_pfn() below.

> I guess the important part of this patch is to not have an elevated
> refcount while calling soft_offline_page().
>=20

That's right.

> >  		pfn =3D page_to_pfn(page);
> > =20
> >  		/*
> > @@ -892,16 +902,11 @@ static int madvise_inject_error(int behavior,
> >  		 */
> >  		order =3D compound_order(compound_head(page));
> > =20
> > -		if (PageHWPoison(page)) {
> > -			put_page(page);
> > -			continue;
> > -		}
>=20
> This change is not reflected in the changelog. I would have expected
> that only the put_page() would go. If this should go completely, I
> suggest a separate patch.
>=20

I forget why I tried to remove the if block, and now I think only the
put_page() should go as you point out.

Thanks for the comment.

- Naoya=


