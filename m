Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA8C36B0006
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:45:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v65-v6so734229qka.23
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:45:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n10-v6si696739qke.302.2018.07.26.01.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:45:58 -0700 (PDT)
Subject: Re: [PATCH v1 0/2] mm/kdump: exclude reserved pages in dumps
References: <20180720123422.10127-1-david@redhat.com>
 <9f46f0ed-e34c-73be-60ca-c892fb19ed08@suse.cz>
 <f8d7b5f9-e5ee-0625-f53d-50d1841e1388@redhat.com>
 <20180724072237.GA28386@dhcp22.suse.cz>
 <e5264f8e-2bb5-7a9b-6352-ad18f04d49c2@redhat.com>
 <20180726083042.GC28386@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <21c31952-7632-b8e1-aa33-d124ce96b88e@redhat.com>
Date: Thu, 26 Jul 2018 10:45:54 +0200
MIME-Version: 1.0
In-Reply-To: <20180726083042.GC28386@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Dave Young <dyoung@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?Q?Marc-Andr=c3=a9_Lureau?= <marcandre.lureau@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Miles Chen <miles.chen@mediatek.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Tesarik <ptesarik@suse.cz>

On 26.07.2018 10:30, Michal Hocko wrote:
> On Thu 26-07-18 10:22:41, David Hildenbrand wrote:
>> On 24.07.2018 09:22, Michal Hocko wrote:
>>> On Mon 23-07-18 19:12:58, David Hildenbrand wrote:
>>>> On 23.07.2018 13:45, Vlastimil Babka wrote:
>>>>> On 07/20/2018 02:34 PM, David Hildenbrand wrote:
>>>>>> Dumping tools (like makedumpfile) right now don't exclude reserved pages.
>>>>>> So reserved pages might be access by dump tools although nobody except
>>>>>> the owner should touch them.
>>>>>
>>>>> Are you sure about that? Or maybe I understand wrong. Maybe it changed
>>>>> recently, but IIRC pages that are backing memmap (struct pages) are also
>>>>> PG_reserved. And you definitely do want those in the dump.
>>>>
>>>> I proposed a new flag/value to mask pages that are logically offline but
>>>> Michal wanted me to go into this direction.
>>>>
>>>> While we can special case struct pages in dump tools ("we have to
>>>> read/interpret them either way, so we can also dump them"), it smells
>>>> like my original attempt was cleaner. Michal?
>>>
>>> But we do not have many page flags spare and even if we have one or two
>>> this doesn't look like the use for them. So I still think we should try
>>> the PageReserved way.
>>>
>>
>> So as a summary, the only real approach that would be acceptable is
>> using PageReserved + some other identifier to mark pages as "logically
>> offline".
>>
>> I wonder what identifier could be used, as this has to be consistent for
>> all reserved pages (to avoid false positives).
>>
>> Using other pageflags in combination might be possible, but then we have
>> to make assumptions about all users of PageReserved right now.
>>
>> As far as I can see (and as has been discussed), page_type could be
>> used. If we don't want to consume a new bit, we could overload/reuse the
>> "PG_balloon" bit.
>>
>>
>> E.g. "PG_balloon" set -> exclude page from dump
> 
> Does each user of PG_balloon check for PG_reserved? If this is the case
> then yes this would be OK.
> 

I can only spot one user of PageBalloon() at all (fs/proc/page.c) ,
which makes me wonder if this bit is actually still relevant. I think
the last "real" user was removed with

commit b1123ea6d3b3da25af5c8a9d843bd07ab63213f4
Author: Minchan Kim <minchan@kernel.org>
Date:   Tue Jul 26 15:23:09 2016 -0700

    mm: balloon: use general non-lru movable page feature

    Now, VM has a feature to migrate non-lru movable pages so balloon
    doesn't need custom migration hooks in migrate.c and compaction.c.


The only user of PG_balloon in general is
"include/linux/balloon_compaction.h", used effectively only by
virtio_balloon.

All such pages are allocated via balloon_page_alloc() and never set
reserved.

So to me it looks like PG_balloon could be easily reused, especially to
also exclude virtio-balloon pages from dumps.


-- 

Thanks,

David / dhildenb
