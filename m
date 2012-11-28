Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 84A426B0074
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 22:24:36 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t49so4177911wey.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 19:24:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50B4B6BE.3000902@cn.fujitsu.com>
References: <1353667445-7593-1-git-send-email-tangchen@cn.fujitsu.com>
	<CAA_GA1d7CxHvmZELvD_DO6u5tu1WBqfmLiuEzeFo=xMzuW50Tg@mail.gmail.com>
	<50B479FA.6010307@cn.fujitsu.com>
	<CAA_GA1ezZJyqVL=Dp5U2zzNw6bkfMKJY_STkt3E7TXkUYcv+jQ@mail.gmail.com>
	<50B4B6BE.3000902@cn.fujitsu.com>
Date: Wed, 28 Nov 2012 11:24:34 +0800
Message-ID: <CAA_GA1fE0fhLVs50rRZ6OsTw7DV0hyVC2EuRyUrbzxLztPLoeg@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] Add movablecore_map boot option
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: hpa@zytor.com, akpm@linux-foundation.org, rob@landley.net, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, linfeng@cn.fujitsu.com, jiang.liu@huawei.com, yinghai@kernel.org, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, rusty@rustcorp.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, m.szyprowski@samsung.com

On Tue, Nov 27, 2012 at 8:49 PM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> On 11/27/2012 08:09 PM, Bob Liu wrote:
>>
>> On Tue, Nov 27, 2012 at 4:29 PM, Tang Chen<tangchen@cn.fujitsu.com>
>> wrote:
>>>
>>> Hi Liu,
>>>
>>>
>>> This feature is used in memory hotplug.
>>>
>>> In order to implement a whole node hotplug, we need to make sure the
>>> node contains no kernel memory, because memory used by kernel could
>>> not be migrated. (Since the kernel memory is directly mapped,
>>> VA = PA + __PAGE_OFFSET. So the physical address could not be changed.)
>>>
>>> User could specify all the memory on a node to be movable, so that the
>>> node could be hot-removed.
>>>
>>
>> Thank you for your explanation. It's reasonable.
>>
>> But i think it's a bit duplicated with CMA, i'm not sure but maybe we
>> can combine it with CMA which already in mainline?
>>
> Hi Liu,
>
> Thanks for your advice. :)
>
> CMA is Contiguous Memory Allocator, right?  What I'm trying to do is
> controlling where is the start of ZONE_MOVABLE of each node. Could
> CMA do this job ?

cma will not control the start of ZONE_MOVABLE of each node, but it
can declare a memory that always movable
and all non movable allocate request will not happen on that area.

Currently cma use a boot parameter "cma=" to declare a memory size
that always movable.
I think it might fulfill your requirement if extending the boot
parameter with a start address.

more info at http://lwn.net/Articles/468044/
>
> And also, after a short investigation, CMA seems need to base on
> memblock. But we need to limit memblock not to allocate memory on
> ZONE_MOVABLE. As a result, we need to know the ranges before memblock
> could be used. I'm afraid we still need an approach to get the ranges,
> such as a boot option, or from static ACPI tables such as SRAT/MPST.
>

Yes, it's based on memblock and with boot option.
In setup_arch32()
    dma_contiguous_reserve(0);   => will declare a cma area using
memblock_reserve()

> I'm don't know much about CMA for now. So if you have any better idea,
> please share with us, thanks. :)

My idea is reuse cma like below patch(even not compiled) and boot with
"cma=size@start_address".
I don't know whether it can work and whether suitable for your
requirement, if not forgive me for this noises.

diff --git a/drivers/base/dma-contiguous.c b/drivers/base/dma-contiguous.c
index 612afcc..564962a 100644
--- a/drivers/base/dma-contiguous.c
+++ b/drivers/base/dma-contiguous.c
@@ -59,11 +59,18 @@ struct cma *dma_contiguous_default_area;
  */
 static const unsigned long size_bytes = CMA_SIZE_MBYTES * SZ_1M;
 static long size_cmdline = -1;
+static long cma_start_cmdline = -1;

 static int __init early_cma(char *p)
 {
+       char *oldp;
        pr_debug("%s(%s)\n", __func__, p);
+       oldp = p;
        size_cmdline = memparse(p, &p);
+
+       if (*p == '@')
+               cma_start_cmdline = memparse(p+1, &p);
+       printk("cma start:0x%x, size: 0x%x\n", size_cmdline, cma_start_cmdline);
        return 0;
 }
 early_param("cma", early_cma);
@@ -127,8 +134,10 @@ void __init dma_contiguous_reserve(phys_addr_t limit)
        if (selected_size) {
                pr_debug("%s: reserving %ld MiB for global area\n", __func__,
                         selected_size / SZ_1M);
-
-               dma_declare_contiguous(NULL, selected_size, 0, limit);
+               if (cma_size_cmdline != -1)
+                       dma_declare_contiguous(NULL, selected_size,
cma_start_cmdline, limit);
+               else
+                       dma_declare_contiguous(NULL, selected_size, 0, limit);
        }
 };

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
