Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CCC506B004F
	for <linux-mm@kvack.org>; Mon, 13 Jul 2009 21:01:55 -0400 (EDT)
Message-ID: <4A5BDF5D.8090306@embeddedalley.com>
Date: Mon, 13 Jul 2009 18:29:01 -0700
From: "Vladislav D. Buzov" <vbuzov@embeddedalley.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] Resource usage threshold notification addition to
 res_counter (v3)
References: <1246998310-16764-1-git-send-email-vbuzov@embeddedalley.com>	<1247530581-31416-1-git-send-email-vbuzov@embeddedalley.com>	<1247530581-31416-2-git-send-email-vbuzov@embeddedalley.com> <20090714093022.6e8c1cc0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090714093022.6e8c1cc0.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers Mailing List <containers@lists.linux-foundation.org>, Linux memory management list <linux-mm@kvack.org>, Dan Malek <dan@embeddedalley.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Mon, 13 Jul 2009 17:16:20 -0700
> Vladislav Buzov <vbuzov@embeddedalley.com> wrote:
>
>   
>> This patch updates the Resource Counter to add a configurable resource usage
>> threshold notification mechanism.
>>
>> Signed-off-by: Vladislav Buzov <vbuzov@embeddedalley.com>
>> Signed-off-by: Dan Malek <dan@embeddedalley.com>
>> ---
>>  Documentation/cgroups/resource_counter.txt |   21 ++++++++-
>>  include/linux/res_counter.h                |   69 ++++++++++++++++++++++++++++
>>  kernel/res_counter.c                       |    7 +++
>>  3 files changed, 95 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/cgroups/resource_counter.txt b/Documentation/cgroups/resource_counter.txt
>> index 95b24d7..1369dff 100644
>> --- a/Documentation/cgroups/resource_counter.txt
>> +++ b/Documentation/cgroups/resource_counter.txt
>> @@ -39,7 +39,20 @@ to work with it.
>>   	The failcnt stands for "failures counter". This is the number of
>>  	resource allocation attempts that failed.
>>  
>> - c. spinlock_t lock
>> + e. unsigned long long threshold
>> +
>> + 	The resource usage threshold to notify the resouce controller. This is
>> +	the minimal difference between the resource limit and current usage
>> +	to fire a notification.
>> +
>> + f. void (*threshold_notifier)(struct res_counter *counter)
>> +
>> +	The threshold notification callback installed by the resource
>> +	controller. Called when the usage reaches or exceeds the threshold.
>> +	Should be fast and not sleep because called when interrupts are
>> +	disabled.
>> +
>>     
>
> This interface isn't very useful..hard to use..can't you just return the result as
> "exceeds threshold" to the callers ?
>
> If I was you, I'll add following state to res_counter
>
> enum {
> 	RES_BELOW_THRESH,
> 	RES_OVER_THRESH,
> } res_state;
>
> struct res_counter {
> 	.....
> 	enum	res_state	state;
> }
>
> Then, caller does
> example)
> 	prev_state = res->state;
> 	res_counter_charge(res....)
> 	if (prev_state != res->state)
> 		do_xxxxx..
>
> notifier under spinlock is not usual interface. And if this is "notifier",
> something generic, notifier_call_chain should be used rather than original
> one, IIUC.
>
> So, avoiding to use "callback" is a way to go, I think.
>
>   
The reason of having this callback is to support the hierarchy, which
was the problem in previous implementation you pointed out.

When a new page charged we want to walk up the hierarchy and find all
the ancestors exceeding their thresholds and notify them. To avoid
walking up the hierarchy twice, I've expanded res_counter with "notifier
callback" called by res_counter_charge() for each res_counter in the
tree which exceeds the limit.

In the example above, the hierarchy is not supported. We know only state
of the res_counter/memcg which current thread belongs to.

Thanks,
Vlad.

> Thanks,
> -Kame
>
>
>
>
>   
>> + g. spinlock_t lock
>>  
>>   	Protects changes of the above values.
>>  
>> @@ -140,6 +153,7 @@ counter fields. They are recommended to adhere to the following rules:
>>  	usage		usage_in_<unit_of_measurement>
>>  	max_usage	max_usage_in_<unit_of_measurement>
>>  	limit		limit_in_<unit_of_measurement>
>> +	threshold	notify_threshold_in_<unit_of_measurement>
>>  	failcnt		failcnt
>>  	lock		no file :)
>>  
>> @@ -153,9 +167,12 @@ counter fields. They are recommended to adhere to the following rules:
>>  	usage		prohibited
>>  	max_usage	reset to usage
>>  	limit		set the limit
>> +	threshold	set the threshold
>>  	failcnt		reset to zero
>>  
>> -
>> + d. Notification is enabled by installing the threshold notifier callback. It
>> +    is up to the resouce controller to communicate the notification to user
>> +    space tasks.
>>  
>>  5. Usage example
>>  
>> diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
>> index 511f42f..5ec98d7 100644
>> --- a/include/linux/res_counter.h
>> +++ b/include/linux/res_counter.h
>> @@ -9,6 +9,11 @@
>>   *
>>   * Author: Pavel Emelianov <xemul@openvz.org>
>>   *
>> + * Resouce usage threshold notification update
>> + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
>> + * Author: Dan Malek <dan@embeddedalley.com>
>> + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
>> + *
>>   * See Documentation/cgroups/resource_counter.txt for more
>>   * info about what this counter is.
>>   */
>> @@ -35,6 +40,19 @@ struct res_counter {
>>  	 */
>>  	unsigned long long limit;
>>  	/*
>> +	 * the resource usage threshold to notify the resouce controller. This
>> +	 * is the minimal difference between the resource limit and current
>> +	 * usage to fire a notification.
>> +	 */
>> +	unsigned long long threshold;
>> +	/*
>> +	 * the threshold notification callback installed by the resource
>> +	 * controller. Called when the usage reaches or exceeds the threshold.
>> +	 * Should be fast and not sleep because called when interrupts are
>> +	 * disabled.
>> +	 */
>> +	void (*threshold_notifier)(struct res_counter *counter);
>> +	/*
>>  	 * the number of unsuccessful attempts to consume the resource
>>  	 */
>>  	unsigned long long failcnt;
>> @@ -87,6 +105,7 @@ enum {
>>  	RES_MAX_USAGE,
>>  	RES_LIMIT,
>>  	RES_FAILCNT,
>> +	RES_THRESHOLD,
>>  };
>>  
>>  /*
>> @@ -132,6 +151,21 @@ static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
>>  	return false;
>>  }
>>  
>> +static inline bool res_counter_threshold_check_locked(struct res_counter *cnt)
>> +{
>> +	if (cnt->usage + cnt->threshold < cnt->limit)
>> +		return true;
>> +
>> +	return false;
>> +}
>> +
>> +static inline void res_counter_threshold_notify_locked(struct res_counter *cnt)
>> +{
>> +	if (!res_counter_threshold_check_locked(cnt) &&
>> +	    cnt->threshold_notifier)
>> +		cnt->threshold_notifier(cnt);
>> +}
>> +
>>  /*
>>   * Helper function to detect if the cgroup is within it's limit or
>>   * not. It's currently called from cgroup_rss_prepare()
>> @@ -147,6 +181,21 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
>>  	return ret;
>>  }
>>  
>> +/*
>> + * Helper function to detect if the cgroup usage is under it's threshold or
>> + * not.
>> + */
>> +static inline bool res_counter_check_under_threshold(struct res_counter *cnt)
>> +{
>> +	bool ret;
>> +	unsigned long flags;
>> +
>> +	spin_lock_irqsave(&cnt->lock, flags);
>> +	ret = res_counter_threshold_check_locked(cnt);
>> +	spin_unlock_irqrestore(&cnt->lock, flags);
>> +	return ret;
>> +}
>> +
>>  static inline void res_counter_reset_max(struct res_counter *cnt)
>>  {
>>  	unsigned long flags;
>> @@ -174,6 +223,26 @@ static inline int res_counter_set_limit(struct res_counter *cnt,
>>  	spin_lock_irqsave(&cnt->lock, flags);
>>  	if (cnt->usage <= limit) {
>>  		cnt->limit = limit;
>> +		if (limit <= cnt->threshold)
>> +			cnt->threshold = 0;
>> +		else
>> +			res_counter_threshold_notify_locked(cnt);
>> +		ret = 0;
>> +	}
>> +	spin_unlock_irqrestore(&cnt->lock, flags);
>> +	return ret;
>> +}
>> +
>> +static inline int res_counter_set_threshold(struct res_counter *cnt,
>> +		unsigned long long threshold)
>> +{
>> +	unsigned long flags;
>> +	int ret = -EINVAL;
>> +
>> +	spin_lock_irqsave(&cnt->lock, flags);
>> +	if (cnt->limit > threshold) {
>> +		cnt->threshold = threshold;
>> +		res_counter_threshold_notify_locked(cnt);
>>  		ret = 0;
>>  	}
>>  	spin_unlock_irqrestore(&cnt->lock, flags);
>> diff --git a/kernel/res_counter.c b/kernel/res_counter.c
>> index e1338f0..9b36748 100644
>> --- a/kernel/res_counter.c
>> +++ b/kernel/res_counter.c
>> @@ -5,6 +5,10 @@
>>   *
>>   * Author: Pavel Emelianov <xemul@openvz.org>
>>   *
>> + * Resouce usage threshold notification update
>> + * Copyright 2009 CE Linux Forum and Embedded Alley Solutions, Inc.
>> + * Author: Dan Malek <dan@embeddedalley.com>
>> + * Author: Vladislav Buzov <vbuzov@embeddedalley.com>
>>   */
>>  
>>  #include <linux/types.h>
>> @@ -32,6 +36,7 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
>>  	counter->usage += val;
>>  	if (counter->usage > counter->max_usage)
>>  		counter->max_usage = counter->usage;
>> +	res_counter_threshold_notify_locked(counter);
>>  	return 0;
>>  }
>>  
>> @@ -101,6 +106,8 @@ res_counter_member(struct res_counter *counter, int member)
>>  		return &counter->limit;
>>  	case RES_FAILCNT:
>>  		return &counter->failcnt;
>> +	case RES_THRESHOLD:
>> +		return &counter->threshold;
>>  	};
>>  
>>  	BUG();
>> -- 
>> 1.5.6.3
>>
>>
>>     
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
