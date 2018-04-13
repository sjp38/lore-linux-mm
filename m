Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 479FE6B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:24:08 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 47so2002837wru.19
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 02:24:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l41si2327520edd.268.2018.04.13.02.24.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 02:24:06 -0700 (PDT)
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180320173512.GA19669@bombadil.infradead.org>
 <alpine.DEB.2.20.1803201250480.27540@nuc-kabylake>
 <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake>
 <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <20c58a03-90a8-7e75-5fc7-856facfb6c8a@suse.cz>
Date: Fri, 13 Apr 2018 11:22:07 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>, Christopher Lameter <cl@linux.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On 03/21/2018 07:36 PM, Mikulas Patocka wrote:
> 
> 
> On Wed, 21 Mar 2018, Christopher Lameter wrote:
> 
>> On Wed, 21 Mar 2018, Mikulas Patocka wrote:
>>
>>>> You should not be using the slab allocators for these. Allocate higher
>>>> order pages or numbers of consecutive smaller pagess from the page
>>>> allocator. The slab allocators are written for objects smaller than page
>>>> size.
>>>
>>> So, do you argue that I need to write my own slab cache functionality
>>> instead of using the existing slab code?
>>
>> Just use the existing page allocator calls to allocate and free the
>> memory you need.
>>
>>> I can do it - but duplicating code is bad thing.
>>
>> There is no need to duplicate anything. There is lots of infrastructure
>> already in the kernel. You just need to use the right allocation / freeing
>> calls.
> 
> So, what would you recommend for allocating 640KB objects while minimizing 
> wasted space?
> * alloc_pages - rounds up to the next power of two
> * kmalloc - rounds up to the next power of two
> * alloc_pages_exact - O(n*log n) complexity; and causes memory 
>   fragmentation if used excesivelly
> * vmalloc - horrible performance (modifies page tables and that causes 
>   synchronization across all CPUs)
> 
> anything else?
> 
> The slab cache with large order seems as a best choice for this.

Sorry for being late, I just read this thread and tend to agree with
Mikulas, that this is a good use case for SL*B. If we extend the
use-case from "space-efficient allocator of objects smaller than page
size" to "space-efficient allocator of objects that are not power-of-two
pages" then IMHO it turns out the implementation would be almost the
same. All other variants listed above would lead to waste of memory or
fragmentation.

Would this perhaps be a good LSF/MM discussion topic? Mikulas, are you
attending, or anyone else that can vouch for your usecase?
