Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BDB736B02A4
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 00:37:49 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o764bo2v013204
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 21:37:51 -0700
Received: from qyk8 (qyk8.prod.google.com [10.241.83.136])
	by wpaz29.hot.corp.google.com with ESMTP id o764bUxk026434
	for <linux-mm@kvack.org>; Thu, 5 Aug 2010 21:37:49 -0700
Received: by qyk8 with SMTP id 8so5690585qyk.10
        for <linux-mm@kvack.org>; Thu, 05 Aug 2010 21:37:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100806131053.411dce6d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100805184434.3a29c0f9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100805185713.4d09339e.kamezawa.hiroyu@jp.fujitsu.com> <xr93zkx0z8e5.fsf@ninji.mtv.corp.google.com>
	<20100806131053.411dce6d.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 5 Aug 2010 21:37:29 -0700
Message-ID: <AANLkTikyGEE+z4yMZp8jEqEXd1V1aEeKBhyfU=baeq7=@mail.gmail.com>
Subject: Re: [PATCH 1/4 -mm][memcg] quick ID lookup in memcg
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 5, 2010 at 9:10 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 05 Aug 2010 21:12:50 -0700
> Greg Thelen <gthelen@google.com> wrote:
>
>> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> writes:
>>
>> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> >
>> > Now, memory cgroup has an ID per cgroup and make use of it at
>> > =A0- hierarchy walk,
>> > =A0- swap recording.
>> >
>> > This patch is for making more use of it. The final purpose is
>> > to replace page_cgroup->mem_cgroup's pointer to an unsigned short.
>> >
>> > This patch caches a pointer of memcg in an array. By this, we
>> > don't have to call css_lookup() which requires radix-hash walk.
>> > This saves some amount of memory footprint at lookup memcg via id.
>> >
>> > Changelog: 20100804
>> > =A0- fixed description in init/Kconfig
>> >
>> > Changelog: 20100730
>> > =A0- fixed rcu_read_unlock() placement.
>> >
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> > ---
>> > =A0init/Kconfig =A0 =A0| =A0 10 ++++++++++
>> > =A0mm/memcontrol.c | =A0 48 ++++++++++++++++++++++++++++++++++--------=
------
>> > =A02 files changed, 44 insertions(+), 14 deletions(-)
>> >
>> > Index: mmotm-0727/mm/memcontrol.c
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > --- mmotm-0727.orig/mm/memcontrol.c
>> > +++ mmotm-0727/mm/memcontrol.c
>> > @@ -292,6 +292,30 @@ static bool move_file(void)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 &mc.to->move_charge_at_immigrate);
>> > =A0}
>> >
>> > +/* 0 is unused */
>> > +static atomic_t mem_cgroup_num;
>> > +#define NR_MEMCG_GROUPS (CONFIG_MEM_CGROUP_MAX_GROUPS + 1)
>> > +static struct mem_cgroup *mem_cgroups[NR_MEMCG_GROUPS] __read_mostly;
>> > +
>> > +static struct mem_cgroup *id_to_memcg(unsigned short id)
>> > +{
>> > + =A0 /*
>> > + =A0 =A0* This array is set to NULL when mem_cgroup is freed.
>> > + =A0 =A0* IOW, there are no more references && rcu_synchronized().
>> > + =A0 =A0* This lookup-caching is safe.
>> > + =A0 =A0*/
>> > + =A0 if (unlikely(!mem_cgroups[id])) {
>> > + =A0 =A0 =A0 =A0 =A0 struct cgroup_subsys_state *css;
>> > +
>> > + =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> > + =A0 =A0 =A0 =A0 =A0 css =3D css_lookup(&mem_cgroup_subsys, id);
>> > + =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> > + =A0 =A0 =A0 =A0 =A0 if (!css)
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> > + =A0 =A0 =A0 =A0 =A0 mem_cgroups[id] =3D container_of(css, struct mem=
_cgroup, css);
>> > + =A0 }
>> > + =A0 return mem_cgroups[id];
>> > +}
>>
>> I am worried that id may be larger than CONFIG_MEM_CGROUP_MAX_GROUPS and
>> cause an illegal array index. =A0I see that
>> mem_cgroup_uncharge_swapcache() uses css_id() to compute 'id'.
>> mem_cgroup_num ensures that there are never more than
>> CONFIG_MEM_CGROUP_MAX_GROUPS memcg active. =A0But do we have guarantee
>> that the that all of the css_id of each active memcg are less than
>> NR_MEMCG_GROUPS?
>>
> Yes. kernel/cgroup.c's ID assign routine use the smallest number, always.
>
>
>
>> > =A0/*
>> > =A0 * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for sof=
t
>> > =A0 * limit reclaim to prevent infinite loops, if they ever occur.
>> > @@ -1824,18 +1848,7 @@ static void mem_cgroup_cancel_charge(str
>> > =A0 * it's concern. (dropping refcnt from swap can be called against r=
emoved
>> > =A0 * memcg.)
>> > =A0 */
>> > -static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>> > -{
>> > - =A0 struct cgroup_subsys_state *css;
>> >
>> > - =A0 /* ID 0 is unused ID */
>> > - =A0 if (!id)
>> > - =A0 =A0 =A0 =A0 =A0 return NULL;
>> > - =A0 css =3D css_lookup(&mem_cgroup_subsys, id);
>> > - =A0 if (!css)
>> > - =A0 =A0 =A0 =A0 =A0 return NULL;
>> > - =A0 return container_of(css, struct mem_cgroup, css);
>> > -}
>> >
>> > =A0struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>> > =A0{
>> > @@ -1856,7 +1869,7 @@ struct mem_cgroup *try_get_mem_cgroup_fr
>> > =A0 =A0 =A0 =A0 =A0 =A0 ent.val =3D page_private(page);
>> > =A0 =A0 =A0 =A0 =A0 =A0 id =3D lookup_swap_cgroup(ent);
>> > =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> > - =A0 =A0 =A0 =A0 =A0 mem =3D mem_cgroup_lookup(id);
>> > + =A0 =A0 =A0 =A0 =A0 mem =3D id_to_memcg(id);
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (mem && !css_tryget(&mem->css))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem =3D NULL;
>> > =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock();
>> > @@ -2208,7 +2221,7 @@ __mem_cgroup_commit_charge_swapin(struct
>> >
>> > =A0 =A0 =A0 =A0 =A0 =A0 id =3D swap_cgroup_record(ent, 0);
>> > =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock();
>> > - =A0 =A0 =A0 =A0 =A0 memcg =3D mem_cgroup_lookup(id);
>> > + =A0 =A0 =A0 =A0 =A0 memcg =3D id_to_memcg(id);
>> > =A0 =A0 =A0 =A0 =A0 =A0 if (memcg) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This recorded memcg can b=
e obsolete one. So, avoid
>> > @@ -2472,7 +2485,7 @@ void mem_cgroup_uncharge_swap(swp_entry_
>> >
>> > =A0 =A0 id =3D swap_cgroup_record(ent, 0);
>> > =A0 =A0 rcu_read_lock();
>> > - =A0 memcg =3D mem_cgroup_lookup(id);
>> > + =A0 memcg =3D id_to_memcg(id);
>> > =A0 =A0 if (memcg) {
>> > =A0 =A0 =A0 =A0 =A0 =A0 /*
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0* We uncharge this because swap is freed.
>> > @@ -3988,6 +4001,9 @@ static struct mem_cgroup *mem_cgroup_all
>> > =A0 =A0 struct mem_cgroup *mem;
>> > =A0 =A0 int size =3D sizeof(struct mem_cgroup);
>> >
>> > + =A0 if (atomic_read(&mem_cgroup_num) =3D=3D NR_MEMCG_GROUPS)
>> > + =A0 =A0 =A0 =A0 =A0 return NULL;
>> > +
>>
>> I think that multiple tasks to be simultaneously running
>> mem_cgroup_create(). =A0Therefore more than NR_MEMCG_GROUPS memcg may be
>> created.
>>
>
> No. cgroup_mutex() is held.
>
> Thanks,
> -Kame
>
>

I see that now.  Thank you clarification.  I am doing some testing on
the patches now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
