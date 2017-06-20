Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id D7A1E6B0314
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 13:29:10 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o142so39624830qke.3
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 10:29:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e128si12229114qkc.302.2017.06.20.10.29.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 10:29:10 -0700 (PDT)
Message-ID: <1497979740.20270.102.camel@redhat.com>
Subject: Re: [PATCH v11 4/6] mm: function to offer a page block on the free
 list
From: Rik van Riel <riel@redhat.com>
Date: Tue, 20 Jun 2017 13:29:00 -0400
In-Reply-To: <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
	 <1497004901-30593-5-git-send-email-wei.w.wang@intel.com>
	 <b92af473-f00e-b956-ea97-eb4626601789@intel.com>
	 <1497977049.20270.100.camel@redhat.com>
	 <7b626551-6d1b-c8d5-4ef7-e357399e78dc@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-9kj1x8ztObs/ecPVraUB"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Wei Wang <wei.w.wang@intel.com>, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com
Cc: Nitesh Narayan Lal <nilal@redhat.com>


--=-9kj1x8ztObs/ecPVraUB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-06-20 at 18:49 +0200, David Hildenbrand wrote:
> On 20.06.2017 18:44, Rik van Riel wrote:

> > Nitesh Lal (on the CC list) is working on a way
> > to efficiently batch recently freed pages for
> > free page hinting to the hypervisor.
> >=20
> > If that is done efficiently enough (eg. with
> > MADV_FREE on the hypervisor side for lazy freeing,
> > and lazy later re-use of the pages), do we still
> > need the harder to use batch interface from this
> > patch?
> >=20
>=20
> David's opinion incoming:
>=20
> No, I think proper free page hinting would be the optimum solution,
> if
> done right. This would avoid the batch interface and even turn
> virtio-balloon in some sense useless.

I agree with that.  Let me go into some more detail of
what Nitesh is implementing:

1) In arch_free_page, the being-freed page is added
   to a per-cpu set of freed pages.
2) Once that set is full, arch_free_pages goes into a
   slow path, which:
   2a) Iterates over the set of freed pages, and
   2b) Checks whether they are still free, and
   2c) Adds the still free pages to a list that is
       to be passed to the hypervisor, to be MADV_FREEd.
   2d) Makes that hypercall.

Meanwhile all arch_alloc_pages has to do is make sure it
does not allocate a page while it is currently being
MADV_FREEd on the hypervisor side.

The code Wei is working on looks like it could be=20
suitable for steps (2c) and (2d) above. Nitesh already
has code for steps 1 through 2b.

--=20
All rights reversed
--=-9kj1x8ztObs/ecPVraUB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZSVtcAAoJEM553pKExN6DWsAH/RVdYjrbXdTBMg+9KCGD7zih
8IjHH7OSo7O9qBnWrHCPhvs8A6y/LusCYmEdWaCH2EVZc8cgvsrEc2Ju5Wt7MnPn
nT6sE5MCVS5puJmnNGlg8jA1PM+bsgx7qUYsRcVAtIMFou0eoSjIGTrQ7GCuefNB
7aW02aByPg3IaDE0ukP4tPvTeSowuTCSsYU+cdaF0TR9qO9j6kdLAr4rxhWQsuIT
HMS/6Dztj9blBhP2JZM8pYu4MqZ5/Wjf6THBCSz3jNgd8HxkD8YYZgyjIn/FTg2v
yJjcmTDnUoXXsDxzJfgKgXC3ludgiuJuhkMF+bMEYG9NpKEupa09a3JQWhi+oQ0=
=bV0p
-----END PGP SIGNATURE-----

--=-9kj1x8ztObs/ecPVraUB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
