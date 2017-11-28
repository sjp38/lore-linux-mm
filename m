Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0DCC6B02B1
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 03:04:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z4so23697674pgo.7
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 00:04:25 -0800 (PST)
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id f9si18095449pgt.484.2017.11.28.00.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 00:04:24 -0800 (PST)
Subject: Re: [PATCH v3 3/3] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
 <1510882624-44342-4-git-send-email-xieyisheng1@huawei.com>
 <ea6e56d5-ede6-580e-ed2d-c1ab975f5d91@suse.cz>
 <43477914-445f-c1cd-afdb-94a23ba25baa@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <4f1ffa1e-9b1e-6268-d3b4-4e3812231b41@huawei.com>
Date: Tue, 28 Nov 2017 16:04:07 +0800
MIME-Version: 1.0
In-Reply-To: <43477914-445f-c1cd-afdb-94a23ba25baa@huawei.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com



On 2017/11/28 10:03, Yisheng Xie wrote:
> Hi Vlastimil,
> 
> Thanks for your comment!
> On 2017/11/28 1:25, Vlastimil Babka wrote:
>> On 11/17/2017 02:37 AM, Yisheng Xie wrote:
>>> As manpage of migrate_pages, the errno should be set to EINVAL when
>>> none of the node IDs specified by new_nodes are on-line and allowed
>>> by the process's current cpuset context, or none of the specified
>>> nodes contain memory. However, when test by following case:
>>>
>>> 	new_nodes = 0;
>>> 	old_nodes = 0xf;
>>> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
>>>
>>> The ret will be 0 and no errno is set. As the new_nodes is empty,
>>> we should expect EINVAL as documented.
>>>
>>> To fix the case like above, this patch check whether target nodes
>>> AND current task_nodes is empty, and then check whether AND
>>> node_states[N_MEMORY] is empty.
>>>
>>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>>> ---
>>>  mm/mempolicy.c | 10 +++++++---
>>>  1 file changed, 7 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>> index 65df28d..f604b22 100644
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -1433,10 +1433,14 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
>>>  		goto out_put;
>>>  	}
>>
>> Let me add the whole preceding that ends on the lines above:
>>
>>         task_nodes = cpuset_mems_allowed(task);
>>         /* Is the user allowed to access the target nodes? */
>>         if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
>>                 err = -EPERM;
>>                 goto out_put;
>>         }
>>
>>>  
>>> -	if (!nodes_subset(*new, node_states[N_MEMORY])) {
>>> -		err = -EINVAL;
>>> +	task_nodes = cpuset_mems_allowed(current);
>>> +	nodes_and(*new, *new, task_nodes);
>>> +	if (nodes_empty(*new))
>>> +		goto out_put;
>>
>> So if we have CAP_SYS_NICE, we pass (or rather skip) the EPERM check
>> above, but the current cpuset restriction still applies regardless. This
>> doesn't make sense to me? If I get Christoph right in the v2 discussion,
>> then CAP_SYS_NICE should not allow current cpuset escape. 
> hmm, maybe I do not get what you mean, the patch seems do not *escape* the
> current cpuset?  if CAP_SYS_NICE it also check current cpuset, right?
> 
>> In that case,
>> we should remove the CAP_SYS_NICE check from the EPERM check? Also
>> should it be a subset check, or a non-empty-intersection check?
> 
> So you mean:
> 1. we should remove the EPERM check above?
> 2. Not sure we should use subset check, or a non-empty-intersection for current cpuset?
> (Please let me know, if have other points.)
> 
> For 1: I have checked the manpage of capabilities[1]:
> CAP_SYS_NICE
> 	[...]
> 	*apply migrate_pages(2) to arbitrary processes* and allow
>         processes to be migrated to arbitrary nodes;
> 
> 	apply move_pages(2) to arbitrary processes;
> 	[...]
> 
> Therefore, IMO, EPERM check should be something like:
> 	if (currtent->mm != task->mm && !capable(CAP_SYS_NICE)) { // or if (currtent != task && !capable(CAP_SYS_NICE)) ?
> 		err = -EPERM;
> 		goto out_put;
> 	}
> And I kept it as unchanged to follow the original code's meaning.(For move_pages
> also use the the logical to check EPERM). I also did not want to break the existing code. :)

Please forget about move_pages part, it has different logical, I am just confused.
Sorry about that. Anyway, I means we should do some check about EPERM, maybe not
as original code, but can not just remove it.

> 
> For 2: we should follow the manpage of migrate_pages about EINVAL, as your listed in
> the former discussion:
> 	  EINVAL... Or, _none_ of the node IDs specified by new_nodes are
>  	 	on-line and allowed by the process's current cpuset context, or none of
>   		the specified nodes contain memory.
> 
> So a non-empty-intersection check for current cpuset should be enough, right?
> And Christoph seems do _not oppose_ this point. (I not sure whether he is *agree* or not).
> 
> [1] http://man7.org/linux/man-pages/man7/capabilities.7.html
>>
>> Note there's still a danger that we are breaking existing code so this
>> will have to be reverted in any case...
> 
> I am not oppose if you want to revert this patch, but we should find a
> correct way to fix the case above, right? Maybe anther version or a fix to fold?
> 
> Thanks
> Yisheng Xie
>>
>>> +
>>> +	nodes_and(*new, *new, node_states[N_MEMORY]);
>>> +	if (nodes_empty(*new))
>>>  		goto out_put;
>>> -	}
>>>  
>>>  	err = security_task_movememory(task);
>>>  	if (err)
>>>
>>
>>
>> .
>>
> 
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
