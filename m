Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 992B36B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 18:51:07 -0500 (EST)
Date: Thu, 24 Jan 2013 15:51:05 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
Message-Id: <20130124155105.85dae9d9.akpm@linux-foundation.org>
In-Reply-To: <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
References: <1359009996-5350-1-git-send-email-glommer@parallels.com>
	<xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Wed, 23 Jan 2013 23:50:31 -0800
Greg Thelen <gthelen@google.com> wrote:

> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -172,7 +172,7 @@ struct mem_cgroup_per_node {
> >  };
> >  
> >  struct mem_cgroup_lru_info {
> > -	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
> > +	struct mem_cgroup_per_node *nodeinfo[0];
> 
> It seems like a VM_BUG_ON() in mem_cgroup_zoneinfo() asserting that the
> nid index is less than nr_node_ids would be good at catching illegal
> indexes.  I don't see any illegal indexes in your patch, but I fear that
> someday a MAX_NUMNODES based for() loop might sneak in.

Can't hurt ;)

> Tangential question: why use inline here?  I figure that modern
> compilers are good at making inlining decisions.

And that'll save some disk space.

This?

--- a/mm/memcontrol.c~memcg-reduce-the-size-of-struct-memcg-244-fold-fix
+++ a/mm/memcontrol.c
@@ -381,7 +381,7 @@ enum {
 		((1 << KMEM_ACCOUNTED_ACTIVE) | (1 << KMEM_ACCOUNTED_ACTIVATED))
 
 #ifdef CONFIG_MEMCG_KMEM
-static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
+static void memcg_kmem_set_active(struct mem_cgroup *memcg)
 {
 	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
 }
@@ -645,6 +645,7 @@ static void drain_all_stock_async(struct
 static struct mem_cgroup_per_zone *
 mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
 {
+	VM_BUG_ON((unsigned)nid >= nr_node_ids);
 	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
 }
 
_

Glauber, could you please cc me on patches more often?  It's a bit of a
pita having to go back to the mailing list to see if there has been
more dicussion and I may end up missing late review comments and acks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
