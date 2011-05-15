Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EA376B0024
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:58:03 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1402606qyk.14
        for <linux-mm@kvack.org>; Sun, 15 May 2011 15:58:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinYGwRa_7uGzbYq+pW3T7jL-nQ7sA@mail.gmail.com>
References: <BANLkTi=XqROAp2MOgwQXEQjdkLMenh_OTQ@mail.gmail.com>
	<m2fwokj0oz.fsf@firstfloor.org>
	<BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
	<20110512054631.GI6008@one.firstfloor.org>
	<BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
	<BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com>
	<20110514165346.GV6008@one.firstfloor.org>
	<BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com>
	<20110514174333.GW6008@one.firstfloor.org>
	<BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com>
	<20110515152747.GA25905@localhost>
	<BANLkTinYGwRa_7uGzbYq+pW3T7jL-nQ7sA@mail.gmail.com>
Date: Mon, 16 May 2011 07:58:01 +0900
Message-ID: <BANLkTinEC1uhZRXjjn1PzENNs7KtGcoQow@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, May 16, 2011 at 12:59 AM, Andrew Lutomirski <luto@mit.edu> wrote:
> I have no clue, but this patch (from Minchan, whitespace-damaged) seems t=
o help:
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f6b435c..4d24828 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t
> *pgdat, int order, long remaining,
> =C2=A0 =C2=A0 =C2=A0 unsigned long balanced =3D 0;
> =C2=A0 =C2=A0 =C2=A0 bool all_zones_ok =3D true;
>
> + =C2=A0 =C2=A0 =C2=A0 /* If kswapd has been running too long, just sleep=
 */
> + =C2=A0 =C2=A0 =C2=A0 if (need_resched())
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
> +
> =C2=A0 =C2=A0 =C2=A0 /* If a direct reclaimer woke kswapd within HZ/10, i=
t's premature */
> =C2=A0 =C2=A0 =C2=A0 if (remaining)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return true;
> @@ -2286,7 +2290,7 @@ static bool sleeping_prematurely(pg_data_t
> *pgdat, int order, long remaining,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0* must be balanced
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> =C2=A0 =C2=A0 =C2=A0 if (order)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return pgdat_balanced(=
pgdat, balanced, classzone_idx);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !pgdat_balanced=
(pgdat, balanced, classzone_idx);
> =C2=A0 =C2=A0 =C2=A0 else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return !all_zones_ok;
> =C2=A0}
>
> I haven't tested it very thoroughly, but it's survived much longer
> than an unpatched kernel probably would have under moderate use.
>
> I have no idea what the patch does :)

The reason I sent this is that I think your problem is similar to
recent Jame's one.
https://lkml.org/lkml/2011/4/27/361

What the patch does is [1] fix of "wrong pgdat_balanced return value"
bug and [2] fix of "infinite kswapd bug of non-preemption kernel" on
high-order page.

About [1], kswapd have to sleep if zone balancing is completed but in
1741c877[mm: kswapd: keep kswapd awake for high-order allocations
until a percentage of the node is balanced], we made a mistake that
returns wrong return.
Then, although we complete zone balancing, kswapd doesn't sleep and
calls balance_pgdat. In this case, balance_pgdat rerurns without any
work and kswapd could repeat this work infinitely.


>
> I'm happy to run any tests. =C2=A0I'm also planning to upgrade from 2GB t=
o
> 8GB RAM soon, which might change something.
>
> --Andy
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
