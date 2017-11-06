Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 570A26B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 02:39:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y83so2311239wmc.8
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 23:39:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b17si1511753edj.328.2017.11.05.23.39.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Nov 2017 23:39:09 -0800 (PST)
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
 <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
 <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d774ecf6-5e7b-e185-85a0-27bf2bcacfb4@suse.cz>
Date: Mon, 6 Nov 2017 08:39:06 +0100
MIME-Version: 1.0
In-Reply-To: <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>

On 11/06/2017 02:31 AM, Yisheng Xie wrote:
> Hi Vlastimil,
> 
> On 2017/10/31 17:46, Vlastimil Babka wrote:
>> +CC Andi and Christoph
>>
>> On 10/27/2017 12:14 PM, Yisheng Xie wrote:
>>> As manpage of migrate_pages, the errno should be set to EINVAL when none
>>> of the specified nodes contain memory. However, when new_nodes is null,
>>> i.e. the specified nodes also do not have memory, as the following case:
>>>
>>> 	new_nodes = 0;
>>> 	old_nodes = 0xf;
>>> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
>>>
>>> The ret will be 0 and no errno is set.
>>>
>>> This patch is to add nodes_empty check to fix above case.
>>
>> Hmm, I think we have a bigger problem than "empty set is a subset of
>> anything" here.
>>
>> The existing checks are:
>>
>>         task_nodes = cpuset_mems_allowed(task);
>>         if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
>>                 err = -EPERM;
>>                 goto out_put;
>>         }
>>
>>         if (!nodes_subset(*new, node_states[N_MEMORY])) {
>>                 err = -EINVAL;
>>                 goto out_put;
>>         }
>>
>>
>> And manpage says:
>>
>>        EINVAL The value specified by maxnode exceeds a kernel-imposed
>> limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
>> are greater than the maximum supported node
>>               ID.  *Or, none of the node IDs specified by new_nodes are
>> on-line and allowed by the process's current cpuset context, or none of
>> the specified nodes contain memory.*
>>
>>        EPERM  Insufficient privilege (CAP_SYS_NICE) to move pages of the
>> process specified by pid, or insufficient privilege (CAP_SYS_NICE) to
>> access the specified target nodes.
>>
>> - it says "none ... are allowed", but checking for subset means we check
>> if "all ... are allowed". Shouldn't we be checking for a non-empty
>> intersection?
> 
> You are absolutely right. To follow the manpage, we should check non-empty
> of intersection instead of subset. I meani 1/4 ?
>          nodes_and(*new, *new, task_nodes);
>          if (!node_empty(*new) && !capable(CAP_SYS_NICE)) {
>                  err = -EPERM;
>                  goto out_put;
>          }
> 
>          nodes_and(*new, *new, node_states[N_MEMORY]);
>          if (!node_empty(*new)) {
>                  err = -EINVAL;
>                  goto out_put;
>          }

Maybe not exactly like this, see below.

> So finally, we should only migrate the smallest intersection of all the node
> set, right?

That's right.

So if new_nodes AND task_nodes AND node_states[N_MEMORY] is empty, then
EINVAL.

I'm not sure what exactly is the EPERM intention. Should really the
capability of THIS process override the cpuset restriction of the TARGET
process? Maybe yes. Then, does "insufficient privilege (CAP_SYS_NICE) to
access the specified target nodes." mean that at least some nodes must
be allowed, or all of them? Maybe the subset check is after all OK for
the EPERM check, but still wrong for the EINVAL check.

>> - there doesn't seem to be any EINVAL check for "process's current
>> cpuset context", there's just an EPERM check for "target process's
>> cpuset context".
> 
> This also need to be checked as manpage.
> 
> Thanks
> Yisheng Xie
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
