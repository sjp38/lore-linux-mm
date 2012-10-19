Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 6B4E46B0069
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 06:08:51 -0400 (EDT)
Message-ID: <5081269B.5000603@parallels.com>
Date: Fri, 19 Oct 2012 14:08:27 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 06/14] memcg: kmem controller infrastructure
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-7-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1210171515290.20712@chino.kir.corp.google.com> <507FCA90.8060307@parallels.com> <alpine.DEB.2.00.1210181454100.30894@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1210181454100.30894@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 10/19/2012 01:59 AM, David Rientjes wrote:
> On Thu, 18 Oct 2012, Glauber Costa wrote:
> 
>>>> @@ -2630,6 +2634,171 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
>>>>  	memcg_check_events(memcg, page);
>>>>  }
>>>>  
>>>> +#ifdef CONFIG_MEMCG_KMEM
>>>> +static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
>>>> +{
>>>> +	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
>>>> +		(memcg->kmem_accounted & KMEM_ACCOUNTED_MASK);
>>>> +}
>>>> +
>>>> +static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
>>>> +{
>>>> +	struct res_counter *fail_res;
>>>> +	struct mem_cgroup *_memcg;
>>>> +	int ret = 0;
>>>> +	bool may_oom;
>>>> +
>>>> +	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
>>>> +	if (ret)
>>>> +		return ret;
>>>> +
>>>> +	/*
>>>> +	 * Conditions under which we can wait for the oom_killer.
>>>> +	 * We have to be able to wait, but also, if we can't retry,
>>>> +	 * we obviously shouldn't go mess with oom.
>>>> +	 */
>>>> +	may_oom = (gfp & __GFP_WAIT) && !(gfp & __GFP_NORETRY);
>>>
>>> What about gfp & __GFP_FS?
>>>
>>
>> Do you intend to prevent or allow OOM under that flag? I personally
>> think that anything that accepts to be OOM-killed should have GFP_WAIT
>> set, so that ought to be enough.
>>
> 
> The oom killer in the page allocator cannot trigger without __GFP_FS 
> because direct reclaim has little chance of being very successful and 
> thus we end up needlessly killing processes, and that tends to happen 
> quite a bit if we dont check for it.  Seems like this would also happen 
> with memcg if mem_cgroup_reclaim() has a large probability of failing?
> 

I can indeed see tests for GFP_FS in some key locations in mm/ before
calling the OOM Killer.

Should I test for GFP_IO as well? If the idea is preventing OOM to
trigger for allocations that can write their pages back, how would you
feel about the following test:

may_oom = (gfp & GFP_KERNEL) && !(gfp & __GFP_NORETRY) ?

Michal, what is your take in here?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
