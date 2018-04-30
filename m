Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E8006B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 02:31:09 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id a125so6332433qkd.4
        for <linux-mm@kvack.org>; Sun, 29 Apr 2018 23:31:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p27-v6si5653611qte.207.2018.04.29.23.31.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Apr 2018 23:31:08 -0700 (PDT)
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413171120.GA1245@bombadil.infradead.org>
 <89329958-2ff8-9447-408e-fd478b914ec4@suse.cz>
 <20180422030130.GG14610@bombadil.infradead.org>
 <7db70df4-c714-574c-5b14-898c1cf49af6@redhat.com>
 <20180422140246.GA30714@bombadil.infradead.org>
 <903ab7f7-88ce-9bc3-036b-261cce1bb26c@redhat.com>
 <20180429210850.GB26305@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <a0748efe-60e1-bc85-dbf3-a2352ab2c5b1@redhat.com>
Date: Mon, 30 Apr 2018 08:31:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180429210850.GB26305@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On 29.04.2018 23:08, Michal Hocko wrote:
> On Sun 22-04-18 17:13:52, David Hildenbrand wrote:
>> On 22.04.2018 16:02, Matthew Wilcox wrote:
>>> On Sun, Apr 22, 2018 at 10:17:31AM +0200, David Hildenbrand wrote:
>>>> On 22.04.2018 05:01, Matthew Wilcox wrote:
>>>>> On Sat, Apr 21, 2018 at 06:52:18PM +0200, Vlastimil Babka wrote:
>>>>>> Sounds like your newly introduced "page types" could be useful here? I
>>>>>> don't suppose those offline pages would be using mapcount which is
>>>>>> aliased there?
>>>>>
>>>>> Oh, that's a good point!  Yes, this is a perfect use for page_type.
>>>>> We have something like twenty bits available there.
>>>>>
>>>>> Now you've got me thinking that we can move PG_hwpoison and PG_reserved
>>>>> to be page_type flags too.  That'll take us from 23 to 21 bits (on 32-bit,
>>>>> with PG_UNCACHED)
>>>>
>>>> Some things to clarify here. I modified the current RFC to also allow
>>>> PG_offline on allocated (ballooned) pages (e.g. virtio-balloon).
>>>>
>>>> kdump based dump tools can then easily identify which pages are not to
>>>> be dumped (either because the content is invalid or not accessible).
>>>>
>>>> I previously stated that ballooned pages would be marked as PG_reserved,
>>>> which is not true (at least not for virtio-balloon). However this allows
>>>> me to detect if all pages in a section are offline by looking at
>>>> (PG_reserved && PG_offline). So I can actually tell if a page is marked
>>>> as offline and allocated or really offline.
>>>>
>>>>
>>>> 1. The location (not the number!) of PG_hwpoison is basically ABI and
>>>> cannot be changed. Moving it around will most probably break dump tools.
>>>> (see kernel/crash_core.c)
>>>
>>> It's not ABI.  It already changed after 4.9 when PG_waiters was introduced
>>> by commit 62906027091f.
>>
>> It is, please have a look at the file I pointed you to.
>>
>> We export the *value* of PG_hwpoison in the ELF file, therefore the
>> *value* can change, but the *location* (page_flags, mapcount, whatever)
>> must not change. Or am I missing something here? I don't think we can
>> move PG_hwpoison that easily.
>>
>> Also, I can read "For pages that are never mapped to userspace,
>> page->mapcount may be used for storing extra information about page
>> type" - is that true for PG_hwpoison/PG_reserved? I am skeptical.
>>
>> And we need something similar for PG_offline, because it will become
>> ABI. (I can see that PAGE_BUDDY_MAPCOUNT_VALUE is also exported in an
>> ELF file, so maybe a new page type might work for marking a page offline
>> - but I have to look at the details first tomorrow)
> 
> Wait wait wait. Who is relying on this? Kdump? Page flags have always
> been an internal implementation detail and _nobody_ outside of the
> kernel should ever rely on the specific value. Well, kdump has been
> cheating but that is because kdump is inherently tight to a specific
> kernel implementation but that doesn't make it a stable ABI IMHO.
> Restricting the kernel internals because of a debugging tool would be
> quite insane.
> 

kdump tools (makedumptool) don't rely on any specific value or assume
anything.

Using the example of musing PG_hwpoison to mapcount:

If it sees PG_hwpoison:
- it knows the right bit number to use
- it knows the kernel uses it

If it doesn't see PG_hwpoison (in the ELF info) anymore:
- it cannot exclude poisoned pages anymore, potentially crashing the
system during a dump


If you have a better fitting name for "requires a interlocked update
with tools to keep it working" than ABI, please let me know :)

Anyhow, I have a new prototype based on PAGE_OFFLINE_MAPCOUNT_VALUE that
I will share briefly.

-- 

Thanks,

David / dhildenb
