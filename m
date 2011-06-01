Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA236B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 09:41:58 -0400 (EDT)
Date: Wed, 1 Jun 2011 15:41:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
Message-ID: <20110601134149.GD4266@tiehlicka.suse.cz>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
 <20110601123913.GC4266@tiehlicka.suse.cz>
 <4DE6399C.8070802@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE6399C.8070802@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

[Let's CC some cgroup people]

On Wed 01-06-11 15:07:40, Igor Mammedov wrote:
> On 06/01/2011 02:39 PM, Michal Hocko wrote:
> >On Wed 01-06-11 12:44:04, Igor Mammedov wrote:
> >>Freshly allocated 'mem_cgroup_per_node' list entries must be
> >>initialized before the rest of the kernel can see them. Otherwise
> >>zero initialized list fields can lead to race condition at
> >>mem_cgroup_force_empty_list:
> >>   pc = list_entry(list->prev, struct page_cgroup, lru);
> >>where 'pc' will be something like 0xfffffffc if list->prev is 0
> >>and cause page fault later when 'pc' is dereferenced.
> >
> >Have you ever seen such a race? I do not see how this could happen.
> >mem_cgroup_force_empty_list is called only from
> >mem_cgroup_force_empty_write (aka echo whatever>  group/force_empty)
> >or mem_cgroup_pre_destroy when the group is destroyed.
> >
> >The initialization code is, however, called before a group is
> >given for use AFAICS.
> >
> >I am not saying tha the change is bad, I like it, but I do not think it
> >is a fix for potential race condition.
> >
> 
> Yes I've seen it (RHBZ#700565). 

I am not subscribed so I will not get there.

> It causes random crashes in virt env ocasionally. It's easier to
> reproduce if you overcommit cpu.

Hmm, I have missed that cgroup_create calls create callback for all
subsystems that the group should be attached to. But this shouldn't be
any problem as cgroup_call_pre_destroy (called from cgroup_rmdir) cannot
be called before the directory is actually created. 
cgroup_create_dir is called after cgroup has been created for all
subsystems so the directory entry will show up only after everything is
initialized AFAICS.  So I still do not see how we can race.

Anyway, if you are able to reproduce the problem then I would say that
the problem is somewhere in the generic cgroup code rather than in
memory controler. The patch just papers over a real bug IMO. But I may
be wrong as I am not definitely an expert in the area.

> 
> >>Signed-off-by: Igor Mammedov<imammedo@redhat.com>
> >>---
> >>  mm/memcontrol.c |    2 +-
> >>  1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >>index bd9052a..ee7cb4c 100644
> >>--- a/mm/memcontrol.c
> >>+++ b/mm/memcontrol.c
> >>@@ -4707,7 +4707,6 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> >>  	if (!pn)
> >>  		return 1;
> >>
> >>-	mem->info.nodeinfo[node] = pn;
> >>  	for (zone = 0; zone<  MAX_NR_ZONES; zone++) {
> >>  		mz =&pn->zoneinfo[zone];
> >>  		for_each_lru(l)
> >>@@ -4716,6 +4715,7 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
> >>  		mz->on_tree = false;
> >>  		mz->mem = mem;
> >>  	}
> >>+	mem->info.nodeinfo[node] = pn;
> >>  	return 0;
> >>  }
> >>
> >>-- 
> >>1.7.1

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
