Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 33A916B0002
	for <linux-mm@kvack.org>; Sat, 20 Apr 2013 11:34:42 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z20so2391361dae.31
        for <linux-mm@kvack.org>; Sat, 20 Apr 2013 08:34:41 -0700 (PDT)
Message-ID: <5172B58A.3090006@gmail.com>
Date: Sat, 20 Apr 2013 23:34:34 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4, part3 01/15] mm: fix build warnings caused by free_reserved_area()
References: <1365256509-29024-1-git-send-email-jiang.liu@huawei.com> <1365256509-29024-2-git-send-email-jiang.liu@huawei.com> <20130419165208.GZ14496@n2100.arm.linux.org.uk>
In-Reply-To: <20130419165208.GZ14496@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, James Bottomley <James.Bottomley@HansenPartnership.com>, David Howells <dhowells@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Mark Salter <msalter@redhat.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

On 04/20/2013 12:52 AM, Russell King - ARM Linux wrote:
> On Sat, Apr 06, 2013 at 09:54:55PM +0800, Jiang Liu wrote:
>> Fix following build warnings cuased by free_reserved_area():
>>
>> arch/arm/mm/init.c: In function 'mem_init':
>> arch/arm/mm/init.c:603:2: warning: passing argument 1 of 'free_reserved_area' makes integer from pointer without a cast [enabled by default]
>>   free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, 0, NULL);
>>   ^
>> In file included from include/linux/mman.h:4:0,
>>                  from arch/arm/mm/init.c:15:
>> include/linux/mm.h:1301:22: note: expected 'long unsigned int' but argument is of type 'void *'
>>  extern unsigned long free_reserved_area(unsigned long start, unsigned long end,
>>
>>    mm/page_alloc.c: In function 'free_reserved_area':
>>>> mm/page_alloc.c:5134:3: warning: passing argument 1 of 'virt_to_phys' makes pointer from integer without a cast [enabled by default]
>>    In file included from arch/mips/include/asm/page.h:49:0,
>>                     from include/linux/mmzone.h:20,
>>                     from include/linux/gfp.h:4,
>>                     from include/linux/mm.h:8,
>>                     from mm/page_alloc.c:18:
>>    arch/mips/include/asm/io.h:119:29: note: expected 'const volatile void *' but argument is of type 'long unsigned int'
>>    mm/page_alloc.c: In function 'free_area_init_nodes':
>>    mm/page_alloc.c:5030:34: warning: array subscript is below array bounds [-Warray-bounds]
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Reported-by: Arnd Bergmann <arnd@arndb.de>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>> Cc: linux-mm@kvack.org
>> ---
>>  arch/arm/mm/init.c |    6 ++++--
>>  mm/page_alloc.c    |    2 +-
>>  2 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
>> index 9a5cdc0..7a82fcd 100644
>> --- a/arch/arm/mm/init.c
>> +++ b/arch/arm/mm/init.c
>> @@ -600,7 +600,8 @@ void __init mem_init(void)
>>  
>>  #ifdef CONFIG_SA1111
>>  	/* now that our DMA memory is actually so designated, we can free it */
>> -	free_reserved_area(__va(PHYS_PFN_OFFSET), swapper_pg_dir, 0, NULL);
>> +	free_reserved_area((unsigned long)__va(PHYS_PFN_OFFSET),
>> +			   (unsigned long)swapper_pg_dir, 0, NULL);
>>  #endif
>>  
>>  	free_highpages();
>> @@ -728,7 +729,8 @@ void free_initmem(void)
>>  	extern char __tcm_start, __tcm_end;
>>  
>>  	poison_init_mem(&__tcm_start, &__tcm_end - &__tcm_start);
>> -	free_reserved_area(&__tcm_start, &__tcm_end, 0, "TCM link");
>> +	free_reserved_area((unsigned long)&__tcm_start,
>> +			   (unsigned long)&__tcm_end, 0, "TCM link");
>>  #endif
>>  
>>  	poison_init_mem(__init_begin, __init_end - __init_begin);
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index e4923e9..8bf7956 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5196,7 +5196,7 @@ unsigned long free_reserved_area(unsigned long start, unsigned long end,
>>  	for (pages = 0; pos < end; pos += PAGE_SIZE, pages++) {
>>  		if (poison)
>>  			memset((void *)pos, poison, PAGE_SIZE);
>> -		free_reserved_page(virt_to_page(pos));
>> +		free_reserved_page(virt_to_page((void *)pos));
> 
> Don't all these casts suggest to you that you may have the type wrong
> in the first place?
> 
Hi Russell,
	Good question! 
	Originally free_reserved_area() is designed to simplify free_initrd_mem(), and 
free_initrd_mem() is declared as:
	void free_initrd_mem(unsigned long start, unsigned long end)
	So I have chosen "unsigned long" for free_reserved_area()'s first and second
parameters, otherwise it will cause much more type casts in function free_initrd_mem().
For code purity, we should use "void *" instead. So should we change to "void *" here?
	Regards!
	Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
