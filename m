Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id E06A36B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:18:08 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so2383711eek.21
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:18:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s42si15458126eew.119.2013.12.10.10.18.07
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 10:18:07 -0800 (PST)
Date: Tue, 10 Dec 2013 18:18:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: ebizzy performance regression due to X86 TLB range flush
Message-ID: <20131210181804.GA24125@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Running tests on a new machine I found that ebizzy regressed between 3.4
and 3.10. The ordering of kernel version is a bit off but you can see it
here

ebizzy
                          3.0.101                3.2.52                3.11.0                3.12.0                3.4.69               3.10.19
                          vanilla               vanilla               vanilla               vanilla               vanilla               vanilla
Mean     1      7633.80 (  0.00%)     7540.60 ( -1.22%)     7296.80 ( -4.41%)     7362.60 ( -3.55%)     7500.80 ( -1.74%)     7441.20 ( -2.52%)
Mean     2      9546.60 (  0.00%)     9679.60 (  1.39%)     8265.40 (-13.42%)     8125.20 (-14.89%)     9496.40 ( -0.53%)     8307.60 (-12.98%)
Mean     3      9011.20 (  0.00%)     9277.00 (  2.95%)     8088.00 (-10.25%)     8014.00 (-11.07%)     9225.80 (  2.38%)     8136.80 ( -9.70%)
Mean     4      8982.20 (  0.00%)     9179.80 (  2.20%)     7877.20 (-12.30%)     7804.40 (-13.11%)     9002.20 (  0.22%)     7952.40 (-11.46%)
Mean     5      8991.00 (  0.00%)     9053.00 (  0.69%)     7552.20 (-16.00%)     7110.80 (-20.91%)     9022.40 (  0.35%)     7777.40 (-13.50%)
Mean     6      8999.80 (  0.00%)     9024.00 (  0.27%)     7478.80 (-16.90%)     6858.40 (-23.79%)     8946.20 ( -0.60%)     7595.40 (-15.60%)
Mean     7      8929.00 (  0.00%)     8969.40 (  0.45%)     7473.80 (-16.30%)     6743.00 (-24.48%)     8942.20 (  0.15%)     7569.00 (-15.23%)
Mean     8      8894.80 (  0.00%)     8951.60 (  0.64%)     7471.00 (-16.01%)     6506.20 (-26.85%)     8919.20 (  0.27%)     7559.20 (-15.02%)
Mean     12     8545.20 (  0.00%)     8704.80 (  1.87%)     7181.40 (-15.96%)     6130.40 (-28.26%)     8675.20 (  1.52%)     7271.80 (-14.90%)
Mean     16     8270.00 (  0.00%)     8513.40 (  2.94%)     6943.40 (-16.04%)     6051.00 (-26.83%)     8454.80 (  2.23%)     7079.00 (-14.40%)
Mean     20     8040.20 (  0.00%)     8317.40 (  3.45%)     6711.20 (-16.53%)     5967.60 (-25.78%)     8235.20 (  2.43%)     6835.60 (-14.98%)
Mean     24     7908.80 (  0.00%)     8108.20 (  2.52%)     6570.80 (-16.92%)     5942.80 (-24.86%)     8067.60 (  2.01%)     6692.20 (-15.38%)
Mean     28     7809.00 (  0.00%)     7937.00 (  1.64%)     6511.20 (-16.62%)     5893.80 (-24.53%)     7947.40 (  1.77%)     6596.00 (-15.53%)
Mean     32     7758.00 (  0.00%)     7856.60 (  1.27%)     6477.60 (-16.50%)     5878.60 (-24.23%)     7893.60 (  1.75%)     6582.80 (-15.15%)
Stddev   1        27.41 (  0.00%)       82.88 (-202.38%)       33.40 (-21.84%)       53.44 (-94.95%)       86.41 (-215.24%)       24.08 ( 12.16%)
Stddev   2       151.35 (  0.00%)       25.35 ( 83.25%)       33.86 ( 77.63%)       74.55 ( 50.74%)      111.26 ( 26.49%)       16.64 ( 89.00%)
Stddev   3       263.59 (  0.00%)       92.26 ( 65.00%)       27.77 ( 89.46%)       56.03 ( 78.74%)       76.78 ( 70.87%)       30.35 ( 88.49%)
Stddev   4        44.80 (  0.00%)       39.77 ( 11.23%)       57.74 (-28.89%)       36.71 ( 18.06%)       72.71 (-62.29%)       58.68 (-30.98%)
Stddev   5        34.25 (  0.00%)       36.81 ( -7.46%)       77.78 (-127.08%)       65.94 (-92.51%)       61.81 (-80.45%)       64.64 (-88.73%)
Stddev   6        49.11 (  0.00%)       29.70 ( 39.53%)       76.19 (-55.14%)       47.35 (  3.59%)       43.15 ( 12.14%)       37.04 ( 24.58%)
Stddev   7        23.13 (  0.00%)       13.75 ( 40.55%)       37.18 (-60.76%)       85.62 (-270.26%)       24.94 ( -7.86%)       34.05 (-47.25%)
Stddev   8        26.53 (  0.00%)       16.67 ( 37.17%)       29.60 (-11.57%)       41.08 (-54.86%)       40.18 (-51.47%)       30.32 (-14.30%)
Stddev   12       23.47 (  0.00%)       33.39 (-42.23%)       36.43 (-55.22%)       32.29 (-37.56%)       31.92 (-35.99%)       30.66 (-30.60%)
Stddev   16        7.40 (  0.00%)       14.25 (-92.49%)       48.36 (-553.21%)       10.14 (-36.96%)       64.97 (-777.68%)       64.96 (-777.45%)
Stddev   20       25.03 (  0.00%)       12.21 ( 51.23%)       20.83 ( 16.80%)       21.74 ( 13.15%)       30.77 (-22.94%)       57.62 (-130.20%)
Stddev   24       49.13 (  0.00%)       26.10 ( 46.87%)       25.90 ( 47.28%)        7.05 ( 85.64%)       33.13 ( 32.57%)       17.43 ( 64.53%)
Stddev   28       21.96 (  0.00%)       21.49 (  2.14%)       16.44 ( 25.16%)       13.88 ( 36.82%)       22.97 ( -4.56%)       13.04 ( 40.64%)
Stddev   32       30.61 (  0.00%)       35.76 (-16.80%)       38.46 (-25.64%)        6.47 ( 78.87%)       25.40 ( 17.04%)       17.31 ( 43.45%)

Bisection initially found at least two problems of which the first was
commit 611ae8e3 (x86/tlb: enable tlb flush range support for x86). The
intent of the patch appears to be to preserve existing TLB entries which
makes sense. The decision on whether to do a full mm flush or a number of
single page flushes depends on the size of the relevant TLB and the CPU
which is presuably taking the cost of a TLB refill.

It's a gamble because the cost of the per-page flushes must be offset by a
reduced TLB miss count. There are no indications what the cost of calling
invlpg are if there are no TLB entries and it's also not taking into
account how many CPUs it may have to execute these single TLB flushes on.

Ebizzy sees very little benefit as it discards newly allocated memory very
quickly which is why it appeared to regress so badly. It's a benchmark
so there is little point optimising for it. However, I'm curious as
to whether you are aware of this problem already for this or any other
workload and whether it has been concluded that the cost is justified or
not?

The below hatchet job happens to work for smaller numbers of clients
because threads have a chance to run on multiple CPUs in time to decide
to do a full mm flush. It actually still works out better for ebizzy to
always flush the full mm and the same might be true for other workloads. I
haven't thought of a better way of detecting the correct decision though.

---8<---
x86: mm: Take number of CPUs to flush into account

ebizzy
                       3.13.0-rc3            3.13.0-rc3
                          vanilla           native-v1r5
Mean     1      7353.60 (  0.00%)     7388.20 (  0.47%)
Mean     2      8120.40 (  0.00%)     9517.60 ( 17.21%)
Mean     3      8087.80 (  0.00%)     8933.40 ( 10.46%)
Mean     4      7919.20 (  0.00%)     8549.40 (  7.96%)
Mean     5      7310.60 (  0.00%)     8131.20 ( 11.22%)
Mean     6      6798.00 (  0.00%)     7434.00 (  9.36%)
Mean     7      6759.40 (  0.00%)     6942.20 (  2.70%)
Mean     8      6501.80 (  0.00%)     6526.00 (  0.37%)
Mean     12     6606.00 (  0.00%)     6669.40 (  0.96%)
Mean     16     6655.40 (  0.00%)     6702.20 (  0.70%)
Mean     20     6703.80 (  0.00%)     6727.00 (  0.35%)
Mean     24     6705.80 (  0.00%)     6742.80 (  0.55%)
Mean     28     6706.60 (  0.00%)     6737.20 (  0.46%)
Mean     32     6727.20 (  0.00%)     6746.60 (  0.29%)
Stddev   1        42.71 (  0.00%)       51.62 (-20.87%)
Stddev   2       250.26 (  0.00%)       22.37 ( 91.06%)
Stddev   3        71.67 (  0.00%)       32.38 ( 54.82%)
Stddev   4        30.25 (  0.00%)       67.76 (-124.00%)
Stddev   5        71.18 (  0.00%)      130.12 (-82.80%)
Stddev   6        34.22 (  0.00%)      192.50 (-462.60%)
Stddev   7       100.59 (  0.00%)      148.51 (-47.64%)
Stddev   8        20.26 (  0.00%)       80.64 (-297.99%)
Stddev   12       19.43 (  0.00%)       26.79 (-37.84%)
Stddev   16       14.47 (  0.00%)       13.95 (  3.62%)
Stddev   20       21.37 (  0.00%)       17.78 ( 16.81%)
Stddev   24       12.87 (  0.00%)       17.81 (-38.37%)
Stddev   28       13.89 (  0.00%)       12.83 (  7.67%)
Stddev   32       18.14 (  0.00%)        9.99 ( 44.91%)

---
 arch/x86/mm/tlb.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/tlb.c b/arch/x86/mm/tlb.c
index 0f35bfb..907d124 100644
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -220,6 +220,7 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 {
 	unsigned long addr;
 	unsigned act_entries, tlb_entries = 0;
+	unsigned nr_flushes;
 
 	preempt_disable();
 	if (current->active_mm != mm)
@@ -243,9 +244,11 @@ void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 		tlb_entries = tlb_lld_4k[ENTRIES];
 	/* Assume all of TLB entries was occupied by this task */
 	act_entries = mm->total_vm > tlb_entries ? tlb_entries : mm->total_vm;
+	nr_flushes = (end - start) >> PAGE_SHIFT;
+	nr_flushes *= cpumask_weight(mm_cpumask(mm));
 
 	/* tlb_flushall_shift is on balance point, details in commit log */
-	if ((end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift) {
+	if (nr_flushes > act_entries >> tlb_flushall_shift) {
 		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
 	} else {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
