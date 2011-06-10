Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6965F6B004A
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 20:17:11 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p5A0H7gc004983
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 17:17:07 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by wpaz9.hot.corp.google.com with ESMTP id p5A0Erah027549
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 9 Jun 2011 17:17:05 -0700
Received: by qyj19 with SMTP id 19so3254556qyj.2
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 17:17:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110609233154.GA26745@cmpxchg.org>
References: <20110602075028.GB20630@cmpxchg.org>
	<BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
	<20110602175142.GH28684@cmpxchg.org>
	<BANLkTi=9083abfiKdZ5_oXyA+dZqaXJfZg@mail.gmail.com>
	<20110608153211.GB27827@cmpxchg.org>
	<BANLkTincHpoay1JtpjG0RY9CCvfepRohTXUH6KKULYJ9jbdo+A@mail.gmail.com>
	<20110609083503.GC11603@cmpxchg.org>
	<BANLkTiknpTjj3saw+zS5ABeD+4ESz68xvRot7TTvKs7A_RtrdA@mail.gmail.com>
	<20110609183637.GC20333@cmpxchg.org>
	<BANLkTin3ZZYXdZgSFfi=8QMnN5we8RcoMyZ_vM3kdbRXCaoWnw@mail.gmail.com>
	<20110609233154.GA26745@cmpxchg.org>
Date: Thu, 9 Jun 2011 17:17:05 -0700
Message-ID: <BANLkTi=SD7-W17bT-+ZujA68BiAXyEmbC_tE+aLHEtQ6jzXBHQ@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2011 at 4:31 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Thu, Jun 09, 2011 at 03:30:27PM -0700, Ying Han wrote:
>> On Thu, Jun 9, 2011 at 11:36 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Thu, Jun 09, 2011 at 10:36:47AM -0700, Ying Han wrote:
>> >> On Thu, Jun 9, 2011 at 1:35 AM, Johannes Weiner <hannes@cmpxchg.org> =
wrote:
>> >> > On Wed, Jun 08, 2011 at 08:52:03PM -0700, Ying Han wrote:
>> >> >> On Wed, Jun 8, 2011 at 8:32 AM, Johannes Weiner <hannes@cmpxchg.or=
g> wrote:
>> >> >> > I guess it would make much more sense to evaluate if reclaiming =
from
>> >> >> > memcgs while there are others exceeding their soft limit is even=
 a
>> >> >> > problem. =A0Otherwise this discussion is pretty pointless.
>> >> >>
>> >> >> AFAIK it is a problem since it changes the spec of kernel API
>> >> >> memory.soft_limit_in_bytes. That value is set per-memcg which all =
the
>> >> >> pages allocated above that are best effort and targeted to reclaim
>> >> >> prior to others.
>> >> >
>> >> > That's not really true. =A0Quoting the documentation:
>> >> >
>> >> > =A0 =A0When the system detects memory contention or low memory, con=
trol groups
>> >> > =A0 =A0are pushed back to their soft limits. If the soft limit of e=
ach control
>> >> > =A0 =A0group is very high, they are pushed back as much as possible=
 to make
>> >> > =A0 =A0sure that one control group does not starve the others of me=
mory.
>> >> >
>> >> > I am language lawyering here, but I don't think it says it won't to=
uch
>> >> > other memcgs at all while there are memcgs exceeding their soft lim=
it.
>> >>
>> >> Well... :) I would say that the documentation of soft_limit needs lot=
s
>> >> of work especially after lots of discussions we have after the LSF.
>> >>
>> >> The RFC i sent after our discussion has the following documentation,
>> >> and I only cut & paste the content relevant to our conversation here:
>> >>
>> >> What is "soft_limit"?
>> >> The "soft_limit was introduced in memcg to support over-committing th=
e
>> >> memory resource on the host. Each cgroup can be configured with
>> >> "hard_limit", where it will be throttled or OOM killed by going over
>> >> the limit. However, the allocation can go above the "soft_limit" as
>> >> long as there is no memory contention. The "soft_limit" is the kernel
>> >> mechanism for re-distributing spare memory resource among cgroups.
>> >>
>> >> What we have now?
>> >> The current implementation of softlimit is based on per-zone RB tree,
>> >> where only the cgroup exceeds the soft_limit the most being selected
>> >> for reclaim.
>> >>
>> >> It makes less sense to only reclaim from one cgroup rather than
>> >> reclaiming all cgroups based on calculated propotion. This is require=
d
>> >> for fairness.
>> >>
>> >> Proposed design:
>> >> round-robin across the cgroups where they have memory allocated on th=
e
>> >> zone and also exceed the softlimit configured.
>> >>
>> >> there was a question on how to do zone balancing w/o global LRU. This
>> >> could be solved by building another cgroup list per-zone, where we
>> >> also link cgroups under their soft_limit. We won't scan the list
>> >> unless the first list being exhausted and
>> >> the free pages is still under the high_wmark.
>> >>
>> >> Since the per-zone memcg list design is being replaced by your
>> >> patchset, some of the details doesn't apply. But the concept still
>> >> remains where we would like to scan some memcgs first (above
>> >> soft_limit) .
>> >
>> > I think the most important thing we wanted was to round-robin scan all
>> > soft limit excessors instead of just the biggest one. =A0I understood
>> > this is the biggest fault with soft limits right now.
>> >
>> > We came up with maintaining a list of excessors, rather than a tree,
>> > and from this particular implementation followed naturally that this
>> > list is scanned BEFORE we look at other memcgs at all.
>> >
>> > This is a nice to have, but it was never the primary problem with the
>> > soft limit implementation, as far as I understood.
>> >
>> >> > It would be a lie about the current code in the first place, which
>> >> > does soft limit reclaim and then regular reclaim, no matter the
>> >> > outcome of the soft limit reclaim cycle. =A0It will go for the soft
>> >> > limit first, but after an allocation under pressure the VM is likel=
y
>> >> > to have reclaimed from other memcgs as well.
>> >> >
>> >> > I saw your patch to fix that and break out of reclaim if soft limit
>> >> > reclaim did enough. =A0But this fix is not much newer than my chang=
es.
>> >>
>> >> My soft_limit patch was developed in parallel with your patchset, and
>> >> most of that wouldn't apply here.
>> >> Is that what you are referring to?
>> >
>> > No, I meant that the current behaviour is old and we are only changing
>> > it only now, so we are not really breaking backward compatibility.
>> >
>> >> > The second part of this is:
>> >> >
>> >> > =A0 =A0Please note that soft limits is a best effort feature, it co=
mes with
>> >> > =A0 =A0no guarantees, but it does its best to make sure that when m=
emory is
>> >> > =A0 =A0heavily contended for, memory is allocated based on the soft=
 limit
>> >> > =A0 =A0hints/setup. Currently soft limit based reclaim is setup suc=
h that
>> >> > =A0 =A0it gets invoked from balance_pgdat (kswapd).
>> >>
>> >> We had patch merged which add the soft_limit reclaim also in the glob=
al ttfp.
>> >>
>> >> memcg-add-the-soft_limit-reclaim-in-global-direct-reclaim.patch
>> >>
>> >> > It's not the pages-over-soft-limit that are best effort. =A0It says=
 that
>> >> > it tries its best to take soft limits into account while reclaiming=
.
>> >> Hmm. Both cases are true. The best effort pages I referring to means
>> >> "the page above the soft_limit are targeted to reclaim first under
>> >> memory contention"
>> >
>> > I really don't know where you are taking this from. =A0That is neither
>> > documented anywhere, nor is it the current behaviour.
>>
>> I got the email from andrew on may 27 and you were on the cc-ed :)
>> Anyway, i just forwarded you that one.
>
> I wasn't asking about this patch at all... =A0This is the conversation:
>
> Me:
>
>> >> > It's not the pages-over-soft-limit that are best effort. =A0It says=
 that
>> >> > it tries its best to take soft limits into account while reclaiming=
.
>
> You:
>
>> >> Hmm. Both cases are true. The best effort pages I referring to means
>> >> "the page above the soft_limit are targeted to reclaim first under
>> >> memory contention"
>
> Me:
>
>> > I really don't know where you are taking this from. =A0That is neither
>> > documented anywhere, nor is it the current behaviour.
>
> And this is still my question.
>
> Current: scan up to all pages of the biggest soft limit offender, then
> reclaim from random memcgs (because of the global LRU).
agree.

>
> After my patch: scan all memcgs according to their size, with double
> the pressure on those over their soft limit.
agree.
>
> Please tell me exactly how my patch regresses existing behaviour, a
> user interface, a documented feature, etc.
>

Ok, thank you for clarifying it. Now i understand what's the confusion here=
.

I agree that your patch doesn't regress from what we have now
currently. What i referred earlier was the improvement from the
current design. So we were comparing to two targets.

Please go ahead with your patch, and I don't have problem with that
now. I will propose the soft_limit reclaim improvement as separate
thread.

Thanks

--Ying

> If you have an even better idea, please propose it.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
