Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 84F306B0005
	for <linux-mm@kvack.org>; Sun, 13 Mar 2016 21:15:51 -0400 (EDT)
Received: by mail-qk0-f169.google.com with SMTP id o6so69538766qkc.2
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 18:15:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c207si19363805qhc.129.2016.03.13.18.15.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Mar 2016 18:15:50 -0700 (PDT)
Message-ID: <1457918081.8898.1.camel@redhat.com>
Subject: Re: [PATCH v2 2/2] mm, thp: avoid unnecessary swapin in khugepaged
From: Rik van Riel <riel@redhat.com>
Date: Sun, 13 Mar 2016 21:14:41 -0400
In-Reply-To: <20160313233301.GB10438@node.shutemov.name>
References: <1457861335-23297-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1457861335-23297-3-git-send-email-ebru.akagunduz@gmail.com>
	 <20160313233301.GB10438@node.shutemov.name>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-B85HOJRZY+k4VWm2oKhg"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com


--=-B85HOJRZY+k4VWm2oKhg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-03-14 at 02:33 +0300, Kirill A. Shutemov wrote:
> On Sun, Mar 13, 2016 at 11:28:55AM +0200, Ebru Akagunduz wrote:
> >=C2=A0
> > @@ -2493,7 +2494,14 @@ static void collapse_huge_page(struct
> > mm_struct *mm,
> > =C2=A0		goto out;
> > =C2=A0	}
> > =C2=A0
> > -	__collapse_huge_page_swapin(mm, vma, address, pmd);
> > +	swap =3D get_mm_counter(mm, MM_SWAPENTS);
> > +	curr_allocstall =3D sum_vm_event(ALLOCSTALL);
> > +	/*
> > +	=C2=A0* When system under pressure, don't swapin readahead.
> > +	=C2=A0* So that avoid unnecessary resource consuming.
> > +	=C2=A0*/
> > +	if (allocstall =3D=3D curr_allocstall && swap !=3D 0)
> > +		__collapse_huge_page_swapin(mm, vma, address,
> > pmd);
>=20
> So, between these too points, where new ALLOCSTALL events comes from?
>=20
> I would guess that in most cases they would come from allocation of
> huge
> page itself (if khugepaged defrag is enabled). So we are willing to
> pay
> for allocation new huge page, but not for swapping in.
>=20
> I wounder, if it was wise to allocate the huge page in first place?
>=20
> Or shouldn't we at least have consistent behaviour on swap-in vs.
> allocation wrt khugepaged defragmentation option?
>=20
> Or am I wrong and ALLOCSTALLs aren't caused by khugepagd?

It could be caused by khugepaged, but it could just as well
be caused by any other task running in the system.

Khugepaged stores the allocstall value when it goes to sleep,
and checks it before calling (or not) __collapse_huge_page_swapin.

--=20
All Rights Reversed.


--=-B85HOJRZY+k4VWm2oKhg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJW5hCBAAoJEM553pKExN6DcGwH/1EZVF8tFdEsjY6JDlGra8mJ
twrvfKc8+jc0n9Zr6oYtuCYVQSn2RDwNIBubTWy8wLi+0WL7Mm2kocI5ugXBasuc
EHM36BuLO0Ps3mhf6s5GbPbVRinxucXxxwFEfkFj5/qdoJr6VZy/7XQTtTmm2YFx
tnDStXo+o31qON0muHAwpJg01oNtb9WyIlW9IcZZ+kn4/ZZIklK+N7MqvFFcJdqC
/eZt8pGbpjKJDy0MOk4aMDjj5JYqclQ2JaEFD0O4l+lDt71RFdAm6gJ24x+wHAFi
OPcnoNYKEP9lfEpZCRINlbz1ZsAFRukJkCyIH8OinTp9BexKRm4d77xXGgj5EAU=
=vrc1
-----END PGP SIGNATURE-----

--=-B85HOJRZY+k4VWm2oKhg--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
