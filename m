Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 451116B0069
	for <linux-mm@kvack.org>; Sun,  4 Dec 2016 08:13:28 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 83so469720987pfx.1
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 05:13:28 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r17si11318798pgr.219.2016.12.04.05.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 05:13:27 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v5 5/5] virtio-balloon: tell host vm's unused
 page info
Date: Sun, 4 Dec 2016 13:13:23 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A12D814@shsmsx102.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <1480495397-23225-6-git-send-email-liang.z.li@intel.com>
 <438dd41a-fdf1-2a77-ef9c-8c103f492b2f@intel.com>
In-Reply-To: <438dd41a-fdf1-2a77-ef9c-8c103f492b2f@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> On 11/30/2016 12:43 AM, Liang Li wrote:
> > +static void send_unused_pages_info(struct virtio_balloon *vb,
> > +				unsigned long req_id)
> > +{
> > +	struct scatterlist sg_in;
> > +	unsigned long pos =3D 0;
> > +	struct virtqueue *vq =3D vb->req_vq;
> > +	struct virtio_balloon_resp_hdr *hdr =3D vb->resp_hdr;
> > +	int ret, order;
> > +
> > +	mutex_lock(&vb->balloon_lock);
> > +
> > +	for (order =3D MAX_ORDER - 1; order >=3D 0; order--) {
>=20
> I scratched my head for a bit on this one.  Why are you walking over orde=
rs,
> *then* zones.  I *think* you're doing it because you can efficiently fill=
 the
> bitmaps at a given order for all zones, then move to a new bitmap.  But, =
it
> would be interesting to document this.
>=20

Yes, use the order is somewhat strange, but it's helpful to keep the API si=
mple.=20
Do you think it's acceptable?

> > +		pos =3D 0;
> > +		ret =3D get_unused_pages(vb->resp_data,
> > +			 vb->resp_buf_size / sizeof(unsigned long),
> > +			 order, &pos);
>=20
> FWIW, get_unsued_pages() is a pretty bad name.  "get" usually implies
> bumping reference counts or consuming something.  You're just "recording"
> or "marking" them.
>=20

Will change to mark_unused_pages().

> > +		if (ret =3D=3D -ENOSPC) {
> > +			void *new_resp_data;
> > +
> > +			new_resp_data =3D kmalloc(2 * vb->resp_buf_size,
> > +						GFP_KERNEL);
> > +			if (new_resp_data) {
> > +				kfree(vb->resp_data);
> > +				vb->resp_data =3D new_resp_data;
> > +				vb->resp_buf_size *=3D 2;
>=20
> What happens to the data in ->resp_data at this point?  Doesn't this just
> throw it away?
>=20

Yes, so we should make sure the data in resp_data is not inuse.

> ...
> > +struct page_info_item {
> > +	__le64 start_pfn : 52; /* start pfn for the bitmap */
> > +	__le64 page_shift : 6; /* page shift width, in bytes */
> > +	__le64 bmap_len : 6;  /* bitmap length, in bytes */ };
>=20
> Is 'bmap_len' too short?  a 64-byte buffer is a bit tiny.  Right?
>=20

Currently, we just use the 8 bytes and 0 bytes bitmap, should we support mo=
re than 64 bytes?

> > +static int  mark_unused_pages(struct zone *zone,
> > +		unsigned long *unused_pages, unsigned long size,
> > +		int order, unsigned long *pos)
> > +{
> > +	unsigned long pfn, flags;
> > +	unsigned int t;
> > +	struct list_head *curr;
> > +	struct page_info_item *info;
> > +
> > +	if (zone_is_empty(zone))
> > +		return 0;
> > +
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +
> > +	if (*pos + zone->free_area[order].nr_free > size)
> > +		return -ENOSPC;
>=20
> Urg, so this won't partially fill?  So, what the nr_free pages limit wher=
e we no
> longer fit in the kmalloc()'d buffer where this simply won't work?
>=20

Yes.  My initial implementation is partially fill, it's better for the wors=
t case.
I thought the above code is more efficient for most case ...
Do you think partially fill the bitmap is better?
=20
> > +	for (t =3D 0; t < MIGRATE_TYPES; t++) {
> > +		list_for_each(curr, &zone->free_area[order].free_list[t]) {
> > +			pfn =3D page_to_pfn(list_entry(curr, struct page, lru));
> > +			info =3D (struct page_info_item *)(unused_pages +
> *pos);
> > +			info->start_pfn =3D pfn;
> > +			info->page_shift =3D order + PAGE_SHIFT;
> > +			*pos +=3D 1;
> > +		}
> > +	}
>=20
> Do we need to fill in ->bmap_len here?

For integrity, the bmap_len should be filled, will add.
Omit this step just because QEMU assume the ->bmp_len is 0 and ignore this =
field.

Thanks for your comment!

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
