From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16994.40448.409740.477339@gargle.gargle.HOWL>
Date: Sun, 17 Apr 2005 21:33:52 +0400
Subject: [PATCH]: VM 0/8 pageout fixes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <AKPM@Osdl.ORG>
List-ID: <linux-mm.kvack.org>

Hello, dear SCM developers,

this message preambles a series of patches that:

 - try to improve performance of pageout from tail of the inactive list, and

 - cleanup some VM code.

This is mostly resend of patches already presented on linux-mm and/or lkml at
various times in the past.

Patches are against 2.6.12-rc2. Note: they are not part of and bear no
relation to Lustre.

vm_01-zoneinfo
vm_02-rmap-cleanup
vm_03-skip-writepage
vm_04-dont-rotate-active-list
vm_05-async-writepage
vm_06-page_referenced-move-dirty
vm_07-cluster-pageout
vm_08-SetPageReclaimed-inactive-tail

Below are micro-benchmarking results. Benchmark's pseudo-code, where N and M
are parameters:

        unlink("file");
        fd = open("file", O_CREAT);
        ftruncate(fd, N * GB);
        for (i = 0; i < M; ++ i) {
                for (j = 0; j < N; ++ j) {
                     t0 = time(0);
                     mmap j-th gigabyte of fd;
                     dirty each page in the mmapped region;
                     unmap;
                     print time(0) - t0;
                }
        }

Results for N = 1, M = 8. First column is vanilla kernel, further columns
correspond to patches applied one after another (cleanup patches vm_01 and
vm_02 skipped). Numbers are seconds it took to dirty 1GB. Tests were run with
mem=64m.

2.6.12-rc2:     03    04    05    06    07    08

      70.8    48.4  45.4  45.8  32.3  27.9  28.9
     304.6   269.5 214.4 204.3  93.2  86.0  86.2
     303.5   266.4 199.1 194.8  89.5  85.1  87.7
     307.8   260.0 208.3 194.9  89.9  86.2  85.8
     306.6   268.3 199.5 197.7  92.1  87.1  88.6
     305.3   268.3 206.8 195.0  90.2  84.6  87.2
     305.3   266.6 200.8 199.4  89.5  85.7  87.6
     307.0   271.6 204.7 196.3  89.2  84.6  88.8

File is created at the beginning of this test, so that first iteration always
writes into hole. Block allocation is done during page-out.

Repeating whole test gives no significant variation.

I also tested that patches do not introduce performance regression under
"normal" workload (i.e., when little or no IO is done from VM scanner).

Results for make CC='ccache cc' -j4 bzImage with prefilled ccache cache (after
make allnoconfig):

2.6.12-rc2:     03    04    05    06    07    08
      21.3    21.5  21.3  21.2  21.3  21.3  21.2 elapsed time, seconds.
       0.4     0.3   0.4   0.2   0.5   0.4   0.4 std. deviation over 10 runs

OSDL/STP tests (dbt1-1tier, contest, db3-pgsql, and iozone) also didn't
register regression.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
