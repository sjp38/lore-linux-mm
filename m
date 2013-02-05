Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4BF696B0007
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:38:03 -0500 (EST)
Date: Tue, 5 Feb 2013 13:37:53 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
Message-ID: <20130205183753.GA6481@cmpxchg.org>
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
 <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
 <20130124155105.85dae9d9.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130124155105.85dae9d9.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Thu, Jan 24, 2013 at 03:51:05PM -0800, Andrew Morton wrote:
> On Wed, 23 Jan 2013 23:50:31 -0800
> Greg Thelen <gthelen@google.com> wrote:
> 
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -172,7 +172,7 @@ struct mem_cgroup_per_node {
> > >  };
> > >  
> > >  struct mem_cgroup_lru_info {
> > > -	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> > > +	struct mem_cgroup_per_node *nodeinfo[0];
> > 
> > It seems like a VM_BUG_ON() in mem_cgroup_zoneinfo() asserting that the
> > nid index is less than nr_node_ids would be good at catching illegal
> > indexes.  I don't see any illegal indexes in your patch, but I fear that
> > someday a MAX_NUMNODES based for() loop might sneak in.
> 
> Can't hurt ;)
> 
> > Tangential question: why use inline here?  I figure that modern
> > compilers are good at making inlining decisions.
> 
> And that'll save some disk space.
> 
> This?
> 
> --- a/mm/memcontrol.c~memcg-reduce-the-size-of-struct-memcg-244-fold-fix
> +++ a/mm/memcontrol.c
> @@ -381,7 +381,7 @@ enum {
>  		((1 << KMEM_ACCOUNTED_ACTIVE) | (1 << KMEM_ACCOUNTED_ACTIVATED))
>  
>  #ifdef CONFIG_MEMCG_KMEM
> -static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
> +static void memcg_kmem_set_active(struct mem_cgroup *memcg)
>  {
>  	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }

I don't disapprove, but it's the wrong function for this patch.
Should be memcg_size().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
