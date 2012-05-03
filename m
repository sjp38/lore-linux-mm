Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id D83446B004D
	for <linux-mm@kvack.org>; Thu,  3 May 2012 03:18:29 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so1448207vbb.14
        for <linux-mm@kvack.org>; Thu, 03 May 2012 00:18:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334499755-4399-1-git-send-email-andi@firstfloor.org>
References: <1334499755-4399-1-git-send-email-andi@firstfloor.org>
Date: Thu, 3 May 2012 10:18:28 +0300
Message-ID: <CAOJsxLE36GNJBmdrJqFfoyEve8swVsaBSq_oVgkgXSMEC3oBfA@mail.gmail.com>
Subject: Re: [PATCH] slab/mempolicy: always use local policy from interrupt
 context v2
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

(Adding some CC's.)

On Sun, Apr 15, 2012 at 5:22 PM, Andi Kleen <andi@firstfloor.org> wrote:
> From: Andi Kleen <ak@linux.intel.com>
>
> slab_node() could access current->mempolicy from interrupt context.
> However there's a race condition during exit where the mempolicy
> is first freed and then the pointer zeroed.
>
> Using this from interrupts seems bogus anyways. The interrupt
> will interrupt a random process and therefore get a random
> mempolicy. Many times, this will be idle's, which noone can change.
>
> Just disable this here and always use local for slab
> from interrupts. I also cleaned up the callers of slab_node a bit
> which always passed the same argument.
>
> I believe the original mempolicy code did that in fact,
> so it's likely a regression.
>
> v2: send version with correct logic
> Reported-by: Arun Sharma <asharma@fb.com>
> Cc: penberg@kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
> =A0include/linux/mempolicy.h | =A0 =A02 +-
> =A0mm/mempolicy.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 ++-
> =A0mm/slab.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++--
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
> =A04 files changed, 6 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
> index 7c727a9..7106786 100644
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -215,7 +215,7 @@ extern struct zonelist *huge_zonelist(struct vm_area_=
struct *vma,
> =A0extern bool init_nodemask_of_mempolicy(nodemask_t *mask);
> =A0extern bool mempolicy_nodemask_intersects(struct task_struct *tsk,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const node=
mask_t *mask);
> -extern unsigned slab_node(struct mempolicy *policy);
> +extern unsigned slab_node(void);
>
> =A0extern enum zone_type policy_zone;
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index cfb6c86..da79bbf 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1586,8 +1586,9 @@ static unsigned interleave_nodes(struct mempolicy *=
policy)
> =A0* task can change it's policy. =A0The system default policy requires n=
o
> =A0* such protection.
> =A0*/
> -unsigned slab_node(struct mempolicy *policy)
> +unsigned slab_node(void)
> =A0{
> + =A0 =A0 =A0 struct mempolicy *policy =3D !in_interrupt() ? current->pol=
icy : NULL;
> =A0 =A0 =A0 =A0if (!policy || policy->flags & MPOL_F_LOCAL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return numa_node_id();
>
> diff --git a/mm/slab.c b/mm/slab.c
> index e901a36..af3b405 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3336,7 +3336,7 @@ static void *alternate_node_alloc(struct kmem_cache=
 *cachep, gfp_t flags)
> =A0 =A0 =A0 =A0if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_M=
EM_SPREAD))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nid_alloc =3D cpuset_slab_spread_node();
> =A0 =A0 =A0 =A0else if (current->mempolicy)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid_alloc =3D slab_node(current->mempolicy)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 nid_alloc =3D slab_node();
> =A0 =A0 =A0 =A0if (nid_alloc !=3D nid_here)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ____cache_alloc_node(cachep, flags,=
 nid_alloc);
> =A0 =A0 =A0 =A0return NULL;
> @@ -3368,7 +3368,7 @@ static void *fallback_alloc(struct kmem_cache *cach=
e, gfp_t flags)
>
> =A0retry_cpuset:
> =A0 =A0 =A0 =A0cpuset_mems_cookie =3D get_mems_allowed();
> - =A0 =A0 =A0 zonelist =3D node_zonelist(slab_node(current->mempolicy), f=
lags);
> + =A0 =A0 =A0 zonelist =3D node_zonelist(slab_node(), flags);
>
> =A0retry:
> =A0 =A0 =A0 =A0/*
> diff --git a/mm/slub.c b/mm/slub.c
> index ffe13fd..ef936f3 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1614,7 +1614,7 @@ static struct page *get_any_partial(struct kmem_cac=
he *s, gfp_t flags,
>
> =A0 =A0 =A0 =A0do {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpuset_mems_cookie =3D get_mems_allowed();
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 zonelist =3D node_zonelist(slab_node(curren=
t->mempolicy), flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 zonelist =3D node_zonelist(slab_node(), fla=
gs);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_zone_zonelist(zone, z, zonelist, =
high_zoneidx) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n;
>
> --
> 1.7.7.6
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
