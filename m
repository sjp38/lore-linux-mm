Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8DB6B0254
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 03:20:55 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so60931547pab.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 00:20:54 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id w7si37030482pbt.197.2015.08.26.00.20.53
        for <linux-mm@kvack.org>;
        Wed, 26 Aug 2015 00:20:54 -0700 (PDT)
Message-ID: <55DD6877.6080709@cn.fujitsu.com>
Date: Wed, 26 Aug 2015 15:19:19 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memory-hotplug: remove reset_node_managed_pages()
 and reset_node_managed_pages() in hotadd_new_pgdat()
References: <55C9A3A9.5090300@huawei.com> <55C9A554.4090509@huawei.com> <55D9A036.7060506@cn.fujitsu.com> <55DAE113.20503@huawei.com> <55DAE666.5020302@cn.fujitsu.com> <55DAFEEB.4050601@huawei.com>
In-Reply-To: <55DAFEEB.4050601@huawei.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>


On 08/24/2015 07:24 PM, Xishi Qiu wrote:
> ......
>>>> [ 2007.584000] On node 5 totalpages: 0
>>>> [ 2007.585000] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 32588823
>>>> [ 2007.594000] Policy zone: Normal
>>>> [ 2007.598000] init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
>>>>
>>>>
>>>> And also, if we merge this patch, /sys/devices/system/node/nodeX/meminfo will break.
>>>>
>>> trigger call trace?
>> No. There is no error output. But if you see /sys/devices/system/node/nodeX/meminfo,
>> memory size will double because totalpages is calculated once here, and one more time
>> when onlining memory.
>>
> Hi Tang,
>
> Do you mean si_meminfo_node() -> val->totalram = managed_pages; will be added double?
> But my patch will keep it 0 in hotadd_new_pgdat(), so it will not be double, right?
>

Hi,

I mean this:

online_pages()
|--> zone->zone_pgdat->node_present_pages += onlined_pages;

It will be double.

Since meminfo data is retrieved from these kernel structures, /proc/meminfo
will be broken.


Actually speaking, reset it when hot-adding memory is not a good idea.
We should make the memory init code be suitable for both boot code and
memory hot-plug code.


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
