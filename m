Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id DD14B2808E3
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 17:18:04 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id c85so159170128qkg.0
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 14:18:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q88si6651453qkh.92.2017.03.09.14.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 14:18:04 -0800 (PST)
Message-ID: <1489097880.1906.16.camel@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Rik van Riel <riel@redhat.com>
Date: Thu, 09 Mar 2017 17:18:00 -0500
In-Reply-To: <20170309180540.GA8678@cmpxchg.org>
References: <20170307133057.26182-1-mhocko@kernel.org>
	 <1488916356.6405.4.camel@redhat.com> <20170309180540.GA8678@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-64qKgzGHRcnpQtIViQFI"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--=-64qKgzGHRcnpQtIViQFI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-03-09 at 13:05 -0500, Johannes Weiner wrote:
> On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> >=20
> > It only does this to some extent. =C2=A0If reclaim made
> > no progress, for example due to immediately bailing
> > out because the number of already isolated pages is
> > too high (due to many parallel reclaimers), the code
> > could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> > test without ever looking at the number of reclaimable
> > pages.
> Hm, there is no early return there, actually. We bump the loop
> counter
> every time it happens, but then *do* look at the reclaimable pages.

Am I looking at an old tree? =C2=A0I see this code
before we look at the reclaimable pages.

=C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* Make sure we conver=
ge to OOM if we cannot make any progress
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0* several times in th=
e row.
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0*/
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (*no_progress_loops > MA=
X_RECLAIM_RETRIES) {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0/* Before OOM, exhaust highatomic_reserve */
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0return unreserve_highatomic_pageblock(ac, true);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}

> > Could that create problems if we have many concurrent
> > reclaimers?
> With increased concurrency, the likelihood of OOM will go up if we
> remove the unlimited wait for isolated pages, that much is true.
>=20
> I'm not sure that's a bad thing, however, because we want the OOM
> killer to be predictable and timely. So a reasonable wait time in
> between 0 and forever before an allocating thread gives up under
> extreme concurrency makes sense to me.

That is a fair point, a faster OOM kill is preferable
to a system that is livelocked.

> Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
> behind this patch. Can we think about a general model to deal with
> allocation concurrency? Unlimited parallel direct reclaim is kinda
> bonkers in the first place. How about checking for excessive
> isolation
> counts from the page allocator and putting allocations on a
> waitqueue?

The (limited) number of reclaimers can still do a
relatively fast OOM kill, if none of them manage
to make progress.

That should avoid the potential issue you and I
both pointed out, and, as a bonus, it might actually
be faster than letting all the tasks in the system
into the direct reclaim code simultaneously.

--=20
All rights reversed

--=-64qKgzGHRcnpQtIViQFI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJYwdSZAAoJEM553pKExN6DasQH/3sWPd/kNBkE1EM1WInU26F1
pmD6DLP6oW+oacwyASj1P9q8RZ8RGTWlagG7mUK42ntbON2CO+4OOTgLRjU6EjSX
19XQR44JLkmbXz/E05IJNiUwtvNfKFuwmKq6UH3Q3ftfBvsUMoRx+ACsGXaaITxQ
hezAB2DKkKixZbvRlq1PxWCzNlIAm7xKeG+22dQq0ruiYApzi5gRwtWWYhUxKiCg
dF16UxR93KkGK8tcU5/v1hNBpS9hWT2hm5FRUvtbM2o58Hm1wz4r2rBa9JWYerAv
dwSBBBpGNKO9aQDf+H+GkmgtXZHQjHU/HJdJ4NineI27axB60t6iWowJnnRcpRw=
=YxQ3
-----END PGP SIGNATURE-----

--=-64qKgzGHRcnpQtIViQFI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
