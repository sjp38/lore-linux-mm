Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9ABF76B0209
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 00:26:09 -0400 (EDT)
Received: by ywh26 with SMTP id 26so1129142ywh.12
        for <linux-mm@kvack.org>; Thu, 15 Apr 2010 21:26:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100416115437.27AD.A69D9226@jp.fujitsu.com>
References: <20100415135031.D186.A69D9226@jp.fujitsu.com>
	 <20100415051911.GA17110@localhost>
	 <20100416115437.27AD.A69D9226@jp.fujitsu.com>
Date: Fri, 16 Apr 2010 13:26:03 +0900
Message-ID: <t2j28c262361004152126t1975cd96kc21e54f3a9e41f82@mail.gmail.com>
Subject: Re: [PATCH] vmscan: page_check_references() check low order lumpy
	reclaim properly
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 12:16 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Thu, Apr 15, 2010 at 12:55:30PM +0800, KOSAKI Motohiro wrote:
>> > > On Thu, Apr 15, 2010 at 12:32:50PM +0800, KOSAKI Motohiro wrote:
>> > > > > On Thu, Apr 15, 2010 at 11:31:52AM +0800, KOSAKI Motohiro wrote:
>> > > > > > > > Many applications (this one and below) are stuck in
>> > > > > > > > wait_on_page_writeback(). I guess this is why "heavy write=
 to
>> > > > > > > > irrelevant partition stalls the whole system". =C2=A0They =
are stuck on page
>> > > > > > > > allocation. Your 512MB system memory is a bit tight, so re=
claim
>> > > > > > > > pressure is a bit high, which triggers the wait-on-writeba=
ck logic.
>> > > > > > >
>> > > > > > > I wonder if this hacking patch may help.
>> > > > > > >
>> > > > > > > When creating 300MB dirty file with dd, it is creating conti=
nuous
>> > > > > > > region of hard-to-reclaim pages in the LRU list. priority ca=
n easily
>> > > > > > > go low when irrelevant applications' direct reclaim run into=
 these
>> > > > > > > regions..
>> > > > > >
>> > > > > > Sorry I'm confused not. can you please tell us more detail exp=
lanation?
>> > > > > > Why did lumpy reclaim cause OOM? lumpy reclaim might cause
>> > > > > > direct reclaim slow down. but IIUC it's not cause OOM because =
OOM is
>> > > > > > only occur when priority-0 reclaim failure.
>> > > > >
>> > > > > No I'm not talking OOM. Nor lumpy reclaim.
>> > > > >
>> > > > > I mean the direct reclaim can get stuck for long time, when we d=
o
>> > > > > wait_on_page_writeback() on lumpy_reclaim=3D1.
>> > > > >
>> > > > > > IO get stcking also prevent priority reach to 0.
>> > > > >
>> > > > > Sure. But we can wait for IO a bit later -- after scanning 1/64 =
LRU
>> > > > > (the below patch) instead of the current 1/1024.
>> > > > >
>> > > > > In Andreas' case, 512MB/1024 =3D 512KB, this is way too low comp=
aring to
>> > > > > the 22MB writeback pages. There can easily be a continuous range=
 of
>> > > > > 512KB dirty/writeback pages in the LRU, which will trigger the w=
ait
>> > > > > logic.
>> > > >
>> > > > In my feeling from your explanation, we need auto adjustment mecha=
nism
>> > > > instead change default value for special machine. no?
>> > >
>> > > You mean the dumb DEF_PRIORITY/2 may be too large for a 1TB memory b=
ox?
>> > >
>> > > However for such boxes, whether it be DEF_PRIORITY-2 or DEF_PRIORITY=
/2
>> > > shall be irrelevant: it's trivial anyway to reclaim an order-1 or
>> > > order-2 page. In other word, lumpy_reclaim will hardly go 1. =C2=A0D=
o you
>> > > think so?
>> >
>> > If my remember is correct, Its order-1 lumpy reclaim was introduced
>> > for solving such big box + AIM7 workload made kernel stack (order-1 pa=
ge)
>> > allocation failure.
>> >
>> > Now, We are living on moore's law. so probably we need to pay attentio=
n
>> > scalability always. today's big box is going to become desktop box aft=
er
>> > 3-5 years.
>> >
>> > Probably, Lee know such problem than me. cc to him.
>>
>> In Andreas' trace, the processes are blocked in
>> - do_fork: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0console-kit-d
>> - __alloc_skb: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0x-terminal-em, konquero=
r
>> - handle_mm_fault: =C2=A0 =C2=A0 =C2=A0tclsh
>> - filemap_fault: =C2=A0 =C2=A0 =C2=A0 =C2=A0ls
>>
>> I'm a bit confused by the last one, and wonder what's the typical
>> gfp order of __alloc_skb().
>
> Probably I've found one of reason of low order lumpy reclaim slow down.
> Let's fix obvious bug at first!
>
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Subject: [PATCH] vmscan: page_check_references() check low order lumpy re=
claim properly
>
> If vmscan is under lumpy reclaim mode, it have to ignore referenced bit
> for making contenious free pages. but current page_check_references()
> doesn't.
>
> Fixes it.
>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

I am not sure how the patch affects this problem.
But I think the patch is reasonable.

Nice catch, Kosaiki.
Below is just nitpick. :)

> ---
> =C2=A0mm/vmscan.c | =C2=A0 32 +++++++++++++++++---------------
> =C2=A01 files changed, 17 insertions(+), 15 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 3ff3311..13d9546 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -77,6 +77,8 @@ struct scan_control {
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int order;
>
> + =C2=A0 =C2=A0 =C2=A0 int lumpy_reclaim;
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Which cgroup do we reclaim from */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct mem_cgroup *mem_cgroup;
>
> @@ -575,7 +577,7 @@ static enum page_references page_check_references(str=
uct page *page,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0referenced_page =3D TestClearPageReferenced(pa=
ge);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Lumpy reclaim - ignore references */
> - =C2=A0 =C2=A0 =C2=A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> + =C2=A0 =C2=A0 =C2=A0 if (sc->lumpy_reclaim)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return PAGEREF_REC=
LAIM;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -1130,7 +1132,6 @@ static unsigned long shrink_inactive_list(unsigned =
long max_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_scanned =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone_reclaim_stat *reclaim_stat =3D get=
_reclaim_stat(zone, sc);
> - =C2=A0 =C2=A0 =C2=A0 int lumpy_reclaim =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0while (unlikely(too_many_isolated(zone, file, =
sc))) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0congestion_wait(BL=
K_RW_ASYNC, HZ/10);
> @@ -1140,17 +1141,6 @@ static unsigned long shrink_inactive_list(unsigned=
 long max_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return SWAP_CLUSTER_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 /*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we need a large contiguous chunk of mem=
ory, or have
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* trouble getting a small set of contiguous =
pages, we
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* will reclaim both active and inactive page=
s.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* We use the same threshold as pageout conge=
stion_wait below.
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> - =C2=A0 =C2=A0 =C2=A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lumpy_reclaim =3D 1;
> - =C2=A0 =C2=A0 =C2=A0 else if (sc->order && priority < DEF_PRIORITY - 2)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lumpy_reclaim =3D 1;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pagevec_init(&pvec, 1);
>
> @@ -1163,7 +1153,7 @@ static unsigned long shrink_inactive_list(unsigned =
long max_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_f=
reed;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_a=
ctive;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned int count=
[NR_LRU_LISTS] =3D { 0, };
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int mode =3D lumpy_rec=
laim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int mode =3D sc->lumpy=
_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_a=
non;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_f=
ile;
>
> @@ -1216,7 +1206,7 @@ static unsigned long shrink_inactive_list(unsigned =
long max_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * but that should=
 be acceptable to the caller
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (nr_freed < nr_=
taken && !current_is_kswapd() &&
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 lumpy_re=
claim) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->lump=
y_reclaim) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0congestion_wait(BLK_RW_ASYNC, HZ/10);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/*
> @@ -1655,6 +1645,18 @@ static void shrink_zone(int priority, struct zone =
*zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&r=
eclaim_stat->nr_saved_scan[l]);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we need a large contiguous chunk of mem=
ory, or have
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* trouble getting a small set of contiguous =
pages, we
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* will reclaim both active and inactive page=
s.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->lumpy_reclaim =3D =
1;
> + =C2=A0 =C2=A0 =C2=A0 else if (sc->order && priority < DEF_PRIORITY - 2)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->lumpy_reclaim =3D =
1;
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->lumpy_reclaim =3D =
0;

How about making new function for readability instead of nesting else?
int is_lumpy_reclaim(struct scan_control *sc)
{
....
}

If you merge patch reduced stack usage of reclaim path, I think it's
enough alone scan_control argument.
It's just nitpick. :)
If you don't mind, ignore, please.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
