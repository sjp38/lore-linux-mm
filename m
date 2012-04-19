Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id E2A5E6B0092
	for <linux-mm@kvack.org>; Thu, 19 Apr 2012 13:47:29 -0400 (EDT)
Received: by lagz14 with SMTP id z14so8883226lag.14
        for <linux-mm@kvack.org>; Thu, 19 Apr 2012 10:47:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120419170434.GE15634@tiehlicka.suse.cz>
References: <1334680666-12361-1-git-send-email-yinghan@google.com>
	<20120418122448.GB1771@cmpxchg.org>
	<CALWz4iz_17fQa=EfT2KqvJUGyHQFc5v9r+7b947yMbocC9rrjA@mail.gmail.com>
	<20120419170434.GE15634@tiehlicka.suse.cz>
Date: Thu, 19 Apr 2012 10:47:27 -0700
Message-ID: <CALWz4iw156qErZn0gGUUatUTisy_6uF_5mrY0kXt1W89hvVjRw@mail.gmail.com>
Subject: Re: [PATCH V3 0/2] memcg softlimit reclaim rework
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Apr 19, 2012 at 10:04 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 18-04-12 11:00:40, Ying Han wrote:
>> On Wed, Apr 18, 2012 at 5:24 AM, Johannes Weiner <hannes@cmpxchg.org> wr=
ote:
>> > On Tue, Apr 17, 2012 at 09:37:46AM -0700, Ying Han wrote:
>> >> The "soft_limit" was introduced in memcg to support over-committing t=
he
>> >> memory resource on the host. Each cgroup configures its "hard_limit" =
where
>> >> it will be throttled or OOM killed by going over the limit. However, =
the
>> >> cgroup can go above the "soft_limit" as long as there is no system-wi=
de
>> >> memory contention. So, the "soft_limit" is the kernel mechanism for
>> >> re-distributing system spare memory among cgroups.
>> >>
>> >> This patch reworks the softlimit reclaim by hooking it into the new g=
lobal
>> >> reclaim scheme. So the global reclaim path including direct reclaim a=
nd
>> >> background reclaim will respect the memcg softlimit.
>> >>
>> >> v3..v2:
>> >> 1. rebase the patch on 3.4-rc3
>> >> 2. squash the commits of replacing the old implementation with new
>> >> implementation into one commit. This is to make sure to leave the tre=
e
>> >> in stable state between each commit.
>> >> 3. removed the commit which changes the nr_to_reclaim for global recl=
aim
>> >> case. The need of that patch is not obvious now.
>> >>
>> >> Note:
>> >> 1. the new implementation of softlimit reclaim is rather simple and f=
irst
>> >> step for further optimizations. there is no memory pressure balancing=
 between
>> >> memcgs for each zone, and that is something we would like to add as f=
ollow-ups.
>> >>
>> >> 2. this patch is slightly different from the last one posted from Joh=
annes
>> >> http://comments.gmane.org/gmane.linux.kernel.mm/72382
>> >> where his patch is closer to the reverted implementation by doing hie=
rarchical
>> >> reclaim for each selected memcg. However, that is not expected behavi=
or from
>> >> user perspective. Considering the following example:
>> >>
>> >> root (32G capacity)
>> >> --> A (hard limit 20G, soft limit 15G, usage 16G)
>> >> =A0 =A0--> A1 (soft limit 5G, usage 4G)
>> >> =A0 =A0--> A2 (soft limit 10G, usage 12G)
>> >> --> B (hard limit 20G, soft limit 10G, usage 16G)
>> >>
>> >> Under global reclaim, we shouldn't add pressure on A1 although its pa=
rent(A)
>> >> exceeds softlimit. This is what admin expects by setting softlimit to=
 the
>> >> actual working set size and only reclaim pages under softlimit if sys=
tem has
>> >> trouble to reclaim.
>> >
>> > Actually, this is exactly what the admin expects when creating a
>> > hierarchy, because she defines that A1 is a child of A and is
>> > responsible for the memory situation in its parent.
>
> Hmm, I guess that both approaches have cons and pros.
> * Hierarchical soft limit reclaim - reclaim the whole subtree of the over
> =A0soft limit memcg
> =A0+ it is consistent with the hard limit reclaim
Not sure why we want them to be consistent. Soft_limit is serving
different purpose and the one of the main purpose is to preserve the
working set of the cgroup.

> =A0+ easier for top to bottom configuration - especially when you allow
> =A0 =A0subgroups to create deeper hierarchies. Does anybody do that?

As far as I heard, most (if not all) are using flat configuration
where everything is running under root.

> =A0- harder to set up if soft limit should act as a guarantee - might lea=
d
> =A0 =A0to an unexpected reclaim.
>
> * Targeted soft limit reclaim - only reclaim LRUs of over limit memcgs
> =A0+ easier to set up for the working set guarantee because admin can foc=
us
> =A0 =A0on the working set of a single group and not the whole hierarchy
This is true.

> =A0- easier to construct soft unreclaimable hierarchies - whole subtree
> =A0 =A0contributes but nobody wants to take the responsibility when we re=
ach
> =A0 =A0the limit.
>
> Both approaches don't play very well with the default 0 limit because we
> either reclaim unless we set up the whole hierarchy properly or we just
> burn cycles by trying to reclaim groups wit no or only few pages.

Setting the default to 0 is a good optimization which makes everybody
to be eligible for reclaim if admin doesn't do anything.

In reality, if admin want to preserve working set of cgroups and
he/she has to set the softlimit. By doing that, it is easier to only
focus on the cgroup itself without looking up its ancestors.

> The second approach leads to more expected results though because we do
> not touch "leaf" groups unless they are over limit.
> I have to think about that some more but it seems that the second approac=
h
> is much easier to implement and matches the "guarantee" expectations
> more.

Agree.

> I guess we could converge both approaches if we could reclaim from the
> leaf groups upwards to the root but I didn't think about this very much.

That is what the current patch does, which only consider softlimit
under global pressure :)

--Ying
>
> [...]
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
