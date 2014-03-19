Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9CD6B0126
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 20:18:28 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8080932pbb.33
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 17:18:28 -0700 (PDT)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id mu18si13519778pab.395.2014.03.18.17.18.25
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 17:18:27 -0700 (PDT)
Date: Wed, 19 Mar 2014 09:18:26 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/6] mm: support madvise(MADV_FREE)
Message-ID: <20140319001826.GA13475@bbox>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <5328888C.7030402@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5328888C.7030402@mit.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

Hello,

On Tue, Mar 18, 2014 at 10:55:24AM -0700, Andy Lutomirski wrote:
> On 03/13/2014 11:37 PM, Minchan Kim wrote:
> > This patch is an attempt to support MADV_FREE for Linux.
> > 
> > Rationale is following as.
> > 
> > Allocators call munmap(2) when user call free(3) if ptr is
> > in mmaped area. But munmap isn't cheap because it have to clean up
> > all pte entries, unlinking a vma and returns free pages to buddy
> > so overhead would be increased linearly by mmaped area's size.
> > So they like madvise_dontneed rather than munmap.
> > 
> > "dontneed" holds read-side lock of mmap_sem so other threads
> > of the process could go with concurrent page faults so it is
> > better than munmap if it's not lack of address space.
> > But the problem is that most of allocator reuses that address
> > space soonish so applications see page fault, page allocation,
> > page zeroing if allocator already called madvise_dontneed
> > on the address space.
> > 
> > For avoidng that overheads, other OS have supported MADV_FREE.
> > The idea is just mark pages as lazyfree when madvise called
> > and purge them if memory pressure happens. Otherwise, VM doesn't
> > detach pages on the address space so application could use
> > that memory space without above overheads.
> 
> I must be missing something.
> 
> If the application issues MADV_FREE and then writes to the MADV_FREEd
> range, the kernel needs to know that the pages are no longer safe to
> lazily free.  This would presumably happen via a page fault on write.
> For that to happen reliably, the kernel has to write protect the pages
> when MADV_FREE is called, which in turn requires flushing the TLBs.

It could be done by pte_dirty bit check. Of course, if some architectures
don't support it by H/W, pte_mkdirty would make it CoW as you said.
> 
> How does this end up being faster than munmap?

MADV_FREE doesn't need to return back the pages into page allocator
compared to MADV_DONTNEED and the overhead is not small when I measured
that on my machine.(Roughly, MADV_FREE's cost is half of DONTNEED through
avoiding involving page allocator.)

But I'd like to clarify that it's not MADV_FREE's goal that syscall
itself should be faster than MADV_DONTNEED but major goal is to
avoid unnecessary page fault + page allocation + page zeroing +
garbage swapout.

> 
> --Andy
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
