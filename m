Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 207156B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 22:10:41 -0400 (EDT)
Message-ID: <51F089C1.4010402@cn.fujitsu.com>
Date: Thu, 25 Jul 2013 10:13:21 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 14/21] x86, acpi, numa: Reserve hotpluggable memory at
 early time.
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com> <1374220774-29974-15-git-send-email-tangchen@cn.fujitsu.com> <20130723205557.GS21100@mtj.dyndns.org> <20130723213212.GA21100@mtj.dyndns.org>
In-Reply-To: <20130723213212.GA21100@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On 07/24/2013 05:32 AM, Tejun Heo wrote:
> On Tue, Jul 23, 2013 at 04:55:57PM -0400, Tejun Heo wrote:
>> On Fri, Jul 19, 2013 at 03:59:27PM +0800, Tang Chen wrote:
>>> +		/*
>>> +		 * In such an early time, we don't have nid. We specify pxm
>>> +		 * instead of MAX_NUMNODES to prevent memblock merging regions
>>> +		 * on different nodes. And later modify pxm to nid when nid is
>>> +		 * mapped so that we can arrange ZONE_MOVABLE on different
>>> +		 * nodes.
>>> +		 */
>>> +		memblock_reserve_hotpluggable(base_address, length, pxm);
>>
>> This is rather hacky.  Why not just introduce MEMBLOCK_NO_MERGE flag?

The original thinking is to merge regions with the same nid. So I used pxm.
And then refresh the nid field when nids are mapped.

I will try to introduce MEMBLOCK_NO_MERGE and make it less hacky.

>
> Also, if memblock is gonna know about hotplug memory, why not just let
> it control its allocation too instead of blocking it by reserving it
> from outside?  These are all pretty general memory hotplug logic which
> doesn't have much to do with acpi and I think too much is implemented
> on the acpi side.

At the very beginning, a long time ago, we just did this.
Please refer to: https://lkml.org/lkml/2012/12/10/656

In order to let memblock control the allocation, we have to store the
hotpluggable ranges somewhere, and keep the allocated range out of the
hotpluggable regions. I just think reserving the hotpluggable regions
and then memblock won't allocate them. No need to do any other limitation.

And also, the acpi side modification in this patch-set is to get SRAT
and parse it. I think most of the logic in 
acpi_reserve_hotpluggable_memory()
is necessary. I don't think letting memblock control the allocation will
make the acpi side easier.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
