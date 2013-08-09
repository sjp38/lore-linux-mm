Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AEC4D6B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 19:39:31 -0400 (EDT)
Received: by mail-ob0-f170.google.com with SMTP id eh20so7126736obb.29
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 16:39:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5204B74B.4050805@cn.fujitsu.com>
References: <1375954883-30225-1-git-send-email-tangchen@cn.fujitsu.com>
	<1375954883-30225-5-git-send-email-tangchen@cn.fujitsu.com>
	<CAE9FiQXwAkGU96Oe5YNErTXs-OHGHTAfVo4oyrF-WUZ97X7pQA@mail.gmail.com>
	<5204B74B.4050805@cn.fujitsu.com>
Date: Fri, 9 Aug 2013 16:39:30 -0700
Message-ID: <CAE9FiQXe2SXN6KxfNBFZhZqJANZoVUprY2g=BYDzeYBUPWp-4A@mail.gmail.com>
Subject: Re: [PATCH part4 4/4] x86, acpi, numa, mem_hotplug: Find hotpluggable
 memory in SRAT memory affinities.
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Bob Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, yanghy@cn.fujitsu.com, the arch/x86 maintainers <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Fri, Aug 9, 2013 at 2:32 AM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
> On 08/09/2013 12:41 AM, Yinghai Lu wrote:
>>
>> On Thu, Aug 8, 2013 at 2:41 AM, Tang Chen<tangchen@cn.fujitsu.com>  wrote:
>>>
>>> In ACPI SRAT(System Resource Affinity Table), there is a memory affinity
>>> for each
>>> memory range in the system. In each memory affinity, there is a field
>>> indicating
>>> that if the memory range is hotpluggable.
>>>
>>> This patch parses all the memory affinities in SRAT only, and find out
>>> all the
>>> hotpluggable memory ranges in the system.
>>
>>
>> oh, no.
>>
>> How do you make sure the SRAT's entries are right ?
>> later numa_init could reject srat table if srat ranges does not cover
>> e820 memmap.
>
>
> In numa_meminfo_cover_memory(), it checks if SRAT covers the e820 ranges.
> And it uses
>     e820ram = max_pfn - absent_pages_in_range(0, max_pfn)
> to calculate the e820 ram size.
>
> Since max_pfn is initialized before memblock.memory is fulfilled, I think
> we can also do this check at earlier time.
>
>
>>
>> Also parse srat table two times looks silly.
>
>
> By parsing SRAT twice, I can avoid memory allocation for acpi_tables_addr
> in acpi_initrd_override_copy() procedure at such an early time. This memory
> could also be in hotpluggable area.

You already mark kernel position to be not hot-plugged,  so near the
kernel range should be safe to be put override acpi tables.

also what I mean parse srat two times:
parse to get hotplug range, and late parse other numa info again.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
