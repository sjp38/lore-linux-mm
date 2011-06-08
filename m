Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75A3C6B007B
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 23:53:25 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p583rMgQ001937
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 20:53:22 -0700
Received: from qyj19 (qyj19.prod.google.com [10.241.83.83])
	by wpaz29.hot.corp.google.com with ESMTP id p583rJGP016524
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2011 20:53:21 -0700
Received: by qyj19 with SMTP id 19so1993019qyj.16
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 20:53:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110602175142.GH28684@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
	<BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
	<20110602075028.GB20630@cmpxchg.org>
	<BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
	<20110602175142.GH28684@cmpxchg.org>
Date: Tue, 7 Jun 2011 20:53:21 -0700
Message-ID: <BANLkTi=9083abfiKdZ5_oXyA+dZqaXJfZg@mail.gmail.com>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 2, 2011 at 10:51 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
>
> On Thu, Jun 02, 2011 at 08:51:39AM -0700, Ying Han wrote:
> > On Thu, Jun 2, 2011 at 12:50 AM, Johannes Weiner <hannes@cmpxchg.org> w=
rote:
> > > On Wed, Jun 01, 2011 at 09:05:18PM -0700, Ying Han wrote:
> > >> On Wed, Jun 1, 2011 at 4:52 PM, Hiroyuki Kamezawa
> > >> <kamezawa.hiroyuki@gmail.com> wrote:
> > >> > 2011/6/1 Johannes Weiner <hannes@cmpxchg.org>:
> > >> >> Hi,
> > >> >>
> > >> >> this is the second version of the memcg naturalization series. =
=A0The
> > >> >> notable changes since the first submission are:
> > >> >>
> > >> >> =A0 =A0o the hierarchy walk is now intermittent and will abort an=
d
> > >> >> =A0 =A0 =A0remember the last scanned child after sc->nr_to_reclai=
m pages
> > >> >> =A0 =A0 =A0have been reclaimed during the walk in one zone (Rik)
> > >> >>
> > >> >> =A0 =A0o the global lru lists are never scanned when memcg is ena=
bled
> > >> >> =A0 =A0 =A0after #2 'memcg-aware global reclaim', which makes thi=
s patch
> > >> >> =A0 =A0 =A0self-sufficient and complete without requiring the per=
-memcg lru
> > >> >> =A0 =A0 =A0lists to be exclusive (Michal)
> > >> >>
> > >> >> =A0 =A0o renamed sc->memcg and sc->current_memcg to sc->target_me=
m_cgroup
> > >> >> =A0 =A0 =A0and sc->mem_cgroup and fixed their documentation, I ho=
pe this is
> > >> >> =A0 =A0 =A0better understandable now (Rik)
> > >> >>
> > >> >> =A0 =A0o the reclaim statistic counters have been renamed. =A0the=
re is no
> > >> >> =A0 =A0 =A0more distinction between 'pgfree' and 'pgsteal', it is=
 now
> > >> >> =A0 =A0 =A0'pgreclaim' in both cases; 'kswapd' has been replaced =
by
> > >> >> =A0 =A0 =A0'background'
> > >> >>
> > >> >> =A0 =A0o fixed a nasty crash in the hierarchical soft limit check=
 that
> > >> >> =A0 =A0 =A0happened during global reclaim in memcgs that are hier=
archical
> > >> >> =A0 =A0 =A0but have no hierarchical parents themselves
> > >> >>
> > >> >> =A0 =A0o properly implemented the memcg-aware unevictable page re=
scue
> > >> >> =A0 =A0 =A0scanner, there were several blatant bugs in there
> > >> >>
> > >> >> =A0 =A0o documentation on new public interfaces
> > >> >>
> > >> >> Thanks for your input on the first version.
> > >> >>
> > >> >> I ran microbenchmarks (sparse file catting, essentially) to stres=
s
> > >> >> reclaim and LRU operations. =A0There is no measurable overhead fo=
r
> > >> >> !CONFIG_MEMCG, memcg disabled during boot, memcg enabled but no
> > >> >> configured groups, and hard limit reclaim.
> > >> >>
> > >> >> I also ran single-threaded kernbenchs in four unlimited memcgs in
> > >> >> parallel, contained in a hard-limited hierarchical parent that pu=
t
> > >> >> constant pressure on the workload. =A0There is no measurable diff=
erence
> > >> >> in runtime, the pgpgin/pgpgout counters, and fairness among memcg=
s in
> > >> >> this test compared to an unpatched kernel. =A0Needs more evaluati=
on,
> > >> >> especially with a higher number of memcgs.
> > >> >>
> > >> >> The soft limit changes are also proven to work in so far that it =
is
> > >> >> possible to prioritize between children in a hierarchy under pres=
sure
> > >> >> and that runtime differences corresponded directly to the soft li=
mit
> > >> >> settings in the previously described kernbench setup with stagger=
ed
> > >> >> soft limits on the groups, but this needs quantification.
> > >> >>
> > >> >> Based on v2.6.39.
> > >> >>
> > >> >
> > >> > Hmm, I welcome and will review this patches but.....some points I =
want to say.
> > >> >
> > >> > 1. No more conflict with Ying's work ?
> > >> > =A0 =A0Could you explain what she has and what you don't in this v=
2 ?
> > >> > =A0 =A0If Ying's one has something good to be merged to your set, =
please
> > >> > include it.
> > >>
> > >> My patch I sent out last time was doing rework of soft_limit reclaim=
.
> > >> It convert the RB-tree based to
> > >> a linked list round-robin fashion of all memcgs across their soft
> > >> limit per-zone.
> > >>
> > >> I will apply this patch and try to test it. After that i will get
> > >> better idea whether or not it is being covered here.
> > >
> > > Thanks!!
> > >
> > >> > 4. This work can be splitted into some small works.
> > >> > =A0 =A0 a) fix for current code and clean ups
> > >>
> > >> > =A0 =A0 a') statistics
> > >>
> > >> > =A0 =A0 b) soft limit rework
> > >>
> > >> > =A0 =A0 c) change global reclaim
> > >>
> > >> My last patchset starts with a patch reverting the RB-tree
> > >> implementation of the soft_limit
> > >> reclaim, and then the new round-robin implementation comes on the
> > >> following patches.
> > >>
> > >> I like the ordering here, and that is consistent w/ the plan we
> > >> discussed earlier in LSF. Changing
> > >> the global reclaim would be the last step when the changes before th=
at
> > >> have been well understood
> > >> and tested.
> > >>
> > >> Sorry If that is how it is done here. I will read through the patchs=
et.
> > >
> > > It's not. =A0The way I implemented soft limits depends on global recl=
aim
> > > performing hierarchical reclaim. =A0I don't see how I can reverse the
> > > order with this dependency.
> >
> > That is something I don't quite get yet, and maybe need a closer look
> > into the patchset. The current design of
> > soft_limit doesn't do reclaim hierarchically but instead links the
> > memcgs together on per-zone basis.
> >
> > However on this patchset, we changed that design and doing
> > hierarchy_walk of the memcg tree. Can we clarify more on why we made
> > the design change? I can see the current design provides a efficient
> > way to pick the one memcg over-their-soft-limit under shrink_zone().
>
> The question is whether we even want it to work that way. =A0I outlined
> that in the changelog of the soft limit rework patch.
>
> As I see it, the soft limit should not exist solely to punish a memcg,
> but to prioritize memcgs in case hierarchical pressure exists. =A0I am
> arguing that the focus should be on relieving the pressure, rather
> than beating the living crap out of the single-biggest offender. =A0Keep
> in mind the scenarios where the biggest offender has a lot of dirty,
> hard-to-reclaim pages while there are other, unsoftlimited groups that
> have large amounts of easily reclaimable cache of questionable future
> value. =A0I believe only going for soft-limit excessors is too extreme,
> only for the single-biggest one outright nuts.
>
> The second point I made last time already is that there is no
> hierarchy support with that current scheme. =A0If you have a group with
> two subgroups, it makes sense to soft limit one subgroup against the
> other when the parent hits its limit. =A0This is not possible otherwise.
>
> The third point was that the amount of code to actually support the
> questionable behaviour of picking the biggest offender is gigantic
> compared to naturally hooking soft limit reclaim into regular reclaim.

Ok, thank you for detailed clarification. After reading through the
patchset more closely, I do agree that it makes
better integration of memcg reclaim to the other part of vm reclaim
code. So I don't have objection at this point to
proceed w/ this direction. However, three of my concerns still remains:

1.  Whether or not we introduced extra overhead for each shrink_zone()
under global memory pressure. We used to have quick
access of memcgs to reclaim from who has pages charged on the zone.
Now we need to do hierarchy_walk for all memcgs on the system. This
requires more testing and more data results would be helpful

2. The way we treat the per-memcg soft_limit is changed in this patch.
The same comment I made on the following patch where we shouldn't
change the definition of user API (soft_limit_in_bytes in this case).
So I attached the patch to fix that where we should only go to the
ones under their soft_limit above certain reclaim priority. Please
consider.

3. Please break this patchset into different patchsets. One way to
break it could be:

a) code which is less relevant to this effort and should be merged
first early regardless
b) code added in vm reclaim supporting the following changes
c) rework soft limit reclaim
d) make per-memcg lru lists exclusive

I should have the patch posted soon which breaks the zone->lru lock
for memcg reclaim. That patch should come after everything listed
above.

Thanks
--Ying
>
> The implementation is not proven to be satisfactory, I only sent it
> out so early and with this particular series because I wanted people
> to stop merging reclaim statistics that may not even be supportable in
> the long run.
>
> I agree with Andrew: we either need to prove it's the way to go, or
> prove that we never want to do it like this. =A0Before we start adding
> statistics that commit us to one way or the other.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
