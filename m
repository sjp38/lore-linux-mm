Date: Wed, 24 May 2000 13:35:37 -0700 (PDT)
From: Matthew Dillon <dillon@apollo.backplane.com>
Message-Id: <200005242035.NAA76960@apollo.backplane.com>
Subject: Re: [RFC] 2.3/4 VM queues idea
References: <OF99EF36E0.B08E89EA-ON862568E9.005C0C02@RSC.RAY.COM>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson@Raytheon.com
Cc: riel@conectiva.com.br, acme@conectiva.com.br, linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

    I should make a clarification on the LRU.  It's a center-weighted LRU,
    statistically based, which is different from a strict LRU.  In a
    strict LRU design when you access an element it will be moved to the end
    of the LRU queue.  In a weighted LRU design accessing the element
    adjusts the weight, and the queue placement depends on the new weight
    (i.e. the element may not be moved to the end of the queue).  The idea
    here is to get a statistical view of how 'active' the page is that
    is fairly consistent no matter when you sample it.  This is a very 
    different result then what you get with a strict LRU model because
    the statistical model incorporates the page's use history whereas a
    strict LRU model does not.

    The statistical model cannot predict if a page will be accessed 'soon',
    but it can do a reasonable job of predicting whether a page will be
    accessed continuously (over and over again), and it is the latter
    prediction which is the most important when trying to regulate a
    system's paging load.

    In regards to the overhead of maintaining the weight-ordering of pages
    in the queue -- this is one of the (several) reasons why you use a 
    multi-queue model rather then a single-queue model.  With a multi-queue
    model you do not have to spend a lot of time trying to keep the elements
    in each queue sorted, which reduces the per-page complexity of entering
    a page into the queue from O(N) to nearly O(1).  Taking the FBsd 
    implementation as an example, the pageout code will scan the active 
    queue looking for pages with 0 weightings.  It will scan the *entire*
    queue if it needs to but, in general, the loose ordering of pages
    within that queue results in being able to cut the scan off early
    in most cases.  This is what I mean by 'loose ordering within the queue'.

: - treat pages equally - I think I disagree with both you and Matt on this
:one. We have different usage patterns for different kinds of data (e.g.
:execution of code tends to be localized but not sequential vs. sequential
:read of data in a file) & should have a means of distinguishing between
:them. This does not mean that one algorithm won't do a good job for both
:the VM & buffer cache, just recognize that we should have ways to treat
:them differently. See my comments on "stress cases" below for my rationale.

    Finally, on how to treat pages.  Here's the problem:  When one 
    allocates a new page there is enough contextual information to determine
    how the page is likely to be used, allowing you to adjust the initial
    weight of the page.

    But once the page has been allocated you can't really make any assumptions
    about the ongoing use of the page short of actually checking to see if
    it has been accessed, not without putting the processes running on the
    system that happen to not operate under your assumptions at a huge
    disadvantage and as a consequence of that placing the system under more
    stress.

    What page load comes down to is simply this:  It's the kernel deciding
    to reuse a page that some process immediately tries to fault back in,
    requiring an I/O to get it back, or the kernel flushing a dirty page to
    backing store that some process immediately re-dirties, costing an
    unnecessary I/O.  This extra overhead creates memory strain on a system
    that can be avoided.  It doesn't matter what kind of page the strain
    was related to (swap, data file, binary, NFS, anything...).  We can't
    prevent the above from occuring (you can fully predict when a page will
    be needed), but what the statistical weighting gives us is the ability
    to prevent the above situation from *re*occuring, over and over again,
    for any given page.

    Actually measuring the useage statistically (the 'weight' of the page)
    is the only way to get reasonably close to actual use.  If you skew
    the results by making continuing assumptions (beyond the calculation 
    of the initial weight) on how the page will be used simply based on 
    the type of page you have, then *any* process in the system that happens
    to operate differently from those assumptions will not just cause
    inefficient paging to occur, it will *always* cause inefficient paging
    to occur.  Many of the memory stress situations Linux has come up
    against in the last few years are due directly to this scenario.

    The statistical model, on the otherhand, has a much better chance (not
    perfect obviously, but *better*) of adapting itself to the useage pattern
    of a process whatever that pattern happens to be.

    What you want to do instead is have heuristics which 'detect' certain
    page-use patterns and then adjust the weight based on that.  You aren't
    really making blatent assumptions here, you are simply figuring out what
    the actual pattern is and then acting upon it.  This is what all those
    'sequential detection' and other heuristics do.  These sorts of 
    adjustments to page weighting are very, very different from adjustments
    based on assumptions.

					-Matt
					Matthew Dillon
					<dillon@backplane.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
