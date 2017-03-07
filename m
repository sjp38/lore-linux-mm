Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6D8C6B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 14:52:45 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id f191so19533093qka.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 11:52:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si916878qth.198.2017.03.07.11.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 11:52:40 -0800 (PST)
Message-ID: <1488916356.6405.4.camel@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Rik van Riel <riel@redhat.com>
Date: Tue, 07 Mar 2017 14:52:36 -0500
In-Reply-To: <20170307133057.26182-1-mhocko@kernel.org>
References: <20170307133057.26182-1-mhocko@kernel.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-VK4R86LtK6PJs5B0tUAu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--=-VK4R86LtK6PJs5B0tUAu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-03-07 at 14:30 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>=20
> Tetsuo Handa has reported [1][2] that direct reclaimers might get
> stuck
> in too_many_isolated loop basically for ever because the last few
> pages
> on the LRU lists are isolated by the kswapd which is stuck on fs
> locks
> when doing the pageout or slab reclaim. This in turn means that there
> is
> nobody to actually trigger the oom killer and the system is basically
> unusable.
>=20
> too_many_isolated has been introduced by 35cd78156c49 ("vmscan:
> throttle
> direct reclaim when too many pages are isolated already") to prevent
> from pre-mature oom killer invocations because back then no reclaim
> progress could indeed trigger the OOM killer too early. But since the
> oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
> the allocation/reclaim retry loop considers all the reclaimable pages
> and throttles the allocation at that layer so we can loosen the
> direct
> reclaim throttling.

It only does this to some extent. =C2=A0If reclaim made
no progress, for example due to immediately bailing
out because the number of already isolated pages is
too high (due to many parallel reclaimers), the code
could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
test without ever looking at the number of reclaimable
pages.

Could that create problems if we have many concurrent
reclaimers?

It may be OK, I just do not understand all the implications.

I like the general direction your patch takes the code in,
but I would like to understand it better...

--=20
All rights reversed

--=-VK4R86LtK6PJs5B0tUAu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYvw+FAAoJEM553pKExN6DgGcH+gKB8lybd0g8awJexA3cBeaZ
WLFj/xAIyBVvZwKiSkSPj0wOLOUZkWHI7vw4rO8Uu2AjEhgXB1yAz0No5dSYzECm
zgTxzdA1ONzxhGK1iA0g7uefvGBDRESOxU6z50VwkKfkBgWcHk0h0nVj9/FhyBfK
be0/hSAXDDh4GxdV7uR/+hc0Qj6U9ORyHUxgf9Evxh7UozQ0K7jDRaclgTB8Ilu7
t5FPRKBTz3k1zQEqLUQWp58V+kIuHRu2mnq64qD6r58AXeVZ14cnli/B0qRRLHSo
evY1kmUr8S1LwvqvJGmD8Mr0KoaQoN1wGCyWAt+SvDjpAgx0ZB2Pnp/oyr2fCBE=
=/ugz
-----END PGP SIGNATURE-----

--=-VK4R86LtK6PJs5B0tUAu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
