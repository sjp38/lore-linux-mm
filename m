Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFE3D6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 10:22:13 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o20so5880536wro.8
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 07:22:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f22si3809273eda.157.2017.12.01.07.22.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 07:22:12 -0800 (PST)
Subject: Re: [patch 04/15] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <5a2082fa.bXLNoQ4bvY4J0ImP%akpm@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <238af2fe-e8c2-5fe5-aa5b-1361e334058b@suse.cz>
Date: Fri, 1 Dec 2017 16:20:46 +0100
MIME-Version: 1.0
In-Reply-To: <5a2082fa.bXLNoQ4bvY4J0ImP%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org, xieyisheng1@huawei.com, ak@linux.intel.com, cl@linux.com, mingo@kernel.org, n-horiguchi@ah.jp.nec.com, rientjes@google.com, salls@cs.ucsb.edu, tanxiaojun@huawei.com

On 11/30/2017 11:15 PM, akpm@linux-foundation.org wrote:
> From: Yisheng Xie <xieyisheng1@huawei.com>
> Subject: mm/mempolicy: add nodes_empty check in SYSC_migrate_pages
> 
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
> Link: http://lkml.kernel.org/r/1510882624-44342-4-git-send-email-xieyisheng1@huawei.com
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> Cc: Andi Kleen <ak@linux.intel.com>
> Cc: Chris Salls <salls@cs.ucsb.edu>
> Cc: Christopher Lameter <cl@linux.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Tan Xiaojun <tanxiaojun@huawei.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

My previous concerns here were a mistake as I explained in my reply to
v4. So you can add

Acked-by: Vlastimil Babka <vbabka@suse.cz>

and proceed with the series. Thanks.

> ---
> 
>  mm/mempolicy.c |   10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff -puN mm/mempolicy.c~mm-mempolicy-add-nodes_empty-check-in-sysc_migrate_pages mm/mempolicy.c
> --- a/mm/mempolicy.c~mm-mempolicy-add-nodes_empty-check-in-sysc_migrate_pages
> +++ a/mm/mempolicy.c
> @@ -1433,10 +1433,14 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
>  		goto out_put;
>  	}
>  
> -	if (!nodes_subset(*new, node_states[N_MEMORY])) {
> -		err = -EINVAL;
> +	task_nodes = cpuset_mems_allowed(current);
> +	nodes_and(*new, *new, task_nodes);
> +	if (nodes_empty(*new))
> +		goto out_put;
> +
> +	nodes_and(*new, *new, node_states[N_MEMORY]);
> +	if (nodes_empty(*new))
>  		goto out_put;
> -	}
>  
>  	err = security_task_movememory(task);
>  	if (err)
> _
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
