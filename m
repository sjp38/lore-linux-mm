Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36E9B6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 21:08:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so78077507pac.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 18:08:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id v8si15180075pac.107.2016.07.28.18.08.15
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 18:08:16 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 repost 4/7] virtio-balloon: speed up
 inflate/deflate process
Date: Fri, 29 Jul 2016 01:08:09 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04214C5C@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com> <20160728003644-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04213E5D@shsmsx102.ccr.corp.intel.com>
 <20160728221533.GA789@redhat.com>
In-Reply-To: <20160728221533.GA789@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> > > On Wed, Jul 27, 2016 at 09:03:21AM -0700, Dave Hansen wrote:
> > > > On 07/26/2016 06:23 PM, Liang Li wrote:
> > > > > +	vb->pfn_limit =3D VIRTIO_BALLOON_PFNS_LIMIT;
> > > > > +	vb->pfn_limit =3D min(vb->pfn_limit, get_max_pfn());
> > > > > +	vb->bmap_len =3D ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > > > > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > > > > +	hdr_len =3D sizeof(struct balloon_bmap_hdr);
> > > > > +	vb->bmap_hdr =3D kzalloc(hdr_len + vb->bmap_len,
> GFP_KERNEL);
> > > >
> > > > This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.
> > > > How big was the pfn buffer before?
> > >
> > >
> > > Yes I would limit this to 1G memory in a go, will result in a 32KByte=
 bitmap.
> > >
> > > --
> > > MST
> >
> > Limit to 1G is bad for the performance, I sent you the test result seve=
ral
> weeks ago.
> >
> > Paste it bellow:
> > ----------------------------------------------------------------------
> > --------------------------------------------------
> > About the size of page bitmap, I have test the performance of filling
> > the balloon to 15GB with a  16GB RAM VM.
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > 32K Byte (cover 1GB of RAM)
> >
> > Time spends on inflating: 2031ms
> > ---------------------------------------------
> > 64K Byte (cover 2GB of RAM)
> >
> > Time spends on inflating: 1507ms
> > --------------------------------------------
> > 512K Byte (cover 16GB of RAM)
> >
> > Time spends on inflating: 1237ms
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > If possible, a big bitmap is better for performance.
> >
> > Liang
>=20
> Earlier you said:
> a. allocating pages (6.5%)
> b. sending PFNs to host (68.3%)
> c. address translation (6.1%)
> d. madvise (19%)
>=20
> Here sending PFNs to host with 512K Byte map should be almost free.
>=20
> So is something else taking up the time?
>=20
I just want to show you the benefits of using a big bitmap. :)
I did not measure the time spend on each stage after optimization(I will do=
 it later),
but I have tried to allocate the page with big chunk and found it can make =
things faster.
Without allocating big chunk page, the performance improvement is about 85%=
, and with
 allocating big  chunk page, the improvement is about 94%.

Liang

>=20
> --
> MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
