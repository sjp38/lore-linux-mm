Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 668A66B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 20:33:41 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p5G0XYvv019219
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 17:33:35 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by kpbe13.cbf.corp.google.com with ESMTP id p5G0XWjf017204
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 17:33:33 -0700
Received: by qyg14 with SMTP id 14so583255qyg.12
        for <linux-mm@kvack.org>; Wed, 15 Jun 2011 17:33:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikUmzF6kgJ6WUQGK0M=uzPH6Ac09koCnQwi8vMbxu40WQ@mail.gmail.com>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
	<1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
	<BANLkTim5TSWpBfeF2dugGZwQmNC-Cf+GCNctraq8FtziJxsd2g@mail.gmail.com>
	<BANLkTimuRks4+h=Kjt2Lzc-s-XsAHCH9vg@mail.gmail.com>
	<20110609150026.GD3994@tiehlicka.suse.cz>
	<20110610073638.GA15403@tiehlicka.suse.cz>
	<BANLkTikUmzF6kgJ6WUQGK0M=uzPH6Ac09koCnQwi8vMbxu40WQ@mail.gmail.com>
Date: Wed, 15 Jun 2011 17:33:32 -0700
Message-ID: <BANLkTimHEGj1p0kXGA+cNgNHYpoFViyLd4XMSPg+dYZtct_fsQ@mail.gmail.com>
Subject: Re: [patch 4/8] memcg: rework soft limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2011 at 3:57 PM, Ying Han <yinghan@google.com> wrote:
> On Fri, Jun 10, 2011 at 12:36 AM, Michal Hocko <mhocko@suse.cz> wrote:
>> On Thu 09-06-11 17:00:26, Michal Hocko wrote:
>>> On Thu 02-06-11 22:25:29, Ying Han wrote:
>>> > On Thu, Jun 2, 2011 at 2:55 PM, Ying Han <yinghan@google.com> wrote:
>>> > > On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.o=
rg> wrote:
>>> > >> Currently, soft limit reclaim is entered from kswapd, where it sel=
ects
>>> [...]
>>> > >> diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> > >> index c7d4b44..0163840 100644
>>> > >> --- a/mm/vmscan.c
>>> > >> +++ b/mm/vmscan.c
>>> > >> @@ -1988,9 +1988,13 @@ static void shrink_zone(int priority, struc=
t zone *zone,
>>> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long reclaimed =3D sc->nr_=
reclaimed;
>>> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long scanned =3D sc->nr_sc=
anned;
>>> > >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long nr_reclaimed;
>>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>>> > >> +
>>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(r=
oot, mem))
>>> > >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
>>> > >
>>> > > Here we grant the ability to shrink from all the memcgs, but only
>>> > > higher the priority for those exceed the soft_limit. That is a desi=
gn
>>> > > change
>>> > > for the "soft_limit" which giving a hint to which memcgs to reclaim
>>> > > from first under global memory pressure.
>>> >
>>> >
>>> > Basically, we shouldn't reclaim from a memcg under its soft_limit
>>> > unless we have trouble reclaim pages from others.
>>>
>>> Agreed.
>>>
>>> > Something like the following makes better sense:
>>> >
>>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>>> > index bdc2fd3..b82ba8c 100644
>>> > --- a/mm/vmscan.c
>>> > +++ b/mm/vmscan.c
>>> > @@ -1989,6 +1989,8 @@ restart:
>>> > =A0 =A0 =A0 =A0 throttle_vm_writeout(sc->gfp_mask);
>>> > =A0}
>>> >
>>> > +#define MEMCG_SOFTLIMIT_RECLAIM_PRIORITY =A0 =A0 =A0 2
>>> > +
>>> > =A0static void shrink_zone(int priority, struct zone *zone,
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struc=
t scan_control *sc)
>>> > =A0{
>>> > @@ -2001,13 +2003,13 @@ static void shrink_zone(int priority, struct =
zone *zone,
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long reclaimed =3D sc->nr_re=
claimed;
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long scanned =3D sc->nr_scan=
ned;
>>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned long nr_reclaimed;
>>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int epriority =3D priority;
>>> >
>>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_soft_limit_exceeded(root=
, mem))
>>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 epriority -=3D 1;
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!mem_cgroup_soft_limit_exceeded(roo=
t, mem) &&
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priorit=
y > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
>>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>>>
>>> yes, this makes sense but I am not sure about the right(tm) value of th=
e
>>> MEMCG_SOFTLIMIT_RECLAIM_PRIORITY. 2 sounds too low.
>>
>> There is also another problem. I have just realized that this code path
>> is shared with the cgroup direct reclaim. We shouldn't care about soft
>> limit in such a situation. It would be just a wasting of cycles. So we
>> have to:
>>
>> if (current_is_kswapd() &&
>> =A0 =A0 =A0 =A0!mem_cgroup_soft_limit_exceeded(root, mem) &&
>> =A0 =A0 =A0 =A0priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
>> =A0 =A0 =A0 =A0continue;
>
> Agreed.
>
>>
>> Maybe the condition would have to be more complex for per-cgroup
>> background reclaim, though.
>
> That would be the same logic for per-memcg direct reclaim. In general,
> we don't consider soft_limit
> unless the global memory pressure. So the condition could be something li=
ke:
>
>> if ( =A0 global_reclaim(sc) &&
>> =A0 =A0 =A0 =A0!mem_cgroup_soft_limit_exceeded(root, mem) &&
>> =A0 =A0 =A0 =A0priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
>> =A0 =A0 =A0 =A0continue;
>
> make sense?

Also

+bool mem_cgroup_soft_limit_exceeded(struct mem_cgroup *mem)
+{
+       return res_counter_soft_limit_excess(&mem->res);
+}

--Ying
>
> Thanks
>
> --Ying
>>
>>> You would do quite a
>>> lot of loops
>>> (DEFAULT_PRIORITY-MEMCG_SOFTLIMIT_RECLAIM_PRIORITY) * zones * memcg_cou=
nt
>>> without any progress (assuming that all of them are under soft limit
>>> which doesn't sound like a totally artificial configuration) until you
>>> allow reclaiming from groups that are under soft limit. Then, when you
>>> finally get to reclaiming, you scan rather aggressively.
>>>
>>> Maybe something like 3/4 of DEFAULT_PRIORITY? You would get 3 times
>>> over all (unbalanced) zones and all cgroups that are above the limit
>>> (scanning max{1/4096+1/2048+1/1024, 3*SWAP_CLUSTER_MAX} of the LRUs for
>>> each cgroup) which could be enough to collect the low hanging fruit.
>>
>> --
>> Michal Hocko
>> SUSE Labs
>> SUSE LINUX s.r.o.
>> Lihovarska 1060/12
>> 190 00 Praha 9
>> Czech Republic
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
