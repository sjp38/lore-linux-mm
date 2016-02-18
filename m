Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7C812828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 15:15:47 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id b67so45996673qgb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:15:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f195si9733351qhf.20.2016.02.18.12.15.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 12:15:46 -0800 (PST)
Message-ID: <1455826543.15821.64.camel@redhat.com>
Subject: Re: [PATCH] mm: scale kswapd watermarks in proportion to memory
From: Rik van Riel <riel@redhat.com>
Date: Thu, 18 Feb 2016 15:15:43 -0500
In-Reply-To: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
References: <1455813719-2395-1-git-send-email-hannes@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-57Mc5GhvV2xcBuxfTKcR"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--=-57Mc5GhvV2xcBuxfTKcR
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-02-18 at 11:41 -0500, Johannes Weiner wrote:
> In machines with 140G of memory and enterprise flash storage, we have
> seen read and write bursts routinely exceed the kswapd watermarks and
> cause thundering herds in direct reclaim. Unfortunately, the only way
> to tune kswapd aggressiveness is through adjusting min_free_kbytes -
> the system's emergency reserves - which is entirely unrelated to the
> system's latency requirements. In order to get kswapd to maintain a
> 250M buffer of free memory, the emergency reserves need to be set to
> 1G. That is a lot of memory wasted for no good reason.
>=20
> On the other hand, it's reasonable to assume that allocation bursts
> and overall allocation concurrency scale with memory capacity, so it
> makes sense to make kswapd aggressiveness a function of that as well.
>=20
> Change the kswapd watermark scale factor from the currently fixed 25%
> of the tunable emergency reserve to a tunable 0.001% of memory.
>=20
> On a 140G machine, this raises the default watermark steps - the
> distance between min and low, and low and high - from 16M to 143M.

This is an excellent idea for a large system,
but your patch reduces the gap between watermarks
on small systems.

On an 8GB zone, your patch halves the gap between
the watermarks, and on smaller systems it would be
even worse.

Would it make sense to keep using the old calculation
on small systems, when the result of the old calculation
exceeds that of the new calculation?

Using the max of the two calculations could prevent
the issue you are trying to prevent on large systems,
from happening on smaller systems.

--=C2=A0
All rights reversed

--=-57Mc5GhvV2xcBuxfTKcR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWxiZvAAoJEM553pKExN6DEd4IAKfvPU+SmZPsBhBFQDqS1l0U
GaVBi42xWCa1SjJeNqUacGkYGI6KXhYhSGxXO/8fhGCmSiFxUvhInQNUfpHOl4eY
t50ZQg0OskG1dTtMnjS+fs5hMRDAFCDoHuSsdYUqrOEfO5tc0SAFtgjSEhF/EZmy
XaxITKE7bnNCX9qXxPNtfdV9ZodZvwvYMqJX/rzuFoVg0s5amfYlZEBJLalKAmSy
tO1HMRfJnHdd4r9OQFhBkAe1TKj/nbGrm+XimUd+fUvl+aRu1Z/k+uBaZ9N087mu
l7KYc7aPZjY0W1EZDkWjuoGw3RS9UI0AG+E43SBiotNH4OvZuia1IYezpRUp3ME=
=Rqrm
-----END PGP SIGNATURE-----

--=-57Mc5GhvV2xcBuxfTKcR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
