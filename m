Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 2FCD96B0039
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 17:32:20 -0400 (EDT)
Message-ID: <1371591120.13194.10.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm, sparse: Put clear_hwpoisoned_pages within
 CONFIG_MEMORY_HOTREMOVE
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 18 Jun 2013 15:32:00 -0600
In-Reply-To: <51C06F51.2030704@gmail.com>
References: <51C06F51.2030704@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 2013-06-18 at 22:31 +0800, Zhang Yanfei wrote:
> From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> With CONFIG_MEMORY_HOTREMOVE unset, there is a compile warning:
> 
> mm/sparse.c:755: warning: a??clear_hwpoisoned_pagesa?? defined but not used
> 
> And Bisecting it ended up pointing to:
> 
> commit 4edd7ceff0662afde195da6f6c43e7cbe1ed2dc4
> Author: David Rientjes <rientjes@google.com>
> Date:   Mon Apr 29 15:08:22 2013 -0700
> 
>     mm, hotplug: avoid compiling memory hotremove functions when disabled
>     
>     __remove_pages() is only necessary for CONFIG_MEMORY_HOTREMOVE.  PowerPC
>     pseries will return -EOPNOTSUPP if unsupported.
>     
>     Adding an #ifdef causes several other functions it depends on to also
>     become unnecessary, which saves in .text when disabled (it's disabled in
>     most defconfigs besides powerpc, including x86).  remove_memory_block()
>     becomes static since it is not referenced outside of
>     drivers/base/memory.c.
>     
>     Build tested on x86 and powerpc with CONFIG_MEMORY_HOTREMOVE both enabled
>     and disabled.
>     
>     Signed-off-by: David Rientjes <rientjes@google.com>
>     Acked-by: Toshi Kani <toshi.kani@hp.com>
>     Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>     Cc: Paul Mackerras <paulus@samba.org>
>     Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>     Cc: Wen Congyang <wency@cn.fujitsu.com>
>     Cc: Tang Chen <tangchen@cn.fujitsu.com>
>     Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> This is because the commit above put function sparse_remove_one_section
> within the protection of CONFIG_MEMORY_HOTREMOVE but the only user of
> function clear_hwpoisoned_pages is sparse_remove_one_section, and it
> is not within the protection of CONFIG_MEMORY_HOTREMOVE.
> 
> So put clear_hwpoisoned_pages within CONFIG_MEMORY_HOTREMOVE should
> fix the warning.
> 
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Toshi Kani <toshi.kani@hp.com>

Looks good.

Acked-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi


>  mm/sparse.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 1c91f0d..999a1fe 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -751,6 +751,7 @@ out:
>  	return ret;
>  }
>  
> +#ifdef CONFIG_MEMORY_HOTREMOVE
>  #ifdef CONFIG_MEMORY_FAILURE
>  static void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  {
> @@ -772,7 +773,6 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
>  }
>  #endif
>  
> -#ifdef CONFIG_MEMORY_HOTREMOVE
>  static void free_section_usemap(struct page *memmap, unsigned long *usemap)
>  {
>  	struct page *usemap_page;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
