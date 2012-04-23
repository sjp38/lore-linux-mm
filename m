Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id DDDEE6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 18:19:44 -0400 (EDT)
Received: by lbbgg6 with SMTP id gg6so38109lbb.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 15:19:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120421004858.GH2536@cmpxchg.org>
References: <CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
	<20120419170434.GE15634@tiehlicka.suse.cz>
	<CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
	<20120419223318.GA2536@cmpxchg.org>
	<CALWz4iy2==jYkYx98EGbqbM2Y7q4atJpv9sH_B7Fjr8aqq++JQ@mail.gmail.com>
	<20120420131722.GD2536@cmpxchg.org>
	<CALWz4iz2GZU_aa=28zQfK-a65QuC5v7zKN4Sg7SciPLXN-9dVQ@mail.gmail.com>
	<20120420185846.GD15021@tiehlicka.suse.cz>
	<CALWz4izyaywap8Qo=EO=uYqODZ4Diaio8Y41X0xjmE_UTsdSzA@mail.gmail.com>
	<20120421001914.GG2536@cmpxchg.org>
	<20120421004858.GH2536@cmpxchg.org>
Date: Mon, 23 Apr 2012 15:19:42 -0700
Message-ID: <CALWz4iybySL+=f1hBR0yQoJ3h7Dn9k1sD=Nw9HPs0dAocKktpg@mail.gmail.com>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 5:48 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> On Sat, Apr 21, 2012 at 02:19:14AM +0200, Johannes Weiner wrote:
>> It's like you're trying to redefine multiplication because you
>> accidentally used * instead of + in your equation.
>
> You could for example do this:
>
> -> A (hard limit =3D 16G)
> =A0 -> A1 (hard limit =3D 10G)
> =A0 -> A2 (hard limit =3D =A06G)
>
> and say the same: you want to account A, A1, and A2 under the same
> umbrella, so you want the same hierarchy. =A0And you want to limit the
> memory in A (from finished jobs and tasks running directly in A), but
> this limit should NOT apply to A1 and A2 when they have not reached
> THEIR respective limits.
>
> You can apply all your current arguments to this same case. =A0And yet,
> you say hierarchical hard limits make sense while hierarchical soft
> limits don't. =A0I hope this example makes it clear why this is not true
> at all.

I understand the example above which the pressure from A goes down to
A1 and A2, although neither of them reaches their hard_limit.

I am not against doing similar hierarchical reclaim on soft_limit, as
long as it is solving the problem which the soft_limit is targeted
for. The admin is setting up soft_limit to preserve working set for
each cgroup, which means that reclaim under the soft_limit could hurt
the application's performance. I assume that expectation is slightly
different from hard_limit and that's why we have two APIs instead of
one.

>
> We have cases where we want the hierarchical limits. =A0Both hard limits
> and soft limits. =A0You can easily fix your setup without taking away
> this power from everyone else or introducing inconsistency. =A0Your
> whole problem stems from a simple misconfiguration.

Let's see the following example:
A
 -- A1
 -- A2

There are three possibilities of how the soft_limit being set :

Here I use X to represent pages in A's lru only (re-parented or
process running under A) and admin wants to preserve.
1. soft_limit(A) =3D=3D soft_limit(A1) + soft_limit(A2) + X

// only reclaiming from A2 will bring the usage_in_bytes of A under
its soft_limit.
A (soft_limit =3D=3D 31G, X=3D1G, usage_in_bytes =3D 35G)
  -- A1 (soft_limit =3D=3D 15G, usage_in_bytes =3D 14G)
  -- A2 (soft_limit =3D=3D 15G, usage_in_bytes =3D 20G)

2. soft_limit(A) > soft_limit(A1) + soft_limit(A2) + X

//only reclaiming from A2 and it is ok.
A (soft_limit =3D=3D 40G, X=3D1G, usage_in_bytes =3D 35G)
  -- A1 (soft_limit =3D=3D 15G, usage_in_bytes =3D 14G)
  -- A2 (soft_limit =3D=3D 15G, usage_in_bytes =3D 20G)

3. soft_limit (A) < soft_limit(A1) + soft_limit(A2) + X

//only reclaiming from A2 doesn't help and we have to reclaim both A1 and A=
2.
A (soft_limit =3D=3D 31G, X=3D1G, usage_in_bytes =3D 35G)
  -- A1 (soft_limit =3D=3D 100G, usage_in_bytes =3D 14G)
  -- A2 (soft_limit =3D=3D 15G, usage_in_bytes =3D 20G)

If I understand correctly, the case3 is what my patch works
differently from yours. The difference is that my patch won't reclaim
from A1 but it is reclaimed from yours.

AFAIK, in most of the cases (if not all), the case1 would be adopted
by admin and that is what I've been trying to make to work. On the
other hand, i agree w/ you that we shouldn't constrain ourselves to
support only one configuration. But here is my question:

1. Do you agree that case1 would be the configuration makes most of
the senses for admin ?

2. If the answer of 1) is yes, do you agree that your proposal doesn't
work well w/ the admin's expectation ?

Meanwhile, i haven't figured out whether case 3 would be a well
adopted configuration. But let me guess why it is configured like
this?

a) admin wants to guarantee no reclaim on pages in A1 ?
if so, my patch works as expected

b) mis-configuration ?
if so, my patch doesn't work as expected. but since it is
mis-configuration and there is really no expectation. what we need
instead is not breaking the system

Overall, I would like to make sure the most-popular use case to work
and at the same time not breaking the system by having
mis-configuration. Hopefully this makes sense to you :)

--Ying

>
> The solution to both cases is this: don't stick memory in these meta
> groups and complain that their hierarchical limits apply to their
> children.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
