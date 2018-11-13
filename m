Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id B03516B0007
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 19:21:32 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id w5-v6so11530322ioj.3
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:21:32 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id e21-v6si9207224ita.133.2018.11.12.16.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 16:21:31 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH v1 11/11] mm: hwpoison: introduce
 clear_hwpoison_free_buddy_page()
Date: Tue, 13 Nov 2018 00:19:08 +0000
Message-ID: <20181113001907.GD5945@hori1.linux.bs1.fc.nec.co.jp>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-12-git-send-email-n-horiguchi@ah.jp.nec.com>
 <d37c1be2-2069-a147-9ba8-4749cd386d0b@arm.com>
In-Reply-To: <d37c1be2-2069-a147-9ba8-4749cd386d0b@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E98FB80BE4F9824B971DACC8E14BE8C3@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>

On Fri, Nov 09, 2018 at 05:03:06PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> > The new function is a reverse operation of set_hwpoison_free_buddy_page=
()
> > to adjust unpoison_memory() to the new semantics.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>=20
> snip
>=20
> > +
> > +/*
> > + * Reverse operation of set_hwpoison_free_buddy_page(), which is expec=
ted
> > + * to work only on error pages isolated from buddy allocator.
> > + */
> > +bool clear_hwpoison_free_buddy_page(struct page *page)
> > +{
> > +	struct zone *zone =3D page_zone(page);
> > +	bool unpoisoned =3D false;
> > +
> > +	spin_lock(&zone->lock);
> > +	if (TestClearPageHWPoison(page)) {
> > +		unsigned long pfn =3D page_to_pfn(page);
> > +		int migratetype =3D get_pfnblock_migratetype(page, pfn);
> > +
> > +		__free_one_page(page, pfn, zone, 0, migratetype);
> > +		unpoisoned =3D true;
> > +	}
> > +	spin_unlock(&zone->lock);
> > +	return unpoisoned;
> > +}
> >  #endif
> >=20
>=20
> Though there are multiple page state checks in unpoison_memory() leading
> upto clearing HWPoison flag, the page must not be in buddy already if
> __free_one_page() would be called on it.

Yes, you're right.
clear_hwpoison_free_buddy_page() is intended to cancel the isolation by
set_hwpoison_free_buddy_page() which removes the target page from buddy all=
ocator,
so the page clear_hwpoison_free_buddy_page() tries to handle is not a buddy=
 page
actually (not linked to any freelist).

Thanks,
Naoya Horiguchi=
