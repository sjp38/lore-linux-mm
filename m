Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7B0856B0152
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 01:16:02 -0400 (EDT)
Received: by mail-bk0-f49.google.com with SMTP id my13so525469bkb.8
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 22:16:01 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id zj7si8931390bkb.197.2014.03.18.22.16.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 22:16:00 -0700 (PDT)
Date: Wed, 19 Mar 2014 01:15:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/6] mm: support madvise(MADV_FREE)
Message-ID: <20140319051543.GI14688@cmpxchg.org>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <5328888C.7030402@mit.edu>
 <20140319001826.GA13475@bbox>
 <CALCETrUsgVgKDRjqY=7avbvowkNSn-CWJ3L9zti1SCOYgrY3UA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUsgVgKDRjqY=7avbvowkNSn-CWJ3L9zti1SCOYgrY3UA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

On Tue, Mar 18, 2014 at 05:23:37PM -0700, Andy Lutomirski wrote:
> On Tue, Mar 18, 2014 at 5:18 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello,
> >
> > On Tue, Mar 18, 2014 at 10:55:24AM -0700, Andy Lutomirski wrote:
> >> On 03/13/2014 11:37 PM, Minchan Kim wrote:
> >> > This patch is an attempt to support MADV_FREE for Linux.
> >> >
> >> > Rationale is following as.
> >> >
> >> > Allocators call munmap(2) when user call free(3) if ptr is
> >> > in mmaped area. But munmap isn't cheap because it have to clean up
> >> > all pte entries, unlinking a vma and returns free pages to buddy
> >> > so overhead would be increased linearly by mmaped area's size.
> >> > So they like madvise_dontneed rather than munmap.
> >> >
> >> > "dontneed" holds read-side lock of mmap_sem so other threads
> >> > of the process could go with concurrent page faults so it is
> >> > better than munmap if it's not lack of address space.
> >> > But the problem is that most of allocator reuses that address
> >> > space soonish so applications see page fault, page allocation,
> >> > page zeroing if allocator already called madvise_dontneed
> >> > on the address space.
> >> >
> >> > For avoidng that overheads, other OS have supported MADV_FREE.
> >> > The idea is just mark pages as lazyfree when madvise called
> >> > and purge them if memory pressure happens. Otherwise, VM doesn't
> >> > detach pages on the address space so application could use
> >> > that memory space without above overheads.
> >>
> >> I must be missing something.
> >>
> >> If the application issues MADV_FREE and then writes to the MADV_FREEd
> >> range, the kernel needs to know that the pages are no longer safe to
> >> lazily free.  This would presumably happen via a page fault on write.
> >> For that to happen reliably, the kernel has to write protect the pages
> >> when MADV_FREE is called, which in turn requires flushing the TLBs.
> >
> > It could be done by pte_dirty bit check. Of course, if some architectures
> > don't support it by H/W, pte_mkdirty would make it CoW as you said.
> 
> If the page already has dirty PTEs, then you need to clear the dirty
> bits and flush TLBs so that other CPUs notice that the PTEs are clean,
> I think.
> 
> Also, this has very odd semantics wrt reading the page after MADV_FREE
> -- is reading the page guaranteed to un-free it?

MADV_FREE simply invalidates content.  Sure, you can read at a given
address repeatedly after it.  You might see a different page every
time you do it, but it doesn't matter; the content is undefined.

It's no different than doing malloc() and looking at the memory before
writing anything in it.  After MADV_FREE, the memory is like a freshly
malloc'd chunk: the first access may result in page faults and the
content is undefined until you write it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
