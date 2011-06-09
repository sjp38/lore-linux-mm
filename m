Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0BB3E6B0083
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 13:36:59 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p59Hapth018471
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 10:36:54 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by wpaz5.hot.corp.google.com with ESMTP id p59HZgON026973
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 10:36:50 -0700
Received: by qyk29 with SMTP id 29so2709138qyk.3
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 10:36:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110609083503.GC11603@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
	<20110602075028.GB20630@cmpxchg.org>
	<BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
	<20110602175142.GH28684@cmpxchg.org>
	<BANLkTi=9083abfiKdZ5_oXyA+dZqaXJfZg@mail.gmail.com>
	<20110608153211.GB27827@cmpxchg.org>
	<BANLkTincHpoay1JtpjG0RY9CCvfepRohTXUH6KKULYJ9jbdo+A@mail.gmail.com>
	<20110609083503.GC11603@cmpxchg.org>
Date: Thu, 9 Jun 2011 10:36:47 -0700
Message-ID: <BANLkTiknpTjj3saw+zS5ABeD+4ESz68xvRot7TTvKs7A_RtrdA@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2011 at 1:35 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Jun 08, 2011 at 08:52:03PM -0700, Ying Han wrote:
>> On Wed, Jun 8, 2011 at 8:32 AM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>> > On Tue, Jun 07, 2011 at 08:53:21PM -0700, Ying Han wrote:
>> >> 2. The way we treat the per-memcg soft_limit is changed in this patch=
.
>> >> The same comment I made on the following patch where we shouldn't
>> >> change the definition of user API (soft_limit_in_bytes in this case).
>> >> So I attached the patch to fix that where we should only go to the
>> >> ones under their soft_limit above certain reclaim priority. Please
>> >> consider.
>> >
>> > Here is your proposal from the other mail:
>> >
>> > : Basically, we shouldn't reclaim from a memcg under its soft_limit
>> > : unless we have trouble reclaim pages from others. Something like the
>> > : following makes better sense:
>> > :
>> > : diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > : index bdc2fd3..b82ba8c 100644
>> > : --- a/mm/vmscan.c
>> > : +++ b/mm/vmscan.c
>> > : @@ -1989,6 +1989,8 @@ restart:
>> > : =A0 =A0 =A0 =A0 throttle_vm_writeout(sc->gfp_mask);
>> > : =A0}
>> > :
>> > : +#define MEMCG_SOFTLIMIT_RECLAIM_PRIORITY =A0 =A0 =A0 2
>> > : +
>> > : =A0static void shrink_zone(int priority, struct zone *zone,
>> > : =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 stru=
ct scan_control *sc)
>> > : =A0{
>> > : @@ -2001,13 +2003,13 @@ static void shrink_zone(int priority, struct=
 zone *zone,
>> > : =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long reclaimed =3D sc->nr_r=
eclaimed;
>> > : =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scanned =3D sc->nr_sca=
nned;
>> > : =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
>> > : - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>> > :
>> > : - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(roo=
t, mem))
>> > : - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
>> > : + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_soft_limit_exceeded(ro=
ot, mem) &&
>> > : + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priori=
ty > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
>> > : + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> >
>> > I am not sure if you are serious or playing devil's advocate here,
>> > because it exacerbates the problem you are concerned about in 1. by
>> > orders of magnitude.
>>
>> No, the two are different issues. The first one is a performance
>> concern of detailed implementation, while the second one is a design
>> concern.
>
> Got ya.
>
>> > I guess it would make much more sense to evaluate if reclaiming from
>> > memcgs while there are others exceeding their soft limit is even a
>> > problem. =A0Otherwise this discussion is pretty pointless.
>>
>> AFAIK it is a problem since it changes the spec of kernel API
>> memory.soft_limit_in_bytes. That value is set per-memcg which all the
>> pages allocated above that are best effort and targeted to reclaim
>> prior to others.
>
> That's not really true. =A0Quoting the documentation:
>
> =A0 =A0When the system detects memory contention or low memory, control g=
roups
> =A0 =A0are pushed back to their soft limits. If the soft limit of each co=
ntrol
> =A0 =A0group is very high, they are pushed back as much as possible to ma=
ke
> =A0 =A0sure that one control group does not starve the others of memory.
>
> I am language lawyering here, but I don't think it says it won't touch
> other memcgs at all while there are memcgs exceeding their soft limit.

Well... :) I would say that the documentation of soft_limit needs lots
of work especially after lots of discussions we have after the LSF.

The RFC i sent after our discussion has the following documentation,
and I only cut & paste the content relevant to our conversation here:

What is "soft_limit"?
The "soft_limit was introduced in memcg to support over-committing the
memory resource on the host. Each cgroup can be configured with
"hard_limit", where it will be throttled or OOM killed by going over
the limit. However, the allocation can go above the "soft_limit" as
long as there is no memory contention. The "soft_limit" is the kernel
mechanism for re-distributing spare memory resource among cgroups.

What we have now?
The current implementation of softlimit is based on per-zone RB tree,
where only the cgroup exceeds the soft_limit the most being selected
for reclaim.

It makes less sense to only reclaim from one cgroup rather than
reclaiming all cgroups based on calculated propotion. This is required
for fairness.

Proposed design:
round-robin across the cgroups where they have memory allocated on the
zone and also exceed the softlimit configured.

there was a question on how to do zone balancing w/o global LRU. This
could be solved by building another cgroup list per-zone, where we
also link cgroups under their soft_limit. We won't scan the list
unless the first list being exhausted and
the free pages is still under the high_wmark.

Since the per-zone memcg list design is being replaced by your
patchset, some of the details doesn't apply. But the concept still
remains where we would like to scan some memcgs first (above
soft_limit) .

>
> It would be a lie about the current code in the first place, which
> does soft limit reclaim and then regular reclaim, no matter the
> outcome of the soft limit reclaim cycle. =A0It will go for the soft
> limit first, but after an allocation under pressure the VM is likely
> to have reclaimed from other memcgs as well.
>
> I saw your patch to fix that and break out of reclaim if soft limit
> reclaim did enough. =A0But this fix is not much newer than my changes.

My soft_limit patch was developed in parallel with your patchset, and
most of that wouldn't apply here.
Is that what you are referring to?

>
> The second part of this is:
>
> =A0 =A0Please note that soft limits is a best effort feature, it comes wi=
th
> =A0 =A0no guarantees, but it does its best to make sure that when memory =
is
> =A0 =A0heavily contended for, memory is allocated based on the soft limit
> =A0 =A0hints/setup. Currently soft limit based reclaim is setup such that
> =A0 =A0it gets invoked from balance_pgdat (kswapd).

We had patch merged which add the soft_limit reclaim also in the global ttf=
p.

memcg-add-the-soft_limit-reclaim-in-global-direct-reclaim.patch

> It's not the pages-over-soft-limit that are best effort. =A0It says that
> it tries its best to take soft limits into account while reclaiming.
Hmm. Both cases are true. The best effort pages I referring to means
"the page above the soft_limit are targeted to reclaim first under
memory contention"

>
> My code does that, so I don't think we are breaking any promises
> currently made in the documentation.
>
> But much more important than keeping documentation promises is not to
> break actual users. =A0So if you are yourself a user of soft limits,
> test the new code pretty please and complain if it breaks your setup!

Yes, I've been running tests on your patchset, but not getting into
specific configurations yet. But I don't think it is hard to generate
the following scenario:

on 32G machine, under root I have three cgroups with 20G hard_limit and
cgroup-A: soft_limit 1g, usage 20g with clean file pages
cgroup-B: soft_limit 10g, usage 5g with clean file pages
cgroup-C: soft_limit 10g, usage 5g with clean file pages

I would assume reclaiming from cgroup-A should be sufficient under
global memory pressure, and no pages needs to be reclaimed from B or
C, especially both of them have memory usage under their soft_limit.

I see we also have discussion on the soft_limit reclaim on the [patch
4] with Michal, then i might start working on that.

--Ying




>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
