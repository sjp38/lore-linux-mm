Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CEDBB6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 23:57:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 194so3634651pgd.7
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 20:57:03 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 10si10474720pgg.262.2017.01.17.20.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jan 2017 20:57:02 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Date: Wed, 18 Jan 2017 04:56:58 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C355672@shsmsx102.ccr.corp.intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
 <20170117211131-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170117211131-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

> > -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > -	virtqueue_kick(vq);
> > +static void do_set_resp_bitmap(struct virtio_balloon *vb,
> > +		unsigned long base_pfn, int pages)
> >
> > -	/* When host has read buffer, this completes via balloon_ack */
> > -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > +{
> > +	__le64 *range =3D vb->resp_data + vb->resp_pos;
> >
> > +	if (pages > (1 << VIRTIO_BALLOON_NR_PFN_BITS)) {
> > +		/* when the length field can't contain pages, set it to 0 to
>=20
> /*
>  * Multi-line
>  * comments
>  * should look like this.
>  */
>=20
> Also, pls start sentences with an upper-case letter.
>=20

Sorry for that.

> > +		 * indicate the actual length is in the next __le64;
> > +		 */
>=20
> This is part of the interface so should be documented as such.
>=20
> > +		*range =3D cpu_to_le64((base_pfn <<
> > +				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
> > +		*(range + 1) =3D cpu_to_le64(pages);
> > +		vb->resp_pos +=3D 2;
>=20
> Pls use structs for this kind of stuff.

I am not sure if you mean to use=20

struct  range {
 	__le64 pfn: 52;
	__le64 nr_page: 12
}
Instead of the shift operation?

I didn't use this way because I don't want to include 'virtio-balloon.h' in=
 page_alloc.c,
or copy the define of this struct in page_alloc.c

Thanks!
Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
