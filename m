Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84F6C6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 12:42:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 203so371169141pfy.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 09:42:03 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id dy1si2773666pab.117.2016.05.23.09.42.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 09:42:02 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id xk12so63975088pac.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 09:42:02 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: move page_ext_init after all struct pages are
 initialized
References: <1463696006-31360-1-git-send-email-yang.shi@linaro.org>
 <20160520131649.GC5197@dhcp22.suse.cz>
 <f0c27d67-3735-300b-76eb-e49d56ab7a10@linaro.org>
 <20160523073157.GD2278@dhcp22.suse.cz>
From: "Shi, Yang" <yang.shi@linaro.org>
Message-ID: <dfdab52b-f6dc-b72a-58a3-2884aaa2254c@linaro.org>
Date: Mon, 23 May 2016 09:42:00 -0700
MIME-Version: 1.0
In-Reply-To: <20160523073157.GD2278@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On 5/23/2016 12:31 AM, Michal Hocko wrote:
> On Fri 20-05-16 08:41:09, Shi, Yang wrote:
>> On 5/20/2016 6:16 AM, Michal Hocko wrote:
>>> On Thu 19-05-16 15:13:26, Yang Shi wrote:
>>> [...]
>>>> diff --git a/init/main.c b/init/main.c
>>>> index b3c6e36..2075faf 100644
>>>> --- a/init/main.c
>>>> +++ b/init/main.c
>>>> @@ -606,7 +606,6 @@ asmlinkage __visible void __init start_kernel(void)
>>>>  		initrd_start = 0;
>>>>  	}
>>>>  #endif
>>>> -	page_ext_init();
>>>>  	debug_objects_mem_init();
>>>>  	kmemleak_init();
>>>>  	setup_per_cpu_pageset();
>>>> @@ -1004,6 +1003,8 @@ static noinline void __init kernel_init_freeable(void)
>>>>  	sched_init_smp();
>>>>
>>>>  	page_alloc_init_late();
>>>> +	/* Initialize page ext after all struct pages are initializaed */
>>>> +	page_ext_init();
>>>>
>>>>  	do_basic_setup();
>>>
>>> I might be missing something but don't we have the same problem with
>>> CONFIG_FLATMEM? page_ext_init_flatmem is called way earlier. Or
>>> CONFIG_DEFERRED_STRUCT_PAGE_INIT is never enabled for CONFIG_FLATMEM?
>>
>> Yes, CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on MEMORY_HOTPLUG which
>> depends on SPARSEMEM. So, this config is not valid for FLATMEM at all.
>
> Well
> config MEMORY_HOTPLUG
>         bool "Allow for memory hot-add"
> 	depends on SPARSEMEM || X86_64_ACPI_NUMA
> 	depends on ARCH_ENABLE_MEMORY_HOTPLUG
>
> I wasn't really sure about X86_64_ACPI_NUMA dependency branch which
> depends on X86_64 && NUMA && ACPI && PCI and that didn't sound like
> SPARSEMEM only. If the FLATMEM shouldn't exist with

Actually, FLATMEMT depends on !NUMA.

> CONFIG_DEFERRED_STRUCT_PAGE_INIT can we make that explicit please?

Sure, it makes the condition clearer and more readable.

Thanks,
Yang

>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
