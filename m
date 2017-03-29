Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 334AE6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 03:45:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id i18so1285186wrb.21
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 00:45:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w132si6197766wmg.127.2017.03.29.00.45.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 29 Mar 2017 00:45:27 -0700 (PDT)
Date: Wed, 29 Mar 2017 09:45:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] module: check if memory leak by module.
Message-ID: <20170329074522.GB27994@dhcp22.suse.cz>
References: <CGME20170329060315epcas5p1c6f7ce3aca1b2770c5e1d9aaeb1a27e1@epcas5p1.samsung.com>
 <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490767322-9914-1-git-send-email-maninder1.s@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, joonas.lahtinen@linux.intel.com, keescook@chromium.org, pavel@ucw.cz, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>

On Wed 29-03-17 11:32:02, Maninder Singh wrote:
> This patch checks if any module which is going to be unloaded
> is doing vmalloc memory leak or not.

Hmm, how can you track _all_ vmalloc allocations done on behalf of the
module? It is quite some time since I've checked kernel/module.c but
from my vague understading your check is basically only about statically
vmalloced areas by module loader. Is that correct? If yes then is this
actually useful? Were there any bugs in the loader code recently? What
led you to prepare this patch? All this should be part of the changelog!
 
> Logs:-
> [  129.336368] Module [test_module] is getting unloaded before doing vfree
> [  129.336371] Memory still allocated: addr:0xffffc90001461000 - 0xffffc900014c7000, pages 101
> [  129.336376] Allocating function kernel_init+0x1c/0x20 [test_module]
> 
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> ---
> v1->v2: made code generic rather than dependent on config.
> 	changed pr_alert to pr_err.
> 
>  include/linux/vmalloc.h |  2 ++
>  kernel/module.c         | 22 ++++++++++++++++++++++
>  mm/vmalloc.c            |  2 --
>  3 files changed, 24 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 46991ad..5531af3 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -29,6 +29,8 @@
>  #define IOREMAP_MAX_ORDER	(7 + PAGE_SHIFT)	/* 128 pages */
>  #endif
>  
> +#define VM_VM_AREA  0x04
> +
>  struct vm_struct {
>  	struct vm_struct	*next;
>  	void			*addr;
> diff --git a/kernel/module.c b/kernel/module.c
> index f953df9..98a8018 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -2117,9 +2117,31 @@ void __weak module_arch_freeing_init(struct module *mod)
>  {
>  }
>  
> +static void check_memory_leak(struct module *mod)
> +{
> +	struct vmap_area *va;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(va, &vmap_area_list, list) {
> +		if (!(va->flags & VM_VM_AREA))
> +			continue;
> +		if ((mod->core_layout.base < va->vm->caller) &&
> +			(mod->core_layout.base + mod->core_layout.size) > va->vm->caller) {
> +			pr_err("Module [%s] is getting unloaded before doing vfree\n", mod->name);
> +			pr_err("Memory still allocated: addr:0x%lx - 0x%lx, pages %u\n",
> +				va->va_start, va->va_end, va->vm->nr_pages);
> +			pr_err("Allocating function %pS\n", va->vm->caller);
> +		}
> +
> +	}
> +	rcu_read_unlock();
> +}
> +
>  /* Free a module, remove from lists, etc. */
>  static void free_module(struct module *mod)
>  {
> +	check_memory_leak(mod);
> +
>  	trace_module_free(mod);
>  
>  	mod_sysfs_teardown(mod);
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 68eb002..0166a0a 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -314,8 +314,6 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
>  
>  /*** Global kva allocator ***/
>  
> -#define VM_VM_AREA	0x04
> -
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
>  LIST_HEAD(vmap_area_list);
> -- 
> 1.9.1
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
