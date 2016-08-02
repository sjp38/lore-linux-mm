Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4C7C6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 06:39:42 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e139so354930004oib.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 03:39:42 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30139.outbound.protection.outlook.com. [40.107.3.139])
        by mx.google.com with ESMTPS id t142si927087oih.73.2016.08.02.03.39.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 03:39:40 -0700 (PDT)
Subject: Re: [PATCH] mm: add restriction when memory_hotplug config enable
References: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com>
 <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57A078B1.6060408@virtuozzo.com>
Date: Tue, 2 Aug 2016 13:40:49 +0300
MIME-Version: 1.0
In-Reply-To: <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com



On 08/01/2016 10:54 PM, Andrew Morton wrote:
> On Mon, 1 Aug 2016 23:00:51 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
> 
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> At present, It is obvious that memory online and offline will fail
>> when KASAN enable,
> 
> huh, I didn't know that.

Ahem... https://lkml.kernel.org/r/<20150130133552.580f73b97a9bd007979b5419@linux-foundation.org>

Also

commit 786a8959912eb94fc2381c2ae487a96ce55dabca
    kasan: disable memory hotplug
    
    Currently memory hotplug won't work with KASan.  As we don't have shadow
    for hotplugged memory, kernel will crash on the first access to it.  To
    make this work we will need to allocate shadow for new memory.
    
    At some future point proper memory hotplug support will be implemented.
    Until then, print a warning at startup and disable memory hot-add.



> What's the problem and are there plans to fix it?

Nobody complained, so I didn't bother to fix it.
The fix for this should be simple, I'll look into this.

> 
>>  therefore, it is necessary to add the condition
>> to limit the memory_hotplug when KASAN enable.
>>

I don't understand why we need Kconfig dependency.
Why is that better than runtime warn message?

>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  mm/Kconfig | 1 +
>>  1 file changed, 1 insertion(+)
>>
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 3e2daef..f6dd77e 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -187,6 +187,7 @@ config MEMORY_HOTPLUG
>>  	bool "Allow for memory hot-add"
>>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>>  	depends on ARCH_ENABLE_MEMORY_HOTPLUG
>> +	depends on !KASAN
>>  
>>  config MEMORY_HOTPLUG_SPARSE
>>  	def_bool y
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
