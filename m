Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81FE88E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 22:37:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so8720058pgc.22
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 19:37:21 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id z11-v6si1003421pgf.66.2018.09.24.19.37.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Sep 2018 19:37:19 -0700 (PDT)
Date: Tue, 25 Sep 2018 10:37:09 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/9] Improve zone lock scalability using Daniel
 Jordan's list work
Message-ID: <20180925023709.GA28604@intel.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
 <20180921174536.7igaoi36rg76auy4@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921174536.7igaoi36rg76auy4@ca-dmjordan1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Fri, Sep 21, 2018 at 10:45:36AM -0700, Daniel Jordan wrote:
> On Tue, Sep 11, 2018 at 01:36:07PM +0800, Aaron Lu wrote:
> > Daniel Jordan and others proposed an innovative technique to make
> > multiple threads concurrently use list_del() at any position of the
> > list and list_add() at head position of the list without taking a lock
> > in this year's MM summit[0].
> > 
> > People think this technique may be useful to improve zone lock
> > scalability so here is my try.
> 
> Nice, this uses the smp_list_* functions well in spite of the limitations you
> encountered with them here.
> 
> > Performance wise on 56 cores/112 threads Intel Skylake 2 sockets server
> > using will-it-scale/page_fault1 process mode(higher is better):
> > 
> > kernel        performance      zone lock contention
> > patch1         9219349         76.99%
> > patch7         2461133 -73.3%  54.46%(another 34.66% on smp_list_add())
> > patch8        11712766 +27.0%  68.14%
> > patch9        11386980 +23.5%  67.18%
> 
> Is "zone lock contention" the percentage that readers and writers combined
> spent waiting?  I'm curious to see read and write wait time broken out, since
> it seems there are writers (very likely on the allocation side) spoiling the
> parallelism we get with the read lock.

lock contention is combined, read side consumes about 31% while write
side consumes 35%. Write side definitely is blocking read side.

I also tried not taking lock in read mode on free path to avoid free
path blocking on allocation path, but that caused other unplesant
consequences for allocation path, namely the free_list head->next can
be NULL when allocating pages due to free path can be adding pages to
the list using smp_list_add/splice so I had to use free_list head->prev
instead to fetch pages on allocation path. Also, the fetched page can be
merged in the mean time on free path so need to confirm if it is really
usable, etc. This complicated allocation path and didn't deliver good
results so I gave up this idea.

> If the contention is from allocation, I wonder whether it's feasible to make
> that path use SMP list functions.  Something like smp_list_cut_position
> combined with using page clusters from [*] to cut off a chunk of list.  Many
> details to keep in mind there, though, like having to unset PageBuddy in that
> list chunk when other tasks can be concurrently merging pages that are part of
> it.

As you put here, the PageBuddy flag is a problem. If I cut off a batch
of pages from free_list and then dropping the lock, these pages will
have PageBuddy flag set and free path can attempt a merge with any of
these pages and cause problems.

PageBuddy flag can not be cleared with lock held since that would
require accessing 'struct page's for these pages and it is the most time
consuming part among all operations that happened on allocation path
under zone lock.

This is doable in your referenced no_merge+cluster_alloc approach because
we skipped merge most of the time. And when merge really needs to
happen like in compaction, cluser_alloc will be disabled.

> Or maybe what's needed is a more scalable data structure than an array of
> lists, since contention on the heads seems to be the limiting factor.  A simple
> list that keeps the pages in most-recently-used order (except when adding to
> the list tail) is good for cache warmth, but I wonder how helpful that is when
> all CPUs can allocate from the front.  Having multiple places to put pages of a
> given order/mt would ease the contention.

Agree.

> > Though lock contention reduced a lot for patch7, the performance dropped
> > considerably due to severe cache bouncing on free list head among
> > multiple threads doing page free at the same time, because every page free
> > will need to add the page to the free list head.
> 
> Could be beneficial to take an MCS-style approach in smp_list_splice/add so
> that multiple waiters aren't bouncing the same cacheline around.  This is
> something I'm planning to try on lru_lock.

That's a good idea.
If that is done, we can at least parallelise free path and gain
something by not paying the penalty of cache bouncing on list head.

> 
> Daniel
> 
> [*] https://lkml.kernel.org/r/20180509085450.3524-1-aaron.lu@intel.com

And thanks a lot for the comments!
