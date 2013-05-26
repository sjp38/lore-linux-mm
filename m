Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id ABDA76B00BE
	for <linux-mm@kvack.org>; Sun, 26 May 2013 09:55:44 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so5897347pbb.34
        for <linux-mm@kvack.org>; Sun, 26 May 2013 06:55:43 -0700 (PDT)
Message-ID: <51A21456.50400@gmail.com>
Date: Sun, 26 May 2013 21:55:34 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5, part4 16/41] mm/blackfin: prepare for removing num_physpages
 and simplify mem_init()
References: <1368028298-7401-1-git-send-email-jiang.liu@huawei.com> <1368028298-7401-17-git-send-email-jiang.liu@huawei.com> <CAJxxZ0Ous_4_QCM7dyDkDHyHiLiib3Gr70Z22-ac0u275shfSQ@mail.gmail.com>
In-Reply-To: <CAJxxZ0Ous_4_QCM7dyDkDHyHiLiib3Gr70Z22-ac0u275shfSQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sonic Zhang <sonic.adi@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, David Rientjes <rientjes@google.com>, Wen Congyang <wency@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, James Bottomley <james.bottomley@hansenpartnership.com>, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>, David Howells <dhowells@redhat.com>, Mark Salter <msalter@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-arch@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>, Mike Frysinger <vapier@gentoo.org>, Bob Liu <lliubbo@gmail.com>, uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>

On Sat 25 May 2013 09:25:47 PM CST, Sonic Zhang wrote:
> Hi Jiang
>
> On Wed, May 8, 2013 at 11:51 PM, Jiang Liu <liuj97@gmail.com> wrote:
>> Prepare for removing num_physpages and simplify mem_init().
>>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>> Cc: Mike Frysinger <vapier@gentoo.org>
>> Cc: Bob Liu <lliubbo@gmail.com>
>> Cc: uclinux-dist-devel@blackfin.uclinux.org
>> Cc: linux-kernel@vger.kernel.org
>> ---
>>  arch/blackfin/mm/init.c |   38 ++++++--------------------------------
>>  1 file changed, 6 insertions(+), 32 deletions(-)
>>
>> diff --git a/arch/blackfin/mm/init.c b/arch/blackfin/mm/init.c
>> index 1cc8607..e4b6e11 100644
>> --- a/arch/blackfin/mm/init.c
>> +++ b/arch/blackfin/mm/init.c
>> @@ -90,43 +90,17 @@ asmlinkage void __init init_pda(void)
>>
>>  void __init mem_init(void)
>>  {
>> -       unsigned int codek = 0, datak = 0, initk = 0;
>> -       unsigned int reservedpages = 0, freepages = 0;
>> -       unsigned long tmp;
>> -       unsigned long start_mem = memory_start;
>> -       unsigned long end_mem = memory_end;
>> +       char buf[64];
>>
>> -       end_mem &= PAGE_MASK;
>> -       high_memory = (void *)end_mem;
>> -
>> -       start_mem = PAGE_ALIGN(start_mem);
>> -       max_mapnr = num_physpages = MAP_NR(high_memory);
>> -       printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", num_physpages);
>> +       high_memory = (void *)(memory_end & PAGE_MASK);
>> +       max_mapnr = MAP_NR(high_memory);
>> +       printk(KERN_DEBUG "Kernel managed physical pages: %lu\n", max_mapnr);
>>
>>         /* This will put all low memory onto the freelists. */
>>         free_all_bootmem();
>>
>> -       reservedpages = 0;
>> -       for (tmp = ARCH_PFN_OFFSET; tmp < max_mapnr; tmp++)
>> -               if (PageReserved(pfn_to_page(tmp)))
>> -                       reservedpages++;
>> -       freepages =  max_mapnr - ARCH_PFN_OFFSET - reservedpages;
>> -
>> -       /* do not count in kernel image between _rambase and _ramstart */
>> -       reservedpages -= (_ramstart - _rambase) >> PAGE_SHIFT;
>> -#if (defined(CONFIG_BFIN_EXTMEM_ICACHEABLE) && ANOMALY_05000263)
>> -       reservedpages += (_ramend - memory_end - DMA_UNCACHED_REGION) >> PAGE_SHIFT;
>> -#endif
>> -
>> -       codek = (_etext - _stext) >> 10;
>> -       initk = (__init_end - __init_begin) >> 10;
>> -       datak = ((_ramstart - _rambase) >> 10) - codek - initk;
>> -
>> -       printk(KERN_INFO
>> -            "Memory available: %luk/%luk RAM, "
>> -               "(%uk init code, %uk kernel code, %uk data, %uk dma, %uk reserved)\n",
>> -               (unsigned long) freepages << (PAGE_SHIFT-10), (_ramend - CONFIG_PHY_RAM_BASE_ADDRESS) >> 10,
>> -               initk, codek, datak, DMA_UNCACHED_REGION >> 10, (reservedpages << (PAGE_SHIFT-10)));
>
> You can't remove all these memory information for blackfin. They are
> useful on blackfin platform.
>
> Regards,
>
> Sonic

Hi Sonic,
           Thanks for review!
           We are not trying to remove these code, but replacing it 
with a generic
helper function mem_init_print_info(), which will print similar (actual 
more info)
boot message. I have no blackfin platforms to generate a real boot 
message,
so could only share an example boot messages on x86:
Memory: 7744624K/8074824K available (6969K kernel code, 1011K data, 
2828K rodata, 1016K init, 9640K bss, 330200K reserved)

Regards!
Gerry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
