Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 7B4596B00B5
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 04:08:01 -0400 (EDT)
Message-ID: <515BE38B.2060602@parallels.com>
Date: Wed, 3 Apr 2013 12:08:43 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v2] memcg: don't do cleanup manually if mem_cgroup_css_online()
 fails
References: <515A8A40.6020406@huawei.com> <20130402121600.GK24345@dhcp22.suse.cz> <20130402141646.GQ24345@dhcp22.suse.cz> <515AE948.1000704@parallels.com> <20130402142825.GA32520@dhcp22.suse.cz> <515AEC3A.2030401@parallels.com> <20130402150422.GB32520@dhcp22.suse.cz>
In-Reply-To: <20130402150422.GB32520@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On 04/02/2013 07:04 PM, Michal Hocko wrote:
> On Tue 02-04-13 18:33:30, Glauber Costa wrote:
>> On 04/02/2013 06:28 PM, Michal Hocko wrote:
>>> On Tue 02-04-13 18:20:56, Glauber Costa wrote:
>>>> On 04/02/2013 06:16 PM, Michal Hocko wrote:
>>>>>  mem_cgroup_css_online
>>>>>       memcg_init_kmem
>>>>>         mem_cgroup_get		# refcnt = 2
>>>>>           memcg_update_all_caches
>>>>>             memcg_update_cache_size	# fails with ENOMEM
>>>>
>>>> Here is the thing: this one in kmem only happens for kmem enabled
>>>> memcgs. For those, we tend to do a get once, and put only when the last
>>>> kmem reference is gone.
>>>>
>>>> For non-kmem memcgs, refcnt will be 1 here, and will be balanced out by
>>>> the mem_cgroup_put() in css_free.
>>>
>>> So we need this, right?
>>> ---
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index f608546..2ef875d 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -5306,6 +5306,8 @@ static int memcg_propagate_kmem(struct mem_cgroup *memcg)
>>>  	ret = memcg_update_cache_sizes(memcg);
>>>  	mutex_unlock(&set_limit_mutex);
>>>  out:
>>> +	if (ret)
>>> +		mem_cgroup_put(memcg);
>>>  	return ret;
>>>  }
>>>  #endif /* CONFIG_MEMCG_KMEM */
>>> @@ -6417,16 +6419,6 @@ mem_cgroup_css_online(struct cgroup *cont)
>>>  
>>>  	error = memcg_init_kmem(memcg, &mem_cgroup_subsys);
>>>  	mutex_unlock(&memcg_create_mutex);
>>> -	if (error) {
>>> -		/*
>>> -		 * We call put now because our (and parent's) refcnts
>>> -		 * are already in place. mem_cgroup_put() will internally
>>> -		 * call __mem_cgroup_free, so return directly
>>> -		 */
>>> -		mem_cgroup_put(memcg);
>>> -		if (parent->use_hierarchy)
>>> -			mem_cgroup_put(parent);
>>> -	}
>>>  	return error;
>>>  }
>>>  
>>>
>> Yes, indeed you are very right - and thanks for looking at such depth.
> 
> So what about the patch bellow? It seems that I provoked all this mess
> but my brain managed to push it away so I do not remember why I thought
> the parent needs reference drop... It is "only" 3.9 thing fortunately.
> ---

Li being fine with it, I am fine with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
