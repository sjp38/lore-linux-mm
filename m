Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id F077C6B0036
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 03:23:32 -0400 (EDT)
Message-ID: <51C7F4A3.6060307@cn.fujitsu.com>
Date: Mon, 24 Jun 2013 15:26:27 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <20130618020357.GZ32663@mtj.dyndns.org> <51BFF464.809@cn.fujitsu.com> <20130618172129.GH2767@htj.dyndns.org> <51C298B2.9060900@cn.fujitsu.com> <20130620061719.GA16114@mtj.dyndns.org> <51C41AB4.9070500@cn.fujitsu.com> <20130621182511.GA1763@htj.dyndns.org> <51C7C258.8070906@cn.fujitsu.com>
In-Reply-To: <51C7C258.8070906@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 06/24/2013 11:51 AM, Tang Chen wrote:
> On 06/22/2013 02:25 AM, Tejun Heo wrote:
>> Hey,
>>
>> On Fri, Jun 21, 2013 at 05:19:48PM +0800, Tang Chen wrote:
>>>> * As memblock allocator can relocate itself. There's no point in
>>>> avoiding setting NUMA node while parsing and registering NUMA
>>>> topology. Just parse and register NUMA info and later tell it to
>>>> relocate itself out of hot-pluggable node. A number of patches in
>>>> the series is doing this dancing - carefully reordering NUMA
>>>> probing. No need to do that. It's really fragile thing to do.
>>>>
>>>> * Once you get the above out of the way, I don't think there are a lot
>>>> of permanent allocations in the way before NUMA is initialized.
>>>> Re-order the remaining ones if that's cleaner to do. If that gets
>>>> overly messy / fragile, copying them around or freeing and reloading
>>>> afterwards could be an option too.
>>>
>>> memblock allocator can relocate itself, but it cannot relocate the
>>> memory
>>
>> Hmmm... maybe I wasn't clear but that's the first bullet point above.
>>
>>> it allocated for users. There could be some pointers pointing to these
>>> memory ranges. If we do the relocation, how to update these pointers ?
>>
>> And the second. Can you please list what persistent areas are
>> allocated before numa info is configured into memblock? There
>
> Hi tj,
>
> My box is x86_64, and the memory layout is:
> [ 0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
> [ 0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x307ffffff]
> [ 0.000000] SRAT: Node 1 PXM 2 [mem 0x308000000-0x587ffffff] Hot Pluggable
> [ 0.000000] SRAT: Node 2 PXM 3 [mem 0x588000000-0x7ffffffff] Hot Pluggable
>
>
> I marked ranges reserved by memblock before we parse SRAT with flag 0x4.
> There are about 14 ranges which is persistent after boot.
>
> [ 0.000000] reserved[0x0] [0x00000000000000-0x0000000000ffff], 0x10000
> bytes flags: 0x4
> [ 0.000000] reserved[0x1] [0x00000000093000-0x000000000fffff], 0x6d000
> bytes flags: 0x4
> [ 0.000000] reserved[0x2] [0x00000001000000-0x00000002a9afff], 0x1a9b000
> bytes flags: 0x4
> [ 0.000000] reserved[0x3] [0x00000030000000-0x00000037ffffff], 0x8000000
> bytes flags: 0x4
> ...
> [ 0.000000] reserved[0x5] [0x0000006da81000-0x0000006e46afff], 0x9ea000
> bytes flags: 0x4
> [ 0.000000] reserved[0x6] [0x0000006ed6a000-0x0000006f246fff], 0x4dd000
> bytes flags: 0x4
> [ 0.000000] reserved[0x7] [0x0000006f28a000-0x0000006f299fff], 0x10000
> bytes flags: 0x4
> [ 0.000000] reserved[0x8] [0x0000006f29c000-0x0000006fe91fff], 0xbf6000
> bytes flags: 0x4
> [ 0.000000] reserved[0x9] [0x00000070e92000-0x00000071d54fff], 0xec3000
> bytes flags: 0x4
> [ 0.000000] reserved[0xa] [0x00000071d5e000-0x00000072204fff], 0x4a7000
> bytes flags: 0x4
> [ 0.000000] reserved[0xb] [0x00000072220000-0x0000007222074f], 0x750
> bytes flags: 0x4
> ...
> [ 0.000000] reserved[0xd] [0x000000722bc000-0x000000722bc1cf], 0x1d0
> bytes flags: 0x4
> [ 0.000000] reserved[0xe] [0x00000072bd3000-0x00000076c8ffff], 0x40bd000
> bytes flags: 0x4
> ......
> [ 0.000000] reserved[0x134] [0x000007fffdf000-0x000007ffffffff], 0x21000
> bytes flags: 0x4

This range is allocated by init_mem_mapping() in setup_arch(), it calls
alloc_low_pages() to allocate pagetable pages.

I think if we do the local device pagetable, we can solve this problem
without any relocation.

I will make a patch trying to do this. But I'm not sure if there are any
other relocation problems on other architectures.

But even if not, I still think this could be dangerous if someone modifies
the boot path and allocates some persistent memory before SRAT parsed in
the future. He has to be aware of memory hotplug things and do the 
necessary
relocation himself.

I'll try to make the patch to acheve this with comment as full as possible.

Thanks. :)

>
>
> Just for the readability:
> [0x00000308000000-0x00000587ffffff] Hot Pluggable
> [0x00000588000000-0x000007ffffffff] Hot Pluggable
>
> Seeing from the dmesg, only the last one is in hotpluggable area. I need
> to go
> through the code to find out what it is, and find a way to relocate it.
>
> But I'm not sure if a box with a different SRAT will have different result.
>
> I will send more info later.
>
> Thanks. :)
>
>
>> shouldn't be whole lot. And, again, this type of information should
>> have been available in the head message so that high-level discussion
>> could take place right away.
>>
>> Thanks.
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
