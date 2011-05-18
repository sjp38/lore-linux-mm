Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A1A946B0023
	for <linux-mm@kvack.org>; Wed, 18 May 2011 00:19:39 -0400 (EDT)
Received: by qyk30 with SMTP id 30so863958qyk.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 21:19:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305640239.2046.27.camel@lenovo>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	<1305295404-12129-5-git-send-email-mgorman@suse.de>
	<4DCFAA80.7040109@jp.fujitsu.com>
	<1305519711.4806.7.camel@mulgrave.site>
	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	<20110516084558.GE5279@suse.de>
	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	<20110516102753.GF5279@suse.de>
	<BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
	<20110517103840.GL5279@suse.de>
	<1305640239.2046.27.camel@lenovo>
Date: Wed, 18 May 2011 13:19:37 +0900
Message-ID: <BANLkTi=esh86EtfQgRGWkHx6Z3fYV+42tA@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@canonical.com>
Cc: Mel Gorman <mgorman@suse.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

Hello Colin,

On Tue, May 17, 2011 at 10:50 PM, Colin Ian King
<colin.king@canonical.com> wrote:
> On Tue, 2011-05-17 at 11:38 +0100, Mel Gorman wrote:
>> On Tue, May 17, 2011 at 08:50:44AM +0900, Minchan Kim wrote:
>> > On Mon, May 16, 2011 at 7:27 PM, Mel Gorman <mgorman@suse.de> wrote:
>> > > On Mon, May 16, 2011 at 05:58:59PM +0900, Minchan Kim wrote:
>> > >> On Mon, May 16, 2011 at 5:45 PM, Mel Gorman <mgorman@suse.de> wrote=
:
>> > >> > On Mon, May 16, 2011 at 02:04:00PM +0900, Minchan Kim wrote:
>> > >> >> On Mon, May 16, 2011 at 1:21 PM, James Bottomley
>> > >> >> <James.Bottomley@hansenpartnership.com> wrote:
>> > >> >> > On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
>> > >> >> >> (2011/05/13 23:03), Mel Gorman wrote:
>> > >> >> >> > Under constant allocation pressure, kswapd can be in the si=
tuation where
>> > >> >> >> > sleeping_prematurely() will always return true even if kswa=
pd has been
>> > >> >> >> > running a long time. Check if kswapd needs to be scheduled.
>> > >> >> >> >
>> > >> >> >> > Signed-off-by: Mel Gorman<mgorman@suse.de>
>> > >> >> >> > ---
>> > >> >> >> > =C2=A0 mm/vmscan.c | =C2=A0 =C2=A04 ++++
>> > >> >> >> > =C2=A0 1 files changed, 4 insertions(+), 0 deletions(-)
>> > >> >> >> >
>> > >> >> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > >> >> >> > index af24d1e..4d24828 100644
>> > >> >> >> > --- a/mm/vmscan.c
>> > >> >> >> > +++ b/mm/vmscan.c
>> > >> >> >> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_=
data_t *pgdat, int order, long remaining,
>> > >> >> >> > =C2=A0 =C2=A0 unsigned long balanced =3D 0;
>> > >> >> >> > =C2=A0 =C2=A0 bool all_zones_ok =3D true;
>> > >> >> >> >
>> > >> >> >> > + =C2=A0 /* If kswapd has been running too long, just sleep=
 */
>> > >> >> >> > + =C2=A0 if (need_resched())
>> > >> >> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> > >> >> >> > +
>> > >> >> >>
>> > >> >> >> Hmm... I don't like this patch so much. because this code doe=
s
>> > >> >> >>
>> > >> >> >> - don't sleep if kswapd got context switch at shrink_inactive=
_list
>> > >> >> >
>> > >> >> > This isn't entirely true: =C2=A0need_resched() will be false, =
so we'll follow
>> > >> >> > the normal path for determining whether to sleep or not, in ef=
fect
>> > >> >> > leaving the current behaviour unchanged.
>> > >> >> >
>> > >> >> >> - sleep if kswapd didn't
>> > >> >> >
>> > >> >> > This also isn't entirely true: whether need_resched() is true =
at this
>> > >> >> > point depends on a whole lot more that whether we did a contex=
t switch
>> > >> >> > in shrink_inactive. It mostly depends on how long we've been r=
unning
>> > >> >> > without giving up the CPU. =C2=A0Generally that will mean we'v=
e been round
>> > >> >> > the shrinker loop hundreds to thousands of times without sleep=
ing.
>> > >> >> >
>> > >> >> >> It seems to be semi random behavior.
>> > >> >> >
>> > >> >> > Well, we have to do something. =C2=A0Chris Mason first suspect=
ed the hang was
>> > >> >> > a kswapd rescheduling problem a while ago. =C2=A0We tried putt=
ing
>> > >> >> > cond_rescheds() in several places in the vmscan code, but to n=
o avail.
>> > >> >>
>> > >> >> Is it a result of =C2=A0test with patch of Hannes(ie, !pgdat_bal=
anced)?
>> > >> >>
>> > >> >> If it isn't, it would be nop regardless of putting cond_reshed a=
t vmscan.c.
>> > >> >> Because, although we complete zone balancing, kswapd doesn't sle=
ep as
>> > >> >> pgdat_balance returns wrong result. And at last VM calls
>> > >> >> balance_pgdat. In this case, balance_pgdat returns without any w=
ork as
>> > >> >> kswap couldn't find zones which have not enough free pages and g=
oto
>> > >> >> out. kswapd could repeat this work infinitely. So you don't have=
 a
>> > >> >> chance to call cond_resched.
>> > >> >>
>> > >> >> But if your test was with Hanne's patch, I am very curious how c=
ome
>> > >> >> kswapd consumes CPU a lot.
>> > >> >>
>> > >> >> > The need_resched() in sleeping_prematurely() seems to be about=
 the best
>> > >> >> > option. =C2=A0The other option might be just to put a cond_res=
ched() in
>> > >> >> > kswapd_try_to_sleep(), but that will really have about the sam=
e effect.
>> > >> >>
>> > >> >> I don't oppose it but before that, I think we have to know why k=
swapd
>> > >> >> consumes CPU a lot although we applied Hannes' patch.
>> > >> >>
>> > >> >
>> > >> > Because it's still possible for processes to allocate pages at th=
e same
>> > >> > rate kswapd is freeing them leading to a situation where kswapd d=
oes not
>> > >> > consider the zone balanced for prolonged periods of time.
>> > >>
>> > >> We have cond_resched in shrink_page_list, shrink_slab and balance_p=
gdat.
>> > >> So I think kswapd can be scheduled out although it's scheduled in
>> > >> after a short time as task scheduled also need page reclaim. Althou=
gh
>> > >> all task in system need reclaim, kswapd cpu 99% consumption is a
>> > >> natural result, I think.
>> > >> Do I miss something?
>> > >>
>> > >
>> > > Lets see;
>> > >
>> > > shrink_page_list() only applies if inactive pages were isolated
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0which in turn may not happen if all_unrec=
laimable is set in
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zones(). If for whatver reason, al=
l_unreclaimable is
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0set on all zones, we can miss calling con=
d_resched().
>> > >
>> > > shrink_slab only applies if we are reclaiming slab pages. If the fir=
st
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0shrinker returns -1, we do not call cond_=
resched(). If that
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0first shrinker is dcache and __GFP_FS is =
not set, direct
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaimers will not shrink at all. Howeve=
r, if there are
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0enough of them running or if one of the o=
ther shrinkers
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0is running for a very long time, kswapd c=
ould be starved
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0acquiring the shrinker_rwsem and never re=
aching the
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched().
>> >
>> > Don't we have to move cond_resched?
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 292582c..633e761 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -231,8 +231,10 @@ unsigned long shrink_slab(struct shrink_control *=
shrink,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (scanned =3D=3D 0)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scanned =3D SW=
AP_CLUSTER_MAX;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem))
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1; =C2=A0 =
=C2=A0 =C2=A0 /* Assume we'll be able to shrink next time */
>> > + =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 1;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out; /* Assume=
 we'll be able to shrink next time */
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(shrinker, &shrinker_li=
st, list) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long =
long delta;
>> > @@ -280,12 +282,14 @@ unsigned long shrink_slab(struct shrink_control =
*shrink,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 count_vm_events(SLABS_SCANNED, this_scan);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 total_scan -=3D this_scan;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 cond_resched();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrinker->nr +=
=3D total_scan;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 up_read(&shrinker_rwsem);
>> > +out:
>> > + =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
>> > =C2=A0}
>> >
>>
>> This makes some sense for the exit path but if one or more of the
>> shrinkers takes a very long time without sleeping (extremely long
>> list searches for example) then kswapd will not call cond_resched()
>> between shrinkers and still consume a lot of CPU.
>>
>> > >
>> > > balance_pgdat() only calls cond_resched if the zones are not
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0balanced. For a high-order allocation tha=
t is balanced, it
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0checks order-0 again. During that window,=
 order-0 might have
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0become unbalanced so it loops again for o=
rder-0 and returns
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0that was reclaiming for order-0 to kswapd=
(). It can then find
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0that a caller has rewoken kswapd for a hi=
gh-order and re-enters
>> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0balance_pgdat() without ever have called =
cond_resched().
>> >
>> > If kswapd reclaims order-o followed by high order, it would have a
>> > chance to call cond_resched in shrink_page_list. But if all zones are
>> > all_unreclaimable is set, balance_pgdat could return any work. Okay.
>> > It does make sense.
>> > By your scenario, someone wakes up kswapd with higher order, again.
>> > So re-enters balance_pgdat without ever have called cond_resched.
>> > But if someone wakes up higher order again, we can't have a chance to
>> > call kswapd_try_to_sleep. So your patch effect would be nop, too.
>> >
>> > It would be better to put cond_resched after balance_pgdat?
>> >
>>
>> Which will leave kswapd runnable instead of going to sleep but
>> guarantees a scheduling point. Lets see if the problem is that
>> cond_resched is being missed although if this was the case then patch
>> 4 would truly be a no-op but Colin has already reported that patch 1 on
>> its own didn't fix his problem. If the problem is sandybridge-specific
>> where kswapd remains runnable and consuming large amounts of CPU in
>> turbo mode then we know that there are other cond_resched() decisions
>> that will need to be revisited.
>>
>> Colin or James, would you be willing to test with patch 1 from this
>> series and Minchan's patch below? Thanks.
>
> This works OK fine. =C2=A0Ran 250 test cycles for about 2 hours.

Thanks for the testing!.
I would like to know exact patch for you to apply.
My modification of inserting cond_resched is two.

1) shrink_slab function
2) kswapd right after balance_pgdat.

1) or 2) ?
Or
Both?


Thanks
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
