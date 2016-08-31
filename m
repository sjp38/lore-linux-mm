Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id E5EDC6B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:30:33 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id g124so121143031qkd.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:30:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d3si923278ywf.349.2016.08.31.14.30.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:30:33 -0700 (PDT)
Date: Wed, 31 Aug 2016 14:30:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2] mm: Don't use radix tree writeback tags for pages
 in swap cache
Message-Id: <20160831143031.4e5a180f969ec6997637a96f@linux-foundation.org>
In-Reply-To: <20160831091459.GY8119@techsingularity.net>
References: <1472578089-5560-1-git-send-email-ying.huang@intel.com>
	<20160831091459.GY8119@techsingularity.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Wu Fengguang <fengguang.wu@intel.com>

On Wed, 31 Aug 2016 10:14:59 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> >    2506952 __  2%     +28.1%    3212076 __  7%  vm-scalability.throughput
> >    1207402 __  7%     +22.3%    1476578 __  6%  vmstat.swap.so
> >      10.86 __ 12%     -23.4%       8.31 __ 16%  perf-profile.cycles-pp._raw_spin_lock_irq.__add_to_swap_cache.add_to_swap_cache.add_to_swap.shrink_page_list
> >      10.82 __ 13%     -33.1%       7.24 __ 14%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_zone_memcg
> >      10.36 __ 11%    -100.0%       0.00 __ -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.__test_set_page_writeback.bdev_write_page.__swap_writepage.swap_writepage
> >      10.52 __ 12%    -100.0%       0.00 __ -1%  perf-profile.cycles-pp._raw_spin_lock_irqsave.test_clear_page_writeback.end_page_writeback.page_endio.pmem_rw_page
> > 
> 
> I didn't see anything wrong with the patch but it's worth highlighting
> that this hunk means we are now out of GFP bits.

Well ugh.  What are we to do about that?

Sigh.  This?


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm: check that we haven't used more than 32 bits in address_space.flags

After "mm: don't use radix tree writeback tags for pages in swap cache",
all the flags are now used up on 32-bit builds.

Add a build-time assertion to prevent 64-bit developers from accidentally
breaking things.

Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: "Huang, Ying" <ying.huang@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/pagemap.h |    2 ++
 init/main.c             |    4 ++++
 2 files changed, 6 insertions(+)

diff -puN include/linux/pagemap.h~mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags include/linux/pagemap.h
--- a/include/linux/pagemap.h~mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags
+++ a/include/linux/pagemap.h
@@ -27,6 +27,8 @@ enum mapping_flags {
 	AS_EXITING	= __GFP_BITS_SHIFT + 4, /* final truncate in progress */
 	/* writeback related tags are not used */
 	AS_NO_WRITEBACK_TAGS = __GFP_BITS_SHIFT + 5,
+
+	AS_LAST_FLAG,
 };
 
 static inline void mapping_set_error(struct address_space *mapping, int error)
diff -puN init/main.c~mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags init/main.c
--- a/init/main.c~mm-check-that-we-havent-used-more-than-32-bits-in-address_spaceflags
+++ a/init/main.c
@@ -59,6 +59,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/device.h>
 #include <linux/kthread.h>
+#include <linux/pagemap.h>
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/idr.h>
@@ -463,6 +464,9 @@ void __init __weak thread_stack_cache_in
  */
 static void __init mm_init(void)
 {
+	/* Does address_space.flags still fit into a 32-bit ulong? */
+	BUILD_BUG_ON(AS_LAST_FLAG > 32);
+
 	/*
 	 * page_ext requires contiguous pages,
 	 * bigger than MAX_ORDER unless SPARSEMEM.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
