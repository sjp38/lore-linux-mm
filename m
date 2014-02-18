Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4E16B003B
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 14:30:19 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so17121040pab.17
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 11:30:19 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id va10si19294163pbc.128.2014.02.18.11.30.18
        for <linux-mm@kvack.org>;
        Tue, 18 Feb 2014 11:30:18 -0800 (PST)
Subject: [RFC][PATCH 6/6] x86: mm: set TLB flush tunable to sane value
From: Dave Hansen <dave@sr71.net>
Date: Tue, 18 Feb 2014 11:30:17 -0800
References: <20140218193008.CA410E17@viggo.jf.intel.com>
In-Reply-To: <20140218193008.CA410E17@viggo.jf.intel.com>
Message-Id: <20140218193017.ECDF1089@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, ak@linux.intel.com, alex.shi@linaro.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, tim.c.chen@linux.intel.com, x86@kernel.org, peterz@infradead.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

Now that we have some shiny new tracepoints, we can actually
figure out what the heck is going on.

During a kernel compile, 60% of the flush_tlb_mm_range() calls
are for a single page.  It breaks down like this:

 size   percent  percent<=
  V        V        V
GLOBAL:   2.20%   2.20% avg cycles:  2283
     1:  56.92%  59.12% avg cycles:  1276
     2:  13.78%  72.90% avg cycles:  1505
     3:   8.26%  81.16% avg cycles:  1880
     4:   7.41%  88.58% avg cycles:  2447
     5:   1.73%  90.31% avg cycles:  2358
     6:   1.32%  91.63% avg cycles:  2563
     7:   1.14%  92.77% avg cycles:  2862
     8:   0.62%  93.39% avg cycles:  3542
     9:   0.08%  93.47% avg cycles:  3289
    10:   0.43%  93.90% avg cycles:  3570
    11:   0.20%  94.10% avg cycles:  3767
    12:   0.08%  94.18% avg cycles:  3996
    13:   0.03%  94.20% avg cycles:  4077
    14:   0.02%  94.23% avg cycles:  4836
    15:   0.04%  94.26% avg cycles:  5699
    16:   0.06%  94.32% avg cycles:  5041
    17:   0.57%  94.89% avg cycles:  5473
    18:   0.02%  94.91% avg cycles:  5396
    19:   0.03%  94.95% avg cycles:  5296
    20:   0.02%  94.96% avg cycles:  6749
    21:   0.18%  95.14% avg cycles:  6225
    22:   0.01%  95.15% avg cycles:  6393
    23:   0.01%  95.16% avg cycles:  6861
    24:   0.12%  95.28% avg cycles:  6912
    25:   0.05%  95.32% avg cycles:  7190
    26:   0.01%  95.33% avg cycles:  7793
    27:   0.01%  95.34% avg cycles:  7833
    28:   0.01%  95.35% avg cycles:  8253
    29:   0.08%  95.42% avg cycles:  8024
    30:   0.03%  95.45% avg cycles:  9670
    31:   0.01%  95.46% avg cycles:  8949
    32:   0.01%  95.46% avg cycles:  9350
    33:   3.11%  98.57% avg cycles:  8534
    34:   0.02%  98.60% avg cycles: 10977
    35:   0.02%  98.62% avg cycles: 11400

We get in to dimishing returns pretty quickly.  On pre-IvyBridge
CPUs, we used to set the limit at 8 pages, and it was set at 128
on IvyBrige.  That 128 number looks pretty silly considering that
less than 0.5% of the flushes are that large.

The previous code tried to size this number based on the size of
the TLB.  Good idea, but it's error-prone, needs maintenance
(which it didn't get up to now), and probably would not matter in
practice much.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/mm/tlb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN arch/x86/mm/tlb.c~set-tunable-to-sane-value arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~set-tunable-to-sane-value	2014-02-18 11:05:37.304813166 -0800
+++ b/arch/x86/mm/tlb.c	2014-02-18 11:05:37.306813257 -0800
@@ -166,7 +166,7 @@ void flush_tlb_current_task(void)
 }
 
 /* in units of pages */
-unsigned long tlb_single_page_flush_ceiling = 5;
+unsigned long tlb_single_page_flush_ceiling = 33;
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 				unsigned long end, unsigned long vmflag)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
