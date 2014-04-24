Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id D12696B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:26:55 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id md12so2076619pbc.35
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:26:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id nj10si2884365pbc.476.2014.04.24.08.26.54
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 08:26:54 -0700 (PDT)
Message-ID: <53592C16.8000906@intel.com>
Date: Thu, 24 Apr 2014 08:21:58 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Throttle shrinkers harder
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk> <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org> <20140422193041.GD10722@phenom.ffwll.local> <53582D3C.1010509@intel.com> <20140424055836.GB31221@nuc-i3427.alporthouse.com>
In-Reply-To: <20140424055836.GB31221@nuc-i3427.alporthouse.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On 04/23/2014 10:58 PM, Chris Wilson wrote:
> [ 4756.750938] Node 0 DMA free:14664kB min:32kB low:40kB high:48kB active_anon:0kB inactive_anon:1024kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:412kB slab_reclaimable:80kB slab_unreclaimable:24kB kernel_stack:0kB pagetables:48kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:76 all_unreclaimable? yes
> [ 4756.751103] lowmem_reserve[]: 0 3337 3660 3660
> [ 4756.751133] Node 0 DMA32 free:7208kB min:7044kB low:8804kB high:10564kB active_anon:36172kB inactive_anon:3351408kB active_file:92kB inactive_file:72kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3518336kB managed:3440548kB mlocked:0kB dirty:0kB writeback:0kB mapped:12kB shmem:1661420kB slab_reclaimable:17624kB slab_unreclaimable:14400kB kernel_stack:696kB pagetables:4324kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:327 all_unreclaimable? yes
> [ 4756.751341] lowmem_reserve[]: 0 0 322 322
> [ 4756.752889] Node 0 Normal free:328kB min:680kB low:848kB high:1020kB active_anon:61372kB inactive_anon:250740kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:393216kB managed:330360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:227740kB slab_reclaimable:3032kB slab_unreclaimable:5128kB kernel_stack:400kB pagetables:624kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:6 all_unreclaimable? yes
> [ 4756.757635] lowmem_reserve[]: 0 0 0 0
> [ 4756.759294] Node 0 DMA: 2*4kB (UM) 2*8kB (UM) 3*16kB (UEM) 4*32kB (UEM) 2*64kB (UM) 4*128kB (UEM) 2*256kB (EM) 2*512kB (EM) 2*1024kB (UM) 3*2048kB (EMR) 1*4096kB (M) = 14664kB
> [ 4756.762776] Node 0 DMA32: 424*4kB (UEM) 171*8kB (UEM) 21*16kB (UEM) 1*32kB (R) 1*64kB (R) 1*128kB (R) 0*256kB 1*512kB (R) 1*1024kB (R) 1*2048kB (R) 0*4096kB = 7208kB
> [ 4756.766284] Node 0 Normal: 26*4kB (UER) 18*8kB (UER) 3*16kB (E) 1*32kB (R) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 328kB
> [ 4756.768198] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> [ 4756.770026] 916139 total pagecache pages
> [ 4756.771857] 443703 pages in swap cache
> [ 4756.773695] Swap cache stats: add 15363874, delete 14920171, find 6533699/7512215
> [ 4756.775592] Free swap  = 0kB
> [ 4756.777505] Total swap = 2047996kB

OK, so here's my theory as to what happens:

1. The graphics pages got put on the LRU
2. System is low on memory, they get on (and *STAY* on) the inactive
   LRU.
3. VM adds graphics pages to the swap cache, and writes them out, and
   we see the writeout from the vmstat, and lots of adds/removes from
   the swap cache.
4. But, despite all the swap writeout, we don't get helped by seeing
   much memory get freed.  Why?

I _suspect_ that the graphics drivers here are holding a reference to
the page.  During reclaim, we're mostly concerned with the pages being
mapped.  If we manage to get them unmapped, we'll go ahead and swap
them, which I _think_ is what we're seeing.  But, when it comes time to
_actually_ free them, that last reference on the page keeps them from
being freed.

Is it possible that there's still a get_page() reference that's holding
those pages in place from the graphics code?

>> Also, the vmstat output from the bug:
>>
>>> https://bugs.freedesktop.org/show_bug.cgi?id=72742
>>
>> shows there being an *AWFUL* lot of swap I/O going on here.  From the
>> looks of it, we stuck ~2GB in swap and evicted another 1.5GB of page
>> cache (although I guess that could be double-counting tmpfs getting
>> swapped out too).  Hmmm, was this one of the cases where you actually
>> ran _out_ of swap?
> 
> Yes. This bug is a little odd because they always run out of swap. We
> have another category of bug (which appears to be fixed, touch wood)
> where we trigger oom without even touching swap. The test case is
> designed to only just swap (use at most 1/4 of the available swap space)
> and checks that its working set should fit into available memory + swap.
> However, when QA run the test, their systems run completely out of
> virtual memory. There is a discrepancy on their machines where
> anon_inactive is reported as being 2x shmem, but we only expect
> anon_inactive to be our own shmem allocations. I don't know how to track
> what else is using anon_inactive. Suggestions?

Let's tackle one bug at a time.  They might be the same thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
