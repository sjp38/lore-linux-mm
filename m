Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5E16B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 01:07:30 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id n128so164245203ith.3
        for <linux-mm@kvack.org>; Tue, 16 Aug 2016 22:07:30 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id p202si9430057iod.63.2016.08.16.22.07.28
        for <linux-mm@kvack.org>;
        Tue, 16 Aug 2016 22:07:29 -0700 (PDT)
Date: Wed, 17 Aug 2016 14:07:43 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 00/11] THP swap: Delay splitting THP during swapping out
Message-ID: <20160817050743.GB5372@bbox>
References: <1470760673-12420-1-git-send-email-ying.huang@intel.com>
 <20160817005905.GA5372@bbox>
 <87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87inv0kv3r.fsf@yhuang-mobile.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 16, 2016 at 07:06:00PM -0700, Huang, Ying wrote:
> Hi, Kim,
> 
> Minchan Kim <minchan@kernel.org> writes:
> 
> > Hello Huang,
> >
> > On Tue, Aug 09, 2016 at 09:37:42AM -0700, Huang, Ying wrote:
> >> From: Huang Ying <ying.huang@intel.com>
> >> 
> >> This patchset is based on 8/4 head of mmotm/master.
> >> 
> >> This is the first step for Transparent Huge Page (THP) swap support.
> >> The plan is to delaying splitting THP step by step and avoid splitting
> >> THP finally during THP swapping out and swapping in.
> >
> > What does it mean "delay splitting THP on swapping-in"?
> 
> Sorry for my poor English.  We will only delay splitting the THP during
> swapping out.  The final target is to avoid splitting the THP during
> swapping out, and swap out/in the THP directly.  Thanks for pointing out
> that.  I will revise the patch description in the next version.

Thanks.

> 
> >> 
> >> The advantages of THP swap support are:
> >> 
> >> - Batch swap operations for THP to reduce lock acquiring/releasing,
> >>   including allocating/freeing swap space, adding/deleting to/from swap
> >>   cache, and writing/reading swap space, etc.
> >> 
> >> - THP swap space read/write will be 2M sequence IO.  It is particularly
> >>   helpful for swap read, which usually are 4k random IO.
> >> 
> >> - It will help memory fragmentation, especially when THP is heavily used
> >>   by the applications.  2M continuous pages will be free up after THP
> >>   swapping out.
> >
> > Could we take the benefit for normal pages as well as THP page?
> 
> This patchset benefits the THP swap only.  It has no effect for normal pages.
> 
> > I think Tim and me discussed about that a few weeks ago.
> 
> I work closely with Tim on swap optimization.  This patchset is the part
> of our swap optimization plan.
> 
> > Please search below topics.
> >
> > [1] mm: Batch page reclamation under shink_page_list
> > [2] mm: Cleanup - Reorganize the shrink_page_list code into smaller functions
> >
> > It's different with yours which focused on THP swapping while the suggestion
> > would be more general if we can do so it's worth to try it, I think.
> 
> I think the general optimization above will benefit both normal pages
> and THP at least for now.  And I think there are no hard conflict
> between those two patchsets.

If we could do general optimzation, I guess THP swap without splitting
would be more straight forward.

If we can reclaim batch a certain of pages all at once, it helps we can
do scan_swap_map(si, SWAP_HAS_CACHE, nr_pages). The nr_pages could be
greater or less than 512 pages. With that, scan_swap_map effectively
search empty swap slots from scan_map or free cluser list.
Then, needed part from your patchset is to just delay splitting of THP.

> 
> The THP swap has more opportunity to be optimized, because we can batch
> 512 operations together more easily.  For full THP swap support, unmap a
> THP could be more efficient with only one swap count operation instead
> of 512, so do many other operations, such as add/remove from swap cache
> with multi-order radix tree etc.  And it will help memory fragmentation.
> THP can be kept after swapping out/in, need not to rebuild THP via
> khugepaged.

It seems you increased cluster size to 512 and search a empty cluster
for a THP swap. With that approach, I have a concern that once clusters
will be fragmented, THP swap support doesn't take benefit at all.

Why do we need a empty cluster for swapping out 512 pages?
IOW, below case could work for the goal.

A : Allocated slot
F : Free slot

cluster A   cluster B
AAAAFFFF  -  FFFFAAAA

That's one of the reason I suggested batch reclaim work first and
support THP swap based on it. With that, scan_swap_map can be aware of nr_pages
and selects right clusters.

With the approach, justfication of THP swap support would be easier, too.
IOW, I'm not sure how only THP swap support is valuable in real workload.

Anyways, that's just my two cents.

> 
> But not all pages are huge, so normal pages swap optimization is
> necessary and good anyway.
> 
> > Anyway, I hope [1/11] should be merged regardless of the patchset because
> > I believe anyone doesn't feel comfortable with cluser_info functions. ;-)
> 
> Thanks,
> 
> Best Regards,
> Huang, Ying
> 
> [snip]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
