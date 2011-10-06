Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF8F6B002D
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 19:11:01 -0400 (EDT)
Received: by ggdk5 with SMTP id k5so2950565ggd.14
        for <linux-mm@kvack.org>; Thu, 06 Oct 2011 16:10:59 -0700 (PDT)
Date: Thu, 6 Oct 2011 16:10:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC] mm: add vm_area_add_early()
Message-Id: <20111006161056.e1cf56ec.akpm@linux-foundation.org>
In-Reply-To: <alpine.LFD.2.00.1109141427340.20358@xanadu.home>
References: <alpine.LFD.2.00.1109141427340.20358@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org

On Wed, 14 Sep 2011 14:35:21 -0400 (EDT)
Nicolas Pitre <nicolas.pitre@linaro.org> wrote:

> 
> The existing vm_area_register_early() allows for early vmalloc space
> allocation.  However upcoming cleanups in the ARM architecture require
> that some fixed locations in the vmalloc area be reserved also very early.
> 
> The name "vm_area_register_early" would have been a good name for the
> reservation part without the allocation.  Since it is already in use with
> different semantics, let's create vm_area_add_early() instead.
> 
> Both vm_area_register_early() and vm_area_add_early() can be used together
> meaning that the former is now implemented using the later where it is
> ensured that no conflicting areas are added, but no attempt is made to
> make the allocation scheme in vm_area_register_early() more sophisticated.
> After all, you must know what you're doing when using those functions.
> 
> Signed-off-by: Nicolas Pitre <nicolas.pitre@linaro.org>
> ---
> 
> Comments / ACKs appreciated.

Deafening silence?

> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 9332e52ea8..e7d2cba995 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -130,6 +130,7 @@ extern long vwrite(char *buf, char *addr, unsigned long count);
>   */
>  extern rwlock_t vmlist_lock;
>  extern struct vm_struct *vmlist;
> +extern __init void vm_area_add_early(struct vm_struct *vm);
>  extern __init void vm_area_register_early(struct vm_struct *vm, size_t align);
>  
>  #ifdef CONFIG_SMP
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 7ef0903058..bf20a0ff95 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1118,6 +1118,31 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
>  EXPORT_SYMBOL(vm_map_ram);
>  
>  /**
> + * vm_area_add_early - add vmap area early during boot
> + * @vm: vm_struct to add
> + *
> + * This function is used to add fixed kernel vm area to vmlist before
> + * vmalloc_init() is called.  @vm->addr, @vm->size, and @vm->flags
> + * should contain proper values and the other fields should be zero.
> + *
> + * DO NOT USE THIS FUNCTION UNLESS YOU KNOW WHAT YOU'RE DOING.
> + */
> +void __init vm_area_add_early(struct vm_struct *vm)
> +{
> +	struct vm_struct *tmp, **p;
> +
> +	for (p = &vmlist; (tmp = *p) != NULL; p = &tmp->next) {
> +		if (tmp->addr >= vm->addr) {
> +			BUG_ON(tmp->addr < vm->addr + vm->size);
> +			break;
> +		} else
> +			BUG_ON(tmp->addr + tmp->size > vm->addr);
> +	}
> +	vm->next = *p;
> +	*p = vm;
> +}
> +
> +/**
>   * vm_area_register_early - register vmap area early during boot
>   * @vm: vm_struct to register
>   * @align: requested alignment
> @@ -1139,8 +1164,7 @@ void __init vm_area_register_early(struct vm_struct *vm, size_t align)
>  
>  	vm->addr = (void *)addr;
>  
> -	vm->next = vmlist;
> -	vmlist = vm;
> +	vm_area_add_early(vm);
>  }
>  
>  void __init vmalloc_init(void)

I tossed this into my tree for a bit of testing, assuming it's
up-to-date and still desired?

Feel free to add it to some ARM tree.  I'll drop my copy when that
turns up in linux-next.

Yes, the naming scheme in there is gruseome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
