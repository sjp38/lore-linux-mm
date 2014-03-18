Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C53736B0112
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 13:55:28 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lj1so7650750pab.34
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:55:28 -0700 (PDT)
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
        by mx.google.com with ESMTPS id zt8si1326549pbc.255.2014.03.18.10.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 10:55:27 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so7570194pbb.26
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 10:55:27 -0700 (PDT)
Message-ID: <5328888C.7030402@mit.edu>
Date: Tue, 18 Mar 2014 10:55:24 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] mm: support madvise(MADV_FREE)
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1394779070-8545-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

On 03/13/2014 11:37 PM, Minchan Kim wrote:
> This patch is an attempt to support MADV_FREE for Linux.
> 
> Rationale is following as.
> 
> Allocators call munmap(2) when user call free(3) if ptr is
> in mmaped area. But munmap isn't cheap because it have to clean up
> all pte entries, unlinking a vma and returns free pages to buddy
> so overhead would be increased linearly by mmaped area's size.
> So they like madvise_dontneed rather than munmap.
> 
> "dontneed" holds read-side lock of mmap_sem so other threads
> of the process could go with concurrent page faults so it is
> better than munmap if it's not lack of address space.
> But the problem is that most of allocator reuses that address
> space soonish so applications see page fault, page allocation,
> page zeroing if allocator already called madvise_dontneed
> on the address space.
> 
> For avoidng that overheads, other OS have supported MADV_FREE.
> The idea is just mark pages as lazyfree when madvise called
> and purge them if memory pressure happens. Otherwise, VM doesn't
> detach pages on the address space so application could use
> that memory space without above overheads.

I must be missing something.

If the application issues MADV_FREE and then writes to the MADV_FREEd
range, the kernel needs to know that the pages are no longer safe to
lazily free.  This would presumably happen via a page fault on write.
For that to happen reliably, the kernel has to write protect the pages
when MADV_FREE is called, which in turn requires flushing the TLBs.

How does this end up being faster than munmap?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
