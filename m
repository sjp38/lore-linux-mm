Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2E8C86B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 02:31:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a8so6982083pfc.6
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 23:31:20 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id w12si164974pfa.434.2017.10.12.23.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Oct 2017 23:31:18 -0700 (PDT)
Date: Fri, 13 Oct 2017 14:31:11 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH] mm/page_alloc: make sure __rmqueue() etc. always inline
Message-ID: <20171013063111.GA26032@intel.com>
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com>
 <20171010025601.GE1798@intel.com>
 <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
 <20171010054342.GF1798@intel.com>
 <20171010144545.c87a28b0f3c4e475305254ab@linux-foundation.org>
 <20171011023402.GC27907@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011023402.GC27907@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

__rmqueue(), __rmqueue_fallback(), __rmqueue_smallest() and
__rmqueue_cma_fallback() are all in page allocator's hot path and
better be finished as soon as possible. One way to make them faster
is by making them inline. But as Andrew Morton and Andi Kleen pointed
out:
https://lkml.org/lkml/2017/10/10/1252
https://lkml.org/lkml/2017/10/10/1279
To make sure they are inlined, we should use __always_inline for them.

With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
processes to stress buddy, the results for will-it-scale.processes with
and without the patch are:

On a 2-sockets Intel-Skylake machine:

 compiler          base        head
gcc-4.4.7       6496131     6911823 +6.4%
gcc-4.9.4       7225110     7731072 +7.0%
gcc-5.4.1       7054224     7688146 +9.0%
gcc-6.2.0       7059794     7651675 +8.4%

On a 4-sockets Intel-Skylake machine:

 compiler          base        head
gcc-4.4.7      13162890    13508193 +2.6%
gcc-4.9.4      14997463    15484353 +3.2%
gcc-5.4.1      14708711    15449805 +5.0%
gcc-6.2.0      14574099    15349204 +5.3%

The above 4 compilers are used becuase I've done the tests through Intel's
Linux Kernel Performance(LKP) infrastructure and they are the available
compilers there.

The benefit being less on 4 sockets machine is due to the lock contention
there(perf-profile/native_queued_spin_lock_slowpath=81%) is less severe
than on the 2 sockets machine(85%).

What the benchmark does is: it forks nr_cpu processes and then each
process does the following:
    1 mmap() 128M anonymous space;
    2 writes to each page there to trigger actual page allocation;
    3 munmap() it.
in a loop.
https://github.com/antonblanchard/will-it-scale/blob/master/tests/page_fault1.c

Binary size wise, I have locally built them with different compilers:

[aaron@aaronlu obj]$ size */*/mm/page_alloc.o
   text    data     bss     dec     hex filename
  37409    9904    8524   55837    da1d gcc-4.9.4/base/mm/page_alloc.o
  38273    9904    8524   56701    dd7d gcc-4.9.4/head/mm/page_alloc.o
  37465    9840    8428   55733    d9b5 gcc-5.5.0/base/mm/page_alloc.o
  38169    9840    8428   56437    dc75 gcc-5.5.0/head/mm/page_alloc.o
  37573    9840    8428   55841    da21 gcc-6.4.0/base/mm/page_alloc.o
  38261    9840    8428   56529    dcd1 gcc-6.4.0/head/mm/page_alloc.o
  36863    9840    8428   55131    d75b gcc-7.2.0/base/mm/page_alloc.o
  37711    9840    8428   55979    daab gcc-7.2.0/head/mm/page_alloc.o

Text size increased about 800 bytes for mm/page_alloc.o.

[aaron@aaronlu obj]$ size */*/vmlinux
   text    data     bss     dec       hex     filename
10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/base/vmlinux
10342757   5903208 17723392 33969357  20654cd gcc-4.9.4/head/vmlinux
10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/base/vmlinux
10332448   5836608 17715200 33884256  2050860 gcc-5.5.0/head/vmlinux
10094546   5836696 17715200 33646442  201676a gcc-6.4.0/base/vmlinux
10094546   5836696 17715200 33646442  201676a gcc-6.4.0/head/vmlinux
10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/base/vmlinux
10018775   5828732 17715200 33562707  2002053 gcc-7.2.0/head/vmlinux

Text size for vmlinux has no change though, probably due to function
alignment.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0e309ce4a44a..0fe3e2095268 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1794,7 +1794,7 @@ static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags
  * Go through the free lists for the given migratetype and remove
  * the smallest available page from the freelists
  */
-static inline
+static __always_inline
 struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 						int migratetype)
 {
@@ -1838,7 +1838,7 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 };
 
 #ifdef CONFIG_CMA
-static struct page *__rmqueue_cma_fallback(struct zone *zone,
+static __always_inline struct page *__rmqueue_cma_fallback(struct zone *zone,
 					unsigned int order)
 {
 	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
@@ -2219,7 +2219,7 @@ static bool unreserve_highatomic_pageblock(const struct alloc_context *ac,
  * deviation from the rest of this file, to make the for loop
  * condition simpler.
  */
-static inline bool
+static __always_inline bool
 __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
 	struct free_area *area;
@@ -2291,8 +2291,8 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
-static struct page *__rmqueue(struct zone *zone, unsigned int order,
-				int migratetype)
+static __always_inline struct page *
+__rmqueue(struct zone *zone, unsigned int order, int migratetype)
 {
 	struct page *page;
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
