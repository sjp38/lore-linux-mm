Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B97436B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 18:30:35 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p59MUSPe013635
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:30:28 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by wpaz29.hot.corp.google.com with ESMTP id p59MTV3J007976
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 15:30:27 -0700
Received: by qwc9 with SMTP id 9so1367223qwc.13
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 15:30:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110609183637.GC20333@cmpxchg.org>
References: <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
	<20110602075028.GB20630@cmpxchg.org>
	<BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
	<20110602175142.GH28684@cmpxchg.org>
	<BANLkTi=9083abfiKdZ5_oXyA+dZqaXJfZg@mail.gmail.com>
	<20110608153211.GB27827@cmpxchg.org>
	<BANLkTincHpoay1JtpjG0RY9CCvfepRohTXUH6KKULYJ9jbdo+A@mail.gmail.com>
	<20110609083503.GC11603@cmpxchg.org>
	<BANLkTiknpTjj3saw+zS5ABeD+4ESz68xvRot7TTvKs7A_RtrdA@mail.gmail.com>
	<20110609183637.GC20333@cmpxchg.org>
Date: Thu, 9 Jun 2011 15:30:27 -0700
Message-ID: <BANLkTin3ZZYXdZgSFfi=8QMnN5we8RcoMyZ_vM3kdbRXCaoWnw@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2011 at 11:36 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Thu, Jun 09, 2011 at 10:36:47AM -0700, Ying Han wrote:
>> On Thu, Jun 9, 2011 at 1:35 AM, Johannes Weiner <hannes@cmpxchg.org> wro=
te:
>> > On Wed, Jun 08, 2011 at 08:52:03PM -0700, Ying Han wrote:
>> >> On Wed, Jun 8, 2011 at 8:32 AM, Johannes Weiner <hannes@cmpxchg.org> =
wrote:
>> >> > I guess it would make much more sense to evaluate if reclaiming fro=
m
>> >> > memcgs while there are others exceeding their soft limit is even a
>> >> > problem. =A0Otherwise this discussion is pretty pointless.
>> >>
>> >> AFAIK it is a problem since it changes the spec of kernel API
>> >> memory.soft_limit_in_bytes. That value is set per-memcg which all the
>> >> pages allocated above that are best effort and targeted to reclaim
>> >> prior to others.
>> >
>> > That's not really true. =A0Quoting the documentation:
>> >
>> > =A0 =A0When the system detects memory contention or low memory, contro=
l groups
>> > =A0 =A0are pushed back to their soft limits. If the soft limit of each=
 control
>> > =A0 =A0group is very high, they are pushed back as much as possible to=
 make
>> > =A0 =A0sure that one control group does not starve the others of memor=
y.
>> >
>> > I am language lawyering here, but I don't think it says it won't touch
>> > other memcgs at all while there are memcgs exceeding their soft limit.
>>
>> Well... :) I would say that the documentation of soft_limit needs lots
>> of work especially after lots of discussions we have after the LSF.
>>
>> The RFC i sent after our discussion has the following documentation,
>> and I only cut & paste the content relevant to our conversation here:
>>
>> What is "soft_limit"?
>> The "soft_limit was introduced in memcg to support over-committing the
>> memory resource on the host. Each cgroup can be configured with
>> "hard_limit", where it will be throttled or OOM killed by going over
>> the limit. However, the allocation can go above the "soft_limit" as
>> long as there is no memory contention. The "soft_limit" is the kernel
>> mechanism for re-distributing spare memory resource among cgroups.
>>
>> What we have now?
>> The current implementation of softlimit is based on per-zone RB tree,
>> where only the cgroup exceeds the soft_limit the most being selected
>> for reclaim.
>>
>> It makes less sense to only reclaim from one cgroup rather than
>> reclaiming all cgroups based on calculated propotion. This is required
>> for fairness.
>>
>> Proposed design:
>> round-robin across the cgroups where they have memory allocated on the
>> zone and also exceed the softlimit configured.
>>
>> there was a question on how to do zone balancing w/o global LRU. This
>> could be solved by building another cgroup list per-zone, where we
>> also link cgroups under their soft_limit. We won't scan the list
>> unless the first list being exhausted and
>> the free pages is still under the high_wmark.
>>
>> Since the per-zone memcg list design is being replaced by your
>> patchset, some of the details doesn't apply. But the concept still
>> remains where we would like to scan some memcgs first (above
>> soft_limit) .
>
> I think the most important thing we wanted was to round-robin scan all
> soft limit excessors instead of just the biggest one. =A0I understood
> this is the biggest fault with soft limits right now.
>
> We came up with maintaining a list of excessors, rather than a tree,
> and from this particular implementation followed naturally that this
> list is scanned BEFORE we look at other memcgs at all.
>
> This is a nice to have, but it was never the primary problem with the
> soft limit implementation, as far as I understood.
>
>> > It would be a lie about the current code in the first place, which
>> > does soft limit reclaim and then regular reclaim, no matter the
>> > outcome of the soft limit reclaim cycle. =A0It will go for the soft
>> > limit first, but after an allocation under pressure the VM is likely
>> > to have reclaimed from other memcgs as well.
>> >
>> > I saw your patch to fix that and break out of reclaim if soft limit
>> > reclaim did enough. =A0But this fix is not much newer than my changes.
>>
>> My soft_limit patch was developed in parallel with your patchset, and
>> most of that wouldn't apply here.
>> Is that what you are referring to?
>
> No, I meant that the current behaviour is old and we are only changing
> it only now, so we are not really breaking backward compatibility.
>
>> > The second part of this is:
>> >
>> > =A0 =A0Please note that soft limits is a best effort feature, it comes=
 with
>> > =A0 =A0no guarantees, but it does its best to make sure that when memo=
ry is
>> > =A0 =A0heavily contended for, memory is allocated based on the soft li=
mit
>> > =A0 =A0hints/setup. Currently soft limit based reclaim is setup such t=
hat
>> > =A0 =A0it gets invoked from balance_pgdat (kswapd).
>>
>> We had patch merged which add the soft_limit reclaim also in the global =
ttfp.
>>
>> memcg-add-the-soft_limit-reclaim-in-global-direct-reclaim.patch
>>
>> > It's not the pages-over-soft-limit that are best effort. =A0It says th=
at
>> > it tries its best to take soft limits into account while reclaiming.
>> Hmm. Both cases are true. The best effort pages I referring to means
>> "the page above the soft_limit are targeted to reclaim first under
>> memory contention"
>
> I really don't know where you are taking this from. =A0That is neither
> documented anywhere, nor is it the current behaviour.

I got the email from andrew on may 27 and you were on the cc-ed :)
Anyway, i just forwarded you that one.

--Ying

>
> Yeah, currently the soft limit reclaim cycle preceeds the generic
> reclaim cycle. =A0But the end result is that other memcgs are reclaimed
> from as well in both cases. =A0The exact timing is irrelevant.
>
> And this has been the case for a long time, so I don't think my rework
> breaks existing users in that regard.
>
>> > My code does that, so I don't think we are breaking any promises
>> > currently made in the documentation.
>> >
>> > But much more important than keeping documentation promises is not to
>> > break actual users. =A0So if you are yourself a user of soft limits,
>> > test the new code pretty please and complain if it breaks your setup!
>>
>> Yes, I've been running tests on your patchset, but not getting into
>> specific configurations yet. But I don't think it is hard to generate
>> the following scenario:
>>
>> on 32G machine, under root I have three cgroups with 20G hard_limit and
>> cgroup-A: soft_limit 1g, usage 20g with clean file pages
>> cgroup-B: soft_limit 10g, usage 5g with clean file pages
>> cgroup-C: soft_limit 10g, usage 5g with clean file pages
>>
>> I would assume reclaiming from cgroup-A should be sufficient under
>> global memory pressure, and no pages needs to be reclaimed from B or
>> C, especially both of them have memory usage under their soft_limit.
>
> Keep in mind that memcgs are scanned proportionally to their size,
> that we start out with relatively low scan counts, and that the
> priority levels are a logarithmic scale.
>
> The formula is essentially this:
>
> =A0 =A0 =A0 =A0(usage / PAGE_SIZE) >> priority
>
> which means that we would scan as follows, with decreased soft limit
> priority for A:
>
> =A0 =A0 =A0 =A0A: ((20 << 30) >> 12) >> 11 =3D 2560 pages
> =A0 =A0 =A0 =A0B: (( 5 << 30) >> 12) >> 12 =3D =A0320 pages
> =A0 =A0 =A0 =A0C: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=3D =
=A0320 pages.
>
> So even if B and C are scanned, they are only shrunk by a bit over a
> megabyte tops. =A0For decreasing levels (if they are reached at all if
> there is clean cache around):
>
> =A0 =A0 =A0 =A0A: 20M 40M 80M 160M ...
> =A0 =A0 =A0 =A0B: =A02M =A04M =A08M =A016M ...
>
> While it would be sufficient to reclaim only from A, actually
> reclaiming from B and C is not a big deal in practice, I would
> suspect.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
