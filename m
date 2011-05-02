Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E058F6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:14:13 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p42NEBG6010166
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:14:11 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by hpaq2.eem.corp.google.com with ESMTP id p42NDsF7010069
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 2 May 2011 16:14:09 -0700
Received: by qyk2 with SMTP id 2so1889167qyk.0
        for <linux-mm@kvack.org>; Mon, 02 May 2011 16:14:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110502224838.GB10278@cmpxchg.org>
References: <1304366849.15370.27.camel@mulgrave.site>
	<20110502224838.GB10278@cmpxchg.org>
Date: Mon, 2 May 2011 16:14:09 -0700
Message-ID: <BANLkTikDyL9-XLpwyLwUQNuUfkBwbUBcZg@mail.gmail.com>
Subject: Re: memcg: fix fatal livelock in kswapd
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Balbir Singh <balbir@linux.vnet.ibm.com>

On Mon, May 2, 2011 at 3:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Hi,
>
> On Mon, May 02, 2011 at 03:07:29PM -0500, James Bottomley wrote:
>> The fatal livelock in kswapd, reported in this thread:
>>
>> http://marc.info/?t=3D130392066000001
>>
>> Is mitigateable if we prevent the cgroups code being so aggressive in
>> its zone shrinking (by reducing it's default shrink from 0 [everything]
>> to DEF_PRIORITY [some things]). =A0This will have an obvious knock on
>> effect to cgroup accounting, but it's better than hanging systems.
>
> Actually, it's not that obvious. =A0At least not to me. =A0I added Balbir=
,
> who added said comment and code in the first place, to CC: Here is the
> comment in full quote:
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * NOTE: Although we can get the priority field, using it
> =A0 =A0 =A0 =A0 * here is not a good idea, since it limits the pages we c=
an scan.
> =A0 =A0 =A0 =A0 * if we don't reclaim here, the shrink_zone from balance_=
pgdat
> =A0 =A0 =A0 =A0 * will pick up pages from other mem cgroup's as well. We =
hack
> =A0 =A0 =A0 =A0 * the priority and make it zero.
> =A0 =A0 =A0 =A0 */
>
> The idea is that if one memcg is above its softlimit, we prefer
> reducing pages from this memcg over reclaiming random other pages,
> including those of other memcgs.
>
> But the code flow looks like this:
>
> =A0 =A0 =A0 =A0balance_pgdat
> =A0 =A0 =A0 =A0 =A0mem_cgroup_soft_limit_reclaim
> =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_shrink_node_zone
> =A0 =A0 =A0 =A0 =A0 =A0 =A0shrink_zone(0, zone, &sc)
> =A0 =A0 =A0 =A0 =A0shrink_zone(prio, zone, &sc)
>
> so the success of the inner memcg shrink_zone does at least not
> explicitely result in the outer, global shrink_zone steering clear of
> other memcgs' pages. =A0It just tries to move the pressure of balancing
> the zones to the memcg with the biggest soft limit excess. =A0That can
> only really work if the memcg is a large enough contributor to the
> zone's total number of lru pages, though, and looks very likely to hit
> the exceeding memcg too hard in other cases.
yes, the logic is selecting one memcg(the one exceeding the most) and
starting hierarchical reclaim on it. It will looping until the the
following condition becomes true:
1. memcg usage is below its soft_limit
2. looping 100 times
3. reclaimed pages equal or greater than (excess >>2) where excess is
the (usage - soft_limit)

hmm, the worst case i can think of is the memcg only has one page
allocate on the zone, and we end up looping 100 time each time and not
contributing much to the global reclaim.

>
> I am very much for removing this hack. =A0There is still more scan
> pressure applied to memcgs in excess of their soft limit even if the
> extra scan is happening at a sane priority level. =A0And the fact that
> global reclaim operates completely unaware of memcgs is a different
> story.
>
> However, this code came into place with v2.6.31-8387-g4e41695. =A0Why is
> it only now showing up?
>
> You also wrote in that thread that this happens on a standard F15
> installation. =A0On the F15 I am running here, systemd does not
> configure memcgs, however. =A0Did you manually configure memcgs and set
> soft limits? =A0Because I wonder how it ended up in soft limit reclaim
> in the first place.

curious as well. if we have workload to reproduce it, i would like to try

--Ying
>
> =A0 =A0 =A0 =A0Hannes
>
>> Signed-off-by: James Bottomley <James.Bottomley@suse.de>
>>
>> ---
>>
>> >From 74b62fc417f07e1411d98181631e4e097c8e3e68 Mon Sep 17 00:00:00 2001
>> From: James Bottomley <James.Bottomley@HansenPartnership.com>
>> Date: Mon, 2 May 2011 14:56:29 -0500
>> Subject: [PATCH] vmscan: move containers scan back to default priority
>>
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index f6b435c..46cde92 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2173,8 +2173,12 @@ unsigned long mem_cgroup_shrink_node_zone(struct =
mem_cgroup *mem,
>> =A0 =A0 =A0 =A0* if we don't reclaim here, the shrink_zone from balance_=
pgdat
>> =A0 =A0 =A0 =A0* will pick up pages from other mem cgroup's as well. We =
hack
>> =A0 =A0 =A0 =A0* the priority and make it zero.
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* FIXME: jejb: zero here was causing a livelock in the
>> + =A0 =A0 =A0* shrinker so changed to DEF_PRIORITY to fix this. Now need=
 to
>> + =A0 =A0 =A0* sort out cgroup accounting.
>> =A0 =A0 =A0 =A0*/
>> - =A0 =A0 shrink_zone(0, zone, &sc);
>> + =A0 =A0 shrink_zone(DEF_PRIORITY, zone, &sc);
>>
>> =A0 =A0 =A0 trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed)=
;
>>
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
