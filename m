Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 539816B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:43:31 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u203so178896326itc.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:43:31 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ol5si21777360pab.73.2016.06.07.13.43.30
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 13:43:30 -0700 (PDT)
Message-ID: <1465332209.22178.236.camel@linux.intel.com>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 07 Jun 2016 13:43:29 -0700
In-Reply-To: <20160607082158.GA23435@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
	 <20160531091550.GA19976@bbox> <20160531171722.GA5763@linux.intel.com>
	 <20160601071225.GN19976@bbox> <1464805433.22178.191.camel@linux.intel.com>
	 <20160607082158.GA23435@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill
 A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, 2016-06-07 at 17:21 +0900, Minchan Kim wrote:
> On Wed, Jun 01, 2016 at 11:23:53AM -0700, Tim Chen wrote:
> > 
> > On Wed, 2016-06-01 at 16:12 +0900, Minchan Kim wrote:
> > > 
> > > A 
> > > Hi Tim,
> > > 
> > > To me, this reorganization is too limited and not good for me,
> > > frankly speaking. It works for only your goal which allocate batch
> > > swap slot, I guess. :)
> > > 
> > > My goal is to make them work with batch page_check_references,
> > > batch try_to_unmap and batch __remove_mapping where we can avoid frequent
> > > mapping->lock(e.g., anon_vma or i_mmap_lock with hoping such batch locking
> > > help system performance) if batch pages has same inode or anon.
> > This is also my goal to group pages that are either under the same
> > mapping or are anonymous pages together so we can reduce the i_mmap_lock
> > acquisition. A One logic that's yet to be implemented in your patch
> > is the grouping of similar pages together so we only need one i_mmap_lock
> > acquisition. A Doing this efficiently is non-trivial. A 
> Hmm, my assumption is based on same inode pages are likely to order
> in LRU so no need to group them. If successive page in page_list comes
> from different inode, we can drop the lock and get new lock from new
> inode. That sounds strange?
> 

Sounds reasonable. But your process function passed to spl_batch_pages may
need to be modified to know if the radix tree lock or swap info lock
has already been held, as it deals with only 1 page. A It may be
tricky as the lock may get acquired and dropped more than once in process
function.

Are you planning to update the patch with lock batching?

Thanks.

Tim

> > 
> > 
> > I punted the problem somewhat in my patch and elected to defer the processing
> > of the anonymous pages at the end so they are naturally grouped without
> > having to traverse the page_list more than once. A So I'm batching the
> > anonymous pages but the file mapped pages were not grouped.
> > 
> > In your implementation, you may need to traverse the page_list in two pass, where the
> > first one is to categorize the pages and grouping them and the second one
> > is the actual processing. A Then the lock batching can be implemented
> > for the pages. A Otherwise the locking is still done page by page in
> > your patch, and can only be batched if the next page on page_list happens
> > to have the same mapping. A Your idea of using a spl_batch_pages is pretty
> Yes. as I said above, I expect pages in LRU would be likely to order per
> inode normally. If it's not, yeb, we need grouping but such overhead would
> mitigate the benefit of lock batch as SWAP_CLUSTER_MAX get bigger.
> 
> > 
> > neat. A It may need some enhancement so it is known whether some locks
> > are already held for lock batching purpose.
> > 
> > 
> > Thanks.
> > 
> > Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
