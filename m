Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD09E6B0033
	for <linux-mm@kvack.org>; Sun, 17 Dec 2017 08:47:26 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id q12so3588138pli.12
        for <linux-mm@kvack.org>; Sun, 17 Dec 2017 05:47:26 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 62si5991335pld.618.2017.12.17.05.47.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Dec 2017 05:47:25 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v19 3/7] xbitmap: add more operations
Date: Sun, 17 Dec 2017 13:47:21 +0000
Message-ID: <286AC319A985734F985F78AFA26841F739387C1D@shsmsx102.ccr.corp.intel.com>
References: <5A311C5E.7000304@intel.com>
 <201712132316.EJJ57332.MFOSJHOFFVLtQO@I-love.SAKURA.ne.jp>
 <5A31F445.6070504@intel.com>
 <201712150129.BFC35949.FFtFOLSOJOQHVM@I-love.SAKURA.ne.jp>
 <20171214181219.GA26124@bombadil.infradead.org>
 <201712160121.BEJ26052.HOFFOOQFMLtSVJ@I-love.SAKURA.ne.jp>
 <20171215184915.GB27160@bombadil.infradead.org>
 <20171215192203.GC27160@bombadil.infradead.org>
In-Reply-To: <20171215192203.GC27160@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu@aliyun.com" <quan.xu@aliyun.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Saturday, December 16, 2017 3:22 AM, Matthew Wilcox wrote:
> On Fri, Dec 15, 2017 at 10:49:15AM -0800, Matthew Wilcox wrote:
> > Here's the API I'm looking at right now.  The user need take no lock;
> > the locking (spinlock) is handled internally to the implementation.

Another place I saw your comment " The xb_ API requires you to handle your =
own locking" which seems conflict with the above "the user need take no loc=
k".
Doesn't the caller need a lock to avoid concurrent accesses to the ida bitm=
ap?


> I looked at the API some more and found some flaws:
>  - how does xbit_alloc communicate back which bit it allocated?
>  - What if xbit_find_set() is called on a completely empty array with
>    a range of 0, ULONG_MAX -- there's no invalid number to return.

We'll change it to "bool xb_find_set(.., unsigned long *result)", returning=
 false indicates no "1" bit is found.


>  - xbit_clear() can't return an error.  Neither can xbit_zero().

I found the current xbit_clear implementation only returns 0, and there isn=
't an error to be returned from this function. In this case, is it better t=
o make the function "void"?


>  - Need to add __must_check to various return values to discourage sloppy
>    programming
>=20
> So I modify the proposed API we compete with thusly:
>=20
> bool xbit_test(struct xbitmap *, unsigned long bit); int __must_check
> xbit_set(struct xbitmap *, unsigned long bit, gfp_t); void xbit_clear(str=
uct
> xbitmap *, unsigned long bit); int __must_check xbit_alloc(struct xbitmap=
 *,
> unsigned long *bit, gfp_t);
>=20
> int __must_check xbit_fill(struct xbitmap *, unsigned long start,
>                         unsigned long nbits, gfp_t); void xbit_zero(struc=
t xbitmap *,
> unsigned long start, unsigned long nbits); int __must_check
> xbit_alloc_range(struct xbitmap *, unsigned long *bit,
>                         unsigned long nbits, gfp_t);
>=20
> bool xbit_find_clear(struct xbitmap *, unsigned long *start, unsigned lon=
g
> max); bool xbit_find_set(struct xbitmap *, unsigned long *start, unsigned
> long max);
>=20
> (I'm a little sceptical about the API accepting 'max' for the find functi=
ons and
> 'nbits' in the fill/zero/alloc_range functions, but I think that matches =
how
> people want to use it, and it matches how bitmap.h works)

Are you suggesting to rename the current xb_ APIs to the above xbit_ names =
(with parameter changes)?=20

Why would we need xbit_alloc, which looks like ida_get_new, I think set/cle=
ar should be adequate to the current usages.

Best,
Wei



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
