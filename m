Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4938D6B0003
	for <linux-mm@kvack.org>; Sun, 11 Nov 2018 22:24:37 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s140so449361oih.4
        for <linux-mm@kvack.org>; Sun, 11 Nov 2018 19:24:37 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u15-v6sor7766294oiv.66.2018.11.11.19.24.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 11 Nov 2018 19:24:36 -0800 (PST)
Subject: Re: [PATCH] mm:vmalloc add vm_struct for vm_map_ram
References: <1541675689-13363-1-git-send-email-huangzhaoyang@gmail.com>
From: Xishi Qiu <qiuxishi@gmail.com>
Message-ID: <bdd6deb0-9c28-9353-e445-5bf5c893d64d@gmail.com>
Date: Mon, 12 Nov 2018 11:24:08 +0800
MIME-Version: 1.0
In-Reply-To: <1541675689-13363-1-git-send-email-huangzhaoyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, David Rientjes <rientjes@google.com>, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2018/11/8 19:14, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> There is no caller and pages information etc for the area which is
> created by vm_map_ram as well as the page count > VMAP_MAX_ALLOC.
> Add them on in this commit.
> 
> Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> ---
>  mm/vmalloc.c | 30 ++++++++++++++++++++----------
>  1 file changed, 20 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index cfea25b..819b690 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -45,7 +45,8 @@ struct vfree_deferred {
>  static DEFINE_PER_CPU(struct vfree_deferred, vfree_deferred);
>  
>  static void __vunmap(const void *, int);
> -
> +static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
> +			      unsigned long flags, const void *caller);
>  static void free_work(struct work_struct *w)
>  {
>  	struct vfree_deferred *p = container_of(w, struct vfree_deferred, wq);
> @@ -1138,6 +1139,7 @@ void vm_unmap_ram(const void *mem, unsigned int count)
>  	BUG_ON(!va);
>  	debug_check_no_locks_freed((void *)va->va_start,
>  				    (va->va_end - va->va_start));
> +	kfree(va->vm);
>  	free_unmap_vmap_area(va);
>  }
>  EXPORT_SYMBOL(vm_unmap_ram);
> @@ -1170,6 +1172,8 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
>  		addr = (unsigned long)mem;
>  	} else {
>  		struct vmap_area *va;
> +		struct vm_struct *area;
> +
>  		va = alloc_vmap_area(size, PAGE_SIZE,
>  				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
>  		if (IS_ERR(va))
> @@ -1177,11 +1181,17 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
>  
>  		addr = va->va_start;
>  		mem = (void *)addr;
> +		area = kzalloc_node(sizeof(*area), GFP_KERNEL, node);
> +		if (likely(area)) {
> +			setup_vmalloc_vm(area, va, 0, __builtin_return_address(0));
> +			va->flags &= ~VM_VM_AREA;
> +		}
Hi Zhaoyangi 1/4 ?

I think if we set the flag VM_VM_AREA, that means we have some info,
so how about do not clear the flag after setup_vmalloc_vm, and just
update the print in s_show.

	...
	if (v->flags & VM_ALLOC)
		seq_puts(m, " vmalloc");
+	if (v->flags & VM_MAP_RAM)  // add a new flag for vm_map_ram?
+		seq_puts(m, " vm_map_ram");
	...

Thanks,
Xishi QIu
>  	}
>  	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
>  		vm_unmap_ram(mem, count);
>  		return NULL;
>  	}
> +
>  	return mem;
>  }
>  EXPORT_SYMBOL(vm_map_ram);
> @@ -2688,19 +2698,19 @@ static int s_show(struct seq_file *m, void *p)
>  	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
>  	 * behalf of vmap area is being tear down or vm_map_ram allocation.
>  	 */
> -	if (!(va->flags & VM_VM_AREA)) {
> -		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
> -			(void *)va->va_start, (void *)va->va_end,
> -			va->va_end - va->va_start,
> -			va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
> -
> +	if (!(va->flags & VM_VM_AREA) && !va->vm)
>  		return 0;
> -	}
>  
>  	v = va->vm;
>  
> -	seq_printf(m, "0x%pK-0x%pK %7ld",
> -		v->addr, v->addr + v->size, v->size);
> +	if (!(va->flags & VM_VM_AREA))
> +		seq_printf(m, "0x%pK-0x%pK %7ld %s\n",
> +				(void *)va->va_start, (void *)va->va_end,
> +				va->va_end - va->va_start,
> +				va->flags & VM_LAZY_FREE ? "unpurged vm_area" : "vm_map_ram");
> +	else
> +		seq_printf(m, "0x%pK-0x%pK %7ld",
> +				v->addr, v->addr + v->size, v->size);
>  
>  	if (v->caller)
>  		seq_printf(m, " %pS", v->caller);
> 
