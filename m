Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0809F6B0038
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 20:32:31 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id s144so8924115oih.5
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 17:32:31 -0800 (PST)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTP id s11si4904795oth.307.2017.11.05.17.32.29
        for <linux-mm@kvack.org>;
        Sun, 05 Nov 2017 17:32:29 -0800 (PST)
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
 <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <bc57f574-92f2-0b69-4717-a1ec7170387c@huawei.com>
Date: Mon, 6 Nov 2017 09:31:44 +0800
MIME-Version: 1.0
In-Reply-To: <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>

Hi Vlastimil,

On 2017/10/31 17:46, Vlastimil Babka wrote:
> +CC Andi and Christoph
> 
> On 10/27/2017 12:14 PM, Yisheng Xie wrote:
>> As manpage of migrate_pages, the errno should be set to EINVAL when none
>> of the specified nodes contain memory. However, when new_nodes is null,
>> i.e. the specified nodes also do not have memory, as the following case:
>>
>> 	new_nodes = 0;
>> 	old_nodes = 0xf;
>> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
>>
>> The ret will be 0 and no errno is set.
>>
>> This patch is to add nodes_empty check to fix above case.
> 
> Hmm, I think we have a bigger problem than "empty set is a subset of
> anything" here.
> 
> The existing checks are:
> 
>         task_nodes = cpuset_mems_allowed(task);
>         if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
>                 err = -EPERM;
>                 goto out_put;
>         }
> 
>         if (!nodes_subset(*new, node_states[N_MEMORY])) {
>                 err = -EINVAL;
>                 goto out_put;
>         }
> 
> 
> And manpage says:
> 
>        EINVAL The value specified by maxnode exceeds a kernel-imposed
> limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
> are greater than the maximum supported node
>               ID.  *Or, none of the node IDs specified by new_nodes are
> on-line and allowed by the process's current cpuset context, or none of
> the specified nodes contain memory.*
> 
>        EPERM  Insufficient privilege (CAP_SYS_NICE) to move pages of the
> process specified by pid, or insufficient privilege (CAP_SYS_NICE) to
> access the specified target nodes.
> 
> - it says "none ... are allowed", but checking for subset means we check
> if "all ... are allowed". Shouldn't we be checking for a non-empty
> intersection?

You are absolutely right. To follow the manpage, we should check non-empty
of intersection instead of subset. I meani 1/4 ?
         nodes_and(*new, *new, task_nodes);
         if (!node_empty(*new) && !capable(CAP_SYS_NICE)) {
                 err = -EPERM;
                 goto out_put;
         }

         nodes_and(*new, *new, node_states[N_MEMORY]);
         if (!node_empty(*new)) {
                 err = -EINVAL;
                 goto out_put;
         }

So finally, we should only migrate the smallest intersection of all the node
set, right?

> - there doesn't seem to be any EINVAL check for "process's current
> cpuset context", there's just an EPERM check for "target process's
> cpuset context".

This also need to be checked as manpage.

Thanks
Yisheng Xie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
