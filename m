Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7836B0253
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 04:51:27 -0500 (EST)
Received: by ykdr82 with SMTP id r82so152347108ykd.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 01:51:26 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id y81si9546809ywy.200.2015.11.20.01.51.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Nov 2015 01:51:26 -0800 (PST)
Message-ID: <564EEC06.9030501@huawei.com>
Date: Fri, 20 Nov 2015 17:46:46 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: direct mapping count in /proc/meminfo is error
References: <564ED708.5090405@huawei.com> <564EDD3F.6070302@cn.fujitsu.com>
In-Reply-To: <564EDD3F.6070302@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/11/20 16:43, Tang Chen wrote:

> Hi Shi,
> 
> Would you please share where did you add the printk debug info ?
> 

Sure, at the end of init_mem_mapping(), I add a new function, like arch_report_meminfo(),
just change "seq_printf" to "printk".

Thanks,
Xishi Qiu

> Thanks. :)
> 
> On 11/20/2015 04:17 PM, Xishi Qiu wrote:
>> I find the direct mapping count in /proc/meminfo is error.
>> The value should be equal to the size of init_memory_mapping which
>> showed in boot log.
>>
>> I add some print to show direct_pages_count[] immediately after
>> init_memory_mapping(). The reason is that we double counting.
>>
>> Here is the log(kernel v4.4):
>> ...
>> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]  // called from "init_memory_mapping(0, ISA_END_ADDRESS);"
>> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
>> [    0.000000] BRK [0x01ebf000, 0x01ebffff] PGTABLE
>> [    0.000000] BRK [0x01ec0000, 0x01ec0fff] PGTABLE
>> [    0.000000] BRK [0x01ec1000, 0x01ec1fff] PGTABLE
>> [    0.000000] init_memory_mapping: [mem 0xc3fe00000-0xc3fffffff]  // called from "memory_map_top_down(ISA_END_ADDRESS, end);"
>> [    0.000000]  [mem 0xc3fe00000-0xc3fffffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) one time
>> [    0.000000] init_memory_mapping: [mem 0xc20000000-0xc3fdfffff]
>> [    0.000000]  [mem 0xc20000000-0xc3fdfffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) two time
>> [    0.000000] init_memory_mapping: [mem 0x00100000-0xbf78ffff]
>> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
>> [    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
>> [    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
>> [    0.000000]  [mem 0x80000000-0xbf5fffff] page 2M
>> [    0.000000]  [mem 0xbf600000-0xbf78ffff] page 4k
>> [    0.000000] init_memory_mapping: [mem 0x100000000-0xc1fffffff]
>> [    0.000000]  [mem 0x100000000-0xc1fffffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) three time
>> ...
>> [    0.000000] DirectMap4k:        3648 kB
>> [    0.000000] DirectMap2M:     2084864 kB
>> [    0.000000] DirectMap1G:    50331648 kB
>>
>> euler-linux:~ # cat /proc/meminfo | grep DirectMap
>> DirectMap4k:       91712 kB
>> DirectMap2M:     4093952 kB
>> DirectMap1G:    48234496 kB
>>
>>
>> total DirectMap is 48234496 + 4093952 + 91712 = 52420160kb
>>             50331648 + 2084864 + 3648 = 52420160kb
>> total init_memory_mapping is 50323008kb
>>
>> 52420160kb - 50323008kb = 2097152kb = 2G
>>
>> However I haven't find a better way to fix it, any ideas?
>>
>> Thanks,
>> Xishi Qiu
>>
>>
>> .
>>
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
