Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id ACB236B0039
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 13:14:51 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so1351554pab.26
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:14:51 -0700 (PDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so1209412pbb.13
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 10:14:48 -0700 (PDT)
Message-ID: <52558EEF.4050009@gmail.com>
Date: Thu, 10 Oct 2013 01:14:23 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org>
In-Reply-To: <20131009164449.GG22495@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello tejun,

Thanks for the response:)

On 10/10/2013 12:44 AM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Oct 09, 2013 at 01:36:36AM +0800, Zhang Yanfei wrote:
>>> I'm still seriously concerned about this.  This unconditionally
>>> introduces new behavior which may very well break some classes of
> 
> This is an optional behavior which is triggered by a very specific
> kernel boot param, which I suspect is gonna need to stick around to
> support memory hotplug in the current setup unless we add another
> layer of address translation to support memory hotplug.

Yeah, I have explained that this is conditional.

> 
>>> systems -- the whole point of creating the page tables top down is
>>> because the kernel tends to be allocated in lower memory, which is also
>>> the memory that some devices need for DMA.
> 
> Would that really matter for the target use cases here?  These are
> likely fairly huge highend machines.  ISA DMA limit is below the
> kernel image and 32bit limit is pretty big in comparison and at this
> point even that limit is likely to be irrelevant at least for the
> target machines, which are gonna be almost inherently extremely niche.
> 
>>> so if we allocate memory close to the kernel image,
>>>   it's likely that we don't contaminate hotpluggable node.  We're
>>>   talking about few megs at most right after the kernel image.  I
>>>   can't see how that would make any noticeable difference.
>>
>> You meant that the memory size is about few megs. But here, page tables
>> seems to be large enough in big memory machines, so that page tables will
> 
> Hmmm?  Even with 4k mappings and, say, 16Gigs of memory, it's still
> somewhere above 32MiB, right?  And, these physical mappings don't
> usually use 4k mappings to begin with.  Unless we're worrying about
> ISA DMA limit, I don't think it'd be problematic.

I think Peter meant very huge memory machines, say 2T memory? In the worst
case, this may need 2G memory for page tables, seems huge....

And I am not familiar with the ISA DMA limit, does this mean the memory 
below 4G? Just as we have the ZONE_DMA32 in x86_64. (16MB limit seems not
the case here)

> 
>> consume the precious lower memory. So I think we may really reorder
>> the page table setup after we get the hotplug info in some way. Just like
>> we have done in patch 5, we reorder reserve_crashkernel() to be called
>> after initmem_init().
>>
>> So do you still have any objection to the pagetable setup reorder?
> 
> I still feel quite uneasy about pulling SRAT parsing and ACPI initrd
> overriding into early boot.
> 

I am trying to read all the discussion mails before. Maybe from the very
first patchset that made you uneasy about parsing SRAT earlier. The patchset
may do too much splitting and registering. So I am thinking that if we
could combine two thing together to make things cleaner:

1. introduce bottom up allocation to allocate memory near the kernel before
   we parse SRAT.
2. Since peter have the serious concern about the pagetable setup in bottom-up
   and Ingo also said we'd better not to touch the current top-down pagetable
   setup. Could we just put acpi_initrd_override and numa_init related functions
   before init_mem_mapping()? After numa info is parsed (including SRAT), we
   reset the allocation direction back to top-down, so we needn't change the
   page table setup process. And before numa info parsed, we use the bottom-up
   allocation to make sure all memory allocated by memblock is near the kernel
   image.

How do you think?

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
