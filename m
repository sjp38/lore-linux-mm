Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f200.google.com (mail-ig0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD426B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 14:23:55 -0400 (EDT)
Received: by mail-ig0-f200.google.com with SMTP id lp2so47266148igb.3
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 11:23:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bk3si8473310pad.27.2016.06.01.11.23.53
        for <linux-mm@kvack.org>;
        Wed, 01 Jun 2016 11:23:53 -0700 (PDT)
Message-ID: <1464805433.22178.191.camel@linux.intel.com>
Subject: Re: [PATCH] mm: Cleanup - Reorganize the shrink_page_list code into
 smaller functions
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 01 Jun 2016 11:23:53 -0700
In-Reply-To: <20160601071225.GN19976@bbox>
References: <1463779979.22178.142.camel@linux.intel.com>
	 <20160531091550.GA19976@bbox> <20160531171722.GA5763@linux.intel.com>
	 <20160601071225.GN19976@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, "Kirill
 A.Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Aaron Lu <aaron.lu@intel.com>, Huang Ying <ying.huang@intel.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Wed, 2016-06-01 at 16:12 +0900, Minchan Kim wrote:
>A 
> Hi Tim,
> 
> To me, this reorganization is too limited and not good for me,
> frankly speaking. It works for only your goal which allocate batch
> swap slot, I guess. :)
> 
> My goal is to make them work with batch page_check_references,
> batch try_to_unmap and batch __remove_mapping where we can avoid frequent
> mapping->lock(e.g., anon_vma or i_mmap_lock with hoping such batch locking
> help system performance) if batch pages has same inode or anon.

This is also my goal to group pages that are either under the same
mapping or are anonymous pages together so we can reduce the i_mmap_lock
acquisition. A One logic that's yet to be implemented in your patch
is the grouping of similar pages together so we only need one i_mmap_lock
acquisition. A Doing this efficiently is non-trivial. A 

I punted the problem somewhat in my patch and elected to defer the processing
of the anonymous pages at the end so they are naturally grouped without
having to traverse the page_list more than once. A So I'm batching the
anonymous pages but the file mapped pages were not grouped.

In your implementation, you may need to traverse the page_list in two pass, where the
first one is to categorize the pages and grouping them and the second one
is the actual processing. A Then the lock batching can be implemented
for the pages. A Otherwise the locking is still done page by page in
your patch, and can only be batched if the next page on page_list happens
to have the same mapping. A Your idea of using a spl_batch_pages is pretty
neat. A It may need some enhancement so it is known whether some locks
are already held for lock batching purpose.


Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
