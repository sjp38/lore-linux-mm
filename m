Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id DE23F6B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 04:00:57 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DC0263EE0B5
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:00:55 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C091E45DE5A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:00:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A1D4F45DE51
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:00:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 88AA41DB8045
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:00:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 327A71DB8040
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 17:00:55 +0900 (JST)
Message-ID: <507D1403.2070205@jp.fujitsu.com>
Date: Tue, 16 Oct 2012 17:00:03 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 06/14] memcg: kmem controller infrastructure
References: <1349690780-15988-1-git-send-email-glommer@parallels.com> <1349690780-15988-7-git-send-email-glommer@parallels.com> <20121011124212.GC29295@dhcp22.suse.cz> <5077CAAA.3090709@parallels.com> <20121012083944.GD10110@dhcp22.suse.cz> <5077D889.2040100@parallels.com> <20121012085740.GG10110@dhcp22.suse.cz> <5077DF20.7020200@parallels.com>
In-Reply-To: <5077DF20.7020200@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Suleiman Souhlal <suleiman@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, devel@openvz.org, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

(2012/10/12 18:13), Glauber Costa wrote:
> On 10/12/2012 12:57 PM, Michal Hocko wrote:
>> On Fri 12-10-12 12:44:57, Glauber Costa wrote:
>>> On 10/12/2012 12:39 PM, Michal Hocko wrote:
>>>> On Fri 12-10-12 11:45:46, Glauber Costa wrote:
>>>>> On 10/11/2012 04:42 PM, Michal Hocko wrote:
>>>>>> On Mon 08-10-12 14:06:12, Glauber Costa wrote:
>>>> [...]
>>>>>>> +	/*
>>>>>>> +	 * Conditions under which we can wait for the oom_killer.
>>>>>>> +	 * __GFP_NORETRY should be masked by __mem_cgroup_try_charge,
>>>>>>> +	 * but there is no harm in being explicit here
>>>>>>> +	 */
>>>>>>> +	may_oom = (gfp & __GFP_WAIT) && !(gfp & __GFP_NORETRY);
>>>>>>
>>>>>> Well we _have to_ check __GFP_NORETRY here because if we don't then we
>>>>>> can end up in OOM. mem_cgroup_do_charge returns CHARGE_NOMEM for
>>>>>> __GFP_NORETRY (without doing any reclaim) and of oom==true we decrement
>>>>>> oom retries counter and eventually hit OOM killer. So the comment is
>>>>>> misleading.
>>>>>
>>>>> I will update. What i understood from your last message is that we don't
>>>>> really need to, because try_charge will do it.
>>>>
>>>> IIRC I just said it couldn't happen before because migration doesn't go
>>>> through charge and thp disable oom by default.
>>>>
>>>
>>> I had it changed to:
>>>
>>>          /*
>>>           * Conditions under which we can wait for the oom_killer.
>>>           * We have to be able to wait, but also, if we can't retry,
>>>           * we obviously shouldn't go mess with oom.
>>>           */
>>>          may_oom = (gfp & __GFP_WAIT) && !(gfp & __GFP_NORETRY);
>>
>> OK
>>
>>>
>>>>>>> +
>>>>>>> +	_memcg = memcg;
>>>>>>> +	ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
>>>>>>> +				      &_memcg, may_oom);
>>>>>>> +
>>>>>>> +	if (!ret) {
>>>>>>> +		ret = res_counter_charge(&memcg->kmem, size, &fail_res);
>>>>>>
>>>>>> Now that I'm thinking about the charging ordering we should charge the
>>>>>> kmem first because we would like to hit kmem limit before we hit u+k
>>>>>> limit, don't we.
>>>>>> Say that you have kmem limit 10M and the total limit 50M. Current `u'
>>>>>> would be 40M and this charge would cause kmem to hit the `k' limit. I
>>>>>> think we should fail to charge kmem before we go to u+k and potentially
>>>>>> reclaim/oom.
>>>>>> Or has this been alredy discussed and I just do not remember?
>>>>>>
>>>>> This has never been discussed as far as I remember. We charged u first
>>>>> since day0, and you are so far the first one to raise it...
>>>>>
>>>>> One of the things in favor of charging 'u' first is that
>>>>> mem_cgroup_try_charge is already equipped to make a lot of decisions,
>>>>> like when to allow reclaim, when to bypass charges, and it would be good
>>>>> if we can reuse all that.
>>>>
>>>> Hmm, I think that we should prevent from those decisions if kmem charge
>>>> would fail anyway (especially now when we do not have targeted slab
>>>> reclaim).
>>>>
>>>
>>> Let's revisit this discussion when we do have targeted reclaim. For now,
>>> I'll agree that charging kmem first would be acceptable.
>>>
>>> This will only make a difference when K < U anyway.
>>
>> Yes and it should work as advertised (aka hit the k limit first).
>>
> Just so we don't ping-pong in another submission:
>
> I changed memcontrol.h's memcg_kmem_newpage_charge to include:
>
>          /* If the test is dying, just let it go. */
>          if (unlikely(test_thread_flag(TIF_MEMDIE)
>                       || fatal_signal_pending(current)))
>                  return true;
>
>
> I'm also attaching the proposed code in memcontrol.c
>
> +static int memcg_charge_kmem(struct mem_cgroup *memcg, gfp_t gfp, u64 size)
> +{
> +	struct res_counter *fail_res;
> +	struct mem_cgroup *_memcg;
> +	int ret = 0;
> +	bool may_oom;
> +
> +	ret = res_counter_charge(&memcg->kmem, size, &fail_res);
> +	if (ret)
> +		return ret;
> +
> +	/*
> +	 * Conditions under which we can wait for the oom_killer.
> +	 * We have to be able to wait, but also, if we can't retry,
> +	 * we obviously shouldn't go mess with oom.
> +	 */
> +	may_oom = (gfp & __GFP_WAIT) && !(gfp & __GFP_NORETRY);
> +
> +	_memcg = memcg;
> +	ret = __mem_cgroup_try_charge(NULL, gfp, size >> PAGE_SHIFT,
> +				      &_memcg, may_oom);
> +
> +	if (ret == -EINTR)  {
> +		/*
> +		 * __mem_cgroup_try_charge() chosed to bypass to root due to
> +		 * OOM kill or fatal signal.  Since our only options are to
> +		 * either fail the allocation or charge it to this cgroup, do
> +		 * it as a temporary condition. But we can't fail. From a
> +		 * kmem/slab perspective, the cache has already been selected,
> +		 * by mem_cgroup_get_kmem_cache(), so it is too late to change
> +		 * our minds. This condition will only trigger if the task
> +		 * entered memcg_charge_kmem in a sane state, but was
> +		 * OOM-killed.  during __mem_cgroup_try_charge. Tasks that are
> +		 * already dying when the allocation triggers should have been
> +		 * already directed to the root cgroup.
> +		 */
> +		res_counter_charge_nofail(&memcg->res, size, &fail_res);
> +		if (do_swap_account)
> +			res_counter_charge_nofail(&memcg->memsw, size,
> +						  &fail_res);
> +		ret = 0;
> +	} else if (ret)
> +		res_counter_uncharge(&memcg->kmem, size);
> +
> +	return ret;
> +}

seems ok to me. but we'll need a patch to hide the usage > limit situation from
users.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
