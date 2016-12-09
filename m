Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 611B66B0253
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 23:45:42 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q10so15424447pgq.7
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 20:45:42 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id d7si31885285plj.257.2016.12.08.20.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 20:45:41 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [PATCH kernel v5 0/5] Extend virtio-balloon for
 fast (de)inflating & fast live migration
Date: Fri, 9 Dec 2016 04:45:36 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E3A14E2AD@SHSMSX104.ccr.corp.intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
 <f67ca79c-ad34-59dd-835f-e7bc9dcaef58@redhat.com>
 <F2CBF3009FA73547804AE4C663CAB28E3A130C01@shsmsx102.ccr.corp.intel.com>
 <0b18c636-ee67-cbb4-1ba3-81a06150db76@redhat.com>
 <0b83db29-ebad-2a70-8d61-756d33e33a48@intel.com>
 <2171e091-46ee-decd-7348-772555d3a5e3@redhat.com>
 <d3ff453c-56fa-19de-317c-1c82456f2831@intel.com>
 <20161207183817.GE28786@redhat.com>
 <b58fd9f6-d9dd-dd56-d476-dd342174dac5@intel.com>
 <20161207202824.GH28786@redhat.com>
In-Reply-To: <20161207202824.GH28786@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Hansen, Dave" <dave.hansen@intel.com>
Cc: David Hildenbrand <david@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, "mst@redhat.com" <mst@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

> > 1. Current patches do a hypercall for each order in the allocator.
> >    This is inefficient, but independent from the underlying data
> >    structure in the ABI, unless bitmaps are in play, which they aren't.
> > 2. Should we have bitmaps in the ABI, even if they are not in use by th=
e
> >    guest implementation today?  Andrea says they have zero benefits
> >    over a pfn/len scheme.  Dave doesn't think they have zero benefits
> >    but isn't that attached to them.  QEMU's handling gets more
> >    complicated when using a bitmap.
> > 3. Should the ABI contain records each with a pfn/len pair or a
> >    pfn/order pair?
> >    3a. 'len' is more flexible, but will always be a power-of-two anyway
> > 	for high-order pages (the common case)
>=20
> Len wouldn't be a power of two practically only if we detect adjacent pag=
es
> of smaller order that may merge into larger orders we already allocated (=
or
> the other way around).
>=20
> [addr=3D2M, len=3D2M] allocated at order 9 pass [addr=3D4M, len=3D1M] all=
ocated at
> order 8 pass -> merge as [addr=3D2M, len=3D3M]
>=20
> Not sure if it would be worth it, but that unless we do this, page-order =
or len
> won't make much difference.
>=20
> >    3b. if we decide not to have a bitmap, then we basically have plenty
> > 	of space for 'len' and should just do it
> >    3c. It's easiest for the hypervisor to turn pfn/len into the
> >        madvise() calls that it needs.
> >
> > Did I miss anything?
>=20
> I think you summarized fine all my arguments in your summary.
>=20
> > FWIW, I don't feel that strongly about the bitmap.  Li had one
> > originally, but I think the code thus far has demonstrated a huge
> > benefit without even having a bitmap.
> >
> > I've got no objections to ripping the bitmap out of the ABI.
>=20
> I think we need to see a statistic showing the number of bits set in each
> bitmap in average, after some uptime and lru churn, like running stresste=
st
> app for a while with I/O and then inflate the balloon and
> count:
>=20
> 1) how many bits were set vs total number of bits used in bitmaps
>=20
> 2) how many times bitmaps were used vs bitmap_len =3D 0 case of single
>    page
>=20
> My guess would be like very low percentage for both points.
>=20

> So there is a connection with the MAX_ORDER..0 allocation loop and the AB=
I
> change, but I agree any of the ABI proposed would still allow for it this=
 logic to
> be used. Bitmap or not bitmap, the loop would still work.

Hi guys,

What's the conclusion of your discussion?=20
It seems you want some statistic before deciding whether to  ripping the bi=
tmap from the ABI, am I right?

Thanks!
Liang=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
