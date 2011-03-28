Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9597A8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 13:35:19 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p2SHZF8x001290
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:35:15 -0700
Received: from ywl41 (ywl41.prod.google.com [10.192.12.41])
	by hpaq2.eem.corp.google.com with ESMTP id p2SHZ8P7026563
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:35:14 -0700
Received: by ywl41 with SMTP id 41so1499436ywl.4
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 10:35:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328174421.6ac9ada0.kamezawa.hiroyu@jp.fujitsu.com>
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
	<1301292775-4091-2-git-send-email-yinghan@google.com>
	<20110328154033.F068.A69D9226@jp.fujitsu.com>
	<20110328174421.6ac9ada0.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 28 Mar 2011 10:35:07 -0700
Message-ID: <AANLkTi=_GbgB6xVcBws+-3FOYM-4h+-xsVYq-Kegygi+@mail.gmail.com>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Mon, Mar 28, 2011 at 1:44 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Mar 2011 15:39:59 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> > In the global background reclaim, we do soft reclaim before scanning t=
he
>> > per-zone LRU. However, the return value is ignored. This patch adds th=
e logic
>> > where no per-zone reclaim happens if the soft reclaim raise the free p=
ages
>> > above the zone's high_wmark.
>> >
>> > I did notice a similar check exists but instead leaving a "gap" above =
the
>> > high_wmark(the code right after my change in vmscan.c). There are disc=
ussions
>> > on whether or not removing the "gap" which intends to balance pressure=
s across
>> > zones over time. Without fully understand the logic behind, I didn't t=
ry to
>> > merge them into one, but instead adding the condition only for memcg u=
sers
>> > who care a lot on memory isolation.
>> >
>> > Signed-off-by: Ying Han <yinghan@google.com>
>>
>> Looks good to me. But this depend on "memcg soft limit" spec. To be hone=
st,
>> I don't know this return value ignorance is intentional or not. So I thi=
nk
>> you need to get ack from memcg folks.
>>
>>
> Hi,
>
>
>> > ---
>> > =A0mm/vmscan.c | =A0 16 +++++++++++++++-
>> > =A01 files changed, 15 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 060e4c1..e4601c5 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pg=
dat, int order,
>> > =A0 =A0 int end_zone =3D 0; =A0 =A0 =A0 /* Inclusive. =A00 =3D ZONE_DM=
A */
>> > =A0 =A0 unsigned long total_scanned;
>> > =A0 =A0 struct reclaim_state *reclaim_state =3D current->reclaim_state=
;
>> > + =A0 unsigned long nr_soft_reclaimed;
>> > =A0 =A0 struct scan_control sc =3D {
>> > =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> > =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> > @@ -2413,7 +2414,20 @@ loop_again:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclaim b=
efore calling shrink_zone.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For now we ignore the ret=
urn value
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_soft_limit_reclaim(zo=
ne, order, sc.gfp_mask);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_soft_reclaimed =3D mem_cgroup=
_soft_limit_reclaim(zone,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 order, sc.gfp_mask);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Check the watermark after t=
he soft limit reclaim. If
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* the free pages is above the=
 watermark, no need to
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* proceed to the zone reclaim=
.
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_soft_reclaimed && zone_wa=
termark_ok_safe(zone,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
order, high_wmark_pages(zone),
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
end_zone, 0)) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_state=
(zone, NR_SKIP_RECLAIM_GLOBAL);
>>
>> NR_SKIP_RECLAIM_GLOBAL is defined by patch 2/2. please don't break bisec=
tability.
>>
>>
>>
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> Hmm, this "continue" seems not good to me. And, IIUC, this was a reason
> we ignore the result. But yes, ignore the result is bad.
> I think you should just do sc.nr_reclaimed +=3D nr_soft_reclaimed.
> Or mem_cgroup_soft_limit_reclaim() should update sc.
>
>
> And allow kswapd to do some jobs as
> =A0- call shrink_slab()
> =A0- update total_scanned
> =A0- update other flags.. etc...etc..

The change make sense to me. I will make the next patch to update
total_scanned and sc.nr_reclaimed.
Also, we might not want to skip shrink_slab() in this case, so i will add t=
hat.

>
> If extra shink_zone() seems bad, please skip it, if mem_cgroup_soft_limit=
_reclaim()
> did enough jobs.
>
> IOW, mem_cgroup_soft_limit_reclaim() can't do enough jobs to satisfy
> =3D=3D
> =A0 2426 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 balance_gap =3D =
min(low_wmark_pages(zone),
> =A0 2427 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
(zone->present_pages +
> =A0 2428 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> =A0 2429 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
KSWAPD_ZONE_BALANCE_GAP_RATIO);
> =A0 2430 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!zone_waterm=
ark_ok_safe(zone, order,
> =A0 2431 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 high_wmark_pages(zone) + balance_gap,
> =A0 2432 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 end_zone, 0))
> =A0 2433 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
shrink_zone(priority, zone, &sc);
> =3D=3D
> This condition, you should update mem_cgroup_soft_limit_relcaim() to sati=
sfy this,
> rather than continue here.
>
> I guess this is not easy...So, how about starting from updating 'sc' pass=
ed to
> mem_cgroup_soft_limit_reclaim() ? Then, we can think of algorithm.

The original patch introducing the "gap" was doing memory pressure
balancing across physical zones. Eventually we should get rid of
global per-zone reclaim in memcg(due to isolation), and maybe we need
something similar on per-memcg-per-zone. I will think about that.

So i will make the change on updating the two counters in scan_control
in next patch.

Thanks

--Ying

>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
