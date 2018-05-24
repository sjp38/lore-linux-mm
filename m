Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE666B000A
	for <linux-mm@kvack.org>; Thu, 24 May 2018 05:14:44 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id n33-v6so651918qte.23
        for <linux-mm@kvack.org>; Thu, 24 May 2018 02:14:44 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l28-v6si7819063qta.188.2018.05.24.02.14.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 02:14:43 -0700 (PDT)
Subject: Re: [PATCH v1 00/10] mm: online/offline 4MB chunks controlled by
 device driver
References: <20180523151151.6730-1-david@redhat.com>
 <20180524075327.GU20441@dhcp22.suse.cz>
 <14d79dad-ad47-f090-2ec0-c5daf87ac529@redhat.com>
 <20180524085610.GA5467@dhcp-128-65.nay.redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e70de03e-6965-749a-6c3c-ecf6dcb60c71@redhat.com>
Date: Thu, 24 May 2018 11:14:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180524085610.GA5467@dhcp-128-65.nay.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <dyoung@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Balbir Singh <bsingharora@gmail.com>, Baoquan He <bhe@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Dmitry Vyukov <dvyukov@google.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jaewon Kim <jaewon31.kim@samsung.com>, Jan Kara <jack@suse.cz>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Mel Gorman <mgorman@suse.de>, Michael Ellerman <mpe@ellerman.id.au>, Miles Chen <miles.chen@mediatek.com>, Oscar Salvador <osalvador@techadventures.net>, Paul Mackerras <paulus@samba.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Philippe Ombredanne <pombredanne@nexb.com>, Rashmica Gupta <rashmica.g@gmail.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Souptick Joarder <jrdr.linux@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>

On 24.05.2018 10:56, Dave Young wrote:
> Hi,
> 
> [snip]
>>>
>>>> For kdump and onlining/offlining code, we
>>>> have to mark pages as offline before a new segment is visible to the system
>>>> (e.g. as these pages might not be backed by real memory in the hypervisor).
>>>
>>> Please expand on the kdump part. That is really confusing because
>>> hotplug should simply not depend on kdump at all. Moreover why don't you
>>> simply mark those pages reserved and pull them out from the page
>>> allocator?
>>
>> 1. "hotplug should simply not depend on kdump at all"
>>
>> In theory yes. In the current state we already have to trigger kdump to
>> reload whenever we add/remove a memory block.
>>
>>
>> 2. kdump part
>>
>> Whenever we offline a page and tell the hypervisor about it ("unplug"),
>> we should not assume that we can read that page again. Now, if dumping
>> tools assume they can read all memory that is offline, we are in trouble.
>>
>> It is the same thing as we already have with Pg_hwpoison. Just a
>> different meaning - "don't touch this page, it is offline" compared to
>> "don't touch this page, hw is broken".
> 
> Does that means in case an offline no kdump reload as mentioned in 1)?
> 
> If we have the offline event and reload kdump, I assume the memory state
> is refreshed so kdump will not read the memory offlined, am I missing
> something?

If a whole section is offline: yes. (ACPI hotplug)

If pages are online but broken ("logically offline" - hwpoison): no

If single pages are logically offline: no. (Balloon inflation - let's
call it unplug as that's what some people refer to)

If only subsections (4MB chunks) are offline: no.

Exporting memory ranges in a smaller granularity to kdump than section
size would a) be heavily complicated b) introduce a lot of overhead for
this tracking data c) make us retrigger kdump way too often.

So simply marking pages offline in the struct pages and telling kdump
about it is the straight forward thing to do. And it is fairly easy to
add and implement as we have the exact same thing in place for hwpoison.

> 
>>
>> Balloon drivers solve this problem by always allowing to read unplugged
>> memory. In virtio-mem, this cannot and should even not be guaranteed.
>>
> 
> Hmm, that sounds a bug..

I can give you a simple example why reading such unplugged (or balloon
inflated) memory is problematic: Huge page backed guests.

There is no zero page for huge pages. So if we allow the guest to read
that memory any time, we cannot guarantee that we actually consume less
memory in the hypervisor. This is absolutely to be avoided.

Existing balloon drivers don't support huge page backed guests. (well
you can inflate, but the hypervisor cannot madvise() 4k on a huge page,
resulting in no action being performed). This scenario is to be
supported with virtio-mem.


So yes, this is actually a bug in e.g. virtio-balloon implementations:

With "VIRTIO_BALLOON_F_MUST_TELL_HOST" we have to tell the hypervisor
before we access a page again. kdump cannot do this and does not care,
so this page is silently accessed and dumped. One of the main problems
why extending virtio-balloon hypervisor implementations to support
host-enforced R/W protection is impossible.

> 
>> And what we have to do to make this work is actually pretty simple: Just
>> like Pg_hwpoison, track per page if it is online and provide this
>> information to kdump.
>>
>>
> 
> Thanks
> Dave
> 


-- 

Thanks,

David / dhildenb
