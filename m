Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 4C24B6B0008
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 05:32:48 -0500 (EST)
Message-ID: <5108F6A1.6060400@cn.fujitsu.com>
Date: Wed, 30 Jan 2013 18:32:01 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH Bug fix] acpi, movablemem_map: node0 should always be
 unhotpluggable when using SRAT.
References: <1359532470-28874-1-git-send-email-tangchen@cn.fujitsu.com> <alpine.DEB.2.00.1301300049100.19679@chino.kir.corp.google.com> <5108E245.9060501@cn.fujitsu.com> <alpine.DEB.2.00.1301300139070.25371@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1301300139070.25371@chino.kir.corp.google.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, rob@landley.net, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi David,

On 01/30/2013 05:45 PM, David Rientjes wrote:
> On Wed, 30 Jan 2013, Tang Chen wrote:
>
>> The failure I'm trying to fix is that if all the memory is hotpluggable, and
>> user
>> specified movablemem_map, my code will set all the memory as ZONE_MOVABLE, and
>> kernel
>> will fail to allocate any memory, and it will fail to boot.
>>
>
> I'm curious, do you have a dmesg of the failure?
>
> Historically I've seen this panic as late as build_sched_domains()
> because of a bad mapping between pxms and apicids that assumes node 0 is
> online and results in node_distance() being inaccurate.  I'm not sure if
> you're even getting that far in boot?

I'm sorry I cannot provide you any dmesg. I am using a remote machine 
and if
it failed to boot very early, it will redirect nothing to me.

So I think I didn't go that far.

>
>> Are you saying your memory is not on node0, and your physical address
>> 0x0 is not on node0 ? And your /sys fs don't have a node0 interface, it is
>> node1 or something else ?
>>
>
> Exactly, there is a node 0 but it includes no online memory (and that
> should be the case as if it was solely hotpluggable memory) at the time of
> boot.  The sysfs interfaces only get added if the memory is onlined later.

OK, you mean you have only node1 at first and no node0 interface, right?
If so, then this patch is wrong. :)

But you mean physical address 0x0 is on your node1, right? Otherwise, 
how could
the kernel be loaded ?

Could you provide the dmesg of your box like this:

[    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x7fffffff]
[    0.000000] SRAT: Node 0 PXM 0 [mem 0x100000000-0x7ffffffff]
[    0.000000] SRAT: Node 1 PXM 2 [mem 0x1000000000-0x17ffffffff] Hot 
Pluggable
[    0.000000] SRAT: Node 2 PXM 3 [mem 0x1800000000-0x1fffffffff] Hot 
Pluggable
[    0.000000] SRAT: Node 3 PXM 4 [mem 0x2000000000-0x27ffffffff]
[    0.000000] SRAT: Node 4 PXM 5 [mem 0x2800000000-0x2fffffffff]
[    0.000000] SRAT: Node 5 PXM 6 [mem 0x3000000000-0x37ffffffff]
[    0.000000] SRAT: Node 6 PXM 7 [mem 0x3800000000-0x3fffffffff]
[    0.000000] SRAT: Node 7 PXM 1 [mem 0x800000000-0xfffffffff]

>
>> If so, I think I'd better find another way to fix this problem because node0
>> may not be
>> the first node on the system.
>>
>
> I haven't tried it over the past year or so, but this used to work in the
> past.  I think if we had some more information we'd be able to see if we
> really need to treat node 0 in a special way.
>
I'll try to do more investigation and find a better way to fix it. :)

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
