Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 8C6946B0006
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 05:51:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 953273EE0C1
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:51:23 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75A1F45DE4E
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:51:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A30F45DE4F
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:51:23 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BBDF1DB8037
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:51:23 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CE1E31DB803B
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 19:51:22 +0900 (JST)
Message-ID: <51371F92.5060206@jp.fujitsu.com>
Date: Wed, 06 Mar 2013 19:50:58 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
References: <1362489058-3455-1-git-send-email-glommer@parallels.com> <1362489058-3455-3-git-send-email-glommer@parallels.com> <51368D80.20701@jp.fujitsu.com> <5136FEC2.2050004@parallels.com>
In-Reply-To: <5136FEC2.2050004@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

(2013/03/06 17:30), Glauber Costa wrote:
> On 03/06/2013 04:27 AM, Kamezawa Hiroyuki wrote:
>> (2013/03/05 22:10), Glauber Costa wrote:
>>> For the root memcg, there is no need to rely on the res_counters if hierarchy
>>> is enabled The sum of all mem cgroups plus the tasks in root itself, is
>>> necessarily the amount of memory used for the whole system. Since those figures
>>> are already kept somewhere anyway, we can just return them here, without too
>>> much hassle.
>>>
>>> Limit and soft limit can't be set for the root cgroup, so they are left at
>>> RESOURCE_MAX. Failcnt is left at 0, because its actual meaning is how many
>>> times we failed allocations due to the limit being hit. We will fail
>>> allocations in the root cgroup, but the limit will never the reason.
>>>
>>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>>> CC: Michal Hocko <mhocko@suse.cz>
>>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> CC: Johannes Weiner <hannes@cmpxchg.org>
>>> CC: Mel Gorman <mgorman@suse.de>
>>> CC: Andrew Morton <akpm@linux-foundation.org>
>>
>> I think this patch's calculation is wrong.
>>
> where exactly ?
> 
>>> ---
>>>    mm/memcontrol.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 64 insertions(+)
>>>
>>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>> index b8b363f..bfbf1c2 100644
>>> --- a/mm/memcontrol.c
>>> +++ b/mm/memcontrol.c
>>> @@ -4996,6 +4996,56 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>>>    	return val << PAGE_SHIFT;
>>>    }
>>>    
>>> +static u64 memcg_read_root_rss(void)
>>> +{
>>> +	struct task_struct *p;
>>> +
>>> +	u64 rss = 0;
>>> +	read_lock(&tasklist_lock);
>>> +	for_each_process(p) {
>>> +		if (!p->mm)
>>> +			continue;
>>> +		task_lock(p);
>>> +		rss += get_mm_rss(p->mm);
>>> +		task_unlock(p);
>>> +	}
>>> +	read_unlock(&tasklist_lock);
>>> +	return rss;
>>> +}
>>
>> I think you can use rcu_read_lock() instead of tasklist_lock.
>> Isn't it enough to use NR_ANON_LRU rather than this ?
> 
> Is it really just ANON_LRU ? get_mm_rss also include filepages, which
> are not in this list.

And mlocked ones counted as Unevictable
> 
> Maybe if we sum up *all* LRUs we would get the right result ?
> 
_MEM...i.e. ...usage_in_bytes is the sum of all LRUs.

> About the tasklist lock, if I get values from the LRUs, maybe. Otherwise
> it is still necessary, no ?

tasklist is RCU list and we don't need locking at reading values, I think.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
