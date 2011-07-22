Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22F0E6B00E8
	for <linux-mm@kvack.org>; Thu, 21 Jul 2011 20:22:00 -0400 (EDT)
Received: by vxg38 with SMTP id 38so1896334vxg.14
        for <linux-mm@kvack.org>; Thu, 21 Jul 2011 17:21:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110721170112.GU5349@suse.de>
References: <1308926697-22475-1-git-send-email-mgorman@suse.de>
	<1308926697-22475-5-git-send-email-mgorman@suse.de>
	<20110719160903.GA2978@barrios-desktop>
	<20110720104847.GI5349@suse.de>
	<20110721153007.GC1713@barrios-desktop>
	<20110721160706.GS5349@suse.de>
	<20110721163649.GG1713@barrios-desktop>
	<20110721170112.GU5349@suse.de>
Date: Fri, 22 Jul 2011 09:21:57 +0900
Message-ID: <CAEwNFnB-JQpBctJxCUkO3WiTr7L3BTJfqirBRG8GOMrp79+cbA@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: Only read new_classzone_idx from pgdat
 when reclaiming successfully
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, P?draig Brady <P@draigbrady.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Andrew Lutomirski <luto@mit.edu>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Fri, Jul 22, 2011 at 2:01 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Fri, Jul 22, 2011 at 01:36:49AM +0900, Minchan Kim wrote:
>> > > > <SNIP>
>> > > > @@ -2740,17 +2742,23 @@ static int kswapd(void *p)
>> > > > =C2=A0 =C2=A0 =C2=A0 tsk->flags |=3D PF_MEMALLOC | PF_SWAPWRITE | =
PF_KSWAPD;
>> > > > =C2=A0 =C2=A0 =C2=A0 set_freezable();
>> > > >
>> > > > - =C2=A0 =C2=A0 order =3D 0;
>> > > > - =C2=A0 =C2=A0 classzone_idx =3D MAX_NR_ZONES - 1;
>> > > > + =C2=A0 =C2=A0 order =3D new_order =3D 0;
>> > > > + =C2=A0 =C2=A0 classzone_idx =3D new_classzone_idx =3D pgdat->nr_=
zones - 1;
>> > > > =C2=A0 =C2=A0 =C2=A0 for ( ; ; ) {
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long new_orde=
r;
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int new_classzone_idx;
>> > > > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int ret;
>> > > >
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new_order =3D pgdat->k=
swapd_max_order;
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 new_classzone_idx =3D =
pgdat->classzone_idx;
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgdat->kswapd_max_orde=
r =3D 0;
>> > > > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgdat->classzone_idx =
=3D MAX_NR_ZONES - 1;
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If the last ba=
lance_pgdat was unsuccessful it's unlikely a
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* new request of=
 a similar or harder type will succeed soon
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* so consider go=
ing to sleep on the basis we reclaimed at
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (classzone_idx >=3D=
 new_classzone_idx && order =3D=3D new_order) {
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 new_order =3D pgdat->kswapd_max_order;
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 new_classzone_idx =3D pgdat->classzone_idx;
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pgdat->kswapd_max_order =3D =C2=A00;
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 pgdat->classzone_idx =3D pgdat->nr_zones - 1;
>> > > > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > > > +
>> > >
>> > > But in this part.
>> > > Why do we need this?
>> >
>> > Lets say it's a fork-heavy workload and it is routinely being woken
>> > for order-1 allocations and the highest zone is very small. For the
>> > most part, it's ok because the allocations are being satisfied from
>> > the lower zones which kswapd has no problem balancing.
>> >
>> > However, by reading the information even after failing to
>> > balance, kswapd continues balancing for order-1 due to reading
>> > pgdat->kswapd_max_order, each time failing for the highest zone. It
>> > only takes one wakeup request per balance_pgdat() to keep kswapd
>> > awake trying to balance the highest zone in a continual loop.
>>
>> You made balace_pgdat's classzone_idx as communicated back so classzone_=
idx returned
>> would be not high zone and in [1/4], you changed that sleeping_premature=
ly consider only
>> classzone_idx not nr_zones. So I think it should sleep if low zones is b=
alanced.
>>
>
> If a wakeup for order-1 happened during the last pgdat, the
> classzone_idx as communicated back from balance_pgdat() is lost and it
> will not sleep in this ordering of events
>
> kswapd =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0other processes
> =3D=3D=3D=3D=3D=3D =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
> order =3D balance_pgdat(pgdat, order, &classzone_idx);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wakeup for order-1
> kswapd balances lower zone
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0allocate from lower zone
> balance_pgdat fails balance for highest zone, returns
> =C2=A0 =C2=A0 =C2=A0 =C2=A0with lower classzone_idx and possibly lower or=
der
> new_order =3D pgdat->kswapd_max_order =C2=A0 =C2=A0 =C2=A0(order =3D=3D 1=
)
> new_classzone_idx =3D pgdat->classzone_idx (highest zone)
> if (order < new_order || classzone_idx > new_classzone_idx) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0order =3D new_order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0classzone_idx =3D new_classzone_idx; (failure =
from balance_pgdat() lost)
> }
> order =3D balance_pgdat(pgdat, order, &classzone_idx);
>
> The wakup for order-1 at any point during balance_pgdat() is enough to
> keep kswapd awake even though the process that called wakeup_kswapd
> would be able to allocate from the lower zones without significant
> difficulty.
>
> This is why if balance_pgdat() fails its request, it should go to sleep
> if watermarks for the lower zones are met until woken by another
> process.

Hmm.

The role of kswapd is to reclaim pages by background until all of zone
meet HIGH_WMARK to prevent costly direct reclaim.(Of course, there is
another reason like GFP_ATOMIC). So it's not wrong to consume many cpu
usage by design unless other tasks are ready. It would be balanced or
unreclaimable at last so it should end up. However, the problem is
small part of highest zone is easily [set|reset] to be
all_unreclaimabe so the situation could be forever like our example.
So fundamental solution is to prevent it that all_unreclaimable is
set/reset easily, I think.
Unfortunately it have no idea now.

In different viewpoint,  the problem is that it's too excessive
because kswapd is just best-effort and if it got fails, we have next
wakeup and even direct reclaim as last resort. In such POV, I think
this patch is right and it would be a good solution. Then, other
concern is on your reply about KOSAKI's question.

I think below your patch is needed.

Quote from
"
1. Read for balance-request-A (order, classzone) pair
2. Fail balance_pgdat
3. Sleep based on (order, classzone) pair
4. Wake for balance-request-B (order, classzone) pair where
  balance-request-B !=3D balance-request-A
5. Succeed balance_pgdat
6. Compare order,classzone with balance-request-A which will treat
  balance_pgdat() as fail and try go to sleep

This is not the same as new_classzone_idx being "garbage" but is it
what you mean? If so, is this your proposed fix?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index fe854d7..1a518e6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2770,6 +2770,8 @@ static int kswapd(void *p)
                       kswapd_try_to_sleep(pgdat, order, classzone_idx);
                       order =3D pgdat->kswapd_max_order;
                       classzone_idx =3D pgdat->classzone_idx;
+                       new_order =3D order;
+                       new_classzone_idx =3D classzone_idx;
"



-
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
