Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4FF0E6B0032
	for <linux-mm@kvack.org>; Sun,  6 Oct 2013 20:02:22 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id up15so6303339pbc.26
        for <linux-mm@kvack.org>; Sun, 06 Oct 2013 17:02:21 -0700 (PDT)
Message-ID: <5251F9AB.6000203@zytor.com>
Date: Sun, 06 Oct 2013 17:00:43 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com>
In-Reply-To: <524E2127.4090904@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Tejun Heo <tj@kernel.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 10/03/2013 07:00 PM, Zhang Yanfei wrote:
> From: Tang Chen <tangchen@cn.fujitsu.com>
> 
> The Linux kernel cannot migrate pages used by the kernel. As a
> result, kernel pages cannot be hot-removed. So we cannot allocate
> hotpluggable memory for the kernel.
> 
> In a memory hotplug system, any numa node the kernel resides in
> should be unhotpluggable. And for a modern server, each node could
> have at least 16GB memory. So memory around the kernel image is
> highly likely unhotpluggable.
> 
> ACPI SRAT (System Resource Affinity Table) contains the memory
> hotplug info. But before SRAT is parsed, memblock has already
> started to allocate memory for the kernel. So we need to prevent
> memblock from doing this.
> 
> So direct memory mapping page tables setup is the case. init_mem_mapping()
> is called before SRAT is parsed. To prevent page tables being allocated
> within hotpluggable memory, we will use bottom-up direction to allocate
> page tables from the end of kernel image to the higher memory.
> 
> Acked-by: Tejun Heo <tj@kernel.org>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

I'm still seriously concerned about this.  This unconditionally
introduces new behavior which may very well break some classes of
systems -- the whole point of creating the page tables top down is
because the kernel tends to be allocated in lower memory, which is also
the memory that some devices need for DMA.

+#ifdef CONFIG_X86
+		kernel_end = __pa_symbol(_end);
+#else
+		kernel_end = __pa(RELOC_HIDE((unsigned long)(_end), 0));
+#endif

We really should make __pa_symbol() available everywhere by putting
something like the above in a global define (under #ifndef __pa_symbol).

Is RELOC_HIDE() even correct here?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
