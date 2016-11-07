Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB1D76B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2016 22:38:02 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so43157544pfy.2
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 19:38:02 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id xc5si24190467pab.198.2016.11.06.19.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Nov 2016 19:38:01 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused
 page info
Date: Mon, 7 Nov 2016 03:37:58 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A106DAA@shsmsx102.ccr.corp.intel.com>
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
 <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
 <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
In-Reply-To: <b25eac6e-3744-3874-93a8-02f814549adf@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "mst@redhat.com" <mst@redhat.com>
Cc: "pbonzini@redhat.com" <pbonzini@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>

> Please squish this and patch 5 together.  It makes no sense to separate t=
hem.
>=20

OK.

> > +static void send_unused_pages_info(struct virtio_balloon *vb,
> > +				unsigned long req_id)
> > +{
> > +	struct scatterlist sg_in;
> > +	unsigned long pfn =3D 0, bmap_len, pfn_limit, last_pfn, nr_pfn;
> > +	struct virtqueue *vq =3D vb->req_vq;
> > +	struct virtio_balloon_resp_hdr *hdr =3D vb->resp_hdr;
> > +	int ret =3D 1, used_nr_bmap =3D 0, i;
> > +
> > +	if (virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_PAGE_BITMAP) &&
> > +		vb->nr_page_bmap =3D=3D 1)
> > +		extend_page_bitmap(vb);
> > +
> > +	pfn_limit =3D PFNS_PER_BMAP * vb->nr_page_bmap;
> > +	mutex_lock(&vb->balloon_lock);
> > +	last_pfn =3D get_max_pfn();
> > +
> > +	while (ret) {
> > +		clear_page_bitmap(vb);
> > +		ret =3D get_unused_pages(pfn, pfn + pfn_limit, vb-
> >page_bitmap,
> > +			 PFNS_PER_BMAP, vb->nr_page_bmap);
>=20
> This changed the underlying data structure without changing the way that
> the structure is populated.
>=20
> This algorithm picks a "PFNS_PER_BMAP * vb->nr_page_bmap"-sized set of
> pfns, allocates a bitmap for them, the loops through all zones looking fo=
r
> pages in any free list that are in that range.
>=20
> Unpacking all the indirection, it looks like this:
>=20
> for (pfn =3D 0; pfn < get_max_pfn(); pfn +=3D BITMAP_SIZE_IN_PFNS)
> 	for_each_populated_zone(zone)
> 		for_each_migratetype_order(order, t)
> 			list_for_each(..., &zone->free_area[order])...
>=20
> Let's say we do a 32k bitmap that can hold ~1M pages.  That's 4GB of RAM.
> On a 1TB system, that's 256 passes through the top-level loop.
> The bottom-level lists have tens of thousands of pages in them, even on m=
y
> laptop.  Only 1/256 of these pages will get consumed in a given pass.
>=20
Your description is not exactly.
A 32k bitmap is used only when there is few free memory left in the system =
and when=20
the extend_page_bitmap() failed to allocate more memory for the bitmap. Or =
dozens of=20
32k split bitmap will be used, this version limit the bitmap count to 32, i=
t means we can use
at most 32*32 kB for the bitmap, which can cover 128GB for RAM. We can incr=
ease the bitmap
count limit to a larger value if 32 is not big enough.

> That's an awfully inefficient way of doing it.  This patch essentially ch=
anged
> the data structure without changing the algorithm to populate it.
>=20
> Please change the *algorithm* to use the new data structure efficiently.
>  Such a change would only do a single pass through each freelist, and wou=
ld
> choose whether to use the extent-based (pfn -> range) or bitmap-based
> approach based on the contents of the free lists.

Save the free page info to a raw bitmap first and then process the raw bitm=
ap to
get the proper ' extent-based ' and  'bitmap-based' is the most efficient w=
ay I can=20
come up with to save the virtio data transmission.  Do you have some better=
 idea?


In the QEMU, no matter how we encode the bitmap, the raw format bitmap will=
 be
used in the end.  But what I did in this version is:
   kernel: get the raw bitmap  --> encode the bitmap
   QEMU: decode the bitmap --> get the raw bitmap

Is it worth to do this kind of job here? we can save the virtio data transm=
ission, but at the
same time, we did extra work.

It seems the benefit we get for this feature is not as big as that in fast =
balloon inflating/deflating.
>=20
> You should not be using get_max_pfn().  Any patch set that continues to u=
se
> it is not likely to be using a proper algorithm.

Do you have any suggestion about how to avoid it?

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
