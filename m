Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA2B6B6B13
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 16:06:39 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so6990284eda.12
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 13:06:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e44sor8107353ede.13.2018.12.03.13.06.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 13:06:38 -0800 (PST)
Date: Mon, 3 Dec 2018 21:06:36 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181203210636.cdocbv7432dqjl7z@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
 <20181130042815.t44nroyqcqa3tpgv@master>
 <e44018ff-b3d1-a1e2-3496-9554ff148fc4@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e44018ff-b3d1-a1e2-3496-9554ff148fc4@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Dec 03, 2018 at 12:25:20PM +0100, David Hildenbrand wrote:
>On 30.11.18 05:28, Wei Yang wrote:
>> On Thu, Nov 29, 2018 at 05:06:15PM +0100, David Hildenbrand wrote:
>>> On 29.11.18 16:53, Wei Yang wrote:
>>>> pgdat_resize_lock is used to protect pgdat's memory region information
>>>> like: node_start_pfn, node_present_pages, etc. While in function
>>>> sparse_add/remove_one_section(), pgdat_resize_lock is used to protect
>>>> initialization/release of one mem_section. This looks not proper.
>>>>
>>>> Based on current implementation, even remove this lock, mem_section
>>>> is still away from contention, because it is protected by global
>>>> mem_hotpulg_lock.
>>>
>>> s/mem_hotpulg_lock/mem_hotplug_lock/
>>>
>>>>
>>>> Following is the current call trace of sparse_add/remove_one_section()
>>>>
>>>>     mem_hotplug_begin()
>>>>     arch_add_memory()
>>>>        add_pages()
>>>>            __add_pages()
>>>>                __add_section()
>>>>                    sparse_add_one_section()
>>>>     mem_hotplug_done()
>>>>
>>>>     mem_hotplug_begin()
>>>>     arch_remove_memory()
>>>>         __remove_pages()
>>>>             __remove_section()
>>>>                 sparse_remove_one_section()
>>>>     mem_hotplug_done()
>>>>
>>>> The comment above the pgdat_resize_lock also mentions "Holding this will
>>>> also guarantee that any pfn_valid() stays that way.", which is true with
>>>> the current implementation and false after this patch. But current
>>>> implementation doesn't meet this comment. There isn't any pfn walkers
>>>> to take the lock so this looks like a relict from the past. This patch
>>>> also removes this comment.
>>>
>>> Should we start to document which lock is expected to protect what?
>>>
>>> I suggest adding what you just found out to
>>> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
>>> Maybe a new subsection for mem_hotplug_lock. And eventually also
>>> pgdat_resize_lock.
>> 
>> Well, I am not good at document writting. Below is my first trial.  Look
>> forward your comments.
>> 
>> BTW, in case I would send a new version with this, would I put this into
>> a separate one or merge this into current one?
>> 
>> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
>> index 5c4432c96c4b..1548820a0762 100644
>> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
>> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
>
>BTW, it really should go into
>
>Documentation/core-api/memory-hotplug.rst
>
>Something got wrong while merging this in linux-next, so now we have
>duplicate documentation and the one in
>Documentation/admin-guide/mm/memory-hotplug.rst about locking internals
>has to go.
>

Sounds reasonable.

Admin may not necessary need to understand the internal locking.

-- 
Wei Yang
Help you, Help me
