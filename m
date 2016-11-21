Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E768B280260
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 03:36:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so34180715wms.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 00:36:24 -0800 (PST)
Received: from smtp50.i.mail.ru (smtp50.i.mail.ru. [94.100.177.110])
        by mx.google.com with ESMTPS id m76si12514809wmh.131.2016.11.21.00.36.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 21 Nov 2016 00:36:23 -0800 (PST)
Date: Mon, 21 Nov 2016 11:36:16 +0300
From: Vladimir Davydov <vdavydov@tarantool.org>
Subject: Re: [RESEND] [PATCH v1 1/3] Add basic infrastructure for memcg
 hotplug support
Message-ID: <20161121083616.GC18431@esperanza>
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
 <1479253501-26261-2-git-send-email-bsingharora@gmail.com>
 <20161116090129.GA18225@esperanza>
 <3accc533-8dda-a69c-fabc-23eb388cf11b@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3accc533-8dda-a69c-fabc-23eb388cf11b@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Nov 17, 2016 at 11:28:12AM +1100, Balbir Singh wrote:
> >> @@ -5773,6 +5771,59 @@ static int __init cgroup_memory(char *s)
> >>  }
> >>  __setup("cgroup.memory=", cgroup_memory);
> >>  
> >> +static void memcg_node_offline(int node)
> >> +{
> >> +	struct mem_cgroup *memcg;
> >> +
> >> +	if (node < 0)
> >> +		return;
> > 
> > Is this possible?
> 
> Yes, please see node_states_check_changes_online/offline

OK, I see.

> 
> > 
> >> +
> >> +	for_each_mem_cgroup(memcg) {
> >> +		free_mem_cgroup_per_node_info(memcg, node);
> >> +		mem_cgroup_may_update_nodemask(memcg);
> > 
> > If memcg->numainfo_events is 0, mem_cgroup_may_update_nodemask() won't
> > update memcg->scan_nodes. Is it OK?
> > 
> >> +	}
> > 
> > What if a memory cgroup is created or destroyed while you're walking the
> > tree? Should we probably use get_online_mems() in mem_cgroup_alloc() to
> > avoid that?
> > 
> 
> The iterator internally takes rcu_read_lock() to avoid any side-effects
> of cgroups added/removed. I suspect you are also suggesting using get_online_mems()
> around each call to for_each_online_node
> 
> My understanding so far is
> 
> 1. invalidate_reclaim_iterators should be safe (no bad side-effects)
> 2. mem_cgroup_free - should be safe as well
> 3. mem_cgroup_alloc - needs protection
> 4. mem_cgroup_init - needs protection
> 5. mem_cgroup_remove_from_tress - should be safe

I'm not into the memory hotplug code, but my understanding is that if
memcg offline happens to race with node unplug, it's possible that

 - mem_cgroup_free() doesn't free the node's data, because it sees the
   node as already offline
 - memcg hotplug code doesn't free the node's data either, because it
   sees the cgroup as offline

May be, we should surround all the loops over online nodes with
get/put_online_mems() to be sure that nothing wrong can happen.
They are slow path, anyway.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
