Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 260A06B0279
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 15:51:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m57so85325764qta.9
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:51:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r28si12814209qkr.367.2017.06.20.12.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 12:51:12 -0700 (PDT)
Message-ID: <1497988260.20270.109.camel@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
From: Rik van Riel <riel@redhat.com>
Date: Tue, 20 Jun 2017 15:51:00 -0400
In-Reply-To: <20170620212107-mutt-send-email-mst@kernel.org>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
	 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
	 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
	 <1497977049.20270.100.camel@redhat.com>
	 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
	 <1497979740.20270.102.camel@redhat.com>
	 <20170620212107-mutt-send-email-mst@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-/CdBXLQWUXqNPsXR1B2X"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, Nitesh Narayan Lal <nilal@redhat.com>


--=-/CdBXLQWUXqNPsXR1B2X
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-06-20 at 21:26 +0300, Michael S. Tsirkin wrote:
> On Tue, Jun 20, 2017 at 01:29:00PM -0400, Rik van Riel wrote:
> > I agree with that.=C2=A0=C2=A0Let me go into some more detail of
> > what Nitesh is implementing:
> >=20
> > 1) In arch_free_page, the being-freed page is added
> > =C2=A0=C2=A0=C2=A0to a per-cpu set of freed pages.
> > 2) Once that set is full, arch_free_pages goes into a
> > =C2=A0=C2=A0=C2=A0slow path, which:
> > =C2=A0=C2=A0=C2=A02a) Iterates over the set of freed pages, and
> > =C2=A0=C2=A0=C2=A02b) Checks whether they are still free, and
> > =C2=A0=C2=A0=C2=A02c) Adds the still free pages to a list that is
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0to be passed to the hyperviso=
r, to be MADV_FREEd.
> > =C2=A0=C2=A0=C2=A02d) Makes that hypercall.
> >=20
> > Meanwhile all arch_alloc_pages has to do is make sure it
> > does not allocate a page while it is currently being
> > MADV_FREEd on the hypervisor side.
> >=20
> > The code Wei is working on looks like it could be=C2=A0
> > suitable for steps (2c) and (2d) above. Nitesh already
> > has code for steps 1 through 2b.
>=20
> So my question is this: Wei posted these numbers for balloon
> inflation times:
> inflating 7GB of an 8GB idle guest:
>=20
> 	1) allocating pages (6.5%)
> 	2) sending PFNs to host (68.3%)
> 	3) address translation (6.1%)
> 	4) madvise (19%)
>=20
> 	It takes about 4126ms for the inflating process to complete.
>=20
> It seems that this is an excessive amount of time to stay
> under a lock. What are your estimates for Nitesh's work?

That depends on the batch size used for step
(2c), and is something that we should be able
to tune for decent performance.

What seems to matter is that things are batched.
There are many ways to achieve that.

--=20
All rights reversed
--=-/CdBXLQWUXqNPsXR1B2X
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZSXykAAoJEM553pKExN6DC2QH/1E5nvrRR1z6XeXLr/emhHbH
E20L0/z3rCW/tIsMGlRNV3kkcsblKiS2KlWYNqNwQqSDnLvHLAC5e8fh/zme7k2m
hjvCl+Icj5aatmo+JdncpkygC89MnC6DETFrkrs2wobgoXigMUgwONH6PF0Yhx0a
EjDSYwPbyjZJAa1VSDT146xPLSrapQ3jrNUhWCVrxGzl4d6TiNinLhjG61fECxMR
sJ4qXDGrr1z/jWNrkJT2IZOZrD/V5t4O2a/16LeHzMai1xv3opRkbmffnz9YLiWJ
kLjjO64QlgrtL1oOcpFpyktTGbjLG3QPiq1lDJ6YEsvoLjkr1H0hcpaWLB3I2FI=
=6M0R
-----END PGP SIGNATURE-----

--=-/CdBXLQWUXqNPsXR1B2X--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
