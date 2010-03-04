Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C4EE6B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 23:53:21 -0500 (EST)
Date: Thu, 4 Mar 2010 15:53:15 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy
 and mems_allowed
Message-ID: <20100304045315.GP8653@laptop>
References: <4B8E3F77.6070201@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B8E3F77.6070201@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 03, 2010 at 06:52:39PM +0800, Miao Xie wrote:
> if MAX_NUMNODES > BITS_PER_LONG, loading/storing task->mems_allowed or mems_allowed in
> task->mempolicy are not atomic operations, and the kernel page allocator gets an empty
> mems_allowed when updating task->mems_allowed or mems_allowed in task->mempolicy. So we
> use a rwlock to protect them to fix this probelm.

Oh, and something else I'm also concerned about:

If  MAX_NUMNODES <= BITS_PER_LONG then these locks are a noop.

> +#define read_mem_lock_irqsave(p, flags)		do { (void)(flags); } while (0)
> +
> +#define read_mem_unlock_irqrestore(p, flags)	do { (void)(flags); } while (0)
> +
> +/* Be used to protect task->mempolicy and mems_allowed when user reads them */

However you are appearing to use them for more than just atomically
loading of the nodemasks.

> @@ -2447,11 +2503,14 @@ void cpuset_unlock(void)
>  int cpuset_mem_spread_node(void)
>  {
>  	int node;
> +	unsigned long flags;
>  
> +	read_mem_lock_irqsave(current, flags);
>  	node = next_node(current->cpuset_mem_spread_rotor, current->mems_allowed);
>  	if (node == MAX_NUMNODES)
>  		node = first_node(current->mems_allowed);
>  	current->cpuset_mem_spread_rotor = node;
> +	read_mem_unlock_irqrestore(current, flags);
>  	return node;
>  }
>  EXPORT_SYMBOL_GPL(cpuset_mem_spread_node);

If you are worried about doing this kind of atomic RMW on the mask, then
you cannot make the lock a noop. So if you're nooping the lock in this
way then you really need to cuddle it neatly around loading of the mask.

Once you do that, it would be trivial to use a seqlock.

...

> @@ -1381,8 +1434,16 @@ static struct mempolicy *get_vma_policy(struct task_struct *task,
>  		} else if (vma->vm_policy)
>  			pol = vma->vm_policy;
>  	}
> +	if (!pol) {
> +		read_mem_lock_irqsave(task, irqflags);
> +		pol = task->mempolicy;
> +		mpol_get(pol);
> +		read_mem_unlock_irqrestore(task, irqflags);
> +	}
> +
>  	if (!pol)
>  		pol = &default_policy;
> +
>  	return pol;
>  }

And a couple of others. It looks like you're using it here to guarantee
existence of the mempolicy.... Did you mean read_mempolicy_lock? Or do
you have another problem (there seems to be several cases of this).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
