Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id A0AC26B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 06:00:21 -0500 (EST)
Received: by wicr5 with SMTP id r5so3750465wic.14
        for <linux-mm@kvack.org>; Tue, 24 Jan 2012 03:00:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120123170354.82b9f127.akpm@linux-foundation.org>
References: <CAJd=RBDVxT5Pc2HZjz15LUb7xhFbztpFmXqLXVB3nCoQLKHiHg@mail.gmail.com>
	<20120123170354.82b9f127.akpm@linux-foundation.org>
Date: Tue, 24 Jan 2012 19:00:19 +0800
Message-ID: <CAJd=RBByNhLSiBtyaYOHeMRQpXmAO=hEKTOanPTzrb2gRZTOSg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: fix malused nr_reclaimed in shrinking zone
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 24, 2012 at 9:03 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> Well, let's step back and look at it.
>
> - The multiple-definitions-of-a-local-per-line thing is generally a
> =C2=A0bad idea, partly because it prevents people from adding comments to
> =C2=A0the definition. =C2=A0It would be better like this:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long reclaimed =3D 0; =C2=A0 =C2=A0/*=
 total for this function */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D 0; /* on each p=
ass through the loop */
>
> - The names of these things are terrible! =C2=A0Why not
> =C2=A0reclaimed_this_pass and reclaimed_total or similar?
>
> - It would be cleaner to do the "reclaimed +=3D nr_reclaimed" at the
> =C2=A0end of the loop, if we've decided to goto restart. =C2=A0(But bette=
r
> =C2=A0to do it within the loop!)
>
> - Only need to update sc->nr_reclaimed at the end of the function
> =C2=A0(assumes that callees of this function aren't interested in
> =C2=A0sc->nr_reclaimed, which seems a future-safe assumption to me).
>
> - Should be able to avoid the temporary addition of nr_reclaimed to
> =C2=A0reclaimed inside the loop by updating `reclaimed' at an appropriate
> =C2=A0place.
>
>
> Or whatever. =C2=A0That code's handling of `reclaimed' and `nr_reclaimed'=
 is
> a twisty mess. =C2=A0Please clean it up! =C2=A0If it is done correctly,
> `nr_reclaimed' can (and should) be local to the internal loop.

Hi Andrew

The mess is cleaned up, please review again.

Thanks
Hillf


=3D=3D=3Dcut here=3D=3D=3D
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: vmscan: fix malused nr_reclaimed in shrinking zone

The value of nr_reclaimed is the amount of pages reclaimed in the current
round of loop, whereas nr_to_reclaim should be compared with pages reclaime=
d
in all rounds.

In each round of loop, reclaimed pages are cut off from the reclaim goal,
and loop stops once goal achieved.

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/vmscan.c	Mon Jan 23 00:23:10 2012
+++ b/mm/vmscan.c	Tue Jan 24 17:10:34 2012
@@ -2113,7 +2113,12 @@ restart:
 		 * with multiple processes reclaiming pages, the total
 		 * freeing target can get unreasonably large.
 		 */
-		if (nr_reclaimed >=3D nr_to_reclaim && priority < DEF_PRIORITY)
+		if (nr_reclaimed >=3D nr_to_reclaim)
+			nr_to_reclaim =3D 0;
+		else
+			nr_to_reclaim -=3D nr_reclaimed;
+
+		if (!nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
 	}
 	blk_finish_plug(&plug);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
