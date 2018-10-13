Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C9096B0005
	for <linux-mm@kvack.org>; Sat, 13 Oct 2018 19:01:30 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id b7-v6so11464307pgt.10
        for <linux-mm@kvack.org>; Sat, 13 Oct 2018 16:01:30 -0700 (PDT)
Received: from ipmail01.adl6.internode.on.net (ipmail01.adl6.internode.on.net. [150.101.137.136])
        by mx.google.com with ESMTP id 1-v6si5887195plk.405.2018.10.13.16.01.27
        for <linux-mm@kvack.org>;
        Sat, 13 Oct 2018 16:01:28 -0700 (PDT)
Date: Sun, 14 Oct 2018 10:01:24 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 4/6] mm: introduce page->dma_pinned_flags, _count
Message-ID: <20181013230124.GB18822@dastard>
References: <20181012060014.10242-1-jhubbard@nvidia.com>
 <20181012060014.10242-5-jhubbard@nvidia.com>
 <20181013035516.GA18822@dastard>
 <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c2e3b54-0b1d-6726-a508-804ef8620cfd@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On Sat, Oct 13, 2018 at 12:34:12AM -0700, John Hubbard wrote:
> On 10/12/18 8:55 PM, Dave Chinner wrote:
> > On Thu, Oct 11, 2018 at 11:00:12PM -0700, john.hubbard@gmail.com wrote:
> >> From: John Hubbard <jhubbard@nvidia.com>
> [...]
> >> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> >> index 5ed8f6292a53..017ab82e36ca 100644
> >> --- a/include/linux/mm_types.h
> >> +++ b/include/linux/mm_types.h
> >> @@ -78,12 +78,22 @@ struct page {
> >>  	 */
> >>  	union {
> >>  		struct {	/* Page cache and anonymous pages */
> >> -			/**
> >> -			 * @lru: Pageout list, eg. active_list protected by
> >> -			 * zone_lru_lock.  Sometimes used as a generic list
> >> -			 * by the page owner.
> >> -			 */
> >> -			struct list_head lru;
> >> +			union {
> >> +				/**
> >> +				 * @lru: Pageout list, eg. active_list protected
> >> +				 * by zone_lru_lock.  Sometimes used as a
> >> +				 * generic list by the page owner.
> >> +				 */
> >> +				struct list_head lru;
> >> +				/* Used by get_user_pages*(). Pages may not be
> >> +				 * on an LRU while these dma_pinned_* fields
> >> +				 * are in use.
> >> +				 */
> >> +				struct {
> >> +					unsigned long dma_pinned_flags;
> >> +					atomic_t      dma_pinned_count;
> >> +				};
> >> +			};
> > 
> > Isn't this broken for mapped file-backed pages? i.e. they may be
> > passed as the user buffer to read/write direct IO and so the pages
> > passed to gup will be on the active/inactive LRUs. hence I can't see
> > how you can have dual use of the LRU list head like this....
> > 
> > What am I missing here?
> 
> Hi Dave,
> 
> In patch 6/6, pin_page_for_dma(), which is called at the end of get_user_pages(),
> unceremoniously rips the pages out of the LRU, as a prerequisite to using
> either of the page->dma_pinned_* fields. 

How is that safe? If you've ripped the page out of the LRU, it's no
longer being tracked by the page cache aging and reclaim algorithms.
Patch 6 doesn't appear to put these pages back in the LRU, either,
so it looks to me like this just dumps them on the ground after the
gup reference is dropped.  How do we reclaim these page cache pages
when there is memory pressure if they aren't in the LRU?

> The idea is that LRU is not especially useful for this situation anyway,
> so we'll just make it one or the other: either a page is dma-pinned, and
> just hanging out doing RDMA most likely (and LRU is less meaningful during that
> time), or it's possibly on an LRU list.

gup isn't just used for RDMA. It's used by direct IO in far, far
more situations and machines than RDMA is. Please explain why
ripping pages out of the LRU and not putting them back is safe, has
no side effects, doesn't adversely impact page cache reclaim, etc.
Indeed, I'd love to see a description of all the page references and
where they come and go so we know the changes aren't just leaking
these pages until the filesystem invalidates them at unmount.

Maybe I'm not seeing why this is safe yet, but seeing as you haven't
explained why it is safe then, at minimum, the patch descriptions
are incomplete.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
