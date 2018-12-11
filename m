Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 447158E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 04:49:41 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o21so6702984edq.4
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:49:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q26-v6sor3541843ejn.48.2018.12.11.01.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 01:49:39 -0800 (PST)
Date: Tue, 11 Dec 2018 09:49:38 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/1] mm, memory_hotplug: Initialize struct pages for the
 full memory section
Message-ID: <20181211094938.3mykr3n3tp6rfz4p@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181210130712.30148-1-zaslonko@linux.ibm.com>
 <20181210130712.30148-2-zaslonko@linux.ibm.com>
 <20181210132451.GO1286@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181210132451.GO1286@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, gerald.schaefer@de.ibm.com

On Mon, Dec 10, 2018 at 02:24:51PM +0100, Michal Hocko wrote:
>On Mon 10-12-18 14:07:12, Mikhail Zaslonko wrote:
>> If memory end is not aligned with the sparse memory section boundary, the
>> mapping of such a section is only partly initialized.
>
>It would be great to mention how you can end up in the situation like
>this(a user provided memmap or a strange HW). 
>
>> This may lead to
>> VM_BUG_ON due to uninitialized struct page access from
>> is_mem_section_removable() or test_pages_in_a_zone() function triggered by
>> memory_hotplug sysfs handlers:
>> 
>>  page:000003d082008000 is uninitialized and poisoned
>>  page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>>  Call Trace:
>>  ([<0000000000385b26>] test_pages_in_a_zone+0xde/0x160)
>>   [<00000000008f15c4>] show_valid_zones+0x5c/0x190
>>   [<00000000008cf9c4>] dev_attr_show+0x34/0x70
>>   [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
>>   [<00000000003e4194>] seq_read+0x204/0x480
>>   [<00000000003b53ea>] __vfs_read+0x32/0x178
>>   [<00000000003b55b2>] vfs_read+0x82/0x138
>>   [<00000000003b5be2>] ksys_read+0x5a/0xb0
>>   [<0000000000b86ba0>] system_call+0xdc/0x2d8
>>  Last Breaking-Event-Address:
>>   [<0000000000385b26>] test_pages_in_a_zone+0xde/0x160
>>  Kernel panic - not syncing: Fatal exception: panic_on_oops
>> 
>> Fix the problem by initializing the last memory section of the highest zone
>> in memmap_init_zone() till the very end, even if it goes beyond the zone
>> end.
>
>Why do we need to restrict this to the highest zone? In other words, why
>cannot we do what I was suggesting earlier [1]. What does prevent other
>zones to have an incomplete section boundary?
>
>[1] http://lkml.kernel.org/r/20181105183533.GQ4361@dhcp22.suse.cz
>

I tried to go through the original list and make myself familiar with
the bug.

Confused why initialize the *last* end_pfn could fix this, since
is_mem_section_removable() will iterate on each page of a section. This
means we need to initialize all the pages left in the section.

One way to fix this in my mind is to record the last pfn in mem_section.
This could be done in memory_preset(), since after that we may assume
the section is full. Not sure whether you would like it.

-- 
Wei Yang
Help you, Help me
