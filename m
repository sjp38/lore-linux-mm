Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id B29DE6B0005
	for <linux-mm@kvack.org>; Mon, 28 May 2018 06:03:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id m65-v6so10264978qkh.11
        for <linux-mm@kvack.org>; Mon, 28 May 2018 03:03:23 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id o35-v6si14533498qte.336.2018.05.28.03.03.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 03:03:22 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524085610.GA5467@dhcp-128-65.nay.redhat.com>
 <e70de03e-6965-749a-6c3c-ecf6dcb60c71@redhat.com>
 <20180528082846.GA7884@dhcp-128-65.nay.redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <4b181422-334d-7ede-c00f-c967e4e3d13e@redhat.com>
Date: Mon, 28 May 2018 12:03:11 +0200
MIME-Version: 1.0
In-Reply-To: <20180528082846.GA7884@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 28.05.2018 10:28, Dave Young wrote:
> On 05/24/18 at 11:14am, David Hildenbrand wrote:
>> On 24.05.2018 10:56, Dave Young wrote:
>>> Hi,
>>>
>>> [snip]
>>>>>
>>>>>> For kdump and onlining/offlining code, we
>>>>>> have to mark pages as offline before a new segment is visible to the system
>>>>>> (e.g. as these pages might not be backed by real memory in the hypervisor).
>>>>>
>>>>> Please expand on the kdump part. That is really confusing because
>>>>> hotplug should simply not depend on kdump at all. Moreover why don't you
>>>>> simply mark those pages reserved and pull them out from the page
>>>>> allocator?
>>>>
>>>> 1. "hotplug should simply not depend on kdump at all"
>>>>
>>>> In theory yes. In the current state we already have to trigger kdump to
>>>> reload whenever we add/remove a memory block.
>>>>
>>>>
>>>> 2. kdump part
>>>>
>>>> Whenever we offline a page and tell the hypervisor about it ("unplug"),
>>>> we should not assume that we can read that page again. Now, if dumping
>>>> tools assume they can read all memory that is offline, we are in trouble.
>>>>
>>>> It is the same thing as we already have with Pg_hwpoison. Just a
>>>> different meaning - "don't touch this page, it is offline" compared to
>>>> "don't touch this page, hw is broken".
>>>
>>> Does that means in case an offline no kdump reload as mentioned in 1)?
>>>
>>> If we have the offline event and reload kdump, I assume the memory state
>>> is refreshed so kdump will not read the memory offlined, am I missing
>>> something?
>>
>> If a whole section is offline: yes. (ACPI hotplug)

After my investigation and reply to the other subthread, I think this is
not the case.

If a section/memory block is offline, it will currently still be dumped
as far as I can see. The ONLINE flag for sections is not (yet)
interpreted in makedumpfile.

>>
>> If pages are online but broken ("logically offline" - hwpoison): no
>>
>> If single pages are logically offline: no. (Balloon inflation - let's
>> call it unplug as that's what some people refer to)
>>
>> If only subsections (4MB chunks) are offline: no.
>>
>> Exporting memory ranges in a smaller granularity to kdump than section
>> size would a) be heavily complicated b) introduce a lot of overhead for
>> this tracking data c) make us retrigger kdump way too often.
>>
>> So simply marking pages offline in the struct pages and telling kdump
>> about it is the straight forward thing to do. And it is fairly easy to
>> add and implement as we have the exact same thing in place for hwpoison.
> 
> Ok, it is clear enough.   If case fine grained page offline is is like
> a hwpoison page so a userspace patch for makedumpfile is needes to
> exclude them when copying vmcore.

Exactly, to not touch pages that have no backing in the hypervisor. Even
if the pages would be readable on the hypervisor side, it makes no sense
to read/process them, as the y are logically offline and the content is
of no importance anymore - performance improvement, possible dump size
reduction.

-- 

Thanks,

David / dhildenb
