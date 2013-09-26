Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 19A5C6B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:43:17 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1400943pdj.3
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:43:16 -0700 (PDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so1400762pdj.32
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:43:14 -0700 (PDT)
Message-ID: <52446413.50504@gmail.com>
Date: Fri, 27 Sep 2013 00:42:59 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 6/6] mem-hotplug: Introduce movablenode boot option
References: <5241D897.1090905@gmail.com> <5241DB62.2090300@gmail.com> <20130926145326.GH3482@htj.dyndns.org>
In-Reply-To: <20130926145326.GH3482@htj.dyndns.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J . Wysocki" <rjw@sisk.pl>, lenb@kernel.org, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, prarit@redhat.com, "x86@kernel.org" <x86@kernel.org>, linux-doc@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, imtangchen@gmail.com, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

On 09/26/2013 10:53 PM, Tejun Heo wrote:
> On Wed, Sep 25, 2013 at 02:35:14AM +0800, Zhang Yanfei wrote:
>> From: Tang Chen <tangchen@cn.fujitsu.com>
>>
>> The hot-Pluggable field in SRAT specifies which memory is hotpluggable.
>> As we mentioned before, if hotpluggable memory is used by the kernel,
>> it cannot be hot-removed. So memory hotplug users may want to set all
>> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use it.
>>
>> Memory hotplug users may also set a node as movable node, which has
>> ZONE_MOVABLE only, so that the whole node can be hot-removed.
>>
>> But the kernel cannot use memory in ZONE_MOVABLE. By doing this, the
>> kernel cannot use memory in movable nodes. This will cause NUMA
>> performance down. And other users may be unhappy.
>>
>> So we need a way to allow users to enable and disable this functionality.
>> In this patch, we introduce movablenode boot option to allow users to
>> choose to not to consume hotpluggable memory at early boot time and
>> later we can set it as ZONE_MOVABLE.
>>
>> To achieve this, the movablenode boot option will control the memblock
>> allocation direction. That said, after memblock is ready, before SRAT is
>> parsed, we should allocate memory near the kernel image as we explained
>> in the previous patches. So if movablenode boot option is set, the kernel
>> does the following:
>>
>> 1. After memblock is ready, make memblock allocate memory bottom up.
>> 2. After SRAT is parsed, make memblock behave as default, allocate memory
>>    top down.
>>
>> Users can specify "movablenode" in kernel commandline to enable this
>> functionality. For those who don't use memory hotplug or who don't want
>> to lose their NUMA performance, just don't specify anything. The kernel
>> will work as before.
>>
>> Suggested-by: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>> Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
> 
> I hope the param description and comment were better.  Not necessarily
> longer, but clearer, so it'd be great if you can polish them a bit

OK. Trying below:

movablenode	[KNL,X86] This option enables the kernel to arrange
		hotpluggable memory into ZONE_MOVABLE zone. If memory
		in a node is all hotpluggable, the option may make
		the whole node has only one ZONE_MOVABLE zone, so that
		the whole node can be hot-removed after system is up.
		Note that this option may cause NUMA performance down.

As for the comment in cmdline_parse_movablenode():

	/*
	 * ACPI SRAT records all hotpluggable memory ranges. But before
	 * SRAT is parsed, we don't know about it. So by specifying this
	 * option, we will use the bottom-up mode to try allocating memory
	 * near the kernel image before SRAT is parsed.
	 * 
	 * Bottom-up mode prevents memblock allocating hotpluggable memory
	 * for the kernel so that the kernel will arrange hotpluggable
	 * memory into ZONE_MOVABLE zone when possible.
	 */

Thanks.

> more.  Other than that,
> 
>  Acked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks.
> 


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
