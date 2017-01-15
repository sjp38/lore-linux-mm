Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 431446B0033
	for <linux-mm@kvack.org>; Sun, 15 Jan 2017 05:28:03 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id y196so112650632ity.1
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 02:28:03 -0800 (PST)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id p139si12118774iop.237.2017.01.15.02.28.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jan 2017 02:28:02 -0800 (PST)
Received: by mail-io0-x22e.google.com with SMTP id l66so73957405ioi.1
        for <linux-mm@kvack.org>; Sun, 15 Jan 2017 02:28:02 -0800 (PST)
MIME-Version: 1.0
From: Bamvor Zhang Jian <bamvor.zhangjian@linaro.org>
Date: Sun, 15 Jan 2017 18:28:01 +0800
Message-ID: <CAFy1USSdqRMJ2X5MNc3OUOEcGVy-_EMdB=qqOdA=fSASR8Oiew@mail.gmail.com>
Subject: [LSF/MM TOPIC][LSF/MM ATTEND] Implement contiguous page hint for
 anonymous page in user space
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoffer Dall <christoffer.dall@linaro.org>, labbott@redhat.com, mgorman@suse.de, Marc Zyngier <marc.zyngier@arm.com>, lizefan@huawei.com

    Contiguous page hint is a feature in arm/arm64 which could
decrease the tlb miss and improve the performance by sharing a single
TLB entry across 16 4k pages whenever the pages are also physically
contiguous. Currently, it is only used in hugetlb which limited the
scenario. This proposal want to discuss the possibility and design for
implementing contiguous page hint in anonymous page in user space.
There are already some off-list discussion on two aspects: how much
performance gain we could get; how to implement it in a simple way.

    Hope could discuss the following items in lsf/mm:
    1.  Discuss the my current idea and/or prototype(I am actively
working on the prototype, hope could get a work prototype with
performance result before lsf).
        Allocate 64k(with GFP_NOWAIT to avoid evict any other pages)
during pte fault, where we have already handled the possible
transparent hugepage. Immediately split it up into 4k pages and only
add one page at this time. Once the fault happens again in the same
contiguous area, add all the remaining 15 pages and set the contiguous
page hint. We will track the 64k pages in mm_struct.
        We will split the 64k page in mprotect, mremap, munmap, LRU
handling and any other point similar to transparent hugepage.

    2.  Analysis the reason of performance result of specint in mix
with 4k/64k page size, transparent hugepage(THP) and hugetlb.
        2.1 The following test result is compare with 4k page with THP
with or without hugetlb through libhugetlbfs and hugectl. In this
test, hugepage is allocated before THP, while in our idea, the
contiguous page hint will be allocated after THP. Allocate 64k
hugepage before THP could break the 2M THP. So we could see that the
overall performance improvement of 2048k hugetlb is better than 64k
hugetlb.
        With the performance monitor unit in arm cpu, we could see the
positive correlation between tlb miss and performance improvement.
        We also notice xalancbmk downgrade in both 64k and 2048k
hugetlb. This is very interesting thing I plan to investigate and
discuss it in lsf.
        The following test results come from Cortex-A57 which is a
classic high performance CPU in arm64. It support larger tlb than low
power CPU(such as Cortex-A53). I would expect the more improvement in
low power CPU.

                      64k hugetlb 2048k hugetlb
           401.bzip2:       2.33%         3.18%
             403.gcc:       0.13%         0.64%
             429.mcf:      -0.22%         0.77%
           445.gobmk:       0.00%         0.88%
           456.hmmer:       5.96%         5.30%
           458.sjeng:      -1.87%         0.00%
      462.libquantum:       3.73%         4.35%
         471.omnetpp:      -2.66%         0.89%
           473.astar:       2.19%         4.37%
       483.xalancbmk:      -4.10%        -2.46%

       2.2  In our another test, we found that there are some
downgrade of 64k compare with 4k with or without THP. I think it show
that there is some shortage of 64k of base page size, and we need to
find a better way to improve the overall performance instead of
increasing the base page size. As several distributions are already
using 64k base pages, moving them to 4k pages with the continuous page
hint should drastically improve performance in cases that are
currently limited on the amount of memory, but ideally also keep the
better performance in benchmarks that are limited by TLB misses.

                            4k with transtlb      64k(transtlb
disable)  64k with transtlb  Mark
             400.perlbench:  1.59%                  2.38%
      2.38%
                 401.bzip2:  0.53%                  2.88%
      3.21%
                   403.gcc:  1.58%                  3.16%
      3.29%
                   429.mcf: 19.65%                 17.26%
      18.33%
                 445.gobmk:  0.88%                  1.77%
      1.77%
                 456.hmmer:  0.00%                -39.61%
     -40.33%          ---
                 458.sjeng:  2.88%                  3.85%
      1.92%
            462.libquantum:  5.88%                  9.80%
      14.38%          ++
               471.omnetpp: 12.54%                 13.04%
      12.04%
                 473.astar:  8.59%                 10.59%
      9.76%
             483.xalancbmk:  8.11%                  5.41%
      6.31%           -

    3.  Discuss the potential solution for mobile world. Android is
usually base on 4k page and disable THP and hugetlb to save high order
memories and total memories. Our idea of contiguous page hint could be
a better balance for mobile or other limited memory scenario.

Regards

Bamvor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
