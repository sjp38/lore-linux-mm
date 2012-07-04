Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A2B086B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 05:32:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C86303EE0AE
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 18:32:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0889745DE54
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 18:32:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D971345DE4D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 18:32:38 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C77D0E08001
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 18:32:38 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6EC5B1DB803B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 18:32:38 +0900 (JST)
Message-ID: <4FF40D33.4030704@jp.fujitsu.com>
Date: Wed, 04 Jul 2012 18:30:27 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] memcg: add res_counter_usage_safe()
References: <4FF3B0DC.5090508@jp.fujitsu.com> <20120704091428.GB7881@cmpxchg.org>
In-Reply-To: <20120704091428.GB7881@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>

(2012/07/04 18:14), Johannes Weiner wrote:
> On Wed, Jul 04, 2012 at 11:56:28AM +0900, Kamezawa Hiroyuki wrote:
>> I think usage > limit means a sign of BUG. But, sometimes,
>> res_counter_charge_nofail() is very convenient. tcp_memcg uses it.
>> And I'd like to use it for helping page migration.
>>
>> This patch adds res_counter_usage_safe() which returns min(usage,limit).
>> By this we can use res_counter_charge_nofail() without breaking
>> user experience.
>>
>> Changelog:
>>   - read res_counter directrly under lock.
>>   - fixed comment.
>>
>> Acked-by: Glauber Costa <glommer@parallels.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>>   include/linux/res_counter.h |    2 ++
>>   kernel/res_counter.c        |   18 ++++++++++++++++++
>>   net/ipv4/tcp_memcontrol.c   |    2 +-
>>   3 files changed, 21 insertions(+), 1 deletions(-)
>>
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index 7d7fbe2..a6f8cc5 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -226,4 +226,6 @@ res_counter_set_soft_limit(struct res_counter *cnt,
>>   	return 0;
>>   }
>>
>> +u64 res_counter_usage_safe(struct res_counter *cnt);
>> +
>>   #endif
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index ad581aa..f0507cd 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -171,6 +171,24 @@ u64 res_counter_read_u64(struct res_counter *counter, int member)
>>   }
>>   #endif
>>
>> +/*
>> + * Returns usage. If usage > limit, limit is returned.
>> + * This is useful not to break user experiance if the excess
>> + * is temporary.
>> + */
>> +u64 res_counter_usage_safe(struct res_counter *counter)
>> +{
>> +	unsigned long flags;
>> +	u64 usage, limit;
>> +
>> +	spin_lock_irqsave(&counter->lock, flags);
>> +	limit = counter->limit;
>> +	usage = counter->usage;
>> +	spin_unlock_irqrestore(&counter->lock, flags);
>> +
>> +	return min(usage, limit);
>> +}
>> +
>>   int res_counter_memparse_write_strategy(const char *buf,
>>   					unsigned long long *res)
>>   {
>> diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
>> index b6f3583..a73dce6 100644
>> --- a/net/ipv4/tcp_memcontrol.c
>> +++ b/net/ipv4/tcp_memcontrol.c
>> @@ -180,7 +180,7 @@ static u64 tcp_read_usage(struct mem_cgroup *memcg)
>>   		return atomic_long_read(&tcp_memory_allocated) << PAGE_SHIFT;
>>
>>   	tcp = tcp_from_cgproto(cg_proto);
>> -	return res_counter_read_u64(&tcp->tcp_memory_allocated, RES_USAGE);
>> +	return res_counter_usage_safe(&tcp->tcp_memory_allocated);
>>   }
>
> Hm, it depends on what you consider more important.
>
> Personally, I think it's more useful to report the truth rather than
> pretending we'd enforce an invariant that we actually don't.  And I
> think it can just be documented that we have to charge memory over the
> limit in certain contexts, so people/scripts should expect usage to
> exceed the limit.
>

I think asking applications to handle usage > limit case will cause
trouble and we can keep simple interface by lying here. And,
applications doesn't need to handle this case.

 From the viewpoint of our enterprise service, it's better to keep
usage <= limit for avoiding unnecessary, unimportant, troubles.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
