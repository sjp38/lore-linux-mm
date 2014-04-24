Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3866B0038
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 11:40:11 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id b57so1997760eek.26
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 08:40:10 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id s46si8836592eeg.345.2014.04.24.08.40.09
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 08:40:10 -0700 (PDT)
Date: Thu, 24 Apr 2014 16:39:20 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: Throttle shrinkers harder
Message-ID: <20140424153920.GM31221@nuc-i3427.alporthouse.com>
References: <1397113506-9177-1-git-send-email-chris@chris-wilson.co.uk>
 <20140418121416.c022eca055da1b6d81b2cf1b@linux-foundation.org>
 <20140422193041.GD10722@phenom.ffwll.local>
 <53582D3C.1010509@intel.com>
 <20140424055836.GB31221@nuc-i3427.alporthouse.com>
 <53592C16.8000906@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53592C16.8000906@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On Thu, Apr 24, 2014 at 08:21:58AM -0700, Dave Hansen wrote:
> On 04/23/2014 10:58 PM, Chris Wilson wrote:
> > [ 4756.750938] Node 0 DMA free:14664kB min:32kB low:40kB high:48kB active_anon:0kB inactive_anon:1024kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:412kB slab_reclaimable:80kB slab_unreclaimable:24kB kernel_stack:0kB pagetables:48kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:76 all_unreclaimable? yes
> > [ 4756.751103] lowmem_reserve[]: 0 3337 3660 3660
> > [ 4756.751133] Node 0 DMA32 free:7208kB min:7044kB low:8804kB high:10564kB active_anon:36172kB inactive_anon:3351408kB active_file:92kB inactive_file:72kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3518336kB managed:3440548kB mlocked:0kB dirty:0kB writeback:0kB mapped:12kB shmem:1661420kB slab_reclaimable:17624kB slab_unreclaimable:14400kB kernel_stack:696kB pagetables:4324kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:327 all_unreclaimable? yes
> > [ 4756.751341] lowmem_reserve[]: 0 0 322 322
> > [ 4756.752889] Node 0 Normal free:328kB min:680kB low:848kB high:1020kB active_anon:61372kB inactive_anon:250740kB active_file:0kB inactive_file:4kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:393216kB managed:330360kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:227740kB slab_reclaimable:3032kB slab_unreclaimable:5128kB kernel_stack:400kB pagetables:624kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:6 all_unreclaimable? yes
> > [ 4756.757635] lowmem_reserve[]: 0 0 0 0
> > [ 4756.759294] Node 0 DMA: 2*4kB (UM) 2*8kB (UM) 3*16kB (UEM) 4*32kB (UEM) 2*64kB (UM) 4*128kB (UEM) 2*256kB (EM) 2*512kB (EM) 2*1024kB (UM) 3*2048kB (EMR) 1*4096kB (M) = 14664kB
> > [ 4756.762776] Node 0 DMA32: 424*4kB (UEM) 171*8kB (UEM) 21*16kB (UEM) 1*32kB (R) 1*64kB (R) 1*128kB (R) 0*256kB 1*512kB (R) 1*1024kB (R) 1*2048kB (R) 0*4096kB = 7208kB
> > [ 4756.766284] Node 0 Normal: 26*4kB (UER) 18*8kB (UER) 3*16kB (E) 1*32kB (R) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 328kB
> > [ 4756.768198] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
> > [ 4756.770026] 916139 total pagecache pages
> > [ 4756.771857] 443703 pages in swap cache
> > [ 4756.773695] Swap cache stats: add 15363874, delete 14920171, find 6533699/7512215
> > [ 4756.775592] Free swap  = 0kB
> > [ 4756.777505] Total swap = 2047996kB
> 
> OK, so here's my theory as to what happens:
> 
> 1. The graphics pages got put on the LRU
> 2. System is low on memory, they get on (and *STAY* on) the inactive
>    LRU.
> 3. VM adds graphics pages to the swap cache, and writes them out, and
>    we see the writeout from the vmstat, and lots of adds/removes from
>    the swap cache.
> 4. But, despite all the swap writeout, we don't get helped by seeing
>    much memory get freed.  Why?
> 
> I _suspect_ that the graphics drivers here are holding a reference to
> the page.  During reclaim, we're mostly concerned with the pages being
> mapped.  If we manage to get them unmapped, we'll go ahead and swap
> them, which I _think_ is what we're seeing.  But, when it comes time to
> _actually_ free them, that last reference on the page keeps them from
> being freed.
> 
> Is it possible that there's still a get_page() reference that's holding
> those pages in place from the graphics code?

Not from i915.ko. The last resort of our shrinker is to drop all page
refs held by the GPU, which is invoked if we are asked to free memory
and we have no inactive objects left.

If we could get a callback for the oom report, I could dump some details
about what the GPU is holding onto. That seems like a useful extension to
add to the shrinkers.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
