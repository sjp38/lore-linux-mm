Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1559D6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 01:57:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g14so424254427ioj.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 22:57:10 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id z203si3697892oiz.27.2016.08.02.22.57.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 22:57:09 -0700 (PDT)
Message-ID: <57A186C6.9050301@huawei.com>
Date: Wed, 3 Aug 2016 13:53:10 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add restriction when memory_hotplug config enable
References: <1470063651-29519-1-git-send-email-zhongjiang@huawei.com> <20160801125417.ece9c623f03d952a60113a3f@linux-foundation.org> <57A078B1.6060408@virtuozzo.com>
In-Reply-To: <57A078B1.6060408@virtuozzo.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On 2016/8/2 18:40, Andrey Ryabinin wrote:
>
> On 08/01/2016 10:54 PM, Andrew Morton wrote:
>> On Mon, 1 Aug 2016 23:00:51 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>>
>>> From: zhong jiang <zhongjiang@huawei.com>
>>>
>>> At present, It is obvious that memory online and offline will fail
>>> when KASAN enable,
>> huh, I didn't know that.
> Ahem... https://lkml.kernel.org/r/<20150130133552.580f73b97a9bd007979b5419@linux-foundation.org>
>
> Also
>
> commit 786a8959912eb94fc2381c2ae487a96ce55dabca
>     kasan: disable memory hotplug
>     
>     Currently memory hotplug won't work with KASan.  As we don't have shadow
>     for hotplugged memory, kernel will crash on the first access to it.  To
>     make this work we will need to allocate shadow for new memory.
>     
>     At some future point proper memory hotplug support will be implemented.
>     Until then, print a warning at startup and disable memory hot-add.
>
>
>
>> What's the problem and are there plans to fix it?
> Nobody complained, so I didn't bother to fix it.
> The fix for this should be simple, I'll look into this.
>
>>>  therefore, it is necessary to add the condition
>>> to limit the memory_hotplug when KASAN enable.
>>>
> I don't understand why we need Kconfig dependency.
> Why is that better than runtime warn message?
  The user rarely care about the runtime warn message when the
  system is good running.  In fact, They are confilct with each other.
  For me,  I know the reason. but I always forget to do so. As a result,
  I test the memory hotplug fails again.  so, I hope to add the explicit dependency.
 
  Thanks
  zhongjiang
>>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>>> ---
>>>  mm/Kconfig | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/mm/Kconfig b/mm/Kconfig
>>> index 3e2daef..f6dd77e 100644
>>> --- a/mm/Kconfig
>>> +++ b/mm/Kconfig
>>> @@ -187,6 +187,7 @@ config MEMORY_HOTPLUG
>>>  	bool "Allow for memory hot-add"
>>>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>>>  	depends on ARCH_ENABLE_MEMORY_HOTPLUG
>>> +	depends on !KASAN
>>>  
>>>  config MEMORY_HOTPLUG_SPARSE
>>>  	def_bool y
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
