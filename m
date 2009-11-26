Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E02136B0093
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 07:19:53 -0500 (EST)
Date: Thu, 26 Nov 2009 12:19:45 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH-RFC] cfq: Disable low_latency by default for 2.6.32
Message-ID: <20091126121945.GB13095@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

(cc'ing the people from the page allocator failure thread as this might be
relevant to some of their problems)

I know this is very last minute but I believe we should consider disabling
the "low_latency" tunable for block devices by default for 2.6.32.  There was
evidence that low_latency was a problem last week for page allocation failure
reports but the reproduction-case was unusual and involved high-order atomic
allocations in low-memory conditions. It took another few days to accurately
show the problem for more normal workloads and it's a bit more wide-spread
than just allocation failures.

Basically, low_latency looks great as long as you have plenty of memory
but in low memory situations, it appears to cause problems that manifest
as reduced performance, desktop stalls and in some cases, page allocation
failures. I think most kernel developers are not seeing the problem as they
tend to test on beefier machines and without hitting swap or low-memory
situations for the most part. When they are hitting low-memory situations,
it tends to be for stress tests where stalls and low performance are expected.

To show the problem, I used an x86-64 machine booting booted with 512MB of
memory. This is a small amount of RAM but the bug reports related to page
allocation failures were on smallish machines and the disks in the system
are not very high-performance.

I used three tests. The first was sysbench on postgres running an IO-heavy
test against a large database with 10,000,000 rows. The second was IOZone
running most of the automatic tests with a record length of 4KB and the
last was a simulated launching of gitk with a music player running in the
background to act as a desktop-like scenario. The final test was similar
to the test described here http://lwn.net/Articles/362184/ except that
dm-crypt was not used as it has its own problems.

Sysbench results looks as follows

                 sysbench-with  sysbench-without
                   low-latency       low-latency
           1  1266.02 ( 0.00%)  1278.55 ( 0.98%)
           2  1182.58 ( 0.00%)  1379.25 (14.26%)
           3  1257.08 ( 0.00%)  1580.08 (20.44%)
           4  1212.11 ( 0.00%)  1534.17 (20.99%)
           5  1046.77 ( 0.00%)  1552.48 (32.57%)
           6  1187.14 ( 0.00%)  1661.19 (28.54%)
           7  1179.37 ( 0.00%)   790.26 (-49.24%)
           8  1164.62 ( 0.00%)   854.10 (-36.36%)
           9  1125.04 ( 0.00%)  1655.04 (32.02%)
          10  1147.52 ( 0.00%)  1653.89 (30.62%)
          11   823.38 ( 0.00%)  1627.45 (49.41%)
          12   813.73 ( 0.00%)  1494.63 (45.56%)
          13   898.22 ( 0.00%)  1521.64 (40.97%)
          14   873.50 ( 0.00%)  1311.09 (33.38%)
          15   808.32 ( 0.00%)  1009.70 (19.94%)
          16   758.17 ( 0.00%)   725.17 (-4.55%)

The first column is threads. Disabling low_latency performs much better
for the most part.  I should point out that with plenty of memory, sysbench
tends to perform better *with* low_latency but as we're seeing page allocation
failure reports in low memory situations and desktop stalls, the lower memory
situation is also important.

The IOZone results are long I'm afraid.

                           iozone-with        iozone-without
                           low-latency           low-latency
write-64               151212 ( 0.00%)       159856 ( 5.41%)
write-128              189357 ( 0.00%)       206233 ( 8.18%)
write-256              219883 ( 0.00%)       223174 ( 1.47%)
write-512              224932 ( 0.00%)       220227 (-2.14%)
write-1024             227738 ( 0.00%)       226155 (-0.70%)
write-2048             227564 ( 0.00%)       224848 (-1.21%)
write-4096             208556 ( 0.00%)       223430 ( 6.66%)
write-8192             219484 ( 0.00%)       219389 (-0.04%)
write-16384            206670 ( 0.00%)       206295 (-0.18%)
write-32768            203023 ( 0.00%)       201852 (-0.58%)
write-65536            162134 ( 0.00%)       189173 (14.29%)
write-131072            68534 ( 0.00%)        67417 (-1.66%)
write-262144            32936 ( 0.00%)        27750 (-18.69%)
write-524288            24044 ( 0.00%)        23759 (-1.20%)
rewrite-64             755681 ( 0.00%)       755681 ( 0.00%)
rewrite-128            581518 ( 0.00%)       799840 (27.30%)
rewrite-256            639427 ( 0.00%)       659861 ( 3.10%)
rewrite-512            669577 ( 0.00%)       684954 ( 2.24%)
rewrite-1024           680960 ( 0.00%)       686182 ( 0.76%)
rewrite-2048           685263 ( 0.00%)       692780 ( 1.09%)
rewrite-4096           631352 ( 0.00%)       643266 ( 1.85%)
rewrite-8192           442146 ( 0.00%)       442624 ( 0.11%)
rewrite-16384          428641 ( 0.00%)       432613 ( 0.92%)
rewrite-32768          425361 ( 0.00%)       430568 ( 1.21%)
rewrite-65536          405183 ( 0.00%)       389242 (-4.10%)
rewrite-131072          66110 ( 0.00%)        58472 (-13.06%)
rewrite-262144          29254 ( 0.00%)        29306 ( 0.18%)
rewrite-524288          23812 ( 0.00%)        24543 ( 2.98%)
read-64                934589 ( 0.00%)       840903 (-11.14%)
read-128              1601534 ( 0.00%)      1280633 (-25.06%)
read-256              1255511 ( 0.00%)      1310683 ( 4.21%)
read-512              1291158 ( 0.00%)      1319723 ( 2.16%)
read-1024             1319408 ( 0.00%)      1347557 ( 2.09%)
read-2048             1316016 ( 0.00%)      1347393 ( 2.33%)
read-4096             1253710 ( 0.00%)      1251882 (-0.15%)
read-8192              995149 ( 0.00%)      1011794 ( 1.65%)
read-16384             883156 ( 0.00%)       897458 ( 1.59%)
read-32768             844368 ( 0.00%)       856364 ( 1.40%)
read-65536             816099 ( 0.00%)       826473 ( 1.26%)
read-131072            818055 ( 0.00%)       824351 ( 0.76%)
read-262144            827225 ( 0.00%)       835693 ( 1.01%)
read-524288             24653 ( 0.00%)        22519 (-9.48%)
reread-64             2329708 ( 0.00%)      1985134 (-17.36%)
reread-128            1446222 ( 0.00%)      2137031 (32.33%)
reread-256            1828508 ( 0.00%)      1879725 ( 2.72%)
reread-512            1521718 ( 0.00%)      1579934 ( 3.68%)
reread-1024           1347557 ( 0.00%)      1375171 ( 2.01%)
reread-2048           1340664 ( 0.00%)      1350783 ( 0.75%)
reread-4096           1259592 ( 0.00%)      1284839 ( 1.96%)
reread-8192           1007285 ( 0.00%)      1011317 ( 0.40%)
reread-16384           891404 ( 0.00%)       905022 ( 1.50%)
reread-32768           850492 ( 0.00%)       862772 ( 1.42%)
reread-65536           836565 ( 0.00%)       847020 ( 1.23%)
reread-131072          844516 ( 0.00%)       853155 ( 1.01%)
reread-262144          851524 ( 0.00%)       860653 ( 1.06%)
reread-524288           24927 ( 0.00%)        22487 (-10.85%)
randread-64           1605256 ( 0.00%)      1775099 ( 9.57%)
randread-128          1179358 ( 0.00%)      1528576 (22.85%)
randread-256          1421755 ( 0.00%)      1310683 (-8.47%)
randread-512          1306873 ( 0.00%)      1281909 (-1.95%)
randread-1024         1201314 ( 0.00%)      1231629 ( 2.46%)
randread-2048         1179413 ( 0.00%)      1190529 ( 0.93%)
randread-4096         1107005 ( 0.00%)      1116792 ( 0.88%)
randread-8192          894337 ( 0.00%)       899487 ( 0.57%)
randread-16384         783760 ( 0.00%)       791341 ( 0.96%)
randread-32768         740498 ( 0.00%)       743511 ( 0.41%)
randread-65536         721640 ( 0.00%)       728139 ( 0.89%)
randread-131072        715284 ( 0.00%)       720825 ( 0.77%)
randread-262144        709855 ( 0.00%)       714943 ( 0.71%)
randread-524288           394 ( 0.00%)          431 ( 8.58%)
randwrite-64           730988 ( 0.00%)       730988 ( 0.00%)
randwrite-128          746459 ( 0.00%)       742331 (-0.56%)
randwrite-256          695778 ( 0.00%)       727850 ( 4.41%)
randwrite-512          666253 ( 0.00%)       691126 ( 3.60%)
randwrite-1024         651223 ( 0.00%)       659625 ( 1.27%)
randwrite-2048         655558 ( 0.00%)       664073 ( 1.28%)
randwrite-4096         635556 ( 0.00%)       642400 ( 1.07%)
randwrite-8192         467357 ( 0.00%)       469734 ( 0.51%)
randwrite-16384        413188 ( 0.00%)       417282 ( 0.98%)
randwrite-32768        404161 ( 0.00%)       407580 ( 0.84%)
randwrite-65536        379372 ( 0.00%)       381273 ( 0.50%)
randwrite-131072        21780 ( 0.00%)        19758 (-10.23%)
randwrite-262144         6249 ( 0.00%)         6316 ( 1.06%)
randwrite-524288         2915 ( 0.00%)         2859 (-1.96%)
bkwdread-64           1141196 ( 0.00%)      1141196 ( 0.00%)
bkwdread-128          1066865 ( 0.00%)      1101900 ( 3.18%)
bkwdread-256           877797 ( 0.00%)      1105556 (20.60%)
bkwdread-512          1133103 ( 0.00%)      1162547 ( 2.53%)
bkwdread-1024         1163562 ( 0.00%)      1195962 ( 2.71%)
bkwdread-2048         1163439 ( 0.00%)      1204552 ( 3.41%)
bkwdread-4096         1116792 ( 0.00%)      1150600 ( 2.94%)
bkwdread-8192          912288 ( 0.00%)       934724 ( 2.40%)
bkwdread-16384         817707 ( 0.00%)       829152 ( 1.38%)
bkwdread-32768         775898 ( 0.00%)       787691 ( 1.50%)
bkwdread-65536         759643 ( 0.00%)       772174 ( 1.62%)
bkwdread-131072        763215 ( 0.00%)       773816 ( 1.37%)
bkwdread-262144        765491 ( 0.00%)       780021 ( 1.86%)
bkwdread-524288          3688 ( 0.00%)         3724 ( 0.97%)

The first column is "operation-sizeInKB". The other figures are measured
in operations (-O in iozone). It's a little less clear-cut but disabling
low_latency wins more often than not although many of the gains are small and
in the 1-3% range (or is that considered lots in iozone land?)  There were
big gains and losses for some tests but the really big differences were
around 128 bytes so it might be a CPU caching effect.

Running a simulation of multiple instances of gitk and a music player results
in the following

                     gitk-with      gitk-without
                   low-latency       low-latency
min            954.46 ( 0.00%)   640.65 (32.88%)
mean           964.79 ( 0.00%)   655.57 (32.05%)
stddev          10.01 ( 0.00%)    13.33 (-33.18%)
max            981.23 ( 0.00%)   675.65 (31.14%)

The measure is the time taken for the fake-gitk program to complete its job.
Disabling low_latency completes the test far faster. On previous tests,
I had busted networking to do high-order atomic allocations to simualate
wireless cards which are high-order happy. In those tests, disabling
low_latency performed better, produced more stable results, stalled less
(which I think would look like a desktop stall in a normal environment)
and critically, it didn't fail high-order page allocations. i.e. Enabling
low_latency hurts reclaim in some unspecified fashion.

On my laptop (2GB RAM), I find the desktop stalls less when I disable
low_latency in the situation where something kicks off a lot of IO. For
example, if I do a large git operation and switch to a browser while that
is doing its thing, I notice that the desktop sometimes stalls for almost a
second. I do not see this with low_latency disabled but I cannot quantify
this better and it's tricky to reproduce. I also might be fooling myself
because I expect to see problems with low_latency enabled.

I regret that I do not have an explanation as to why low_latency causes
problems other than a hunch that low_latency is preventing page writeback
happening fast enough and that causes stalls later. Theories and patches
welcome but if it cannot be resolved, should the following be applied?

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 block/cfq-iosched.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/block/cfq-iosched.c b/block/cfq-iosched.c
index aa1e953..dc33045 100644
--- a/block/cfq-iosched.c
+++ b/block/cfq-iosched.c
@@ -2543,7 +2543,7 @@ static void *cfq_init_queue(struct request_queue *q)
 	cfqd->cfq_slice[1] = cfq_slice_sync;
 	cfqd->cfq_slice_async_rq = cfq_slice_async_rq;
 	cfqd->cfq_slice_idle = cfq_slice_idle;
-	cfqd->cfq_latency = 1;
+	cfqd->cfq_latency = 0;
 	cfqd->hw_tag = 1;
 	cfqd->last_end_sync_rq = jiffies;
 	return cfqd;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
