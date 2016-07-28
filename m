Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9F06B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:06:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o124so30746930pfg.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:06:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q8si9790323pfk.31.2016.07.27.20.06.40
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 20:06:40 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Date: Thu, 28 Jul 2016 03:06:37 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213E1D@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <20160728002243-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728002243-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> > + * VIRTIO_BALLOON_PFNS_LIMIT is used to limit the size of page bitmap
> > + * to prevent a very large page bitmap, there are two reasons for this=
:
> > + * 1) to save memory.
> > + * 2) allocate a large bitmap may fail.
> > + *
> > + * The actual limit of pfn is determined by:
> > + * pfn_limit =3D min(max_pfn, VIRTIO_BALLOON_PFNS_LIMIT);
> > + *
> > + * If system has more pages than VIRTIO_BALLOON_PFNS_LIMIT, we will
> > +scan
> > + * the page list and send the PFNs with several times. To reduce the
> > + * overhead of scanning the page list. VIRTIO_BALLOON_PFNS_LIMIT
> > +should
> > + * be set with a value which can cover most cases.
>=20
> So what if it covers 1/32 of the memory? We'll do 32 exits and not 1, sti=
ll not a
> big deal for a big guest.
>=20

The issue here is the overhead is too high for scanning the page list for 3=
2 times.
Limit the page bitmap size to a fixed value is better for a big guest?

> > + */
> > +#define VIRTIO_BALLOON_PFNS_LIMIT ((32 * (1ULL << 30)) >>
> PAGE_SHIFT)
> > +/* 32GB */
>=20
> I already said this with a smaller limit.
>=20
> 	2<< 30  is 2G but that is not a useful comment.
> 	pls explain what is the reason for this selection.
>=20
> Still applies here.
>=20

I will add the comment for this.

> > -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> > +	if (virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_PAGE_BITMAP)) {
> > +		struct balloon_bmap_hdr *hdr =3D vb->bmap_hdr;
> > +		unsigned long bmap_len;
> > +
> > +		/* cmd and req_id are not used here, set them to 0 */
> > +		hdr->cmd =3D cpu_to_virtio16(vb->vdev, 0);
> > +		hdr->page_shift =3D cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> > +		hdr->reserved =3D cpu_to_virtio16(vb->vdev, 0);
> > +		hdr->req_id =3D cpu_to_virtio64(vb->vdev, 0);
>=20
> no need to swap 0, just fill it in. in fact you allocated all 0s so no ne=
ed to touch
> these fields at all.
>=20

Will change in v3.

> > @@ -489,7 +612,7 @@ static int virtballoon_migratepage(struct
> > balloon_dev_info *vb_dev_info,  static int virtballoon_probe(struct
> > virtio_device *vdev)  {
> >  	struct virtio_balloon *vb;
> > -	int err;
> > +	int err, hdr_len;
> >
> >  	if (!vdev->config->get) {
> >  		dev_err(&vdev->dev, "%s failure: config access disabled\n",
> @@
> > -508,6 +631,18 @@ static int virtballoon_probe(struct virtio_device *vd=
ev)
> >  	spin_lock_init(&vb->stop_update_lock);
> >  	vb->stop_update =3D false;
> >  	vb->num_pages =3D 0;
> > +	vb->pfn_limit =3D VIRTIO_BALLOON_PFNS_LIMIT;
> > +	vb->pfn_limit =3D min(vb->pfn_limit, get_max_pfn());
> > +	vb->bmap_len =3D ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
>=20
> What are these 2 longs in aid of?
>=20
The rounddown(vb->start_pfn,  BITS_PER_LONG) and roundup(vb->end_pfn, BITS_=
PER_LONG)=20
may cause (vb->end_pfn - vb->start_pfn) > vb->pfn_limit, so we need extra s=
pace to save the
bitmap for this case. 2 longs are enough.

> > +	hdr_len =3D sizeof(struct balloon_bmap_hdr);
> > +	vb->bmap_hdr =3D kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
>=20
> So it can go up to 1MByte but adding header size etc you need a higher or=
der
> allocation. This is a waste, there is no need to have a power of two allo=
cation.
> Start from the other side. Say "I want to allocate 32KBytes for the bitma=
p".
> Subtract the header and you get bitmap size.
> Calculate the pfn limit from there.
>=20

Indeed, will change. Thanks a lot!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
