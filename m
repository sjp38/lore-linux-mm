Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 283976B0035
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 05:35:42 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so2131202pdj.1
        for <linux-mm@kvack.org>; Mon, 28 Apr 2014 02:35:41 -0700 (PDT)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id ud10si10001155pbc.374.2014.04.28.02.04.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 28 Apr 2014 02:04:54 -0700 (PDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Mon, 28 Apr 2014 19:02:04 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 57EAA2BB005E
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:02:01 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s3S8erTl10551644
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 18:40:53 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s3S920K3027171
	for <linux-mm@kvack.org>; Mon, 28 Apr 2014 19:02:00 +1000
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
Subject: [PATCH V3 2/2] powerpc/pseries: init fault_around_order for pseries
Date: Mon, 28 Apr 2014 14:31:30 +0530
Message-Id: <1398675690-16186-3-git-send-email-maddy@linux.vnet.ibm.com>
In-Reply-To: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com>
References: <1398675690-16186-1-git-send-email-maddy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>

Performance data for different FAULT_AROUND_ORDER values from 4 socket
Power7 system (128 Threads and 128GB memory). perf stat with repeat of 5
is used to get the stddev values. Test ran in v3.14 kernel (Baseline) and
v3.15-rc1 for different fault around order values.

FAULT_AROUND_ORDER      Baseline        1               3               4               5               8

Linux build (make -j64)
minor-faults            47,437,359      35,279,286      25,425,347      23,461,275      22,002,189      21,435,836
times in seconds        347.302528420   344.061588460   340.974022391   348.193508116   348.673900158   350.986543618
 stddev for time        ( +-  1.50% )   ( +-  0.73% )   ( +-  1.13% )   ( +-  1.01% )   ( +-  1.89% )   ( +-  1.55% )
 %chg time to baseline                  -0.9%           -1.8%           0.2%            0.39%           1.06%

Linux rebuild (make -j64)
minor-faults            941,552         718,319         486,625         440,124         410,510         397,416
times in seconds        30.569834718    31.219637539    31.319370649    31.434285472    31.972367174    31.443043580
 stddev for time        ( +-  1.07% )   ( +-  0.13% )   ( +-  0.43% )   ( +-  0.18% )   ( +-  0.95% )   ( +-  0.58% )
 %chg time to baseline                  2.1%            2.4%            2.8%            4.58%           2.85%

Binutils build (make all -j64 )
minor-faults            474,821         371,380         269,463         247,715         235,255         228,337
times in seconds        53.882492432    53.584289348    53.882773216    53.755816431    53.607824348    53.423759642
 stddev for time        ( +-  0.08% )   ( +-  0.56% )   ( +-  0.17% )   ( +-  0.11% )   ( +-  0.60% )   ( +-  0.69% )
 %chg time to baseline                  -0.55%          0.0%            -0.23%          -0.51%          -0.85%

Two synthetic tests: access every word in file in sequential/random order.

Sequential access 16GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4               5               8
1 thread
       minor-faults     263,148         131,166         32,908          16,514          8,260           1,093
       times in seconds 53.091138345    53.113191672    53.188776177    53.233017218    53.206841347    53.429979442
       stddev for time  ( +-  0.06% )   ( +-  0.07% )   ( +-  0.08% )   ( +-  0.09% )   ( +-  0.03% )   ( +-  0.03% )
       %chg time to baseline            0.04%           0.18%           0.26%           0.21%           0.63%
8 threads
       minor-faults     2,097,267       1,048,753       262,237         131,397         65,621          8,274
       times in seconds 55.173790028    54.591880790    54.824623287    54.802162211    54.969680503    54.790387715
       stddev for time  ( +-  0.78% )   ( +-  0.09% )   ( +-  0.08% )   ( +-  0.07% )   ( +-  0.28% )   ( +-  0.05% )
       %chg time to baseline            -1.05%          -0.63%          -0.67%          -0.36%          -0.69%
32 threads
       minor-faults     8,388,751       4,195,621       1,049,664       525,461         262,535         32,924
       times in seconds 60.431573046    60.669110744    60.485336388    60.697789706    60.077959564    60.588855032
       stddev for time  ( +-  0.44% )   ( +-  0.27% )   ( +-  0.46% )   ( +-  0.67% )   ( +-  0.31% )   ( +-  0.49% )
       %chg time to baseline            0.39%           0.08%           0.44%           -0.58%          0.25%
64 threads
       minor-faults     16,777,409      8,607,527       2,289,766       1,202,264       598,405         67,587
       times in seconds 96.932617720    100.675418760   102.109880836   103.881733383   102.580199555   105.751194041
       stddev for time  ( +-  1.39% )   ( +-  1.06% )   ( +-  0.99% )   ( +-  0.76% )   ( +-  1.65% )   ( +-  1.60% )
       %chg time to baseline            3.86%           5.34%           7.16%           5.82%           9.09%
128 threads
       minor-faults     33,554,705      17,375,375      4,682,462       2,337,245       1,179,007       134,819
       times in seconds 128.766704495   115.659225437   120.353046307   115.291871270   115.450886036   113.991902150
       stddev for time  ( +-  2.93% )   ( +-  0.30% )   ( +-  2.93% )   ( +-  1.24% )   ( +-  1.03% )   ( +-  0.70% )
       %chg time to baseline            -10.17%         -6.53%          -10.46%         -10.34%         -11.47%

Random access 1GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4               5               8
1 thread
       minor-faults     17,155          8,678           2,126           1,097           581             134
       times in seconds 51.904430523    51.658017987    51.919270792    51.560531738    52.354431597    51.976469502
       stddev for time  ( +-  3.19% )   ( +-  1.35% )   ( +-  1.56% )   ( +-  0.91% )   ( +-  1.70% )   ( +-  2.02% )
       %chg time to baseline            -0.47%          0.02%           -0.66%          0.86%           0.13%
8 threads
       minor-faults     131,844         70,705          17,457          8,505           4,251           598
       times in seconds 58.162813956    54.991706305    54.952675791    55.323057492    54.755587379    53.376722828
       stddev for time  ( +-  1.44% )   ( +-  0.69% )   ( +-  1.23% )   ( +-  2.78% )   ( +-  1.90% )   ( +-  2.91% )
       %chg time to baseline            -5.45%          -5.52%          -4.88%          -5.86%          -8.22%
32 threads
       minor-faults     524,437         270,760         67,069          33,414          16,641          2,204
       times in seconds 69.981777072    76.539570015    79.753578505    76.245943618    77.254258344    79.072596831
       stddev for time  ( +-  2.81% )   ( +-  1.95% )   ( +-  2.66% )   ( +-  0.99% )   ( +-  2.35% )   ( +-  3.22% )
       %chg time to baseline            9.37%           13.96%          8.95%           10.39%          12.98%
64 threads
       minor-faults     1,049,117       527,451         134,016         66,638          33,391          4,559
       times in seconds 108.024517536   117.575067996   115.322659914   111.943998437   115.049450815   119.218450840
       stddev for time  ( +-  2.40% )   ( +-  1.77% )   ( +-  1.19% )   ( +-  3.29% )   ( +-  2.32% )   ( +-  1.42% )
       %chg time to baseline            8.84%           6.75%           3.62%           6.5%            10.3%
128 threads
       minor-faults     2,097,440       1,054,360       267,042         133,328         66,532          8,652
       times in seconds 155.055861167   153.059625968   152.449492156   151.024005282   150.844647770   155.954366718
       stddev for time  ( +-  1.32% )   ( +-  1.14% )   ( +-  1.32% )   ( +-  0.81% )   ( +-  0.75% )   ( +-  0.72% )
       %chg time to baseline            -1.28%          -1.68%          -2.59%          -2.71%          0.57%

Incase of Kernel compilation, fault around order (fao) of 1 and 3 provides fast compilation time
when compared to a value of 4. On closer look, fao of 3 has higher agains. Incase of Sequential access
synthetic tests fao of 1 has higher gains and in Random access test, fao of 3 has marginal gains.
Going by compilation time, fao value of 3 is suggested in this patch for pseries platform.

Worst case scenario: we touch one page every 16M to demonstrate overhead.

Touch only one page in page table in 16GiB file
FAULT_AROUND_ORDER      Baseline        1               3               4               5               8
1 thread
       minor-faults     1,104           1,090           1,071           1,068           1,065           1,063
       times in seconds 0.006583298     0.008531502     0.019733795     0.036033763     0.062300553     0.406857086
       stddev for time  ( +-  2.79% )   ( +-  2.42% )   ( +-  3.47% )   ( +-  2.81% )   ( +-  2.01% )   ( +-  1.33% )
8 threads
       minor-faults     8,279           8,264           8,245           8,243           8,239           8,240
       times in seconds 0.044572398     0.057211811     0.107606306     0.205626815     0.381679120     2.647979955
       stddev for time  ( +-  1.95% )   ( +-  2.98% )   ( +-  1.74% )   ( +-  2.80% )   ( +-  2.01% )   ( +-  1.86% )
32 threads
       minor-faults     32,879          32,864          32,849          32,845          32,839          32,843
       times in seconds 0.197659343     0.218486087     0.445116407     0.694235883     1.296894038     9.127517045
       stddev for time  ( +-  3.05% )   ( +-  3.05% )   ( +-  4.33% )   ( +-  3.08% )   ( +-  3.75% )   ( +-  0.56% )
64 threads
       minor-faults     65,680          65,664          65,646          65,645          65,640          65,647
       times in seconds 0.455537304     0.489688780     0.866490093     1.427393118     2.379628982     17.059295051
       stddev for time  ( +-  4.01% )   ( +-  4.13% )   ( +-  2.92% )   ( +-  1.68% )   ( +-  1.79% )   ( +-  0.48% )
128 threads
       minor-faults     131,279         131,265         131,250         131,245         131,241         131,254
       times in seconds 1.026880651     1.095327536     1.721728274     2.808233068     4.662729948     31.732848290
       stddev for time  ( +-  6.85% )   ( +-  4.09% )   ( +-  1.71% )   ( +-  3.45% )   ( +-  2.40% )   ( +-  0.68% )

Signed-off-by: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
---
 arch/powerpc/platforms/pseries/setup.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/powerpc/platforms/pseries/setup.c b/arch/powerpc/platforms/pseries/setup.c
index 2db8cc6..c87e6b6 100644
--- a/arch/powerpc/platforms/pseries/setup.c
+++ b/arch/powerpc/platforms/pseries/setup.c
@@ -74,6 +74,8 @@ int CMO_SecPSP = -1;
 unsigned long CMO_PageSize = (ASM_CONST(1) << IOMMU_PAGE_SHIFT_4K);
 EXPORT_SYMBOL(CMO_PageSize);
 
+extern unsigned int fault_around_order;
+
 int fwnmi_active;  /* TRUE if an FWNMI handler is present */
 
 static struct device_node *pSeries_mpic_node;
@@ -465,6 +467,9 @@ static void __init pSeries_setup_arch(void)
 {
 	set_arch_panic_timeout(10, ARCH_PANIC_TIMEOUT);
 
+	/* Measured on a 4 socket Power7 system (128 Threads and 128GB memory) */
+	fault_around_order = 3;
+
 	/* Discover PIC type and setup ppc_md accordingly */
 	pseries_discover_pic();
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
