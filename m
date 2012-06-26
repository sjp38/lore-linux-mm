Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 26B836B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:30:49 -0400 (EDT)
Message-ID: <4FE9D501.3050004@parallels.com>
Date: Tue, 26 Jun 2012 19:28:01 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
References: <1340717428-9009-1-git-send-email-glommer@parallels.com> <20120626152711.GF9566@tiehlicka.suse.cz>
In-Reply-To: <20120626152711.GF9566@tiehlicka.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 06/26/2012 07:27 PM, Michal Hocko wrote:
> On Tue 26-06-12 17:30:28, Glauber Costa wrote:
>> Okay, so after recent discussions, I am proposing the following
>> patch. It won't remove hierarchy, or anything like that. Just default
>> to true in the root cgroup, and print a warning once if you try
>> to set it back to 0.
>>
>> I am not adding it to feature-removal-schedule.txt because I don't
>> view it as a consensus. Rather, changing the default would allow us
>> to give it a time around in the open, and see if people complain
>> and what we can learn about that.
>>
>> Signed-off-by: Glauber Costa <glommer@parallels.com>
>> CC: Michal Hocko <mhocko@suse.cz>
>> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> CC: Johannes Weiner <hannes@cmpxchg.org>
>> CC: Tejun Heo <tj@kernel.org>
>> ---
>>   mm/memcontrol.c |    3 +++
>>   1 file changed, 3 insertions(+)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 9e710bc..037ddd4 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3949,6 +3949,8 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>>   	if (memcg->use_hierarchy == val)
>>   		goto out;
>>
>> +	WARN_ONCE((!parent_memcg && memcg->use_hierarchy && val == false),
>> +		"Non-hierarchical memcg is considered for deprecation");
>>   	/*
>>   	 * If parent's use_hierarchy is set, we can't make any modifications
>>   	 * in the child subtrees. If it is unset, then the change can
>> @@ -5175,6 +5177,7 @@ mem_cgroup_create(struct cgroup *cont)
>>   			INIT_WORK(&stock->work, drain_local_stock);
>>   		}
>>   		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>> +		memcg->use_hierarchy = true;
>
> So the only way to disable hierarchies is to do it on the root first
> (before any children exist) and then start creating your groups?

Yes.

This is true after my patch.
This is also true before my patch, if you set it to 1 in the root, and 
then tries to flip it back.

> I think it will be much safer if we could enable it to the first floor
> under the root - I know hackish - but I guess that most users don't set
> anything in the root cgroup (most of the time it's EINVAL anyway) and
> only set up groups they are creating.

Well, I think it is fair to say that the reasonable expectation of this,
is that they will still not set anything, and still things will work
(we are assuming very few people actually care about this)

So I don't see a reason for it.
> Anyway, I guess we can give this approach a try.
>
>>   	} else {
>>   		parent = mem_cgroup_from_cont(cont->parent);
>>   		memcg->use_hierarchy = parent->use_hierarchy;
>
> Thanks
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
