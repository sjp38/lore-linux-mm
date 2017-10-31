Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7FB6B0069
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:46:41 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w105so9592208wrc.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 02:46:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 193si1110356wmq.218.2017.10.31.02.46.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 02:46:39 -0700 (PDT)
Subject: Re: [PATCH RFC v2 4/4] mm/mempolicy: add nodes_empty check in
 SYSC_migrate_pages
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <dccbeccc-4155-94a8-0e67-b7c28238896d@suse.cz>
Date: Tue, 31 Oct 2017 10:46:37 +0100
MIME-Version: 1.0
In-Reply-To: <1509099265-30868-5-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Christoph Lameter <cl@linux.com>

+CC Andi and Christoph

On 10/27/2017 12:14 PM, Yisheng Xie wrote:
> As manpage of migrate_pages, the errno should be set to EINVAL when none
> of the specified nodes contain memory. However, when new_nodes is null,
> i.e. the specified nodes also do not have memory, as the following case:
> 
> 	new_nodes = 0;
> 	old_nodes = 0xf;
> 	ret = migrate_pages(pid, old_nodes, new_nodes, MAX);
> 
> The ret will be 0 and no errno is set.
> 
> This patch is to add nodes_empty check to fix above case.

Hmm, I think we have a bigger problem than "empty set is a subset of
anything" here.

The existing checks are:

        task_nodes = cpuset_mems_allowed(task);
        /* Is the user allowed to access the target nodes? */
        if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
                err = -EPERM;
                goto out_put;
        }

        if (!nodes_subset(*new, node_states[N_MEMORY])) {
                err = -EINVAL;
                goto out_put;
        }

And manpage says:

       EINVAL The value specified by maxnode exceeds a kernel-imposed
limit.  Or, old_nodes or new_nodes specifies one or more node IDs that
are greater than the maximum supported node
              ID.  *Or, none of the node IDs specified by new_nodes are
on-line and allowed by the process's current cpuset context, or none of
the specified nodes contain memory.*

       EPERM  Insufficient privilege (CAP_SYS_NICE) to move pages of the
process specified by pid, or insufficient privilege (CAP_SYS_NICE) to
access the specified target nodes.

- it says "none ... are allowed", but checking for subset means we check
if "all ... are allowed". Shouldn't we be checking for a non-empty
intersection?
- there doesn't seem to be any EINVAL check for "process's current
cpuset context", there's just an EPERM check for "target process's
cpuset context".

> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/mempolicy.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 8798ecb..58352cc 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1402,6 +1402,11 @@ static int copy_nodes_to_user(unsigned long __user *mask, unsigned long maxnode,
>  	if (err)
>  		goto out;
>  
> +	if (nodes_empty(*new)) {
> +		err = -EINVAL;
> +		goto out;
> +	}
> +
>  	/* Find the mm_struct */
>  	rcu_read_lock();
>  	task = pid ? find_task_by_vpid(pid) : current;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
