Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 895786B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 04:22:13 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1E6043EE0C8
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:12 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E8C562B7B06
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C513F2E68C8
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0B9EE18007
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:11 +0900 (JST)
Received: from g01jpexchyt07.g01.fujitsu.local (g01jpexchyt07.g01.fujitsu.local [10.128.194.46])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 523B01DB803E
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 17:22:11 +0900 (JST)
Message-ID: <5009151F.3060903@jp.fujitsu.com>
Date: Fri, 20 Jul 2012 17:21:51 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 6/8] memory-hotplug: introduce new function arch_remove_memory()
References: <5009038A.4090001@cn.fujitsu.com> <500904D6.3030109@cn.fujitsu.com>
In-Reply-To: <500904D6.3030109@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wen Congyang <wency@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

2012/07/20 16:12, Wen Congyang wrote:
> We don't call __add_pages() directly in the function add_memory()
> because some other architecture related thins needs to be done
> before or after calling __add_pages(). So we should not call
> __remove_pages() directly in the function remove_memory.
> Introduce new function arch_remove_memory() to revert the things done
> in arch_add_memory().
>
> Note: the function for x86_64 will be implemented later. And I don't
> know how to implement it for s390.

I think you need cc to other arch ML for reviewing the patch.


> CC: David Rientjes <rientjes@google.com>
> CC: Jiang Liu <liuj97@gmail.com>
> CC: Len Brown <len.brown@intel.com>
> CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> CC: Paul Mackerras <paulus@samba.org>
> CC: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
> ---
>   arch/ia64/mm/init.c            |   16 ++++++++++++++++
>   arch/powerpc/mm/mem.c          |   14 ++++++++++++++
>   arch/s390/mm/init.c            |    8 ++++++++
>   arch/sh/mm/init.c              |   15 +++++++++++++++
>   arch/tile/mm/init.c            |    8 ++++++++
>   arch/x86/mm/init_32.c          |   10 ++++++++++
>   arch/x86/mm/init_64.c          |    7 +++++++
>   include/linux/memory_hotplug.h |    1 +
>   mm/memory_hotplug.c            |    2 +-
>   9 files changed, 80 insertions(+), 1 deletions(-)
>
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 0eab454..1e345ed 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -688,6 +688,22 @@ int arch_add_memory(int nid, u64 start, u64 size)
>
>   	return ret;
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(u64 start, u64 size)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	int ret;
> +
> +	ret = __remove_pages(start_pfn, nr_pages);
> +	if (ret)
> +		pr_warn("%s: Problem encountered in __remove_pages() as"
> +			" ret=%d\n", __func__,  ret);
> +
> +	return ret;
> +}
> +#endif
>   #endif
>
>   /*
> diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
> index baaafde..249cef4 100644
> --- a/arch/powerpc/mm/mem.c
> +++ b/arch/powerpc/mm/mem.c
> @@ -133,6 +133,20 @@ int arch_add_memory(int nid, u64 start, u64 size)
>
>   	return __add_pages(nid, zone, start_pfn, nr_pages);
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(u64 start, u64 size)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +
> +	start = (unsigned long)__va(start);
> +	if (remove_section_mapping(start, start + size))
> +		return -EINVAL;
> +
> +	return __remove_pages(start_pfn, nr_pages);
> +}
> +#endif
>   #endif /* CONFIG_MEMORY_HOTPLUG */
>
>   /*
> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
> index 2bea060..3de0d5b 100644
> --- a/arch/s390/mm/init.c
> +++ b/arch/s390/mm/init.c
> @@ -259,4 +259,12 @@ int arch_add_memory(int nid, u64 start, u64 size)
>   		vmem_remove_mapping(start, size);
>   	return rc;
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(u64 start, u64 size)
> +{
> +	/* TODO */
> +	return -EBUSY;
> +}
> +#endif
>   #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
> index 82cc576..fc84491 100644
> --- a/arch/sh/mm/init.c
> +++ b/arch/sh/mm/init.c
> @@ -558,4 +558,19 @@ int memory_add_physaddr_to_nid(u64 addr)
>   EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
>   #endif
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(u64 start, u64 size)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	int ret;
> +
> +	ret = __remove_pages(start_pfn, nr_pages);
> +	if (unlikely(ret))
> +		pr_warn("%s: Failed, __remove_pages() == %d\n", __func__,
> +			ret);
> +
> +	return ret;
> +}
> +#endif
>   #endif /* CONFIG_MEMORY_HOTPLUG */
> diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
> index 630dd2c..bdd8a99 100644
> --- a/arch/tile/mm/init.c
> +++ b/arch/tile/mm/init.c
> @@ -947,6 +947,14 @@ int remove_memory(u64 start, u64 size)
>   {
>   	return -EINVAL;
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(u64 start, u64 size)
> +{
> +	/* TODO */
> +	return -EBUSY;
> +}
> +#endif
>   #endif
>
>   struct kmem_cache *pgd_cache;
> diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
> index 575d86f..a690153 100644
> --- a/arch/x86/mm/init_32.c
> +++ b/arch/x86/mm/init_32.c
> @@ -842,6 +842,16 @@ int arch_add_memory(int nid, u64 start, u64 size)
>
>   	return __add_pages(nid, zone, start_pfn, nr_pages);
>   }
> +
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(unsigned long start, unsigned long size)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +
> +	return __remove_pages(start_pfn, nr_pages);
> +}
> +#endif
>   #endif
>
>   /*
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 9e635b3..78b94bc 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -675,6 +675,13 @@ int arch_add_memory(int nid, u64 start, u64 size)
>   }
>   EXPORT_SYMBOL_GPL(arch_add_memory);
>
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +int arch_remove_memory(unsigned long start, unsigned long size)
> +{
> +	/* TODO */
> +	return -EBUSY;
> +}
> +#endif

Why does not the function call __remove_pages()?

Thanks,
Yasuaki ishimatsu

>   #endif /* CONFIG_MEMORY_HOTPLUG */
>
>   static struct kcore_list kcore_vsyscall;
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index 2ba0a1a..8639799 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -84,6 +84,7 @@ extern void __online_page_free(struct page *page);
>
>   #ifdef CONFIG_MEMORY_HOTREMOVE
>   extern bool is_pageblock_removable_nolock(struct page *page);
> +extern int arch_remove_memory(unsigned long start, unsigned long size);
>   #endif /* CONFIG_MEMORY_HOTREMOVE */
>
>   /* reasonably generic interface to expand the physical pages in a zone  */
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index dccdf71..cc2c8b9 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1055,7 +1055,7 @@ int __ref remove_memory(int nid, u64 start, u64 size)
>   		unregister_one_node(nid);
>   	}
>
> -	__remove_pages(start >> PAGE_SHIFT, size >> PAGE_SHIFT);
> +	arch_remove_memory(start, size);
>   out:
>   	unlock_memory_hotplug();
>   	return ret;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
