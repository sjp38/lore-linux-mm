Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC056B0260
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 20:43:49 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a6so7255407pff.17
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 17:43:49 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w1si4505250pgq.816.2017.12.07.17.43.47
        for <linux-mm@kvack.org>;
        Thu, 07 Dec 2017 17:43:48 -0800 (PST)
Date: Fri, 8 Dec 2017 10:43:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-ID: <20171208014346.GA8915@bbox>
References: <20171207011426.1633-1-ying.huang@intel.com>
 <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu, Dec 07, 2017 at 04:29:37PM -0800, Andrew Morton wrote:
> On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:
> 
> > When the swapin is performed, after getting the swap entry information
> > from the page table, the PTL (page table lock) will be released, then
> > system will go to swap in the swap entry, without any lock held to
> > prevent the swap device from being swapoff.  This may cause the race
> > like below,
> > 
> > CPU 1				CPU 2
> > -----				-----
> > 				do_swap_page
> > 				  swapin_readahead
> > 				    __read_swap_cache_async
> > swapoff				      swapcache_prepare
> >   p->swap_map = NULL		        __swap_duplicate
> > 					  p->swap_map[?] /* !!! NULL pointer access */
> > 
> > Because swap off is usually done when system shutdown only, the race
> > may not hit many people in practice.  But it is still a race need to
> > be fixed.
> 
> swapoff is so rare that it's hard to get motivated about any fix which
> adds overhead to the regular codepaths.

That was my concern, too when I see this patch.

> 
> Is there something we can do to ensure that all the overhead of this
> fix is placed into the swapoff side?  stop_machine() may be a bit
> brutal, but a surprising amount of code uses it.  Any other ideas?

How about this?

I think It's same approach with old where we uses si->lock everywhere
instead of more fine-grained cluster lock.

The reason I repeated to reset p->max to zero in the loop is to avoid
using lockdep annotation(maybe, spin_lock_nested(something) to prevent
false positive.

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 42fe5653814a..9ce007a42bbc 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2644,6 +2644,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 	swap_file = p->swap_file;
 	old_block_size = p->old_block_size;
 	p->swap_file = NULL;
+
+	if (p->flags & SWP_SOLIDSTATE) {
+		unsigned long ci, nr_cluster;
+
+		nr_cluster = DIV_ROUND_UP(p->max, SWAPFILE_CLUSTER);
+		for (ci = 0; ci < nr_cluster; ci++) {
+			struct swap_cluster_info *sci;
+
+			sci = lock_cluster(p, ci * SWAPFILE_CLUSTER);
+			p->max = 0;
+			unlock_cluster(sci);
+		}
+	}
 	p->max = 0;
 	swap_map = p->swap_map;
 	p->swap_map = NULL;
@@ -3369,10 +3382,10 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
 		goto bad_file;
 	p = swap_info[type];
 	offset = swp_offset(entry);
-	if (unlikely(offset >= p->max))
-		goto out;
 
 	ci = lock_cluster_or_swap_info(p, offset);
+	if (unlikely(offset >= p->max))
+		goto unlock_out;
 
 	count = p->swap_map[offset];
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
