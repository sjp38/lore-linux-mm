Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5D5EC8E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 17:24:18 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so7620430edq.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 14:24:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z25-v6sor4090100eja.49.2018.12.11.14.24.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 14:24:17 -0800 (PST)
Date: Tue, 11 Dec 2018 22:24:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
Message-ID: <20181211222415.yfco6l2dmywxgid7@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
 <20181210132451.GO1286@dhcp22.suse.cz>
 <20181211094938.3mykr3n3tp6rfz4p@master>
 <e23ad186-31d4-176d-7330-8c22378891ee@linux.bm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e23ad186-31d4-176d-7330-8c22378891ee@linux.bm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zaslonko Mikhail <zaslonko@linux.bm.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Michal Hocko <mhocko@kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Tue, Dec 11, 2018 at 04:17:34PM +0100, Zaslonko Mikhail wrote:
>
>
>On 11.12.2018 10:49, Wei Yang wrote:
>> On Mon, Dec 10, 2018 at 02:24:51PM +0100, Michal Hocko wrote:
>>> On Mon 10-12-18 14:07:12, Mikhail Zaslonko wrote:
>>>> If memory end is not aligned with the sparse memory section boundary, the
>>>> mapping of such a section is only partly initialized.
>>>
>>> It would be great to mention how you can end up in the situation like
>>> this(a user provided memmap or a strange HW). 
>>>
>>>> This may lead to
>>>> VM_BUG_ON due to uninitialized struct page access from
>>>> is_mem_section_removable() or test_pages_in_a_zone() function triggered by
>>>> memory_hotplug sysfs handlers:
>>>>
>>>>  page:000003d082008000 is uninitialized and poisoned
>>>>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>>>  Call Trace:
>>>>  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
>>>>   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
>>>>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>>>>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>>>>   [<00000000003e4194>] seq_read+0x204/0x480
>>>>   [<00000000003b53ea>] __vfs_read+0x32/0x178
>>>>   [<00000000003b55b2>] vfs_read+0x82/0x138
>>>>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
>>>>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
>>>>  Last Breaking-Event-Address:
>>>>   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
>>>>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>>>>
>>>> Fix the problem by initializing the last memory section of the highest zone
>>>> in memmap_init_zone() till the very end, even if it goes beyond the zone
>>>> end.
>>>
>>> Why do we need to restrict this to the highest zone? In other words, why
>>> cannot we do what I was suggesting earlier [1]. What does prevent other
>>> zones to have an incomplete section boundary?
>>>
>>> [1] http://lkml.kernel.org/r/20181105183533.GQ4361@dhcp22.suse.cz
>>>
>> 
>> I tried to go through the original list and make myself familiar with
>> the bug.
>> 
>> Confused why initialize the *last* end_pfn could fix this, since
>> is_mem_section_removable() will iterate on each page of a section. This
>> means we need to initialize all the pages left in the section.
>That's exactly what the fix does. We initialize all the pages left in 
>the section.
>

You are right, I misunderstand your code.

>> 
>> One way to fix this in my mind is to record the last pfn in mem_section.
>Do you mean last initialized pfn? I guess we have agreed upon that the 
>entire section should be initialized.  

Well, that would be great.

>
>> This could be done in memory_preset(), since after that we may assume
>> the section is full. Not sure whether you would like it.
>> 

-- 
Wei Yang
Help you, Help me
