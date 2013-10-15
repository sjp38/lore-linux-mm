Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AB6E96B0038
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 16:35:50 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kx10so1477588pab.15
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:35:50 -0700 (PDT)
Subject: [RFC][PATCH 6/8] mm: pcp: consolidate high-to-batch ratio code
From: Dave Hansen <dave@sr71.net>
Date: Tue, 15 Oct 2013 13:35:47 -0700
References: <20131015203536.1475C2BE@viggo.jf.intel.com>
In-Reply-To: <20131015203536.1475C2BE@viggo.jf.intel.com>
Message-Id: <20131015203547.8724C69C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Up until now in this patch set, we really should not have been
changing any behavior that users would notice.  This patch
potentially has performance implications for virtually all users
since it changes the kernel's default behavior.

The per-cpu-pageset code currently has hard-coded ratios which
relate the batch size to the high watermark.  However, the ratio
is different for the boot-time and sysctl-set variants, and I
believe this difference in the code was an accident.

This patch introduces a common variable to store this ratio, no
matter whether we are using the default or sysctl code.  It also
changes the default boot-time ratio from 6:1 to 4:1, since I
believe that we never intended to make it a 6:1 ratio.  As best
I can tell, that change came from e46a5e28c, and there is no
mention in that patch of doing this.  The *correct* thing in
that patch would have been to drop ->low from 2->0 and also drop
high from 6->4 to keep the average size of the pool the same.

BTW, I'm fairly ambivalent on whether the ratio should really
4:1 or 6:1.  We obviously intended it to be 4:1, but it's been
6:1 for 8 or so years.

I did quite a bit of testing on some large (160-cpu) and medium
(12-cpu) systems.  On the 12-cpu system, I ran several hundred
allyesconfig compiles varying the ->high watermark (x axis) to
see if there was a sweet spot for these values (y axis is seconds
to complete a kernel compile):

	http://sr71.net/~dave/intel/201310-pcp/pcp1.png

As you can see, the results are all over the map.  Doing a
running-average, things calm down a bit:

	http://sr71.net/~dave/intel/201310-pcp/pcp-runavg5.png

but still not enough for me to say that we can see any real
trends.

A little more investigation of the code follow, but it's probably
more than most readers care about.

---

Looking at the code, I can not really grok what this comment in
zone_batchsize() means:

	batch /= 4;             /* We effectively *= 4 below */

It surely can't refer to the:

	batch = rounddown_pow_of_two(batch + batch/2) - 1;

code in the same function since the round down code at *MOST*
does a *= 1.5 (but *averages* out to be just under 1).  I
*think* this comment refers to the code which is now in:

static void pageset_set_batch(struct per_cpu_pageset *p...
{
        pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
}

Where the 6*batch argument is the "high" mark.  Note that we do a
/=4, but then follow up with a 6*batch later.  These got
mismatched when the pcp->low code got removed.  The result is
that we now operate by default with a 6:1 high:batch ratio where
the percpu_pagelist_fraction sysctl code operates with a 4:1
ratio:

static void pageset_set_high(struct per_cpu_pageset *p...
{
        unsigned long batch = max(1UL, high / 4);

I would suspect that this ratio isn't all that important since
nobody seems to have ever noticed this, plus I wasn't able to
observe it _doing_ anything in my benchmarks.  Furthermore, the
*actual* ratio for the sysctl-set pagelist sizes is variable since
it clamps the batch size to <=PAGE_SHIFT*8 on matter how large
->high is.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/Documentation/sysctl/vm.txt |    2 +-
 linux.git-davehans/mm/page_alloc.c             |   10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff -puN Documentation/sysctl/vm.txt~fix-pcp-batch-calculation Documentation/sysctl/vm.txt
--- linux.git/Documentation/sysctl/vm.txt~fix-pcp-batch-calculation	2013-10-15 09:57:07.304675699 -0700
+++ linux.git-davehans/Documentation/sysctl/vm.txt	2013-10-15 09:57:07.309675920 -0700
@@ -654,7 +654,7 @@ why oom happens. You can get snapshot.
 percpu_pagelist_fraction
 
 Set (at boot) to 0.  The kernel will size each percpu pagelist to around
-1/1000th of the size of the zone but limited to be around 0.75MB.
+1/1000th of the size of the zone (but no larger than 512kB).
 
 This is the fraction of pages at most (high mark pcp->high) in each zone that
 are allocated for each per cpu page list.  The min value for this is 8.  It
diff -puN mm/page_alloc.c~fix-pcp-batch-calculation mm/page_alloc.c
--- linux.git/mm/page_alloc.c~fix-pcp-batch-calculation	2013-10-15 09:57:07.306675787 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-10-15 09:57:07.312676053 -0700
@@ -4059,6 +4059,8 @@ static void __meminit zone_init_free_lis
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
+static int pcp_high_to_batch_ratio = 4;
+
 static int zone_batchsize(struct zone *zone)
 {
 #ifdef CONFIG_MMU
@@ -4073,7 +4075,7 @@ static int zone_batchsize(struct zone *z
 	batch = zone->managed_pages / 1024;
 	if (batch * PAGE_SIZE > 512 * 1024)
 		batch = (512 * 1024) / PAGE_SIZE;
-	batch /= 4;		/* We effectively *= 4 below */
+	batch /= pcp_high_to_batch_ratio;
 	if (batch < 1)
 		batch = 1;
 
@@ -4144,7 +4146,7 @@ static void pageset_setup_from_batch_siz
 					unsigned long batch)
 {
 	unsigned long high;
-	high = 6 * batch;
+	high = pcp_high_to_batch_ratio * batch;
 	if (!batch)
 		batch = 1;
 	pageset_update(&p->pcp, high, batch);
@@ -4176,8 +4178,8 @@ static void setup_pageset(struct per_cpu
 static void pageset_setup_from_high_mark(struct per_cpu_pageset *p,
 					unsigned long high)
 {
-	unsigned long batch = max(1UL, high / 4);
-	if ((high / 4) > (PAGE_SHIFT * 8))
+	unsigned long batch = max(1UL, high / pcp_high_to_batch_ratio);
+	if ((high / pcp_high_to_batch_ratio) > (PAGE_SHIFT * 8))
 		batch = PAGE_SHIFT * 8;
 
 	pageset_update(&p->pcp, high, batch);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
