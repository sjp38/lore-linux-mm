Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 696BF6B0036
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 17:20:24 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1520466pbc.18
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:20:24 -0700 (PDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1678918pad.9
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 14:20:21 -0700 (PDT)
Message-ID: <5255C87F.8070701@gmail.com>
Date: Thu, 10 Oct 2013 05:19:59 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
References: <524E2032.4020106@gmail.com> <524E2127.4090904@gmail.com> <5251F9AB.6000203@zytor.com> <525442A4.9060709@gmail.com> <20131009164449.GG22495@htj.dyndns.org> <52558EEF.4050009@gmail.com> <20131009192040.GA5592@mtj.dyndns.org>
In-Reply-To: <20131009192040.GA5592@mtj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hi tejun,

On 10/10/2013 03:20 AM, Tejun Heo wrote:
> Hello,
> 
> On Thu, Oct 10, 2013 at 01:14:23AM +0800, Zhang Yanfei wrote:
>>>> You meant that the memory size is about few megs. But here, page tables
>>>> seems to be large enough in big memory machines, so that page tables will
>>>
>>> Hmmm?  Even with 4k mappings and, say, 16Gigs of memory, it's still
>>> somewhere above 32MiB, right?  And, these physical mappings don't
>>> usually use 4k mappings to begin with.  Unless we're worrying about
>>> ISA DMA limit, I don't think it'd be problematic.
>>
>> I think Peter meant very huge memory machines, say 2T memory? In the worst
>> case, this may need 2G memory for page tables, seems huge....
> 
> Realistically tho, why would people be using 4k mappings on 2T
> machines?  For the sake of argument, let's say 4k mappings are
> required for some weird reason, even then, doing SRAT parsing early
> doesn't necessarily solve the problem in itself.  It'd still need
> heuristics to avoid occupying too much of 32bit memory because it
> isn't difficult to imagine specific NUMA settings which would drive
> page table allocation into low address.
> 
> No matter what we do, there's no way around the fact that this whole
> effort is mostly an incomplete solution in its nature and that's why I
> think we better keep things isolated and simple.  It isn't a good idea
> to make structural changes to accomodate something which isn't and
> doesn't have much chance of becoming a full solution.  In addition,
> the problem itself is niche to begin with.
> 
>> And I am not familiar with the ISA DMA limit, does this mean the memory 
>> below 4G? Just as we have the ZONE_DMA32 in x86_64. (16MB limit seems not
>> the case here)
> 
> Yeah, I was referring to the 16MB limit, which apparently ceased to
> exist.

Hmmmm...If we are talking 16MB limit hear, I don't think it a problem, either.
Currently, default loading & running address of kernel is 16MB, so the
kernel itself is above 16MB, memory allocated in bottom-up mode is obviously
above the 16MB. Just seeing from a RHEL6.3 server:

  01000000-01507ff4 : Kernel code
  01507ff5-01c07b2f : Kernel data
  01d4e000-02012023 : Kernel bss

IOW, even if kernel is loaded and running at 1MB, it self will occupy about
16MB from the above.

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
