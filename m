Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7D8800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 08:57:28 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id v14so145929lfi.21
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 05:57:28 -0800 (PST)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id 15si109497lfe.131.2018.01.23.05.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 05:57:26 -0800 (PST)
Subject: Re: [PATCH 3/4] kernel/fork: switch vmapped stack callation to
 __vmalloc_area()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670492913.658225.2758351129158778856.stgit@buzz>
Message-ID: <5c19630f-7466-676d-dbbc-a5668c91cbcd@yandex-team.ru>
Date: Tue, 23 Jan 2018 16:57:21 +0300
MIME-Version: 1.0
In-Reply-To: <151670492913.658225.2758351129158778856.stgit@buzz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: ru-RU
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

# stress-ng --clone 100 -t 10s --metrics-brief
at 32-core machine shows boost 35000 -> 36000 bogo ops

Patch 4/4 is a kind of RFC.
Actually per-cpu cache of preallocated stacks works faster than buddy allocator thus
performance boots for it happens only at completely insane rate of clones.

On 23.01.2018 13:55, Konstantin Khlebnikov wrote:
> This gives as pointer vm_struct without calling find_vm_area().
> 
> And fix comment about that task holds cache of vm area: this cache used
> for retrieving actual stack pages, freeing is done by vfree_deferred().
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>   kernel/fork.c |   37 +++++++++++++++----------------------
>   1 file changed, 15 insertions(+), 22 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 2295fc69717f..457c9151f3c8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -204,39 +204,32 @@ static int free_vm_stack_cache(unsigned int cpu)
>   static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
>   {
>   #ifdef CONFIG_VMAP_STACK
> -	void *stack;
> +	struct vm_struct *stack;
>   	int i;
>   
>   	for (i = 0; i < NR_CACHED_STACKS; i++) {
> -		struct vm_struct *s;
> -
> -		s = this_cpu_xchg(cached_stacks[i], NULL);
> -
> -		if (!s)
> +		stack = this_cpu_xchg(cached_stacks[i], NULL);
> +		if (!stack)
>   			continue;
>   
>   #ifdef CONFIG_DEBUG_KMEMLEAK
>   		/* Clear stale pointers from reused stack. */
> -		memset(s->addr, 0, THREAD_SIZE);
> +		memset(stack->addr, 0, THREAD_SIZE);
>   #endif
> -		tsk->stack_vm_area = s;
> -		return s->addr;
> +		tsk->stack_vm_area = stack;
> +		return stack->addr;
>   	}
>   
> -	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
> -				     VMALLOC_START, VMALLOC_END,
> -				     THREADINFO_GFP,
> -				     PAGE_KERNEL,
> -				     0, node, __builtin_return_address(0));
> +	stack = __vmalloc_area(THREAD_SIZE, THREAD_ALIGN,
> +			       VMALLOC_START, VMALLOC_END,
> +			       THREADINFO_GFP, PAGE_KERNEL,
> +			       0, node, __builtin_return_address(0));
> +	if (unlikely(!stack))
> +		return NULL;
>   
> -	/*
> -	 * We can't call find_vm_area() in interrupt context, and
> -	 * free_thread_stack() can be called in interrupt context,
> -	 * so cache the vm_struct.
> -	 */
> -	if (stack)
> -		tsk->stack_vm_area = find_vm_area(stack);
> -	return stack;
> +	/* Cache the vm_struct for stack to page conversions. */
> +	tsk->stack_vm_area = stack;
> +	return stack->addr;
>   #else
>   	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
>   					     THREAD_SIZE_ORDER);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
