Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A00306B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 13:39:08 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so15657529pad.11
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 10:39:08 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bp2si15620619pab.272.2014.02.17.10.39.07
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 10:39:07 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv2 0/2] mm: map few pages around fault address if they are in page cache
Date: Mon, 17 Feb 2014 20:38:51 +0200
Message-Id: <1392662333-25470-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

I've rewrote it from scratch since v1. Locking multiple pages at once was
not that great idea. lock_page() is mess. It seems we don't have good
locking ordering rules for lock_page() vs. lock_page() and it triggers
deadlocks.

Now we have ->fault_nonblock() to ask filesystem for a page, if it's
reachable without blocking. We request one page a time. It's not terribly
efficient and I will probably re-think the interface once again to expose
iterator or something...

Synthetic tests shows pretty impressive numbers: time to complete is
reduced by 80% on sequential multi-threaded access to a file.

Unfortunately, scripting use-case doesn't show any change. I've tried git
test-suite, kernel build and kernel rebuild: no significant difference.

I will try reduce FAULT_AROUND_PAGES to see if it makes any difference.

One important use-case which is not covered is shmem/tmpfs: we need to
implement separate ->fault_nonblock() for it.

Yet another feature to implement is MAP_POPULATE|MAP_NONBLOCK on top of
->fault_nonblock(). It should be useful for dynamic linker for example.

Benchmark data is below.

Any comments?

=========================================================================

Git test-suite make -j60 test:

Base:
 1,529,278,935,718      cycles                     ( +-  0.23% ) [100.00%]
   799,283,349,594      instructions              #    0.52  insns per cycle
                                                  #    3.14  stalled cycles per insn  ( +-  0.12% ) [100.00%]
 2,509,889,276,415      stalled-cycles-frontend   #  164.12% frontend cycles idle     ( +-  0.18% )
       115,493,976      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 1      major-faults

      59.686645587 seconds time elapsed                                          ( +-  0.30% )
Patched:
 1,613,998,434,527      cycles                     ( +-  0.24% ) [100.00%]
   865,776,308,589      instructions              #    0.54  insns per cycle
                                                  #    3.07  stalled cycles per insn  ( +-  0.18% ) [100.00%]
 2,661,812,494,310      stalled-cycles-frontend   #  164.92% frontend cycles idle     ( +-  0.17% )
        47,428,068      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 1      major-faults                                                  ( +- 50.00% )

      60.241766430 seconds time elapsed                                          ( +-  0.85% )

Run make -j60 on clean allmodconfig kernel tree:

Base:
19,511,808,321,876      cycles                    [100.00%]
17,551,075,994,147      instructions              #    0.90  insns per cycle
                                                  #    1.55  stalled cycles per insn [100.00%]
27,227,785,020,522      stalled-cycles-frontend   #  139.55% frontend cycles idle
       268,039,365      minor-faults                                                 [100.00%]
                 0      major-faults

     132.830612471 seconds time elapsed
Patched:
19,421,069,663,037      cycles                    [100.00%]
17,587,643,648,161      instructions              #    0.91  insns per cycle
                                                  #    1.54  stalled cycles per insn [100.00%]
27,063,152,011,598      stalled-cycles-frontend   #  139.35% frontend cycles idle
       193,550,437      minor-faults                                                 [100.00%]
                 0      major-faults

     132.851823758 seconds time elapsed

Run make -j60 on already built allmodconfig kernel tree:

Base:
   286,539,116,594      cycles                     ( +-  0.05% ) [100.00%]
   386,447,067,412      instructions              #    1.35  insns per cycle
                                                  #    0.96  stalled cycles per insn  ( +-  0.00% ) [100.00%]
   372,549,722,846      stalled-cycles-frontend   #  130.02% frontend cycles idle     ( +-  0.04% )
         4,967,540      minor-faults                                                  ( +-  0.06% ) [100.00%]
                 0      major-faults

      27.215434226 seconds time elapsed                                          ( +-  0.18% )
Patched:
   286,435,472,207      cycles                     ( +-  0.07% ) [100.00%]
   388,217,937,147      instructions              #    1.36  insns per cycle
                                                  #    0.96  stalled cycles per insn  ( +-  0.01% ) [100.00%]
   373,681,951,018      stalled-cycles-frontend   #  130.46% frontend cycles idle     ( +-  0.10% )
         2,285,563      minor-faults                                                  ( +-  0.26% ) [100.00%]
                 0      major-faults

      27.292854546 seconds time elapsed                                          ( +-  0.29% )

Access 16g file sequential:

Threads		Base, seconds	Patched, seconds	Diff, %
1		8.284232583	5.424205564		-34,52
8		18.338648302	6.330400940		-65.48
32		54.004043136	10.774241948		-80.04
60		88.928810991	16.571960471		-81.36
120		144.729413453	28.875873029		-80.04

Access 1g file random:

Threads		Base, seconds	Patched, seconds	Diff, %
1		18.247095738	15.003616508		-17.77
8		15.226716773	14.239478275		-6.48
32		22.080582106	16.797777162		-23.92
60		25.759900660	22.768611526		-11.61
120		44.443953873	38.197095497		-14.05

Below is `perf stat' output for the tests above.

=========================================================================

# usemem -t <threads> -f testfile -o 16g #

## 1 thread ##
### base ###
   28,284,111,426      cycles                     ( +-  1.53% ) [100.00%]
    44,120,803,329      instructions              #    1.56  insns per cycle
                                                  #    1.02  stalled cycles per insn  ( +-  0.00% ) [100.00%]
    45,148,666,958      stalled-cycles-frontend   #  159.63% frontend cycles idle     ( +-  1.89% )
         4,194,709      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

       8.284232583 seconds time elapsed                                          ( +-  1.67% )
### patched ###
    18,615,784,628      cycles                     ( +-  8.46% ) [100.00%]
    41,590,187,000      instructions              #    2.23  insns per cycle
                                                  #    0.66  stalled cycles per insn  ( +-  0.02% ) [100.00%]
    27,374,671,499      stalled-cycles-frontend   #  147.05% frontend cycles idle     ( +- 11.48% )
           131,260      minor-faults                                                  ( +-  0.03% ) [100.00%]
                 0      major-faults

       5.424205564 seconds time elapsed                                          ( +-  8.54% )

## 8 threads ##
### base ###
   447,114,910,645      cycles                     ( +-  3.22% ) [100.00%]
   350,993,124,470      instructions              #    0.79  insns per cycle
                                                  #    2.29  stalled cycles per insn  ( +-  0.01% ) [100.00%]
   803,040,468,490      stalled-cycles-frontend   #  179.60% frontend cycles idle     ( +-  3.59% )
        33,556,008      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      18.338648302 seconds time elapsed                                          ( +-  3.20% )
### patched ###
   136,437,995,805      cycles                     ( +-  0.87% ) [100.00%]
   328,096,731,149      instructions              #    2.40  insns per cycle
                                                  #    0.60  stalled cycles per insn  ( +-  0.02% ) [100.00%]
   197,237,317,698      stalled-cycles-frontend   #  144.56% frontend cycles idle     ( +-  1.19% )
         1,338,884      minor-faults                                                  ( +-  3.11% ) [100.00%]
                 0      major-faults

       6.330400940 seconds time elapsed                                          ( +-  1.50% )

## 32 threads ##
### base ###
 4,844,333,104,028      cycles                     ( +-  2.17% ) [100.00%]
 1,401,233,609,645      instructions              #    0.29  insns per cycle
                                                  #    6.61  stalled cycles per insn  ( +-  0.02% ) [100.00%]
 9,265,429,354,789      stalled-cycles-frontend   #  191.26% frontend cycles idle     ( +-  1.81% )
       134,228,040      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      54.004043136 seconds time elapsed                                          ( +-  2.03% )
### patched ###
   512,226,985,443      cycles                     ( +-  2.21% ) [100.00%]
 1,307,350,894,141      instructions              #    2.55  insns per cycle
                                                  #    0.52  stalled cycles per insn  ( +-  0.02% ) [100.00%]
   677,259,628,341      stalled-cycles-frontend   #  132.22% frontend cycles idle     ( +-  1.56% )
         4,820,979      minor-faults                                                  ( +-  3.88% ) [100.00%]
                 0      major-faults

      10.774241948 seconds time elapsed                                          ( +-  2.40% )
## 60 threads ##
### base ###
14,878,749,780,310      cycles                     ( +-  1.24% ) [100.00%]
 2,633,166,794,060      instructions              #    0.18  insns per cycle
                                                  #   10.75  stalled cycles per insn  ( +-  0.01% ) [100.00%]
28,301,405,498,867      stalled-cycles-frontend   #  190.21% frontend cycles idle     ( +-  0.88% )
       251,687,643      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      88.928810991 seconds time elapsed                                          ( +-  1.44% )
### patched ###
 1,156,172,977,262      cycles                     ( +-  3.24% ) [100.00%]
 2,450,915,465,588      instructions              #    2.12  insns per cycle
                                                  #    0.63  stalled cycles per insn  ( +-  0.01% ) [100.00%]
 1,534,996,614,819      stalled-cycles-frontend   #  132.77% frontend cycles idle     ( +-  4.37% )
         9,239,706      minor-faults                                                  ( +-  1.66% ) [100.00%]
                 0      major-faults

      16.571960471 seconds time elapsed                                          ( +-  2.64% )
## 120 threads ##
### base ###
47,350,885,336,341      cycles                     ( +-  2.28% ) [100.00%]
 5,282,921,722,672      instructions              #    0.11  insns per cycle
                                                  #    8.96  stalled cycles per insn  ( +-  0.04% ) [100.00%]
47,332,933,971,860      stalled-cycles-frontend   #   99.96% frontend cycles idle     ( +-  2.40% )
       503,357,749      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

     144.729413453 seconds time elapsed                                          ( +-  1.75% )
### patched ###
 3,791,855,572,557      cycles                     ( +-  2.15% ) [100.00%]
 4,901,681,561,338      instructions              #    1.29  insns per cycle
                                                  #    0.59  stalled cycles per insn  ( +-  0.01% ) [100.00%]
 2,880,236,854,539      stalled-cycles-frontend   #   75.96% frontend cycles idle     ( +-  3.69% )
        18,080,707      minor-faults                                                  ( +-  1.22% ) [100.00%]
                 0      major-faults

      28.875873029 seconds time elapsed                                          ( +-  1.19% )

# usemem -t <threads> -R -f testfile -o 1g #

## 1 thread ##
### base ###
    62,357,670,556      cycles                     ( +-  0.58% ) [100.00%]
    11,612,293,315      instructions              #    0.19  insns per cycle
                                                  #   10.31  stalled cycles per insn  ( +-  0.03% ) [100.00%]
   119,734,125,613      stalled-cycles-frontend   #  192.01% frontend cycles idle     ( +-  0.58% )
           262,723      minor-faults                                                  ( +-  0.01% ) [100.00%]
                 0      major-faults

      18.247095738 seconds time elapsed                                          ( +-  0.58% )
### patched ###
    51,421,735,331      cycles                     ( +- 11.53% ) [100.00%]
    11,446,081,379      instructions              #    0.22  insns per cycle
                                                  #    8.55  stalled cycles per insn  ( +-  0.19% ) [100.00%]
    97,900,718,100      stalled-cycles-frontend   #  190.39% frontend cycles idle     ( +- 12.09% )
             8,629      minor-faults                                                  ( +-  1.20% ) [100.00%]
                 0      major-faults                                                  ( +-100.00% )

      15.003616508 seconds time elapsed                                          ( +- 11.56% )

## 8 threads ##
### base ###
   395,785,250,840      cycles                     ( +-  0.60% ) [100.00%]
    93,850,278,507      instructions              #    0.24  insns per cycle
                                                  #    8.02  stalled cycles per insn  ( +-  0.03% ) [100.00%]
   752,951,585,171      stalled-cycles-frontend   #  190.24% frontend cycles idle     ( +-  0.61% )
         2,097,988      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      15.226716773 seconds time elapsed                                          ( +-  0.41% )
### patched ###
 Performance counter stats for 'system wide' (5 runs):

   369,032,514,042      cycles                     ( +-  0.42% ) [100.00%]
    92,357,503,760      instructions              #    0.25  insns per cycle
                                                  #    7.59  stalled cycles per insn  ( +-  0.01% ) [100.00%]
   700,555,940,601      stalled-cycles-frontend   #  189.84% frontend cycles idle     ( +-  0.44% )
            89,186      minor-faults                                                  ( +-  1.88% ) [100.00%]
                 0      major-faults

      14.239478275 seconds time elapsed                                          ( +-  0.48% )

## 32 threads ##
### base ###
 1,791,516,702,606      cycles                     ( +-  1.57% ) [100.00%]
   369,936,392,907      instructions              #    0.21  insns per cycle
                                                  #    9.07  stalled cycles per insn  ( +-  0.07% ) [100.00%]
 3,357,017,162,189      stalled-cycles-frontend   #  187.38% frontend cycles idle     ( +-  1.77% )
         8,390,395      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      22.080582106 seconds time elapsed                                          ( +-  9.50% )
### patched ###
 1,517,335,667,819      cycles                     ( +-  0.63% ) [100.00%]
   363,401,817,392      instructions              #    0.24  insns per cycle
                                                  #    7.45  stalled cycles per insn  ( +-  0.01% ) [100.00%]
 2,705,627,050,641      stalled-cycles-frontend   #  178.31% frontend cycles idle     ( +-  1.15% )
           269,287      minor-faults                                                  ( +-  0.16% ) [100.00%]
                 0      major-faults

      16.797777162 seconds time elapsed                                          ( +-  7.69% )

## 60 threads ##
### base ###
 3,983,862,013,747      cycles                     ( +-  1.42% ) [100.00%]
   693,310,458,766      instructions              #    0.17  insns per cycle
                                                  #   10.75  stalled cycles per insn  ( +-  0.01% ) [100.00%]
 7,454,138,580,163      stalled-cycles-frontend   #  187.11% frontend cycles idle     ( +-  1.27% )
        15,735,826      minor-faults                                                  ( +-  0.02% ) [100.00%]
                 1      major-faults                                                  ( +-100.00% )

      25.759900660 seconds time elapsed                                          ( +-  0.64% )
### patched ###
 2,871,988,372,901      cycles                     ( +-  1.17% ) [100.00%]
   681,452,765,745      instructions              #    0.24  insns per cycle
                                                  #    7.61  stalled cycles per insn  ( +-  0.03% ) [100.00%]
 5,186,017,674,808      stalled-cycles-frontend   #  180.57% frontend cycles idle     ( +-  1.24% )
           498,198      minor-faults                                                  ( +-  0.05% ) [100.00%]
                 0      major-faults

      22.768611526 seconds time elapsed                                          ( +-  3.13% )

## 120 threads ##
### base ###
14,891,491,866,813      cycles                     ( +-  0.83% ) [100.00%]
 1,391,880,325,881      instructions              #    0.09  insns per cycle
                                                  #   10.51  stalled cycles per insn  ( +-  0.02% ) [100.00%]
14,629,621,106,104      stalled-cycles-frontend   #   98.24% frontend cycles idle     ( +-  1.04% )
        31,468,057      minor-faults                                                  ( +-  0.00% ) [100.00%]
                 0      major-faults

      44.443953873 seconds time elapsed                                          ( +-  0.91% )
### patched ###
12,450,645,304,818      cycles                     ( +-  2.94% ) [100.00%]
 1,367,989,003,638      instructions              #    0.11  insns per cycle
                                                  #    8.98  stalled cycles per insn  ( +-  0.04% ) [100.00%]
12,282,274,614,247      stalled-cycles-frontend   #   98.65% frontend cycles idle     ( +-  3.34% )
           996,361      minor-faults                                                  ( +-  0.02% ) [100.00%]
                 0      major-faults

      38.197095497 seconds time elapsed                                          ( +-  2.

Kirill A. Shutemov (2):
  mm: introduce vm_ops->fault_nonblock()
  mm: implement ->fault_nonblock() for page cache

 Documentation/filesystems/Locking |  8 ++++++++
 fs/9p/vfs_file.c                  |  2 ++
 fs/btrfs/file.c                   |  1 +
 fs/cifs/file.c                    |  1 +
 fs/ext4/file.c                    |  1 +
 fs/f2fs/file.c                    |  1 +
 fs/fuse/file.c                    |  1 +
 fs/gfs2/file.c                    |  1 +
 fs/nfs/file.c                     |  1 +
 fs/nilfs2/file.c                  |  1 +
 fs/ubifs/file.c                   |  1 +
 fs/xfs/xfs_file.c                 |  1 +
 include/linux/mm.h                |  3 +++
 mm/filemap.c                      | 35 +++++++++++++++++++++++++++++++++++
 mm/memory.c                       | 38 +++++++++++++++++++++++++++++++++++++-
 15 files changed, 95 insertions(+), 1 deletion(-)

-- 
1.9.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
