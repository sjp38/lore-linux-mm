Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 643686B0038
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 20:08:23 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so3666268pab.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 17:08:23 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id aj10si345171pbd.206.2015.04.09.17.08.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 17:08:22 -0700 (PDT)
Received: by pabsx10 with SMTP id sx10so3625196pab.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 17:08:22 -0700 (PDT)
Date: Fri, 10 Apr 2015 09:08:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/4] mm: make every pte dirty on do_swap_page
Message-ID: <20150410000759.GA30287@blaptop>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-4-git-send-email-minchan@kernel.org>
 <20150408235012.GA13690@blaptop>
 <20150409135939.bbc9025d925de9d0fdd12797@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150409135939.bbc9025d925de9d0fdd12797@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Yalin.Wang@sonymobile.com, Hugh Dickins <hughd@google.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@parallels.com>

Hello Andrew,

On Thu, Apr 09, 2015 at 01:59:39PM -0700, Andrew Morton wrote:
> On Thu, 9 Apr 2015 08:50:25 +0900 Minchan Kim <minchan@kernel.org> wrote:
> 
> > Bump.
> 
> I'm getting the feeling that MADV_FREE is out of control.
> 
> Below is the overall rollup of
> 
> mm-support-madvisemadv_free.patch
> mm-support-madvisemadv_free-fix.patch
> mm-support-madvisemadv_free-fix-2.patch
> mm-dont-split-thp-page-when-syscall-is-called.patch
> mm-dont-split-thp-page-when-syscall-is-called-fix.patch
> mm-dont-split-thp-page-when-syscall-is-called-fix-2.patch
> mm-free-swp_entry-in-madvise_free.patch
> mm-move-lazy-free-pages-to-inactive-list.patch
> mm-move-lazy-free-pages-to-inactive-list-fix.patch
> mm-move-lazy-free-pages-to-inactive-list-fix-fix.patch
> mm-move-lazy-free-pages-to-inactive-list-fix-fix-fix.patch
> mm-make-every-pte-dirty-on-do_swap_page.patch
> 
> 
> It's pretty large and has its sticky little paws in all sorts of places.
> 
> 
> The feature would need to be pretty darn useful to justify a mainline
> merge.  Has any such usefulness been demonstrated?

Jemalloc has used MADV_FREE instead of MADV_DONTNEED for a long time
in MADV_FREE supporting OSes(FreeBSD, Solaris, Darwin, Windows).
It used MADV_DONTNEED on only Linux because there was no the feature.

========================== &< ===========================

jemalloc:

/*
 * Methods for purging unused pages differ between operating systems.
 *
 *   madvise(..., MADV_DONTNEED) : On Linux, this immediately discards pages,
 *                                 such that new pages will be demand-zeroed if
 *                                 the address region is later touched.
 *   madvise(..., MADV_FREE) : On FreeBSD and Darwin, this marks pages as being
 *                             unused, such that they will be discarded rather
 *                             than swapped out.
 */
...

bool
pages_purge(void *addr, size_t length)
{
        bool unzeroed;

#ifdef _WIN32
        VirtualAlloc(addr, length, MEM_RESET, PAGE_READWRITE);
        unzeroed = true;
#elif defined(JEMALLOC_HAVE_MADVISE)
#  ifdef JEMALLOC_PURGE_MADVISE_DONTNEED
#    define JEMALLOC_MADV_PURGE MADV_DONTNEED
#    define JEMALLOC_MADV_ZEROS true
#  elif defined(JEMALLOC_PURGE_MADVISE_FREE)
#    define JEMALLOC_MADV_PURGE MADV_FREE
#    define JEMALLOC_MADV_ZEROS false
#  else
#    error "No madvise(2) flag defined for purging unused dirty pages."
#  endif
        int err = madvise(addr, length, JEMALLOC_MADV_PURGE);
        unzeroed = (!JEMALLOC_MADV_ZEROS || err != 0); 
#  undef JEMALLOC_MADV_PURGE
#  undef JEMALLOC_MADV_ZEROS
#else
        /* Last resort no-op. */
        unzeroed = true;
#endif
        return (unzeroed);
}


Tcmalloc is same page.

========================== &< ===========================

// MADV_FREE is specifically designed for use by malloc(), but only
// FreeBSD supports it; in linux we fall back to the somewhat inferior
// MADV_DONTNEED.
#if !defined(MADV_FREE) && defined(MADV_DONTNEED)
# define MADV_FREE  MADV_DONTNEED
#endif

..

bool TCMalloc_SystemRelease(void* start, size_t length) {
#ifdef MADV_FREE
  if (FLAGS_malloc_devmem_start) {
    // It's not safe to use MADV_FREE/MADV_DONTNEED if we've been
    // mapping /dev/mem for heap memory.
    return false;
  }
  if (FLAGS_malloc_disable_memory_release) return false;
  if (pagesize == 0) pagesize = getpagesize();
  const size_t pagemask = pagesize - 1;

  size_t new_start = reinterpret_cast<size_t>(start);
  size_t end = new_start + length;
  size_t new_end = end;

  // Round up the starting address and round down the ending address
  // to be page aligned:
  new_start = (new_start + pagesize - 1) & ~pagemask;
  new_end = new_end & ~pagemask;

  ASSERT((new_start & pagemask) == 0);
  ASSERT((new_end & pagemask) == 0);
  ASSERT(new_start >= reinterpret_cast<size_t>(start));
  ASSERT(new_end <= end);

  if (new_end > new_start) {
    int result;
    do {
      result = madvise(reinterpret_cast<char*>(new_start),
          new_end - new_start, MADV_FREE);
    } while (result == -1 && errno == EAGAIN);

    return result != -1;
  }
#endif
  return false;
}

glibc want it, too.
https://sourceware.org/ml/libc-alpha/2015-02/msg00197.html


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
