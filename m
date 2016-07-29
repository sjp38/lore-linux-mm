Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB18E6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:38:22 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so76994678pac.3
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:38:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id um11si7987754pab.133.2016.07.28.17.38.21
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 17:38:21 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [PATCH v2 repost 4/7] virtio-balloon: speed up inflate/deflate
 process
Date: Fri, 29 Jul 2016 00:38:18 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04214BD3@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <20160728002243-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04213E1D@shsmsx102.ccr.corp.intel.com>
 <20160729011553-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160729011553-mutt-send-email-mst@kernel.org>
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

> On Thu, Jul 28, 2016 at 03:06:37AM +0000, Li, Liang Z wrote:
> > > > + * VIRTIO_BALLOON_PFNS_LIMIT is used to limit the size of page
> > > > +bitmap
> > > > + * to prevent a very large page bitmap, there are two reasons for =
this:
> > > > + * 1) to save memory.
> > > > + * 2) allocate a large bitmap may fail.
> > > > + *
> > > > + * The actual limit of pfn is determined by:
> > > > + * pfn_limit =3D min(max_pfn, VIRTIO_BALLOON_PFNS_LIMIT);
> > > > + *
> > > > + * If system has more pages than VIRTIO_BALLOON_PFNS_LIMIT, we
> > > > +will scan
> > > > + * the page list and send the PFNs with several times. To reduce
> > > > +the
> > > > + * overhead of scanning the page list. VIRTIO_BALLOON_PFNS_LIMIT
> > > > +should
> > > > + * be set with a value which can cover most cases.
> > >
> > > So what if it covers 1/32 of the memory? We'll do 32 exits and not
> > > 1, still not a big deal for a big guest.
> > >
> >
> > The issue here is the overhead is too high for scanning the page list f=
or 32
> times.
> > Limit the page bitmap size to a fixed value is better for a big guest?
> >
>=20
> I'd say avoid scanning free lists completely. Scan pages themselves and c=
heck
> the refcount to see whether they are free.
> This way each page needs to be tested once.
>=20
> And skip the whole optimization if less than e.g. 10% is free.

That's better than rescanning the free list. Will change in next version.

Thanks!

Liang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
