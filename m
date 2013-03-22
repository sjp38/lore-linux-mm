Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 0C9CC6B0044
	for <linux-mm@kvack.org>; Fri, 22 Mar 2013 04:17:37 -0400 (EDT)
Message-ID: <514C1388.6090909@huawei.com>
Date: Fri, 22 Mar 2013 16:17:12 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
References: <514A60CD.60208@huawei.com> <20130321090849.GF6094@dhcp22.suse.cz> <20130321102257.GH6094@dhcp22.suse.cz> <514BB23E.70908@huawei.com> <20130322080749.GB31457@dhcp22.suse.cz>
In-Reply-To: <20130322080749.GB31457@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>

>>>>> @@ -3217,17 +3217,16 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>>>>>  static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>>>>>  {
>>>>>  	char *name;
>>>>> -	struct dentry *dentry;
>>>>> +
>>>>> +	name = (char *)__get_free_page(GFP_TEMPORARY);
>>>>
>>>> Ouch. Can we use a static temporary buffer instead?
>>>
>>>> This is called from workqueue context so we do not have to be afraid
>>>> of the deep call chain.
>>>
>>> Bahh, I was thinking about two things at the same time and that is how
>>> it ends... I meant a temporary buffer on the stack. But a separate
>>> allocation sounds even easier.
>>>
>>
>> Actually I don't care much about which way to take. Use on-stack buffer (if stack
>> usage is not a concern) or local static buffer (caller already held memcg_cache_mutex)
>> is simplest.
>>
>> But why it's bad to allocate a page for temp use?
> 
> GFP_TEMPORARY groups short lived allocations but the mem cache is not
> an ideal candidate of this type of allocations..
> 

I'm not sure I'm following you...

char *memcg_cache_name()
{
	char *name = alloc();
	return name;
}

kmem_cache_dup()
{
	name = memcg_cache_name();
	kmem_cache_create_memcg(name);
	free(name);
}

Isn't this a short lived allocation?

>>>> It is also not a hot path AFAICS.
>>>>
>>>> Even GFP_ATOMIC for kasprintf would be an improvement IMO.
>>>
>>> What about the following (not even compile tested because I do not have
>>> cgroup_name in my tree yet):
>>
>> No, it won't compile. ;)
> 
> Somehow expected so as this was just a quick hack to show what I meant.
> The full patch is bellow (compile time tested on top of for-3.10 branch
> this time :P)
> ---
>>From 7e1f6f0e266a230ced238a9bf2398b4069a6a764 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Fri, 22 Mar 2013 09:04:58 +0100
> Subject: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
> 
> As cgroup supports rename, it's unsafe to dereference dentry->d_name
> without proper vfs locks. Fix this by using cgroup_name().
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 53b8201..5741bf5 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3220,13 +3220,18 @@ static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>  	struct dentry *dentry;
>  
>  	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> +	name = kasprintf(GFP_ATOMIC, "%s(%d:%s)", s->name,
> +			 memcg_cache_id(memcg), dcgroup_name(memcg->css.cgroup));
>  	rcu_read_unlock();
>  
> -	BUG_ON(dentry == NULL);
> +	if (!name) {
> +		name = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		rcu_read_lock();
> +		name = snprintf(name, PAGE_SIZE, "%s(%d:%s)", s->name,
> +				 memcg_cache_id(memcg), dcgroup_name(memcg->css.cgroup));
> +		rcu_read_unlock();
>  
> -	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> +	}
>  
>  	return name;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
