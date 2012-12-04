Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 884DB6B005D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 03:05:27 -0500 (EST)
Message-ID: <50BDAEC1.8040805@parallels.com>
Date: Tue, 4 Dec 2012 12:05:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] memcg: split part of memcg creation to css_online
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-4-git-send-email-glommer@parallels.com> <20121203173205.GI17093@dhcp22.suse.cz>
In-Reply-To: <20121203173205.GI17093@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 12/03/2012 09:32 PM, Michal Hocko wrote:
> On Fri 30-11-12 17:31:25, Glauber Costa wrote:
>> Although there is arguably some value in doing this per se, the main
>> goal of this patch is to make room for the locking changes to come.
>>
>> With all the value assignment from parent happening in a context where
>> our iterators can already be used, we can safely lock against value
>> change in some key values like use_hierarchy, without resorting to the
>> cgroup core at all.
> 
> I am sorry but I really do not get why online_css callback is more
> appropriate. Quite contrary. With this change iterators can see a group
> which is not fully initialized which calls for a problem (even though it
> is not one yet).

But it should be extremely easy to protect against this. It is just a
matter of not returning online css in the iterator: then we'll never see
them until they are online. This also sounds a lot more correct than
returning allocated css.


> Could you be more specific why we cannot keep the initialization in
> mem_cgroup_css_alloc? We can lock there as well, no?
> 
Because we need to parent value of things like use_hierarchy and
oom_control not to change after it was copied to a child.

If we do it in css_alloc, the iterators won't be working yet - nor will
cgrp->children list, for that matter - and we will risk a situation
where another thread thinks no children exist, and flips use_hierarchy
to 1 (or oom_control, etc), right after the children already got the
value of 0.

The two other ways to solve this problem that I see, are:

1) lock in css_alloc and unlock in css_online, that tejun already ruled
out as too damn ugly (and I can't possibly disagree)

2) have an alternate indication of emptiness that is working since
css_alloc (like counting number of children).

Since I don't share your concerns about the iterator showing incomplete
memcgs - trivial to fix, if not fixed already - I deemed my approach
preferable here.



>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> ---
>>  mm/memcontrol.c | 52 +++++++++++++++++++++++++++++++++++-----------------
>>  1 file changed, 35 insertions(+), 17 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index d80b6b5..b6d352f 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -5023,12 +5023,40 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>>  			INIT_WORK(&stock->work, drain_local_stock);
>>  		}
>>  		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>> -	} else {
>> -		parent = mem_cgroup_from_cont(cont->parent);
>> -		memcg->use_hierarchy = parent->use_hierarchy;
>> -		memcg->oom_kill_disable = parent->oom_kill_disable;
>> +
>> +		res_counter_init(&memcg->res, NULL);
>> +		res_counter_init(&memcg->memsw, NULL);
>>  	}
>>  
>> +	memcg->last_scanned_node = MAX_NUMNODES;
>> +	INIT_LIST_HEAD(&memcg->oom_notify);
>> +	atomic_set(&memcg->refcnt, 1);
>> +	memcg->move_charge_at_immigrate = 0;
>> +	mutex_init(&memcg->thresholds_lock);
>> +	spin_lock_init(&memcg->move_lock);
>> +
>> +	return &memcg->css;
>> +
>> +free_out:
>> +	__mem_cgroup_free(memcg);
>> +	return ERR_PTR(error);
>> +}
>> +
>> +static int
>> +mem_cgroup_css_online(struct cgroup *cont)
>> +{
>> +	struct mem_cgroup *memcg, *parent;
>> +	int error = 0;
>> +
>> +	if (!cont->parent)
>> +		return 0;
>> +
>> +	memcg = mem_cgroup_from_cont(cont);
>> +	parent = mem_cgroup_from_cont(cont->parent);
>> +
>> +	memcg->use_hierarchy = parent->use_hierarchy;
>> +	memcg->oom_kill_disable = parent->oom_kill_disable;
>> +
>>  	if (parent && parent->use_hierarchy) {
>>  		res_counter_init(&memcg->res, &parent->res);
>>  		res_counter_init(&memcg->memsw, &parent->memsw);
>> @@ -5050,15 +5078,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>>  		if (parent && parent != root_mem_cgroup)
>>  			mem_cgroup_subsys.broken_hierarchy = true;
>>  	}
>> -	memcg->last_scanned_node = MAX_NUMNODES;
>> -	INIT_LIST_HEAD(&memcg->oom_notify);
>>  
>> -	if (parent)
>> -		memcg->swappiness = mem_cgroup_swappiness(parent);
>> -	atomic_set(&memcg->refcnt, 1);
>> -	memcg->move_charge_at_immigrate = 0;
>> -	mutex_init(&memcg->thresholds_lock);
>> -	spin_lock_init(&memcg->move_lock);
>> +	memcg->swappiness = mem_cgroup_swappiness(parent);
>>  
>>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>>  	if (error) {
>> @@ -5068,12 +5089,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>>  		 * call __mem_cgroup_free, so return directly
>>  		 */
>>  		mem_cgroup_put(memcg);
>> -		return ERR_PTR(error);
>>  	}
>> -	return &memcg->css;
>> -free_out:
>> -	__mem_cgroup_free(memcg);
>> -	return ERR_PTR(error);
>> +	return error;
>>  }
>>  
>>  static void mem_cgroup_css_offline(struct cgroup *cont)
>> @@ -5702,6 +5719,7 @@ struct cgroup_subsys mem_cgroup_subsys = {
>>  	.name = "memory",
>>  	.subsys_id = mem_cgroup_subsys_id,
>>  	.css_alloc = mem_cgroup_css_alloc,
>> +	.css_online = mem_cgroup_css_online,
>>  	.css_offline = mem_cgroup_css_offline,
>>  	.css_free = mem_cgroup_css_free,
>>  	.can_attach = mem_cgroup_can_attach,
>> -- 
>> 1.7.11.7
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
