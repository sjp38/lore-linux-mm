Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D99CE6B027F
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 11:13:22 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w5so14544546pgt.4
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 08:13:22 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u11si13004690pls.169.2017.12.20.08.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Dec 2017 08:13:21 -0800 (PST)
From: "Wang, Wei W" <wei.w.wang@intel.com>
Subject: RE: [PATCH v20 0/7] Virtio-balloon Enhancement
Date: Wed, 20 Dec 2017 16:13:16 +0000
Message-ID: <286AC319A985734F985F78AFA26841F73938CC3E@shsmsx102.ccr.corp.intel.com>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
 <201712192305.AAE21882.MtQHJOFFSFVOLO@I-love.SAKURA.ne.jp>
 <5A3A3CBC.4030202@intel.com> <20171220122547.GA1654@bombadil.infradead.org>
In-Reply-To: <20171220122547.GA1654@bombadil.infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, "virtio-dev@lists.oasis-open.org" <virtio-dev@lists.oasis-open.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mst@redhat.com" <mst@redhat.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "david@redhat.com" <david@redhat.com>, "cornelia.huck@de.ibm.com" <cornelia.huck@de.ibm.com>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>, "aarcange@redhat.com" <aarcange@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "liliang.opensource@gmail.com" <liliang.opensource@gmail.com>, "yang.zhang.wz@gmail.com" <yang.zhang.wz@gmail.com>, "quan.xu0@gmail.com" <quan.xu0@gmail.com>, "nilal@redhat.com" <nilal@redhat.com>, "riel@redhat.com" <riel@redhat.com>

On Wednesday, December 20, 2017 8:26 PM, Matthew Wilcox wrote:
> On Wed, Dec 20, 2017 at 06:34:36PM +0800, Wei Wang wrote:
> > On 12/19/2017 10:05 PM, Tetsuo Handa wrote:
> > > I think xb_find_set() has a bug in !node path.
> >
> > I think we can probably remove the "!node" path for now. It would be
> > good to get the fundamental part in first, and leave optimization to
> > come as separate patches with corresponding test cases in the future.
>=20
> You can't remove the !node path.  You'll see !node when the highest set b=
it
> is less than 1024.  So do something like this:
>=20
> 	unsigned long bit;
> 	xb_preload(GFP_KERNEL);
> 	xb_set_bit(xb, 700);
> 	xb_preload_end();
> 	bit =3D xb_find_set(xb, ULONG_MAX, 0);
> 	assert(bit =3D=3D 700);

This above test will result in "!node with bitmap !=3DNULL", and it goes to=
 the regular "if (bitmap)" path, which finds 700.

A better test would be
...
xb_set_bit(xb, 700);
assert(xb_find_set(xb, ULONG_MAX, 800) =3D=3D ULONG_MAX);
...

The first try with the "if (bitmap)" path doesn't find a set bit, and the r=
emaining tries will always result in "!node && !bitmap", which implies no s=
et bit anymore and no need to try in this case.

So, I think we can change it to

If (!node && !bitmap)
	return size;


Best,
Wei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
