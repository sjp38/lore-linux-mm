Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0CCAB9003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 02:11:36 -0400 (EDT)
Received: by pacan13 with SMTP id an13so9083867pac.1
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 23:11:35 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ns8si17953341pdb.234.2015.07.23.23.11.33
        for <linux-mm@kvack.org>;
        Thu, 23 Jul 2015 23:11:35 -0700 (PDT)
Date: Fri, 24 Jul 2015 15:16:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
Message-ID: <20150724061603.GB11135@js1304-P5Q-DELUXE>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz>
 <1435826795-13777-2-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com>
 <55AE0AFE.8070200@suse.cz>
 <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz>
 <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com>
 <55B0B175.9090306@suse.cz>
 <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

On Thu, Jul 23, 2015 at 02:21:29PM -0700, David Rientjes wrote:
> On Thu, 23 Jul 2015, Vlastimil Babka wrote:
> 
> > > When a khugepaged allocation fails for a node, it could easily kick off 
> > > background compaction on that node and revisit the range later, very 
> > > similar to how we can kick off background compaction in the page allocator 
> > > when async or sync_light compaction fails.
> > 
> > The revisiting sounds rather complicated. Page allocator doesn't have to do that.
> > 
> 
> I'm referring to khugepaged having a hugepage allocation fail, the page 
> allocator kicking off background compaction, and khugepaged rescanning the 
> same memory for which the allocation failed later.
> 
> > > The distinction I'm trying to draw is between "periodic" and "background" 
> > > compaction.  I think there're usecases for both and we shouldn't be 
> > > limiting ourselves to one or the other.
> > 
> > OK, I understand you think we can have both, and the periodic one would be in
> > khugepaged. My main concern is that if we do the periodic one in khugepaged,
> > people might oppose adding yet another one as kcompactd. I hope we agree that
> > khugepaged is not suitable for all the use cases of the background one.
> > 
> 
> Yes, absolutely.  I agree that we need the ability to do background 
> compaction without requiring CONFIG_TRANSPARENT_HUGEPAGE.
> 
> > My secondary concern/opinion is that I would hope that the background compaction
> > would be good enough to remove the need for the periodic one. So I would try the
> > background one first. But I understand the periodic one is simpler to implement.
> > On the other hand, it's not as urgent if you can simulate it from userspace.
> > With the 15min period you use, there's likely not much overhead saved when
> > invoking it from within the kernel? Sure there wouldn't be the synchronization
> > with khugepaged activity, but I still wonder if wiating for up to 1 minute
> > before khugepaged wakes up can make much difference with the 15min period.
> > Hm, your cron job could also perhaps adjust the khugepaged sleep tunable when
> > compaction is done, which IIRC results in immediate wakeup.
> > 
> 
> There are certainly ways to do this from userspace, but the premise is 
> that this issue, specifically for users of thp, is significant for 
> everyone ;)
> 
> The problem that I've encountered with a background-only approach is that 
> it doesn't help when you exec a large process that wants to fault most of 
> its text and thp immediately cannot be allocated.  This can be a result of 
> never having done any compaction at all other than from the page 
> allocator, which terminates when a page of the given order is available.  
> So on a fragmented machine, all memory faulted is shown in 
> thp_fault_fallback and we rely on khugepaged to (slowly) fix this problem 
> up for us.  We have shown great improvement in cpu utilization by 
> periodically compacting memory today.
> 
> Background compaction arguably wouldn't help that situation because it's 
> not fast enough to compact memory simultaneous to the large number of page 
> faults, and you can't wait for it to complete at exec().  The result is 
> the same: large thp_fault_fallback.
> 
> So I can understand the need for both periodic and background compaction 
> (and direct compaction for non-thp non-atomic high-order allocations 
> today) and I'm perhaps not as convinced as you are that we can eventually 
> do without periodic compaction.
> 
> 
> It seems to me that the vast majority of this discussion has centered 
> around the vehicle that performs the compaction.  We certainly require 
> kcompactd for background compaction, and we both agree that we need that 
> functionality.
> 
> Two issues I want to bring up:
> 
>  (1) do non-thp configs benefit from periodic compaction?
> 
>      In my experience, no, but perhaps there are other use cases where
>      this has been a pain.  The primary candidates, in my opinion,
>      would be the networking stack and slub.  Joonsoo reports having to
>      workaround issues with high-order slub allocations being too
>      expensive.  I'm not sure that would be better served by periodic
>      compaction, but it seems like a candidate for background compaction.

In embedded world, there is another candidate, ION allocator. When launching
a new app, it try to allocate high order pages for graphic memory and
fallback to low order pages as following sequence (8, 4, 0). Success of it
affects system performance. It looks like similar case as THP. I guess
it can be also benefit from periodic compaction. Detailed explanation
about the problem is noted on Pintu's slide so please refer it for
further information.

http://events.linuxfoundation.org/sites/events/files/slides/
%5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf

I think that supporting periodic compaction for other configs is way
to go.

Thanks.

> 
>      This is why my rfc tied periodic compaction to khugepaged, and we
>      have strong evidence that this helps thp and cpu utilization.  For
>      periodic compaction to be possible outside of thp, we'd need a use
>      case for it.
> 
>  (2) does kcompactd have to be per-node?
> 
>      I don't see the immediate benefit since direct compaction can
>      already scan remote memory and migrate it, khugepaged can do the
>      same.  Is there evidence that suggests that a per-node kcompactd
>      is significantly better than a single kthread?  I think others
>      would be more receptive of a single kthread addition.
> 
> My theory is that periodic compaction is only significantly beneficial for 
> thp per my rfc, and I think there's a significant advantage for khugepaged 
> to be able to trigger this periodic compaction immediately before scanning 
> and allocating to avoid waiting potentially for the lengthy 
> alloc_sleep_millisecs.  I don't see a problem with defining the period 
> with a khugepaged tunable for that reason.
> 
> For background compaction, which is more difficult, it would be simple to 
> implement a kcompactd to perform the memory compaction and actually be 
> triggered by khugepaged to do the compaction on its behalf and wait to 
> scan and allocate until it' complete.  The vehicle will probably end up as 
> kcompactd doing the actual compaction is both cases.
> 
> But until we have a background compaction implementation, it seems like 
> there's no objection to doing and defining periodic compaction in 
> khugepaged as the rfc proposes?  It seems like we can easily extend that 
> in the future once background compaction is available.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
