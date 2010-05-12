Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 25B1A6B0207
	for <linux-mm@kvack.org>; Tue, 11 May 2010 21:49:11 -0400 (EDT)
Date: Tue, 11 May 2010 18:49:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] cpuset,mm: fix no node to alloc memory when
 changing cpuset's mems
Message-Id: <20100511184900.8211b6f9.akpm@linux-foundation.org>
In-Reply-To: <4BDFFCCA.3020906@cn.fujitsu.com>
References: <4BDFFCCA.3020906@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 04 May 2010 18:54:02 +0800
Miao Xie <miaox@cn.fujitsu.com> wrote:

> Before applying this patch, cpuset updates task->mems_allowed and mempolicy by
> setting all new bits in the nodemask first, and clearing all old unallowed bits
> later. But in the way, the allocator may find that there is no node to alloc
> memory.
> 
> The reason is that cpuset rebinds the task's mempolicy, it cleans the nodes which
> the allocater can alloc pages on, for example:
> (mpol: mempolicy)
> 	task1			task1's mpol	task2
> 	alloc page		1
> 	  alloc on node0? NO	1
> 				1		change mems from 1 to 0
> 				1		rebind task1's mpol
> 				0-1		  set new bits
> 				0	  	  clear disallowed bits
> 	  alloc on node1? NO	0
> 	  ...
> 	can't alloc page
> 	  goto oom
> 
> This patch fixes this problem by expanding the nodes range first(set newly
> allowed bits) and shrink it lazily(clear newly disallowed bits). So we use a
> variable to tell the write-side task that read-side task is reading nodemask,
> and the write-side task clears newly disallowed nodes after read-side task ends
> the current memory allocation.
> 
>
> ...
>
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -16,6 +16,7 @@
>  #include <linux/key.h>
>  #include <linux/security.h>
>  #include <linux/cpu.h>
> +#include <linux/cpuset.h>
>  #include <linux/acct.h>
>  #include <linux/tsacct_kern.h>
>  #include <linux/file.h>
> @@ -1003,8 +1004,10 @@ NORET_TYPE void do_exit(long code)
>  
>  	exit_notify(tsk, group_dead);
>  #ifdef CONFIG_NUMA
> +	task_lock(tsk);
>  	mpol_put(tsk->mempolicy);
>  	tsk->mempolicy = NULL;
> +	task_unlock(tsk);
>  #endif
>  #ifdef CONFIG_FUTEX
>  	if (unlikely(current->pi_state_cache))

Given that this function is already holding task_lock(tsk), this
didn't work very well.

Also, why was the inclusion of cpuset.h added?  Nothing which this
patch adds appears to need it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
