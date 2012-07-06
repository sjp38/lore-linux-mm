Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 299356B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 10:54:43 -0400 (EDT)
Received: by qadz32 with SMTP id z32so496171qad.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 07:54:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120316144240.234456258@chello.nl>
References: <20120316144028.036474157@chello.nl>
	<20120316144240.234456258@chello.nl>
Date: Fri, 6 Jul 2012 23:54:41 +0900
Message-ID: <CAH9JG2U-_RzDQ9TgjXWSBFjscCKn0oKp1mhvOsRVoxR7hsSxHA@mail.gmail.com>
Subject: Re: [RFC][PATCH 02/26] mm, mpol: Remove NUMA_INTERLEAVE_HIT
From: Kyungmin Park <kmpark@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 16, 2012 at 11:40 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Since the NUMA_INTERLEAVE_HIT statistic is useless on its own; it wants
> to be compared to either a total of interleave allocations or to a miss
> count, remove it.
>
> Fixing it would be possible, but since we've gone years without these
> statistics I figure we can continue that way.
>
> This cleans up some of the weird MPOL_INTERLEAVE allocation exceptions.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  drivers/base/node.c    |    2 +-
>  include/linux/mmzone.h |    1 -
>  mm/mempolicy.c         |   66 +++++++++++++++--------------------------------
>  3 files changed, 22 insertions(+), 47 deletions(-)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 5693ece..942cdbc 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -172,7 +172,7 @@ static ssize_t node_read_numastat(struct sys_device * dev,
>                        node_page_state(dev->id, NUMA_HIT),
>                        node_page_state(dev->id, NUMA_MISS),
>                        node_page_state(dev->id, NUMA_FOREIGN),
> -                      node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
> +                      0UL,
>                        node_page_state(dev->id, NUMA_LOCAL),
>                        node_page_state(dev->id, NUMA_OTHER));
>  }
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 3ac040f..3a3be81 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -111,7 +111,6 @@ enum zone_stat_item {
>         NUMA_HIT,               /* allocated in intended node */
>         NUMA_MISS,              /* allocated in non intended node */
>         NUMA_FOREIGN,           /* was intended here, hit elsewhere */
> -       NUMA_INTERLEAVE_HIT,    /* interleaver preferred this zone */
>         NUMA_LOCAL,             /* allocation from local node */
>         NUMA_OTHER,             /* allocation from other node */
>  #endif
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index c3fdbcb..2c48c45 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1530,11 +1530,29 @@ static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
>         return NULL;
>  }
>
> +/* Do dynamic interleaving for a process */
> +static unsigned interleave_nodes(struct mempolicy *policy)
> +{
> +       unsigned nid, next;
> +       struct task_struct *me = current;
> +
> +       nid = me->il_next;
> +       next = next_node(nid, policy->v.nodes);
> +       if (next >= MAX_NUMNODES)
> +               next = first_node(policy->v.nodes);
> +       if (next < MAX_NUMNODES)
> +               me->il_next = next;
> +       return nid;
> +}
> +
>  /* Return a zonelist indicated by gfp for node representing a mempolicy */
>  static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
>         int nd)
>  {
>         switch (policy->mode) {
> +       case MPOL_INTERLEAVE:
> +               nd = interleave_nodes(policy);
Jut nitpick,
Original code also uses the 'unsigned nid' but now it assigned
'unsigned nid' to 'int nd' at here. does it right?

Thank you,
Kyungmin Park
> +               break;
>         case MPOL_PREFERRED:
>                 if (!(policy->flags & MPOL_F_LOCAL))
>                         nd = policy->v.preferred_node;
> @@ -1556,21 +1574,6 @@ static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *policy,
>         return node_zonelist(nd, gfp);
>  }
>
> -/* Do dynamic interleaving for a process */
> -static unsigned interleave_nodes(struct mempolicy *policy)
> -{
> -       unsigned nid, next;
> -       struct task_struct *me = current;
> -
> -       nid = me->il_next;
> -       next = next_node(nid, policy->v.nodes);
> -       if (next >= MAX_NUMNODES)
> -               next = first_node(policy->v.nodes);
> -       if (next < MAX_NUMNODES)
> -               me->il_next = next;
> -       return nid;
> -}
> -
>  /*
>   * Depending on the memory policy provide a node from which to allocate the
>   * next slab entry.
> @@ -1801,21 +1804,6 @@ out:
>         return ret;
>  }
>
> -/* Allocate a page in interleaved policy.
> -   Own path because it needs to do special accounting. */
> -static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
> -                                       unsigned nid)
> -{
> -       struct zonelist *zl;
> -       struct page *page;
> -
> -       zl = node_zonelist(nid, gfp);
> -       page = __alloc_pages(gfp, order, zl);
> -       if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
> -               inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
> -       return page;
> -}
> -
>  /**
>   *     alloc_pages_vma - Allocate a page for a VMA.
>   *
> @@ -1848,15 +1836,6 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>         struct page *page;
>
>         get_mems_allowed();
> -       if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
> -               unsigned nid;
> -
> -               nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
> -               mpol_cond_put(pol);
> -               page = alloc_page_interleave(gfp, order, nid);
> -               put_mems_allowed();
> -               return page;
> -       }
>         zl = policy_zonelist(gfp, pol, node);
>         if (unlikely(mpol_needs_cond_ref(pol))) {
>                 /*
> @@ -1909,12 +1888,9 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
>          * No reference counting needed for current->mempolicy
>          * nor system default_policy
>          */
> -       if (pol->mode == MPOL_INTERLEAVE)
> -               page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
> -       else
> -               page = __alloc_pages_nodemask(gfp, order,
> -                               policy_zonelist(gfp, pol, numa_node_id()),
> -                               policy_nodemask(gfp, pol));
> +       page = __alloc_pages_nodemask(gfp, order,
> +                       policy_zonelist(gfp, pol, numa_node_id()),
> +                       policy_nodemask(gfp, pol));
>         put_mems_allowed();
>         return page;
>  }
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
