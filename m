Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 70F876B0069
	for <linux-mm@kvack.org>; Sat, 30 Sep 2017 00:24:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y77so2161584pfd.2
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 21:24:31 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o1si708709pll.166.2017.09.29.21.24.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 21:24:30 -0700 (PDT)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v15 2/5] lib/xbitmap: add xb_find_next_bit() and
 xb_zero()
Date: Sat, 30 Sep 2017 04:24:26 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73931DE83@shsmsx102.ccr.corp.intel.com>
References: <1503914913-28893-1-git-send-email-wei.w.wang@intel.com>
 <1503914913-28893-3-git-send-email-wei.w.wang@intel.com>
 <20170911132710.GB32538@bombadil.infradead.org>
In-Reply-To: <20170911132710.GB32538@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>

On Monday, September 11, 2017 9:27 PM, Matthew Wilcox wrote
> On Mon, Aug 28, 2017 at 06:08:30PM +0800, Wei Wang wrote:
> > +/**
> > + *  xb_zero - zero a range of bits in the xbitmap
> > + *  @xb: the xbitmap that the bits reside in
> > + *  @start: the start of the range, inclusive
> > + *  @end: the end of the range, inclusive  */ void xb_zero(struct xb
> > +*xb, unsigned long start, unsigned long end) {
> > +	unsigned long i;
> > +
> > +	for (i =3D start; i <=3D end; i++)
> > +		xb_clear_bit(xb, i);
> > +}
> > +EXPORT_SYMBOL(xb_zero);
>=20
> Um.  This is not exactly going to be quick if you're clearing a range of =
bits.
> I think it needs to be more along the lines of this:
>=20
> void xb_clear(struct xb *xb, unsigned long start, unsigned long end) {
>         struct radix_tree_root *root =3D &xb->xbrt;
>         struct radix_tree_node *node;
>         void **slot;
>         struct ida_bitmap *bitmap;
>=20
>         for (; end < start; start =3D (start | (IDA_BITMAP_BITS - 1)) + 1=
) {
>                 unsigned long index =3D start / IDA_BITMAP_BITS;
>                 unsigned long bit =3D start % IDA_BITMAP_BITS;
>=20
>                 bitmap =3D __radix_tree_lookup(root, index, &node, &slot)=
;
>                 if (radix_tree_exception(bitmap)) {
>                         unsigned long ebit =3D bit + 2;
>                         unsigned long tmp =3D (unsigned long)bitmap;
>                         if (ebit >=3D BITS_PER_LONG)
>                                 continue;
>                         tmp &=3D ... something ...;
>                         if (tmp =3D=3D RADIX_TREE_EXCEPTIONAL_ENTRY)
>                                 __radix_tree_delete(root, node, slot);
>                         else
>                                 rcu_assign_pointer(*slot, (void *)tmp);
>                 } else if (bitmap) {
>                         unsigned int nbits =3D end - start + 1;
>                         if (nbits + bit > IDA_BITMAP_BITS)
>                                 nbits =3D IDA_BITMAP_BITS - bit;
>                         bitmap_clear(bitmap->bitmap, bit, nbits);
>                         if (bitmap_empty(bitmap->bitmap, IDA_BITMAP_BITS)=
) {
>                                 kfree(bitmap);
>                                 __radix_tree_delete(root, node, slot);
>                         }
>                 }
>         }
> }
>=20
> Also note that this should be called xb_clear(), not xb_zero() to fit in =
with
> bitmap_clear().  And this needs a thorough test suite testing all values =
for 'start'
> and 'end' between 0 and at least 1024; probably much higher.  And a varia=
ble
> number of bits need to be set before calling
> xb_clear() in the test suite.
>=20
> Also, this implementation above is missing a few tricks.  For example, if=
 'bit' is 0
> and 'nbits' =3D=3D IDA_BITMAP_BITS, we can simply call kfree without firs=
t zeroing
> out the bits and then checking if the whole thing is zero.

Thanks for the optimization suggestions. We've seen significant improvement=
 of
the ballooning time. Some other optimizations (stated in the changelog) hav=
en't
been included in the new version. If possible, we can leave that to a secon=
d step
optimization outside this patch series.

Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
