Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 224D06B010C
	for <linux-mm@kvack.org>; Sun, 20 Sep 2009 10:04:21 -0400 (EDT)
Date: Sun, 20 Sep 2009 15:04:21 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
Message-ID: <20090920140421.GB18162@csn.ul.ie>
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Sep 20, 2009 at 11:45:54AM +0300, Pekka Enberg wrote:
> On Fri, Sep 18, 2009 at 10:34 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > SLQB used a seemingly nice hack to allocate per-node data for the statically
> > initialised caches. Unfortunately, due to some unknown per-cpu
> > optimisation, these regions are being reused by something else as the
> > per-node data is getting randomly scrambled. This patch fixes the
> > problem but it's not fully understood *why* it fixes the problem at the
> > moment.
> 
> Ouch, that sounds bad. I guess it's architecture specific bug as x86
> works ok? Lets CC Tejun.
> 
> Nick, are you okay with this patch being merged for now?
> 

I don't think it should be merged as-is. This patch might be treating
symptons so needs further thought. The second patch is a hatchet job and
as Christoph points out, it may be suffering a subtle list-corruption
bug.

> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/slqb.c |   16 ++++++++--------
> >  1 files changed, 8 insertions(+), 8 deletions(-)
> >
> > diff --git a/mm/slqb.c b/mm/slqb.c
> > index 4ca85e2..4d72be2 100644
> > --- a/mm/slqb.c
> > +++ b/mm/slqb.c
> > @@ -1944,16 +1944,16 @@ static void init_kmem_cache_node(struct kmem_cache *s,
> >  static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cache_cpus);
> >  #endif
> >  #ifdef CONFIG_NUMA
> > -/* XXX: really need a DEFINE_PER_NODE for per-node data, but this is better than
> > - * a static array */
> > -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cache_nodes);
> > +/* XXX: really need a DEFINE_PER_NODE for per-node data because a static
> > + *      array is wasteful */
> > +static struct kmem_cache_node kmem_cache_nodes[MAX_NUMNODES];
> >  #endif
> >
> >  #ifdef CONFIG_SMP
> >  static struct kmem_cache kmem_cpu_cache;
> >  static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_cpu_cpus);
> >  #ifdef CONFIG_NUMA
> > -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_cpu_nodes); /* XXX per-nid */
> > +static struct kmem_cache_node kmem_cpu_nodes[MAX_NUMNODES]; /* XXX per-nid */
> >  #endif
> >  #endif
> >
> > @@ -1962,7 +1962,7 @@ static struct kmem_cache kmem_node_cache;
> >  #ifdef CONFIG_SMP
> >  static DEFINE_PER_CPU(struct kmem_cache_cpu, kmem_node_cpus);
> >  #endif
> > -static DEFINE_PER_CPU(struct kmem_cache_node, kmem_node_nodes); /*XXX per-nid */
> > +static struct kmem_cache_node kmem_node_nodes[MAX_NUMNODES]; /*XXX per-nid */
> >  #endif
> >
> >  #ifdef CONFIG_SMP
> > @@ -2918,15 +2918,15 @@ void __init kmem_cache_init(void)
> >        for_each_node_state(i, N_NORMAL_MEMORY) {
> >                struct kmem_cache_node *n;
> >
> > -               n = &per_cpu(kmem_cache_nodes, i);
> > +               n = &kmem_cache_nodes[i];
> >                init_kmem_cache_node(&kmem_cache_cache, n);
> >                kmem_cache_cache.node_slab[i] = n;
> >  #ifdef CONFIG_SMP
> > -               n = &per_cpu(kmem_cpu_nodes, i);
> > +               n = &kmem_cpu_nodes[i];
> >                init_kmem_cache_node(&kmem_cpu_cache, n);
> >                kmem_cpu_cache.node_slab[i] = n;
> >  #endif
> > -               n = &per_cpu(kmem_node_nodes, i);
> > +               n = &kmem_node_nodes[i];
> >                init_kmem_cache_node(&kmem_node_cache, n);
> >                kmem_node_cache.node_slab[i] = n;
> >        }
> > --
> > 1.6.3.3
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
