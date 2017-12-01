Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 925466B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:20:11 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so6008678wrc.20
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:20:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u26si1069399eda.521.2017.12.01.07.20.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 07:20:10 -0800 (PST)
Subject: Re: [PATCH v4 3/3] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1512122128-6220-1-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <305e9b37-0e58-a53d-55b7-f0815c1ba64f@suse.cz>
Date: Fri, 1 Dec 2017 16:18:42 +0100
MIME-Version: 1.0
In-Reply-To: <1512122128-6220-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Chris Salls <salls@cs.ucsb.edu>, Christopher Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tan Xiaojun <tanxiaojun@huawei.com>

On 12/01/2017 10:55 AM, Yisheng Xie wrote:
> As in manpage of migrate_pages, the errno should be set to EINVAL when
> none of the node IDs specified by new_nodes are on-line and allowed by the
> process's current cpuset context, or none of the specified nodes contain
> memory.  However, when test by following case:
> 
> 	new_nodes = 0;
> 	old_nodes = 0xf;
> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
> 
> The ret will be 0 and no errno is set.  As the new_nodes is empty, we
> should expect EINVAL as documented.
> 
> To fix the case like above, this patch check whether target nodes AND
> current task_nodes is empty, and then check whether AND
> node_states[N_MEMORY] is empty.
> 
> Meanwhile,this patch also remove the check of EPERM on CAP_SYS_NICE. 
> The caller of migrate_pages should be able to migrate the target process
> pages anywhere the caller can allocate memory, if the caller can access
> the mm_struct.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Chris Salls <salls@cs.ucsb.edu>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Tan Xiaojun <tanxiaojun@huawei.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> ---
> v3:
>  * check whether node is empty after AND current task node, and then nodes
>    which have memory
> v4:
>  * remove the check of EPERM on CAP_SYS_NICE.
> 
> Hi Vlastimil and Christopher,
> 
> Could you please help to review this version?

Hi, I think we should stay with v3 after all. What I missed when
reviewing it, is that the EPERM check is for cpuset_mems_allowed(task)
and in v3 you add EINVAL check for cpuset_mems_allowed(current), which
may not be the same, and the intention of CAP_SYS_NICE is not whether we
can bypass our own cpuset, but whether we can bypass the target task's
cpuset. Sorry for the confusion.

> Thanks
> Yisheng Xie
> 
>  mm/mempolicy.c | 13 +++++--------
>  1 file changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 65df28d..4da74b6 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1426,17 +1426,14 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
>  	}
>  	rcu_read_unlock();
>  
> -	task_nodes = cpuset_mems_allowed(task);
> -	/* Is the user allowed to access the target nodes? */
> -	if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
> -		err = -EPERM;
> +	task_nodes = cpuset_mems_allowed(current);
> +	nodes_and(*new, *new, task_nodes);
> +	if (nodes_empty(*new))
>  		goto out_put;
> -	}
>  
> -	if (!nodes_subset(*new, node_states[N_MEMORY])) {
> -		err = -EINVAL;
> +	nodes_and(*new, *new, node_states[N_MEMORY]);
> +	if (nodes_empty(*new))
>  		goto out_put;
> -	}
>  
>  	err = security_task_movememory(task);
>  	if (err)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
