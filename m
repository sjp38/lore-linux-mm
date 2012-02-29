Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B186B6B004A
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 14:00:24 -0500 (EST)
Received: by qcsd16 with SMTP id d16so3450166qcs.14
        for <linux-mm@kvack.org>; Wed, 29 Feb 2012 11:00:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120229152227.aa416668.kamezawa.hiroyu@jp.fujitsu.com>
References: <1330383533-20711-1-git-send-email-ssouhlal@FreeBSD.org>
	<1330383533-20711-3-git-send-email-ssouhlal@FreeBSD.org>
	<20120229152227.aa416668.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 29 Feb 2012 11:00:23 -0800
Message-ID: <CABCjUKAt0gvnSU9-jbK9QjOWBECgohZ699Tptd6W2ucb8-B8=w@mail.gmail.com>
Subject: Re: [PATCH 02/10] memcg: Uncharge all kmem when deleting a cgroup.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, cgroups@vger.kernel.org, glommer@parallels.com, penberg@kernel.org, yinghan@google.com, hughd@google.com, gthelen@google.com, linux-mm@kvack.org, devel@openvz.org

On Tue, Feb 28, 2012 at 10:22 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 27 Feb 2012 14:58:45 -0800
> Suleiman Souhlal <ssouhlal@FreeBSD.org> wrote:
>
>> A later patch will also use this to move the accounting to the root
>> cgroup.
>>
>> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
>> ---
>> =A0mm/memcontrol.c | =A0 30 +++++++++++++++++++++++++++++-
>> =A01 files changed, 29 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 11e31d6..6f44fcb 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -378,6 +378,7 @@ static void mem_cgroup_get(struct mem_cgroup *memcg)=
;
>> =A0static void mem_cgroup_put(struct mem_cgroup *memcg);
>> =A0static void memcg_kmem_init(struct mem_cgroup *memcg,
>> =A0 =A0 =A0struct mem_cgroup *parent);
>> +static void memcg_kmem_move(struct mem_cgroup *memcg);
>>
>> =A0/* Writing them here to avoid exposing memcg's inner layout */
>> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> @@ -3674,6 +3675,7 @@ static int mem_cgroup_force_empty(struct mem_cgrou=
p *memcg, bool free_all)
>> =A0 =A0 =A0 int ret;
>> =A0 =A0 =A0 int node, zid, shrink;
>> =A0 =A0 =A0 int nr_retries =3D MEM_CGROUP_RECLAIM_RETRIES;
>> + =A0 =A0 unsigned long usage;
>> =A0 =A0 =A0 struct cgroup *cgrp =3D memcg->css.cgroup;
>>
>> =A0 =A0 =A0 css_get(&memcg->css);
>> @@ -3693,6 +3695,8 @@ move_account:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This is for making all *used* pages to be=
 on LRU. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru_add_drain_all();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_sync(memcg);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (!free_all)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg_kmem_move(memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_start_move(memcg);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_node_state(node, N_HIGH_MEMORY) {
>> @@ -3714,8 +3718,13 @@ move_account:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret =3D=3D -ENOMEM)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto try_to_free;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cond_resched();
>> + =A0 =A0 =A0 =A0 =A0 =A0 usage =3D memcg->res.usage;
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (free_all && !memcg->independent_kmem_limit=
)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 usage -=3D memcg->kmem_bytes.u=
sage;
>> +#endif
>
> Why we need this even if memcg_kmem_move() does uncharge ?

We need it when manually calling force_empty.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
