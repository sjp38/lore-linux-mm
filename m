Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 776586B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 12:58:27 -0400 (EDT)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [RFC PATCH] Increase locking granularity in THP page fault code
Date: Fri, 30 Aug 2013 11:58:16 -0500
Message-Id: <1377881897-138063-1-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Robin Holt <robinmholt@gmail.com>, Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org

We have a threaded page fault scaling test that is performing very
poorly due to the use of the page_table_lock in the THP fault code
path. By replacing the page_table_lock with the ptl on the pud_page
(need CONFIG_SPLIT_PTLOCKS for this to work), we're able to increase
the granularity of the locking here by a factor of 512, i.e. instead
of locking all 256TB of addressable memory, we only lock the 512GB that
is handled by a single pud_page.

The test I'm running creates 512 threads, pins each thread to a cpu, has
the threads allocate 512mb of memory each and then touch the first byte
of each 4k chunk of the allocated memory.  Here are the timings from
this test on 3.11-rc7, clean, THP on:

real	22m50.904s
user	15m26.072s
sys	11430m19.120s

And here are the timings with my modified kernel, THP on:

real	0m37.018s
user	21m39.164s
sys	155m9.132s

As you can see, we get a huge performance boost by locking a more
targeted chunk of memory instead of locking the whole page table.  At
this point, I'm comfortable saying that there are obvious benefits to
increasing the granularity of the locking, but I'm not sure that I've
done this in the best way possible.  Mainly, I'm not positive that using
the pud_page lock actually protects everything that we're concerned
about locking here.  I'm hoping that everyone can provide some input
on whether or not this seems like a reasonable move to make and, if so,
confirm that I've locked things appropriately.

As a side note, we still have some pretty significant scaling issues
with this test, both with THP on, and off.  I'm cleaning up the locking
here first as this is causing the biggest performance hit.

Alex Thorlton (1):
  Change THP code to use pud_page(pud)->ptl lock instead of
    page_table_lock

 mm/huge_memory.c | 4 ++--
 mm/memory.c      | 6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
