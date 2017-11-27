Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5B06B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 12:27:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id n13so4741455wmc.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 09:27:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 5si3001178edk.337.2017.11.27.09.27.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 09:27:15 -0800 (PST)
Subject: Re: [PATCH v3 3/3] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1510882624-44342-1-git-send-email-xieyisheng1@huawei.com>
 <1510882624-44342-4-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ea6e56d5-ede6-580e-ed2d-c1ab975f5d91@suse.cz>
Date: Mon, 27 Nov 2017 18:25:48 +0100
MIME-Version: 1.0
In-Reply-To: <1510882624-44342-4-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu, ak@linux.intel.com, cl@linux.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, tanxiaojun@huawei.com

On 11/17/2017 02:37 AM, Yisheng Xie wrote:
> As manpage of migrate_pages, the errno should be set to EINVAL when
> none of the node IDs specified by new_nodes are on-line and allowed
> by the process's current cpuset context, or none of the specified
> nodes contain memory. However, when test by following case:
> 
> 	new_nodes = 0;
> 	old_nodes = 0xf;
> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
> 
> The ret will be 0 and no errno is set. As the new_nodes is empty,
> we should expect EINVAL as documented.
> 
> To fix the case like above, this patch check whether target nodes
> AND current task_nodes is empty, and then check whether AND
> node_states[N_MEMORY] is empty.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/mempolicy.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 65df28d..f604b22 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1433,10 +1433,14 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
>  		goto out_put;
>  	}

Let me add the whole preceding that ends on the lines above:

        task_nodes = cpuset_mems_allowed(task);
        /* Is the user allowed to access the target nodes? */
        if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
                err = -EPERM;
                goto out_put;
        }

>  
> -	if (!nodes_subset(*new, node_states[N_MEMORY])) {
> -		err = -EINVAL;
> +	task_nodes = cpuset_mems_allowed(current);
> +	nodes_and(*new, *new, task_nodes);
> +	if (nodes_empty(*new))
> +		goto out_put;

So if we have CAP_SYS_NICE, we pass (or rather skip) the EPERM check
above, but the current cpuset restriction still applies regardless. This
doesn't make sense to me? If I get Christoph right in the v2 discussion,
then CAP_SYS_NICE should not allow current cpuset escape. In that case,
we should remove the CAP_SYS_NICE check from the EPERM check? Also
should it be a subset check, or a non-empty-intersection check?

Note there's still a danger that we are breaking existing code so this
will have to be reverted in any case...

> +
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
