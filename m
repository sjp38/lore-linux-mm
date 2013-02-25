Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 2AEAB6B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 21:55:09 -0500 (EST)
Message-ID: <512AD269.2010900@cn.fujitsu.com>
Date: Mon, 25 Feb 2013 10:54:33 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Bug fix PATCH 2/2] acpi, movablemem_map: Make whatever nodes
 the kernel resides in un-hotpluggable.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com> <1361358056-1793-3-git-send-email-tangchen@cn.fujitsu.com> <1361647596.11282.7@driftwood>
In-Reply-To: <1361647596.11282.7@driftwood>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Landley <rob@landley.net>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/24/2013 03:26 AM, Rob Landley wrote:
> On 02/20/2013 05:00:56 AM, Tang Chen wrote:
>> There could be several memory ranges in the node in which the kernel
>> resides.
>> When using movablemem_map=acpi, we may skip one range that have memory
>> reserved
>> by memblock. But if it is too small, then the kernel will fail to
>> boot. So, make
>> the whole node which the kernel resides in un-hotpluggable. Then the
>> kernel has
>> enough memory to use.
>>
>> Reported-by: H Peter Anvin <hpa@zytor.com>
>> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
>
> Docs part Acked-by: Rob Landley <rob@landley.net> (with minor
> non-blocking snark).

Hi Rob,

Thanks for ack. :)

>
>> @@ -1673,6 +1675,10 @@ bytes respectively. Such letter suffixes can
>> also be entirely omitted.
>> satisfied. So the administrator should be careful that
>> the amount of movablemem_map areas are not too large.
>> Otherwise kernel won't have enough memory to start.
>> + NOTE: We don't stop users specifying the node the
>> + kernel resides in as hotpluggable so that this
>> + option can be used as a workaround of firmware
>> + bugs.
>
> I usually see workaround "for", not "of". And your whitespace is
> inconsistent on that last line.
>
> And I'm now kind of curious what such a workaround would accomplish, but
> I'm suspect it's obvious to people who wind up needing it.

SFAIK, this is more useful when debugging.

>
>> MTD_Partition= [MTD]
>> Format: <name>,<region-number>,<size>,<offset>
>> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
>> index b8028b2..79836d0 100644
>> --- a/arch/x86/mm/srat.c
>> +++ b/arch/x86/mm/srat.c
>> @@ -166,6 +166,9 @@ handle_movablemem(int node, u64 start, u64 end,
>> u32 hotpluggable)
>> * for other purposes, such as for kernel image. We cannot prevent
>> * kernel from using these memory, so we need to exclude these memory
>> * even if it is hotpluggable.
>> + * Furthermore, to ensure the kernel has enough memory to boot, we make
>> + * all the memory on the node which the kernel resides in
>> + * un-hotpluggable.
>> */
>
> Can you hot-unplug half a node? (Do you have a choice with the
> granularity here?)

No, we cannot hot-plug/hot-unplug half a node. But we can offline some 
of the
memory, not all the memory on one node. :)

Here, hotplug means finally you will physically remove the hardware 
device from
the system while the system is running. So there is no such thing like 
hotplug
half a node, I think. :)

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
