Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCFF6B026B
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 16:53:12 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so151996448pap.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 13:53:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hb9si4733054pac.193.2016.07.14.13.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 13:53:11 -0700 (PDT)
Date: Thu, 14 Jul 2016 13:53:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] mm: Fix memcg stack accounting for sub-page stacks
Message-Id: <20160714135310.ba2b7dcca48184538260ec21@linux-foundation.org>
In-Reply-To: <9b5314e3ee5eda61b0317ec1563768602c1ef438.1468523549.git.luto@kernel.org>
References: <cover.1468523549.git.luto@kernel.org>
	<9b5314e3ee5eda61b0317ec1563768602c1ef438.1468523549.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org

On Thu, 14 Jul 2016 12:14:11 -0700 Andy Lutomirski <luto@kernel.org> wrote:

> We should account for stacks regardless of stack size, and we need
> to account in sub-page units if THREAD_SIZE < PAGE_SIZE.  Change the
> units to kilobytes and Move it into account_kernel_stack().

I queued this patch after
http://ozlabs.org/~akpm/mmotm/broken-out/mm-charge-uncharge-kmemcg-from-generic-page-allocator-paths.patch
so some changes are needed.  (patching mainline when we're at -rc7 was
optimistic!)

> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -165,20 +165,12 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
>  	struct page *page = alloc_kmem_pages_node(node, THREADINFO_GFP,
>  						  THREAD_SIZE_ORDER);
>  
> -	if (page)
> -		memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -					    1 << THREAD_SIZE_ORDER);
> -
>  	return page ? page_address(page) : NULL;
>  }
>  
>  static inline void free_thread_stack(unsigned long *stack)
>  {
> -	struct page *page = virt_to_page(stack);
> -
> -	memcg_kmem_update_page_stat(page, MEMCG_KERNEL_STACK,
> -				    -(1 << THREAD_SIZE_ORDER));
> -	__free_kmem_pages(page, THREAD_SIZE_ORDER);
> +	free_kmem_pages((unsigned long)stack, THREAD_SIZE_ORDER);
>  }

Here's what I ended up with:

static unsigned long *alloc_thread_stack_node(struct task_struct *tsk,
						  int node)
{
	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
					     THREAD_SIZE_ORDER);

	return page ? page_address(page) : NULL;
}

static inline void free_thread_stack(unsigned long *stack)
{
	__free_pages(virt_to_page(stack), THREAD_SIZE_ORDER);
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
