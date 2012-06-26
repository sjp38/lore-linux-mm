Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 771346B0095
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 10:32:35 -0400 (EDT)
Message-ID: <4FE9C75D.1070907@parallels.com>
Date: Tue, 26 Jun 2012 18:29:49 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: first step towards hierarchical controller
References: <1340717428-9009-1-git-send-email-glommer@parallels.com> <20120626141127.GA27816@cmpxchg.org>
In-Reply-To: <20120626141127.GA27816@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On 06/26/2012 06:11 PM, Johannes Weiner wrote:
> On Tue, Jun 26, 2012 at 05:30:28PM +0400, Glauber Costa wrote:
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
>
> Agreed, this is a much better first step than the global switch.
>
> Nitpicks:
>
> Should the warning be emitted for any memcg, not just the parent?

It doesn't matter. Only the parent can be set to 0. It is impossible to 
set the others to 0 if the parent is set to 1 (only vice-versa)

> If
> somebody takes notice of the changed semantics, it's better to print
> the warning on the first try to disable hierarchies instead of holding
> back until they walk up the tree and try to change it in the root.

That is precisely what is done here. Again, since you can only 
effectively change in the root, that will be equivalent to first try.

> Still forbid disabling at lower levels, just be more eager to inform
> the people trying it.
>
> The memcg->use_hierarchy check should not be needed as you make sure
> it's different from val, so checking val == false should suffice?

Yes, you are right here.

> Also, why the extra parens around the condition?

I will remove them.

> I find the warning message a bit terse.  Maybe include something like
> "restructure the cgroup directory structure to match your accounting
> requirements or complain to (linux-mm, cgroups list etc.)  if not
> possible"

Since I was expecting a "get out of here, you moron!" kind of reception,
I didn't worried too much about the message =p

I do agree that pointing to a mailing list address is a good thing to do.

>> @@ -5175,6 +5177,7 @@ mem_cgroup_create(struct cgroup *cont)
>>   			INIT_WORK(&stock->work, drain_local_stock);
>>   		}
>>   		hotcpu_notifier(memcg_cpu_hotplug_callback, 0);
>> +		memcg->use_hierarchy = true;
>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>
> Let's try this.  We have crappy semantics all over the place and no
> evidence, only fear, that someone may rely on them.

beautiful words.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
