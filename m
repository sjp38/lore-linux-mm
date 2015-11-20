Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 03F3E6B0255
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 03:46:31 -0500 (EST)
Received: by pacej9 with SMTP id ej9so110342832pac.2
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 00:46:30 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id a1si17657745pas.56.2015.11.20.00.46.29
        for <linux-mm@kvack.org>;
        Fri, 20 Nov 2015 00:46:30 -0800 (PST)
Message-ID: <564EDD3F.6070302@cn.fujitsu.com>
Date: Fri, 20 Nov 2015 16:43:43 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: direct mapping count in /proc/meminfo is error
References: <564ED708.5090405@huawei.com>
In-Reply-To: <564ED708.5090405@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Shi,

Would you please share where did you add the printk debug info ?

Thanks. :)

On 11/20/2015 04:17 PM, Xishi Qiu wrote:
> I find the direct mapping count in /proc/meminfo is error.
> The value should be equal to the size of init_memory_mapping which
> showed in boot log.
>
> I add some print to show direct_pages_count[] immediately after
> init_memory_mapping(). The reason is that we double counting.
>
> Here is the log(kernel v4.4):
> ...
> [    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]  // called from "init_memory_mapping(0, ISA_END_ADDRESS);"
> [    0.000000]  [mem 0x00000000-0x000fffff] page 4k
> [    0.000000] BRK [0x01ebf000, 0x01ebffff] PGTABLE
> [    0.000000] BRK [0x01ec0000, 0x01ec0fff] PGTABLE
> [    0.000000] BRK [0x01ec1000, 0x01ec1fff] PGTABLE
> [    0.000000] init_memory_mapping: [mem 0xc3fe00000-0xc3fffffff]  // called from "memory_map_top_down(ISA_END_ADDRESS, end);"
> [    0.000000]  [mem 0xc3fe00000-0xc3fffffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) one time
> [    0.000000] init_memory_mapping: [mem 0xc20000000-0xc3fdfffff]
> [    0.000000]  [mem 0xc20000000-0xc3fdfffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) two time
> [    0.000000] init_memory_mapping: [mem 0x00100000-0xbf78ffff]
> [    0.000000]  [mem 0x00100000-0x001fffff] page 4k
> [    0.000000]  [mem 0x00200000-0x3fffffff] page 2M
> [    0.000000]  [mem 0x40000000-0x7fffffff] page 1G
> [    0.000000]  [mem 0x80000000-0xbf5fffff] page 2M
> [    0.000000]  [mem 0xbf600000-0xbf78ffff] page 4k
> [    0.000000] init_memory_mapping: [mem 0x100000000-0xc1fffffff]
> [    0.000000]  [mem 0x100000000-0xc1fffffff] page 1G  // increase count of PG_LEVEL_1G in c00000000(48G)-c3fffffff(49G) three time
> ...
> [    0.000000] DirectMap4k:        3648 kB
> [    0.000000] DirectMap2M:     2084864 kB
> [    0.000000] DirectMap1G:    50331648 kB
>
> euler-linux:~ # cat /proc/meminfo | grep DirectMap
> DirectMap4k:       91712 kB
> DirectMap2M:     4093952 kB
> DirectMap1G:    48234496 kB
>
>
> total DirectMap is 48234496 + 4093952 + 91712 = 52420160kb
> 		    50331648 + 2084864 + 3648 = 52420160kb
> total init_memory_mapping is 50323008kb
>
> 52420160kb - 50323008kb = 2097152kb = 2G
>
> However I haven't find a better way to fix it, any ideas?
>
> Thanks,
> Xishi Qiu
>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
