Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5356B0008
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:28 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id v32so11452947uaf.13
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:28 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h30si543359uac.224.2018.01.31.15.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:27 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 00/13] lru_lock scalability
Date: Wed, 31 Jan 2018 18:04:00 -0500
Message-Id: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

lru_lock, a per-node* spinlock that protects an LRU list, is one of the
hottest locks in the kernel.  On some workloads on large machines, it
shows up at the top of lock_stat.

One way to improve lru_lock scalability is to introduce an array of locks,
with each lock protecting certain batches of LRU pages.

        *ooooooooooo**ooooooooooo**ooooooooooo**oooo ...
        |           ||           ||           ||
         \ batch 1 /  \ batch 2 /  \ batch 3 /  

In this ASCII depiction of an LRU, a page is represented with either '*'
or 'o'.  An asterisk indicates a sentinel page, which is a page at the
edge of a batch.  An 'o' indicates a non-sentinel page.

To remove a non-sentinel LRU page, only one lock from the array is
required.  This allows multiple threads to remove pages from different
batches simultaneously.  A sentinel page requires lru_lock in addition to
a lock from the array.

Full performance numbers appear in the last patch in this series, but this
prototype allows a microbenchmark to do up to 28% more page faults per
second with 16 or more concurrent processes.

This work was developed in collaboration with Steve Sistare.

Note: This is an early prototype.  I'm submitting it now to support my
request to attend LSF/MM, as well as get early feedback on the idea.  Any
comments appreciated.


* lru_lock is actually per-memcg, but without memcg's in the picture it
  becomes per-node.


Aaron Lu (1):
  mm: add a percpu_pagelist_batch sysctl interface

Daniel Jordan (12):
  mm: allow compaction to be disabled
  mm: add lock array to pgdat and batch fields to struct page
  mm: introduce struct lru_list_head in lruvec to hold per-LRU batch
    info
  mm: add batching logic to add/delete/move API's
  mm: add lru_[un]lock_all APIs
  mm: convert to-be-refactored lru_lock callsites to lock-all API
  mm: temporarily convert lru_lock callsites to lock-all API
  mm: introduce add-only version of pagevec_lru_move_fn
  mm: add LRU batch lock API's
  mm: use lru_batch locking in release_pages
  mm: split up release_pages into non-sentinel and sentinel passes
  mm: splice local lists onto the front of the LRU

 include/linux/mm_inline.h | 209 +++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/mm_types.h  |   5 ++
 include/linux/mmzone.h    |  25 +++++-
 kernel/sysctl.c           |   9 ++
 mm/Kconfig                |   1 -
 mm/huge_memory.c          |   6 +-
 mm/memcontrol.c           |   5 +-
 mm/mlock.c                |  11 +--
 mm/mmzone.c               |   7 +-
 mm/page_alloc.c           |  43 +++++++++-
 mm/page_idle.c            |   4 +-
 mm/swap.c                 | 208 ++++++++++++++++++++++++++++++++++++---------
 mm/vmscan.c               |  49 +++++------
 13 files changed, 500 insertions(+), 82 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
