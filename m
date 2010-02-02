Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 280E36001DA
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 17:38:14 -0500 (EST)
Date: Tue, 2 Feb 2010 17:38:03 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 00/11] [RFC] 512K readahead size with thrashing safe
	readahead
Message-ID: <20100202223803.GF3922@redhat.com>
References: <20100202152835.683907822@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202152835.683907822@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 11:28:35PM +0800, Wu Fengguang wrote:
> Andrew,
> 
> This is to lift default readahead size to 512KB, which I believe yields
> more I/O throughput without noticeably increasing I/O latency for today's HDD.
> 

Hi Fengguang,

I was doing a quick test with the patches. I was using fio to run some
sequential reader threads. I have got one access to one Lun from an HP
EVA. In my case it looks like with the patches throughput has come down.

Folllowing are the results.

Kernel=2.6.33-rc5 Workload=bsr      iosched=cfq     Filesz=1G   bs=32K
AVERAGE
-------
job       Set NR  ReadBW(KB/s)   MaxClat(us)    WriteBW(KB/s)  MaxClat(us)
---       --- --  ------------   -----------    -------------  -----------
bsr       3   1   141768         130965         0              0
bsr       3   2   131979         135402         0              0
bsr       3   4   132351         420733         0              0
bsr       3   8   133152         455434         0              0
bsr       3   16  130316         674499         0              0

Kernel=2.6.33-rc5-readahead Workload=bsr      iosched=cfq     Filesz=1G  bs=32K
AVERAGE
-------
job       Set NR  ReadBW(KB/s)   MaxClat(us)    WriteBW(KB/s)  MaxClat(us)
---       --- --  ------------   -----------    -------------  -----------
bsr       3   1   84749.3        53213          0              0
bsr       3   2   83189.7        157473         0              0
bsr       3   4   77583.3        330030         0              0
bsr       3   8   88545.7        378201         0              0
bsr       3   16  95331.7        482657         0              0

I run increasing number of sequential readers. File system is ext3 and
filesize is 1G. 

I have run the tests 3 times (3sets) and taken the average of it.

Thanks
Vivek


> For example, for a 100MB/s and 8ms access time HDD:
> 
> io_size KB      access_time   transfer_time  io_latency  util%    throughput KB/s IOPS
> 4               8             0.04           8.04        0.49%    497.57          124.39
> 8               8             0.08           8.08        0.97%    990.33          123.79
> 16              8             0.16           8.16        1.92%    1961.69         122.61
> 32              8             0.31           8.31        3.76%    3849.62         120.30
> 64              8             0.62           8.62        7.25%    7420.29         115.94
> 128             8             1.25           9.25        13.51%   13837.84        108.11
> 256             8             2.50           10.50       23.81%   24380.95        95.24
> 512             8             5.00           13.00       38.46%   39384.62        76.92
> 1024            8             10.00          18.00       55.56%   56888.89        55.56
> 2048            8             20.00          28.00       71.43%   73142.86        35.71
> 4096            8             40.00          48.00       83.33%   85333.33        20.83
> 
> The 128KB => 512KB readahead size boosts IO throughput from ~13MB/s to ~39MB/s, while
> merely increases IO latency from 9.25ms to 13.00ms.
> 
> As for SSD, I find that Intel X25-M SSD desires large readahead size
> even for sequential reads (the first patch has benchmark details):
> 
>         rasize  first run time/throughput       second run time/throughput
>         ------------------------------------------------------------------
>           4k    3.40038 s,      123 MB/s        3.42842 s,      122 MB/s
>           8k    2.7362 s,       153 MB/s        2.74528 s,      153 MB/s
>          16k    2.59808 s,      161 MB/s        2.58728 s,      162 MB/s
>          32k    2.50488 s,      167 MB/s        2.49138 s,      168 MB/s
>          64k    2.12861 s,      197 MB/s        2.13055 s,      197 MB/s
>         128k    1.92905 s,      217 MB/s        1.93176 s,      217 MB/s
>         256k    1.75896 s,      238 MB/s        1.78963 s,      234 MB/s
>         512k    1.67357 s,      251 MB/s        1.69112 s,      248 MB/s
>           1M    1.62115 s,      259 MB/s        1.63206 s,      257 MB/s
>           2M    1.56204 s,      269 MB/s        1.58854 s,      264 MB/s
>           4M    1.57949 s,      266 MB/s        1.57426 s,      266 MB/s
> 
> As suggested by Linus, decrease default readahead size for small devices at the same time.
> 
> 	[PATCH 01/11] readahead: limit readahead size for small devices
> 	[PATCH 02/11] readahead: bump up the default readahead size
> 	[PATCH 03/11] readahead: introduce {MAX|MIN}_READAHEAD_PAGES macros for ease of use
> 
> The two other impacts of an enlarged readahead size are
> 
> - memory footprint (caused by readahead miss)
> 	Sequential readahead hit ratio is pretty high regardless of max
> 	readahead size; the extra memory footprint is mainly caused by
> 	enlarged mmap read-around.
> 	I measured my desktop:
> 	- under Xwindow:
> 		128KB readahead cache hit ratio = 143MB/230MB = 62%
> 		512KB readahead cache hit ratio = 138MB/248MB = 55%
> 	- under console: (seems more stable than the Xwindow data)
> 		128KB readahead cache hit ratio = 30MB/56MB   = 53%
> 		  1MB readahead cache hit ratio = 30MB/59MB   = 51%
> 	So the impact to memory footprint looks acceptable.
> 
> - readahead thrashing
> 	It will now cost 1MB readahead buffer per stream.  Memory tight systems
> 	typically do not run multiple streams; but if they do so, it should
> 	help I/O performance as long as we can avoid thrashing, which can be
> 	achieved with the following patches.
> 
> 	[PATCH 04/11] readahead: replace ra->mmap_miss with ra->ra_flags
> 	[PATCH 05/11] readahead: retain inactive lru pages to be accessed soon
> 	[PATCH 06/11] readahead: thrashing safe context readahead
> 
> This is a major rewrite of the readahead algorithm, so I did careful tests with
> the following tracing/stats patches:
> 
> 	[PATCH 07/11] readahead: record readahead patterns
> 	[PATCH 08/11] readahead: add tracing event
> 	[PATCH 09/11] readahead: add /debug/readahead/stats
> 
> I verified the new readahead behavior on various access patterns,
> as well as stress tested the thrashing safety, by running 300 streams
> with mem=128M.
> 
> Only 2031/61325=3.3% readahead windows are thrashed (due to workload
> variation):
> 
> # cat /debug/readahead/stats
> pattern     readahead    eof_hit  cache_hit         io    sync_io    mmap_io       size async_size    io_size
> initial            20          9          4         20         20         12         73         37         35
> subsequent          3          3          0          1          0          1          8          8          1
> context         61325          1       5479      61325       6788          5         14          2         13
> thrash           2031          0       1222       2031       2031          0          9          0          6
> around            235         90        142        235        235        235         60          0         19
> fadvise             0          0          0          0          0          0          0          0          0
> random            223        133          0         91         91          1          1          0          1
> all             63837        236       6847      63703       9165          0         14          2         13
> 
> And the readahead inside a single stream is working as expected:
> 
> # grep streams-3162 /debug/tracing/trace
>          streams-3162  [000]  8602.455953: readahead: readahead-context(dev=0:2, ino=0, req=287352+1, ra=287354+10-2, async=1) = 10
>          streams-3162  [000]  8602.907873: readahead: readahead-context(dev=0:2, ino=0, req=287362+1, ra=287364+20-3, async=1) = 20
>          streams-3162  [000]  8604.027879: readahead: readahead-context(dev=0:2, ino=0, req=287381+1, ra=287384+14-2, async=1) = 14
>          streams-3162  [000]  8604.754722: readahead: readahead-context(dev=0:2, ino=0, req=287396+1, ra=287398+10-2, async=1) = 10
>          streams-3162  [000]  8605.191228: readahead: readahead-context(dev=0:2, ino=0, req=287406+1, ra=287408+18-3, async=1) = 18
>          streams-3162  [000]  8606.831895: readahead: readahead-context(dev=0:2, ino=0, req=287423+1, ra=287426+12-2, async=1) = 12
>          streams-3162  [000]  8606.919614: readahead: readahead-thrash(dev=0:2, ino=0, req=287425+1, ra=287425+8-0, async=0) = 1
>          streams-3162  [000]  8607.545016: readahead: readahead-context(dev=0:2, ino=0, req=287436+1, ra=287438+9-2, async=1) = 9
>          streams-3162  [000]  8607.960039: readahead: readahead-context(dev=0:2, ino=0, req=287445+1, ra=287447+18-3, async=1) = 18
>          streams-3162  [000]  8608.790973: readahead: readahead-context(dev=0:2, ino=0, req=287462+1, ra=287465+21-3, async=1) = 21
>          streams-3162  [000]  8609.763138: readahead: readahead-context(dev=0:2, ino=0, req=287483+1, ra=287486+15-2, async=1) = 15
>          streams-3162  [000]  8611.467401: readahead: readahead-context(dev=0:2, ino=0, req=287499+1, ra=287501+11-2, async=1) = 11
>          streams-3162  [000]  8642.512413: readahead: readahead-context(dev=0:2, ino=0, req=288053+1, ra=288056+10-2, async=1) = 10
>          streams-3162  [000]  8643.246618: readahead: readahead-context(dev=0:2, ino=0, req=288064+1, ra=288066+22-3, async=1) = 22
>          streams-3162  [000]  8644.278613: readahead: readahead-context(dev=0:2, ino=0, req=288085+1, ra=288088+16-3, async=1) = 16
>          streams-3162  [000]  8644.395782: readahead: readahead-context(dev=0:2, ino=0, req=288087+1, ra=288087+21-3, async=0) = 5
>          streams-3162  [000]  8645.109918: readahead: readahead-context(dev=0:2, ino=0, req=288101+1, ra=288108+8-1, async=1) = 8
>          streams-3162  [000]  8645.285078: readahead: readahead-context(dev=0:2, ino=0, req=288105+1, ra=288116+8-1, async=1) = 8
>          streams-3162  [000]  8645.731794: readahead: readahead-context(dev=0:2, ino=0, req=288115+1, ra=288122+14-2, async=1) = 13
>          streams-3162  [000]  8646.114250: readahead: readahead-context(dev=0:2, ino=0, req=288123+1, ra=288136+8-1, async=1) = 8
>          streams-3162  [000]  8646.626320: readahead: readahead-context(dev=0:2, ino=0, req=288134+1, ra=288144+16-3, async=1) = 16
>          streams-3162  [000]  8647.035721: readahead: readahead-context(dev=0:2, ino=0, req=288143+1, ra=288160+10-2, async=1) = 10
>          streams-3162  [000]  8647.693082: readahead: readahead-context(dev=0:2, ino=0, req=288157+1, ra=288165+12-2, async=1) = 8
>          streams-3162  [000]  8648.221368: readahead: readahead-context(dev=0:2, ino=0, req=288168+1, ra=288177+15-2, async=1) = 15
>          streams-3162  [000]  8649.280800: readahead: readahead-context(dev=0:2, ino=0, req=288190+1, ra=288192+23-3, async=1) = 23
> 	 [...]
> 
> btw, Linus suggested to disable start-of-file readahead if lseek() has been called:
> 
> 	[PATCH 10/11] readahead: dont do start-of-file readahead after lseek()
> 
> At last, the updated context readahead will do more radix tree scans, so need
> to optimize radix_tree_prev_hole():
> 
> 	[PATCH 11/11] radixtree: speed up next/prev hole search
> 
> It will on average reduce 8*64 level-0 slot searches to 32 level-0 slot
> plus 8 level-1 node searches.
> 
> Thanks,
> Fengguang
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
