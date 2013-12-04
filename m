Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id F1B236B0092
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 19:02:52 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id i72so10801179yha.11
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:02:52 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id r49si1276380yho.17.2013.12.03.16.02.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 16:02:52 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id z10so21103929pdj.2
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 16:02:51 -0800 (PST)
Message-ID: <529E7114.9060107@gmail.com>
Date: Wed, 04 Dec 2013 08:02:28 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND part2 v2 0/8] Arrange hotpluggable memory as ZONE_MOVABLE
References: <529D3FC0.6000403@cn.fujitsu.com> <20131203154811.90113f91ddd23413dd92b768@linux-foundation.org>
In-Reply-To: <20131203154811.90113f91ddd23413dd92b768@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, "Rafael J . Wysocki" <rjw@sisk.pl>, Len Brown <lenb@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Thomas Renninger <trenn@suse.de>, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, Vasilis Liaskovitis <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, Prarit Bhargava <prarit@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Chen Tang <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

Hello Andrew

On 12/04/2013 07:48 AM, Andrew Morton wrote:
> On Tue, 03 Dec 2013 10:19:44 +0800 Zhang Yanfei <zhangyanfei@cn.fujitsu.com> wrote:
> 
>> The current Linux cannot migrate pages used by the kerenl because
>> of the kernel direct mapping. In Linux kernel space, va = pa + PAGE_OFFSET.
>> When the pa is changed, we cannot simply update the pagetable and
>> keep the va unmodified. So the kernel pages are not migratable.
>>
>> There are also some other issues will cause the kernel pages not migratable.
>> For example, the physical address may be cached somewhere and will be used.
>> It is not to update all the caches.
>>
>> When doing memory hotplug in Linux, we first migrate all the pages in one
>> memory device somewhere else, and then remove the device. But if pages are
>> used by the kernel, they are not migratable. As a result, memory used by
>> the kernel cannot be hot-removed.
>>
>> Modifying the kernel direct mapping mechanism is too difficult to do. And
>> it may cause the kernel performance down and unstable. So we use the following
>> way to do memory hotplug.
>>
>>
>> [What we are doing]
>>
>> In Linux, memory in one numa node is divided into several zones. One of the
>> zones is ZONE_MOVABLE, which the kernel won't use.
>>
>> In order to implement memory hotplug in Linux, we are going to arrange all
>> hotpluggable memory in ZONE_MOVABLE so that the kernel won't use these memory.
> 
> How does the user enable this?  I didn't spot a Kconfig variable which
> enables it.  Is there a boot option?

Yeah, there is a Kconfig variable "MOVABLE_NODE" and a boot option "movable_node"

mm/Kconfig

config MOVABLE_NODE
        boolean "Enable to assign a node which has only movable memory"
        ......
        default n
        help
          Allow a node to have only movable memory.  Pages used by the kernel,
          such as direct mapping pages cannot be migrated.  So the corresponding
          memory device cannot be hotplugged.  This option allows the following
          two things:
          - When the system is booting, node full of hotpluggable memory can 
          be arranged to have only movable memory so that the whole node can 
          be hot-removed. (need movable_node boot option specified).
          - After the system is up, the option allows users to online all the 
          memory of a node as movable memory so that the whole node can be
          hot-removed.

          Users who don't use the memory hotplug feature are fine with this
          option on since they don't specify movable_node boot option or they
          don't online memory as movable.

          Say Y here if you want to hotplug a whole node.
          Say N here if you want kernel to use memory on all nodes evenly.

And the movable_node boot option in DOC:

Documentation/kernel-parameters.txt

        movable_node    [KNL,X86] Boot-time switch to *enable* the effects
                        of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.


> 
> Or is it always enabled?  If so, that seems incautious - if it breaks
> in horrid ways we want people to be able to go back to the usual
> behavior.
> 

-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
