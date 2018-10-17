Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A549D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 11:17:07 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s141-v6so20113555pgs.23
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 08:17:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id 3-v6si16689821plx.33.2018.10.17.08.17.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 08:17:06 -0700 (PDT)
Subject: Re: [mm PATCH v3 3/6] mm: Use memblock/zone specific iterator for
 handling deferred page init
References: <20181015202456.2171.88406.stgit@localhost.localdomain>
 <20181015202709.2171.75580.stgit@localhost.localdomain>
 <20181017091154.GK18839@dhcp22.suse.cz>
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Message-ID: <ff1add3a-446b-1e30-c4c2-cfab035f11f2@linux.intel.com>
Date: Wed, 17 Oct 2018 08:17:05 -0700
MIME-Version: 1.0
In-Reply-To: <20181017091154.GK18839@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, pavel.tatashin@microsoft.com, dave.jiang@intel.com, linux-kernel@vger.kernel.org, willy@infradead.org, davem@davemloft.net, yi.z.zhang@linux.intel.com, khalid.aziz@oracle.com, rppt@linux.vnet.ibm.com, vbabka@suse.cz, sparclinux@vger.kernel.org, dan.j.williams@intel.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mingo@kernel.org, kirill.shutemov@linux.intel.com

On 10/17/2018 2:11 AM, Michal Hocko wrote:
> On Mon 15-10-18 13:27:09, Alexander Duyck wrote:
>> This patch introduces a new iterator for_each_free_mem_pfn_range_in_zone.
>>
>> This iterator will take care of making sure a given memory range provided
>> is in fact contained within a zone. It takes are of all the bounds checking
>> we were doing in deferred_grow_zone, and deferred_init_memmap. In addition
>> it should help to speed up the search a bit by iterating until the end of a
>> range is greater than the start of the zone pfn range, and will exit
>> completely if the start is beyond the end of the zone.
>>
>> This patch adds yet another iterator called
>> for_each_free_mem_range_in_zone_from and then uses it to support
>> initializing and freeing pages in groups no larger than MAX_ORDER_NR_PAGES.
>> By doing this we can greatly improve the cache locality of the pages while
>> we do several loops over them in the init and freeing process.
>>
>> We are able to tighten the loops as a result since we only really need the
>> checks for first_init_pfn in our first iteration and after that we can
>> assume that all future values will be greater than this. So I have added a
>> function called deferred_init_mem_pfn_range_in_zone that primes the
>> iterators and if it fails we can just exit.
> 
> Numbers please.
> 
> Besides that, this adds a lot of code and I am not convinced the result
> is so much better to justify that.
If I recall most of the gains are due to better cache locality. Instead 
of running through all of memory once for init, and once for freeing 
this patch has us doing it in MAX_ORDER_NR_PAGES sized chunks. So the 
advantage is that we can keep most of the pages structs in the L2 cache 
at least on x86 processors to avoid having to go to memory as much.

I'll run performance numbers per patch today and try to make certain I 
have a line mentioning the delta for each patch in the v4 patch set.

- Alex
