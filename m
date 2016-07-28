Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9740E6B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:30:41 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so31602562pfg.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:30:41 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 10si9898885pab.31.2016.07.27.20.30.40
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 20:30:40 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Date: Thu, 28 Jul 2016 03:30:09 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213E5D@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com> <20160728003644-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728003644-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo
 Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/defla=
te
> process
>=20
> On Wed, Jul 27, 2016 at 09:03:21AM -0700, Dave Hansen wrote:
> > On 07/26/2016 06:23 PM, Liang Li wrote:
> > > +	vb->pfn_limit =3D VIRTIO_BALLOON_PFNS_LIMIT;
> > > +	vb->pfn_limit =3D min(vb->pfn_limit, get_max_pfn());
> > > +	vb->bmap_len =3D ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > > +	hdr_len =3D sizeof(struct balloon_bmap_hdr);
> > > +	vb->bmap_hdr =3D kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
> >
> > This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.
> > How big was the pfn buffer before?
>=20
>=20
> Yes I would limit this to 1G memory in a go, will result in a 32KByte bit=
map.
>=20
> --
> MST

Limit to 1G is bad for the performance, I sent you the test result several =
weeks ago.

Paste it bellow:
---------------------------------------------------------------------------=
---------------------------------------------
About the size of page bitmap, I have test the performance of filling the b=
alloon to 15GB with a
 16GB RAM VM.

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
32K Byte (cover 1GB of RAM)

Time spends on inflating: 2031ms
---------------------------------------------
64K Byte (cover 2GB of RAM)

Time spends on inflating: 1507ms
--------------------------------------------
512K Byte (cover 16GB of RAM)

Time spends on inflating: 1237ms
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D

If possible, a big bitmap is better for performance.

Liang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
