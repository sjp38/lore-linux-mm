Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 9B1096B0044
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:58:09 -0400 (EDT)
Received: by vcbfy7 with SMTP id fy7so1283875vcb.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 16:58:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F9AD455.9030306@parallels.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
	<4F9A34B2.8080103@jp.fujitsu.com>
	<4F9AD455.9030306@parallels.com>
Date: Sat, 28 Apr 2012 08:58:08 +0900
Message-ID: <CABEgKgpfhM-AFBZLjUGNE_oA0VykTOEhrnR-k+fpuR2CeBgiXw@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in move_parent
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Apr 28, 2012 at 2:16 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> On 04/27/2012 02:54 AM, KAMEZAWA Hiroyuki wrote:
>> By using res_counter_uncharge_until(), we can avoid
>> unnecessary charging.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0 mm/memcontrol.c | =A0 63 ++++++++++++++++++++++++++++++++++++-------=
-----------
>> =A0 1 files changed, 42 insertions(+), 21 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 613bb15..ed53d64 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2420,6 +2420,24 @@ static void __mem_cgroup_cancel_charge(struct mem=
_cgroup *memcg,
>> =A0 }
>>
>> =A0 /*
>> + * Cancel chages in this cgroup....doesn't propagates to parent cgroup.
>> + * This is useful when moving usage to parent cgroup.
>> + */
>> +static void __mem_cgroup_cancel_local_charge(struct mem_cgroup *memcg,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 unsigned int nr_pages)
>> +{
>> + =A0 =A0 if (!mem_cgroup_is_root(memcg)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 unsigned long bytes =3D nr_pages * PAGE_SIZE;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 res_counter_uncharge_until(&memcg->res,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 memcg->res.parent, bytes);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (do_swap_account)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_uncharge_until(&me=
mcg->memsw,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 memcg->memsw.parent, bytes);
>> + =A0 =A0 }
>> +}
>
> Kame, this is a nitpick, but I usually prefer to write this like:
>
> if (mem_cgroup_is_root(memcg))
> =A0 return;
>
> res_counter...
>
> Specially with memcg, where function names are bigger than average, in
> comparison.
>
> the code itself seems fine.
>
Ok, I'll use that style in the next post.

>> +/*
>> =A0 =A0* A helper function to get mem_cgroup from ID. must be called und=
er
>> =A0 =A0* rcu_read_lock(). The caller must check css_is_removed() or some=
 if
>> =A0 =A0* it's concern. (dropping refcnt from swap can be called against =
removed
>> @@ -2677,16 +2695,28 @@ static int mem_cgroup_move_parent(struct page *p=
age,
>> =A0 =A0 =A0 nr_pages =3D hpage_nr_pages(page);
>>
>> =A0 =A0 =A0 parent =3D mem_cgroup_from_cont(pcg);
>> - =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL, gfp_mask, nr_pages,&pare=
nt, false);
>> - =A0 =A0 if (ret)
>> - =A0 =A0 =A0 =A0 =A0 =A0 goto put_back;
>> + =A0 =A0 if (!parent->use_hierarchy) {
> Can we avoid testing for use hierarchy ?
> Specially given this might go away.
>
> parent_mem_cgroup() already bundles this information. So maybe we can
> test for parent_mem_cgroup(parent) =3D=3D NULL. It is the same thing afte=
r all.

We need to find parent even if use_hierarchy=3D=3D0 in this patch.
I'll consider to use it in later patch, thank you for pointing out.


>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D __mem_cgroup_try_charge(NULL,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 gfp_mask, nr_pages,&parent, false);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put_back;
>> + =A0 =A0 }
>
> Why? If we are not hierarchical, we should not charge the parent, right?
Current implementation moves charges to parent regardless of use_hierarchy.
It's handled in  a following patch.

>
>> =A0 =A0 =A0 if (nr_pages> =A01)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags =3D compound_lock_irqsave(page);
>>
>> - =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pages, pc, child, par=
ent, true);
>> - =A0 =A0 if (ret)
>> - =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_charge(parent, nr_pages);
>> + =A0 =A0 if (parent->use_hierarchy) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pages=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pc, child, parent, false);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_local_char=
ge(child, nr_pages);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D mem_cgroup_move_account(page, nr_pages=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 pc, child, parent, true);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_cancel_charge(par=
ent, nr_pages);
>> + =A0 =A0 }
>
> Calling move account also seems not necessary to me. If we are not
> uncharging + charging, we won't even touch the parent.

we need to overwrite pc->mem_cgroup and touch other statistics.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
