Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8E16B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 18:57:51 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so1749409pbb.13
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:57:50 -0700 (PDT)
In-Reply-To: <20130926155205.7f364b64c4a0fae77d4ca15d@linux-foundation.org>
References: <5241D897.1090905@gmail.com> <5241DA5B.8000909@gmail.com> <20130926155205.7f364b64c4a0fae77d4ca15d@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v5 4/6] x86/mem-hotplug: Support initialize page tables in bottom-up
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Thu, 26 Sep 2013 15:57:06 -0700
Message-ID: <59d57cc9-9f4b-4f28-95d0-a526bd0b9a29@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Can we put this in a common header somewhere?

Andrew Morton <akpm@linux-foundation.org> wrote:
>On Wed, 25 Sep 2013 02:30:51 +0800 Zhang Yanfei
><zhangyanfei.yes@gmail.com> wrote:
>
>> From: Tang Chen <tangchen@cn.fujitsu.com>
>> 
>> The Linux kernel cannot migrate pages used by the kernel. As a
>> result, kernel pages cannot be hot-removed. So we cannot allocate
>> hotpluggable memory for the kernel.
>> 
>> In a memory hotplug system, any numa node the kernel resides in
>> should be unhotpluggable. And for a modern server, each node could
>> have at least 16GB memory. So memory around the kernel image is
>> highly likely unhotpluggable.
>> 
>> ACPI SRAT (System Resource Affinity Table) contains the memory
>> hotplug info. But before SRAT is parsed, memblock has already
>> started to allocate memory for the kernel. So we need to prevent
>> memblock from doing this.
>> 
>> So direct memory mapping page tables setup is the case.
>init_mem_mapping()
>> is called before SRAT is parsed. To prevent page tables being
>allocated
>> within hotpluggable memory, we will use bottom-up direction to
>allocate
>> page tables from the end of kernel image to the higher memory.
>> 
>> ...
>>
>> +		kernel_end = __pa_symbol(_end);
>
>__pa_symbol() is implemented only on mips and x86.
>
>I stole the mips implementation like this:
>
>--- a/mm/memblock.c~a
>+++ a/mm/memblock.c
>@@ -187,8 +187,11 @@ phys_addr_t __init_memblock memblock_fin
> 	/* avoid allocating the first page */
> 	start = max_t(phys_addr_t, start, PAGE_SIZE);
> 	end = max(start, end);
>+#ifdef CONFIG_X86
> 	kernel_end = __pa_symbol(_end);
>-
>+#else
>+	kernel_end = __pa(RELOC_HIDE((unsigned long)(_end), 0));
>+#endif
> 	/*
> 	 * try bottom-up allocation only when bottom-up mode
> 	 * is set and @end is above the kernel image.
>
>just so I can get a -mm release out the door.

-- 
Sent from my mobile phone.  Please pardon brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
