Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37B076B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 05:22:54 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id c96so80983755qgd.3
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 02:22:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a97si28860882qkh.49.2015.12.21.02.22.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 02:22:53 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1450457155-31234-1-git-send-email-vkuznets@redhat.com>
	<56743A00.4020503@citrix.com>
Date: Mon, 21 Dec 2015 11:22:46 +0100
In-Reply-To: <56743A00.4020503@citrix.com> (David Vrabel's message of "Fri, 18
	Dec 2015 16:53:20 +0000")
Message-ID: <87y4corthl.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>

David Vrabel <david.vrabel@citrix.com> writes:

> On 18/12/15 16:45, Vitaly Kuznetsov wrote:
>> Currently, all newly added memory blocks remain in 'offline' state unless
>> someone onlines them, some linux distributions carry special udev rules
>> like:
>> 
>> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline", ATTR{state}="online"
>> 
>> to make this happen automatically. This is not a great solution for virtual
>> machines where memory hotplug is being used to address high memory pressure
>> situations as such onlining is slow and a userspace process doing this
>> (udev) has a chance of being killed by the OOM killer as it will probably
>> require to allocate some memory.
>> 
>> Introduce default policy for the newly added memory blocks in
>> /sys/devices/system/memory/hotplug_autoonline file with two possible
>> values: "offline" which preserves the current behavior and "online" which
>> causes all newly added memory blocks to go online as soon as they're added.
>> The default is "online" when MEMORY_HOTPLUG_AUTOONLINE kernel config option
>> is selected.
>
> FWIW, I'd prefer it if the caller of add_memory_resource() could specify
> that it wants the new memory automatically onlined.
>

Oh, I missed the fact that add_memory_resource() is also called directly
from Xen balloon driver. I can change the interface and move the policy
check to add_memory() then.

> I'm not sure just having one knob is appropriate -- there are different
> sorts of memory that can be added.  e,g., in the Xen balloon driver we
> use the memory add infrastructure to add empty pages (pages with no
> machine pages backing them) for mapping things into, as well as adding
> regular pages.

But all this memory still appears in /sys/devices/system/memory/* and
someone (e.g. - a udev rule) can still try to online it, right? Actually
Hyper-V driver does something similar when adding partially populated
memory blocks and it registers a special callback (hv_online_page()) to
prevent non-populated pages from onlining.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
