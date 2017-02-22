Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE19E6B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 09:18:11 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so5662539pgi.7
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 06:18:11 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id l1si1386081pln.71.2017.02.22.06.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Feb 2017 06:18:10 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id 1so584898pgz.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 06:18:10 -0800 (PST)
Date: Wed, 22 Feb 2017 22:18:04 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: return 0 in case this node has no page
 within the zone
Message-ID: <20170222141804.GA81216@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170206154314.15705-1-richard.weiyang@gmail.com>
 <20170207094557.GE5065@dhcp22.suse.cz>
 <20170207153247.GB31837@WeideMBP.lan>
 <20170207154120.GW5065@dhcp22.suse.cz>
 <20170209135929.GA59297@WeideMacBook-Pro.local>
 <20170222084947.GE5753@dhcp22.suse.cz>
 <20170222105131.GA57616@WeideMacBook-Pro.local>
 <20170222114521.GJ5753@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="J2SCkAp4GZ/dPZZf"
Content-Disposition: inline
In-Reply-To: <20170222114521.GJ5753@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 22, 2017 at 12:45:22PM +0100, Michal Hocko wrote:
>On Wed 22-02-17 18:51:31, Wei Yang wrote:
>> On Wed, Feb 22, 2017 at 09:49:47AM +0100, Michal Hocko wrote:
>> >On Thu 09-02-17 21:59:29, Wei Yang wrote:
>> >> On Tue, Feb 07, 2017 at 04:41:21PM +0100, Michal Hocko wrote:
>> >> >On Tue 07-02-17 23:32:47, Wei Yang wrote:
>> >> >> On Tue, Feb 07, 2017 at 10:45:57AM +0100, Michal Hocko wrote:
>> >> >[...]
>> >> >> >Is there any reason why for_each_mem_pfn_range cannot be changed =
to
>> >> >> >honor the given start/end pfns instead? I can imagine that a smal=
l zone
>> >> >> >would see a similar pointless iterations...
>> >> >> >
>> >> >>=20
>> >> >> Hmm... No special reason, just not thought about this implementati=
on. And
>> >> >> actually I just do the similar thing as in zone_spanned_pages_in_n=
ode(), in
>> >> >> which also return 0 when there is no overlap.
>> >> >>=20
>> >> >> BTW, I don't get your point. You wish to put the check in
>> >> >> for_each_mem_pfn_range() definition?
>> >> >
>> >> >My point was that you are handling one special case (an empty zone) =
but
>> >> >the underlying problem is that __absent_pages_in_range might be wast=
ing
>> >> >cycles iterating over memblocks that are way outside of the given pfn
>> >> >range. At least this is my understanding. If you fix that you do not
>> >> >need the special case, right?
>> >> >--=20
>> >> >Michal Hocko
>> >> >SUSE Labs
>> >>=20
>> >> > Not really, sorry, this area is full of awkward and subtle code whe=
n new
>> >> > changes build on top of previous awkwardness/surprises. Any cleanup
>> >> > would be really appreciated. That is the reason I didn't like the
>> >> > initial check all that much.
>> >>=20
>> >> Looks my fetchmail failed to get your last reply. So I copied it here.
>> >>=20
>> >> Yes, the change here looks not that nice, while currently this is wha=
t I can't
>> >> come up with.
>> >
>> >THen I will suggest dropping this patch from the mmotm tree because it
>> >doesn't sound like a big improvement and I would encourage you or
>> >anybody else to take a deeper look and unclutter this area to be more
>> >readable and better maintainable.
>>=20
>> Hi, Michal
>>=20
>> I don't get your point, which part of the code makes you feel uncomforta=
ble?
>
>It adds a check which would better be handled at a different level. I've
>tried to explain what are my concerns about quick&dirty solutions in
>this area. I would agree to add the check as a immediate workaround if
>this had some measurable benefits but the changelog doesn't mention
>any. So I do not really see this as an improvement in the end. If we
>want to address the suboptimal code, let's do it properly rather than
>spewing ifs all over the code.

Yep, I agree that to pursuit a better solution in the project is our ultima=
te
goal.

First let me explain why it is not enough to add it in the "different level=
" .
As you mentioned, it would be better to add this check in
__absent_pages_in_range(). Yes, I agree this would be proper place to add
this check at first sight. While __absent_pages_in_range() return 0 is not a
guarantee the ZONE_MOVEABLE handling would get 0 absent_page . So if we add=
 the
check in __absent_pages_in_range(), we still need to add a check before
ZONE_MOVEABLE handling to avoid the iteration in this loop.

Here is a code snippet, I could come up with your suggestion.

	zone_absent_pages_in_node()
	=09
		__absent_pages_in_range()
			check zone and node overlap

		check zone and node overlap
		handle ZONE_MOVEABLE

Then let me explain why it is not necessary to add the check in
__absent_pages_in_range() now. Hmm... this looks a very good place to add t=
his
check, since it would guard all cases to avoid these invalid
iterations. While in current implementation zone_absent_pages_in_node() is =
the
only place where the (start_pfn =3D=3D end_pfn) could happen.

The __absent_pages_in_range() is invoked at three places:

* numa_meminfo_cover_memory()
* zone_absent_pages_in_node()
* absent_pages_in_range()

And looks the other two would have no chance to pass two equal parameters,
which falls into the check. So it looks not necessary to add a check here f=
or
more general cases. The detailed explanation is posted in this mail,
https://lkml.org/lkml/2017/2/8/337

Based on these two analysis, I choose to put the check outside
__absent_pages_in_range(), which makes the code look like this:

	zone_absent_pages_in_node()
	=09
		check zone and node overlap
		__absent_pages_in_range()

		handle ZONE_MOVEABLE

So only one check instead of two.

Last but not the least, yes, I agree with you that this check is better to
be put in a different level while it may not as good as we think for current
implementation.

Glad to discuss with you about these details. Not sure which one you like or
you don't like any of them?

>
>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--J2SCkAp4GZ/dPZZf
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJYrZ2cAAoJEKcLNpZP5cTd+L0QALTEA7ocdIrB1hayoDDPYr6j
fv8OLT/inrS0pWVXV91eg3Lh8hPxb3RZJDz+VV5eMN6LPSgVIVIlCfE00NJGhS/6
0Vg4p1DNqPqMrb+Glo4BL9tD04wp45NsMGU4kOfFSP5gNeCVY9hcCwjGznkFBJsd
Kosip82SBThPbTNLO4JTmw4WR/cu6TyCup503xKBdxcM+Lq2OVrzZawUC+EkVecl
zS/9Ixdmv+6I0RMNf+70qOhP3ju+j1HLnsN8XE60TSmzSgQY7rqixohKgCW5nGSB
ZJ6UrlNZMAoQA/Oed5QFxz385by3dB0COu3E95SxHVJGAEANKbCPcdkrkPMNo6cz
OaQWmNUQBIY8/hs17Sc8Liev4hl4yr+8X5bg7kpCWdvTqQGsZdbJIorYZNCJYvg8
AfUIv9AWSZOv2Nm4EkGWzQk0zGeo+3+4tm4NP2lSlr8EYqmv7bEJDl5ePbN/yVw6
wagTcGOybJZRZqA9+uGKcDrAirRipFNNIw/1c+uxo5DY+fMyJNOuJ/+sG87eMdW2
DJywg0wBhCc4IQHeWC8xF5zTVUYJy48Ygf9fQFWfCbPpD8eZgL57Xcpdwl4IQ3H9
n92MwibNRK1jquoSYuPq42INV6A0ivF+Cs2dMP9Mo/pTGOP+HUGiRmal+7sjAuHR
86lpnu5HhD/0dK+dwbCB
=qR9t
-----END PGP SIGNATURE-----

--J2SCkAp4GZ/dPZZf--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
