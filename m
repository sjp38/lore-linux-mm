Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id A03136B0089
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 20:32:47 -0500 (EST)
Received: by iwn5 with SMTP id 5so414665iwn.14
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 17:32:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101206105558.GA21406@csn.ul.ie>
References: <1291376734-30202-1-git-send-email-mel@csn.ul.ie>
	<1291376734-30202-2-git-send-email-mel@csn.ul.ie>
	<AANLkTi=ZXBXS2m0WCTNWT1t6EFi=Vji5t-yQG=fTJQgs@mail.gmail.com>
	<20101206105558.GA21406@csn.ul.ie>
Date: Tue, 7 Dec 2010 10:32:45 +0900
Message-ID: <AANLkTimvmbvZ-9RcLsefTqbq1ktm6=-XD1N6z4JHBh=v@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm: kswapd: Stop high-order balancing when any
 suitable zone is balanced
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Simon Kirby <sim@hostway.ca>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 6, 2010 at 7:55 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Mon, Dec 06, 2010 at 08:35:18AM +0900, Minchan Kim wrote:
>> Hi Mel,
>>
>> On Fri, Dec 3, 2010 at 8:45 PM, Mel Gorman <mel@csn.ul.ie> wrote:
>> > When the allocator enters its slow path, kswapd is woken up to balance=
 the
>> > node. It continues working until all zones within the node are balance=
d. For
>> > order-0 allocations, this makes perfect sense but for higher orders it=
 can
>> > have unintended side-effects. If the zone sizes are imbalanced, kswapd=
 may
>> > reclaim heavily within a smaller zone discarding an excessive number o=
f
>> > pages. The user-visible behaviour is that kswapd is awake and reclaimi=
ng
>> > even though plenty of pages are free from a suitable zone.
>> >
>> > This patch alters the "balance" logic for high-order reclaim allowing =
kswapd
>> > to stop if any suitable zone becomes balanced to reduce the number of =
pages
>> > it reclaims from other zones. kswapd still tries to ensure that order-=
0
>> > watermarks for all zones are met before sleeping.
>> >
>> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>>
>> <snip>
>>
>> > - =A0 =A0 =A0 if (!all_zones_ok) {
>> > + =A0 =A0 =A0 if (!(all_zones_ok || (order && any_zone_ok))) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0try_to_freeze();
>> > @@ -2361,6 +2366,31 @@ out:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto loop_again;
>> > =A0 =A0 =A0 =A0}
>> >
>> > + =A0 =A0 =A0 /*
>> > + =A0 =A0 =A0 =A0* If kswapd was reclaiming at a higher order, it has =
the option of
>> > + =A0 =A0 =A0 =A0* sleeping without all zones being balanced. Before i=
t does, it must
>> > + =A0 =A0 =A0 =A0* ensure that the watermarks for order-0 on *all* zon=
es are met and
>> > + =A0 =A0 =A0 =A0* that the congestion flags are cleared
>> > + =A0 =A0 =A0 =A0*/
>> > + =A0 =A0 =A0 if (order) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i <=3D end_zone; i++) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pg=
dat->node_zones + i;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone=
))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue=
;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (zone->all_unreclaima=
ble && priority !=3D DEF_PRIORITY)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue=
;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 zone_clear_flag(zone, ZO=
NE_CONGESTED);
>>
>> Why clear ZONE_CONGESTED?
>> If you have a cause, please, write down the comment.
>>
>
> It's because kswapd is the only mechanism that clears the congestion
> flag. If it's not cleared and kswapd goes to sleep, the flag could be
> left set causing hard-to-diagnose stalls. I'll add a comment.

Seems good.

>
>> <snip>
>>
>> First impression on this patch is that it changes scanning behavior as
>> well as reclaiming on high order reclaim.
>
> It does affect scanning behaviour for high-order reclaim. Specifically,
> it may stop scanning once a zone is balanced within the node. Previously
> it would continue scanning until all zones were balanced. Is this what
> you are thinking of or something else?

Yes. I mean page aging of high zones.

>
>> I can't say old behavior is right but we can't say this behavior is
>> right, too although this patch solves the problem. At least, we might
>> need some data that shows this patch doesn't have a regression.
>
> How do you suggest it be tested and this data be gathered? I tested a num=
ber of
> workloads that keep kswapd awake but found no differences of major signif=
icant
> even though it was using high-order allocations. The =A0problem with iden=
tifying
> small regressions for high-order allocations is that the state of the sys=
tem
> when lumpy reclaim starts is very important as it determines how much wor=
k
> has to be done. I did not find major regressions in performance.
>
> For the tests I did run;
>
> fsmark showed nothing useful. iozone showed nothing useful either as it d=
idn't
> even wake kswapd. sysbench showed minor performance gains and losses but =
it
> is not useful as it typically does not wake kswapd unless the database is
> badly configured.
>
> I ran postmark because it was the closest benchmark to a mail simulator I
> had access to. This sucks because it's no longer representative of a mail
> server and is more like a crappy filesystem benchmark. To get it closer t=
o a
> real server, there was also a program running in the background that mapp=
ed
> a large anonymous segment and scanned it in blocks.
>
> POSTMARK
> =A0 =A0 =A0 =A0 =A0 =A0postmark-traceonly-v3r1-postmarkpostmark-kanyzone-=
v2r6-postmark
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0traceonly-v3r1 =A0 =A0 kanyzone-v2r6
> Transactions per second: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A02.00 ( 0.00%) =A0=
 =A0 2.00 ( 0.00%)
> Data megabytes read per second: =A0 =A0 =A0 =A0 8.14 ( 0.00%) =A0 =A0 8.5=
9 ( 5.24%)
> Data megabytes written per second: =A0 =A0 18.94 ( 0.00%) =A0 =A019.98 ( =
5.21%)
> Files created alone per second: =A0 =A0 =A0 =A0 4.00 ( 0.00%) =A0 =A0 4.0=
0 ( 0.00%)
> Files create/transact per second: =A0 =A0 =A0 1.00 ( 0.00%) =A0 =A0 1.00 =
( 0.00%)
> Files deleted alone per second: =A0 =A0 =A0 =A034.00 ( 0.00%) =A0 =A030.0=
0 (-13.33%)

Do you know the reason only file deletion has a big regression?

> Files delete/transact per second: =A0 =A0 =A0 1.00 ( 0.00%) =A0 =A0 1.00 =
( 0.00%)
>
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds) =A0 =A0 =A0 =A0 152.4 =A0 =A0152.92
> Total Elapsed Time (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 5110.96 =A0 4847=
.22
>
> FTrace Reclaim Statistics: vmscan
> =A0 =A0 =A0 =A0 =A0 =A0postmark-traceonly-v3r1-postmarkpostmark-kanyzone-=
v2r6-postmark
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0traceonly-v3r1 =A0 =A0 kanyzone-v2r6
> Direct reclaims =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> Direct reclaim pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =
=A0 =A0 =A0 =A0 =A00
> Direct reclaim pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =
=A0 =A0 =A0 =A00
> Direct reclaim write file async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00
> Direct reclaim write anon async I/O =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =
=A0 =A0 =A00
> Direct reclaim write file sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00
> Direct reclaim write anon sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00
> Wake kswapd requests =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 0 =A0 =A0 =A0 =A0 =A00
> Kswapd wakeups =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A02177 =A0 =A0 =A0 2174
> Kswapd pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A034690766 =
=A0 34691473

Perhaps, in your workload, any_zone is highest zone.
If any_zone became low zone, kswapd pages scanned would have a big
difference because old behavior try to balance all zones.
Could we evaluate this situation? but I have no idea how we set up the
situation. :(

> Kswapd pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A034511965 =
=A0 34513478
> Kswapd reclaim write file async I/O =A0 =A0 =A0 =A0 =A0 =A0 32 =A0 =A0 =
=A0 =A0 =A00
> Kswapd reclaim write anon async I/O =A0 =A0 =A0 =A0 =A0 2357 =A0 =A0 =A0 =
2561
> Kswapd reclaim write file sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00
> Kswapd reclaim write anon sync I/O =A0 =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =
=A0 =A0 =A00
> Time stalled direct reclaim (seconds) =A0 =A0 =A0 =A0 0.00 =A0 =A0 =A0 0.=
00
> Time kswapd awake (seconds) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 632.10 =A0 =
=A0 683.34
>
> Total pages scanned =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 34690766 =
=A034691473
> Total pages reclaimed =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 34511965 =
=A034513478
> %age total pages scanned/reclaimed =A0 =A0 =A0 =A0 =A099.48% =A0 =A099.49=
%
> %age total pages scanned/written =A0 =A0 =A0 =A0 =A0 =A0 0.01% =A0 =A0 0.=
01%
> %age =A0file pages scanned/written =A0 =A0 =A0 =A0 =A0 =A0 0.00% =A0 =A0 =
0.00%
> Percentage Time Spent Direct Reclaim =A0 =A0 =A0 =A0 0.00% =A0 =A0 0.00%
> Percentage Time kswapd Awake =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A012.37% =A0 =
=A014.10%

Is "kswapd Awake" correct?
AFAIR, In your implementation, you seems to account kswapd time even
though kswapd are schedule out.
I mean, for example,

kswapd
-> time stamp start
-> balance_pgdat
-> cond_resched(kswapd schedule out)
-> app 1 start
-> app 2 start
-> kswapd schedule in
-> time stamp end.

If it's right, kswapd awake doesn't have a big meaning.

>
> proc vmstat: Faults
> =A0 =A0 =A0 =A0 =A0 =A0postmark-traceonly-v3r1-postmarkpostmark-kanyzone-=
v2r6-postmark
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0traceonly-v3r1 =A0 =A0 kanyzone-v2r6
> Major Faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A01979 =A0 =A0 =A01741
> Minor Faults =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01=
3660834 =A013587939
> Page ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 89060 =A0 =A0 74704
> Page outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A069800 =A0 =A0 58884
> Swap ins =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A01193 =A0 =A0 =A01499
> Swap outs =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 2403 =A0 =A0 =A02562
>
> Still, IO performance was improved (higher rates of read/write) and the t=
est
> completed significantly faster with this patch series applied. =A0kswapd =
was
> awake for longer and reclaimed marginally more pages with more swap-ins a=
nd

Longer wake may be due to wrong gathering of time as I said.

> swap-outs which is unfortunate but it's somewhat balanced by fewer faults
> and fewer page-ins. Basically, in terms of reclaim the figures are so clo=
se
> that it is within the performance variations lumpy reclaim has depending =
on
> the exact state of the system when reclaim starts.

What I wanted to see is that when if zones above any_zone isn't aging
how it affect system performance.
This patch is changing balancing mechanism of kswapd so I think the
experiment is valuable.
I don't want to make contributors to be tired by bad reviewer.
What do you think about that?

>
>> It's
>> not easy but I believe you can do very well as like having done until
>> now. I didn't see whole series so I might miss something.
>>
>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
