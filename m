Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 958C36B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 00:50:26 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so39717539pfg.0
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 21:50:26 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u75si10499544pfa.86.2016.11.07.21.50.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 21:50:25 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused
 page info
Date: Tue, 8 Nov 2016 05:50:22 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A108196@shsmsx102.ccr.corp.intel.com>
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
 <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
 <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A106DAA@shsmsx102.ccr.corp.intel.com>
 <281acd8d-fd94-6318-35e5-9eb130303dc6@intel.com>
In-Reply-To: <281acd8d-fd94-6318-35e5-9eb130303dc6@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "pbonzini@redhat.com" <pbonzini@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>

> On 11/06/2016 07:37 PM, Li, Liang Z wrote:
> >> Let's say we do a 32k bitmap that can hold ~1M pages.  That's 4GB of R=
AM.
> >> On a 1TB system, that's 256 passes through the top-level loop.
> >> The bottom-level lists have tens of thousands of pages in them, even
> >> on my laptop.  Only 1/256 of these pages will get consumed in a given =
pass.
> >>
> > Your description is not exactly.
> > A 32k bitmap is used only when there is few free memory left in the
> > system and when the extend_page_bitmap() failed to allocate more
> > memory for the bitmap. Or dozens of 32k split bitmap will be used,
> > this version limit the bitmap count to 32, it means we can use at most
> > 32*32 kB for the bitmap, which can cover 128GB for RAM. We can increase
> the bitmap count limit to a larger value if 32 is not big enough.
>=20
> OK, so it tries to allocate a large bitmap.  But, if it fails, it will tr=
y to work with a
> smaller bitmap.  Correct?
>=20
Yes.

> So, what's the _worst_ case?  It sounds like it is even worse than I was
> positing.
>=20

Only a  32KB bitmap can be allocated, and there are a huge amount of low or=
der (<3) free pages is the worst case.=20

> >> That's an awfully inefficient way of doing it.  This patch
> >> essentially changed the data structure without changing the algorithm =
to
> populate it.
> >>
> >> Please change the *algorithm* to use the new data structure efficientl=
y.
> >>  Such a change would only do a single pass through each freelist, and
> >> would choose whether to use the extent-based (pfn -> range) or
> >> bitmap-based approach based on the contents of the free lists.
> >
> > Save the free page info to a raw bitmap first and then process the raw
> > bitmap to get the proper ' extent-based ' and  'bitmap-based' is the
> > most efficient way I can come up with to save the virtio data transmiss=
ion.
> Do you have some better idea?
>=20
> That's kinda my point.  This patch *does* processing to try to pack the
> bitmaps full of pages from the various pfn ranges.  It's a form of proces=
sing
> that gets *REALLY*, *REALLY* bad in some (admittedly obscure) cases.
>=20
> Let's not pretend that making an essentially unlimited number of passes o=
ver
> the free lists is not processing.
>=20
> 1. Allocate as large of a bitmap as you can. (what you already do) 2. Ite=
rate
> from the largest freelist order.  Store those pages in the
>    bitmap.
> 3. If you can no longer fit pages in the bitmap, return the list that
>    you have.
> 4. Make an approximation about where the bitmap does not make any more,
>    and fall back to listing individual PFNs.  This would make sens, for
>    instance in a large zone with very few free order-0 pages left.
>=20
Sounds good.  Should we ignore some of the order-0 pages in step 4 if the b=
itmap is full?
Or should retry to get a complete list of order-0 pages?

>=20
> > It seems the benefit we get for this feature is not as big as that in f=
ast
> balloon inflating/deflating.
> >>
> >> You should not be using get_max_pfn().  Any patch set that continues
> >> to use it is not likely to be using a proper algorithm.
> >
> > Do you have any suggestion about how to avoid it?
>=20
> Yes: get the pfns from the page free lists alone.  Don't derive them from=
 the
> pfn limits of the system or zones.

The ' get_max_pfn()' can be avoid in this patch, but I think we can't avoid=
 it completely.
We need it as a hint for allocating a proper size bitmap. No?

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
