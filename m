Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 499ED6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 02:27:20 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so6700747pab.3
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 23:27:19 -0800 (PST)
Received: from song.cn.fujitsu.com ([222.73.24.84])
        by mx.google.com with ESMTP id sa6si172525pbb.353.2014.01.19.23.27.11
        for <linux-mm@kvack.org>;
        Sun, 19 Jan 2014 23:27:18 -0800 (PST)
Message-ID: <52DCD065.7040408@cn.fujitsu.com>
Date: Mon, 20 Jan 2014 15:29:41 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 1/8] x86: get pg_data_t's memory from
 other node
References: <529D3FC0.6000403@cn.fujitsu.com> <529D4048.9070000@cn.fujitsu.com> <20140116171112.GB24740@suse.de>
In-Reply-To: <20140116171112.GB24740@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>

Hi Mel,

On 01/17/2014 01:11 AM, Mel Gorman wrote:
> On Tue, Dec 03, 2013 at 10:22:00AM +0800, Zhang Yanfei wrote:
>> From: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
>>
>> If system can create movable node which all memory of the node is allocated
>> as ZONE_MOVABLE, setup_node_data() cannot allocate memory for the node's
>> pg_data_t. So, invoke memblock_alloc_nid(...MAX_NUMNODES) again to retry when
>> the first allocation fails. Otherwise, the system could failed to boot.
>> (We don't use memblock_alloc_try_nid() to retry because in this function,
>> if the allocation fails, it will panic the system.)
>>
>
> This implies that it is possible to ahve a configuration with a big ratio
> difference between Normal:Movable memory. In such configurations there
> would be a risk that the system will reclaim heavily or go OOM because
> the kernrel cannot allocate memory due to a relatively small Normal
> zone. What protects against that? Is the user ever warned if the ratio
> between Normal:Movable very high?

For now, there is no way protecting against this. But on a modern 
server, it won't be
that easy running out of memory when booting, I think.

The current implementation will set any node the kernel resides in as 
unhotpluggable,
which means normal zone here. And for nowadays server, especially memory 
hotplug server,
each node would have at least 16GB memory, which is enough for the 
kernel to boot.

We can add a patch to make it return to the original path if we run out 
of memory,
which means turn off the functionality and warn users in log.

How do you think ?

>  The movable_node boot parameter still
> turns the feature on and off, there appears to be no way of controlling
> the ratio of memory other than booting with the minimum amount of memory
> and manually hot-adding the sections to set the appropriate ratio.

For now, yes. We expect firmware and hardware to give the basic ratio 
(how much memory
is hotpluggable), and the user decides how to arrange the memory (decide 
the size of
normal zone and movable zone).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
