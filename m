Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id A06366B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 08:42:36 -0400 (EDT)
Date: Fri, 7 Sep 2012 13:42:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: MMTests 0.05
Message-ID: <20120907124232.GA11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>

MMTests 0.05 is a configurable test suite that runs a number of common
workloads of interest to MM developers. The biggest addition this time
around is separate extraction, compare and reporting scripts. This may
help people run their own analysis in another tool if they wish.

Changelog since V0.04
o Move driver and config scripts into their own directory
o Add bin/extract-mmtests.pl and bin/compare-mmtests.pl
o Remove references to Irish kernel.org mirror
o Small tidy up

At LSF/MM at some point a request was made that a series of tests
be identified that were of interest to MM developers and that could be
used for testing the Linux memory management subsystem. There is renewed
interest in some sort of general testing framework during discussions for
Kernel Summit 2012 so here is what I use.

http://www.csn.ul.ie/~mel/projects/mmtests/
http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.05-mmtests-0.01.tar.gz

There are a number of stock configurations stored in configs/.  For example
config-global-dhp__pagealloc-performance runs a number of tests that
may be able to identify performance regressions or gains in the page
allocator. Similarly there network and scheduler configs. There are also
more complex options. config-global-dhp__parallelio-memcachetest will run
memcachetest in the foreground while doing IO of different sizes in the
background to measure how much unrelated IO affects the throughput of an
in-memory database.

This release is also a little rough and the extraction scripts could
have been tidier but they were mostly written in an airport and for the
most part they work as advertised. I'll fix bugs as according as they are
brought to my attention.

The stats reporting still needs work because while some tests know how
to make a better estimate of mean by filtering outliers it is not being
handled consistently and the methodology needs work. I know filtering
statistics like this is a major flaw in the methodology but the decision
was made in this case in the interest of the benchmarks with unstable
results completing in a reasonable time.

Out of the box it should now do something useful so here is a demo of the
page fault microbenchmark. At the most recent memcg meeting I used this
benchmark to demonstrate how memory control groups have between 6% and 15%
overhead even when not in use. If someone is interested in reproducing
that I'll send on a patch that configures profiling so you can reproduce it.

# Download and "install"
mel@machina:~ > wget -q http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.05-mmtests-0.01.tar.gz
mel@machina:~ > tar -xf mmtests-0.05-mmtests-0.01.tar.gz 
mel@machina:~ > cd mmtests-0.05-mmtests-0.01/

# Run with the default "config" file. It runs a a page fault microbenchmark.
# There are some warnings displayed about root, some tests require root but
# this is not one of them specifically. It also wars about libnuma.h not
# being available but on this machine it doesn't matter
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./run-mmtests.sh test-run-1
Tuning the system for run: test-run-1 monitor: yes
Using default swap configuration
Swap configuration
Filename				Type		Size	Used	Priority
Configuring ftrace
mount: only root can do that
Skipping warmup run

/home/mel/mmtests-0.05-mmtests-0.01/shellpacks/common.sh: line 144: /sys/kernel/mm/transparent_hugepage/enabled: Permission denied
Starting monitors
Started monitor proc-vmstat gzip pid 8595,8597
Started monitor top gzip pid 8653,8655
Started monitor slabinfo gzip pid 8706,8708
Started monitor vmstat latency pid 6146 6149 8759 8762,8760
Started monitor iostat latency pid 8801,8802
Starting test pft
cat: /proc/sys/kernel/stack_tracer_enabled: No such file or directory
/home/mel/mmtests-0.05-mmtests-0.01/shellpacks/common.sh: line 137:
/sys/kernel/mm/transparent_hugepage/enabled: Permission denied
pft-install: Fetching from mirror http://mcp/~gormanm/pft/pft-0.12x.tar.gz/pft-0.12x.tar.gz
pft-install: Fetching from internet http://free.linux.hp.com/~lts/Tools/pft-0.12x.tar.gz
~/mmtests-0.05-mmtests-0.01/work/testdisk/sources/pft-0.12x-installed
~/mmtests-0.05-mmtests-0.01/work/testdisk/sources ~/mmtests-0.05-mmtests-0.01/work/log/pft
WARNING: PFT REQUIRES NUMA.H AND IT IS NOT AVAILABLE
WORKING AROUND, BUT MAY NOT BEHAVE AS EXPECTED
patching file Makefile
patching file numa_stubs.h
patching file pft.c
cc -std=gnu99 -pthread -O3  -D_GNU_SOURCE -DUSE_RUSAGE_THREAD -UUSE_NOCLEAR     -c -o pft.o pft.c
cc -o pft -std=gnu99   pft.o  -lpthread -lrt
pft installed successfully
   1    1   1     0.07s     0.59s     0.65s  622936.989 620037.781
   1    1   1     0.08s     0.50s     0.58s  699060.613 695857.289
   1    1   1     0.06s     0.52s     0.58s  701475.702 697679.908
   1    1   1     0.07s     0.51s     0.58s  702689.514 699572.271
   1    1   1     0.04s     0.51s     0.55s  737121.449 733980.458
[ ..... test run continues ......]

# In a normal situation you would probably install a different kernel as
# part of some comparison and run the test again. Here we'll just run
# it a second time.
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./run-mmtests.sh test-run-2
[ ..... test runs a second time .....]

# Extract the raw results from the test
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./bin/extract-mmtests.pl -d work/log -b pft -n test-run-1 --print-header
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1           0.07        0.59        0.65        622936.989  620037.781  
1           0.08        0.50        0.58        699060.613  695857.289  
1           0.06        0.52        0.58        701475.702  697679.908  
1           0.07        0.51        0.58        702689.514  699572.271  
1           0.04        0.51        0.55        737121.449  733980.458  
[ .... raw results for each sample taken is displayed .... ]

# Print a summary of the results. For this test, a summary shows the
# mean of each sample taken. Other tests summarise differently
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./bin/extract-mmtests.pl -d work/log -b pft -n test-run-1 --print-header --print-summary
Clients User        System      Elapsed     Faults/cpu  Faults/sec  
1       0.06        0.52        0.58        705602.805  702256.189  
2       0.08        0.70        0.40        524681.533  1028256.231 
3       0.09        0.91        0.36        404728.859  1137961.182 
4       0.10        0.97        0.30        382681.532  1371008.438 
5       0.10        1.01        0.25        367927.082  1649637.507 
6       0.10        1.10        0.22        337179.610  1832504.839 
7       0.11        1.25        0.21        299583.769  1966789.329 
8       0.11        1.37        0.21        273358.740  1956777.078 

# Compare test-run-1 and test-run-2. The results are unstable because this
# is running on my laptop which was also doing other work at the time.
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./bin/compare-mmtests.pl -d work/log/ -b pft -n test-run-1,test-run-2
                              test                  test
                             run-1                 run-2
User       1      0.0610 (  0.00%)      0.0600 (  1.64%)
User       2      0.0785 (  0.00%)      0.0645 ( 17.83%)
User       3      0.0920 (  0.00%)      0.0830 (  9.78%)
User       4      0.0960 (  0.00%)      0.0930 (  3.12%)
User       5      0.0975 (  0.00%)      0.0955 (  2.05%)
User       6      0.0995 (  0.00%)      0.1040 ( -4.52%)
User       7      0.1050 (  0.00%)      0.1095 ( -4.29%)
User       8      0.1100 (  0.00%)      0.1130 ( -2.73%)
System     1      0.5160 (  0.00%)      0.4780 (  7.36%)
System     2      0.7000 (  0.00%)      0.5985 ( 14.50%)
System     3      0.9125 (  0.00%)      0.7345 ( 19.51%)
System     4      0.9660 (  0.00%)      0.8525 ( 11.75%)
System     5      1.0085 (  0.00%)      0.9680 (  4.02%)
System     6      1.1030 (  0.00%)      1.1125 ( -0.86%)
System     7      1.2500 (  0.00%)      1.2460 (  0.32%)
System     8      1.3745 (  0.00%)      1.3645 (  0.73%)
Elapsed    1      0.5815 (  0.00%)      0.5395 (  7.22%)
Elapsed    2      0.3990 (  0.00%)      0.3355 ( 15.91%)
Elapsed    3      0.3585 (  0.00%)      0.2740 ( 23.57%)
Elapsed    4      0.2975 (  0.00%)      0.2470 ( 16.97%)
Elapsed    5      0.2455 (  0.00%)      0.2410 (  1.83%)
Elapsed    6      0.2215 (  0.00%)      0.2225 ( -0.45%)
Elapsed    7      0.2065 (  0.00%)      0.2060 (  0.24%)
Elapsed    8      0.2075 (  0.00%)      0.2105 ( -1.45%)
Faults/cpu 1 705602.8052 (  0.00%) 756530.8582 (  7.22%)
Faults/cpu 2 524681.5331 (  0.00%) 612777.6817 ( 16.79%)
Faults/cpu 3 404728.8590 (  0.00%) 495572.8665 ( 22.45%)
Faults/cpu 4 382681.5322 (  0.00%) 429694.5717 ( 12.29%)
Faults/cpu 5 367927.0821 (  0.00%) 381027.2533 (  3.56%)
Faults/cpu 6 337179.6097 (  0.00%) 333885.0524 ( -0.98%)
Faults/cpu 7 299583.7693 (  0.00%) 299253.1277 ( -0.11%)
Faults/cpu 8 273358.7403 (  0.00%) 274967.2918 (  0.59%)
Faults/sec 1 702256.1889 (  0.00%) 752642.3956 (  7.17%)
Faults/sec 21028256.2315 (  0.00%)1213980.6263 ( 18.06%)
Faults/sec 31137961.1816 (  0.00%)1471511.1024 ( 29.31%)
Faults/sec 41371008.4380 (  0.00%)1651793.2132 ( 20.48%)
Faults/sec 51649637.5069 (  0.00%)1685023.2429 (  2.15%)
Faults/sec 61832504.8389 (  0.00%)1828275.9043 ( -0.23%)
Faults/sec 71966789.3289 (  0.00%)1970410.1478 (  0.18%)
Faults/sec 81956777.0777 (  0.00%)1930608.9724 ( -1.34%)

# Compare the running times
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./bin/compare-mmtests.pl -d work/log/ -b pft -n test-run-1,test-run-2 --print-monitor duration
                test        test
               run-1       run-2
User           15.52       14.83
System        196.24      184.81
Elapsed        69.88       61.51

# Compare vmstat information
mel@machina:~/mmtests-0.05-mmtests-0.01 > ./bin/compare-mmtests.pl -d work/log/ -b pft -n test-run-1,test-run-2 --print-monitor vmstat
                               test        test
                              run-1       run-2
Page Ins                       4440           0
Page Outs                     34876        4440
Swap Ins                          0           0
Swap Outs                         0           0
Direct pages scanned              0           0
Kswapd pages scanned         199986           0
Kswapd pages reclaimed       199981           0
Direct pages reclaimed            0           0
Kswapd efficiency               99%        100%
Kswapd velocity            2861.849       0.000
Direct efficiency              100%        100%
Direct velocity               0.000       0.000
Percentage direct scans          0%          0%
Page writes by reclaim            0           0
Page writes file                  0           0
Page writes anon                  0           0
Page reclaim immediate            0           0
Page rescued immediate            0           0
Slabs scanned                145408           0
Direct inode steals               0           0
Kswapd inode steals           33392           0
Kswapd skipped wait               0           0
THP fault alloc                   0           0
THP collapse alloc                0           0
THP splits                        0           0
THP fault fallback                0           0
THP collapse fail                 0           0
Compaction stalls                 0           0
Compaction success                0           0
Compaction failures               0           0
Compaction pages moved            0           0
Compaction move failure           0           0

Feedback welcome.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
