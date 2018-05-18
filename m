Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 034816B05E4
	for <linux-mm@kvack.org>; Fri, 18 May 2018 11:57:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u127-v6so7367914qka.9
        for <linux-mm@kvack.org>; Fri, 18 May 2018 08:57:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p85-v6si7695670qkh.24.2018.05.18.08.57.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 08:57:04 -0700 (PDT)
Subject: Re: [PATCH] mm/kasan: Don't vfree() nonexistent vm_area.
References: <12c9e499-9c11-d248-6a3f-14ec8c4e07f1@molgen.mpg.de>
 <20180201163349.8700-1-aryabinin@virtuozzo.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <784dfdf6-8fc3-be08-833b-a9097c3d1b96@redhat.com>
Date: Fri, 18 May 2018 17:57:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180201163349.8700-1-aryabinin@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On 01.02.2018 17:33, Andrey Ryabinin wrote:
> KASAN uses different routines to map shadow for hot added memory and memory
> obtained in boot process. Attempt to offline memory onlined by normal boot
> process leads to this:
> 
>     Trying to vfree() nonexistent vm area (000000005d3b34b9)
>     WARNING: CPU: 2 PID: 13215 at mm/vmalloc.c:1525 __vunmap+0x147/0x190
> 
>     Call Trace:
>      kasan_mem_notifier+0xad/0xb9
>      notifier_call_chain+0x166/0x260
>      __blocking_notifier_call_chain+0xdb/0x140
>      __offline_pages+0x96a/0xb10
>      memory_subsys_offline+0x76/0xc0
>      device_offline+0xb8/0x120
>      store_mem_state+0xfa/0x120
>      kernfs_fop_write+0x1d5/0x320
>      __vfs_write+0xd4/0x530
>      vfs_write+0x105/0x340
>      SyS_write+0xb0/0x140
> 
> Obviously we can't call vfree() to free memory that wasn't allocated via
> vmalloc(). Use find_vm_area() to see if we can call vfree().
> 
> Unfortunately it's a bit tricky to properly unmap and free shadow allocated
> during boot, so we'll have to keep it. If memory will come online again
> that shadow will be reused.
> 

While debugging kasan memory hotplug problems I am having, stumbled over
this patch.

Couldn't we handle that via VM_KASAN like in kasan_module_alloc/free
instead?

> Fixes: fa69b5989bb0 ("mm/kasan: add support for memory hotplug")
> Reported-by: Paul Menzel <pmenzel+linux-kasan-dev@molgen.mpg.de>
> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: <stable@vger.kernel.org>
> ---
>  mm/kasan/kasan.c | 57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 55 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
> index e13d911251e7..0d9d9d268f32 100644
> --- a/mm/kasan/kasan.c
> +++ b/mm/kasan/kasan.c
> @@ -791,6 +791,41 @@ DEFINE_ASAN_SET_SHADOW(f5);
>  DEFINE_ASAN_SET_SHADOW(f8);
>  
>  #ifdef CONFIG_MEMORY_HOTPLUG
> +static bool shadow_mapped(unsigned long addr)
> +{
> +	pgd_t *pgd = pgd_offset_k(addr);
> +	p4d_t *p4d;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte;
> +
> +	if (pgd_none(*pgd))
> +		return false;
> +	p4d = p4d_offset(pgd, addr);
> +	if (p4d_none(*p4d))
> +		return false;
> +	pud = pud_offset(p4d, addr);
> +	if (pud_none(*pud))
> +		return false;
> +
> +	/*
> +	 * We can't use pud_large() or pud_huge(), the first one
> +	 * is arch-specific, the last one depend on HUGETLB_PAGE.
> +	 * So let's abuse pud_bad(), if bud is bad it's has to
> +	 * because it's huge.
> +	 */
> +	if (pud_bad(*pud))
> +		return true;
> +	pmd = pmd_offset(pud, addr);
> +	if (pmd_none(*pmd))
> +		return false;
> +
> +	if (pmd_bad(*pmd))
> +		return true;
> +	pte = pte_offset_kernel(pmd, addr);
> +	return !pte_none(*pte);
> +}
> +
>  static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>  			unsigned long action, void *data)
>  {
> @@ -812,6 +847,14 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>  	case MEM_GOING_ONLINE: {
>  		void *ret;
>  
> +		/*
> +		 * If shadow is mapped already than it must have been mapped
> +		 * during the boot. This could happen if we onlining previously
> +		 * offlined memory.
> +		 */
> +		if (shadow_mapped(shadow_start))
> +			return NOTIFY_OK;
> +
>  		ret = __vmalloc_node_range(shadow_size, PAGE_SIZE, shadow_start,
>  					shadow_end, GFP_KERNEL,
>  					PAGE_KERNEL, VM_NO_GUARD,
> @@ -823,8 +866,18 @@ static int __meminit kasan_mem_notifier(struct notifier_block *nb,
>  		kmemleak_ignore(ret);
>  		return NOTIFY_OK;
>  	}
> -	case MEM_OFFLINE:
> -		vfree((void *)shadow_start);
> +	case MEM_OFFLINE: {
> +		struct vm_struct *vm;
> +
> +		/*
> +		 * Only hot-added memory have vm_area. Freeing shadow
> +		 * mapped during boot would be tricky, so we'll just
> +		 * have to keep it.
> +		 */
> +		vm = find_vm_area((void *)shadow_start);
> +		if (vm)
> +			vfree((void *)shadow_start);
> +	}
>  	}
>  
>  	return NOTIFY_OK;
> 


-- 

Thanks,

David / dhildenb
