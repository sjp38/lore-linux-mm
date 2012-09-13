Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 110A36B0123
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 21:58:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1561D3EE0B5
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:58:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id EF5CE45DE5A
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:58:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB9BD45DE50
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:58:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B85761DB803F
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:58:18 +0900 (JST)
Received: from g01jpexchkw10.g01.fujitsu.local (g01jpexchkw10.g01.fujitsu.local [10.0.194.49])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A2EA1DB803C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 10:58:18 +0900 (JST)
Message-ID: <50513DA8.1040909@jp.fujitsu.com>
Date: Thu, 13 Sep 2012 10:58:00 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memory-hotplug: don't replace lowmem pages with highmem
References: <1347414231-31451-1-git-send-email-minchan@kernel.org> <1347414231-31451-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1347414231-31451-2-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Nazarewicz <mina86@mina86.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>

2012/09/12 10:43, Minchan Kim wrote:
> [1] reporeted that lowmem pages could be replaced by
> highmem pages during migration of CMA and fixed.
> 
> Quote from [1]'s description
> "
>      The filesystem layer expects pages in the block device's mapping to not
>      be in highmem (the mapping's gfp mask is set in bdget()), but CMA can
>      currently replace lowmem pages with highmem pages, leading to crashes in
>      filesystem code such as the one below:
> 
>        Unable to handle kernel NULL pointer dereference at virtual address 00000400
>        pgd = c0c98000
>        [00000400] *pgd=00c91831, *pte=00000000, *ppte=00000000
>        Internal error: Oops: 817 [#1] PREEMPT SMP ARM
>        CPU: 0    Not tainted  (3.5.0-rc5+ #80)
>        PC is at __memzero+0x24/0x80
>        ...
>        Process fsstress (pid: 323, stack limit = 0xc0cbc2f0)
>        Backtrace:
>        [<c010e3f0>] (ext4_getblk+0x0/0x180) from [<c010e58c>] (ext4_bread+0x1c/0x98)
>        [<c010e570>] (ext4_bread+0x0/0x98) from [<c0117944>] (ext4_mkdir+0x160/0x3bc)
>         r4:c15337f0
>        [<c01177e4>] (ext4_mkdir+0x0/0x3bc) from [<c00c29e0>] (vfs_mkdir+0x8c/0x98)
>        [<c00c2954>] (vfs_mkdir+0x0/0x98) from [<c00c2a60>] (sys_mkdirat+0x74/0xac)
>         r6:00000000 r5:c152eb40 r4:000001ff r3:c14b43f0
>        [<c00c29ec>] (sys_mkdirat+0x0/0xac) from [<c00c2ab8>] (sys_mkdir+0x20/0x24)
>         r6:beccdcf0 r5:00074000 r4:beccdbbc
>        [<c00c2a98>] (sys_mkdir+0x0/0x24) from [<c000e3c0>] (ret_fast_syscall+0x0/0x30)
> "
> 
> Memory-hotplug has same problem with CMA so [1]'s fix could be applied
> with memory-hotplug, too.
> 
> Fix it by reusing.
> 
> [1] 6a6dccba2, mm: cma: don't replace lowmem pages with highmem
> 
> Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Wen Congyang <wency@cn.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>   mm/memory_hotplug.c |   15 ++++++---------
>   1 file changed, 6 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 4491a6b..fb71e5c 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -752,13 +752,6 @@ static unsigned long scan_lru_pages(unsigned long start, unsigned long end)
>   	return 0;
>   }
>   
> -static struct page *
> -hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
> -{
> -	/* This should be improooooved!! */
> -	return alloc_page(GFP_HIGHUSER_MOVABLE);
> -}
> -
>   #define NR_OFFLINE_AT_ONCE_PAGES	(256)
>   static int
>   do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> @@ -809,8 +802,12 @@ do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
>   			putback_lru_pages(&source);
>   			goto out;
>   		}
> -		/* this function returns # of failed pages */
> -		ret = migrate_pages(&source, hotremove_migrate_alloc, 0,
> +
> +		/*
> +		 * alloc_migrate_target should be improooooved!!
> +		 * migrate_pages returns # of failed pages.
> +		 */
> +		ret = migrate_pages(&source, alloc_migrate_target, 0,
>   							true, MIGRATE_SYNC);
>   		if (ret)
>   			putback_lru_pages(&source);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
