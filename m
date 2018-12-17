Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3788E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:14:11 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a9so9057487pla.2
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:14:11 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si10329862pgf.452.2018.12.17.04.14.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:14:10 -0800 (PST)
Date: Mon, 17 Dec 2018 13:14:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fork,memcg: fix crash in free_thread_stack on memcg
 charge fail
Message-ID: <20181217121407.GG30879@dhcp22.suse.cz>
References: <20181214231726.7ee4843c@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181214231726.7ee4843c@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Shakeel Butt <shakeelb@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>

On Fri 14-12-18 23:17:26, Rik van Riel wrote:
> Changeset 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> will result in fork failing if allocating a kernel stack for a task
> in dup_task_struct exceeds the kernel memory allowance for that cgroup.
> 
> Unfortunately, it also results in a crash.
> 
> This is due to the code jumping to free_stack and calling free_thread_stack
> when the memcg kernel stack charge fails, but without tsk->stack pointing
> at the freshly allocated stack.
> 
> This in turn results in the vfree_atomic in free_thread_stack oopsing
> with a backtrace like this:
> 
> #5 [ffffc900244efc88] die at ffffffff8101f0ab
>  #6 [ffffc900244efcb8] do_general_protection at ffffffff8101cb86
>  #7 [ffffc900244efce0] general_protection at ffffffff818ff082
>     [exception RIP: llist_add_batch+7]
>     RIP: ffffffff8150d487  RSP: ffffc900244efd98  RFLAGS: 00010282
>     RAX: 0000000000000000  RBX: ffff88085ef55980  RCX: 0000000000000000
>     RDX: ffff88085ef55980  RSI: 343834343531203a  RDI: 343834343531203a
>     RBP: ffffc900244efd98   R8: 0000000000000001   R9: ffff8808578c3600
>     R10: 0000000000000000  R11: 0000000000000001  R12: ffff88029f6c21c0
>     R13: 0000000000000286  R14: ffff880147759b00  R15: 0000000000000000
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>  #8 [ffffc900244efda0] vfree_atomic at ffffffff811df2c7
>  #9 [ffffc900244efdb8] copy_process at ffffffff81086e37
> #10 [ffffc900244efe98] _do_fork at ffffffff810884e0
> #11 [ffffc900244eff10] sys_vfork at ffffffff810887ff
> #12 [ffffc900244eff20] do_syscall_64 at ffffffff81002a43
>     RIP: 000000000049b948  RSP: 00007ffcdb307830  RFLAGS: 00000246
>     RAX: ffffffffffffffda  RBX: 0000000000896030  RCX: 000000000049b948
>     RDX: 0000000000000000  RSI: 00007ffcdb307790  RDI: 00000000005d7421
>     RBP: 000000000067370f   R8: 00007ffcdb3077b0   R9: 000000000001ed00
>     R10: 0000000000000008  R11: 0000000000000246  R12: 0000000000000040
>     R13: 000000000000000f  R14: 0000000000000000  R15: 000000000088d018
>     ORIG_RAX: 000000000000003a  CS: 0033  SS: 002b
> 
> The simplest fix is to assign tsk->stack right where it is allocated.
> 
> Fixes: 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Shakeel Butt <shakeelb@google.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Signed-off-by: Rik van Riel <riel@surriel.com>

Ouch, I completely missed this during the review. The code is quite
subtle. I was about to suggest that we simply do
	tsk->stack = alloc_thread_stack_node(tsk, node);
but arch_dup_task_struct overwrites it and that is the reason we have
this hairy handling and assign tsk->stack 2 times.

The patch doesn't improve the overall readbility but it is a fix so
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
> ---
>  kernel/fork.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 07cddff89c7b..e2a5156bc9c3 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -240,8 +240,10 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>  	 * free_thread_stack() can be called in interrupt context,
>  	 * so cache the vm_struct.
>  	 */
> -	if (stack)
> +	if (stack) {
>  		tsk->stack_vm_area = find_vm_area(stack);
> +		tsk->stack = stack;
> +	}
>  	return stack;
>  #else
>  	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
> @@ -288,7 +290,10 @@ static struct kmem_cache *thread_stack_cache;
>  static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
>  						  int node)
>  {
> -	return kmem_cache_alloc_node(thread_stack_cache, THREADINFO_GFP, node);
> +	unsigned long *stack;
> +	stack = kmem_cache_alloc_node(thread_stack_cache, THREADINFO_GFP, node);
> +	tsk->stack = stack;
> +	return stack;
>  }
>  
>  static void free_thread_stack(struct task_struct *tsk)
> 
> 
> -- 
> All rights reversed.

-- 
Michal Hocko
SUSE Labs
