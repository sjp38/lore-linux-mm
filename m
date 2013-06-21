Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 653666B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 19:51:28 -0400 (EDT)
Subject: [PATCH 0/2] rwsem: performance enhancements for systems with many
 cores
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 21 Jun 2013 16:51:31 -0700
Message-ID: <1371858691.22432.3.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

In this patchset, we introduce two optimizations to read write semaphore.
The first one reduces cache bouncing of the sem->count field
by doing a pre-read of the sem->count and avoid cmpxchg if possible.
The second patch introduces similar optimistic spining logic in
the mutex code for the writer lock acquisition of rw-sem.

Combining the two patches, in testing by Davidlohr Bueso on aim7 workloads
on 8 socket 80 cores system, he saw improvements of
alltests (+14.5%), custom (+17%), disk (+11%), high_systime
(+5%), shared (+15%) and short (+4%), most of them after around 500
users when i_mmap was implemented as rwsem.

Feedbacks on the effectiveness of these tweaks on other workloads
will be appreciated.


Alex Shi (1):
  rwsem: check the lock before cpmxchg in down_write_trylock and    
    rwsem_do_wake

Tim Chen (1):
  rwsem: do optimistic spinning for writer lock acquisition

 Makefile                    |    2 +-
 include/asm-generic/rwsem.h |    8 +-
 include/linux/rwsem.h       |    3 +
 init/Kconfig                |    9 +++
 kernel/rwsem.c              |   29 +++++++-
 lib/rwsem.c                 |  169 ++++++++++++++++++++++++++++++++++++++-----
 6 files changed, 195 insertions(+), 25 deletions(-)

-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
