Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 389296B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:39:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u81so41114926wmu.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:39:16 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id di2si553067wjc.106.2016.08.31.08.39.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Aug 2016 08:39:14 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id F0F1598A37
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 15:39:11 +0000 (UTC)
Date: Wed, 31 Aug 2016 16:39:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages in
 swap cache
Message-ID: <20160831153908.GA8119@techsingularity.net>
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
 <20160831091459.GY8119@techsingularity.net>
 <87oa49m0hn.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <87oa49m0hn.fsf@yhuang-mobile.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Wed, Aug 31, 2016 at 08:17:24AM -0700, Huang, Ying wrote:
> Mel Gorman <mgorman@techsingularity.net> writes:
> 
> > On Tue, Aug 30, 2016 at 10:28:09AM -0700, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> File pages use a set of radix tree tags (DIRTY, TOWRITE, WRITEBACK,
> >> etc.) to accelerate finding the pages with a specific tag in the radix
> >> tree during inode writeback.  But for anonymous pages in the swap
> >> cache, there is no inode writeback.  So there is no need to find the
> >> pages with some writeback tags in the radix tree.  It is not necessary
> >> to touch radix tree writeback tags for pages in the swap cache.
> >> 
> >> Per Rik van Riel's suggestion, a new flag AS_NO_WRITEBACK_TAGS is
> >> introduced for address spaces which don't need to update the writeback
> >> tags.  The flag is set for swap caches.  It may be used for DAX file
> >> systems, etc.
> >> 
> >> With this patch, the swap out bandwidth improved 22.3% (from ~1.2GB/s to
> >> ~ 1.48GBps) in the vm-scalability swap-w-seq test case with 8 processes.
> >> The test is done on a Xeon E5 v3 system.  The swap device used is a RAM
> >> simulated PMEM (persistent memory) device.  The improvement comes from
> >> the reduced contention on the swap cache radix tree lock.  To test
> >> sequential swapping out, the test case uses 8 processes, which
> >> sequentially allocate and write to the anonymous pages until RAM and
> >> part of the swap device is used up.
> >> 
> >> Details of comparison is as follow,
> >> 
> >> base             base+patch
> >> ---------------- --------------------------
> >>          %stddev     %change         %stddev
> >>              \          |                \
> >>    2506952 +-  2%     +28.1%    3212076 +-  7%  vm-scalability.throughput
> >>    1207402 +-  7%     +22.3%    1476578 +-  6%  vmstat.swap.so
> >>      10.86 +- 12%     -23.4%       8.31 +- 16%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
> >>      10.82 +- 13%     -33.1%       7.24 +- 14%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_zone_memcg
> >>      10.36 +- 11%    -100.0%       0.00 +- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page.__swap_writepage.swap_writepage
> >>      10.52 +- 12%    -100.0%       0.00 +- -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writeback.page_endio.pmem_rw_page
> >> 
> >
> > I didn't see anything wrong with the patch but it's worth highlighting
> > that this hunk means we are now out of GFP bits.
> 
> Sorry, I don't know whether I understand your words.  It is something
> about,
> 
> __GFP_BITS_SHIFT == 26
> 
> So remainning bits in mapping_flags is 6.  And now the latest bit is
> used for the flag introduced in the patch?
> 

__GFP_BITS_SHIFT + 5 (AS_NO_WRITEBACK_TAGS) = 31

mapping->flags is a combination of AS and GFP flags so increasing
__GFP_BITS_SHIFT overflows mapping->flags on 32-bit as gfp_t is an
unsigned int.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
