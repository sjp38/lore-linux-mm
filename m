Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 617436B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 15:20:50 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so1374681pbc.4
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:20:50 -0700 (PDT)
Received: by mail-qa0-f45.google.com with SMTP id k4so5254862qaq.18
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:20:47 -0700 (PDT)
Date: Wed, 9 Oct 2013 15:20:40 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part1 v6 4/6] x86/mem-hotplug: Support initialize page
 tables in bottom-up
Message-ID: <20131009192040.GA5592@mtj.dyndns.org>
References: <524E2032.4020106@gmail.com>
 <524E2127.4090904@gmail.com>
 <5251F9AB.6000203@zytor.com>
 <525442A4.9060709@gmail.com>
 <20131009164449.GG22495@htj.dyndns.org>
 <52558EEF.4050009@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52558EEF.4050009@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhang Yanfei <zhangyanfei.yes@gmail.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello,

On Thu, Oct 10, 2013 at 01:14:23AM +0800, Zhang Yanfei wrote:
> >> You meant that the memory size is about few megs. But here, page tables
> >> seems to be large enough in big memory machines, so that page tables will
> > 
> > Hmmm?  Even with 4k mappings and, say, 16Gigs of memory, it's still
> > somewhere above 32MiB, right?  And, these physical mappings don't
> > usually use 4k mappings to begin with.  Unless we're worrying about
> > ISA DMA limit, I don't think it'd be problematic.
> 
> I think Peter meant very huge memory machines, say 2T memory? In the worst
> case, this may need 2G memory for page tables, seems huge....

Realistically tho, why would people be using 4k mappings on 2T
machines?  For the sake of argument, let's say 4k mappings are
required for some weird reason, even then, doing SRAT parsing early
doesn't necessarily solve the problem in itself.  It'd still need
heuristics to avoid occupying too much of 32bit memory because it
isn't difficult to imagine specific NUMA settings which would drive
page table allocation into low address.

No matter what we do, there's no way around the fact that this whole
effort is mostly an incomplete solution in its nature and that's why I
think we better keep things isolated and simple.  It isn't a good idea
to make structural changes to accomodate something which isn't and
doesn't have much chance of becoming a full solution.  In addition,
the problem itself is niche to begin with.

> And I am not familiar with the ISA DMA limit, does this mean the memory 
> below 4G? Just as we have the ZONE_DMA32 in x86_64. (16MB limit seems not
> the case here)

Yeah, I was referring to the 16MB limit, which apparently ceased to
exist.

> 1. introduce bottom up allocation to allocate memory near the kernel before
>    we parse SRAT.
> 2. Since peter have the serious concern about the pagetable setup in bottom-up
>    and Ingo also said we'd better not to touch the current top-down pagetable
>    setup. Could we just put acpi_initrd_override and numa_init related functions
>    before init_mem_mapping()? After numa info is parsed (including SRAT), we
>    reset the allocation direction back to top-down, so we needn't change the
>    page table setup process. And before numa info parsed, we use the bottom-up
>    allocation to make sure all memory allocated by memblock is near the kernel
>    image.
> 
> How do you think?

Let's wait to hear more about Peter's concern.  Peter, the whole thing
is very specialized, off-by-default thing which is more or less a
kludge no matter which implementation direction we choose and as far
as the cost and risk go, I think the proposed series is pretty small
in its foot print.  What do you think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
