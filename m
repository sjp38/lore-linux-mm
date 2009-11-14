Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 044056B004D
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 04:34:25 -0500 (EST)
Received: by iwn34 with SMTP id 34so3055344iwn.12
        for <linux-mm@kvack.org>; Sat, 14 Nov 2009 01:34:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113181740.GN29804@csn.ul.ie>
References: <20091113142558.33B6.A69D9226@jp.fujitsu.com>
	 <20091113141303.GI29804@csn.ul.ie>
	 <20091114023901.3DA8.A69D9226@jp.fujitsu.com>
	 <20091113181740.GN29804@csn.ul.ie>
Date: Sat, 14 Nov 2009 18:34:23 +0900
Message-ID: <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com>
Subject: Re: [PATCH 4/5] vmscan: Have kswapd sleep for a short interval and
	double check it should be asleep
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

2009/11/14 Mel Gorman <mel@csn.ul.ie>:
> On Sat, Nov 14, 2009 at 03:00:57AM +0900, KOSAKI Motohiro wrote:
>> > On Fri, Nov 13, 2009 at 07:43:09PM +0900, KOSAKI Motohiro wrote:
>> > > > After kswapd balances all zones in a pgdat, it goes to sleep. In t=
he event
>> > > > of no IO congestion, kswapd can go to sleep very shortly after the=
 high
>> > > > watermark was reached. If there are a constant stream of allocatio=
ns from
>> > > > parallel processes, it can mean that kswapd went to sleep too quic=
kly and
>> > > > the high watermark is not being maintained for sufficient length t=
ime.
>> > > >
>> > > > This patch makes kswapd go to sleep as a two-stage process. It fir=
st
>> > > > tries to sleep for HZ/10. If it is woken up by another process or =
the
>> > > > high watermark is no longer met, it's considered a premature sleep=
 and
>> > > > kswapd continues work. Otherwise it goes fully to sleep.
>> > > >
>> > > > This adds more counters to distinguish between fast and slow breac=
hes of
>> > > > watermarks. A "fast" premature sleep is one where the low watermar=
k was
>> > > > hit in a very short time after kswapd going to sleep. A "slow" pre=
mature
>> > > > sleep indicates that the high watermark was breached after a very =
short
>> > > > interval.
>> > > >
>> > > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > >
>> > > Why do you submit this patch to mainline? this is debugging patch
>> > > no more and no less.
>> > >
>> >
>> > Do you mean the stats part? The stats are included until such time as =
the page
>> > allocator failure reports stop or are significantly reduced. In the ev=
ent a
>> > report is received, the value of the counters help determine if kswapd=
 was
>> > struggling or not. They should be removed once this mess is ironed out=
.
>> >
>> > If there is a preference, I can split out the stats part and send it t=
o
>> > people with page allocator failure reports for retesting.
>>
>> I'm sorry my last mail didn't have enough explanation.
>> This stats help to solve this issue. I agreed. but after solving this is=
sue,
>> I don't imagine administrator how to use this stats. if KSWAPD_PREMATURE=
_FAST or
>> KSWAPD_PREMATURE_SLOW significantly increased, what should admin do?
>
> One possible workaround would be to raise min_free_kbytes while a fix is
> being worked on.

Please correct me, if I said wrong thing.

if I was admin, I don't watch this stats because kswapd frequently
wakeup doesn't mean any trouble. instead I watch number of allocation
failure.

[see include/linux/vmstat.h]

umm...
Why don't we have nr-allocation-failure vmstat? I don't remember it.
GFP_NOWARN failure doesn't make syslog error logging. but frequently
GFP_NOWARN failure imply the system is under memory pressure or under
heavy fragmentation. It is good opportunity to change min_free_kbytes.



>> Or, Can LKML folk make any advise to admin?
>>
>
> Work with them to fix the bug :/
>
>> if kernel doesn't have any bug, kswapd wakeup rate is not so worth infor=
mation imho.
>> following your additional code itself looks good to me. but...
>>
>>
>> > =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
>> > vmscan: Have kswapd sleep for a short interval and double check it sho=
uld be asleep fix 1
>> >
>> > This patch is a fix and a claritifacation to the patch "vmscan: Have
>> > kswapd sleep for a short interval and double check it should be asleep=
".
>> > The fix is for kswapd to only check zones in the node it is responsibl=
e
>> > for. The clarification is to rename two counters to better explain wha=
t is
>> > being counted.
>> >
>> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>> > ---
>> > =A0include/linux/vmstat.h | =A0 =A02 +-
>> > =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 20 +++++++++++++-------
>> > =A0mm/vmstat.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 ++--
>> > =A03 files changed, 16 insertions(+), 10 deletions(-)
>> >
>> > diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
>> > index 7d66695..0591a48 100644
>> > --- a/include/linux/vmstat.h
>> > +++ b/include/linux/vmstat.h
>> > @@ -40,7 +40,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOU=
T,
>> > =A0 =A0 =A0 =A0 =A0 =A0 PGSCAN_ZONE_RECLAIM_FAILED,
>> > =A0#endif
>> > =A0 =A0 =A0 =A0 =A0 =A0 PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSW=
APD_INODESTEAL,
>> > - =A0 =A0 =A0 =A0 =A0 KSWAPD_PREMATURE_FAST, KSWAPD_PREMATURE_SLOW,
>> > + =A0 =A0 =A0 =A0 =A0 KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_=
HIT_QUICKLY,
>> > =A0 =A0 =A0 =A0 =A0 =A0 KSWAPD_NO_CONGESTION_WAIT,
>> > =A0 =A0 =A0 =A0 =A0 =A0 PAGEOUTRUN, ALLOCSTALL, PGROTATED,
>> > =A0#ifdef CONFIG_HUGETLB_PAGE
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 70967e1..5557555 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -1905,19 +1905,25 @@ unsigned long try_to_free_mem_cgroup_pages(str=
uct mem_cgroup *mem_cont,
>> > =A0#endif
>> >
>> > =A0/* is kswapd sleeping prematurely? */
>> > -static int sleeping_prematurely(int order, long remaining)
>> > +static int sleeping_prematurely(pg_data_t *pgdat, int order, long rem=
aining)
>> > =A0{
>> > - =A0 struct zone *zone;
>> > + =A0 int i;
>> >
>> > =A0 =A0 /* If a direct reclaimer woke kswapd within HZ/10, it's premat=
ure */
>> > =A0 =A0 if (remaining)
>> > =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> >
>> > =A0 =A0 /* If after HZ/10, a zone is below the high mark, it's prematu=
re */
>> > - =A0 for_each_populated_zone(zone)
>> > + =A0 for (i =3D 0; i < pgdat->nr_zones; i++) {
>> > + =A0 =A0 =A0 =A0 =A0 struct zone *zone =3D pgdat->node_zones + i;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 if (!populated_zone(zone))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > +
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_watermark_ok(zone, order, high_wmark=
_pages(zone),
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0, 0))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> > + =A0 }
>> >
>> > =A0 =A0 return 0;
>> > =A0}
>> > @@ -2221,7 +2227,7 @@ static int kswapd(void *p)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 long remaining=
 =3D 0;
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Try to slee=
p for a short interval */
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_pr=
ematurely(order, remaining)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_pr=
ematurely(pgdat, order, remaining)) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 remaining =3D schedule_timeout(HZ/10);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 finish_wait(&pgdat->kswapd_wait, &wait);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>> > @@ -2232,13 +2238,13 @@ static int kswapd(void *p)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* premature=
 sleep. If not, then go fully
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to sleep =
until explicitly woken up
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_pr=
ematurely(order, remaining))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sleeping_pr=
ematurely(pgdat, order, remaining))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 schedule();
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 if (remaining)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 count_vm_event(KSWAPD_PREMATURE_FAST);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 else
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 count_vm_event(KSWAPD_PREMATURE_SLOW);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >
>> > diff --git a/mm/vmstat.c b/mm/vmstat.c
>> > index bc09547..6cc8dc6 100644
>> > --- a/mm/vmstat.c
>> > +++ b/mm/vmstat.c
>> > @@ -683,8 +683,8 @@ static const char * const vmstat_text[] =3D {
>> > =A0 =A0 "slabs_scanned",
>> > =A0 =A0 "kswapd_steal",
>> > =A0 =A0 "kswapd_inodesteal",
>> > - =A0 "kswapd_slept_prematurely_fast",
>> > - =A0 "kswapd_slept_prematurely_slow",
>> > + =A0 "kswapd_low_wmark_hit_quickly",
>> > + =A0 "kswapd_high_wmark_hit_quickly",
>> > =A0 =A0 "kswapd_no_congestion_wait",
>> > =A0 =A0 "pageoutrun",
>> > =A0 =A0 "allocstall",
>>
>>
>>
>
> --
> Mel Gorman
> Part-time Phd Student =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
Linux Technology Center
> University of Limerick =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IB=
M Dublin Software Lab
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
