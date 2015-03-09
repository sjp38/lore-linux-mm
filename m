Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id AEFCD6B0078
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 17:02:29 -0400 (EDT)
Received: by wevk48 with SMTP id k48so31814797wev.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 14:02:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g13si743644wiv.96.2015.03.09.14.02.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Mar 2015 14:02:28 -0700 (PDT)
Date: Mon, 9 Mar 2015 21:02:20 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150309210147.GA3406@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-5-git-send-email-mgorman@suse.de>
 <20150307163657.GA9702@gmail.com>
 <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
 <20150308203145.GA4038@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150308203145.GA4038@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sun, Mar 08, 2015 at 08:40:25PM +0000, Mel Gorman wrote:
> > Because if the answer is 'yes', then we can safely say: 'we regressed 
> > performance because correctness [not dropping dirty bits] comes before 
> > performance'.
> > 
> > If the answer is 'no', then we still have a mystery (and a regression) 
> > to track down.
> > 
> > As a second hack (not to be applied), could we change:
> > 
> >  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
> > 
> > to:
> > 
> >  #define _PAGE_BIT_PROTNONE      (_PAGE_BIT_GLOBAL+1)
> > 
> 
> In itself, that's not enough. The SWP_OFFSET_SHIFT would also need updating
> as a partial revert of 21d9ee3eda7792c45880b2f11bff8e95c9a061fb but it
> can be done.
> 

More importantily, _PAGE_BIT_GLOBAL+1 == the special PTE bit so just
updating the value should crash. For the purposes of testing the idea, I
thought the straight-forward option was to break soft dirty page tracking
and steal their bit for testing (patch below). Took most of the day to
get access to the test machine so tests are not long running and only
the autonuma one has completed;

autonumabench
                                              3.19.0             4.0.0-rc1             4.0.0-rc1             4.0.0-rc1
                                             vanilla               vanilla         slowscan-v2r7        protnone-v3
Time User-NUMA01                  25695.96 (  0.00%)    32883.59 (-27.97%)    35288.00 (-37.33%)    35236.21 (-37.13%)
Time User-NUMA01_THEADLOCAL       17404.36 (  0.00%)    17453.20 ( -0.28%)    17765.79 ( -2.08%)    17590.10 ( -1.07%)
Time User-NUMA02                   2037.65 (  0.00%)     2063.70 ( -1.28%)     2063.22 ( -1.25%)     2072.95 ( -1.73%)
Time User-NUMA02_SMT                981.02 (  0.00%)      983.70 ( -0.27%)      976.01 (  0.51%)      983.42 ( -0.24%)
Time System-NUMA01                  194.70 (  0.00%)      602.44 (-209.42%)      209.42 ( -7.56%)      737.36 (-278.72%)
Time System-NUMA01_THEADLOCAL        98.52 (  0.00%)       78.10 ( 20.73%)       92.70 (  5.91%)       80.69 ( 18.10%)
Time System-NUMA02                    9.28 (  0.00%)        6.47 ( 30.28%)        6.06 ( 34.70%)        6.63 ( 28.56%)
Time System-NUMA02_SMT                3.79 (  0.00%)        5.06 (-33.51%)        3.39 ( 10.55%)        3.60 (  5.01%)
Time Elapsed-NUMA01                 558.84 (  0.00%)      755.96 (-35.27%)      833.63 (-49.17%)      804.50 (-43.96%)
Time Elapsed-NUMA01_THEADLOCAL      382.54 (  0.00%)      382.22 (  0.08%)      395.45 ( -3.37%)      388.12 ( -1.46%)
Time Elapsed-NUMA02                  49.83 (  0.00%)       49.38 (  0.90%)       50.21 ( -0.76%)       48.99 (  1.69%)
Time Elapsed-NUMA02_SMT              46.59 (  0.00%)       47.70 ( -2.38%)       48.55 ( -4.21%)       49.50 ( -6.25%)
Time CPU-NUMA01                    4632.00 (  0.00%)     4429.00 (  4.38%)     4258.00 (  8.07%)     4471.00 (  3.48%)
Time CPU-NUMA01_THEADLOCAL         4575.00 (  0.00%)     4586.00 ( -0.24%)     4515.00 (  1.31%)     4552.00 (  0.50%)
Time CPU-NUMA02                    4107.00 (  0.00%)     4191.00 ( -2.05%)     4120.00 ( -0.32%)     4244.00 ( -3.34%)
Time CPU-NUMA02_SMT                2113.00 (  0.00%)     2072.00 (  1.94%)     2017.00 (  4.54%)     1993.00 (  5.68%)

              3.19.0   4.0.0-rc1   4.0.0-rc1   4.0.0-rc1
             vanilla     vanillaslowscan-v2r7protnone-v3
User        46119.12    53384.29    56093.11    55882.82
System        306.41      692.14      311.64      828.36
Elapsed      1039.88     1236.87     1328.61     1292.92

So just using a different bit doesn't seem to be it either

                                3.19.0   4.0.0-rc1   4.0.0-rc1   4.0.0-rc1
                               vanilla     vanillaslowscan-v2r7protnone-v3
NUMA alloc hit                 1202922     1437560     1472578     1499274
NUMA alloc miss                      0           0           0           0
NUMA interleave hit                  0           0           0           0
NUMA alloc local               1200683     1436781     1472226     1498680
NUMA base PTE updates        222840103   304513172   121532313   337431414
NUMA huge PMD updates           434894      594467      237170      658715
NUMA page range updates      445505831   608880276   242963353   674693494
NUMA hint faults                601358      733491      334334      820793
NUMA hint local faults          371571      511530      227171      565003
NUMA hint local percent             61          69          67          68
NUMA pages migrated            7073177    26366701     8607082    31288355

Patch to use a bit other than the global bit for prot none is below.

diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 8c7c10802e9c..1f243323693c 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -20,16 +20,16 @@
 #define _PAGE_BIT_SOFTW2	10	/* " */
 #define _PAGE_BIT_SOFTW3	11	/* " */
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
-#define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW1
-#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW1
+#define _PAGE_BIT_SPECIAL	_PAGE_BIT_SOFTW3
+#define _PAGE_BIT_CPA_TEST	_PAGE_BIT_SOFTW3
 #define _PAGE_BIT_SPLITTING	_PAGE_BIT_SOFTW2 /* only valid on a PSE pmd */
-#define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW3 /* hidden by kmemcheck */
-#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW3 /* software dirty tracking */
+#define _PAGE_BIT_HIDDEN	_PAGE_BIT_SOFTW1 /* hidden by kmemcheck */
+#define _PAGE_BIT_SOFT_DIRTY	_PAGE_BIT_SOFTW1 /* software dirty tracking */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
 /* - if the user mapped it with PROT_NONE; pte_present gives true */
-#define _PAGE_BIT_PROTNONE	_PAGE_BIT_GLOBAL
+#define _PAGE_BIT_PROTNONE	_PAGE_BIT_SOFTW1
 
 #define _PAGE_PRESENT	(_AT(pteval_t, 1) << _PAGE_BIT_PRESENT)
 #define _PAGE_RW	(_AT(pteval_t, 1) << _PAGE_BIT_RW)
@@ -98,8 +98,7 @@
 
 /* Set of bits not changed in pte_modify */
 #define _PAGE_CHG_MASK	(PTE_PFN_MASK | _PAGE_PCD | _PAGE_PWT |		\
-			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY |	\
-			 _PAGE_SOFT_DIRTY)
+			 _PAGE_SPECIAL | _PAGE_ACCESSED | _PAGE_DIRTY)
 #define _HPAGE_CHG_MASK (_PAGE_CHG_MASK | _PAGE_PSE)
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
