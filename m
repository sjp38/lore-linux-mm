Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D77B16B0104
	for <linux-mm@kvack.org>; Sun, 20 Sep 2009 04:45:51 -0400 (EDT)
Received: by fxm2 with SMTP id 2so1584743fxm.4
        for <linux-mm@kvack.org>; Sun, 20 Sep 2009 01:45:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1253302451-27740-2-git-send-email-mel@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie>
	 <1253302451-27740-2-git-send-email-mel@csn.ul.ie>
Date: Sun, 20 Sep 2009 11:45:54 +0300
Message-ID: <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com>
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> SLQB used a seemingly nice hack to allocate per-node data for the statica=
lly
> initialised caches. Unfortunately, due to some unknown per-cpu
> optimisation, these regions are being reused by something else as the
> per-node data is getting randomly scrambled. This patch fixes the
> problem but it's not fully understood *why* it fixes the problem at the
> moment.

Ouch, that sounds bad. I guess it's architecture specific bug as x86
works ok? Lets CC Tejun.

Nick, are you okay with this patch being merged for now?

> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
> =A0mm/slqb.c | =A0 16 ++++++++--------
> =A01 files changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/mm/slqb.c b/mm/slqb.c
> index 4ca85e2..4d72be2 100644
> --- a/mm/slqb.c
> +++ b/mm/slqb.c
> @@ -1944,16 +1944,16 @@ static void init_kmem_cache_node(struct kmem_cach=
e *s,
> =A0static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cache_cpus);
> =A0#endif
> =A0#ifdef CONFIG_NUMA
> -/* XXX: really need a DEFINE_PER_NODE for per-node data, but this is bet=
ter than
> - * a static array */
> -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cache_nodes);
> +/* XXX: really need a DEFINE_PER_NODE for per-node data because a static
> + * =A0 =A0 =A0array is wasteful */
> +static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
> =A0#endif
>
> =A0#ifdef CONFIG_SMP
> =A0static struct kmem_cache kmem_cpu_cache;
> =A0static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cpu_cpus);
> =A0#ifdef CONFIG_NUMA
> -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cpu_nodes); /* XXX pe=
r-nid */
> +static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES]; /* XXX per-n=
id */
> =A0#endif
> =A0#endif
>
> @@ -1962,7 +1962,7 @@ static struct kmem_cache kmem_node_cache;
> =A0#ifdef CONFIG_SMP
> =A0static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_node_cpus);
> =A0#endif
> -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_node_nodes); /*XXX pe=
r-nid */
> +static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES]; /*XXX per-n=
id */
> =A0#endif
>
> =A0#ifdef CONFIG_SMP
> @@ -2918,15 +2918,15 @@ void __init kmem_cache_init(void)
> =A0 =A0 =A0 =A0for_each_node_state(i, N_NORMAL_MEMORY) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct kmem_cache_node *n;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &per_cpu(kmem_cache_nodes, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &kmem_cache_nodes[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_kmem_cache_node(&kmem_cache_cache, n)=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cache_cache.node_slab[i] =3D n;
> =A0#ifdef CONFIG_SMP
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &per_cpu(kmem_cpu_nodes, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &kmem_cpu_nodes[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_kmem_cache_node(&kmem_cpu_cache, n);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_cpu_cache.node_slab[i] =3D n;
> =A0#endif
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &per_cpu(kmem_node_nodes, i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 n =3D &kmem_node_nodes[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0init_kmem_cache_node(&kmem_node_cache, n);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0kmem_node_cache.node_slab[i] =3D n;
> =A0 =A0 =A0 =A0}
> --
> 1.6.3.3
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
