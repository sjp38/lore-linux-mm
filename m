Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 283C66B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 05:49:17 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so135279pfi.4
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 02:49:17 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b123si19899531pgc.109.2016.10.25.02.49.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 02:49:16 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [RESEND PATCH v3 kernel 4/7] virtio-balloon: speed up
 inflate/deflate process
Date: Tue, 25 Oct 2016 09:46:33 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A0FBCDC@shsmsx102.ccr.corp.intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
 <1477031080-12616-5-git-send-email-liang.z.li@intel.com>
 <20161025091821-mutt-send-email-mst@kernel.org>
In-Reply-To: <20161025091821-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>

> > +static inline void init_pfn_range(struct virtio_balloon *vb) {
> > +	vb->min_pfn =3D ULONG_MAX;
> > +	vb->max_pfn =3D 0;
> > +}
> > +
> > +static inline void update_pfn_range(struct virtio_balloon *vb,
> > +				 struct page *page)
> > +{
> > +	unsigned long balloon_pfn =3D page_to_balloon_pfn(page);
> > +
> > +	if (balloon_pfn < vb->min_pfn)
> > +		vb->min_pfn =3D balloon_pfn;
> > +	if (balloon_pfn > vb->max_pfn)
> > +		vb->max_pfn =3D balloon_pfn;
> > +}
> > +
>=20
> rename to hint these are all bitmap related.

Will change in v4.

>=20
>=20
> >  static void tell_host(struct virtio_balloon *vb, struct virtqueue
> > *vq)  {
> > -	struct scatterlist sg;
> > -	unsigned int len;
> > +	struct scatterlist sg, sg2[BALLOON_BMAP_COUNT + 1];
> > +	unsigned int len, i;
> > +
> > +	if (virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_PAGE_BITMAP)) {
> > +		struct balloon_bmap_hdr *hdr =3D vb->bmap_hdr;
> > +		unsigned long bmap_len;
> > +		int nr_pfn, nr_used_bmap, nr_buf;
> > +
> > +		nr_pfn =3D vb->end_pfn - vb->start_pfn + 1;
> > +		nr_pfn =3D roundup(nr_pfn, BITS_PER_LONG);
> > +		nr_used_bmap =3D nr_pfn / PFNS_PER_BMAP;
> > +		bmap_len =3D nr_pfn / BITS_PER_BYTE;
> > +		nr_buf =3D nr_used_bmap + 1;
> > +
> > +		/* cmd, reserved and req_id are init to 0, unused here */
> > +		hdr->page_shift =3D cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> > +		hdr->start_pfn =3D cpu_to_virtio64(vb->vdev, vb->start_pfn);
> > +		hdr->bmap_len =3D cpu_to_virtio64(vb->vdev, bmap_len);
> > +		sg_init_table(sg2, nr_buf);
> > +		sg_set_buf(&sg2[0], hdr, sizeof(struct balloon_bmap_hdr));
> > +		for (i =3D 0; i < nr_used_bmap; i++) {
> > +			unsigned int  buf_len =3D BALLOON_BMAP_SIZE;
> > +
> > +			if (i + 1 =3D=3D nr_used_bmap)
> > +				buf_len =3D bmap_len - BALLOON_BMAP_SIZE
> * i;
> > +			sg_set_buf(&sg2[i + 1], vb->page_bitmap[i],
> buf_len);
> > +		}
> >
> > -	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
> > +		while (vq->num_free < nr_buf)
> > +			msleep(2);
>=20
>=20
> What's going on here? Who is expected to update num_free?
>=20

I just want to wait until the vq have enough space to write the bitmap, I t=
hought qemu
side will update the vq->num_free, is it wrong?

>=20
>=20
> > +		if (virtqueue_add_outbuf(vq, sg2, nr_buf, vb, GFP_KERNEL)
> =3D=3D 0)
> > +			virtqueue_kick(vq);
> >
> > -	/* We should always be able to add one buffer to an empty queue.
> */
> > -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > -	virtqueue_kick(vq);
> > +	} else {
> > +		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb-
> >num_pfns);
> > +
> > +		/* We should always be able to add one buffer to an empty
> > +		 * queue. */
>=20
> Pls use a multiple comment style consistent with kernel coding style.

Will change in next version.

>=20
> > +		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > +		virtqueue_kick(vq);
> > +	}
> >
> >  	/* When host has read buffer, this completes via balloon_ack */
> >  	wait_event(vb->acked, virtqueue_get_buf(vq, &len)); @@ -138,13
> > +199,93 @@ static void set_page_pfns(struct virtio_balloon *vb,
> >  					  page_to_balloon_pfn(page) + i);  }
> >
> > -static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
> > +static void extend_page_bitmap(struct virtio_balloon *vb) {
> > +	int i;
> > +	unsigned long bmap_len, bmap_count;
> > +
> > +	bmap_len =3D ALIGN(get_max_pfn(), BITS_PER_LONG) /
> BITS_PER_BYTE;
> > +	bmap_count =3D bmap_len / BALLOON_BMAP_SIZE;
> > +	if (bmap_len % BALLOON_BMAP_SIZE)
> > +		bmap_count++;
> > +	if (bmap_count > BALLOON_BMAP_COUNT)
> > +		bmap_count =3D BALLOON_BMAP_COUNT;
> > +
>=20
> This is doing simple things in tricky ways.
> Please use macros such as ALIGN and max instead of if.
>=20

Will change.

>=20
> > +	for (i =3D 1; i < bmap_count; i++) {
>=20
> why 1?

In probe stage, already allocated one bitmap.

>=20
> > +		vb->page_bitmap[i] =3D kmalloc(BALLOON_BMAP_SIZE,
> GFP_ATOMIC);
>=20
> why GFP_ATOMIC?

Yes, GFP_ATOMIC is not necessary.

> and what will free the previous buffer?

The previous buffer will not be freed.

>=20
>=20
> > +		if (vb->page_bitmap[i])
> > +			vb->nr_page_bmap++;
> > +		else
> > +			break;
>=20
> and what will happen then?

I plan to use the previous allocated buffer to save the bitmap, need more c=
ode for kmalloc failure?

> > -static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
> > +static unsigned int leak_balloon(struct virtio_balloon *vb, size_t num=
,
> > +				bool use_bmap)
>=20
> this is just a feature bit - why not get it internally?

Indeed.

> > @@ -218,8 +374,14 @@ static unsigned leak_balloon(struct virtio_balloon
> *vb, size_t num)
> >  	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
> >  	 * is true, we *have* to do it in this order
> >  	 */
> > -	if (vb->num_pfns !=3D 0)
> > -		tell_host(vb, vb->deflate_vq);
> > +	if (vb->num_pfns !=3D 0) {
> > +		if (use_bmap)
> > +			set_page_bitmap(vb, &pages, vb->deflate_vq);
> > +		else
> > +			tell_host(vb, vb->deflate_vq);
> > +
> > +		release_pages_balloon(vb, &pages);
> > +	}
> >  	release_pages_balloon(vb, &pages);
> >  	mutex_unlock(&vb->balloon_lock);
> >  	return num_freed_pages;
> > @@ -354,13 +516,15 @@ static int virtballoon_oom_notify(struct
> notifier_block *self,
> >  	struct virtio_balloon *vb;
> >  	unsigned long *freed;
> >  	unsigned num_freed_pages;
> > +	bool use_bmap;
> >
> >  	vb =3D container_of(self, struct virtio_balloon, nb);
> >  	if (!virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
> >  		return NOTIFY_OK;
> >
> >  	freed =3D parm;
> > -	num_freed_pages =3D leak_balloon(vb, oom_pages);
> > +	use_bmap =3D virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_PAGE_BITMAP);
> > +	num_freed_pages =3D leak_balloon(vb, oom_pages, use_bmap);
> >  	update_balloon_size(vb);
> >  	*freed +=3D num_freed_pages;
> >
> > @@ -380,15 +544,19 @@ static void update_balloon_size_func(struct
> > work_struct *work)  {
> >  	struct virtio_balloon *vb;
> >  	s64 diff;
> > +	bool use_bmap;
> >
> >  	vb =3D container_of(work, struct virtio_balloon,
> >  			  update_balloon_size_work);
> >  	diff =3D towards_target(vb);
> > +	use_bmap =3D virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_PAGE_BITMAP);
> > +	if (use_bmap && diff && vb->nr_page_bmap =3D=3D 1)
> > +		extend_page_bitmap(vb);
>=20
> So you allocate it on first use, then keep it around until device remove?
> Seems ugly.

Yes, this version behave like this.

> Needs comments explaining the motivation for this.
> Can't we free it immediately when it becomes unused?
>=20

Yes, it can be freed immediately, will change in v4.

Thanks for your time and your valuable comments! I will send out the v4 soo=
n.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
