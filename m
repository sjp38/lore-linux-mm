Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 27BC36B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 20:48:41 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1401959qwa.14
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 17:48:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110610003407.GA27964@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<20110609154839.GF4878@barrios-laptop>
	<20110609172347.GB20333@cmpxchg.org>
	<BANLkTimD-pecv82qAZkyxA9nLQWbcDry-w@mail.gmail.com>
	<BANLkTin7uRdUg_mer3ve5nz3WjX9qjP4SQ@mail.gmail.com>
	<20110610003407.GA27964@cmpxchg.org>
Date: Fri, 10 Jun 2011 09:48:38 +0900
Message-ID: <BANLkTinwCFgocsPOvutV-s4Z33-+YFRJfw@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jun 10, 2011 at 9:34 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Fri, Jun 10, 2011 at 08:47:55AM +0900, Minchan Kim wrote:
>> On Fri, Jun 10, 2011 at 8:41 AM, Minchan Kim <minchan.kim@gmail.com> wro=
te:
>> > On Fri, Jun 10, 2011 at 2:23 AM, Johannes Weiner <hannes@cmpxchg.org> =
wrote:
>> >> On Fri, Jun 10, 2011 at 12:48:39AM +0900, Minchan Kim wrote:
>> >>> On Wed, Jun 01, 2011 at 08:25:13AM +0200, Johannes Weiner wrote:
>> >>> > When a memcg hits its hard limit, hierarchical target reclaim is
>> >>> > invoked, which goes through all contributing memcgs in the hierarc=
hy
>> >>> > below the offending memcg and reclaims from the respective per-mem=
cg
>> >>> > lru lists. =C2=A0This distributes pressure fairly among all involv=
ed
>> >>> > memcgs, and pages are aged with respect to their list buddies.
>> >>> >
>> >>> > When global memory pressure arises, however, all this is dropped
>> >>> > overboard. =C2=A0Pages are reclaimed based on global lru lists tha=
t have
>> >>> > nothing to do with container-internal age, and some memcgs may be
>> >>> > reclaimed from much more than others.
>> >>> >
>> >>> > This patch makes traditional global reclaim consider container
>> >>> > boundaries and no longer scan the global lru lists. =C2=A0For each=
 zone
>> >>> > scanned, the memcg hierarchy is walked and pages are reclaimed fro=
m
>> >>> > the per-memcg lru lists of the respective zone. =C2=A0For now, the
>> >>> > hierarchy walk is bounded to one full round-trip through the
>> >>> > hierarchy, or if the number of reclaimed pages reach the overall
>> >>> > reclaim target, whichever comes first.
>> >>> >
>> >>> > Conceptually, global memory pressure is then treated as if the roo=
t
>> >>> > memcg had hit its limit. =C2=A0Since all existing memcgs contribut=
e to the
>> >>> > usage of the root memcg, global reclaim is nothing more than targe=
t
>> >>> > reclaim starting from the root memcg. =C2=A0The code is mostly the=
 same for
>> >>> > both cases, except for a few heuristics and statistics that do not
>> >>> > always apply. =C2=A0They are distinguished by a newly introduced
>> >>> > global_reclaim() primitive.
>> >>> >
>> >>> > One implication of this change is that pages have to be linked to =
the
>> >>> > lru lists of the root memcg again, which could be optimized away w=
ith
>> >>> > the old scheme. =C2=A0The costs are not measurable, though, even w=
ith
>> >>> > worst-case microbenchmarks.
>> >>> >
>> >>> > As global reclaim no longer relies on global lru lists, this chang=
e is
>> >>> > also in preparation to remove those completely.
>> >>
>> >> [cut diff]
>> >>
>> >>> I didn't look at all, still. You might change the logic later patche=
s.
>> >>> If I understand this patch right, it does round-robin reclaim in all=
 memcgs
>> >>> when global memory pressure happens.
>> >>>
>> >>> Let's consider this memcg size unbalance case.
>> >>>
>> >>> If A-memcg has lots of LRU pages, scanning count for reclaim would b=
e bigger
>> >>> so the chance to reclaim the pages would be higher.
>> >>> If we reclaim A-memcg, we can reclaim the number of pages we want ea=
sily and break.
>> >>> Next reclaim will happen at some time and reclaim will start the B-m=
emcg of A-memcg
>> >>> we reclaimed successfully before. But unfortunately B-memcg has smal=
l lru so
>> >>> scanning count would be small and small memcg's LRU aging is higher =
than bigger memcg.
>> >>> It means small memcg's working set can be evicted easily than big me=
mcg.
>> >>> my point is that we should not set next memcg easily.
>> >>> We have to consider memcg LRU size.
>> >>
>> >> I may be missing something, but you said yourself that B had a smalle=
r
>> >> scan count compared to A, so the aging speed should be proportional t=
o
>> >> respective size.
>> >>
>> >> The number of pages scanned per iteration is essentially
>> >>
>> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0number of lru pages in memcg-zone >> prior=
ity
>> >>
>> >> so we scan relatively more pages from B than from A each round.
>> >>
>> >> It's the exact same logic we have been applying traditionally to
>> >> distribute pressure fairly among zones to equalize their aging speed.
>> >>
>> >> Is that what you meant or are we talking past each other?
>> >
>> > True if we can reclaim pages easily(ie, default priority) in all memcg=
s.
>> > But let's think about it.
>> > Normally direct reclaim path reclaims only SWAP_CLUSTER_MAX size.
>> > If we have small memcg, scan window size would be smaller and it is
>> > likely to be hard reclaim in the priority compared to bigger memcg. It
>> > means it can raise priority easily in small memcg and even it might
>> > call lumpy or compaction in case of global memory pressure. It can
>> > churn all LRU order. :(
>> > Of course, we have bailout routine so we might make such unfair aging
>> > effect small but it's not same with old behavior(ie, single LRU list,
>> > fair aging POV global according to priority raise)
>>
>> To make fair, how about considering turn over different memcg before
>> raise up priority?
>> It can make aging speed fairly while it can make high contention of
>> lru_lock. :(
>
> Actually, the way you describe it is how it used to work for limit
> reclaim before my patches. =C2=A0It would select one memcg, then reclaim
> with increasing priority until SWAP_CLUSTER_MAX were reclaimed.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memcg =3D select_victim()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for each prio:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for each zone:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0shrink_zone(prio, zone, sc =3D {=
 .mem_cgroup =3D memcg })
>
> What it's supposed to do with my patches is scan all memcgs in the
> hierarchy at the same priority. =C2=A0If it hasn't made progress, it will
> increase the priority and iterate again over the hierarchy.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for each prio:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for each zone:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0for each memcg:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0do_shrink_zone(prio, zone=
, sc =3D { .mem_cgroup =3D memcg })
>
>

Right you are. I got confused with old behavior which wasn't good.
Your way is very desirable to me and my concern disappear.
Thanks, Hannes.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
