Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07E436B03D3
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 18:11:10 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j30so7046517qta.2
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 15:11:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u127si18925024qkd.249.2017.04.05.15.11.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 15:11:08 -0700 (PDT)
Message-ID: <1491430264.16856.43.camel@redhat.com>
Subject: Re: [PATCH] mm: vmscan: fix IO/refault regression in cache
 workingset transition
From: Rik van Riel <riel@redhat.com>
Date: Wed, 05 Apr 2017 18:11:04 -0400
In-Reply-To: <20170404220052.27593-1-hannes@cmpxchg.org>
References: <20170404220052.27593-1-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-ZVQRuuSzGMtMeuKPGMPj"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-ZVQRuuSzGMtMeuKPGMPj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-04-04 at 18:00 -0400, Johannes Weiner wrote:

> +
> +	/*
> +	=C2=A0* When refaults are being observed, it means a new
> workingset
> +	=C2=A0* is being established. Disable active list protection to
> get
> +	=C2=A0* rid of the stale workingset quickly.
> +	=C2=A0*/

This looks a little aggressive. What is this
expected to do when you have multiple workloads
sharing the same LRU, and one of the workloads
is doing refaults, while the other workload is
continuing to use the same working set as before?

I have been trying to wrap my mind around that for
the past day or so, and figure I should just ask
the question :)

> +	if (file && actual_reclaim && lruvec->refaults !=3D refaults)
> {
> +		inactive_ratio =3D 0;
> +	} else {
> +		gb =3D (inactive + active) >> (30 - PAGE_SHIFT);
> +		if (gb)
> +			inactive_ratio =3D int_sqrt(10 * gb);
> +		else
> +			inactive_ratio =3D 1;
> +	}

--=20
All rights reversed

--=-ZVQRuuSzGMtMeuKPGMPj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJY5Wt4AAoJEM553pKExN6DwZEH/3vYvvFtryLqCOy63GZcK9lS
ytfChfTSDqflsX9lIj06z1LVyQZbeDHO/NcKV8iQa7g2XKYq21piJEm4yfGfR9fT
bn0kyKZUhxYB7z8U4qV4mBG5gle2u1O5jxX83c2LGFf4FhueLpJdRZJtXBPb/aBR
ojSd+qAF/iVaFrjDlt21eEa0PB5K6QAKHZ2NrA+jGNHeWUVxh1mJUhrIVep+8kfj
/4WendQKIZNy5tMzvQWA4mxiV04+gpRMH/4DkKgBzpepCRC3jzKmc8QZi4DYmK1m
3vBJ+Gy3W6M9gKlnFJvFcBlnrynX3ChhKtLpsb1hszKgw43Y/5lHbWCJLB0arfw=
=qtdw
-----END PGP SIGNATURE-----

--=-ZVQRuuSzGMtMeuKPGMPj--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
