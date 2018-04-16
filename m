Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1EBD96B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 04:31:58 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y2so344576qki.21
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 01:31:58 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id f21si3151562qtm.354.2018.04.16.01.31.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 01:31:57 -0700 (PDT)
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413171120.GA1245@bombadil.infradead.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <1ecb2fe4-a22e-813f-a157-1fdaf3cbc8d1@redhat.com>
Date: Mon, 16 Apr 2018 10:31:48 +0200
MIME-Version: 1.0
In-Reply-To: <20180413171120.GA1245@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On 13.04.2018 19:11, Matthew Wilcox wrote:
> On Fri, Apr 13, 2018 at 03:16:26PM +0200, David Hildenbrand wrote:
>> online_pages()/offline_pages() theoretically allows us to work on
>> sub-section sizes. This is especially relevant in the context of
>> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
>> 4MB chunks.
>>
>> While the whole section is marked as online/offline, we have to know
>> the state of each page. E.g. to not read memory that is not online
>> during kexec() or to properly mark a section as offline as soon as all
>> contained pages are offline.
> 
> Can you not use PG_reserved for this purpose?
> 
>> + * PG_offline indicates that a page is offline and the backing storage
>> + * might already have been removed (virtualization). Don't touch!
> 
>  * PG_reserved is set for special pages, which can never be swapped out. Some
>  * of them might not even exist...
> 
> They seem pretty congruent to me.
> 

Can we really go ahead and make dump tools exclude any PG_reserved page
from a memory dump? While it might be true for ballooned pages, I doubt
that this assumption holds in general. ("cannot be swapped out" doesn't
imply "content should never be read/dumped")


I need PG_offline right now for two reasons:

1. Make kdump skip these pages (like PG_hwpoison), because they might
not even be readable anymore as the hypervisor might have restricted
memory access completely.

2. Detect when all pages of a memory section are offline, so we can mark
the section as offline and eventually remove it.


A clear point speaking against using PG_reserved for 2. is the following
simple example.

Let's assume we use virtio-balloon and inflated some chunk of memory in
a section (let's say 4MB). Now we offline (using the new driver) all
other chunks in a section, except the memory allocated by
virtio-balloon. We would suddenly mark the section as offline and
eventually remove it. This is of course very bad.


I think using PG_reserved for 1. is wrong. PG_reserved is usually used
for pages _after_ coming from an allocator. Using PG_reserved for 2.
will not work.


An ugly way for 2. would be, remembering for each section which pages
are actually online, but I would like to avoid that, especially as it
only solves part of a problem.

-- 

Thanks,

David / dhildenb
