Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id DBEC56B0036
	for <linux-mm@kvack.org>; Sun, 17 Aug 2014 21:12:44 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id z10so6489645pdj.30
        for <linux-mm@kvack.org>; Sun, 17 Aug 2014 18:12:44 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id nz2si82053pbb.232.2014.08.17.18.12.42
        for <linux-mm@kvack.org>;
        Sun, 17 Aug 2014 18:12:43 -0700 (PDT)
Message-ID: <53F15330.5070606@cn.fujitsu.com>
Date: Mon, 18 Aug 2014 09:13:20 +0800
From: tangchen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mem-hotplug: let memblock skip the hotpluggable memory
 regions in __next_mem_range()
References: <53E8C5AA.5040506@huawei.com> <20140816130456.GH9305@htj.dyndns.org> <53EF6C79.3000603@huawei.com> <20140817110821.GM9305@htj.dyndns.org>
In-Reply-To: <20140817110821.GM9305@htj.dyndns.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, "Rafael
 J. Wysocki" <rjw@sisk.pl>, "H. Peter Anvin" <hpa@zytor.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, tangchen@cn.fujitsu.com

Hi tj,

On 08/17/2014 07:08 PM, Tejun Heo wrote:
> Hello,
>
> On Sat, Aug 16, 2014 at 10:36:41PM +0800, Xishi Qiu wrote:
>> numa_clear_node_hotplug()? There is only numa_clear_kernel_node_hotplug().
> Yeah, that one.
>
>> If we don't clear hotpluggable flag in free_low_memory_core_early(), the
>> memory which marked hotpluggable flag will not free to buddy allocator.
>> Because __next_mem_range() will skip them.
>>
>> free_low_memory_core_early
>> 	for_each_free_mem_range
>> 		for_each_mem_range
>> 			__next_mem_range		
> Ah, okay, so the patch fixes __next_mem_range() and thus makes
> free_low_memory_core_early() to skip hotpluggable regions unlike
> before.  Please explain things like that in the changelog.  Also,
> what's its relationship with numa_clear_kernel_node_hotplug()?  Do we
> still need them?  If so, what are the different roles that these two
> separate places serve?

numa_clear_kernel_node_hotplug() only clears hotplug flags for the nodes
the kernel resides in, not for hotpluggable nodes. The reason why we did
this is to enable the kernel to allocate memory in case all the nodes are
hotpluggable.

And we clear hotplug flags for all the nodes in free_low_memory_core_early()
is because if we do not, all hotpluggable memory won't be able to be freed
to buddy after Qiu's patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
