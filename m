Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 066416B017A
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 16:08:38 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rp16so1113577pbb.17
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 13:08:38 -0800 (PST)
Received: from psmtp.com ([74.125.245.156])
        by mx.google.com with SMTP id vs7si3863530pbc.235.2013.11.07.13.08.36
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 13:08:37 -0800 (PST)
Message-ID: <527C0149.6020902@infradead.org>
Date: Thu, 07 Nov 2013 13:08:25 -0800
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: Re: [memcg:since-3.12 75/75] fs/proc/meminfo.c:undefined reference
 to `vm_commit_limit'
References: <527b74a0.xBELNKuc6Ws8XONb%fengguang.wu@intel.com>	<20131107132505.GA16393@dhcp22.suse.cz> <20131107125103.c81016a87bfd72b0acf4058c@linux-foundation.org>
In-Reply-To: <20131107125103.c81016a87bfd72b0acf4058c@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>
Cc: Jerome Marchand <jmarchan@redhat.com>, kbuild-all@01.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com

On 11/07/13 12:51, Andrew Morton wrote:
> On Thu, 7 Nov 2013 14:25:05 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
>> On Thu 07-11-13 19:08:16, Wu Fengguang wrote:
>>> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-3.12
>>> head:   2f11d7af8df66cb4f217b6293ad8189aa101d601
>>> commit: 2f11d7af8df66cb4f217b6293ad8189aa101d601 [75/75] mm-factor-commit-limit-calculation-fix
>>> config: make ARCH=blackfin BF526-EZBRD_defconfig
>>>
>>> All error/warnings:
>>>
>>>    mm/built-in.o: In function `__vm_enough_memory':
>>>    (.text+0x11b4c): undefined reference to `vm_commit_limit'
>>>    fs/built-in.o: In function `meminfo_proc_show':
>>>>> fs/proc/meminfo.c:(.text+0x37ef0): undefined reference to `vm_commit_limit'
>>
>> Andrew, it seems that moving vm_commit_limit out of mman.h is not that
>> easy because it breaks NOMMU configurations. mm/mmap.o is not part of
>> the nommu build apparently.
>>
>> So either we move it back to mman.h or put it somewhere else. I do not
>> have a good idea where, though.
>>
> 
> util.c?
> 
> diff -puN mm/mmap.c~mm-factor-commit-limit-calculation-fix-fix mm/mmap.c
> --- a/mm/mmap.c~mm-factor-commit-limit-calculation-fix-fix
> +++ a/mm/mmap.c
> @@ -110,15 +110,6 @@ unsigned long vm_memory_committed(void)
>  EXPORT_SYMBOL_GPL(vm_memory_committed);
>  
>  /*
> - * Commited memory limit enforced when OVERCOMMIT_NEVER policy is used
> - */
> -unsigned long vm_commit_limit(void)
> -{
> -	return ((totalram_pages - hugetlb_total_pages())
> -		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> -}
> -
> -/*
>   * Check that a process has enough memory to allocate a new virtual
>   * mapping. 0 means there is enough memory for the allocation to
>   * succeed and -ENOMEM implies there is not.
> --- a/mm/util.c~mm-factor-commit-limit-calculation-fix-fix
> +++ a/mm/util.c
> @@ -7,6 +7,9 @@
>  #include <linux/security.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/mman.h>
> +#include <linux/hugetlb.h>
> +
>  #include <asm/uaccess.h>
>  
>  #include "internal.h"
> @@ -398,6 +401,16 @@ struct address_space *page_mapping(struc
>  	return mapping;
>  }
>  
> +/*
> + * Commited memory limit enforced when OVERCOMMIT_NEVER policy is used

      Committed

> + */
> +unsigned long vm_commit_limit(void)
> +{
> +	return ((totalram_pages - hugetlb_total_pages())
> +		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> +}
> +
> +
>  /* Tracepoints definitions. */
>  EXPORT_TRACEPOINT_SYMBOL(kmalloc);
>  EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
> _
> 
> --


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
