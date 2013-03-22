Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 957546B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 21:22:27 -0400 (EDT)
Message-ID: <514BB23E.70908@huawei.com>
Date: Fri, 22 Mar 2013 09:22:06 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix memcg_cache_name() to use cgroup_name()
References: <514A60CD.60208@huawei.com> <20130321090849.GF6094@dhcp22.suse.cz> <20130321102257.GH6094@dhcp22.suse.cz>
In-Reply-To: <20130321102257.GH6094@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>

On 2013/3/21 18:22, Michal Hocko wrote:
> On Thu 21-03-13 10:08:49, Michal Hocko wrote:
>> On Thu 21-03-13 09:22:21, Li Zefan wrote:
>>> As cgroup supports rename, it's unsafe to dereference dentry->d_name
>>> without proper vfs locks. Fix this by using cgroup_name().
>>>
>>> Signed-off-by: Li Zefan <lizefan@huawei.com>
>>> ---
>>>
>>> This patch depends on "cgroup: fix cgroup_path() vs rename() race",
>>> which has been queued for 3.10.
>>>
>>> ---
>>>  mm/memcontrol.c | 15 +++++++--------
>>>  1 file changed, 7 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index 53b8201..72be5c9 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -3217,17 +3217,16 @@ void mem_cgroup_destroy_cache(struct kmem_cache *cachep)
>>>  static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>>>  {
>>>  	char *name;
>>> -	struct dentry *dentry;
>>> +
>>> +	name = (char *)__get_free_page(GFP_TEMPORARY);
>>
>> Ouch. Can we use a static temporary buffer instead?
> 
>> This is called from workqueue context so we do not have to be afraid
>> of the deep call chain.
> 
> Bahh, I was thinking about two things at the same time and that is how
> it ends... I meant a temporary buffer on the stack. But a separate
> allocation sounds even easier.
> 

Actually I don't care much about which way to take. Use on-stack buffer (if stack
usage is not a concern) or local static buffer (caller already held memcg_cache_mutex)
is simplest.

But why it's bad to allocate a page for temp use?

>> It is also not a hot path AFAICS.
>>
>> Even GFP_ATOMIC for kasprintf would be an improvement IMO.
> 
> What about the following (not even compile tested because I do not have
> cgroup_name in my tree yet):

No, it won't compile. ;)

> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f608546..ede0382 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3370,13 +3370,18 @@ static char *memcg_cache_name(struct mem_cgroup *memcg, struct kmem_cache *s)
>  	struct dentry *dentry;
>  
>  	rcu_read_lock();
> -	dentry = rcu_dereference(memcg->css.cgroup->dentry);
> +	name = kasprintf(GFP_ATOMIC, "%s(%d:%s)", s->name,
> +			 memcg_cache_id(memcg), cgroup_name(memcg->css.cgroup));
>  	rcu_read_unlock();
>  
> -	BUG_ON(dentry == NULL);
> -
> -	name = kasprintf(GFP_KERNEL, "%s(%d:%s)", s->name,
> -			 memcg_cache_id(memcg), dentry->d_name.name);
> +	if (!name) {
> +		name = kmalloc(PAGE_SIZE, GFP_KERNEL);
> +		rcu_read_lock();
> +		name = snprintf(name, PAGE_SIZE, "%s(%d:%s)", s->name,
> +				memcg_cache_id(memcg),
> +				cgroup_name(memcg->css.cgroup));
> +		rcu_read_unlock();
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
