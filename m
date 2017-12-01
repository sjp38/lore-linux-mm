Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F5566B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:09:14 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 88so4571308pla.14
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:09:14 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id g59si5090787plb.658.2017.12.01.07.09.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Dec 2017 07:09:13 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v18 05/10] xbitmap: add more operations
Date: Fri, 1 Dec 2017 15:09:08 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739376DA1@shsmsx102.ccr.corp.intel.com>
References: <1511963726-34070-1-git-send-email-wei.w.wang@intel.com>
	<1511963726-34070-6-git-send-email-wei.w.wang@intel.com>
	<201711301934.CDC21800.FSLtJFFOOVQHMO@I-love.SAKURA.ne.jp>
	<5A210C96.8050208@intel.com>
 <201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
In-Reply-To: <201712012202.BDE13557.MJFQLtOOHVOFSF@I-love.SAKURA.ne.jp>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "willy@infradead.org" <willy@infradead.org>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Friday, December 1, 2017 9:02 PM, Tetsuo Handa wrote:
> Wei Wang wrote:
> > On 11/30/2017 06:34 PM, Tetsuo Handa wrote:
> > > Wei Wang wrote:
> > >> + * @start: the start of the bit range, inclusive
> > >> + * @end: the end of the bit range, inclusive
> > >> + *
> > >> + * This function is used to clear a bit in the xbitmap. If all the
> > >> +bits of the
> > >> + * bitmap are 0, the bitmap will be freed.
> > >> + */
> > >> +void xb_clear_bit_range(struct xb *xb, unsigned long start,
> > >> +unsigned long end) {
> > >> +	struct radix_tree_root *root =3D &xb->xbrt;
> > >> +	struct radix_tree_node *node;
> > >> +	void **slot;
> > >> +	struct ida_bitmap *bitmap;
> > >> +	unsigned int nbits;
> > >> +
> > >> +	for (; start < end; start =3D (start | (IDA_BITMAP_BITS - 1)) + 1)=
 {
> > >> +		unsigned long index =3D start / IDA_BITMAP_BITS;
> > >> +		unsigned long bit =3D start % IDA_BITMAP_BITS;
> > >> +
> > >> +		bitmap =3D __radix_tree_lookup(root, index, &node, &slot);
> > >> +		if (radix_tree_exception(bitmap)) {
> > >> +			unsigned long ebit =3D bit + 2;
> > >> +			unsigned long tmp =3D (unsigned long)bitmap;
> > >> +
> > >> +			nbits =3D min(end - start + 1, BITS_PER_LONG - ebit);
> > > "nbits =3D min(end - start + 1," seems to expect that start =3D=3D en=
d is
> > > legal for clearing only 1 bit. But this function is no-op if start =
=3D=3D end.
> > > Please clarify what "inclusive" intended.
> >
> > If xb_clear_bit_range(xb,10,10), then it is effectively the same as
> > xb_clear_bit(10). Why would it be illegal?
> >
> > "@start inclusive" means that the @start will also be included to be
> > cleared.
>=20
> If start =3D=3D end is legal,
>=20
>    for (; start < end; start =3D (start | (IDA_BITMAP_BITS - 1)) + 1) {
>=20
> makes this loop do nothing because 10 < 10 is false.


How about "start <=3D end "?

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
