Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADB556B025F
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 13:25:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so241198711pfg.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 10:25:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id gc14si99223pac.142.2016.08.17.10.25.21
        for <linux-mm@kvack.org>;
        Wed, 17 Aug 2016 10:25:21 -0700 (PDT)
Message-ID: <1471454696.2888.94.camel@linux.intel.com>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Wed, 17 Aug 2016 10:24:56 -0700
In-Reply-To: <20160817050743.GB5372@bbox>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
	 <20160817005905.GA5372@bbox> <87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
	 <20160817050743.GB5372@bbox>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A
 . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2016-08-17 at 14:07 +0900, Minchan Kim wrote:
> On Tue, Aug 16, 2016 at 07:06:00PM -0700, Huang, Ying wrote:
> > 
> >A 
> > > 
> > > I think Tim and me discussed about that a few weeks ago.
> > I work closely with Tim on swap optimization.A A This patchset is the part
> > of our swap optimization plan.
> > 
> > > 
> > > Please search below topics.
> > > 
> > > [1] mm: Batch page reclamation under shink_page_list
> > > [2] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions
> > > 
> > > It's different with yours which focused on THP swapping while the suggestion
> > > would be more general if we can do so it's worth to try it, I think.
> > I think the general optimization above will benefit both normal pages
> > and THP at least for now.A A And I think there are no hard conflict
> > between those two patchsets.
> If we could do general optimzation, I guess THP swap without splitting
> would be more straight forward.
> 
> If we can reclaim batch a certain of pages all at once, it helps we can
> do scan_swap_map(si, SWAP_HAS_CACHE, nr_pages). The nr_pages could be
> greater or less than 512 pages. With that, scan_swap_map effectively
> search empty swap slots from scan_map or free cluser list.
> Then, needed part from your patchset is to just delay splitting of THP.
> 
> > 
> > 
> > The THP swap has more opportunity to be optimized, because we can batch
> > 512 operations together more easily.A A For full THP swap support, unmap a
> > THP could be more efficient with only one swap count operation instead
> > of 512, so do many other operations, such as add/remove from swap cache
> > with multi-order radix tree etc.A A And it will help memory fragmentation.
> > THP can be kept after swapping out/in, need not to rebuild THP via
> > khugepaged.
> It seems you increased cluster size to 512 and search a empty cluster
> for a THP swap. With that approach, I have a concern that once clusters
> will be fragmented, THP swap support doesn't take benefit at all.
> 
> Why do we need a empty cluster for swapping out 512 pages?
> IOW, below case could work for the goal.
> 
> A : Allocated slot
> F : Free slot
> 
> cluster AA A A cluster B
> AAAAFFFFA A -A A FFFFAAAA
> 
> That's one of the reason I suggested batch reclaim work first and
> support THP swap based on it. With that, scan_swap_map can be aware of nr_pages
> and selects right clusters.
> 
> With the approach, justfication of THP swap support would be easier, too.
> IOW, I'm not sure how only THP swap support is valuable in real workload.
> 
> Anyways, that's just my two cents.

Minchan,

Scanning for contiguous slots that span clusters may take quite a
long time under fragmentation, and may eventually fail. A In that case the addition scan
time overhead may go to waste and defeat the purpose of fast swapping of large page.

The empty cluster lookup on the other hand is very fast.
We treat the empty cluster available case as an opportunity for fast path
swap out of large page. A Otherwise, we'll revert to the current
slow path behavior of breaking into normal pages so there's no
regression, and we may get speed up. A We can be considerably faster when a lot of large
pages are used. A 


> 
> > 
> > 
> > But not all pages are huge, so normal pages swap optimization is
> > necessary and good anyway.
> > 

Yes, optimizing the normal swap pages is still an important goal
for us. A THP swap optimization is complementary component. A 

We have seen system with THP spend significant cpu cycles breaking up the
pages on swap out and then compacting the pages for THP again after
swap in. A So if we can avoid this, that will be helpful.

Thanks for your valuable comments.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
