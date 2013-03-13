Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id BFCD26B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 01:38:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA9C03EE0C0
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:38:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B05F345DE55
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:38:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A5F945DE54
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:38:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C17F1DB8032
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:38:53 +0900 (JST)
Received: from g01jpexchkw30.g01.fujitsu.local (g01jpexchkw30.g01.fujitsu.local [10.0.193.113])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E426E08007
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 14:38:53 +0900 (JST)
Message-ID: <514010B8.2030304@jp.fujitsu.com>
Date: Wed, 13 Mar 2013 14:38:00 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2, part1 25/29] mm/x86: use common help functions to
 free reserved pages
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com> <1362896833-21104-26-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <1362896833-21104-26-git-send-email-jiang.liu@huawei.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>

Hi Jiang,

2013/03/10 15:27, Jiang Liu wrote:
> Use common help functions to free reserved pages.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> ---
>   arch/x86/mm/init.c    |    5 +----
>   arch/x86/mm/init_64.c |    5 ++---
>   2 files changed, 3 insertions(+), 7 deletions(-)
> 
> diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
> index 4903a03..4a705e6 100644
> --- a/arch/x86/mm/init.c
> +++ b/arch/x86/mm/init.c
> @@ -516,11 +516,8 @@ void free_init_pages(char *what, unsigned long begin, unsigned long end)

>   	printk(KERN_INFO "Freeing %s: %luk freed\n", what, (end - begin) >> 10);
>   
>   	for (; addr < end; addr += PAGE_SIZE) {
> -		ClearPageReserved(virt_to_page(addr));
> -		init_page_count(virt_to_page(addr));
>   		memset((void *)addr, POISON_FREE_INITMEM, PAGE_SIZE);
> -		free_page(addr);
> -		totalram_pages++;
> +		free_reserved_page(virt_to_page(addr));
>   	}

If I don't misread your code, avobe codes can replace to free_reserved_area()
as follow:

	free_reserved_area(addr, end, POISON_FREE_INITMEM, what)

Am I wrong?

Thanks,
Yasuaki Ishimatsu

>   #endif
>   }
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 474e28f..2ef81f1 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -1067,10 +1067,9 @@ void __init mem_init(void)
>   
>   	/* clear_bss() already clear the empty_zero_page */
>   
> -	reservedpages = 0;
> -
> -	/* this will put all low memory onto the freelists */
>   	register_page_bootmem_info();
> +
> +	/* this will put all memory onto the freelists */
>   	totalram_pages = free_all_bootmem();
>   
>   	absent_pages = absent_pages_in_range(0, max_pfn);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
