Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id C8DFD6B0037
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 12:19:18 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id r10so3663979pdi.28
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 09:19:18 -0700 (PDT)
Message-ID: <52090AF6.6020206@gmail.com>
Date: Tue, 13 Aug 2013 00:19:02 +0800
From: Tang Chen <imtangchen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com> <20130812145016.GI15892@htj.dyndns.org> <52090225.6070208@gmail.com> <20130812154623.GL15892@htj.dyndns.org>
In-Reply-To: <20130812154623.GL15892@htj.dyndns.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org, imtangchen@gmail.com

On 08/12/2013 11:46 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, Aug 12, 2013 at 11:41:25PM +0800, Tang Chen wrote:
>> Then there is no way to tell the users which memory is hotpluggable.
>>
>> phys addr is not user friendly. For users, node or memory device is the
>> best. The firmware should arrange the hotpluggable ranges well.
>
> I don't follow.  Why can't the kernel export that information to
> userland after boot is complete via printk / sysfs / proc / whatever?
> The admin can "request" hotplug by boot param and the kernel would try
> to honor that and return the result on boot completion.  I don't
> understand why that wouldn't work.

Sorry, I was in such a hurry that I didn't make myself clear...

The kernel can export info to users. The point is what kind of info.
Exporting phys addr is meaningless, of course. Now in /sys, we only
have memory_block and node. memory_block is only 128M on x86, and
hotplug a memory_block means nothing. So actually we only have node.

So users want to hotplug a node is reasonable, I think. In the
beginning, we set the hotplug unit to a node. That is also why we
did the movable node.

In summary, node hotplug is much meaningful and usable for users.
So it is the best that we can arrange a whole node to be movable
node, not opportunistic.

>
>> In my opinion, maybe some application layer tools may use SRAT to show
>> the users which memory is hotpluggable. I just think both of the kernel
>> and the application layer should obey the same rule.
>
> Sure, just let the kernel tell the user which memory node ended up
> hotpluggable after booting.
>
>>> * Similar to the point hpa raised.  If this can be made opportunistic,
>>>    do we need the strict reordering to discover things earlier?
>>>    Shouldn't it be possible to configure memblock to allocate close to
>>>    the kernel image until hotplug and numa information is available?
>>>    For most sane cases, the memory allocated will be contained in
>>>    non-hotpluggable node anyway and in case they aren't hotplug
>>>    wouldn't work but the system will boot and function perfectly fine.
>>
>> So far as I know, the kernel image and related data can be loaded
>> anywhere, above 4GB. I just can't make any assumption.
>
> I don't follow why that would be problematic.  Wouldn't finding out
> which node the kernel image is located in and preferring to allocate
> from that node before hotplug info is available be enough?

I'm just thinking of a more extreme case. For example, if a machine
has only one node hotpluggable, and the kernel resides in that node.
Then the system has no hotpluggable node.

If we can prevent the kernel from using hotpluggable memory, in such
a machine, users can still do memory hotplug.

I wanted to do it as generic as possible. But yes, finding out the
nodes the kernel resides in and make it unhotpluggable can work.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
