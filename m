Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 729666B0035
	for <linux-mm@kvack.org>; Fri, 18 Jul 2014 14:52:04 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id w10so5495250pde.18
        for <linux-mm@kvack.org>; Fri, 18 Jul 2014 11:52:04 -0700 (PDT)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id bo7si3429545pdb.350.2014.07.18.11.52.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jul 2014 11:52:03 -0700 (PDT)
Message-ID: <53C96CBF.4040705@gentoo.org>
Date: Fri, 18 Jul 2014 14:51:43 -0400
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: unlock_page page when forcing reclaim
References: <1405698484-25803-1-git-send-email-ryao@gentoo.org> <20140718163843.GK29639@cmpxchg.org>
In-Reply-To: <20140718163843.GK29639@cmpxchg.org>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="jjTcQp912hMWAdKmHvq9iRFEEFl61uANL"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, mthode@mthode.org, kernel@gentoo.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Glauber Costa <glommer@openvz.org>, Rik van Riel <riel@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Dave Chinner <dchinner@redhat.com>, open@kvack.org, list@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--jjTcQp912hMWAdKmHvq9iRFEEFl61uANL
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 07/18/2014 12:38 PM, Johannes Weiner wrote:
> I don't really understand how the scenario you describe can happen.
>=20
> Successfully reclaiming a page means that __remove_mapping() was able
> to freeze a page count of 2 (page cache and LRU isolation), but
> filemap_fault() increases the refcount on the page before trying to
> lock the page.  If __remove_mapping() wins, find_get_page() does not
> work and the fault does not lock the page.  If find_get_page() wins,
> __remove_mapping() does not work and the reclaimer aborts and does a
> regular unlock_page().
>=20
> page_check_references() is purely about reclaim strategy, it should
> not be essential for correctness.
>=20

You are right that something else is happened here. I had not spotted
the cmpxchg being done in __remove_mapping(). If I spot something that
looks like it could be what went wrong doing this, I will propose a new
fix to the list for review. Thanks for your time.

P.S. The system had ECC RAM, so this was not a bit flip. My current
method for debugging this involves using cscope to construct possible
call paths under a couple of assumptions:

1. Something set PG_locked without calling unlock_page().
2. The only ways of doing #1 that I see in the code are calling
__clear_page_locked() or failing to clear the bit. I do not believe that
a patch was accepted that did the latter, so I assume the former.

I have root access to the system, so each time I do a lookup using
cscope, I go through the list to logically eliminate possibilities by
inspecting the system where the problem occurred. When I cannot
eliminate a possibility, I recurse. This is prone to fail positives
should I miss a subtle piece of code that prevents a problem and it is
very tedious, but I do not see a better way of debugging based on what I
have at my disposal. If anyone has any suggestions, I would appreciate th=
em.

P.P.S. I *really* wish that I had used kdump when this issue happened,
but sadly, the system is not setup for kdump.


--jjTcQp912hMWAdKmHvq9iRFEEFl61uANL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJTyWzFAAoJECDuEZm+6Exk/8sQAIYPMg5bpwXGy+/RUpna+4LB
/AbRawUJ3PHLWqHIHhtiYPjTZQVMzuQwR17aGwMf0MwqDmsIpZWH21HO8PS37+Mr
PYCedqeB/fJJA0JXjUu0CIKYTz2Nq+v3+lQQ8xguNlPeUiGEAO+zCftWcn1pAY0c
GguXEBiyCmzHO5Qy7hh3RIUqqN8sUEXiOqoJejE1aJnJW6XI+xHJo2nIzvtVawcP
nWwjEE0QGh7ESILcw5SUddP1eGNZHiAzkHT3mBb4I5Yb38Rw4Vo0ETsaH4BKtL/A
TNuaH4aZTlEW9dXs473ABnmTLcBoWjP51C7v2JMCFYidjP0TcDRNq7SJZne7ZL41
fSAu/0Fw1ntP3Ls6dGL1waKm0LCNtitcTqHaz+gnIsGkwcg5db3Vc2pHk37fuYqk
bM37yQSJvXbp5GTJWjii8WoArswsxqzr6X40iHkFgSn534VjK2WHPjWK2wtQ0k1J
VVQrHarENMxjIDPw2uwe1iKw4Nu/dWKcwK+AoFT73s5U780hTcUEPHGz2m0CBMP4
lu1x69VCEuVj5mvKbpICt0sHEJWi50pfJ7oRpPK9voEempMr0Yx3e0Zhgq5Hx9ZV
oLQfVE6KRFYPyrhyOyE/QDzBjbv1jYir9xIo7uyCYf2075RxU6SBHmrtA+RIxyqV
rrcQ75trtZ31MjcbNF7b
=WAN3
-----END PGP SIGNATURE-----

--jjTcQp912hMWAdKmHvq9iRFEEFl61uANL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
