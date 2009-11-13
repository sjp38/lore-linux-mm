Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 76A466B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 09:48:59 -0500 (EST)
Received: by pwi9 with SMTP id 9so2379319pwi.6
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:48:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113135443.GF29804@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie>
	 <1258054235-3208-6-git-send-email-mel@csn.ul.ie>
	 <20091113142608.33B9.A69D9226@jp.fujitsu.com>
	 <20091113135443.GF29804@csn.ul.ie>
Date: Fri, 13 Nov 2009 23:48:57 +0900
Message-ID: <28c262360911130648q7b615ad4if75b902ed25d5fbd@mail.gmail.com>
Subject: Re: [PATCH 5/5] vmscan: Take order into consideration when deciding
	if kswapd is in trouble
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 13, 2009 at 10:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Fri, Nov 13, 2009 at 06:54:29PM +0900, KOSAKI Motohiro wrote:
>> > If reclaim fails to make sufficient progress, the priority is raised.
>> > Once the priority is higher, kswapd starts waiting on congestion.
>> > However, on systems with large numbers of high-order atomics due to
>> > crappy network cards, it's important that kswapd keep working in
>> > parallel to save their sorry ass.
>> >
>> > This patch takes into account the order kswapd is reclaiming at before
>> > waiting on congestion. The higher the order, the longer it is before
>> > kswapd considers itself to be in trouble. The impact is that kswapd
>> > works harder in parallel rather than depending on direct reclaimers or
>> > atomic allocations to fail.
>> >
>> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > ---
>> > =A0mm/vmscan.c | =A0 14 ++++++++++++--
>> > =A01 files changed, 12 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index ffa1766..5e200f1 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -1946,7 +1946,7 @@ static int sleeping_prematurely(int order, long =
remaining)
>> > =A0static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
>> > =A0{
>> > =A0 =A0 int all_zones_ok;
>> > - =A0 int priority;
>> > + =A0 int priority, congestion_priority;
>> > =A0 =A0 int i;
>> > =A0 =A0 unsigned long total_scanned;
>> > =A0 =A0 struct reclaim_state *reclaim_state =3D current->reclaim_state=
;
>> > @@ -1967,6 +1967,16 @@ static unsigned long balance_pgdat(pg_data_t *p=
gdat, int order)
>> > =A0 =A0 =A0*/
>> > =A0 =A0 int temp_priority[MAX_NR_ZONES];
>> >
>> > + =A0 /*
>> > + =A0 =A0* When priority reaches congestion_priority, kswapd will slee=
p
>> > + =A0 =A0* for a short time while congestion clears. The higher the
>> > + =A0 =A0* order being reclaimed, the less likely kswapd will go to
>> > + =A0 =A0* sleep as high-order allocations are harder to reclaim and
>> > + =A0 =A0* stall direct reclaimers longer
>> > + =A0 =A0*/
>> > + =A0 congestion_priority =3D DEF_PRIORITY - 2;
>> > + =A0 congestion_priority -=3D min(congestion_priority, sc.order);
>>
>> This calculation mean
>>
>> =A0 =A0 =A0 sc.order =A0 =A0 =A0 =A0congestion_priority =A0 =A0 scan-pag=
es
>> =A0 =A0 =A0 ---------------------------------------------------------
>> =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A01/1024 * zone-mem
>> =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/512 =A0* zone-mem
>> =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/256 =A0* zone-mem
>> =A0 =A0 =A0 3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/128 =A0* zone-mem
>> =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/64 =A0 * zone-mem
>> =A0 =A0 =A0 5 =A0 =A0 =A0 =A0 =A0 =A0 =A0 5 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/32 =A0 * zone-mem
>> =A0 =A0 =A0 6 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/16 =A0 * zone-mem
>> =A0 =A0 =A0 7 =A0 =A0 =A0 =A0 =A0 =A0 =A0 3 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/8 =A0 =A0* zone-mem
>> =A0 =A0 =A0 8 =A0 =A0 =A0 =A0 =A0 =A0 =A0 2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/4 =A0 =A0* zone-mem
>> =A0 =A0 =A0 9 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1/2 =A0 =A0* zone-mem
>> =A0 =A0 =A0 10 =A0 =A0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1 =A0 =A0 =A0* zone-mem
>> =A0 =A0 =A0 11+ =A0 =A0 =A0 =A0 =A0 =A0 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 1 =A0 =A0 =A0* zone-mem
>>
>> I feel this is too agressive. The intention of this congestion_wait()
>> is to prevent kswapd use 100% cpu time.

As I said in reply of kosaki's patch, I can't understand point.

> Ok, I thought the intention might be to avoid dumping too many pages on
> the queue but it was already waiting on congestion elsewhere.
>
>> but the above promotion seems
>> break it.
>>
>> example,
>> ia64 have 256MB hugepage (i.e. order=3D14). it mean kswapd never sleep.
>> example2,

But, This is a true problem missed in my review.
Thanks, Kosaki.

>> order-3 (i.e. PAGE_ALLOC_COSTLY_ORDER) makes one of most inefficent
>> reclaim, because it doesn't use lumpy recliam.
>> I've seen 128GB size zone, it mean 1/128 =3D 1GB. oh well, kswapd defini=
tely
>> waste cpu time 100%.
>>
>>
>> > +
>> > =A0loop_again:
>> > =A0 =A0 total_scanned =3D 0;
>> > =A0 =A0 sc.nr_reclaimed =3D 0;
>> > @@ -2092,7 +2102,7 @@ loop_again:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* OK, kswapd is getting into trouble. =A0Ta=
ke a nap, then take
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* another pass across the zones.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < DEF_PRIORITY - 2=
)
>> > + =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < congestion_prior=
ity)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(BLK_RW_ASYNC, =
HZ/10);
>>
>> Instead, How about this?
>>
>
> This makes a lot of sense. Tests look good and I added stats to make sure
> the logic was triggering. On X86, kswapd avoided a congestion_wait 11723
> times and X86-64 avoided it 5084 times. I think we should hold onto the
> stats temporarily until all these bugs are ironed out.
>
> Would you like to sign off the following?
>
> If you are ok to sign off, this patch should replace my patch 5 in
> the series.

I agree Kosaki's patch is more strightforward.

You can add my review sign, too.
Thanks for good patch, Kosaki. :)

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
