Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 105D86B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 02:36:27 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so33391139pab.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:36:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xp2si10825359pab.19.2016.07.27.23.36.26
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 23:36:26 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 repost 4/7] virtio-balloon: speed up
 inflate/deflate process
Date: Thu, 28 Jul 2016 06:36:18 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04214103@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
 <20160728044000-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160728044000-mutt-send-email-mst@kernel.org>
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

> > > This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big.
> > > How big was the pfn buffer before?
> >
> > Yes, it is if the max pfn is more than 32GB.
> > The size of the pfn buffer use before is 256*4 =3D 1024 Bytes, it's too
> > small, and it's the main reason for bad performance.
> > Use the max 1MB kmalloc is a balance between performance and
> > flexibility, a large page bitmap covers the range of all the memory is
> > no good for a system with huge amount of memory. If the bitmap is too
> > small, it means we have to traverse a long list for many times, and it'=
s bad
> for performance.
> >
> > Thanks!
> > Liang
>=20
> There are all your implementation decisions though.
>=20
> If guest memory is so fragmented that you only have order 0 4k pages, the=
n
> allocating a huge 1M contigious chunk is very problematic in and of itsel=
f.
>=20

The memory is allocated in the probe stage. This will not happen if the dri=
ver is
 loaded when booting the guest.

> Most people rarely migrate and do not care how fast that happens.
> Wasting a large chunk of memory (and it's zeroed for no good reason, so y=
ou
> actually request host memory for it) for everyone to speed it up when it
> does happen is not really an option.
>=20
If people don't plan to do inflating/deflating, they should not enable the =
virtio-balloon
at the beginning, once they decide to use it, the driver should provide bet=
ter performance
as much as possible.

1MB is a very small portion for a VM with more than 32GB memory and it's th=
e *worst case*,=20
for VM with less than 32GB memory, the amount of RAM depends on VM's memory=
 size
and will be less than 1MB.

If 1MB is too big, how about 512K, or 256K?  32K seems too small.

Liang

> --
> MST
>=20
> ---------------------------------------------------------------------
> To unsubscribe, e-mail: virtio-dev-unsubscribe@lists.oasis-open.org
> For additional commands, e-mail: virtio-dev-help@lists.oasis-open.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
