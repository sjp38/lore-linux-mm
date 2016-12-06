Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1F76B0069
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 23:47:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a8so533791496pfg.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 20:47:34 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t1si17629552plb.188.2016.12.05.20.47.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 20:47:33 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH kernel v5 5/5] virtio-balloon: tell host vm's unused
 page info
Date: Tue, 6 Dec 2016 04:47:27 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A12F831@shsmsx102.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <1480495397-23225-6-git-send-email-liang.z.li@intel.com>
 <438dd41a-fdf1-2a77-ef9c-8c103f492b2f@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A12D814@shsmsx102.ccr.corp.intel.com>
 <70ece7a5-348b-2eb9-c40a-f21b08df042c@intel.com>
In-Reply-To: <70ece7a5-348b-2eb9-c40a-f21b08df042c@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "mst@redhat.com" <mst@redhat.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> >>> +	mutex_lock(&vb->balloon_lock);
> >>> +
> >>> +	for (order =3D MAX_ORDER - 1; order >=3D 0; order--) {
> >>
> >> I scratched my head for a bit on this one.  Why are you walking over
> >> orders,
> >> *then* zones.  I *think* you're doing it because you can efficiently
> >> fill the bitmaps at a given order for all zones, then move to a new
> >> bitmap.  But, it would be interesting to document this.
> >
> > Yes, use the order is somewhat strange, but it's helpful to keep the AP=
I simple.
> > Do you think it's acceptable?
>=20
> Yeah, it's fine.  Just comment it, please.
>=20
Good!

> >>> +		if (ret =3D=3D -ENOSPC) {
> >>> +			void *new_resp_data;
> >>> +
> >>> +			new_resp_data =3D kmalloc(2 * vb->resp_buf_size,
> >>> +						GFP_KERNEL);
> >>> +			if (new_resp_data) {
> >>> +				kfree(vb->resp_data);
> >>> +				vb->resp_data =3D new_resp_data;
> >>> +				vb->resp_buf_size *=3D 2;
> >>
> >> What happens to the data in ->resp_data at this point?  Doesn't this
> >> just throw it away?
> >
> > Yes, so we should make sure the data in resp_data is not inuse.
>=20
> But doesn't it have valid data that we just collected and haven't told th=
e
> hypervisor about yet?  Aren't we throwing away good data that cost us
> something to collect?

Indeed.  Some filled data may exist for the previous zone. Should we
change the API to=20
'int get_unused_pages(unsigned long *unused_pages, unsigned long size,
		int order, unsigned long *pos, struct zone *zone)' ?

then we can use the 'zone' to record the zone to retry and not discard the
filled data.

> >> ...
> >>> +struct page_info_item {
> >>> +	__le64 start_pfn : 52; /* start pfn for the bitmap */
> >>> +	__le64 page_shift : 6; /* page shift width, in bytes */
>=20
> What does a page_shift "in bytes" mean? :)

Obviously, you know. :o
I will try to make it clear.

>=20
> >>> +	__le64 bmap_len : 6;  /* bitmap length, in bytes */ };
> >>
> >> Is 'bmap_len' too short?  a 64-byte buffer is a bit tiny.  Right?
> >
> > Currently, we just use the 8 bytes and 0 bytes bitmap, should we suppor=
t
> more than 64 bytes?
>=20
> It just means that with this format, you end up wasting at least ~1/8th o=
f the
> space with metadata.  That's a bit unfortunate, but I guess it's not fata=
l.
>=20
> I'd definitely call it out in the patch description and make sure other f=
olks take
> a look at it.

OK.

>=20
> There's a somewhat easy fix, but that would make the qemu implementation
> more complicated: You could just have bmap_len=3D=3D0x3f imply that there=
's
> another field that contains an extended bitmap length for when you need l=
ong
> bitmaps.
>=20
> But, as you note, there's no need for it, so it's a matter of trading the=
 extra
> complexity versus the desire to not habing to change the ABI again for lo=
nger
> (hopefully).
>=20

Your suggestion still works without changing the current code, just reserve
 ' bmap_len=3D=3D0x3f' for future extension, and it's not used by the curre=
nt code.

> >>> +static int  mark_unused_pages(struct zone *zone,
> >>> +		unsigned long *unused_pages, unsigned long size,
> >>> +		int order, unsigned long *pos)
> >>> +{
> >>> +	unsigned long pfn, flags;
> >>> +	unsigned int t;
> >>> +	struct list_head *curr;
> >>> +	struct page_info_item *info;
> >>> +
> >>> +	if (zone_is_empty(zone))
> >>> +		return 0;
> >>> +
> >>> +	spin_lock_irqsave(&zone->lock, flags);
> >>> +
> >>> +	if (*pos + zone->free_area[order].nr_free > size)
> >>> +		return -ENOSPC;
> >>
> >> Urg, so this won't partially fill?  So, what the nr_free pages limit
> >> where we no longer fit in the kmalloc()'d buffer where this simply won=
't
> work?
> >
> > Yes.  My initial implementation is partially fill, it's better for the =
worst case.
> > I thought the above code is more efficient for most case ...
> > Do you think partially fill the bitmap is better?
>=20
> Could you please answer the question I asked?
>=20

For your question:
---------------------------------------------------------------------------=
----------------------------
>So, what the nr_free pages limit where we no longer fit in the kmalloc()'d=
 buffer
> where this simply won't work?
---------------------------------------------------------------------------=
---------------------------
No, if the buffer is not big enough to save 'nr_free'  pages, get_unused_pa=
ges() will return
'-ENOSPC', and the following code will try to allocate a 2x times size buff=
er for retrying,
until the proper size buffer is allocated. The current order will not be sk=
ipped unless the
buffer allocation failed.

> Because if you don't get this right, it could mean that there are system =
that
> simply *fail* here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
