Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E68A86B007B
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 18:50:14 -0500 (EST)
Date: Wed, 3 Mar 2010 15:50:04 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
Message-Id: <20100303155004.5f9e793e.akpm@linux-foundation.org>
In-Reply-To: <4B8E3F77.6070201@cn.fujitsu.com>
References: <4B8E3F77.6070201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 03 Mar 2010 18:52:39 +0800
Miao Xie <miaox@cn.fujitsu.com> wrote:

> if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
> task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
> mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
> use a rwlock to protect them to fix this probelm.

Boy, that is one big ugly patch.  Is there no other way of doing this?

>
> ...
>
> --- a/include/linux/mempolicy.h
> +++ b/include/linux/mempolicy.h
> @@ -51,6 +51,7 @@ enum {
>   */
>  #define MPOL_F_SHARED  (1 << 0)	/* identify shared policies */
>  #define MPOL_F_LOCAL   (1 << 1)	/* preferred local allocation */
> +#define MPOL_F_TASK    (1 << 2)	/* identify tasks' policies */

What's this?  It wasn't mentioned in the changelog - I suspect it
should have been?

>
> ...
>
> +int cpuset_mems_allowed_intersects(struct task_struct *tsk1,
> +				   struct task_struct *tsk2)
>  {
> -	return nodes_intersects(tsk1->mems_allowed, tsk2->mems_allowed);
> +	unsigned long flags1, flags2;
> +	int retval;
> +
> +	read_mem_lock_irqsave(tsk1, flags1);
> +	read_mem_lock_irqsave(tsk2, flags2);
> +	retval = nodes_intersects(tsk1->mems_allowed, tsk2->mems_allowed);
> +	read_mem_unlock_irqrestore(tsk2, flags2);
> +	read_mem_unlock_irqrestore(tsk1, flags1);

I suspect this is deadlockable in sufficiently arcane circumstances:
one task takes the locks in a,b order, another task takes them in b,a
order and a third task gets in at the right time and does a
write_lock().  Probably that's not possible for some reason, dunno.  The usual
way of solving this is to always take the locks in
sorted-by-ascending-virtual-address order.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
