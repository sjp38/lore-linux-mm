Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1B7E16B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 15:33:55 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2035324qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 12:33:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334959051-18203-10-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1334959051-18203-10-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 12:33:53 -0700
Message-ID: <CABCjUKBCqBWXuyzx73y3sekNqAKpYqAhRjQDtSWF5o7qUbC-RA@mail.gmail.com>
Subject: Re: [PATCH 09/23] kmem slab accounting basic infrastructure
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Greg Thelen <gthelen@google.com>

On Fri, Apr 20, 2012 at 2:57 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> This patch adds the basic infrastructure for the accounting of the slab
> caches. To control that, the following files are created:
>
> =A0* memory.kmem.usage_in_bytes
> =A0* memory.kmem.limit_in_bytes
> =A0* memory.kmem.failcnt
> =A0* memory.kmem.max_usage_in_bytes
>
> They have the same meaning of their user memory counterparts. They reflec=
t
> the state of the "kmem" res_counter.
>
> The code is not enabled until a limit is set. This can be tested by the f=
lag
> "kmem_accounted". This means that after the patch is applied, no behavior=
al
> changes exists for whoever is still using memcg to control their memory u=
sage.
>
> We always account to both user and kernel resource_counters. This effecti=
vely
> means that an independent kernel limit is in place when the limit is set
> to a lower value than the user memory. A equal or higher value means that=
 the
> user limit will always hit first, meaning that kmem is effectively unlimi=
ted.
>
> People who want to track kernel memory but not limit it, can set this lim=
it
> to a very high number (like RESOURCE_MAX - 1page - that no one will ever =
hit,
> or equal to the user memory)
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0mm/memcontrol.c | =A0 80 +++++++++++++++++++++++++++++++++++++++++++++=
+++++++++-
> =A01 files changed, 79 insertions(+), 1 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2810228..36f1e6b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -252,6 +252,10 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0};
>
> =A0 =A0 =A0 =A0/*
> + =A0 =A0 =A0 =A0* the counter to account for kernel memory usage.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct res_counter kmem;
> + =A0 =A0 =A0 /*
> =A0 =A0 =A0 =A0 * Per cgroup active and inactive list, similar to the
> =A0 =A0 =A0 =A0 * per zone LRU lists.
> =A0 =A0 =A0 =A0 */
> @@ -266,6 +270,7 @@ struct mem_cgroup {
> =A0 =A0 =A0 =A0 * Should the accounting and control be hierarchical, per =
subtree?
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0bool use_hierarchy;
> + =A0 =A0 =A0 bool kmem_accounted;
>
> =A0 =A0 =A0 =A0bool =A0 =A0 =A0 =A0 =A0 =A0oom_lock;
> =A0 =A0 =A0 =A0atomic_t =A0 =A0 =A0 =A0under_oom;
> @@ -378,6 +383,7 @@ enum res_type {
> =A0 =A0 =A0 =A0_MEM,
> =A0 =A0 =A0 =A0_MEMSWAP,
> =A0 =A0 =A0 =A0_OOM_TYPE,
> + =A0 =A0 =A0 _KMEM,
> =A0};
>
> =A0#define MEMFILE_PRIVATE(x, val) =A0 =A0 =A0 =A0(((x) << 16) | (val))
> @@ -1470,6 +1476,10 @@ done:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_read_u64(&memcg->memsw, RES_US=
AGE) >> 10,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_read_u64(&memcg->memsw, RES_LI=
MIT) >> 10,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0res_counter_read_u64(&memcg->memsw, RES_FA=
ILCNT));
> + =A0 =A0 =A0 printk(KERN_INFO "kmem: usage %llukB, limit %llukB, failcnt=
 %llu\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&memcg->kmem, RES_USAG=
E) >> 10,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&memcg->kmem, RES_LIMI=
T) >> 10,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_counter_read_u64(&memcg->kmem, RES_FAIL=
CNT));
> =A0}
>
> =A0/*
> @@ -3914,6 +3924,11 @@ static ssize_t mem_cgroup_read(struct cgroup *cont=
, struct cftype *cft,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0val =3D res_counter_read_u=
64(&memcg->memsw, name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 case _KMEM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 val =3D res_counter_read_u64(&memcg->kmem, =
name);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> +#endif
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
> =A0 =A0 =A0 =A0}
> @@ -3951,8 +3966,26 @@ static int mem_cgroup_write(struct cgroup *cont, s=
truct cftype *cft,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (type =3D=3D _MEM)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_resize_=
limit(memcg, val);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (type =3D=3D _MEMSWAP)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D mem_cgroup_resize_=
memsw_limit(memcg, val);
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (type =3D=3D _KMEM) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D res_counter_set_lim=
it(&memcg->kmem, val);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Once enabled, can't be=
 disabled. We could in theory
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* disable it if we haven=
't yet created any caches, or
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if we can shrink them =
all to death.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* But it is not worth th=
e trouble
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!memcg->kmem_accounted =
&& val !=3D RESOURCE_MAX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memcg->kmem=
_accounted =3D true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0case RES_SOFT_LIMIT:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D res_counter_memparse_write_strateg=
y(buffer, &val);

Why is RESOURCE_MAX special?

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
