Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 141FE6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 17:16:13 -0400 (EDT)
Date: Tue, 16 Apr 2013 14:16:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/3] mem-hotplug: Put kernel_physical_mapping_remove()
 declaration in CONFIG_MEMORY_HOTREMOVE.
Message-Id: <20130416141610.0da7b7dad5927d9c84fb4943@linux-foundation.org>
In-Reply-To: <1366019207-27818-3-git-send-email-tangchen@cn.fujitsu.com>
References: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
	<1366019207-27818-3-git-send-email-tangchen@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: gregkh@linuxfoundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Mon, 15 Apr 2013 17:46:46 +0800 Tang Chen <tangchen@cn.fujitsu.com> wrote:

> kernel_physical_mapping_remove() is only called by arch_remove_memory() in
> init_64.c, which is enclosed in CONFIG_MEMORY_HOTREMOVE. So when we don't
> configure CONFIG_MEMORY_HOTREMOVE, the compiler will give a warning:
> 
> 	warning: ___kernel_physical_mapping_remove___ defined but not used
> 
> So put kernel_physical_mapping_remove() in CONFIG_MEMORY_HOTREMOVE.
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> ---
>  arch/x86/mm/init_64.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 474e28f..dafdeb2 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1019,6 +1019,7 @@ void __ref vmemmap_free(struct page *memmap, unsigned long nr_pages)
>  	remove_pagetable(start, end, false);
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void __meminit
>  kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  {
> @@ -1028,7 +1029,6 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
>  	remove_pagetable(start, end, true);
>  }
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  int __ref arch_remove_memory(u64 start, u64 size)
>  {
>  	unsigned long start_pfn = start >> PAGE_SHIFT;

Thanks.  I already have this one queued in
http://ozlabs.org/~akpm/mmots/broken-out/arch-x86-mm-init_64c-fix-build-warning-when-config_memory_hotremove=n.patch,
within my "send it to the x86 maintainers" section.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
