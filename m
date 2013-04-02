Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5F86C6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 01:31:38 -0400 (EDT)
Received: from mail-lb0-f178.google.com (assp.southpole.se [37.247.8.10])
	by mail.southpole.se (Postfix) with ESMTPSA id F3C8C4802F1
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 07:31:35 +0200 (CEST)
Received: by mail-lb0-f178.google.com with SMTP id q13so106094lbi.37
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 22:31:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1362896833-21104-17-git-send-email-jiang.liu@huawei.com>
References: <1362896833-21104-1-git-send-email-jiang.liu@huawei.com>
	<1362896833-21104-17-git-send-email-jiang.liu@huawei.com>
Date: Tue, 2 Apr 2013 07:31:35 +0200
Message-ID: <CACM3HyFn-DZukNtftCCQmLBEBvQ4GZdgc1wu-hPsyq-qX2Ef0w@mail.gmail.com>
Subject: Re: [PATCH v2, part1 16/29] mm/openrisc: use common help functions to
 free reserved pages
From: Jonas Bonn <jonas@southpole.se>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 10 March 2013 07:26, Jiang Liu <liuj97@gmail.com> wrote:
> Use common help functions to free reserved pages.
> Also include <asm/sections.h> to avoid local declarations.
>
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Cc: Jonas Bonn <jonas@southpole.se>

Tested and works fine on OpenRISC.

Acked-by: Jonas Bonn <jonas@southpole.se>

/Jonas

> ---
>  arch/openrisc/mm/init.c |   27 +++------------------------
>  1 file changed, 3 insertions(+), 24 deletions(-)
>
> diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
> index e7fdc50..b3cbc67 100644
> --- a/arch/openrisc/mm/init.c
> +++ b/arch/openrisc/mm/init.c
> @@ -43,6 +43,7 @@
>  #include <asm/kmap_types.h>
>  #include <asm/fixmap.h>
>  #include <asm/tlbflush.h>
> +#include <asm/sections.h>
>
>  int mem_init_done;
>
> @@ -201,9 +202,6 @@ void __init paging_init(void)
>
>  /* References to section boundaries */
>
> -extern char _stext, _etext, _edata, __bss_start, _end;
> -extern char __init_begin, __init_end;
> -
>  static int __init free_pages_init(void)
>  {
>         int reservedpages, pfn;
> @@ -263,30 +261,11 @@ void __init mem_init(void)
>  #ifdef CONFIG_BLK_DEV_INITRD
>  void free_initrd_mem(unsigned long start, unsigned long end)
>  {
> -       printk(KERN_INFO "Freeing initrd memory: %ldk freed\n",
> -              (end - start) >> 10);
> -
> -       for (; start < end; start += PAGE_SIZE) {
> -               ClearPageReserved(virt_to_page(start));
> -               init_page_count(virt_to_page(start));
> -               free_page(start);
> -               totalram_pages++;
> -       }
> +       free_reserved_area(start, end, 0, "initrd");
>  }
>  #endif
>
>  void free_initmem(void)
>  {
> -       unsigned long addr;
> -
> -       addr = (unsigned long)(&__init_begin);
> -       for (; addr < (unsigned long)(&__init_end); addr += PAGE_SIZE) {
> -               ClearPageReserved(virt_to_page(addr));
> -               init_page_count(virt_to_page(addr));
> -               free_page(addr);
> -               totalram_pages++;
> -       }
> -       printk(KERN_INFO "Freeing unused kernel memory: %luk freed\n",
> -              ((unsigned long)&__init_end -
> -               (unsigned long)&__init_begin) >> 10);
> +       free_initmem_default(0);
>  }
> --
> 1.7.9.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
