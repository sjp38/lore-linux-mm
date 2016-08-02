Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 803916B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 20:28:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so301334875pfg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 17:28:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id x20si37617229pal.165.2016.08.01.17.28.24
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 17:28:24 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 repost 4/7] virtio-balloon: speed up
 inflate/deflate process
Date: Tue, 2 Aug 2016 00:28:19 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04216308@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
 <20160728044000-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04214103@shsmsx102.ccr.corp.intel.com>
 <20160729003759-mutt-send-email-mst@kernel.org> <579BB30B.2040704@intel.com>
In-Reply-To: <579BB30B.2040704@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> > It's only small because it makes you rescan the free list.
> > So maybe you should do something else.
> > I looked at it a bit. Instead of scanning the free list, how about
> > scanning actual page structures? If page is unused, pass it to host.
> > Solves the problem of rescanning multiple times, does it not?
>=20
> FWIW, I think the new data structure needs some work.
>=20
> Before, we had a potentially very long list of 4k areas.  Now, we've just=
 got a
> very large bitmap.  The bitmap might not even be very dense if we are
> ballooning relatively few things.
>=20
> Can I suggest an alternate scheme?  I think you actually need a hybrid
> scheme that has bitmaps but also allows more flexibility in the pfn range=
s.
> The payload could be a number of records each containing 3 things:
>=20
> 	pfn, page order, length of bitmap (maybe in powers of 2)
>=20
> Each record is followed by the bitmap.  Or, if the bitmap length is 0,
> immediately followed by another record.  A bitmap length of 0 implies a
> bitmap with the least significant bit set.  Page order specifies how many
> pages each bit represents.
>=20
> This scheme could easily encode the new data structure you are proposing
> by just setting pfn=3D0, order=3D0, and a very long bitmap length.  But, =
it could
> handle sparse bitmaps much better *and* represent large pages much more
> efficiently.
>=20
> There's plenty of space to fit a whole record in 64 bits.

I like your idea and it's more flexible, and it's very useful if we want to=
 optimize the
page allocating stage further. I believe the memory fragmentation will not =
be very
serious, so the performance won't be too bad in the worst case.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
