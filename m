Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E3866B4C13
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 03:47:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id k58so12177773eda.20
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 00:47:32 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p14-v6sor1899332ejd.14.2018.11.28.00.47.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 00:47:31 -0800 (PST)
Date: Wed, 28 Nov 2018 08:47:29 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181128084729.jozab2gaej5vh7ig@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <20181128010112.5tv7tpe3qeplzy6d@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128010112.5tv7tpe3qeplzy6d@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, Nov 28, 2018 at 01:01:12AM +0000, Wei Yang wrote:
>On Mon, Nov 26, 2018 at 11:17:40PM -0800, Dave Hansen wrote:
>>On 11/26/18 10:25 PM, Michal Hocko wrote:
>>> [Cc Dave who has added the lock into this path. Maybe he remembers why]
>>
>>I don't remember specifically.  But, the pattern of:
>>
>>	allocate
>>	lock
>>	set
>>	unlock
>>
>>is _usually_ so we don't have two "sets" racing with each other.  In
>>this case, that would have been to ensure that two
>>sparse_init_one_section()'s didn't race and leak one of the two
>>allocated memmaps or worse.
>>
>>I think mem_hotplug_lock protects this case these days, though.  I don't
>>think we had it in the early days and were just slumming it with the
>>pgdat locks.
>>
>>I really don't like the idea of removing the lock by just saying it
>>doesn't protect anything without doing some homework first, though.  It
>>would actually be really nice to comment the entire call chain from the
>>mem_hotplug_lock acquisition to here.  There is precious little
>>commenting in there and it could use some love.
>
>Dave,
>
>Thanks for your comment :-)
>
>I should put more words to the reason for removing the lock.
>
>Here is a simplified call trace for sparse_add_one_section() during
>physical add/remove phase.
>
>    __add_memory()
>        add_memory_resource()
>    	mem_hotplug_begin()
>    
>    	arch_add_memory()
>    	    add_pages()
>    	        __add_pages()
>    	            __add_section()
>    	                sparse_add_one_section(pfn)
>    
>    	mem_hotplug_done()
>
>When we just look at the sparse section initialization, we can see the
>contention happens when __add_memory() try to add a same range or range
>overlapped in SECTIONS_PER_ROOT number of sections. Otherwise, they
>won't access the same memory. 
>
>If this happens, we may face two contentions:
>
>    * reallocation of mem_section[root]
>    * reallocation of memmap and usemap
>
>While neither of them could be protected by the pgdat_resize_lock from
>my understanding. Grab pgdat_resize_lock just slow down the process,
>while finally they will replace the mem_section[root] and
>ms->section_mem_map with their own new allocated data.
>

Hmm... sorry, I am not correct here.

The pgdat_resize_lock do protect the second case.

But not the first one.

>Last bu not the least, to be honest, even the global mem_hotplug_lock
>doesn't help in this situation. In case __add_memory() try to add the
>same range twice, the sparse section would be initialized twice. Which
>means it will be overwritten with the new allocated memmap/usermap.
>

The mem_section[root] still has a chance to face the contention here.

>But maybe we have the assumption this reentrance will not happen.
>
>This is all what I understand, in case there is some misunderstanding,
>please let me know.

I will rewrite the changelog to emphasize this process is protected by
the global mem_hotplug_lock.

>
>-- 
>Wei Yang
>Help you, Help me

-- 
Wei Yang
Help you, Help me
