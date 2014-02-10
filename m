Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6D30A6B0031
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 01:00:21 -0500 (EST)
Received: by mail-pb0-f50.google.com with SMTP id rq2so5800391pbb.23
        for <linux-mm@kvack.org>; Sun, 09 Feb 2014 22:00:21 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id tq3si14012667pab.38.2014.02.09.22.00.18
        for <linux-mm@kvack.org>;
        Sun, 09 Feb 2014 22:00:20 -0800 (PST)
Message-ID: <52F86745.2060204@cn.fujitsu.com>
Date: Mon, 10 Feb 2014 13:44:37 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
References: <529D3FC0.6000403@cn.fujitsu.com> <529D4048.9070000@cn.fujitsu.com> <20140116171112.GB24740@suse.de> <52DCD065.7040408@cn.fujitsu.com> <20140120151409.GU4963@suse.de> <20140206101230.GA21345@suse.de>
In-Reply-To: <20140206101230.GA21345@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hi Mel,

On 02/06/2014 06:12 PM, Mel Gorman wrote:
> Any comment on this or are the issues just going to be waved away?

Sorry for the delay.

>
......
>> Again, booting is fine but least say it's an 8-node machine then that
>> implies the Normal:Movable ratio will be 1:8. All page table pages, inode,
>> dentries etc will have to fit in that 1/8th of memory with all the associated
>> costs including remote access penalties.  In extreme cases it may not be
>> possible to use all of memory because the management structures cannot be
>> allocated. Users may want the option of adjusting what this ratio is so
>> they can unplug some memory while not completely sacrificing performance.
>>
>> Minimally, the kernel should print a big fat warning if the ratio is equal
>> or more than 1:3 Normal:Movable. That ratio selection is arbitrary. I do not
>> recall ever seeing any major Normal:Highmem bugs on 4G 32-bit machines so it
>> is a conservative choice. The last Normal:Highmem bug I remember was related
>> to a 16G 32-bit machine (https://bugzilla.kernel.org/show_bug.cgi?id=42578)
>> a 1:15 ratio feels very optimistic for a very large machine.
......
>>>
>>> For now, yes. We expect firmware and hardware to give the basic
>>> ratio (how much memory
>>> is hotpluggable), and the user decides how to arrange the memory
>>> (decide the size of
>>> normal zone and movable zone).
>>>
>>
>> There seems to be big gaps in the configuration options here. The user
>> can either ask it to be automatically assigned and have no control of
>> the ratio or manually hot-add the memory which is a relatively heavy
>> administrative burden.

Yes.

1. Automatically assigning is done by movable_node boot option, which is 
the
    main work of this patch-set. It depends on SRAT (firmware).

2. Manually assigning has been done since 2012, by the following patch-set.

    https://lkml.org/lkml/2012/8/6//113

    This patch-set allowed users to online memory as normal or movable. 
But it
    is not that easy to use. So, I also think an user space tool is needed.
    And I'm planing to do this recently.

>>
>> I think they should be warned if the ratio is high and have an option of
>> specifying a ratio manually even if that means that additional nodes
>> will not be hot-removable.

I think this is easy to do, provide an option for users to specify a
Normal:Movable ratio. This is not phys addr, and it is easy to use.

>>
>> This is all still a kludge around the fact that node memory hot-remove
>> did not try and cope with full migration by breaking some of the 1:1
>> virt:phys mapping assumptions when hot-remove was enabled.

I also said before, the implementation now can only be a temporary
solution for memory hotplug since it would take us a lot of time to
deal with 1:1 mapping thing.

But about "breaking some of the 1:1 mapping", would you please give me
any hint of it ?  I want to do it too, but I cannot see where to start.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
