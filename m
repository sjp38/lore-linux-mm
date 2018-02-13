Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7923F6B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 16:07:32 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id e33so13155075uae.22
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 13:07:32 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o189si750961vka.113.2018.02.13.13.07.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 13:07:31 -0800 (PST)
Subject: Re: [RFC PATCH v1 00/13] lru_lock scalability
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180208153652.481a77e57cc32c9e1a7e4269@linux-foundation.org>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <40c02402-ab76-6bd2-5e7d-77fea82e55fe@oracle.com>
Date: Tue, 13 Feb 2018 16:07:19 -0500
MIME-Version: 1.0
In-Reply-To: <20180208153652.481a77e57cc32c9e1a7e4269@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 02/08/2018 06:36 PM, Andrew Morton wrote:
> On Wed, 31 Jan 2018 18:04:00 -0500 daniel.m.jordan@oracle.com wrote:
> 
>> lru_lock, a per-node* spinlock that protects an LRU list, is one of the
>> hottest locks in the kernel.  On some workloads on large machines, it
>> shows up at the top of lock_stat.
> 
> Do you have details on which callsites are causing the problem?  That
> would permit us to consider other approaches, perhaps.

Sure, there are two paths where we're seeing contention.

In the first one, a pagevec's worth of anonymous pages are added to 
various LRUs when the per-cpu pagevec fills up:

   /* take an anonymous page fault, eventually end up at... */
   handle_pte_fault
     do_anonymous_page
       lru_cache_add_active_or_unevictable
         lru_cache_add
           __lru_cache_add
             __pagevec_lru_add
               pagevec_lru_move_fn
                 /* contend on lru_lock */


In the second, one or more pages are removed from an LRU under one hold 
of lru_lock:

   // userland calls munmap or exit, eventually end up at...
   zap_pte_range
     __tlb_remove_page // returns true because we eventually hit
                       // MAX_GATHER_BATCH_COUNT in tlb_next_batch
     tlb_flush_mmu_free
       free_pages_and_swap_cache
         release_pages
           /* contend on lru_lock */


For a broader context, we've run decision support benchmarks where 
lru_lock (and zone->lock) show long wait times. But we're not the only 
ones according to certain kernel comments:

mm/vmscan.c:
  * zone_lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
  *
  * For pagecache intensive workloads, this function is the hottest
  * spot in the kernel (apart from copy_*_user functions).
...
static unsigned long isolate_lru_pages(unsigned long nr_to_scan,


include/linux/mmzone.h:
  * zone->lock and the [pgdat->lru_lock] are two of the hottest locks in 
the kernel.
  * So add a wild amount of padding here to ensure that they fall into 
separate
  * cachelines. ...


Anyway, if you're seeing this lock in your workloads, I'm interested in 
hearing what you're running so we can get more real world data on this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
