Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 13AA26B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 18:48:34 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p5FMmVmb023695
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 15:48:31 -0700
Received: from qwc9 (qwc9.prod.google.com [10.241.193.137])
	by hpaq2.eem.corp.google.com with ESMTP id p5FMlrTd025119
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 15:48:30 -0700
Received: by qwc9 with SMTP id 9so741285qwc.27
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 15:48:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110609150026.GD3994@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
	<BANLkTim5TSWpBfeF2dugGZwQmNC-Cf+GCNctraq8FtziJxsd2g@mail.gmail.com>
	<BANLkTimuRks4+h=Kjt2Lzc-s-XsAHCH9vg@mail.gmail.com>
	<20110609150026.GD3994@tiehlicka.suse.cz>
Date: Wed, 15 Jun 2011 15:48:25 -0700
Message-ID: <BANLkTimbEnEHuxBDzKrEjPY7Y5F_aSoOdXkmjaOY+3xLBLzLdA@mail.gmail.com>
Subject: Re: [patch 4/8] memcg: rework soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Jun 9, 2011 at 8:00 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 02-06-11 22:25:29, Ying Han wrote:
>> On Thu, Jun 2, 2011 at 2:55 PM, Ying Han <yinghan@google.com> wrote:
>> > On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org>=
 wrote:
>> >> Currently, soft limit reclaim is entered from kswapd, where it select=
s
> [...]
>> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> index c7d4b44..0163840 100644
>> >> --- a/mm/vmscan.c
>> >> +++ b/mm/vmscan.c
>> >> @@ -1988,9 +1988,13 @@ static void shrink_zone(int priority, struct z=
one *zone,
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long reclaimed =3D sc->nr_rec=
laimed;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scanned =3D sc->nr_scann=
ed;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>> >> +
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(root=
, mem))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
>> >
>> > Here we grant the ability to shrink from all the memcgs, but only
>> > higher the priority for those exceed the soft_limit. That is a design
>> > change
>> > for the "soft_limit" which giving a hint to which memcgs to reclaim
>> > from first under global memory pressure.
>>
>>
>> Basically, we shouldn't reclaim from a memcg under its soft_limit
>> unless we have trouble reclaim pages from others.
>
> Agreed.
>
>> Something like the following makes better sense:
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index bdc2fd3..b82ba8c 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -1989,6 +1989,8 @@ restart:
>> =A0 =A0 =A0 =A0 throttle_vm_writeout(sc->gfp_mask);
>> =A0}
>>
>> +#define MEMCG_SOFTLIMIT_RECLAIM_PRIORITY =A0 =A0 =A0 2
>> +
>> =A0static void shrink_zone(int priority, struct zone *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct s=
can_control *sc)
>> =A0{
>> @@ -2001,13 +2003,13 @@ static void shrink_zone(int priority, struct zon=
e *zone,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long reclaimed =3D sc->nr_recla=
imed;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scanned =3D sc->nr_scanned=
;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(root, m=
em))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_soft_limit_exceeded(root, =
mem) &&
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priority >=
 MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>
> yes, this makes sense but I am not sure about the right(tm) value of the
> MEMCG_SOFTLIMIT_RECLAIM_PRIORITY. 2 sounds too low. You would do quite a
> lot of loops
> (DEFAULT_PRIORITY-MEMCG_SOFTLIMIT_RECLAIM_PRIORITY) * zones * memcg_count
> without any progress (assuming that all of them are under soft limit
> which doesn't sound like a totally artificial configuration) until you
> allow reclaiming from groups that are under soft limit. Then, when you
> finally get to reclaiming, you scan rather aggressively.

Fair enough, something smarter is definitely needed :)

>
> Maybe something like 3/4 of DEFAULT_PRIORITY? You would get 3 times
> over all (unbalanced) zones and all cgroups that are above the limit
> (scanning max{1/4096+1/2048+1/1024, 3*SWAP_CLUSTER_MAX} of the LRUs for
> each cgroup) which could be enough to collect the low hanging fruit.

Hmm, that sounds more reasonable than the initial proposal.

For the same worst case where all the memcgs are blow their soft
limit, we need to scan 3 times of total memcgs before actually doing
anything. For that condition, I can not think of anything solve the
problem totally unless we have separate list of memcg (like what do
currently) per-zone.

--Ying

> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
