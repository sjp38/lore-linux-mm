Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 17E166B0009
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 14:27:49 -0500 (EST)
Message-ID: <50F9A240.5040808@parallels.com>
Date: Fri, 18 Jan 2013 11:28:00 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-3-git-send-email-glommer@parallels.com> <20130118152526.GF10701@dhcp22.suse.cz>
In-Reply-To: <20130118152526.GF10701@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/18/2013 07:25 AM, Michal Hocko wrote:
> On Fri 11-01-13 13:45:22, Glauber Costa wrote:
>> Although there is arguably some value in doing this per se, the main
> 
> This begs for asking what are the other reasons but I would just leave
> it alone and focus on the code reshuffling.
> 
Yes, Sir.

>> goal of this patch is to make room for the locking changes to come.
>>
>> With all the value assignment from parent happening in a context where
>> our iterators can already be used, we can safely lock against value
>> change in some key values like use_hierarchy, without resorting to the
>> cgroup core at all.
> 
> Sorry but I do not understand the above. Please be more specific here.
> Why the context matters if it matters at all.
> 
> Maybe something like the below?
> "
> mem_cgroup_css_alloc is currently responsible for the complete
> initialization of a newly created memcg. Cgroup core offers another
> stage of initialization - css_online - which is called after the newly
> created group is already linked to the cgroup hierarchy.
> All attributes inheritted from the parent group can be safely moved
> into mem_cgroup_css_online because nobody can see the newly created
> group yet. This has also an advantage that the parent can already see
> the child group (via iterators) by the time we inherit values from it
> so he can do appropriate steps (e.g. don't allow changing use_hierarchy
> etc...).
> 
> This patch is a preparatory work for later locking rework to get rid of
> big cgroup lock from memory controller code.
> "
> 
Well, I will look into merging some of it, but AFAIK, you are explaining
why is it safe (a good thing to do), while I was focusing on telling our
future readers why is it needed.

I'll try to rewrite for clarity

> 
> 	/*
> 	 * Initialization of attributes which are linked with parent
> 	 * based on use_hierarchy.
> 	 */
>>  	if (parent && parent->use_hierarchy) {
> 
> parent cannot be NULL.
> 
indeed.

>>  		res_counter_init(&memcg->res, &parent->res);
>>  		res_counter_init(&memcg->memsw, &parent->memsw);
>> @@ -6120,15 +6149,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
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
> 
> Please move this up to oom_kill_disable and use_hierarchy
> initialization.
> 
Yes, Sir!

> 	/*
> 	 * kmem initialization depends on memcg->res initialization
> 	 * because it relies on parent_mem_cgroup
> 	 */
>>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>>  	if (error) {
>> @@ -6138,12 +6160,8 @@ mem_cgroup_css_alloc(struct cgroup *cont)
>>  		 * call __mem_cgroup_free, so return directly
>>  		 */
>>  		mem_cgroup_put(memcg);
> 
> Hmm, this doesn't release parent for use_hierarchy. The bug is there
> from before this patch. So it should go into a separate patch.
> 
Good catch.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
