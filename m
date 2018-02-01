Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB736B0006
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 10:54:44 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id k19so12488599otj.6
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 07:54:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v25si1131867oti.494.2018.02.01.07.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 07:54:43 -0800 (PST)
Subject: Re: [RFC PATCH v1 00/13] lru_lock scalability
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
From: Steven Whitehouse <swhiteho@redhat.com>
Message-ID: <6bd1c8a5-c682-a3ce-1f9f-f1f53b4117a9@redhat.com>
Date: Thu, 1 Feb 2018 15:54:38 +0000
MIME-Version: 1.0
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.m.jordan@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Hi,


On 31/01/18 23:04, daniel.m.jordan@oracle.com wrote:
> lru_lock, a per-node* spinlock that protects an LRU list, is one of the
> hottest locks in the kernel.  On some workloads on large machines, it
> shows up at the top of lock_stat.
>
> One way to improve lru_lock scalability is to introduce an array of locks,
> with each lock protecting certain batches of LRU pages.
>
>          *ooooooooooo**ooooooooooo**ooooooooooo**oooo ...
>          |           ||           ||           ||
>           \ batch 1 /  \ batch 2 /  \ batch 3 /
>
> In this ASCII depiction of an LRU, a page is represented with either '*'
> or 'o'.  An asterisk indicates a sentinel page, which is a page at the
> edge of a batch.  An 'o' indicates a non-sentinel page.
>
> To remove a non-sentinel LRU page, only one lock from the array is
> required.  This allows multiple threads to remove pages from different
> batches simultaneously.  A sentinel page requires lru_lock in addition to
> a lock from the array.
>
> Full performance numbers appear in the last patch in this series, but this
> prototype allows a microbenchmark to do up to 28% more page faults per
> second with 16 or more concurrent processes.
>
> This work was developed in collaboration with Steve Sistare.
>
> Note: This is an early prototype.  I'm submitting it now to support my
> request to attend LSF/MM, as well as get early feedback on the idea.  Any
> comments appreciated.
>
>
> * lru_lock is actually per-memcg, but without memcg's in the picture it
>    becomes per-node.
GFS2 has an lru list for glocks, which can be contended under certain 
workloads. Work is still ongoing to figure out exactly why, but this 
looks like it might be a good approach to that issue too. The main 
purpose of GFS2's lru list is to allow shrinking of the glocks under 
memory pressure via the gfs2_scan_glock_lru() function, and it looks 
like this type of approach could be used there to improve the scalability,

Steve.

>
> Aaron Lu (1):
>    mm: add a percpu_pagelist_batch sysctl interface
>
> Daniel Jordan (12):
>    mm: allow compaction to be disabled
>    mm: add lock array to pgdat and batch fields to struct page
>    mm: introduce struct lru_list_head in lruvec to hold per-LRU batch
>      info
>    mm: add batching logic to add/delete/move API's
>    mm: add lru_[un]lock_all APIs
>    mm: convert to-be-refactored lru_lock callsites to lock-all API
>    mm: temporarily convert lru_lock callsites to lock-all API
>    mm: introduce add-only version of pagevec_lru_move_fn
>    mm: add LRU batch lock API's
>    mm: use lru_batch locking in release_pages
>    mm: split up release_pages into non-sentinel and sentinel passes
>    mm: splice local lists onto the front of the LRU
>
>   include/linux/mm_inline.h | 209 +++++++++++++++++++++++++++++++++++++++++++++-
>   include/linux/mm_types.h  |   5 ++
>   include/linux/mmzone.h    |  25 +++++-
>   kernel/sysctl.c           |   9 ++
>   mm/Kconfig                |   1 -
>   mm/huge_memory.c          |   6 +-
>   mm/memcontrol.c           |   5 +-
>   mm/mlock.c                |  11 +--
>   mm/mmzone.c               |   7 +-
>   mm/page_alloc.c           |  43 +++++++++-
>   mm/page_idle.c            |   4 +-
>   mm/swap.c                 | 208 ++++++++++++++++++++++++++++++++++++---------
>   mm/vmscan.c               |  49 +++++------
>   13 files changed, 500 insertions(+), 82 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
