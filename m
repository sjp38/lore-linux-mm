Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E876C6B0311
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 22:10:39 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e131so28829pfh.7
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 19:10:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor109349pfl.39.2017.06.06.19.10.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Jun 2017 19:10:38 -0700 (PDT)
Date: Wed, 7 Jun 2017 10:10:36 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170607015909.GA6596@WeideMBP.lan>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
 <20170603022440.GA11080@WeideMacBook-Pro.local>
 <20170605064343.GE9248@dhcp22.suse.cz>
 <20170606030401.GA2259@WeideMacBook-Pro.local>
 <20170606120314.GL1189@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="f2QGlHpHGjS2mn6Y"
Content-Disposition: inline
In-Reply-To: <20170606120314.GL1189@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>


--f2QGlHpHGjS2mn6Y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 06, 2017 at 02:03:15PM +0200, Michal Hocko wrote:
>On Tue 06-06-17 11:04:01, Wei Yang wrote:
>> On Mon, Jun 05, 2017 at 08:43:43AM +0200, Michal Hocko wrote:
>> >On Sat 03-06-17 10:24:40, Wei Yang wrote:
>> >> Hi, Michal
>> >>=20
>> >> Just go through your patch.
>> >>=20
>> >> I have one question and one suggestion as below.
>> >>=20
>> >> One suggestion:
>> >>=20
>> >> This patch does two things to me:
>> >> 1. Replace __GFP_REPEAT with __GFP_RETRY_MAYFAIL
>> >> 2. Adjust the logic in page_alloc to provide the middle semantic
>> >>=20
>> >> My suggestion is to split these two task into two patches, so that re=
aders
>> >> could catch your fundamental logic change easily.
>> >
>> >Well, the rename and the change is intentionally tight together. My
>> >previous patches have removed all __GFP_REPEAT users for low order
>> >requests which didn't have any implemented semantic. So as of now we
>> >should only have those users which semantic will not change. I do not
>> >add any new low order user in this patch so it in fact doesn't change
>> >any existing semnatic.
>> >
>> >>=20
>> >> On Tue, Mar 07, 2017 at 04:48:41PM +0100, Michal Hocko wrote:
>> >> >From: Michal Hocko <mhocko@suse.com>
>> >[...]
>> >> >@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigne=
d int order,
>> >> >=20
>> >> > 	/*
>> >> > 	 * Do not retry costly high order allocations unless they are
>> >> >-	 * __GFP_REPEAT
>> >> >+	 * __GFP_RETRY_MAYFAIL
>> >> > 	 */
>> >> >-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>> >> >+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MA=
YFAIL))
>> >> > 		goto nopage;
>> >>=20
>> >> One question:
>> >>=20
>> >> From your change log, it mentions will provide the same semantic for =
!costly
>> >> allocations. While the logic here is the same as before.
>> >>=20
>> >> For a !costly allocation with __GFP_REPEAT flag, the difference after=
 this
>> >> patch is no OOM will be invoked, while it will still continue in the =
loop.
>> >
>> >Not really. There are two things. The above will shortcut retrying if
>> >there is _no_ __GFP_RETRY_MAYFAIL. If the flags _is_ specified we will
>> >back of in __alloc_pages_may_oom.
>> >=20
>> >> Maybe I don't catch your point in this message:
>> >>=20
>> >>   __GFP_REPEAT was designed to allow retry-but-eventually-fail semant=
ic to
>> >>   the page allocator. This has been true but only for allocations req=
uests
>> >>   larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
>> >>   smaller sizes. This is a bit unfortunate because there is no way to
>> >>   express the same semantic for those requests and they are considere=
d too
>> >>   important to fail so they might end up looping in the page allocato=
r for
>> >>   ever, similarly to GFP_NOFAIL requests.
>> >>=20
>> >> I thought you will provide the same semantic to !costly allocation, o=
r I
>> >> misunderstand?
>> >
>> >yes and that is the case. __alloc_pages_may_oom will back off before OOM
>> >killer is invoked and the allocator slow path will fail because
>> >did_some_progress =3D=3D 0;
>>=20
>> Thanks for your explanation.
>>=20
>> So same "semantic" doesn't mean same "behavior".
>> 1. costly allocations will pick up the shut cut
>
>yes and there are no such allocations yet (based on my previous
>cleanups)
>
>> 2. !costly allocations will try something more but finally fail without
>> invoking OOM.
>
>no, the behavior will not change for those.
>=20

Hmm... Let me be more specific. With two factors, costly or not, flag set or
not, we have four combinations. Here it is classified into two categories.

1. __GFP_RETRY_MAYFAIL not set

Brief description on behavior:
    costly: pick up the shortcut, so no OOM
    !costly: no shortcut and will OOM I think

Impact from this patch set:
    No.
   =20
My personal understanding:
    The allocation without __GFP_RETRY_MAYFAIL is not effected by this patch
    set.  Since !costly allocation will trigger OOM, this is the reason why
    "small allocations never fail _practically_", as mentioned in
    https://lwn.net/Articles/723317/.


3. __GFP_RETRY_MAYFAIL set

Brief description on behavior:
    costly/!costly: no shortcut here and no OOM invoked

Impact from this patch set:
    For those allocations with __GFP_RETRY_MAYFAIL, OOM is not invoked for
    both.

My personal understanding:
    This is the semantic you are willing to introduce in this patch set. By
    cutting off the OOM invoke when __GFP_RETRY_MAYFAIL is set, you makes t=
his
    a middle situation between NOFAIL and NORETRY.
   =20
    page_alloc will try some luck to get some free pages without disturb ot=
her
    part of the system. By doing so, the never fail allocation for !costly
    pages will be "fixed". If I understand correctly, you are willing to ma=
ke
    this the default behavior in the future?

>> Hope this time I catch your point.
>>=20
>> BTW, did_some_progress mostly means the OOM works to me. Are there some =
other
>> important situations when did_some_progress is set to 1?
>
>Yes e.g. for GFP_NOFS when we cannot really invoke the OOM killer yet we
>cannot fail the allocation.


Thanks, currently I have a clear concept on this, while I will remember thi=
s :)

>--=20
>Michal Hocko
>SUSE Labs

--=20
Wei Yang
Help you, Help me

--f2QGlHpHGjS2mn6Y
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZN2CcAAoJEKcLNpZP5cTd6HEP/jwpo7yxd76S0J3NxODu5QoY
L7QWWgFpj9UBTheVizOA/SBUuWmFj+Qlh875JbJGmKkvfe8Q9q0u1QMEbwzUROSx
a6AknvrF92MBrraToPj7uBeoADNFi084yclOAzPDbMiaXCuMfnazdxP2yOUCHksT
BnUzWw3JuuWVVH2LE1qCbA3p/nHoEAO2lPfS5AXoK4Br8SG7SrkYtdAR194dF+0p
FLRyjsRM1XLI9uN0JglonWqGVUj19A1p6JJDjz4FS6bCtA5KcZaNo/9x1T+siPrT
7mT5M48BzB5Aq+9SvD2THE1QSjlyEDKTvh0wmL5Ts7pq8DYzjIHTv+6Bt4FDxMv2
Zl9AA3+OOgzri1LfurPKbhb8uz5Z2NBlnZEOo87h6YMT+h2kGRddyXDXTjU4dT3i
kP1ayuMWcp191yxUgQxVJFQsJ1d4MS3IVuDwyNl6QrpztZcOMqQsPadVZ07azOil
fOxPB22n933mWjVWLGEZvqgOBhHCdgN/LNKUvS5aNpNYwc73DvFK8Jqspti16XaY
dMg+AaLmKE9uuHQmZ63RI2Wu7KGuyDcRUTJMTX7h8tXrM13eYeQD2SjrBYHBIEQV
gz3BcZaLtOk/knQJDkl5b/q6cBC+ub7LZBF4Eku3wbXpCtft0v4qbpT4toLl8zPc
abp1M0PAkUP9mQAWJpPf
=gEot
-----END PGP SIGNATURE-----

--f2QGlHpHGjS2mn6Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
