Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B3D436B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 12:14:15 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1683789bwz.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 09:14:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602150123.GE28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-3-git-send-email-hannes@cmpxchg.org>
	<BANLkTikKHq=NBAPOXJVDM7ZEc9CkW+HdmQ@mail.gmail.com>
	<20110602150123.GE28684@cmpxchg.org>
Date: Fri, 3 Jun 2011 01:14:12 +0900
Message-ID: <BANLkTinWGEJHf1MhzDS4JB0-V9iynoFoHA@mail.gmail.com>
Subject: Re: [patch 2/8] mm: memcg-aware global reclaim
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/6/3 Johannes Weiner <hannes@cmpxchg.org>:
> On Thu, Jun 02, 2011 at 10:59:01PM +0900, Hiroyuki Kamezawa wrote:
>> 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:

>> > @@ -1927,8 +1980,7 @@ static int mem_cgroup_do_charge(struct mem_cgrou=
p *mem, gfp_t gfp_mask,
>> > =A0 =A0 =A0 =A0if (!(gfp_mask & __GFP_WAIT))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_WOULDBLOCK;
>> >
>> > - =A0 =A0 =A0 ret =3D mem_cgroup_hierarchical_reclaim(mem_over_limit, =
NULL,
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_mask, flags);
>> > + =A0 =A0 =A0 ret =3D mem_cgroup_reclaim(mem_over_limit, gfp_mask, fla=
gs);
>> > =A0 =A0 =A0 =A0if (mem_cgroup_margin(mem_over_limit) >=3D nr_pages)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return CHARGE_RETRY;
>> > =A0 =A0 =A0 =A0/*
>>
>> It seems this clean-up around hierarchy and softlimit can be in an
>> independent patch, no ?
>
> Hm, why do you think it's a cleanup? =A0The hierarchical target reclaim
> code is moved to vmscan.c and as a result the entry points for hard
> limit and soft limit reclaim differ. =A0This is why the original
> function, mem_cgroup_hierarchical_reclaim() has to be split into two
> parts.
>
If functionality is unchanged, I think it's clean up.
I agree to move hierarchy walk to vmscan.c. but it can be done as
a clean up patch for current code.
(Make current try_to_free_mem_cgroup_pages() to use this code.)
 and then, you can write a patch which only includes a core
logic/purpose of this patch
"use root cgroup's LRU for global and make global reclaim as full-scan
of memcgroup."

In short, I felt this patch is long....and maybe watchers of -mm are
not interested in rewritie of hierarchy walk but are intetested in the
chages in shrink_zone() itself very much.



>> > @@ -1943,6 +1976,31 @@ restart:
>> > =A0 =A0 =A0 =A0throttle_vm_writeout(sc->gfp_mask);
>> > =A0}
>> >
>> > +static void shrink_zone(int priority, struct zone *zone,
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct scan_control *sc)
>> > +{
>> > + =A0 =A0 =A0 unsigned long nr_reclaimed_before =3D sc->nr_reclaimed;
>> > + =A0 =A0 =A0 struct mem_cgroup *root =3D sc->target_mem_cgroup;
>> > + =A0 =A0 =A0 struct mem_cgroup *first, *mem =3D NULL;
>> > +
>> > + =A0 =A0 =A0 first =3D mem =3D mem_cgroup_hierarchy_walk(root, mem);
>>
>> Hmm, I think we should add some scheduling here, later.
>> (as select a group over softlimit or select a group which has
>> =A0easily reclaimable pages on this zone.)
>>
>> This name as hierarchy_walk() sounds like "full scan in round-robin, alw=
ays".
>> Could you find better name ?
>
> Okay, I'll try.
>
>> > + =A0 =A0 =A0 for (;;) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sc->mem_cgroup =3D mem;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do_shrink_zone(priority, zone, sc);
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nr_reclaimed =3D sc->nr_reclaimed - nr_r=
eclaimed_before;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (nr_reclaimed >=3D sc->nr_to_reclaim)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> what this calculation means ? =A0Shouldn't we do this quit based on the
>> number of "scan"
>> rather than "reclaimed" ?
>
> It aborts the loop once sc->nr_to_reclaim pages have been reclaimed
> from that zone during that hierarchy walk, to prevent overreclaim.
>
> If you have unbalanced sizes of memcgs in the system, it is not
> desirable to have every reclaimer scan all memcgs, but let those quit
> early that have made some progress on the bigger memcgs.
>
Hmm, why not if (sc->nr_reclaimed >=3D sc->nr_to_reclaim) ?

I'm sorry if I miss something..


> It's essentially a forward progagation of the same check in
> do_shrink_zone(). =A0It trades absolute fairness for average reclaim
> latency.
>
> Note that kswapd sets the reclaim target to infinity, so this
> optimization applies only to direct reclaimers.
>
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_hierarchy_walk(root, =
mem);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem =3D=3D first)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>>
>> Why we quit loop =A0?
>
> get_scan_count() for traditional global reclaim returns the scan
> target for the zone.
>
> With this per-memcg reclaimer, get_scan_count() will return scan
> targets for the respective per-memcg zone subsizes.
>
> So once we have gone through all memcgs, we should have scanned the
> amount of pages that global reclaim would have deemed sensible for
> that zone at that priority level.
>
> As such, this is the exit condition based on scan count you referred
> to above.
>
That's what I want as a comment in codes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
