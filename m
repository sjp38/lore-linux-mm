Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9D56B0038
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 15:15:59 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id wn1so3451991obc.6
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 12:15:59 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id 11si17758985oij.129.2014.10.22.12.15.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Oct 2014 12:15:58 -0700 (PDT)
Message-ID: <1414004531.12798.27.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] memory-hotplug: Clear pgdat which is allocated by
 bootmem in try_offline_node()
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 22 Oct 2014 13:02:11 -0600
In-Reply-To: <54476215.3010006@jp.fujitsu.com>
References: <54476215.3010006@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhenzhang.zhang@huawei.com, wangnan0@huawei.com, tangchen@cn.fujitsu.com, dave.hansen@intel.com, rientjes@google.com

On Wed, 2014-10-22 at 16:51 +0900, Yasuaki Ishimatsu wrote:
> When hot adding the same memory after hot removing a memory,
> the following messages are shown:
> 
> WARNING: CPU: 20 PID: 6 at mm/page_alloc.c:4968 free_area_init_node+0x3fe/0x426()
> ...
> Call Trace:
>  [<...>] dump_stack+0x46/0x58
>  [<...>] warn_slowpath_common+0x81/0xa0
>  [<...>] warn_slowpath_null+0x1a/0x20
>  [<...>] free_area_init_node+0x3fe/0x426
>  [<...>] ? up+0x32/0x50
>  [<...>] hotadd_new_pgdat+0x90/0x110
>  [<...>] add_memory+0xd4/0x200
>  [<...>] acpi_memory_device_add+0x1aa/0x289
>  [<...>] acpi_bus_attach+0xfd/0x204
>  [<...>] ? device_register+0x1e/0x30
>  [<...>] acpi_bus_attach+0x178/0x204
>  [<...>] acpi_bus_scan+0x6a/0x90
>  [<...>] ? acpi_bus_get_status+0x2d/0x5f
>  [<...>] acpi_device_hotplug+0xe8/0x418
>  [<...>] acpi_hotplug_work_fn+0x1f/0x2b
>  [<...>] process_one_work+0x14e/0x3f0
>  [<...>] worker_thread+0x11b/0x510
>  [<...>] ? rescuer_thread+0x350/0x350
>  [<...>] kthread+0xe1/0x100
>  [<...>] ? kthread_create_on_node+0x1b0/0x1b0
>  [<...>] ret_from_fork+0x7c/0xb0
>  [<...>] ? kthread_create_on_node+0x1b0/0x1b0
> 
> The detaled explanation is as follows:
> 
> When hot removing memory, pgdat is set to 0 in try_offline_node().
> But if the pgdat is allocated by bootmem allocator, the clearing
> step is skipped. And when hot adding the same memory, the uninitialized
> pgdat is reused. But free_area_init_node() checks wether pgdat is set
> to zero. As a result, free_area_init_node() hits WARN_ON().
> 
> This patch clears pgdat which is allocated by bootmem allocator
> in try_offline_node().
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks for the update. It looks good.

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
