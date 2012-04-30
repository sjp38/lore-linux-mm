Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 22B926B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 16:15:25 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2063214qcs.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2012 13:15:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335138820-26590-2-git-send-email-glommer@parallels.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
	<1335138820-26590-2-git-send-email-glommer@parallels.com>
Date: Mon, 30 Apr 2012 13:15:23 -0700
Message-ID: <CABCjUKDOjaZNM+7aNBpLS9YPumCa9r1XJ-kkbW_9qWBNxVE+=w@mail.gmail.com>
Subject: Re: [PATCH 13/23] slub: create duplicate cache
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, fweisbec@gmail.com, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Sun, Apr 22, 2012 at 4:53 PM, Glauber Costa <glommer@parallels.com> wrot=
e:
> This patch provides kmem_cache_dup(), that duplicates
> a cache for a memcg, preserving its creation properties.
> Object size, alignment and flags are all respected.
>
> When a duplicate cache is created, the parent cache cannot
> be destructed during the child lifetime. To assure this,
> its reference count is increased if the cache creation
> succeeds.
>
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Christoph Lameter <cl@linux.com>
> CC: Pekka Enberg <penberg@cs.helsinki.fi>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Suleiman Souhlal <suleiman@google.com>
> ---
> =A0include/linux/memcontrol.h | =A0 =A03 +++
> =A0include/linux/slab.h =A0 =A0 =A0 | =A0 =A03 +++
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 44 ++++++++++++++++++++++=
++++++++++++++++++++++
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 37 ++++++++++++++++=
+++++++++++++++++++++
> =A04 files changed, 87 insertions(+), 0 deletions(-)
>
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 99e14b9..493ecdd 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -445,6 +445,9 @@ int memcg_css_id(struct mem_cgroup *memcg);
> =A0void mem_cgroup_register_cache(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0struct kmem_cache *s);
> =A0void mem_cgroup_release_cache(struct kmem_cache *cachep);
> +extern char *mem_cgroup_cache_name(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0stru=
ct kmem_cache *cachep);
> +
> =A0#else
> =A0static inline void mem_cgroup_register_cache(struct mem_cgroup *memcg,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 struct kmem_cache *s)
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index c7a7e05..909b508 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -323,6 +323,9 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, un=
signed long);
>
> =A0#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> =A0#define MAX_KMEM_CACHE_TYPES 400
> +extern struct kmem_cache *kmem_cache_dup(struct mem_cgroup *memcg,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0struct kmem_cache *cachep);
> +void kmem_cache_drop_ref(struct kmem_cache *cachep);
> =A0#else
> =A0#define MAX_KMEM_CACHE_TYPES 0
> =A0#endif /* CONFIG_CGROUP_MEM_RES_CTLR_KMEM */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0015ed0..e881d83 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -467,6 +467,50 @@ struct cg_proto *tcp_proto_cgroup(struct mem_cgroup =
*memcg)
> =A0EXPORT_SYMBOL(tcp_proto_cgroup);
> =A0#endif /* CONFIG_INET */
>
> +/*
> + * This is to prevent races againt the kmalloc cache creations.
> + * Should never be used outside the core memcg code. Therefore,
> + * copy it here, instead of letting it in lib/
> + */
> +static char *kasprintf_no_account(gfp_t gfp, const char *fmt, ...)
> +{
> + =A0 =A0 =A0 unsigned int len;
> + =A0 =A0 =A0 char *p =3D NULL;
> + =A0 =A0 =A0 va_list ap, aq;
> +
> + =A0 =A0 =A0 va_start(ap, fmt);
> + =A0 =A0 =A0 va_copy(aq, ap);
> + =A0 =A0 =A0 len =3D vsnprintf(NULL, 0, fmt, aq);
> + =A0 =A0 =A0 va_end(aq);
> +
> + =A0 =A0 =A0 p =3D kmalloc_no_account(len+1, gfp);
> + =A0 =A0 =A0 if (!p)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 vsnprintf(p, len+1, fmt, ap);
> +
> +out:
> + =A0 =A0 =A0 va_end(ap);
> + =A0 =A0 =A0 return p;
> +}
> +
> +char *mem_cgroup_cache_name(struct mem_cgroup *memcg, struct kmem_cache =
*cachep)
> +{
> + =A0 =A0 =A0 char *name;
> + =A0 =A0 =A0 struct dentry *dentry =3D memcg->css.cgroup->dentry;

Do we need rcu_dereference() here (and make sure we have rcu_read_lock())?

This might need to be done in all the other places in the patchset
that get the memcg's dentry.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
