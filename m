Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 02AEF6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 22:49:49 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p3S2nmew016468
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:49:48 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by kpbe14.cbf.corp.google.com with ESMTP id p3S2niQk015806
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:49:47 -0700
Received: by qwi2 with SMTP id 2so1690832qwi.8
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:49:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110428085751.fd478fe8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinx+4zXaO3rhHRUzr3m-K-2_NMTQw@mail.gmail.com>
	<20110428085751.fd478fe8.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 19:49:44 -0700
Message-ID: <BANLkTi=eJYQoahG_+rHDqWBUxh9ipWgX-Q@mail.gmail.com>
Subject: Re: [PATCHv2] memcg: reclaim memory from node in round-robin
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, Apr 27, 2011 at 4:57 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 10:33:43 -0700
> Ying Han <yinghan@google.com> wrote:
>
>> On Wed, Apr 27, 2011 at 12:51 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > I changed the logic a little and add a filter for skipping nodes.
>> > With large NUMA, tasks may under cpuset or mempolicy and the usage of =
memory
>> > can be unbalanced. So, I think a filter is required.
>>
>> Thank you.
>>
>> >
>> > =3D=3D
>> > Now, memory cgroup's direct reclaim frees memory from the current node=
.
>> > But this has some troubles. In usual, when a set of threads works in
>> > cooperative way, they are tend to on the same node. So, if they hit
>> > limits under memcg, it will reclaim memory from themselves, it may be
>> > active working set.
>> >
>> > For example, assume 2 node system which has Node 0 and Node 1
>> > and a memcg which has 1G limit. After some work, file cacne remains an=
d
>> > and usages are
>> > =A0 Node 0: =A01M
>> > =A0 Node 1: =A0998M.
>> >
>> > and run an application on Node 0, it will eats its foot before freeing
>> > unnecessary file caches.
>> >
>> > This patch adds round-robin for NUMA and adds equal pressure to each
>> > node. When using cpuset's spread memory feature, this will work very w=
ell.
>> >
>> >
>> > From: Ying Han <yinghan@google.com>
>> > Signed-off-by: Ying Han <yinghan@google.com>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > Changelog v1->v2:
>> > =A0- fixed comments.
>> > =A0- added a logic to avoid scanning unused node.
>> >
>> > ---
>> > =A0include/linux/memcontrol.h | =A0 =A01
>> > =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 98 +++++++++++++++++++=
+++++++++++++++++++++++---
>> > =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A09 +++-
>> > =A03 files changed, 101 insertions(+), 7 deletions(-)
>> >
>> > Index: memcg/include/linux/memcontrol.h
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- memcg.orig/include/linux/memcontrol.h
>> > +++ memcg/include/linux/memcontrol.h
>> > @@ -108,6 +108,7 @@ extern void mem_cgroup_end_migration(str
>> > =A0*/
>> > =A0int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
>> > =A0int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
>> > +int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
>> > =A0unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct zone *zone,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 enum lru_list lru);
>> > Index: memcg/mm/memcontrol.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- memcg.orig/mm/memcontrol.c
>> > +++ memcg/mm/memcontrol.c
>> > @@ -237,6 +237,11 @@ struct mem_cgroup {
>> > =A0 =A0 =A0 =A0 * reclaimed from.
>> > =A0 =A0 =A0 =A0 */
>> > =A0 =A0 =A0 =A0int last_scanned_child;
>> > + =A0 =A0 =A0 int last_scanned_node;
>> > +#if MAX_NUMNODES > 1
>> > + =A0 =A0 =A0 nodemask_t =A0 =A0 =A0scan_nodes;
>> > + =A0 =A0 =A0 unsigned long =A0 next_scan_node_update;
>> > +#endif
>> > =A0 =A0 =A0 =A0/*
>> > =A0 =A0 =A0 =A0 * Should the accounting and control be hierarchical, p=
er subtree?
>> > =A0 =A0 =A0 =A0 */
>> > @@ -650,18 +655,27 @@ static void mem_cgroup_soft_scan(struct
>> > =A0 =A0 =A0 =A0this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_S=
CAN], val);
>> > =A0}
>> >
>> > +static unsigned long
>> > +mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lr=
u_list idx)
>> > +{
>> > + =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
>> > + =A0 =A0 =A0 u64 total;
>> > + =A0 =A0 =A0 int zid;
>> > +
>> > + =A0 =A0 =A0 for (zid =3D 0; zid < MAX_NR_ZONES; zid++) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zoneinfo(mem, nid, zid=
);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D MEM_CGROUP_ZSTAT(mz, idx);
>> > + =A0 =A0 =A0 }
>> > + =A0 =A0 =A0 return total;
>> > +}
>> > =A0static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgrou=
p *mem,
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0enum lru_list idx)
>> > =A0{
>> > - =A0 =A0 =A0 int nid, zid;
>> > - =A0 =A0 =A0 struct mem_cgroup_per_zone *mz;
>> > + =A0 =A0 =A0 int nid;
>> > =A0 =A0 =A0 =A0u64 total =3D 0;
>> >
>> > =A0 =A0 =A0 =A0for_each_online_node(nid)
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (zid =3D 0; zid < MAX_NR_ZONES; zid+=
+) {
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mz =3D mem_cgroup_zonein=
fo(mem, nid, zid);
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D MEM_CGROUP_ZS=
TAT(mz, idx);
>> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 total +=3D mem_cgroup_get_zonestat_node(=
mem, nid, idx);
>> > =A0 =A0 =A0 =A0return total;
>> > =A0}
>> >
>> > @@ -1471,6 +1485,77 @@ mem_cgroup_select_victim(struct mem_cgro
>> > =A0 =A0 =A0 =A0return ret;
>> > =A0}
>> >
>> > +#if MAX_NUMNODES > 1
>> > +
>> > +/*
>> > + * Update nodemask always is not very good. Even if we have empty
>> > + * list, or wrong list here, we can start from some node and traverse=
 all nodes
>> > + * based on zonelist. So, update the list loosely once in 10 secs.
>> > + *
>> > + */
>> > +static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
>> > +{
>> > + =A0 =A0 =A0 int nid;
>> > +
>> > + =A0 =A0 =A0 if (time_after(mem->next_scan_node_update, jiffies))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> > +
>> > + =A0 =A0 =A0 mem->next_scan_node_update =3D jiffies + 10*HZ;
>> > + =A0 =A0 =A0 /* make a nodemask where this memcg uses memory from */
>> > + =A0 =A0 =A0 mem->scan_nodes =3D node_states[N_HIGH_MEMORY];
>> > +
>> > + =A0 =A0 =A0 for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mem_cgroup_get_zonestat_node(mem, ni=
d, LRU_INACTIVE_FILE) ||
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_get_zonestat_node(mem=
, nid, LRU_ACTIVE_FILE))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_swap_pages &&
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (mem_cgroup_get_zonestat_node(me=
m, nid, LRU_INACTIVE_ANON) ||
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_get_zonestat_node(=
mem, nid, LRU_ACTIVE_ANON)))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node_clear(nid, mem->scan_nodes);
>> > + =A0 =A0 =A0 }
>> > +
>> > +}
>> > +
>> > +/*
>> > + * Selecting a node where we start reclaim from. Because what we need=
 is just
>> > + * reducing usage counter, start from anywhere is O,K. Considering
>> > + * memory reclaim from current node, there are pros. and cons.
>> > + *
>> > + * Freeing memory from current node means freeing memory from a node =
which
>> > + * we'll use or we've used. So, it may make LRU bad. And if several t=
hreads
>> > + * hit limits, it will see a contention on a node. But freeing from r=
emote
>> > + * node means more costs for memory reclaim because of memory latency=
.
>> > + *
>> > + * Now, we use round-robin. Better algorithm is welcomed.
>> > + */
>> > +int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
>> > +{
>> > + =A0 =A0 =A0 int node;
>> > +
>> > + =A0 =A0 =A0 mem_cgroup_may_update_nodemask(mem);
>> > + =A0 =A0 =A0 node =3D mem->last_scanned_node;
>> > +
>> > + =A0 =A0 =A0 node =3D next_node(node, mem->scan_nodes);
>> > + =A0 =A0 =A0 if (node =3D=3D MAX_NUMNODES) {
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D first_node(mem->scan_nodes);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(node =3D=3D MAX_NUMNODES))
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 node =3D numa_node_id();
>> not sure about this logic, is that possible we reclaim from a node
>> with all "unreclaimable" pages (based on the
>> mem_cgroup_may_update_nodemask check).
>> If i missed anything here, it would be helpful to add comment.
>>
>
> What I'm afraid here is when a user uses very small memcg,
> all pages on the LRU may be isolated or all usages are in per-cpu cache
> of memcg or because of task-migration between memcg, it hits limit before
> having any pages on LRU.....I think there is possible corner cases which
> can cause hang.
>
> ok, will add comment.

Ok, thanks. Otherwise it looks good.

Acked-by: Ying Han <yinghan@google.com>

--Ying

--Ying
>
> Thanks,
> -Kame
>
>
>
>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
