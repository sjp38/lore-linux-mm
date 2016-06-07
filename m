Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0230F6B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 04:20:57 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id 2so82070681igy.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 01:20:56 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l194si16917786itb.15.2016.06.07.01.20.55
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 01:20:56 -0700 (PDT)
Date: Tue, 7 Jun 2016 17:21:58 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
Message-ID: <20160607082158.GA23435@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
 <20160531091550.GA19976@bbox>
 <20160531171722.GA5763@linux.intel.com>
 <20160601071225.GN19976@bbox>
 <1464805433.22178.191.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1464805433.22178.191.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, Jun 01, 2016 at 11:23:53AM -0700, Tim Chen wrote:
> On Wed, 2016-06-01 at 16:12 +0900, Minchan Kim wrote:
> > 
> > Hi Tim,
> > 
> > To me, this reorganization is too limited and not good for me,
> > frankly speaking. It works for only your goal which allocate batch
> > swap slot, I guess. :)
> > 
> > My goal is to make them work with batch page_check_references,
> > batch try_to_unmap and batch __remove_mapping where we can avoid frequent
> > mapping->lock(e.g., anon_vma or i_mmap_lock with hoping such batch locking
> > help system performance) if batch pages has same inode or anon.
> 
> This is also my goal to group pages that are either under the same
> mapping or are anonymous pages together so we can reduce the i_mmap_lock
> acquisition.  One logic that's yet to be implemented in your patch
> is the grouping of similar pages together so we only need one i_mmap_lock
> acquisition.  Doing this efficiently is non-trivial.  

Hmm, my assumption is based on same inode pages are likely to order
in LRU so no need to group them. If successive page in page_list comes
from different inode, we can drop the lock and get new lock from new
inode. That sounds strange?

> 
> I punted the problem somewhat in my patch and elected to defer the processing
> of the anonymous pages at the end so they are naturally grouped without
> having to traverse the page_list more than once.  So I'm batching the
> anonymous pages but the file mapped pages were not grouped.
> 
> In your implementation, you may need to traverse the page_list in two pass, where the
> first one is to categorize the pages and grouping them and the second one
> is the actual processing.  Then the lock batching can be implemented
> for the pages.  Otherwise the locking is still done page by page in
> your patch, and can only be batched if the next page on page_list happens
> to have the same mapping.  Your idea of using a spl_batch_pages is pretty

Yes. as I said above, I expect pages in LRU would be likely to order per
inode normally. If it's not, yeb, we need grouping but such overhead would
mitigate the benefit of lock batch as SWAP_CLUSTER_MAX get bigger.

> neat.  It may need some enhancement so it is known whether some locks
> are already held for lock batching purpose.
> 
> 
> Thanks.
> 
> Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
