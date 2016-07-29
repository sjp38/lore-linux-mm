Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB996B0253
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 20:46:19 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ca5so77757741pac.0
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 17:46:19 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id p28si15089827pfk.183.2016.07.28.17.46.18
        for <linux-mm@kvack.org>;
        Thu, 28 Jul 2016 17:46:18 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [virtio-dev] Re: [PATCH v2 repost 4/7] virtio-balloon: speed up
 inflate/deflate process
Date: Fri, 29 Jul 2016 00:46:14 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E04214C0B@shsmsx102.ccr.corp.intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
 <1469582616-5729-5-git-send-email-liang.z.li@intel.com>
 <5798DB49.7030803@intel.com>
 <F2CBF3009FA73547804AE4C663CAB28E04213CCB@shsmsx102.ccr.corp.intel.com>
 <20160728044000-mutt-send-email-mst@kernel.org>
 <F2CBF3009FA73547804AE4C663CAB28E04214103@shsmsx102.ccr.corp.intel.com>
 <20160729003759-mutt-send-email-mst@kernel.org>
In-Reply-To: <20160729003759-mutt-send-email-mst@kernel.org>
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

> On Thu, Jul 28, 2016 at 06:36:18AM +0000, Li, Liang Z wrote:
> > > > > This ends up doing a 1MB kmalloc() right?  That seems a _bit_ big=
.
> > > > > How big was the pfn buffer before?
> > > >
> > > > Yes, it is if the max pfn is more than 32GB.
> > > > The size of the pfn buffer use before is 256*4 =3D 1024 Bytes, it's
> > > > too small, and it's the main reason for bad performance.
> > > > Use the max 1MB kmalloc is a balance between performance and
> > > > flexibility, a large page bitmap covers the range of all the
> > > > memory is no good for a system with huge amount of memory. If the
> > > > bitmap is too small, it means we have to traverse a long list for
> > > > many times, and it's bad
> > > for performance.
> > > >
> > > > Thanks!
> > > > Liang
> > >
> > > There are all your implementation decisions though.
> > >
> > > If guest memory is so fragmented that you only have order 0 4k
> > > pages, then allocating a huge 1M contigious chunk is very problematic=
 in
> and of itself.
> > >
> >
> > The memory is allocated in the probe stage. This will not happen if
> > the driver is  loaded when booting the guest.
> >
> > > Most people rarely migrate and do not care how fast that happens.
> > > Wasting a large chunk of memory (and it's zeroed for no good reason,
> > > so you actually request host memory for it) for everyone to speed it
> > > up when it does happen is not really an option.
> > >
> > If people don't plan to do inflating/deflating, they should not enable
> > the virtio-balloon at the beginning, once they decide to use it, the
> > driver should provide better performance as much as possible.
>=20
> The reason people inflate/deflate is so they can overcommit memory.
> Do they need to overcommit very quickly? I don't see why.
> So let's get what we can for free but I don't really believe people would=
 want
> to pay for it.
>=20
> > 1MB is a very small portion for a VM with more than 32GB memory and
> > it's the *worst case*, for VM with less than 32GB memory, the amount
> > of RAM depends on VM's memory size and will be less than 1MB.
>=20
> It's guest memmory so might all be in swap and never touched, your memset
> at probe time will fault it in and make hypervisor actually pay for it.
>=20
> > If 1MB is too big, how about 512K, or 256K?  32K seems too small.
> >
> > Liang
>=20
> It's only small because it makes you rescan the free list.
> So maybe you should do something else.
> I looked at it a bit. Instead of scanning the free list, how about scanni=
ng actual
> page structures? If page is unused, pass it to host.
> Solves the problem of rescanning multiple times, does it not?
>=20

Yes, agree.
>=20
> Another idea: allocate a small bitmap at probe time (e.g. for deflate), a=
llocate
> a bunch more on each request. Use something like GFP_ATOMIC and a
> scatter/gather, if that fails use the smaller bitmap.
>=20

So, the aim of v3 is to use a smaller bitmap without too heavy performance =
penalty.
Thanks a lot!

Liang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
