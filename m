Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3934A6B0121
	for <linux-mm@kvack.org>; Wed, 13 Oct 2010 10:15:13 -0400 (EDT)
Date: Wed, 13 Oct 2010 15:14:55 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
Message-ID: <20101013141455.GQ30667@csn.ul.ie>
References: <20101005185725.088808842@linux.com> <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com> <alpine.DEB.2.00.1010061054410.31538@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010061054410.31538@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Oct 06, 2010 at 10:56:47AM -0500, Christoph Lameter wrote:
> On Wed, 6 Oct 2010, Pekka Enberg wrote:
> 
> > Are there any stability problems left? Have you tried other benchmarks
> > (e.g. hackbench, sysbench)? Can we merge the series in smaller
> > batches? For example, if we leave out the NUMA parts in the first
> > stage, do we expect to see performance regressions?
> 
> I have tried hackbench but the number seem to be unstable on my system.
> There may be various small optimizations still left to be done.
> 

I still haven't reviewed this and I confess it will be some time before I
get the chance but I sent them towards some testing automation and have the
results from one machine below.

Minimally, I see the same sort of hackbench socket performance regression
as reported elsewhere (10-15% regression). Otherwise, it isn't particularly
exciting results. The machine is very basic - 2 socket, 4 cores, x86-64,
2G RAM. Macine model is an IBM BladeCenter HS20. Processor is Xeon but I'm
not sure exact what model. It appears to be from around the P4 times.

Tests were based on three kernels. I used this tarball of scripts
http://www.csn.ul.ie/~mel/projects/mmtests/mmtests-0.01-slabunified-0.01.tar.gz
. The scripts have been pulled from all over the place with varying quality
so try not cry too much if you look at scripts closely :)

This tarball is capable of multiple different types of tests and was
implemented in response to LSF/MM people asking for a suite to MM tests
"of interest". I don't think a single suite is possible without taking a
week to run a test but what is possible is to configure a bunch of tests to
answer questions about a particular series (the tarball is capable of starting
monitoring, profiling and running analysis after the fact to answer questions
related to my own recent patch series). In this case, it's configured to
run a number of benchmarks known to be sensitive to slab and page allocator
performance. Roughly speaking, to test allocators the following happens

1. Configure 2.6.36-rc7 for SLAB, no other patches, build + boot
2. ./run-slabunified.sh slab-vanilla
3. Configure 2.6.36-rc7 for SLUB, no other patches, build + boot
4. ./run-slabunified.sh slub-vanilla
5. Configure 2.6.36-rc7 for SLUB, for-next and Christophs patches
   applied, build + boot
6. ./run-slabunified.sh unified-v4r1 (version 4 of patches, release
   candidate 1)
7. cd work/log
8. ../../compare-kernels.sh

This should be enough to run a cross-section of tests against this
series.

Christoph, in particular while it tests netperf, it is not binding to any
particular CPU (although it can), server and client are running on the local
machine (which has particular performance characterisitcs of its own) and
the tests is STREAM, not RR so the tarball is not a replacement for more
targetting testing or workload-specific testing. Still, it should catch
some of the common snags before getting into specific workloads without
taking an extraordinary amount of time to complete. sysbench might take a
long time for many-core machines, limit the number of threads it tests with
OLTP_MAX_THREADS in the config file.

I'm not going to go into details of how the scripts work - it's as-is
only. That said, most test parameters are specified in the top-level
config file with somewhat self-explanatory names and there is a basic
README.

KERNBENCH
            kernbench-slab-vanilla-kernbenchkernbench-slub-vanilla-kernbench    kernbench-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
Elapsed min      382.95 ( 0.00%)   383.44 (-0.13%)   385.36 (-0.63%)
Elapsed mean     383.39 ( 0.00%)   383.61 (-0.06%)   386.07 (-0.70%)
Elapsed stddev     0.32 ( 0.00%)     0.20 (64.11%)     0.76 (-57.53%)
Elapsed max      383.94 ( 0.00%)   383.97 (-0.01%)   387.17 (-0.83%)
User    min     1291.99 ( 0.00%)  1290.63 ( 0.11%)  1296.50 (-0.35%)
User    mean    1293.05 ( 0.00%)  1291.71 ( 0.10%)  1298.28 (-0.40%)
User    stddev     1.06 ( 0.00%)     0.97 ( 8.76%)     1.56 (-32.28%)
User    max     1295.01 ( 0.00%)  1293.10 ( 0.15%)  1301.16 (-0.47%)
System  min      164.46 ( 0.00%)   166.34 (-1.13%)   167.82 (-2.00%)
System  mean     165.50 ( 0.00%)   167.38 (-1.12%)   168.70 (-1.89%)
System  stddev     0.83 ( 0.00%)     0.67 (22.71%)     0.92 (-10.53%)
System  max      166.98 ( 0.00%)   168.17 (-0.71%)   170.29 (-1.94%)
CPU     min      379.00 ( 0.00%)   379.00 ( 0.00%)   378.00 ( 0.26%)
CPU     mean     379.80 ( 0.00%)   379.80 ( 0.00%)   379.40 ( 0.11%)
CPU     stddev     0.40 ( 0.00%)     0.40 ( 0.00%)     0.80 (-50.00%)
CPU     max      380.00 ( 0.00%)   380.00 ( 0.00%)   380.00 ( 0.00%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       8784.52   8788.55   8837.18
Total Elapsed Time (seconds)               2369.98   2361.80   2384.12

FS-Mark
            fsmark-slab-vanilla-fsmarkfsmark-slub-vanilla-fsmark       fsmark-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
Files/s  min         437.30 ( 0.00%)      437.80 ( 0.11%)      436.80 (-0.11%)
Files/s  mean        440.38 ( 0.00%)      440.36 (-0.00%)      440.68 ( 0.07%)
Files/s  stddev        1.79 ( 0.00%)        1.91 ( 6.06%)        2.95 (39.25%)
Files/s  max         442.60 ( 0.00%)      443.20 ( 0.14%)      445.90 ( 0.74%)
Overhead min     2851289.00 ( 0.00%)  2961679.00 (-3.73%)  2946715.00 (-3.24%)
Overhead mean    2964541.00 ( 0.00%)  3124801.80 (-5.13%)  3172446.40 (-6.55%)
Overhead stddev    64216.04 ( 0.00%)   115096.40 (-44.21%)   145393.19 (-55.83%)
Overhead max     3033464.00 ( 0.00%)  3269057.00 (-7.21%)  3386053.00 (-10.41%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2250.39   2246.04   2252.47
Total Elapsed Time (seconds)               1187.28   1184.36   1184.45

IOZone
            iozone-slab-vanilla-iozoneiozone-slub-vanilla-iozone       iozone-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
write-64               254006 ( 0.00%)       244297 (-3.97%)       246089 (-3.22%)
write-128              268327 ( 0.00%)       268327 ( 0.00%)       262296 (-2.30%)
write-256              277969 ( 0.00%)       275544 (-0.88%)       271777 (-2.28%)
write-512              276175 ( 0.00%)       272184 (-1.47%)       272460 (-1.36%)
write-1024             270893 ( 0.00%)       269838 (-0.39%)       264178 (-2.54%)
write-2048             263917 ( 0.00%)       264698 ( 0.30%)       258976 (-1.91%)
write-4096             261593 ( 0.00%)       261108 (-0.19%)       256141 (-2.13%)
write-8192             258725 ( 0.00%)       257950 (-0.30%)       253497 (-2.06%)
write-16384            256661 ( 0.00%)       256059 (-0.24%)       252683 (-1.57%)
write-32768            255359 ( 0.00%)       255866 ( 0.20%)       251637 (-1.48%)
write-65536            254740 ( 0.00%)       255058 ( 0.12%)       250648 (-1.63%)
write-131072           254432 ( 0.00%)       254863 ( 0.17%)       251498 (-1.17%)
write-262144           251304 ( 0.00%)       252769 ( 0.58%)       246666 (-1.88%)
write-524288           102207 ( 0.00%)       103622 ( 1.37%)       106770 ( 4.27%)
rewrite-64             889431 ( 0.00%)       969761 ( 8.28%)       942521 ( 5.63%)
rewrite-128           1007629 ( 0.00%)       985435 (-2.25%)      1007629 ( 0.00%)
rewrite-256           1007446 ( 0.00%)      1027695 ( 1.97%)      1016025 ( 0.84%)
rewrite-512           1009722 ( 0.00%)      1012101 ( 0.24%)       982917 (-2.73%)
rewrite-1024           933525 ( 0.00%)       939446 ( 0.63%)       923488 (-1.09%)
rewrite-2048           808859 ( 0.00%)       816626 ( 0.95%)       822175 ( 1.62%)
rewrite-4096           781834 ( 0.00%)       788472 ( 0.84%)       783474 ( 0.21%)
rewrite-8192           756475 ( 0.00%)       771023 ( 1.89%)       764385 ( 1.03%)
rewrite-16384          754911 ( 0.00%)       766865 ( 1.56%)       756490 ( 0.21%)
rewrite-32768          752752 ( 0.00%)       760559 ( 1.03%)       758942 ( 0.82%)
rewrite-65536          747709 ( 0.00%)       720857 (-3.73%)       758353 ( 1.40%)
rewrite-131072         748085 ( 0.00%)       757120 ( 1.19%)       759824 ( 1.54%)
rewrite-262144         727700 ( 0.00%)       733333 ( 0.77%)       732503 ( 0.66%)
rewrite-524288         105288 ( 0.00%)       104058 (-1.18%)       110624 ( 4.82%)
read-64               1562436 ( 0.00%)      1879725 (16.88%)      1526887 (-2.33%)
read-128              1526043 ( 0.00%)      1111981 (-37.24%)      1557024 ( 1.99%)
read-256              1729594 ( 0.00%)      1570244 (-10.15%)      1718521 (-0.64%)
read-512              1882427 ( 0.00%)      1672748 (-12.54%)      1917728 ( 1.84%)
read-1024             2031864 ( 0.00%)      2019445 (-0.61%)      1968537 (-3.22%)
read-2048             2298737 ( 0.00%)      2216868 (-3.69%)      2204352 (-4.28%)
read-4096             2356697 ( 0.00%)      2346077 (-0.45%)      2340643 (-0.69%)
read-8192             2480882 ( 0.00%)      2418030 (-2.60%)      2511345 ( 1.21%)
read-16384            2543770 ( 0.00%)      2522203 (-0.86%)      2621399 ( 2.96%)
read-32768            2573242 ( 0.00%)      2572664 (-0.02%)      2655424 ( 3.09%)
read-65536            2597014 ( 0.00%)      2598880 ( 0.07%)      2676570 ( 2.97%)
read-131072           2606221 ( 0.00%)      2607210 ( 0.04%)      2711057 ( 3.87%)
read-262144           2623777 ( 0.00%)      2627375 ( 0.14%)      2711992 ( 3.25%)
read-524288           2626615 ( 0.00%)      2611723 (-0.57%)      2711613 ( 3.13%)
reread-64             2278628 ( 0.00%)      4274062 (46.69%)      2467108 ( 7.64%)
reread-128            3277486 ( 0.00%)      3895854 (15.87%)      2969325 (-10.38%)
reread-256            3770085 ( 0.00%)      3879045 ( 2.81%)      3159869 (-19.31%)
reread-512            3580298 ( 0.00%)      3659616 ( 2.17%)      3220553 (-11.17%)
reread-1024           2877110 ( 0.00%)      2813041 (-2.28%)      2715230 (-5.96%)
reread-2048           2608697 ( 0.00%)      2602375 (-0.24%)      2653011 ( 1.67%)
reread-4096           2578086 ( 0.00%)      2592481 ( 0.56%)      2344476 (-9.96%)
reread-8192           2610564 ( 0.00%)      2598128 (-0.48%)      2717085 ( 3.92%)
reread-16384          2606781 ( 0.00%)      2612629 ( 0.22%)      2743532 ( 4.98%)
reread-32768          2625646 ( 0.00%)      2616449 (-0.35%)      2655014 ( 1.11%)
reread-65536          2628805 ( 0.00%)      2623110 (-0.22%)      2722026 ( 3.42%)
reread-131072         2611458 ( 0.00%)      2635027 ( 0.89%)      2724020 ( 4.13%)
reread-262144         2631362 ( 0.00%)      2630644 (-0.03%)      2751359 ( 4.36%)
reread-524288         2627836 ( 0.00%)      2626339 (-0.06%)      2724960 ( 3.56%)
randread-64           1768283 ( 0.00%)      1638743 (-7.90%)      1599680 (-10.54%)
randread-128          2098744 ( 0.00%)      2784517 (24.63%)      1911894 (-9.77%)
randread-256          2371308 ( 0.00%)      1704877 (-39.09%)      2065659 (-14.80%)
randread-512          2416145 ( 0.00%)      2438090 ( 0.90%)      2294796 (-5.29%)
randread-1024         2110750 ( 0.00%)      2106609 (-0.20%)      1943594 (-8.60%)
randread-2048         2036105 ( 0.00%)      1989882 (-2.32%)      1958129 (-3.98%)
randread-4096         2060231 ( 0.00%)      2006805 (-2.66%)      1979748 (-4.07%)
randread-8192         1931211 ( 0.00%)      2022730 ( 4.52%)      1982009 ( 2.56%)
randread-16384        1994886 ( 0.00%)      1988594 (-0.32%)      1978688 (-0.82%)
randread-32768        1953151 ( 0.00%)      1964148 ( 0.56%)      1944584 (-0.44%)
randread-65536        1917719 ( 0.00%)      1931844 ( 0.73%)      1906665 (-0.58%)
randread-131072       1900225 ( 0.00%)      1908756 ( 0.45%)      1894378 (-0.31%)
randread-262144       1890443 ( 0.00%)      1888592 (-0.10%)      1868879 (-1.15%)
randread-524288       1859164 ( 0.00%)      1855099 (-0.22%)      1843896 (-0.83%)
randwrite-64          1204796 ( 0.00%)       886494 (-35.91%)      1049372 (-14.81%)
randwrite-128         1254941 ( 0.00%)      1306873 ( 3.97%)      1162547 (-7.95%)
randwrite-256         1219045 ( 0.00%)      1286217 ( 5.22%)      1035624 (-17.71%)
randwrite-512         1171691 ( 0.00%)      1224470 ( 4.31%)      1130370 (-3.66%)
randwrite-1024         953418 ( 0.00%)      1001903 ( 4.84%)      1035229 ( 7.90%)
randwrite-2048         781058 ( 0.00%)       853377 ( 8.47%)       840682 ( 7.09%)
randwrite-4096         789341 ( 0.00%)       770646 (-2.43%)       760514 (-3.79%)
randwrite-8192         737352 ( 0.00%)       762824 ( 3.34%)       760208 ( 3.01%)
randwrite-16384        721920 ( 0.00%)       726622 ( 0.65%)       742698 ( 2.80%)
randwrite-32768        713991 ( 0.00%)       716963 ( 0.41%)       711835 (-0.30%)
randwrite-65536        703869 ( 0.00%)       707189 ( 0.47%)       702806 (-0.15%)
randwrite-131072       697603 ( 0.00%)       700211 ( 0.37%)       694241 (-0.48%)
randwrite-262144       674226 ( 0.00%)       688917 ( 2.13%)       682725 ( 1.24%)
randwrite-524288         3862 ( 0.00%)         3290 (-17.39%)         3678 (-5.00%)
bkwdread-64           1255511 ( 0.00%)      1879725 (33.21%)      1780008 (29.47%)
bkwdread-128          1487977 ( 0.00%)       947186 (-57.09%)       887675 (-67.63%)
bkwdread-256          1718521 ( 0.00%)      1219045 (-40.97%)      1254656 (-36.97%)
bkwdread-512          1772135 ( 0.00%)      1455126 (-21.79%)      1689859 (-4.87%)
bkwdread-1024         1825466 ( 0.00%)      1796451 (-1.62%)      1758930 (-3.78%)
bkwdread-2048         1705432 ( 0.00%)      1937372 (11.97%)      1892971 ( 9.91%)
bkwdread-4096         2004931 ( 0.00%)      2010798 ( 0.29%)      1963457 (-2.11%)
bkwdread-8192         2123881 ( 0.00%)      2090796 (-1.58%)      2099355 (-1.17%)
bkwdread-16384        2184219 ( 0.00%)      2167136 (-0.79%)      2156053 (-1.31%)
bkwdread-32768        2183067 ( 0.00%)      2202448 ( 0.88%)      2176705 (-0.29%)
bkwdread-65536        2199044 ( 0.00%)      2217637 ( 0.84%)      2202656 ( 0.16%)
bkwdread-131072       2224130 ( 0.00%)      2232222 ( 0.36%)      2218100 (-0.27%)
bkwdread-262144       2240966 ( 0.00%)      2247557 ( 0.29%)      2216583 (-1.10%)
bkwdread-524288       2236828 ( 0.00%)      2238212 ( 0.06%)      2152063 (-3.94%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         23.08     23.01     23.12
Total Elapsed Time (seconds)                303.03    329.62    303.42

NETPERF UDP
                   netperf-udp       netperf-udp          udp-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
      64    52.23 ( 0.00%)*    53.80 ( 2.92%)     50.56 (-3.30%) 
             1.36%             1.00%             1.00%        
     128   103.70 ( 0.00%)    107.43 ( 3.47%)    101.23 (-2.44%) 
     256   208.62 ( 0.00%)*   212.15 ( 1.66%)    202.35 (-3.10%) 
             1.73%             1.00%             1.00%        
    1024   814.86 ( 0.00%)    827.42 ( 1.52%)    799.13 (-1.97%) 
    2048  1585.65 ( 0.00%)   1614.76 ( 1.80%)   1563.52 (-1.42%) 
    3312  2512.44 ( 0.00%)   2556.70 ( 1.73%)   2460.37 (-2.12%) 
    4096  3016.81 ( 0.00%)*  3058.16 ( 1.35%)   2901.87 (-3.96%) 
             1.15%             1.00%             1.00%        
    8192  5384.46 ( 0.00%)   5092.95 (-5.72%)   4912.71 (-9.60%) 
   16384  8091.96 ( 0.00%)*  8249.26 ( 1.91%)   8004.40 (-1.09%) 
             1.70%             1.00%             1.00%        
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        3318.1   1759.32    2037.7
Total Elapsed Time (seconds)               3986.21   2114.19   2450.19

NETPERF TCP
                   netperf-tcp       netperf-tcp          tcp-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
      64   559.86 ( 0.00%)    561.45 ( 0.28%)    553.43 (-1.16%) 
     128  1015.34 ( 0.00%)   1023.43 ( 0.79%)   1010.13 (-0.52%) 
     256  1758.20 ( 0.00%)   1790.91 ( 1.83%)   1761.10 ( 0.16%) 
    1024  3657.40 ( 0.00%)   3749.93 ( 2.47%)   3617.72 (-1.10%) 
    2048  4237.05 ( 0.00%)*  4338.38 ( 2.34%)   4214.48 (-0.54%)*
             1.05%             1.00%             1.13%        
    3312  4490.72 ( 0.00%)*  4469.92 (-0.47%)*  4293.97 (-4.58%)*
             2.56%             1.47%             2.32%        
    4096  4977.91 ( 0.00%)   5158.15 ( 3.49%)   4882.70 (-1.95%) 
    8192  5574.82 ( 0.00%)   5629.75 ( 0.98%)   5442.13 (-2.44%) 
   16384  7549.99 ( 0.00%)*  7839.95 ( 3.70%)*  7582.45 ( 0.43%)*
             6.34%             6.80%             4.80%        
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        2981.5   2171.64   2817.11
Total Elapsed Time (seconds)               3059.42   2218.98   2879.69

HACKBENCH PIPES
           1     0.07 ( 0.00%)     0.06 ( 1.92%)     0.07 (-5.89%)
           4     0.13 ( 0.00%)     0.14 (-8.39%)     0.14 (-7.73%)
           8     0.24 ( 0.00%)     0.23 ( 3.26%)     0.23 ( 4.43%)
          12     0.37 ( 0.00%)     0.37 (-1.97%)     0.37 (-1.20%)
          16     0.42 ( 0.00%)     0.41 ( 2.42%)     0.44 (-4.16%)
          20     0.51 ( 0.00%)     0.53 (-2.78%)     0.56 (-8.09%)
          24     0.65 ( 0.00%)     0.61 ( 7.45%)     0.61 ( 7.84%)
          28     0.72 ( 0.00%)     0.73 (-0.72%)     0.77 (-6.59%)
          32     0.80 ( 0.00%)     0.80 (-0.12%)     0.81 (-1.32%)
          36     0.97 ( 0.00%)     0.90 ( 7.69%)     0.92 ( 5.40%)
          40     1.00 ( 0.00%)     0.98 ( 2.11%)     1.03 (-2.40%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        116.79    121.81     133.8
Total Elapsed Time (seconds)                143.91    142.96    147.49

HACKBENCH SOCKETS
           1     0.09 ( 0.00%)     0.10 ( 7.91%)     0.09 ( 3.37%)
           4     0.31 ( 0.00%)     0.31 ( 0.34%)     0.27 (-11.78%)
           8     0.58 ( 0.00%)     0.58 (-0.64%)     0.53 (-10.77%)
          12     0.90 ( 0.00%)     0.86 (-4.19%)     0.78 (-14.80%)
          16     1.17 ( 0.00%)     1.13 (-3.53%)     1.02 (-14.57%)
          20     1.46 ( 0.00%)     1.42 (-2.63%)     1.27 (-14.77%)
          24     1.75 ( 0.00%)     1.70 (-3.13%)     1.54 (-13.98%)
          28     2.04 ( 0.00%)     1.96 (-4.13%)     1.75 (-16.31%)
          32     2.32 ( 0.00%)     2.25 (-3.11%)     2.00 (-16.34%)
          36     2.60 ( 0.00%)     2.52 (-3.00%)     2.26 (-15.21%)
          40     2.90 ( 0.00%)     2.81 (-3.35%)     2.52 (-15.03%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1007.63    841.49    765.63
Total Elapsed Time (seconds)                348.97    339.07    309.28

CREATEDELETE

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2287.66   2174.03   2305.63
Total Elapsed Time (seconds)               1053.00   1012.81   1052.59

CACHEEFFECTS

MMTests Statistics: duration
User/Sys Time Running Test (seconds)           0.3      0.27      0.31
Total Elapsed Time (seconds)                  3.87      4.35      3.96

STREAM
                    vmr-stream        vmr-stream       stream-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
Add-static-small-17.0        12064.30 ( 0.00%) 12064.30 ( 0.00%) 11950.48 (-0.95%)
Add-static-small-17.33       14304.10 ( 0.00%) 14658.59 ( 2.42%) 14412.68 ( 0.75%)
Add-static-small-17.66       13037.24 ( 0.00%) 12728.52 (-2.43%) 12520.79 (-4.12%)
Add-static-small-18.0        13899.62 ( 0.00%) 13971.95 ( 0.52%) 13971.95 ( 0.52%)
Add-static-small-18.33       13602.88 ( 0.00%) 13630.44 ( 0.20%) 13562.15 (-0.30%)
Add-static-small-18.66       13140.73 ( 0.00%) 13254.87 ( 0.86%) 13588.01 ( 3.29%)
Add-static-small-19.0        11343.07 ( 0.00%)  9744.24 (-16.41%) 12011.02 ( 5.56%)
Add-static-small-19.33       10266.32 ( 0.00%)  9499.10 (-8.08%)  9659.62 (-6.28%)
Add-static-small-19.66        6755.96 ( 0.00%)  7122.05 ( 5.14%)  7167.80 ( 5.75%)
Add-static-small-20.0         5146.37 ( 0.00%)  4932.07 (-4.35%)  5014.26 (-2.63%)
Add-static-small-20.33        2797.35 ( 0.00%)  2841.12 ( 1.54%)  2913.44 ( 3.98%)
Add-static-small-20.66        2410.63 ( 0.00%)  2409.50 (-0.05%)  2444.73 ( 1.39%)
Add-static-small-21.0         2558.76 ( 0.00%)  2578.45 ( 0.76%)  2544.36 (-0.57%)
Add-static-small-21.33        2374.19 ( 0.00%)  2375.22 ( 0.04%)  2381.77 ( 0.32%)
Add-static-small-21.66        2542.64 ( 0.00%)  2548.12 ( 0.21%)  2552.61 ( 0.39%)
Add-static-small-22.0         2661.86 ( 0.00%)  2647.16 (-0.56%)  2655.80 (-0.23%)
Add-static-small-22.33        2671.42 ( 0.00%)  2677.47 ( 0.23%)  2674.40 ( 0.11%)
Add-static-small-22.66        2473.47 ( 0.00%)  2481.66 ( 0.33%)  2477.52 ( 0.16%)
Add-static-small-23.0         2709.03 ( 0.00%)  2703.36 (-0.21%)  2700.99 (-0.30%)
Add-static-small-23.33        2400.59 ( 0.00%)  2398.40 (-0.09%)  2398.53 (-0.09%)
Add-static-small-23.66        2311.42 ( 0.00%)  2314.08 ( 0.11%)  2315.33 ( 0.17%)
Add-static-small-24.0         2728.27 ( 0.00%)  2732.43 ( 0.15%)  2731.14 ( 0.11%)
Add-static-small-24.33        2671.22 ( 0.00%)  2671.66 ( 0.02%)  2667.95 (-0.12%)
Add-static-small-24.66        2537.32 ( 0.00%)  2540.08 ( 0.11%)  2540.08 ( 0.11%)
Add-static-small-25.0         2749.01 ( 0.00%)  2749.38 ( 0.01%)  2748.98 (-0.00%)
Add-static-small-25.33        2541.34 ( 0.00%)  2542.30 ( 0.04%)  2540.70 (-0.02%)
Add-static-small-25.66        2767.26 ( 0.00%)  2766.62 (-0.02%)  2766.04 (-0.04%)
Add-static-small-26.0         2762.67 ( 0.00%)  2763.35 ( 0.02%)  2763.48 ( 0.03%)
Add-static-small-26.33        2511.43 ( 0.00%)  2510.95 (-0.02%)  2511.01 (-0.02%)
Add-static-small-26.66        2612.54 ( 0.00%)  2611.50 (-0.04%)  2611.98 (-0.02%)
Add-static-small-27.0         2781.28 ( 0.00%)  2780.14 (-0.04%)  2781.63 ( 0.01%)
Add-static-small-27.33        2695.21 ( 0.00%)  2693.52 (-0.06%)  2692.99 (-0.08%)
Add-static-small-27.66        2769.12 ( 0.00%)  2768.34 (-0.03%)  2768.79 (-0.01%)
Add-static-small-28.0         2790.06 ( 0.00%)  2788.43 (-0.06%)  2791.53 ( 0.05%)
Add-static-small-28.33        2817.07 ( 0.00%)  2816.11 (-0.03%)  2816.23 (-0.03%)
Add-static-small-28.66        2733.30 ( 0.00%)  2733.20 (-0.00%)  2733.60 ( 0.01%)
Add-static-small-29.0         2797.55 ( 0.00%)  2796.75 (-0.03%)  2797.62 ( 0.00%)
Add-static-small-29.33        2747.68 ( 0.00%)  2747.16 (-0.02%)  2746.53 (-0.04%)
Add-static-small-29.66        2696.02 ( 0.00%)  2693.31 (-0.10%)  2693.99 (-0.08%)
Add-static-small-30.0         2781.97 ( 0.00%)  2779.25 (-0.10%)  2784.71 ( 0.10%)
Copy-static-small-17.0       14659.26 ( 0.00%) 14414.94 (-1.69%) 14142.10 (-3.66%)
Copy-static-small-17.33      14437.64 ( 0.00%) 14442.96 ( 0.04%) 14515.94 ( 0.54%)
Copy-static-small-17.66      11311.57 ( 0.00%) 11378.11 ( 0.58%) 11311.57 ( 0.00%)
Copy-static-small-18.0       11765.69 ( 0.00%) 11690.63 (-0.64%) 11784.45 ( 0.16%)
Copy-static-small-18.33      11623.77 ( 0.00%) 11522.60 (-0.88%) 11623.77 ( 0.00%)
Copy-static-small-18.66      11321.31 ( 0.00%) 11279.20 (-0.37%) 11443.65 ( 1.07%)
Copy-static-small-19.0       11222.00 ( 0.00%)  9620.40 (-16.65%) 11354.70 ( 1.17%)
Copy-static-small-19.33      10892.85 ( 0.00%)  9996.77 (-8.96%) 10127.48 (-7.56%)
Copy-static-small-19.66       8650.33 ( 0.00%)  8544.79 (-1.24%)  8292.51 (-4.31%)
Copy-static-small-20.0        6776.33 ( 0.00%)  5775.60 (-17.33%)  6393.53 (-5.99%)
Copy-static-small-20.33       3868.82 ( 0.00%)  3903.18 ( 0.88%)  3791.15 (-2.05%)
Copy-static-small-20.66       2962.61 ( 0.00%)  2997.96 ( 1.18%)  2945.59 (-0.58%)
Copy-static-small-21.0        2776.75 ( 0.00%)  2745.67 (-1.13%)  2767.47 (-0.34%)
Copy-static-small-21.33       2665.36 ( 0.00%)  2668.46 ( 0.12%)  2653.65 (-0.44%)
Copy-static-small-21.66       2581.35 ( 0.00%)  2568.24 (-0.51%)  2580.30 (-0.04%)
Copy-static-small-22.0        2449.33 ( 0.00%)  2448.14 (-0.05%)  2447.34 (-0.08%)
Copy-static-small-22.33       2233.25 ( 0.00%)  2229.02 (-0.19%)  2226.57 (-0.30%)
Copy-static-small-22.66       2083.14 ( 0.00%)  2090.15 ( 0.34%)  2084.96 ( 0.09%)
Copy-static-small-23.0        2376.04 ( 0.00%)  2376.96 ( 0.04%)  2374.23 (-0.08%)
Copy-static-small-23.33       2252.81 ( 0.00%)  2255.55 ( 0.12%)  2253.88 ( 0.05%)
Copy-static-small-23.66       2192.97 ( 0.00%)  2196.61 ( 0.17%)  2194.06 ( 0.05%)
Copy-static-small-24.0        2321.02 ( 0.00%)  2326.15 ( 0.22%)  2321.40 ( 0.02%)
Copy-static-small-24.33       2399.02 ( 0.00%)  2397.62 (-0.06%)  2397.38 (-0.07%)
Copy-static-small-24.66       2407.21 ( 0.00%)  2406.11 (-0.05%)  2407.45 ( 0.01%)
Copy-static-small-25.0        2312.30 ( 0.00%)  2312.73 ( 0.02%)  2313.24 ( 0.04%)
Copy-static-small-25.33       2009.71 ( 0.00%)  2008.83 (-0.04%)  2009.39 (-0.02%)
Copy-static-small-25.66       2134.22 ( 0.00%)  2132.93 (-0.06%)  2133.65 (-0.03%)
Copy-static-small-26.0        2306.28 ( 0.00%)  2306.54 ( 0.01%)  2307.05 ( 0.03%)
Copy-static-small-26.33       2184.55 ( 0.00%)  2183.33 (-0.06%)  2183.96 (-0.03%)
Copy-static-small-26.66       2234.97 ( 0.00%)  2234.81 (-0.01%)  2234.18 (-0.03%)
Copy-static-small-27.0        2317.53 ( 0.00%)  2317.06 (-0.02%)  2318.87 ( 0.06%)
Copy-static-small-27.33       2402.66 ( 0.00%)  2401.76 (-0.04%)  2402.54 (-0.00%)
Copy-static-small-27.66       2396.42 ( 0.00%)  2395.54 (-0.04%)  2395.94 (-0.02%)
Copy-static-small-28.0        2334.59 ( 0.00%)  2333.69 (-0.04%)  2334.68 ( 0.00%)
Copy-static-small-28.33       2228.03 ( 0.00%)  2226.75 (-0.06%)  2226.41 (-0.07%)
Copy-static-small-28.66       2168.20 ( 0.00%)  2168.81 ( 0.03%)  2169.26 ( 0.05%)
Copy-static-small-29.0        2343.31 ( 0.00%)  2343.03 (-0.01%)  2344.22 ( 0.04%)
Copy-static-small-29.33       2293.51 ( 0.00%)  2292.53 (-0.04%)  2293.24 (-0.01%)
Copy-static-small-29.66       2296.00 ( 0.00%)  2294.23 (-0.08%)  2296.50 ( 0.02%)
Copy-static-small-30.0        2349.76 ( 0.00%)  2348.91 (-0.04%)  2349.01 (-0.03%)
Scale-static-small-17.0      14254.87 ( 0.00%) 14198.49 (-0.40%) 14659.26 ( 2.76%)
Scale-static-small-17.33     13846.22 ( 0.00%) 13331.26 (-3.86%) 13919.20 ( 0.52%)
Scale-static-small-17.66     10460.06 ( 0.00%) 10477.91 ( 0.17%) 10477.91 ( 0.17%)
Scale-static-small-18.0       9176.40 ( 0.00%)  8959.46 (-2.42%)  9153.79 (-0.25%)
Scale-static-small-18.33      8031.20 ( 0.00%)  8043.81 ( 0.16%)  8051.07 ( 0.25%)
Scale-static-small-18.66      7882.66 ( 0.00%)  7882.66 ( 0.00%)  7923.37 ( 0.51%)
Scale-static-small-19.0       9827.80 ( 0.00%)  9196.63 (-6.86%)  9847.38 ( 0.20%)
Scale-static-small-19.33      9140.09 ( 0.00%)  9112.74 (-0.30%)  8947.76 (-2.15%)
Scale-static-small-19.66      7448.02 ( 0.00%)  7609.60 ( 2.12%)  7634.98 ( 2.45%)
Scale-static-small-20.0       5736.04 ( 0.00%)  5646.54 (-1.59%)  5499.92 (-4.29%)
Scale-static-small-20.33      3767.07 ( 0.00%)  3466.29 (-8.68%)  3731.70 (-0.95%)
Scale-static-small-20.66      2605.20 ( 0.00%)  2586.14 (-0.74%)  2591.36 (-0.53%)
Scale-static-small-21.0       2458.99 ( 0.00%)  2473.66 ( 0.59%)  2425.00 (-1.40%)
Scale-static-small-21.33      2301.60 ( 0.00%)  2316.69 ( 0.65%)  2302.14 ( 0.02%)
Scale-static-small-21.66      2113.64 ( 0.00%)  2116.43 ( 0.13%)  2111.01 (-0.12%)
Scale-static-small-22.0       2334.94 ( 0.00%)  2346.44 ( 0.49%)  2342.90 ( 0.34%)
Scale-static-small-22.33      2355.52 ( 0.00%)  2355.57 ( 0.00%)  2353.04 (-0.11%)
Scale-static-small-22.66      2374.13 ( 0.00%)  2368.80 (-0.23%)  2373.85 (-0.01%)
Scale-static-small-23.0       2193.07 ( 0.00%)  2192.18 (-0.04%)  2198.93 ( 0.27%)
Scale-static-small-23.33      1961.98 ( 0.00%)  1963.48 ( 0.08%)  1963.58 ( 0.08%)
Scale-static-small-23.66      2087.14 ( 0.00%)  2084.43 (-0.13%)  2086.74 (-0.02%)
Scale-static-small-24.0       2317.82 ( 0.00%)  2316.05 (-0.08%)  2319.08 ( 0.05%)
Scale-static-small-24.33      2088.54 ( 0.00%)  2090.38 ( 0.09%)  2090.72 ( 0.10%)
Scale-static-small-24.66      2249.70 ( 0.00%)  2248.20 (-0.07%)  2247.32 (-0.11%)
Scale-static-small-25.0       2191.54 ( 0.00%)  2191.17 (-0.02%)  2191.90 ( 0.02%)
Scale-static-small-25.33      2365.61 ( 0.00%)  2365.82 ( 0.01%)  2365.53 (-0.00%)
Scale-static-small-25.66      2353.54 ( 0.00%)  2355.43 ( 0.08%)  2353.49 (-0.00%)
Scale-static-small-26.0       2328.23 ( 0.00%)  2327.04 (-0.05%)  2327.79 (-0.02%)
Scale-static-small-26.33      2174.75 ( 0.00%)  2176.11 ( 0.06%)  2175.69 ( 0.04%)
Scale-static-small-26.66      2109.83 ( 0.00%)  2108.76 (-0.05%)  2109.16 (-0.03%)
Scale-static-small-27.0       2232.60 ( 0.00%)  2231.80 (-0.04%)  2233.96 ( 0.06%)
Scale-static-small-27.33      2298.19 ( 0.00%)  2298.13 (-0.00%)  2297.96 (-0.01%)
Scale-static-small-27.66      2210.86 ( 0.00%)  2209.71 (-0.05%)  2210.47 (-0.02%)
Scale-static-small-28.0       2347.95 ( 0.00%)  2347.62 (-0.01%)  2348.78 ( 0.04%)
Scale-static-small-28.33      2371.16 ( 0.00%)  2370.16 (-0.04%)  2370.52 (-0.03%)
Scale-static-small-28.66      2373.70 ( 0.00%)  2373.81 ( 0.00%)  2374.67 ( 0.04%)
Scale-static-small-29.0       2289.08 ( 0.00%)  2288.95 (-0.01%)  2290.30 ( 0.05%)
Scale-static-small-29.33      2251.49 ( 0.00%)  2250.53 (-0.04%)  2251.88 ( 0.02%)
Scale-static-small-29.66      2264.59 ( 0.00%)  2262.57 (-0.09%)  2263.30 (-0.06%)
Scale-static-small-30.0       2368.20 ( 0.00%)  2367.55 (-0.03%)  2368.02 (-0.01%)
Triad-static-small-17.0      12462.37 ( 0.00%) 12455.87 (-0.05%) 12405.74 (-0.46%)
Triad-static-small-17.33     13548.09 ( 0.00%) 13572.77 ( 0.18%) 13572.77 ( 0.18%)
Triad-static-small-17.66     12491.80 ( 0.00%) 12405.05 (-0.70%) 12506.85 ( 0.12%)
Triad-static-small-18.0      10050.94 ( 0.00%) 10086.65 ( 0.35%) 10050.94 ( 0.00%)
Triad-static-small-18.33     10622.90 ( 0.00%) 10408.87 (-2.06%) 10506.39 (-1.11%)
Triad-static-small-18.66     10297.50 ( 0.00%) 10025.29 (-2.72%) 10380.22 ( 0.80%)
Triad-static-small-19.0      10984.20 ( 0.00%)  9572.00 (-14.75%) 11701.99 ( 6.13%)
Triad-static-small-19.33      9854.11 ( 0.00%)  9090.86 (-8.40%)  8933.28 (-10.31%)
Triad-static-small-19.66      6082.61 ( 0.00%)  6673.00 ( 8.85%)  6430.92 ( 5.42%)
Triad-static-small-20.0       4571.62 ( 0.00%)  4482.53 (-1.99%)  4473.38 (-2.20%)
Triad-static-small-20.33      2880.73 ( 0.00%)  2891.05 ( 0.36%)  2938.72 ( 1.97%)
Triad-static-small-20.66      2326.63 ( 0.00%)  2320.30 (-0.27%)  2316.88 (-0.42%)
Triad-static-small-21.0       2759.25 ( 0.00%)  2764.61 ( 0.19%)  2744.24 (-0.55%)
Triad-static-small-21.33      2696.68 ( 0.00%)  2694.26 (-0.09%)  2700.09 ( 0.13%)
Triad-static-small-21.66      2595.89 ( 0.00%)  2590.86 (-0.19%)  2589.48 (-0.25%)
Triad-static-small-22.0       2715.27 ( 0.00%)  2709.88 (-0.20%)  2712.39 (-0.11%)
Triad-static-small-22.33      2559.21 ( 0.00%)  2560.17 ( 0.04%)  2559.76 ( 0.02%)
Triad-static-small-22.66      2780.62 ( 0.00%)  2771.40 (-0.33%)  2777.04 (-0.13%)
Triad-static-small-23.0       2725.92 ( 0.00%)  2735.80 ( 0.36%)  2734.08 ( 0.30%)
Triad-static-small-23.33      2197.15 ( 0.00%)  2197.16 ( 0.00%)  2198.22 ( 0.05%)
Triad-static-small-23.66      2491.03 ( 0.00%)  2492.60 ( 0.06%)  2490.21 (-0.03%)
Triad-static-small-24.0       2698.54 ( 0.00%)  2696.26 (-0.08%)  2696.67 (-0.07%)
Triad-static-small-24.33      2572.62 ( 0.00%)  2574.74 ( 0.08%)  2576.27 ( 0.14%)
Triad-static-small-24.66      2693.72 ( 0.00%)  2692.98 (-0.03%)  2694.17 ( 0.02%)
Triad-static-small-25.0       2727.56 ( 0.00%)  2726.54 (-0.04%)  2726.28 (-0.05%)
Triad-static-small-25.33      2774.01 ( 0.00%)  2773.77 (-0.01%)  2773.23 (-0.03%)
Triad-static-small-25.66      2568.71 ( 0.00%)  2569.79 ( 0.04%)  2569.52 ( 0.03%)
Triad-static-small-26.0       2717.27 ( 0.00%)  2717.70 ( 0.02%)  2717.99 ( 0.03%)
Triad-static-small-26.33      2627.58 ( 0.00%)  2627.41 (-0.01%)  2627.89 ( 0.01%)
Triad-static-small-26.66      2469.62 ( 0.00%)  2469.00 (-0.02%)  2468.88 (-0.03%)
Triad-static-small-27.0       2757.61 ( 0.00%)  2756.50 (-0.04%)  2757.91 ( 0.01%)
Triad-static-small-27.33      2756.80 ( 0.00%)  2756.63 (-0.01%)  2757.00 ( 0.01%)
Triad-static-small-27.66      2730.51 ( 0.00%)  2729.97 (-0.02%)  2730.23 (-0.01%)
Triad-static-small-28.0       2760.07 ( 0.00%)  2759.34 (-0.03%)  2760.34 ( 0.01%)
Triad-static-small-28.33      2724.95 ( 0.00%)  2723.63 (-0.05%)  2724.47 (-0.02%)
Triad-static-small-28.66      2818.62 ( 0.00%)  2819.25 ( 0.02%)  2820.00 ( 0.05%)
Triad-static-small-29.0       2787.79 ( 0.00%)  2787.43 (-0.01%)  2788.62 ( 0.03%)
Triad-static-small-29.33      2699.87 ( 0.00%)  2698.92 (-0.04%)  2698.81 (-0.04%)
Triad-static-small-29.66      2764.21 ( 0.00%)  2761.20 (-0.11%)  2762.21 (-0.07%)
Triad-static-small-30.0       2767.82 ( 0.00%)  2766.04 (-0.06%)  2767.55 (-0.01%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)        833.15    833.07    833.27
Total Elapsed Time (seconds)                840.38    839.78    839.63

SYSBENCH
            sysbench-slab-vanilla-sysbenchsysbench-slub-vanilla-sysbench     sysbench-slub
                  slab-vanilla      slub-vanilla      unified-v4r1
           1  7521.24 ( 0.00%)  7719.38 ( 2.57%)  7589.13 ( 0.89%)
           2 14872.85 ( 0.00%) 15275.09 ( 2.63%) 15054.08 ( 1.20%)
           3 16502.53 ( 0.00%) 16676.53 ( 1.04%) 16465.69 (-0.22%)
           4 17831.19 ( 0.00%) 17900.09 ( 0.38%) 17819.03 (-0.07%)
           5 18158.40 ( 0.00%) 18432.74 ( 1.49%) 18341.99 ( 1.00%)
           6 18673.68 ( 0.00%) 18878.41 ( 1.08%) 18614.92 (-0.32%)
           7 17689.75 ( 0.00%) 17871.89 ( 1.02%) 17633.19 (-0.32%)
           8 16885.68 ( 0.00%) 16838.37 (-0.28%) 16498.41 (-2.35%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)       2362.85   2367.19   2430.63
Total Elapsed Time (seconds)               2932.91   2936.30   2932.22

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
