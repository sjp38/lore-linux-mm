Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id D80126B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 07:09:40 -0500 (EST)
Received: by mail-oi0-f44.google.com with SMTP id o124so90713411oia.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:09:40 -0800 (PST)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id w2si21465042oia.30.2015.12.21.04.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 04:09:40 -0800 (PST)
Received: by mail-ob0-x22f.google.com with SMTP id bx1so4373574obb.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 04:09:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5677B1B9.2080707@cn.fujitsu.com>
References: <20151221031501.GA32524@js1304-P5Q-DELUXE>
	<5677A378.6010703@cn.fujitsu.com>
	<20151221071747.GA4396@js1304-P5Q-DELUXE>
	<5677B1B9.2080707@cn.fujitsu.com>
Date: Mon, 21 Dec 2015 21:09:39 +0900
Message-ID: <CAAmzW4NRWacyNZNcYJ55zsw5wWnGQ13ghveU+EEEUzNBBH+MHw@mail.gmail.com>
Subject: Re: [RFC] theoretical race between memory hotplug and pfn iterator
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Toshi Kani <toshi.kani@hpe.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

2015-12-21 17:00 GMT+09:00 Zhu Guihua <zhugh.fnst@cn.fujitsu.com>:
>
> On 12/21/2015 03:17 PM, Joonsoo Kim wrote:
>>
>> On Mon, Dec 21, 2015 at 03:00:08PM +0800, Zhu Guihua wrote:
>>>
>>> On 12/21/2015 11:15 AM, Joonsoo Kim wrote:
>>>>
>>>> Hello, memory-hotplug folks.
>>>>
>>>> I found theoretical problems between memory hotplug and pfn iterator.
>>>> For example, pfn iterator works something like below.
>>>>
>>>> for (pfn = zone_start_pfn; pfn < zone_end_pfn; pfn++) {
>>>>          if (!pfn_valid(pfn))
>>>>                  continue;
>>>>
>>>>          page = pfn_to_page(pfn);
>>>>          /* Do whatever we want */
>>>> }
>>>>
>>>> Sequence of hotplug is something like below.
>>>>
>>>> 1) add memmap (after then, pfn_valid will return valid)
>>>> 2) memmap_init_zone()
>>>>
>>>> So, if pfn iterator runs between 1) and 2), it could access
>>>> uninitialized page information.
>>>>
>>>> This problem could be solved by re-ordering initialization steps.
>>>>
>>>> Hot-remove also has a problem. If memory is hot-removed after
>>>> pfn_valid() succeed in pfn iterator, access to page would cause NULL
>>>> deference because hot-remove frees corresponding memmap. There is no
>>>> guard against free in any pfn iterators.
>>>>
>>>> This problem can be solved by inserting get_online_mems() in all pfn
>>>> iterators but this looks error-prone for future usage. Another idea is
>>>> that delaying free corresponding memmap until synchronization point such
>>>> as system suspend. It will guarantee that there is no running pfn
>>>> iterator. Do any have a better idea?
>>>>
>>>> Btw, I tried to memory-hotremove with QEMU 2.5.5 but it didn't work. I
>>>> followed sequences in doc/memory-hotplug. Do you have any comment on
>>>> this?
>>>
>>> I tried memory hot remove with qemu 2.5.5 and RHEL 7, it works well.
>>> Maybe you can provide more details, such as guest version, err log.
>>
>> I'm testing with qemu 2.5.5 and linux-next-20151209 with reverting
>> following two patches.
>>
>> "mm/memblock.c: use memblock_insert_region() for the empty array"
>>
>> "mm-memblock-use-memblock_insert_region-for-the-empty-array-checkpatch-fixes"
>>
>> When I type "device_del dimm1" in qemu monitor, there is no err log in
>> kernel and it looks like command has no effect. I inserted log to
>> acpi_memory_device_remove() but there is no message, too. Is there
>> another way to check that device_del event is actually transmitted to
>> kernel?
>
>
> You can use udev to monitor memory device remove event. (udevadm monitor)
>

I have tried it but there is no message when I type hot-remove command.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
