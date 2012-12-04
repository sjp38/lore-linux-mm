Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0B8D46B005D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 02:49:21 -0500 (EST)
Message-ID: <50BDAAFA.2010708@parallels.com>
Date: Tue, 4 Dec 2012 11:49:14 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] memcg: replace cgroup_lock with memcg specific memcg_lock
References: <1354282286-32278-1-git-send-email-glommer@parallels.com> <1354282286-32278-5-git-send-email-glommer@parallels.com> <20121203171532.GG17093@dhcp22.suse.cz> <20121203173002.GH17093@dhcp22.suse.cz>
In-Reply-To: <20121203173002.GH17093@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>

On 12/03/2012 09:30 PM, Michal Hocko wrote:
> On Mon 03-12-12 18:15:32, Michal Hocko wrote:
> [...]
>>> @@ -3915,7 +3926,7 @@ static int mem_cgroup_hierarchy_write(struct cgroup *cont, struct cftype *cft,
>>>  	 */
>>>  	if ((!parent_memcg || !parent_memcg->use_hierarchy) &&
>>>  				(val == 1 || val == 0)) {
>>> -		if (list_empty(&cont->children))
>>> +		if (!memcg_has_children(memcg))
>>>  			memcg->use_hierarchy = val;
>>>  		else
>>>  			retval = -EBUSY;
>>
>> Nothing prevents from a race when a task is on the way to be attached to
>> the group. This means that we might miss some charges up the way to the
>> parent.
>>
>> mem_cgroup_hierarchy_write
>>   					cgroup_attach_task
>> 					  ss->can_attach() = mem_cgroup_can_attach
>> 					    mutex_lock(&memcg_lock)
>> 					    memcg->attach_in_progress++
>> 					    mutex_unlock(&memcg_lock)
>> 					    __mem_cgroup_can_attach
>> 					      mem_cgroup_precharge_mc (*)
>>   mutex_lock(memcg_lock)
>>   memcg_has_children(memcg)==false
> 
> Dohh, retard alert. I obviously mixed tasks and children cgroups here.
> Why I thought we also do check for no tasks in the group? Ahh, because
> we should, at least here otherwise parent could see more uncharges than
> charges.
> But that deserves a separate patch. Sorry, for the confusion.

That is okay, here is a beer for you: http://bit.ly/R3rkML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
