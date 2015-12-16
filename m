Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id DC4056B025F
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 05:53:43 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id k189so57272925qkc.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 02:53:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y189si2539617qka.89.2015.12.16.02.53.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 02:53:43 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1450202753-5556-1-git-send-email-vkuznets@redhat.com>
	<5670D83E.9040407@huawei.com> <87k2oevjkn.fsf@vitty.brq.redhat.com>
	<56713D17.1080002@huawei.com>
Date: Wed, 16 Dec 2015 11:53:35 +0100
In-Reply-To: <56713D17.1080002@huawei.com> (Xishi Qiu's message of "Wed, 16
	Dec 2015 18:29:43 +0800")
Message-ID: <8737v2vf4g.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, yanxiaofeng <yanxiaofeng@inspur.com>, Changsheng Liu <liuchangsheng@inspur.com>, Kay Sievers <kay@vrfy.org>

Xishi Qiu <qiuxishi@huawei.com> writes:

> On 2015/12/16 17:17, Vitaly Kuznetsov wrote:
>
>> Xishi Qiu <qiuxishi@huawei.com> writes:
>> 
>>> On 2015/12/16 2:05, Vitaly Kuznetsov wrote:
>>>
>>>> Currently, all newly added memory blocks remain in 'offline' state unless
>>>> someone onlines them, some linux distributions carry special udev rules
>>>> like:
>>>>
>>>> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
>>>>
>>>> to make this happen automatically. This is not a great solution for virtual
>>>> machines where memory hotplug is being used to address high memory pressure
>>>> situations as such onlining is slow and a userspace process doing this
>>>> (udev) has a chance of being killed by the OOM killer as it will probably
>>>> require to allocate some memory.
>>>>
>>>> Introduce default policy for the newly added memory blocks in
>>>> /sys/devices/system/memory/hotplug_autoonline file with two possible
>>>> values: "offline" (the default) which preserves the current behavior and
>>>> "online" which causes all newly added memory blocks to go online as
>>>> soon as they're added.
>>>>
>>>> Cc: Jonathan Corbet <corbet@lwn.net>
>>>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>>>> Cc: Daniel Kiper <daniel.kiper@oracle.com>
>>>> Cc: Dan Williams <dan.j.williams@intel.com>
>>>> Cc: Tang Chen <tangchen@cn.fujitsu.com>
>>>> Cc: David Vrabel <david.vrabel@citrix.com>
>>>> Cc: David Rientjes <rientjes@google.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>>>> Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>
>>>> Cc: Xishi Qiu <qiuxishi@huawei.com>
>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>> Cc: "K. Y. Srinivasan" <kys@microsoft.com>
>>>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>>>> ---
>>>> - I was able to find previous attempts to fix the issue, e.g.:
>>>>   http://marc.info/?l=linux-kernel&m=137425951924598&w=2
>>>>   http://marc.info/?l=linux-acpi&m=127186488905382
>>>>   but I'm not completely sure why it didn't work out and the solution
>>>>   I suggest is not 'smart enough', thus 'RFC'.
>>>
>>> + CC: 
>>> yanxiaofeng@inspur.com
>>> liuchangsheng@inspur.com
>>>
>>> Hi Vitaly,
>>>
>>> Why not use udev rule? I think it can online pages automatically.
>>>
>> 
>> Two main reasons:
>> 1) I remember someone saying "You never need a mouse in order to add
>> another mouse to the kernel" -- but we  we need memory to add more
>> memory. Udev has a chance of being killed by the OOM killer as
>> performing an action will probably require to allocate some
>> memory. Other than that udev actions are generally slow compared to what
>> we can do in kernel.
>
> Hi Vitaly,
>
> So why we add memory when there is almost no free memory left?
> I think the administrator should add memory when the free memory is low
> or he should do something to stop free memory become worse.

I have virtual machines use-case in my mind where hypervisor adds new
memory on high memory pressure reports from the guest (e.g. Hyper-V
behaves like that). This is an automatic action.

>
>> 
>> 2) I agree with Kay that '... unconditional hotplug loop through
>> userspace is absolutely pointless' (https://lkml.org/lkml/2013/7/25/354). 
>> (... and I should had add him to CC, adding now). Udev maintainers
>> refused to add a rule for unconditional memory onlining to udev and now
>> linux distros have to carry such custom rules.
>> 
>
> If the administrator don't know how to config the udev, he could use sysfs
> (echo 1 > /sys/devices/system/node/nodeXX/memoryXX/online) to online it,
> or write a script to do this.

Oh, no, I'm not taking about manual actions here. My suggestion doesn't
eliminate this possibility and it doesn't even change the default --
memory blocks stay in 'offline' state unless someone requests the
auto-online policy.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
