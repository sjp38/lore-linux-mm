Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AEFAD6B0069
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 20:44:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id y143so39490063pfb.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 17:44:42 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 127si1904606pgi.128.2017.01.18.17.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 17:44:41 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate
 process
Date: Thu, 19 Jan 2017 01:44:36 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3C3578BF@shsmsx102.ccr.corp.intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
 <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
 <20170117211131-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E3C355672@shsmsx102.ccr.corp.intel.com>
 <20170118172401-mutt-send-email-mst@kernel.org>
In-Reply-To: <20170118172401-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "david@redhat.com" <david@redhat.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>

> On Wed, Jan 18, 2017 at 04:56:58AM +0000, Li, Liang Z wrote:
> > > > -	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
> > > > -	virtqueue_kick(vq);
> > > > +static void do_set_resp_bitmap(struct virtio_balloon *vb,
> > > > +		unsigned long base_pfn, int pages)
> > > >
> > > > -	/* When host has read buffer, this completes via balloon_ack */
> > > > -	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
> > > > +{
> > > > +	__le64 *range =3D vb->resp_data + vb->resp_pos;
> > > >
> > > > +	if (pages > (1 << VIRTIO_BALLOON_NR_PFN_BITS)) {
> > > > +		/* when the length field can't contain pages, set it to 0 to
> > >
> > > /*
> > >  * Multi-line
> > >  * comments
> > >  * should look like this.
> > >  */
> > >
> > > Also, pls start sentences with an upper-case letter.
> > >
> >
> > Sorry for that.
> >
> > > > +		 * indicate the actual length is in the next __le64;
> > > > +		 */
> > >
> > > This is part of the interface so should be documented as such.
> > >
> > > > +		*range =3D cpu_to_le64((base_pfn <<
> > > > +				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
> > > > +		*(range + 1) =3D cpu_to_le64(pages);
> > > > +		vb->resp_pos +=3D 2;
> > >
> > > Pls use structs for this kind of stuff.
> >
> > I am not sure if you mean to use
> >
> > struct  range {
> >  	__le64 pfn: 52;
> > 	__le64 nr_page: 12
> > }
> > Instead of the shift operation?
>=20
> Not just that. You want to add a pages field as well.
>=20

pages field? Could you give more hints?

> Generally describe the format in the header in some way so host and guest
> can easily stay in sync.

'VIRTIO_BALLOON_NR_PFN_BITS' is for this purpose and it will be passed to t=
he
related function in page_alloc.c as a parameter.

Thanks!
Liang
> All the pointer math and void * means we get zero type safety and I'm not
> happy about it.
>=20
> It's not good that virtio format seeps out to page_alloc anyway.
> If unavoidable it is not a good idea to try to hide this fact, people wil=
l assume
> they can change the format at will.
>=20
> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
