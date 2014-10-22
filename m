Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 90D1E6B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 18:47:00 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so167218pab.6
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 15:47:00 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id cq3si15252215pbb.193.2014.10.22.15.46.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 15:46:59 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id BDF9B3EE0B6
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:46:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id B73EDAC07F1
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:46:56 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 69E4C1DB8038
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:46:56 +0900 (JST)
Message-ID: <54483398.7040005@jp.fujitsu.com>
Date: Thu, 23 Oct 2014 07:45:44 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memory-hotplug: Clear pgdat which is allocated by
 bootmem in try_offline_node()
References: <54476215.3010006@jp.fujitsu.com> <1414004531.12798.27.camel@misato.fc.hp.com>
In-Reply-To: <1414004531.12798.27.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, tangchen@cn.fujitsu.com, dave.hansen@intel.com, rientjes@google.com

(2014/10/23 4:02), Toshi Kani wrote:
> On Wed, 2014-10-22 at 16:51 +0900, Yasuaki Ishimatsu wrote:
>> When hot adding the same memory after hot removing a memory,
>> the following messages are shown:
>>
>> WARNING: CPU: 20 PID: 6 at mm/page_alloc.c:4968 free_area_init_node+0x3fe/0x426()
>> ...
>> Call Trace:
>>   [<...>] dump_stack+0x46/0x58
>>   [<...>] warn_slowpath_common+0x81/0xa0
>>   [<...>] warn_slowpath_null+0x1a/0x20
>>   [<...>] free_area_init_node+0x3fe/0x426
>>   [<...>] ? up+0x32/0x50
>>   [<...>] hotadd_new_pgdat+0x90/0x110
>>   [<...>] add_memory+0xd4/0x200
>>   [<...>] acpi_memory_device_add+0x1aa/0x289
>>   [<...>] acpi_bus_attach+0xfd/0x204
>>   [<...>] ? device_register+0x1e/0x30
>>   [<...>] acpi_bus_attach+0x178/0x204
>>   [<...>] acpi_bus_scan+0x6a/0x90
>>   [<...>] ? acpi_bus_get_status+0x2d/0x5f
>>   [<...>] acpi_device_hotplug+0xe8/0x418
>>   [<...>] acpi_hotplug_work_fn+0x1f/0x2b
>>   [<...>] process_one_work+0x14e/0x3f0
>>   [<...>] worker_thread+0x11b/0x510
>>   [<...>] ? rescuer_thread+0x350/0x350
>>   [<...>] kthread+0xe1/0x100
>>   [<...>] ? kthread_create_on_node+0x1b0/0x1b0
>>   [<...>] ret_from_fork+0x7c/0xb0
>>   [<...>] ? kthread_create_on_node+0x1b0/0x1b0
>>
>> The detaled explanation is as follows:
>>
>> When hot removing memory, pgdat is set to 0 in try_offline_node().
>> But if the pgdat is allocated by bootmem allocator, the clearing
>> step is skipped. And when hot adding the same memory, the uninitialized
>> pgdat is reused. But free_area_init_node() checks wether pgdat is set
>> to zero. As a result, free_area_init_node() hits WARN_ON().
>>
>> This patch clears pgdat which is allocated by bootmem allocator
>> in try_offline_node().
>>
>> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
>
> Thanks for the update. It looks good.
>

> Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thank you for your  review.

Thanks,
Yasuaki Ishimatasu

>
> -Toshi
>
>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
