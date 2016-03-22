Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id E3ED36B0005
	for <linux-mm@kvack.org>; Tue, 22 Mar 2016 15:21:24 -0400 (EDT)
Received: by mail-qk0-f174.google.com with SMTP id o6so96375744qkc.2
        for <linux-mm@kvack.org>; Tue, 22 Mar 2016 12:21:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j201si15036921qhc.131.2016.03.22.12.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Mar 2016 12:21:23 -0700 (PDT)
Message-ID: <1458674476.24206.5.camel@redhat.com>
Subject: Re: [PATCH v4 2/2] mm, thp: avoid unnecessary swapin in khugepaged
From: Rik van Riel <riel@redhat.com>
Date: Tue, 22 Mar 2016 15:21:16 -0400
In-Reply-To: <20160321153637.GE21248@dhcp22.suse.cz>
References: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1458497259-12753-3-git-send-email-ebru.akagunduz@gmail.com>
	 <20160321153637.GE21248@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-XkImkxbSl7u1XvQqbJJH"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com


--=-XkImkxbSl7u1XvQqbJJH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-03-21 at 16:36 +0100, Michal Hocko wrote:
> On Sun 20-03-16 20:07:39, Ebru Akagunduz wrote:
> >=20
> > Currently khugepaged makes swapin readahead to improve
> > THP collapse rate. This patch checks vm statistics
> > to avoid workload of swapin, if unnecessary. So that
> > when system under pressure, khugepaged won't consume
> > resources to swapin.
> OK, so you want to disable the optimization when under the memory
> pressure. That sounds like a good idea in general.
>=C2=A0
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
> this criteria doesn't really make much sense to me. So we are
> checking
> whether there was the direct reclaim invoked since some point in time
> (more on that below) and we take that as a signal of a strong memory
> pressure, right? What if that was quite some time ago? What if we
> didn't
> have a single direct reclaim but the kswapd was busy the whole time.
> Or
> what if the allocstall was from a different numa node?

Do you have a measure in mind that the code should test
against, instead?

I don't think we want page cache turnover to prevent
khugepaged collapsing THPs, but if the system gets
to the point where kswapd is doing pageout IO, or
swapout IO, or kswapd cannot keep up, we should
probably slow down khugepaged.

If another NUMA node is under significant memory
pressure, we probably want the programs from that
node to be able to do some allocations from this
node, rather than have khugepaged consume the memory.

> > =C2=A0	anon_vma_lock_write(vma->anon_vma);
> > =C2=A0
> > @@ -2905,6 +2913,7 @@ static int khugepaged(void *none)
> > =C2=A0	set_user_nice(current, MAX_NICE);
> > =C2=A0
> > =C2=A0	while (!kthread_should_stop()) {
> > +		allocstall =3D sum_vm_event(ALLOCSTALL);
> > =C2=A0		khugepaged_do_scan();
> And this sounds even buggy AFAIU. I guess you want to snapshot before
> goint to sleep no? Otherwise you are comparing allocstall diff from a
> very short time period. Or was this an intention and you really want
> to
> watch for events while khugepaged is running? If yes a comment would
> be
> due here.

You are right, the snapshot should be taken after
khugepaged_do_work().

The memory pressure needs to be measured over the
longest time possible between khugepaged runs.

> That being said, is this actually useful in the real life? Basing
> your
> decision on something as volatile as the direct reclaim would lead to
> rather volatile results. E.g. how stable are the numbers during your
> test?
>=20
> Wouldn't it be better to rather do an optimistic swapin and back out
> if the direct reclaim is really required. I realize this will be a
> much
> bigger change but it would make more sense I guess.

That depends on how costly swap IO is.

Having khugepaged be on the conservative side is probably
a good idea, given how many systems out there still have
hard drives today.

--=20
All Rights Reversed.


--=-XkImkxbSl7u1XvQqbJJH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJW8ZstAAoJEM553pKExN6DUK4H/i9xM4l9GMSi2IuaeScoJkB+
sev5WreloD6zxpxDIEjWMR44SmEEcHhwbBeIGZAx3tNVSU603iPACz5aCn3Zv7qY
rCCe1SFl9pmcW4tuHpxBL9WCrGq/lXZ6I+cYn+BQ/DQVAr8lw++VrVp4KhSW8Noq
GY8Bops4wENCqRIXkG08AWVsHhtn4/xw9xRuk+HRyl0M1HcfvJtuudPwm/6bbDUF
LO8qYyX0Z6cOG0+KRxOrIjbmjMufVVNWomSo/FzbfwN/xt7MSivc9AKE0JzSdSjy
IB3F3u4O8zJ56faO3VusoDfv9U9CQav0fhLhh8wPBiDZSIMPOI++tn7tTDR+uTk=
=sTd7
-----END PGP SIGNATURE-----

--=-XkImkxbSl7u1XvQqbJJH--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
