Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C7CF36B0007
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 07:35:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k21-v6so11184078ede.12
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 04:35:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i16-v6si6966769edv.433.2018.10.19.04.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Oct 2018 04:35:14 -0700 (PDT)
Subject: Re: [RFC PATCH v2 0/8] lru_lock scalability and SMP list functions
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <2705c814-a6b8-0b14-7ea8-790325833d95@suse.cz>
Date: Fri, 19 Oct 2018 13:35:11 +0200
MIME-Version: 1.0
In-Reply-To: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com

On 9/11/18 2:42 AM, Daniel Jordan wrote:
> Hi,
> 
> This is a work-in-progress of what I presented at LSF/MM this year[0] to
> greatly reduce contention on lru_lock, allowing it to scale on large systems.
> 
> This is completely different from the lru_lock series posted last January[1].
> 
> I'm hoping for feedback on the overall design and general direction as I do
> more real-world performance testing and polish the code.  Is this a workable
> approach?
> 
>                                         Thanks,
>                                           Daniel
> 
> ---
> 
> Summary:  lru_lock can be one of the hottest locks in the kernel on big
> systems.  It guards too much state, so introduce new SMP-safe list functions to
> allow multiple threads to operate on the LRUs at once.  The SMP list functions
> are provided in a standalone API that can be used in other parts of the kernel.
> When lru_lock and zone->lock are both fixed, the kernel can do up to 73.8% more
> page faults per second on a 44-core machine.
> 
> ---
> 
> On large systems, lru_lock can become heavily contended in memory-intensive
> workloads such as decision support, applications that manage their memory
> manually by allocating and freeing pages directly from the kernel, and
> workloads with short-lived processes that force many munmap and exit
> operations.  lru_lock also inhibits scalability in many of the MM paths that
> could be parallelized, such as freeing pages during exit/munmap and inode
> eviction.

Interesting, I would have expected isolate_lru_pages() to be the main
culprit, as the comment says:

 * For pagecache intensive workloads, this function is the hottest
 * spot in the kernel (apart from copy_*_user functions).

It also says "Some of the functions that shrink the lists perform better
by taking out a batch of pages and working on them outside the LRU
lock." Makes me wonder why isolate_lru_pages() also doesn't cut the list
first instead of doing per-page list_move() (and perhaps also prefetch
batch of struct pages outside the lock first? Could be doable with some
care hopefully).

> The problem is that lru_lock is too big of a hammer.  It guards all the LRUs in
> a pgdat's lruvec, needlessly serializing add-to-front, add-to-tail, and delete
> operations that are done on disjoint parts of an LRU, or even completely
> different LRUs.
> 
> This RFC series, developed in collaboration with Yossi Lev and Dave Dice,
> offers a two-part solution to this problem.
> 
> First, three new list functions are introduced to allow multiple threads to
> operate on the same linked list simultaneously under certain conditions, which
> are spelled out in more detail in code comments and changelogs.  The functions
> are smp_list_del, smp_list_splice, and smp_list_add, and do the same things as
> their non-SMP-safe counterparts.  These primitives may be used elsewhere in the
> kernel as the need arises; for example, in the page allocator free lists to
> scale zone->lock[2], or in file system LRUs[3].
> 
> Second, lru_lock is converted from a spinlock to a rwlock.  The idea is to
> repurpose rwlock as a two-mode lock, where callers take the lock in shared
> (i.e. read) mode for code using the SMP list functions, and exclusive (i.e.
> write) mode for existing code that expects exclusive access to the LRUs.
> Multiple threads are allowed in under the read lock, of course, and they use
> the SMP list functions to synchronize amongst themselves.
> 
> The rwlock is scaffolding to facilitate the transition from big-hammer lru_lock
> as it exists today to just using the list locking primitives and getting rid of
> lru_lock entirely.  Such an approach allows incremental conversion of lru_lock
> writers until everything uses the SMP list functions and takes the lock in
> shared mode, at which point lru_lock can just go away.

Yeah I guess that will need more care, e.g. I think smp_list_del() can
break any thread doing just a read-only traversal as it can end up with
an entry that's been deleted and its next/prev poisoned. It's a bit
counterintuitive that "read lock" is now enough for selected modify
operations, while read-only traversal would need a write lock.

> This RFC series is incomplete.  More, and more realistic, performance
> numbers are needed; for now, I show only will-it-scale/page_fault1.
> Also, there are extensions I'd like to make to the locking scheme to
> handle certain lru_lock paths--in particular, those where multiple
> threads may delete the same node from an LRU.  The SMP list functions
> now handle only removal of _adjacent_ nodes from an LRU.  Finally, the
> diffstat should become more supportive after I remove some of the code
> duplication in patch 6 by converting the rest of the per-CPU pagevec
> code in mm/swap.c to use the SMP list functions.
