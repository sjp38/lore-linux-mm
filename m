Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6F816B0008
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 23:18:11 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id u133so14861372qka.12
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 20:18:11 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v8si1273873qkb.257.2018.02.01.20.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 20:18:11 -0800 (PST)
Subject: Re: [RFC PATCH v1 00/13] lru_lock scalability
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <6bd1c8a5-c682-a3ce-1f9f-f1f53b4117a9@redhat.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <e3e47085-1b5e-0d2e-f8cb-03defb9af0dd@oracle.com>
Date: Thu, 1 Feb 2018 23:18:01 -0500
MIME-Version: 1.0
In-Reply-To: <6bd1c8a5-c682-a3ce-1f9f-f1f53b4117a9@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com



On 02/01/2018 10:54 AM, Steven Whitehouse wrote:
> Hi,
> 
> 
> On 31/01/18 23:04, daniel.m.jordan@oracle.com wrote:
>> lru_lock, a per-node* spinlock that protects an LRU list, is one of the
>> hottest locks in the kernel.A  On some workloads on large machines, it
>> shows up at the top of lock_stat.
>>
>> One way to improve lru_lock scalability is to introduce an array of locks,
>> with each lock protecting certain batches of LRU pages.
>>
>> A A A A A A A A  *ooooooooooo**ooooooooooo**ooooooooooo**oooo ...
>> A A A A A A A A  |A A A A A A A A A A  ||A A A A A A A A A A  ||A A A A A A A A A A  ||
>> A A A A A A A A A  \ batch 1 /A  \ batch 2 /A  \ batch 3 /
>>
>> In this ASCII depiction of an LRU, a page is represented with either '*'
>> or 'o'.A  An asterisk indicates a sentinel page, which is a page at the
>> edge of a batch.A  An 'o' indicates a non-sentinel page.
>>
>> To remove a non-sentinel LRU page, only one lock from the array is
>> required.A  This allows multiple threads to remove pages from different
>> batches simultaneously.A  A sentinel page requires lru_lock in addition to
>> a lock from the array.
>>
>> Full performance numbers appear in the last patch in this series, but this
>> prototype allows a microbenchmark to do up to 28% more page faults per
>> second with 16 or more concurrent processes.
>>
>> This work was developed in collaboration with Steve Sistare.
>>
>> Note: This is an early prototype.A  I'm submitting it now to support my
>> request to attend LSF/MM, as well as get early feedback on the idea.A  Any
>> comments appreciated.
>>
>>
>> * lru_lock is actually per-memcg, but without memcg's in the picture it
>> A A  becomes per-node.
> GFS2 has an lru list for glocks, which can be contended under certain workloads. Work is still ongoing to figure out exactly why, but this looks like it might be a good approach to that issue too. The main purpose of GFS2's lru list is to allow shrinking of the glocks under memory pressure via the gfs2_scan_glock_lru() function, and it looks like this type of approach could be used there to improve the scalability,

Glad to hear that this could help in gfs2 as well.

Hopefully struct gfs2_glock is less space constrained than struct page for storing the few bits of metadata that this approach requires.

Daniel

> 
> Steve.
> 
>>
>> Aaron Lu (1):
>> A A  mm: add a percpu_pagelist_batch sysctl interface
>>
>> Daniel Jordan (12):
>> A A  mm: allow compaction to be disabled
>> A A  mm: add lock array to pgdat and batch fields to struct page
>> A A  mm: introduce struct lru_list_head in lruvec to hold per-LRU batch
>> A A A A  info
>> A A  mm: add batching logic to add/delete/move API's
>> A A  mm: add lru_[un]lock_all APIs
>> A A  mm: convert to-be-refactored lru_lock callsites to lock-all API
>> A A  mm: temporarily convert lru_lock callsites to lock-all API
>> A A  mm: introduce add-only version of pagevec_lru_move_fn
>> A A  mm: add LRU batch lock API's
>> A A  mm: use lru_batch locking in release_pages
>> A A  mm: split up release_pages into non-sentinel and sentinel passes
>> A A  mm: splice local lists onto the front of the LRU
>>
>> A  include/linux/mm_inline.h | 209 +++++++++++++++++++++++++++++++++++++++++++++-
>> A  include/linux/mm_types.hA  |A A  5 ++
>> A  include/linux/mmzone.hA A A  |A  25 +++++-
>> A  kernel/sysctl.cA A A A A A A A A A  |A A  9 ++
>> A  mm/KconfigA A A A A A A A A A A A A A A  |A A  1 -
>> A  mm/huge_memory.cA A A A A A A A A  |A A  6 +-
>> A  mm/memcontrol.cA A A A A A A A A A  |A A  5 +-
>> A  mm/mlock.cA A A A A A A A A A A A A A A  |A  11 +--
>> A  mm/mmzone.cA A A A A A A A A A A A A A  |A A  7 +-
>> A  mm/page_alloc.cA A A A A A A A A A  |A  43 +++++++++-
>> A  mm/page_idle.cA A A A A A A A A A A  |A A  4 +-
>> A  mm/swap.cA A A A A A A A A A A A A A A A  | 208 ++++++++++++++++++++++++++++++++++++---------
>> A  mm/vmscan.cA A A A A A A A A A A A A A  |A  49 +++++------
>> A  13 files changed, 500 insertions(+), 82 deletions(-)
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
