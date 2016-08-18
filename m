Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9408882F5F
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 04:39:36 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so25218821pfd.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 01:39:36 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a189si1456397pfa.80.2016.08.18.01.39.34
        for <linux-mm@kvack.org>;
        Thu, 18 Aug 2016 01:39:35 -0700 (PDT)
Date: Thu, 18 Aug 2016 17:39:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
Message-ID: <20160818083955.GA12296@bbox>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
 <20160817005905.GA5372@bbox>
 <87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
 <20160817050743.GB5372@bbox>
 <1471454696.2888.94.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1471454696.2888.94.camel@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tim,

On Wed, Aug 17, 2016 at 10:24:56AM -0700, Tim Chen wrote:
> On Wed, 2016-08-17 at 14:07 +0900, Minchan Kim wrote:
> > On Tue, Aug 16, 2016 at 07:06:00PM -0700, Huang, Ying wrote:
> > > 
> > > 
> > > > 
> > > > I think Tim and me discussed about that a few weeks ago.
> > > I work closely with Tim on swap optimization.  This patchset is the part
> > > of our swap optimization plan.
> > > 
> > > > 
> > > > Please search below topics.
> > > > 
> > > > [1] mm: Batch page reclamation under shink_page_list
> > > > [2] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions
> > > > 
> > > > It's different with yours which focused on THP swapping while the suggestion
> > > > would be more general if we can do so it's worth to try it, I think.
> > > I think the general optimization above will benefit both normal pages
> > > and THP at least for now.  And I think there are no hard conflict
> > > between those two patchsets.
> > If we could do general optimzation, I guess THP swap without splitting
> > would be more straight forward.
> > 
> > If we can reclaim batch a certain of pages all at once, it helps we can
> > do scan_swap_map(si, SWAP_HAS_CACHE, nr_pages). The nr_pages could be
> > greater or less than 512 pages. With that, scan_swap_map effectively
> > search empty swap slots from scan_map or free cluser list.
> > Then, needed part from your patchset is to just delay splitting of THP.
> > 
> > > 
> > > 
> > > The THP swap has more opportunity to be optimized, because we can batch
> > > 512 operations together more easily.  For full THP swap support, unmap a
> > > THP could be more efficient with only one swap count operation instead
> > > of 512, so do many other operations, such as add/remove from swap cache
> > > with multi-order radix tree etc.  And it will help memory fragmentation.
> > > THP can be kept after swapping out/in, need not to rebuild THP via
> > > khugepaged.
> > It seems you increased cluster size to 512 and search a empty cluster
> > for a THP swap. With that approach, I have a concern that once clusters
> > will be fragmented, THP swap support doesn't take benefit at all.
> > 
> > Why do we need a empty cluster for swapping out 512 pages?
> > IOW, below case could work for the goal.
> > 
> > A : Allocated slot
> > F : Free slot
> > 
> > cluster A   cluster B
> > AAAAFFFF  -  FFFFAAAA
> > 
> > That's one of the reason I suggested batch reclaim work first and
> > support THP swap based on it. With that, scan_swap_map can be aware of nr_pages
> > and selects right clusters.
> > 
> > With the approach, justfication of THP swap support would be easier, too.
> > IOW, I'm not sure how only THP swap support is valuable in real workload.
> > 
> > Anyways, that's just my two cents.
> 
> Minchan,
> 
> Scanning for contiguous slots that span clusters may take quite a
> long time under fragmentation, and may eventually fail.  In that case the addition scan
> time overhead may go to waste and defeat the purpose of fast swapping of large page.
> 
> The empty cluster lookup on the other hand is very fast.
> We treat the empty cluster available case as an opportunity for fast path
> swap out of large page.  Otherwise, we'll revert to the current
> slow path behavior of breaking into normal pages so there's no
> regression, and we may get speed up.  We can be considerably faster when a lot of large
> pages are used.  

I didn't mean we should search scan_swap_map firstly without peeking
free cluster but what I wanted was we might abstract it into
scan_swap_map.

For example, if nr_pages is greather than the size of cluster, we can
get empty cluster first and nr_pages - sizeof(cluster) for other free
cluster or scanning of current CPU per-cpu cluster. If we cannot find
used slot during scanning, we can bail out simply. Then, although we
fail to get all* contiguous slots, we get a certain of contiguous slots
so it would be benefit for seq write and lock batching point of view
at the cost of a little scanning. And it's not specific to THP algorighm.

My point is that once we optimize normal page batch for swap, THP
swap support would be more straight forward. But I should admit I didn't
look into code in detail so it might have clear hurdle to implement it
so I will rely on you guys's decision whether which one is more urgent/
benefit/making good code quality for the goal.

Thanks.

> 
> 
> > 
> > > 
> > > 
> > > But not all pages are huge, so normal pages swap optimization is
> > > necessary and good anyway.
> > > 
> 
> Yes, optimizing the normal swap pages is still an important goal
> for us.  THP swap optimization is complementary component.  
> 
> We have seen system with THP spend significant cpu cycles breaking up the
> pages on swap out and then compacting the pages for THP again after
> swap in.  So if we can avoid this, that will be helpful.
> 
> Thanks for your valuable comments.

Thanks for good works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
