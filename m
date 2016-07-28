Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7225A6B0260
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:51:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h186so40712222pfg.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:51:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id to7si11023121pac.282.2016.07.28.00.51.04
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 00:51:04 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 7/7] virtio-balloon: tell host vm's free page
 info
Date: Thu, 28 Jul 2016 07:50:52 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E042141EE@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-8-git-send-email-liang.z.li@intel.com>
 <20160728004606-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728004606-mutt-send-email-mst@kernel.org>
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

> >  }
> >
> > +static void update_free_pages_stats(struct virtio_balloon *vb,
>=20
> why _stats?

Will change.

> > +	max_pfn =3D get_max_pfn();
> > +	mutex_lock(&vb->balloon_lock);
> > +	while (pfn < max_pfn) {
> > +		memset(vb->page_bitmap, 0, vb->bmap_len);
> > +		ret =3D get_free_pages(pfn, pfn + vb->pfn_limit,
> > +			vb->page_bitmap, vb->bmap_len * BITS_PER_BYTE);
> > +		hdr->cmd =3D cpu_to_virtio16(vb->vdev,
> BALLOON_GET_FREE_PAGES);
> > +		hdr->page_shift =3D cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
> > +		hdr->req_id =3D cpu_to_virtio64(vb->vdev, req_id);
> > +		hdr->start_pfn =3D cpu_to_virtio64(vb->vdev, pfn);
> > +		bmap_len =3D vb->pfn_limit / BITS_PER_BYTE;
> > +		if (!ret) {
> > +			hdr->flag =3D cpu_to_virtio16(vb->vdev,
> > +
> 	BALLOON_FLAG_DONE);
> > +			if (pfn + vb->pfn_limit > max_pfn)
> > +				bmap_len =3D (max_pfn - pfn) /
> BITS_PER_BYTE;
> > +		} else
> > +			hdr->flag =3D cpu_to_virtio16(vb->vdev,
> > +
> 	BALLOON_FLAG_CONT);
> > +		hdr->bmap_len =3D cpu_to_virtio64(vb->vdev, bmap_len);
> > +		sg_init_one(&sg_out, hdr,
> > +			 sizeof(struct balloon_bmap_hdr) + bmap_len);
>=20
> Wait a second. This adds the same buffer multiple times in a loop.
> We will overwrite the buffer without waiting for hypervisor to process it=
.
> What did I miss?

I am no quite sure about this part, I though the virtqueue_kick(vq) will pr=
event
the buffer from overwrite, I realized it's wrong.

> > +
> > +		virtqueue_add_outbuf(vq, &sg_out, 1, vb, GFP_KERNEL);
>=20
> this can fail. you want to maybe make sure vq has enough space before you
> use it or check error and wait.
>=20
> > +		virtqueue_kick(vq);
>=20
> why kick here within loop? wait until done. in fact kick outside lock is =
better
> for smp.

I will change this part in v3.

>=20
> > +		pfn +=3D vb->pfn_limit;
> > +	static const char * const names[] =3D { "inflate", "deflate", "stats"=
,
> > +						 "misc" };
> >  	int err, nvqs;
> >
> >  	/*
> >  	 * We expect two virtqueues: inflate and deflate, and
> >  	 * optionally stat.
> >  	 */
> > -	nvqs =3D virtio_has_feature(vb->vdev,
> VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
> > +	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
> > +		nvqs =3D 4;
>=20
> Does misc vq depend on stats vq feature then? if yes please validate that=
.

Yes, what's you mean by 'validate' that?

>=20
>=20
> > +	else
> > +		nvqs =3D virtio_has_feature(vb->vdev,
> > +					  VIRTIO_BALLOON_F_STATS_VQ) ? 3 :
> 2;
>=20
> Replace that ? with else too pls.

Will change.

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
