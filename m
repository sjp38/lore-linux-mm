Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E43D6B4C2F
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 04:17:14 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so12237491edd.2
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 01:17:13 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z15-v6sor1943853eju.2.2018.11.28.01.17.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Nov 2018 01:17:12 -0800 (PST)
Date: Wed, 28 Nov 2018 09:17:11 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181128091711.ky7ub3kvkxvjq7ys@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
 <20181128010112.5tv7tpe3qeplzy6d@master>
 <20181128084729.jozab2gaej5vh7ig@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181128084729.jozab2gaej5vh7ig@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, Nov 28, 2018 at 08:47:29AM +0000, Wei Yang wrote:
>>
>>Dave,
>>
>>Thanks for your comment :-)
>>
>>I should put more words to the reason for removing the lock.
>>
>>Here is a simplified call trace for sparse_add_one_section() during
>>physical add/remove phase.
>>
>>    __add_memory()
>>        add_memory_resource()
>>    	mem_hotplug_begin()
>>    
>>    	arch_add_memory()
>>    	    add_pages()
>>    	        __add_pages()
>>    	            __add_section()
>>    	                sparse_add_one_section(pfn)
>>    
>>    	mem_hotplug_done()
>>
>>When we just look at the sparse section initialization, we can see the
>>contention happens when __add_memory() try to add a same range or range
>>overlapped in SECTIONS_PER_ROOT number of sections. Otherwise, they
>>won't access the same memory. 
>>
>>If this happens, we may face two contentions:
>>
>>    * reallocation of mem_section[root]
>>    * reallocation of memmap and usemap
>>
>>While neither of them could be protected by the pgdat_resize_lock from
>>my understanding. Grab pgdat_resize_lock just slow down the process,
>>while finally they will replace the mem_section[root] and
>>ms->section_mem_map with their own new allocated data.
>>
>
>Hmm... sorry, I am not correct here.
>
>The pgdat_resize_lock do protect the second case.
>
>But not the first one.
>

One more thing, (hope I am not too talkative)

Expand the pgdat_resize_lock to include sparse_index_init() may not
work. Because SECTIONS_PER_ROOT number of section may span two nodes.


-- 
Wei Yang
Help you, Help me
