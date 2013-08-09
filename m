Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id D3D526B0031
	for <linux-mm@kvack.org>; Fri,  9 Aug 2013 04:03:43 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id oy10so3700627veb.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2013 01:03:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
Date: Fri, 9 Aug 2013 16:03:42 +0800
Message-ID: <CAA_GA1dTJAJ2K101PwryrCnrE3t0y_EMRz_ttJ3LjBGFiyGp-g@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, Pekka Enberg <penberg@kernel.org>, Bob Liu <bob.liu@oracle.com>

Another test case running sysbench only showed that the average time
per request and transactions per second got around 7% faster!
bootcmdline: mem=1G zcache.enabled=1 single

sysbench --test=oltp --oltp-table-size=15000000 --oltp-read-only=off \
--init-rng=on --num-threads=16 --max-requests=0 \
--oltp-dist-type=special --oltp-dist-pct=10 \
--max-time=7200 --db-driver=mysql --mysql-table-engine=innodb \
--mysql-user=root \
--mysql-password=xxxx --oltp-test-mode=complex run

                                Without zcache        With zcache
OLTP test statistics:
    queries performed:
        read:                  2238446                   2402372(+7%)
        write:                  799445                    857990
        other:                  319778                    343196
        total:                 3357669                   3603558
    transactions:               159889(22.20 per sec.)    171598(23.83
per sec.) (+7%)
    deadlocks:                       0(0.00 per sec.)          0(0.00 per sec.)
    read/write requests:       3037891(421.87 per sec.)
3260362(452.70 per sec.)(+7%)
    other operations:           319778(44.41 per sec.)    343196(47.65
per sec.) (+7%)

Test execution summary:
    total time:                   7201.0705s                7202.0176s
    total number of events:     159889                    171598
    total time taken by event execution:
                                115204.6708              115219.8235
    per-request statistics:
         min:                       94.25ms                  57.80ms (+38%)
         avg:                      720.53ms                 671.45ms (+7%)
         max:                    10684.90ms                7892.48ms (+26%)
         approx.  95 percentile:  1678.39ms                1699.62ms

Threads fairness:
    events (avg/stddev):          9993.0625/28.05          10724.87500/30.32
    execution time (avg/stddev):  7200.2919/0.30            7201.2390/0.48

By comparing /proc/vmstat, there is around 14G data reading are saved
if enabled zcache!
I believe zcache can also be helpful for many other file memory hungry
applications and it do no harm for other users!
Looking forward any feedback!

On Tue, Aug 6, 2013 at 7:36 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Overview:
> Zcache is a in kernel compressed cache for file pages.
> It takes active file pages that are in the process of being reclaimed and
> attempts to compress them into a dynamically allocated RAM-based memory pool.
>
> If this process is successful, when those file pages needed again, the I/O
> reading operation was avoided. This results in a significant performance gains
> under memory pressure for systems full with file pages.
>
> History:
> Nitin Gupta started zcache in 2010:
> http://lwn.net/Articles/397574/
> http://lwn.net/Articles/396467/
>
> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
> It's located in drivers/staging/zcache now. But the current version of zcache is
> too complicated to be merged into upstream.
>
> Seth Jennings implemented a lightweight compressed cache for swap pages(zswap)
> only which was merged into v3.11-rc1 together with a zbud allocation.
>
> What I'm trying is reimplement a simple zcache for file pages only, based on the
> same zbud alloction layer. We can merge zswap and zcache to current zcache in
> staging if there is the requirement in future.
>
> Who can benefit:
> Applications like database which have a lot of file page data in memory, but
> during memory pressure some of those file pages will be reclaimed after their
> data are synced to disk. The data need to be reread into memory when they are
> required again. This may increse the transaction latency and cause performance
> drop. But with zcache, those data are compressed in memory. Only decompressing
> is needed instead of reading from disk!
>
> Other users with limited RAM capacities can also mitigate the performance impact
> of memory pressue if there are many file pages in memory.
>
> Design:
> Zcache receives pages for compression through the Cleancache API and is able to
> evict pages from its own compressed pool on an LRU basis in the case that the
> compressed pool is full.
>
> Zcache makes use of zbud for the managing the compressed memory pool. Each
> allocation in zbud is not directly accessible by address.  Rather, a handle is
> returned(zaddr) by the allocation routine and that handle(zaddr) must be mapped
> before being accessed. The compressed memory pool grows on demand and shrinks
> as compressed pages are freed.
>
> When a file page is passed from cleancache to zcache, zcache maintains a mapping
> of the <filesystem_type, inode_number, page_index> to the zbud address that
> references that compressed file page. This mapping is achieved with a red-black
> tree per filesystem type, plus a radix tree per red-black node.
>
> A zcache pool with pool_id as the index is created when a filesystem mounted.
> Each zcache pool has a red-black tree, the inode number is the search key.
> Each red-black tree node has a radix tree which use page index as the index.
> Each radix tree slot points to the zbud address combining with some extra
> information.
>
> A debugfs interface is provided for various statistic about zcache pool size,
> number of pages stored, loaded and evicted.
>
> Performance, Kernel Building:
>
> Setup
> ========
> Ubuntu with kernel v3.11-rc1
> Quad-core i5-3320 @ 2.6GHz
> 1G memory size(limited with mem=1G on boot)
> started kernbench with -o N(numbers of threads)
>
> Details
> ========
>           Without zcache    With zcache
>
> 8 threads
> Elapsed Time        1821              1814(+0.3%)
> User Time           5332              5304
> System Time          256               306
> Percent CPU          306               306
> Context Switches 1915378           1912027
> Sleeps           1501004           1492835
>
> Nr pages succ decompress from zcache
>                        -              8295
>
> 24 threads
> Elapsed Time        2556              2256(+11.7%)
> User Time           5184              5225
> System Time          271               276
> Percent CPU          213               243
> Context Switches 1993763           2024661
> Sleeps           2000881           1849496
>
> Nr pages succ decompress from zcache
>                        -            174490
>
> 36 threads
> Elapsed Time        5254              3995(+23.9%)
> User Time           4781              4947
> System Time          293               295
> Percent CPU           96               131
> Context Switches 1612581           1779860
> Sleeps           2944985           2414438
>
> Nr pages succ decompress from zcache
>                        -            380470
>
>
> Performance, Sysbench+mysql:
>
> Setup
> ========
> Ubuntu with kernel v3.11-rc1
> Quad-core i5-3320 @ 2.6GHz
> 2G memory size(limited with mem=2G on boot)
> Run sysbench in oltp complex mode for 1 hour:
> sysbench --test=oltp --oltp-table-size=5000000 --num-threads=16  --max-time=3600
> --oltp-test-mode=complex...
>
> After sysbench started, run iozone to trigger memory pressure:
> iozone -a -M -B -s 1200M -y 4k -+u
>
> Sysbench result
> ========
>                                 Without zcache          With zcache
> OLTP test statistics:
>     queries performed:
>         read:                   124320                  166936
>         write:                   44400                   59620
>         other:                   17760                   23848
>         total:                  186480                  250404
>     transactions:                 8880(2.47 per sec.)    11924(3.31 per sec.) (+34%)
>     deadlocks:                       0(0.00 per sec.)        0(0.00 per sec.)
>     read/write requests:        168720(46.86 per sec.)  226556(62.91 per sec.)(+34%)
>     other operations:            17760(4.93 per sec.)    23848(6.62 per sec.) (+34%)
>
> Test execution summary:
>     total time:                   3600.8528s              3601.3977s
>     total number of events:       8880                   11924
>     total time taken by event execution:
>                                  57610.3546              57612.9163
>     per-request statistics:
>          min:                       57.68ms                 49.52ms (+14%)
>          avg:                     6487.65ms               4831.68ms (+25%)
>          max:                   169640.52ms             124282.16ms (+42%)
>          approx.  95 percentile: 25139.93ms              21794.82ms (+13%)
>
> Threads fairness:
>     events (avg/stddev):           555.0000/6.05           745.2500/8.33
>     execution time (avg/stddev):  3600.6472/0.26          3600.8073/0.27
>
> Welcome helps with testing, it would be intersting to find zcache's effect in
> more real life workloads.
>
> Bob Liu (4):
>   mm: zcache: add core files
>   zcache: staging: %s/ZCACHE/ZCACHE_OLD
>   mm: zcache: add evict zpages supporting
>   mm: add WasActive page flag
>
>  drivers/staging/zcache/Kconfig  |   12 +-
>  drivers/staging/zcache/Makefile |    4 +-
>  include/linux/page-flags.h      |    9 +-
>  mm/Kconfig                      |   17 +
>  mm/Makefile                     |    1 +
>  mm/page_alloc.c                 |    3 +
>  mm/vmscan.c                     |    2 +
>  mm/zcache.c                     |  944 +++++++++++++++++++++++++++++++++++++++
>  8 files changed, 983 insertions(+), 9 deletions(-)
>  create mode 100644 mm/zcache.c
>
> --
> 1.7.10.4
>
-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
