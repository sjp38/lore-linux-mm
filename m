Message-ID: <3D879B3B.9F326E20@austin.ibm.com>
Date: Tue, 17 Sep 2002 16:14:35 -0500
From: Bill Hartner <hartner@austin.ibm.com>
MIME-Version: 1.0
Subject: VolanoMark Benchmark results for 2.5.26, 2.5.26 + rmap, 2.5.35, and
 2.5.35 + mm1
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, lse-tech@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

I ran VolanoMark 2.1.2 under memory pressure to test rmap.
                             ---------------
Kernels tested were :

     * 2.5.26
     * 2.5.26 + Dave McCracken 2.5.26-rmap patch
     * 2.5.35
     * 2.5.35 + Andrew Morton 2.5.35-mm1 patch

The SUT was an 8-way 700 Mhz PIII system with 3 GB mem.
A single 2 GB swap partition.
IBM JR2RE 1.3.1 cxia32131-20020302.

When VolanoMark was ran with 4 GB mem, there is about 500 MB free mem.
The JVM heaps totaled 3 GB.
When the test was ran with 3 GB mem 1 GB of swap space was required.

VolanoMark was ran in loopback mode - client and server on same system.
The JVM for the VolanoMark client used a 1536 MB heap.
The JVM for the VolanoMark server used a 1536 MB heap.
The number of messages was set at 25000 and number of rooms at 10.
The JVM does not fork - it uses pthreads.
10 rooms creates 400 client pthreads and 400 server pthreads.

More info on VolanoMark at http://www.volano.com/benchmarks.html

When the JVM heaps are exhausted (memory allocation failure) garbage
collection (GC) is done by the JVM.  GC usually reclaims about 99 % of the
heap.  The client JVM uses its heap more heavily than the server.  The
client JVM will GC about 26 times during the test and the server JVM will GC
about twice.  The meta data for the heap is _not_ in the heap itself, so
when GC is run the JVM does _not_ touch every page in the heap.

As the 3 GB mem test runs (for 2.5.26 baseline) :

   HighFree goes to ~2MB at about  240 seconds into the test
   Low Free goes to ~6MB at about  600 seconds into the test
   SwapFree goes to ~1GB at about 1245 seconds into the test
   The test ends         at about 1966 seconds (33 minutes)

VolanoMark was ran 1 time for each kernel.

The results for the 3 GB mem test were :
                    --------
%sys/%user = ratio of system CPU utilization to %user CPU utilization.

kernel      msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
----------- -----  ---- ----------  ------------  ------------  ------------
2.5.26      51824  96.3 1.42        1,987,024 KB  2,148,100 KB  4,135,124 KB
2.5.26rmap  46053  90.8 1.55        3,139,324 KB  3,887,368 KB  7,026,692 KB
2.5.35      44693  86.1 1.45        1,982,236 KB  5,393,152 KB  7,375,388 KB
2.5.35mm1   39679  99.6 1.50       *2,720,600 KB *6,154,512 KB *8,875,112 KB

* used pgin/pgout instead of swapin/swapout since /proc/stat changed.

2.5.35 had the following errors after high and low mem were exhausted
for the 3 GB test :

kswapd: page allocation failure. order:0, mode:0x50
java: page allocation failure. order:0, mode:0x50

On 2.5.35, I replaced the printk of the page allocation error with a global
counter and ran 2.5.35 again.  The global counter indicated 5532 page
allocation errors during the test and the throughput was 44371 msg/s.

These errors do not occur on 2.5.35 + mm1

The results for the 4 GB mem test were :
                    --------
kernel      msg/s  %CPU %sys/%user  Total swpin   Total swpout  Total swapio
----------- -----  ---- ----------  ------------  ------------  ------------
2.5.26      55446  99.4 1.40        0             0             0
2.5.35      52845  99.9 1.38        0             0             0
2.5.35mm1   52755  99.9 1.42        0             0             0

2.5.26 vs 2.5.26 + rmap patch
-----------------------------
It appears as though the page stealing decisions made when using the
2.5.26 rmap patch may not be as good as the baseline for this workload.
There was more swap activity and idle time.

46053/51824 = 88.9 %, VolanoMark runs 11 % slower with the 2.5.26 rmap patch
when compared to 2.5.26 for the 3 GB test.

Here is a chart that compares (a) swap rate (swapin + swapout)
and (b) CPU utilization for on 2.5.26 and 2.5.26+rmap patch.

www-124.ibm.com/developerworks/opensource/linuxperf/volanomark/091602/v26.gif

2.5.35 vs 2.5.35 + mm1 patch
-----------------------------

The 2.5.35 + mm1 patch does not have the page allocation errors.  
The swapin and swapout are not reported in /proc/stat for this patch.
So I used /proc/stat pgin and pgout to determine swap io rate.

39679/51824 = 77.4 %, VolanoMark runs 22 % slower with the 2.5.35 mm1 patch
when compared to 2.5.26 for the 3GB test.

Bill Hartner
IBM Linux Technology Center
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
