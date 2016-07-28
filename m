Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 14E556B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:13:40 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so23210985pad.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:13:40 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id qi7si9183647pac.183.2016.07.27.18.13.39
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 18:13:39 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Date: Thu, 28 Jul 2016 01:13:35 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
In-Reply-To: <5798DB49.7030803@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Hansen, Dave" <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "quintela@redhat.com" <quintela@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

> Subject: Re: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/defla=
te
> process
>=20
> On 07/26/2016 06:23 PM, Liang Li wrote:
> > +	vb->pfn_limit =3D VIRTIO_BALLOON_PFNS_LIMIT;
> > +	vb->pfn_limit =3D min(vb->pfn_limit, get_max_pfn());
> > +	vb->bmap_len =3D ALIGN(vb->pfn_limit, BITS_PER_LONG) /
> > +		 BITS_PER_BYTE + 2 * sizeof(unsigned long);
> > +	hdr_len =3D sizeof(struct balloon_bmap_hdr);
> > +	vb->bmap_hdr =3D kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
>=20
> This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.  How b=
ig
> was the pfn buffer before?

Yes, it is if the max pfn is more than 32GB.
The size of the pfn buffer use before is 256*4 =3D 1024 Bytes, it's too sma=
ll,=20
and it's the main reason for bad performance.
Use the max 1MB kmalloc is a balance between performance and flexibility,
a large page bitmap covers the range of all the memory is no good for a sys=
tem
with huge amount of memory. If the bitmap is too small, it means we have
to traverse a long list for many times, and it's bad for performance.

Thanks!
Liang  =20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
