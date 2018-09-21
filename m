Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4F9BB8E0002
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 13:46:07 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id f4-v6so23666515ioh.13
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 10:46:07 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id y131-v6si3724775ity.82.2018.09.21.10.46.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 10:46:05 -0700 (PDT)
Date: Fri, 21 Sep 2018 10:45:36 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH 0/9] Improve zone lock scalability using Daniel
 Jordan's list work
Message-ID: <20180921174536.7igaoi36rg76auy4@ca-dmjordan1.us.oracle.com>
References: <20180911053616.6894-1-aaron.lu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180911053616.6894-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Yosef Lev <levyossi@icloud.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Tue, Sep 11, 2018 at 01:36:07PM +0800, Aaron Lu wrote:
> Daniel Jordan and others proposed an innovative technique to make
> multiple threads concurrently use list_del() at any position of the
> list and list_add() at head position of the list without taking a lock
> in this year's MM summit[0].
> 
> People think this technique may be useful to improve zone lock
> scalability so here is my try.

Nice, this uses the smp_list_* functions well in spite of the limitations you
encountered with them here.

> Performance wise on 56 cores/112 threads Intel Skylake 2 sockets server
> using will-it-scale/page_fault1 process mode(higher is better):
> 
> kernel        performance      zone lock contention
> patch1         9219349         76.99%
> patch7         2461133 -73.3%  54.46%(another 34.66% on smp_list_add())
> patch8        11712766 +27.0%  68.14%
> patch9        11386980 +23.5%  67.18%

Is "zone lock contention" the percentage that readers and writers combined
spent waiting?  I'm curious to see read and write wait time broken out, since
it seems there are writers (very likely on the allocation side) spoiling the
parallelism we get with the read lock.

If the contention is from allocation, I wonder whether it's feasible to make
that path use SMP list functions.  Something like smp_list_cut_position
combined with using page clusters from [*] to cut off a chunk of list.  Many
details to keep in mind there, though, like having to unset PageBuddy in that
list chunk when other tasks can be concurrently merging pages that are part of
it.

Or maybe what's needed is a more scalable data structure than an array of
lists, since contention on the heads seems to be the limiting factor.  A simple
list that keeps the pages in most-recently-used order (except when adding to
the list tail) is good for cache warmth, but I wonder how helpful that is when
all CPUs can allocate from the front.  Having multiple places to put pages of a
given order/mt would ease the contention.

> Though lock contention reduced a lot for patch7, the performance dropped
> considerably due to severe cache bouncing on free list head among
> multiple threads doing page free at the same time, because every page free
> will need to add the page to the free list head.

Could be beneficial to take an MCS-style approach in smp_list_splice/add so
that multiple waiters aren't bouncing the same cacheline around.  This is
something I'm planning to try on lru_lock.

Daniel

[*] https://lkml.kernel.org/r/20180509085450.3524-1-aaron.lu@intel.com
