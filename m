Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 772926B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 00:20:26 -0500 (EST)
Received: by pabli10 with SMTP id li10so20729207pab.13
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 21:20:26 -0800 (PST)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id px4si17541256pbb.210.2015.03.02.21.20.23
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 21:20:25 -0800 (PST)
Date: Tue, 3 Mar 2015 16:20:04 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150303052004.GM18360@dastard>
References: <20150302010413.GP4251@dastard>
 <CA+55aFzGFvVGD_8Y=jTkYwgmYgZnW0p0Fjf7OHFPRcL6Mz4HOw@mail.gmail.com>
 <20150303014733.GL18360@dastard>
 <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
 <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com

On Mon, Mar 02, 2015 at 06:37:47PM -0800, Linus Torvalds wrote:
> On Mon, Mar 2, 2015 at 6:22 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > There might be some other case where the new "just change the
> > protection" doesn't do the "oh, but it the protection didn't change,
> > don't bother flushing". I don't see it.
> 
> Hmm. I wonder.. In change_pte_range(), we just unconditionally change
> the protection bits.
> 
> But the old numa code used to do
> 
>     if (!pte_numa(oldpte)) {
>         ptep_set_numa(mm, addr, pte);
> 
> so it would actually avoid the pte update if a numa-prot page was
> marked numa-prot again.
> 
> But are those migrate-page calls really common enough to make these
> things happen often enough on the same pages for this all to matter?

It's looking like that's a possibility.  I am running a fake-numa=4
config on this test VM so it's got 4 nodes of 4p/4GB RAM each.
both kernels are running through the same page fault path and that
is straight through migrate_pages().

3.19:

   13.70%     0.01%  [kernel]            [k] native_flush_tlb_others
   - native_flush_tlb_others
      - 98.58% flush_tlb_page
           ptep_clear_flush
           try_to_unmap_one
           rmap_walk
           try_to_unmap
           migrate_pages
           migrate_misplaced_page
         - handle_mm_fault
            - 96.88% __do_page_fault
                 trace_do_page_fault
                 do_async_page_fault
               + async_page_fault
            + 3.12% __get_user_pages
      + 1.40% flush_tlb_mm_range

4.0-rc1:

-   67.12%     0.04%  [kernel]            [k] native_flush_tlb_others
   - native_flush_tlb_others
      - 99.80% flush_tlb_page
           ptep_clear_flush
           try_to_unmap_one
           rmap_walk
           try_to_unmap
           migrate_pages
           migrate_misplaced_page
         - handle_mm_fault
            - 99.50% __do_page_fault
                 trace_do_page_fault
                 do_async_page_fault
               - async_page_fault

Same call chain, just a lot more CPU used further down the stack.

> Odd.
> 
> So it would be good if your profiles just show "there's suddenly a
> *lot* more calls to flush_tlb_page() from XYZ" and the culprit is
> obvious that way..

Ok, I did a simple 'perf stat -e tlb:tlb_flush -a -r 6 sleep 10' to
count all the tlb flush events from the kernel. I then pulled the
full events for a 30s period to get a sampling of the reason
associated with each flush event.

4.0-rc1:

 Performance counter stats for 'system wide' (6 runs):

         2,190,503      tlb:tlb_flush      ( +-  8.30% )

      10.001970663 seconds time elapsed    ( +-  0.00% )

The reason breakdown:

	81% TLB_REMOTE_SHOOTDOWN
	19% TLB_FLUSH_ON_TASK_SWITCH

3.19:

 Performance counter stats for 'system wide' (6 runs):

           467,151      tlb:tlb_flush      ( +- 25.50% )

      10.002021491 seconds time elapsed    ( +-  0.00% )

The reason breakdown:

	  6% TLB_REMOTE_SHOOTDOWN
	 94% TLB_FLUSH_ON_TASK_SWITCH

The difference would appear to be the number of remote TLB
shootdowns that are occurring from otherwise identical page fault
paths.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
