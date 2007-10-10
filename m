Date: Wed, 10 Oct 2007 14:22:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 2/2] Mem Policy: Fixup Shm and Interleave Policy
 Reference Counting
In-Reply-To: <20071010205849.7230.81877.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0710101415470.32488@schroedinger.engr.sgi.com>
References: <20071010205837.7230.42818.sendpatchset@localhost>
 <20071010205849.7230.81877.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, ak@suse.de, gregkh@suse.de, linux-mm@kvack.org, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 10 Oct 2007, Lee Schermerhorn wrote:

> * get_vma_policy() assumes that shared policies are referenced by
>   the get_policy() vm_op, if any.  This is true for shmem_get_policy()
>   but not for shm_get_policy() when the "backing file" does not
>   support a get_policy() vm_op.  The latter is the case for SHM_HUGETLB
>   segments.  Because get_vma_policy() expects the get_policy() op to
>   have added a ref, it doesn't do so itself.  This results in 
>   premature freeing of the policy.  Add the mpol_get() to the 
>   shm_get_policy() op when the backing file doesn't support shared
>   policies.

Could you add support for SHM_HUGETLB segments instead to make this 
consistent so that shared policies always use a get_policy function?

> * Further, shm_get_policy() was falling back to current task's task
>   policy if the backing file did not support get_policy() vm_op and
>   the vma policy was null.  This is not valid when get_vma_policy() is
>   called from show_numa_map() as task != current.  Also, this did
>   not match the behavior of the shmem_get_policy() vm_op which did
>   NOT fall back to task policy.  So, modify shm_get_policy() NOT to
>   fall back to current->mempolicy.

Hmmm..... The show_numa_map issue is special. Maybe fix that one instead?

> Index: Linux/include/linux/mempolicy.h
> ===================================================================
> --- Linux.orig/include/linux/mempolicy.h	2007-10-10 13:36:44.000000000 -0400
> +++ Linux/include/linux/mempolicy.h	2007-10-10 14:20:28.000000000 -0400
> @@ -2,6 +2,7 @@
>  #define _LINUX_MEMPOLICY_H 1
>  
>  #include <linux/errno.h>
> +#include <linux/mm.h>

I think we tried to avoid a heavy include here. mm.h is huge and draws in 
lots of other include files. The additional include is only needed for the 
VM_BUG_ON it seems? BUG_ON would also work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
