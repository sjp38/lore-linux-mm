Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id AA3306B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 05:47:22 -0500 (EST)
Received: by mail-ig0-f171.google.com with SMTP id ph11so241886999igc.1
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 02:47:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s32si1911797ioi.32.2016.01.04.02.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 02:47:21 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v2] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1450801950-7744-1-git-send-email-vkuznets@redhat.com>
	<20151222135520.1bcb2d18382f1e414864992c@linux-foundation.org>
Date: Mon, 04 Jan 2016 11:47:12 +0100
In-Reply-To: <20151222135520.1bcb2d18382f1e414864992c@linux-foundation.org>
	(Andrew Morton's message of "Tue, 22 Dec 2015 13:55:20 -0800")
Message-ID: <87d1thtydr.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Tue, 22 Dec 2015 17:32:30 +0100 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
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
> I think the default should be "offline" so vendors can ship kernels
> which have CONFIG_MEMORY_HOTPLUG_AUTOONLINE=y while being
> back-compatible with previous kernels.
>

(sorry for the delayed response, just picking things up after holidays)

I was under an (wrong?) impression that in the majority of use cases
users want to start using their newly added memory right away and that's
what distros will ship. As an alternative to making the feature off by
default I can suggest making CONFIG_MEMORY_HOTPLUG_AUTOONLINE a tristate
switch (no feature, default offline, default online).

>> --- a/Documentation/kernel-parameters.txt
>> +++ b/Documentation/kernel-parameters.txt
>> @@ -2537,6 +2537,8 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>>  			shutdown the other cpus.  Instead use the REBOOT_VECTOR
>>  			irq.
>>  
>> +	nomemhp_autoonline	Don't automatically online newly added memory.
>> +
>
> This wasn't mentioned in the changelog.  Why do we need a boot
> parameter as well as the sysfs knob?
>

I was thinking about some faulty hardware (e.g. reporting new memory
blocks which for some reason are not really usable) and an easy way to
make such hardware work.

>> +config MEMORY_HOTPLUG_AUTOONLINE
>> +	bool "Automatically online hot-added memory"
>> +	depends on MEMORY_HOTPLUG_SPARSE
>> +	help
>> +	  When memory is hot-added, it is not at ready-to-use state, a special
>
> "When memory is hot-added it is not in a ready-to-use state.  A special"
>
>> +	  userspace action is required to online the newly added blocks. With
>> +	  this option enabled, the kernel will try to online all newly added
>> +	  memory automatically.
>> +
>>
>> ...
>>

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
