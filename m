Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 165B06B0023
	for <linux-mm@kvack.org>; Mon, 16 May 2011 20:49:05 -0400 (EDT)
Received: by qwa26 with SMTP id 26so9660qwa.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 17:49:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	<1305295404-12129-5-git-send-email-mgorman@suse.de>
	<4DCFAA80.7040109@jp.fujitsu.com>
	<1305519711.4806.7.camel@mulgrave.site>
	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	<20110516084558.GE5279@suse.de>
	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	<20110516102753.GF5279@suse.de>
	<BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
Date: Tue, 17 May 2011 09:48:59 +0900
Message-ID: <BANLkTimHgtzAYQuEXEVc3-qsTyVCohFK6w@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue, May 17, 2011 at 8:50 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Mon, May 16, 2011 at 7:27 PM, Mel Gorman <mgorman@suse.de> wrote:
>> On Mon, May 16, 2011 at 05:58:59PM +0900, Minchan Kim wrote:
>>> On Mon, May 16, 2011 at 5:45 PM, Mel Gorman <mgorman@suse.de> wrote:
>>> > On Mon, May 16, 2011 at 02:04:00PM +0900, Minchan Kim wrote:
>>> >> On Mon, May 16, 2011 at 1:21 PM, James Bottomley
>>> >> <James.Bottomley@hansenpartnership.com> wrote:
>>> >> > On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
>>> >> >> (2011/05/13 23:03), Mel Gorman wrote:
>>> >> >> > Under constant allocation pressure, kswapd can be in the situat=
ion where
>>> >> >> > sleeping_prematurely() will always return true even if kswapd h=
as been
>>> >> >> > running a long time. Check if kswapd needs to be scheduled.
>>> >> >> >
>>> >> >> > Signed-off-by: Mel Gorman<mgorman@suse.de>
>>> >> >> > ---
>>> >> >> > =C2=A0 mm/vmscan.c | =C2=A0 =C2=A04 ++++
>>> >> >> > =C2=A0 1 files changed, 4 insertions(+), 0 deletions(-)
>>> >> >> >
>>> >> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> >> >> > index af24d1e..4d24828 100644
>>> >> >> > --- a/mm/vmscan.c
>>> >> >> > +++ b/mm/vmscan.c
>>> >> >> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data=
_t *pgdat, int order, long remaining,
>>> >> >> > =C2=A0 =C2=A0 unsigned long balanced =3D 0;
>>> >> >> > =C2=A0 =C2=A0 bool all_zones_ok =3D true;
>>> >> >> >
>>> >> >> > + =C2=A0 /* If kswapd has been running too long, just sleep */
>>> >> >> > + =C2=A0 if (need_resched())
>>> >> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>>> >> >> > +
>>> >> >>
>>> >> >> Hmm... I don't like this patch so much. because this code does
>>> >> >>
>>> >> >> - don't sleep if kswapd got context switch at shrink_inactive_lis=
t
>>> >> >
>>> >> > This isn't entirely true: =C2=A0need_resched() will be false, so w=
e'll follow
>>> >> > the normal path for determining whether to sleep or not, in effect
>>> >> > leaving the current behaviour unchanged.
>>> >> >
>>> >> >> - sleep if kswapd didn't
>>> >> >
>>> >> > This also isn't entirely true: whether need_resched() is true at t=
his
>>> >> > point depends on a whole lot more that whether we did a context sw=
itch
>>> >> > in shrink_inactive. It mostly depends on how long we've been runni=
ng
>>> >> > without giving up the CPU. =C2=A0Generally that will mean we've be=
en round
>>> >> > the shrinker loop hundreds to thousands of times without sleeping.
>>> >> >
>>> >> >> It seems to be semi random behavior.
>>> >> >
>>> >> > Well, we have to do something. =C2=A0Chris Mason first suspected t=
he hang was
>>> >> > a kswapd rescheduling problem a while ago. =C2=A0We tried putting
>>> >> > cond_rescheds() in several places in the vmscan code, but to no av=
ail.
>>> >>
>>> >> Is it a result of =C2=A0test with patch of Hannes(ie, !pgdat_balance=
d)?
>>> >>
>>> >> If it isn't, it would be nop regardless of putting cond_reshed at vm=
scan.c.
>>> >> Because, although we complete zone balancing, kswapd doesn't sleep a=
s
>>> >> pgdat_balance returns wrong result. And at last VM calls
>>> >> balance_pgdat. In this case, balance_pgdat returns without any work =
as
>>> >> kswap couldn't find zones which have not enough free pages and goto
>>> >> out. kswapd could repeat this work infinitely. So you don't have a
>>> >> chance to call cond_resched.
>>> >>
>>> >> But if your test was with Hanne's patch, I am very curious how come
>>> >> kswapd consumes CPU a lot.
>>> >>
>>> >> > The need_resched() in sleeping_prematurely() seems to be about the=
 best
>>> >> > option. =C2=A0The other option might be just to put a cond_resched=
() in
>>> >> > kswapd_try_to_sleep(), but that will really have about the same ef=
fect.
>>> >>
>>> >> I don't oppose it but before that, I think we have to know why kswap=
d
>>> >> consumes CPU a lot although we applied Hannes' patch.
>>> >>
>>> >
>>> > Because it's still possible for processes to allocate pages at the sa=
me
>>> > rate kswapd is freeing them leading to a situation where kswapd does =
not
>>> > consider the zone balanced for prolonged periods of time.
>>>
>>> We have cond_resched in shrink_page_list, shrink_slab and balance_pgdat=
.
>>> So I think kswapd can be scheduled out although it's scheduled in
>>> after a short time as task scheduled also need page reclaim. Although
>>> all task in system need reclaim, kswapd cpu 99% consumption is a
>>> natural result, I think.
>>> Do I miss something?
>>>
>>
>> Lets see;
>>
>> shrink_page_list() only applies if inactive pages were isolated
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0which in turn may not happen if all_unreclaim=
able is set in
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zones(). If for whatver reason, all_un=
reclaimable is
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0set on all zones, we can miss calling cond_re=
sched().
>>
>> shrink_slab only applies if we are reclaiming slab pages. If the first
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0shrinker returns -1, we do not call cond_resc=
hed(). If that
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0first shrinker is dcache and __GFP_FS is not =
set, direct
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaimers will not shrink at all. However, i=
f there are
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0enough of them running or if one of the other=
 shrinkers
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0is running for a very long time, kswapd could=
 be starved
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0acquiring the shrinker_rwsem and never reachi=
ng the
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched().
>
> Don't we have to move cond_resched?
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 292582c..633e761 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -231,8 +231,10 @@ unsigned long shrink_slab(struct shrink_control *shr=
ink,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (scanned =3D=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scanned =3D SWAP_C=
LUSTER_MAX;
>
> - =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1; =C2=A0 =C2=
=A0 =C2=A0 /* Assume we'll be able to shrink next time */
> + =C2=A0 =C2=A0 =C2=A0 if (!down_read_trylock(&shrinker_rwsem)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D 1;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out; /* Assume we=
'll be able to shrink next time */
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_for_each_entry(shrinker, &shrinker_list, =
list) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long long=
 delta;
> @@ -280,12 +282,14 @@ unsigned long shrink_slab(struct shrink_control *sh=
rink,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0count_vm_events(SLABS_SCANNED, this_scan);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0total_scan -=3D this_scan;
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 cond_resched();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrinker->nr +=3D =
total_scan;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0up_read(&shrinker_rwsem);
> +out:
> + =C2=A0 =C2=A0 =C2=A0 cond_resched();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
>
>>
>> balance_pgdat() only calls cond_resched if the zones are not
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0balanced. For a high-order allocation that is=
 balanced, it
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0checks order-0 again. During that window, ord=
er-0 might have
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0become unbalanced so it loops again for order=
-0 and returns
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0that was reclaiming for order-0 to kswapd(). =
It can then find
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0that a caller has rewoken kswapd for a high-o=
rder and re-enters
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0balance_pgdat() without ever have called cond=
_resched().
>
> If kswapd reclaims order-o followed by high order, it would have a
> chance to call cond_resched in shrink_page_list. But if all zones are
> all_unreclaimable is set, balance_pgdat could return any work.

    Typo : without any work.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
