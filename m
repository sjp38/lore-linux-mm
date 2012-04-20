Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B47616B00F9
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 18:50:30 -0400 (EDT)
Received: by lagz14 with SMTP id z14so10206117lag.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2012 15:50:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120420185846.GD15021@tiehlicka.suse.cz>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
	<20120418122448.GB1771@cmpxchg.org>
	<CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
	<20120419170434.GE15634@tiehlicka.suse.cz>
	<CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
	<20120419223318.GA2536@cmpxchg.org>
	<CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
	<20120420131722.GD2536@cmpxchg.org>
	<CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
	<20120420185846.GD15021@tiehlicka.suse.cz>
Date: Fri, 20 Apr 2012 15:50:28 -0700
Message-ID: <CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 11:58 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Fri 20-04-12 10:44:14, Ying Han wrote:
>> On Fri, Apr 20, 2012 at 6:17 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > Let me repeat the pros here: no breaking of existing semantics. =A0No
>> > introduction of unprecedented semantics into the cgroup mess. =A0No
>> > changing of kernel code necessary (except what we want to tune
>> > anyway). =A0No computational overhead for you or anyone else.
>>
>> >
>> > If your only counter argument to this is that you can't be bothered to
>> > slightly adjust your setup, I'm no longer interested in this
>> > discussion.
>>
>> Before going further, I wanna make sure there is no mis-communication
>> here. As I replied to Michal, I feel that we are mixing up global
>> reclaim and target reclaim policy here.
>
> I was referring to the global reclaim and my understanding is that
> Johannes did the same when talking about soft reclaim (even though it
> makes some sense to apply the same rules to the hard limit reclaim as
> well - but later to that one...)
>
> The primary question is whether soft reclaim should be hierarchical or
> not. That is what I've tried to express in other email earlier in this
> thread where I've tried (very briefly) to compare those approaches.
> It currently _is_ hierarchical and your patch changes that so we have to
> be sure that this change in semantic is reasonable.

Yes, after reading the other thread and I suddenly realized what you
guys are talking about.

The only workload
> that you seem to consider is when you have a full control over the
> machine while Johannes is considered about containers which might misuse
> your approach to push out working sets of concurrency...
> My concern with hierarchical approach is that it doesn't play well with
> 0 default (which is needed if we want to make soft limit a guarantee,
> right?). I do agree with Johannes about the potential misuse though. =A0S=
o
> it seems that both approaches have serious issues with configurability.
> Does this summary clarify the issue a bit? Or I am confused as well ;)

Thank you for the good summary and now we are on the same page :)

Regarding the misuse case, here I am gonna layout the ground rule for
setting up soft_limit:

"
Never over-commit the system by softlimit.
"

Considering the following:

root (32G, use_hierarchy =3D 1)
   -- A (soft: 16G, usage 22G)
       -- A1 (soft: 10G, usage 17G)
       -- A2 (soft: 6G, usage 5G)
   -- B (soft: 16G, usage 10G)

1) sum_of_softlimit(A + B) <=3D machine capacity
2) sum_of_softlimit(A1 + A2) <=3D softlimit(A)

So we have both A and A1 above softlimit. If we follow the ground rule
to set up the softlimit, we should be confidence to say that "If A is
above its softlimit, there must be cgroups under A who are also above
softlimit". We can still leave the priority check there in case all
the pages from A1 are hard to reclaim, and then we will look into A2
only by then.

I think it is reasonable to layout this upfront, otherwise we can not
make all the misuse cases right. And if we follow that route, lots of
things will become clear.

--Ying
>
> I am more inclined towards selective soft reclaim and make configuration
> admin's responsibility (if you want some guarantee, admin has to approve
> that and set it for you).


This, however, doesn't enable self-ballooning
> use case but I am not entirely sure this would work without a global
> (admin) cooperation.
>
>> The way global reclaim works today is to scan all the mem cgroups to
>> fulfill the overall scan target per zone, and there is no bottom up
>> look up.
>
> bottom up was just an idea without anything in hands so let's put it
> aside for now.
>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
