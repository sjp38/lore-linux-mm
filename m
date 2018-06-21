Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9C846B000A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 21:17:31 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y184-v6so1209459qka.18
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 18:17:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u12-v6si3672542qtj.363.2018.06.20.18.17.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 18:17:29 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:17:05 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180621011656.GA15427@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <CAJX1YtaRtCGt7f8H0VEDrDkcOYusB0JoL-CNB_E--MYGhcvbow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJX1YtaRtCGt7f8H0VEDrDkcOYusB0JoL-CNB_E--MYGhcvbow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gi-Oh Kim <gi-oh.kim@profitbricks.com>
Cc: Jens Axboe <axboe@fb.com>, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, kent.overstreet@gmail.com, dsterba@suse.cz, ying.huang@intel.com, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu, darrick.wong@oracle.com, colyli@suse.de, fdmanana@gmail.com, rdunlap@infradead.org

On Fri, Jun 15, 2018 at 02:59:19PM +0200, Gi-Oh Kim wrote:
> >
> > - bio size can be increased and it should improve some high-bandwidth IO
> > case in theory[4].
> >
> 
> Hi,
> 
> I would like to report your patch set works well on my system based on v4.14.48.
> I thought the multipage bvec could improve the performance of my system.
> (FYI, my system has v4.14.48 and provides KVM-base virtualization service.)

Thanks for your test!

> 
> So I did back-porting your patches to v4.14.48.
> It has done without any serious problem.
> I only needed to cherry-pick "blk-merge: compute
> bio->bi_seg_front_size efficiently" and
> "block: move bio_alloc_pages() to bcache" patches before back-porting
> to prevent conflicts.

Not sure I understand your point, you have to backport all patches.

> And I ran my own test-suit for checking features of md and RAID1 layer.
> There was no problem. All test cases passed.
> (If you want, I will send you the back-ported patches.)
> 
> Then I did two performance test as following.
> To say the conclusion first, I failed to show performance improvement
> of the patch set.
> Of course, my test cases would not be suitable to test your patch set.
> Or maybe I did test wrong.
> Please inform me which tools are suitable, then I will try them.
> 
> 1. fio
> 
> First I ran fio with null device to check the performance of the block-layer.
> I am not sure those test is suitable to show the performance
> improvement or degradation.
> Nevertheless there was a little (-6%) performance degradation.
> 
> If it is not much trouble to you, please review my options for fio and
> inform me if I used wrong or incorrect options.
> Then I will run the test again.
> 
> 1.1 Following is my options for fio.
> 
> gkim@ib1:~/pb-ltp/benchmark/fio$ cat go_local.sh
> #!/bin/bash
> echo "fio start   : $(date)"
> echo "kernel info : $(uname -a)"
> echo "fio version : $(fio --version)"
> 
> # set "none" io-scheduler
> modprobe -r null_blk
> modprobe null_blk
> echo "none" > /sys/block/nullb0/queue/scheduler
> 
> FIO_OPTION="--direct=1 --rw=randrw:2 --time_based=1 --group_reporting \
>             --ioengine=libaio --iodepth=64 --name=fiotest --numjobs=8 \
>             --bssplit=512/20:1k/16:2k/9:4k/12:8k/19:16k/10:32k/8:64k/4 \
>             --fadvise_hint=0 --iodepth_batch_submit=64
> --iodepth_batch_complete=64"
> # fio test null_blk device, so it is not necessary to run long.
> fio $FIO_OPTION --filename=/dev/nullb0 --runtime=600
> 
> 1.2 Following is the result before porting.
> 
> fio start   : Mon Jun 11 04:30:01 CEST 2018
> kernel info : Linux ib1 4.14.48-1-pserver
> #4.14.48-1.1+feature+daily+update+20180607.0857+1bbde0b~deb8 SMP
> x86_64 GNU/Linux
> fio version : fio-2.2.10
> fiotest: (g=0): rw=randrw, bs=512-64K/512-64K/512-64K,
> ioengine=libaio, iodepth=64
> ...
> fio-2.2.10
> Starting 8 processes
> 
> fiotest: (groupid=0, jobs=8): err= 0: pid=1655: Mon Jun 11 04:40:02 2018
>   read : io=7133.2GB, bw=12174MB/s, iops=1342.1K, runt=600001msec
>     slat (usec): min=1, max=15750, avg=123.78, stdev=153.79
>     clat (usec): min=0, max=15758, avg=24.70, stdev=77.93
>      lat (usec): min=2, max=15782, avg=148.49, stdev=167.54
>     clat percentiles (usec):
>      |  1.00th=[    0],  5.00th=[    1], 10.00th=[    1], 20.00th=[    1],
>      | 30.00th=[    2], 40.00th=[    2], 50.00th=[    2], 60.00th=[    6],
>      | 70.00th=[   22], 80.00th=[   36], 90.00th=[   72], 95.00th=[  107],
>      | 99.00th=[  173], 99.50th=[  203], 99.90th=[  932], 99.95th=[ 1416],
>      | 99.99th=[ 2960]
>     bw (MB  /s): min= 1096, max= 2147, per=12.51%, avg=1522.69, stdev=253.89
>   write: io=7131.3GB, bw=12171MB/s, iops=1343.6K, runt=600001msec
>     slat (usec): min=1, max=15751, avg=124.73, stdev=154.11
>     clat (usec): min=0, max=15758, avg=24.69, stdev=77.84
>      lat (usec): min=2, max=15780, avg=149.43, stdev=167.82
>     clat percentiles (usec):
>      |  1.00th=[    0],  5.00th=[    1], 10.00th=[    1], 20.00th=[    1],
>      | 30.00th=[    2], 40.00th=[    2], 50.00th=[    2], 60.00th=[    6],
>      | 70.00th=[   22], 80.00th=[   36], 90.00th=[   72], 95.00th=[  107],
>      | 99.00th=[  173], 99.50th=[  203], 99.90th=[  932], 99.95th=[ 1416],
>      | 99.99th=[ 2960]
>     bw (MB  /s): min= 1080, max= 2121, per=12.51%, avg=1522.33, stdev=253.96
>     lat (usec) : 2=21.63%, 4=37.80%, 10=2.12%, 20=6.43%, 50=16.70%
>     lat (usec) : 100=8.86%, 250=6.07%, 500=0.17%, 750=0.08%, 1000=0.05%
>     lat (msec) : 2=0.06%, 4=0.02%, 10=0.01%, 20=0.01%
>   cpu          : usr=22.39%, sys=64.19%, ctx=15425825, majf=0, minf=97
>   IO depths    : 1=1.8%, 2=1.8%, 4=8.8%, 8=14.4%, 16=12.3%, 32=41.7%, >=64=19.3%
>      submit    : 0=0.0%, 4=5.8%, 8=9.7%, 16=15.0%, 32=18.0%, 64=51.5%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.1%, 8=0.0%, 16=0.1%, 32=0.1%, 64=100.0%, >=64=0.0%
>      issued    : total=r=805764385/w=806127393/d=0, short=r=0/w=0/d=0,
> drop=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=64
> 
> Run status group 0 (all jobs):
>    READ: io=7133.2GB, aggrb=12174MB/s, minb=12174MB/s, maxb=12174MB/s,
> mint=600001msec, maxt=600001msec
>   WRITE: io=7131.3GB, aggrb=12171MB/s, minb=12171MB/s, maxb=12171MB/s,
> mint=600001msec, maxt=600001msec
> 
> Disk stats (read/write):
>   nullb0: ios=442461761/442546060, merge=363197836/363473703,
> ticks=12280990/12452480, in_queue=2740, util=0.43%
> 
> 1.3 Following is the result after porting.
> 
> fio start   : Fri Jun 15 12:42:47 CEST 2018
> kernel info : Linux ib1 4.14.48-1-pserver-mpbvec+ #12 SMP Fri Jun 15
> 12:21:36 CEST 2018 x86_64 GNU/Linux
> fio version : fio-2.2.10
> fiotest: (g=0): rw=randrw, bs=512-64K/512-64K/512-64K,
> ioengine=libaio, iodepth=64
> ...
> fio-2.2.10
> Starting 8 processes
> Jobs: 4 (f=0): [m(1),_(2),m(1),_(1),m(2),_(1)] [100.0% done]
> [8430MB/8444MB/0KB /s] [961K/963K/0 iops] [eta 00m:00s]
> fiotest: (groupid=0, jobs=8): err= 0: pid=14096: Fri Jun 15 12:52:48 2018
>   read : io=6633.8GB, bw=11322MB/s, iops=1246.9K, runt=600005msec
>     slat (usec): min=1, max=16939, avg=135.34, stdev=156.23
>     clat (usec): min=0, max=16947, avg=26.10, stdev=78.50
>      lat (usec): min=2, max=16957, avg=161.45, stdev=168.88
>     clat percentiles (usec):
>      |  1.00th=[    0],  5.00th=[    1], 10.00th=[    1], 20.00th=[    1],
>      | 30.00th=[    2], 40.00th=[    2], 50.00th=[    2], 60.00th=[    5],
>      | 70.00th=[   23], 80.00th=[   37], 90.00th=[   79], 95.00th=[  115],
>      | 99.00th=[  181], 99.50th=[  211], 99.90th=[  948], 99.95th=[ 1416],
>      | 99.99th=[ 2864]
>     bw (MB  /s): min= 1106, max= 2031, per=12.51%, avg=1416.05, stdev=201.81
>   write: io=6631.1GB, bw=11318MB/s, iops=1247.5K, runt=600005msec
>     slat (usec): min=1, max=16938, avg=136.48, stdev=156.54
>     clat (usec): min=0, max=16947, avg=26.08, stdev=78.43
>      lat (usec): min=2, max=16957, avg=162.58, stdev=169.15
>     clat percentiles (usec):
>      |  1.00th=[    0],  5.00th=[    1], 10.00th=[    1], 20.00th=[    1],
>      | 30.00th=[    2], 40.00th=[    2], 50.00th=[    2], 60.00th=[    5],
>      | 70.00th=[   23], 80.00th=[   37], 90.00th=[   79], 95.00th=[  115],
>      | 99.00th=[  181], 99.50th=[  211], 99.90th=[  948], 99.95th=[ 1416],
>      | 99.99th=[ 2864]
>     bw (MB  /s): min= 1084, max= 2044, per=12.51%, avg=1415.67, stdev=201.93
>     lat (usec) : 2=20.98%, 4=38.82%, 10=2.15%, 20=5.08%, 50=16.91%
>     lat (usec) : 100=8.75%, 250=6.91%, 500=0.19%, 750=0.09%, 1000=0.05%
>     lat (msec) : 2=0.07%, 4=0.02%, 10=0.01%, 20=0.01%
>   cpu          : usr=21.02%, sys=65.53%, ctx=15321661, majf=0, minf=78
>   IO depths    : 1=1.9%, 2=1.9%, 4=9.5%, 8=13.6%, 16=11.2%, 32=42.1%, >=64=19.9%
>      submit    : 0=0.0%, 4=6.3%, 8=10.1%, 16=14.1%, 32=18.2%,
> 64=51.3%, >=64=0.0%
>      complete  : 0=0.0%, 4=0.1%, 8=0.0%, 16=0.1%, 32=0.1%, 64=100.0%, >=64=0.0%
>      issued    : total=r=748120019/w=748454509/d=0, short=r=0/w=0/d=0,
> drop=r=0/w=0/d=0
>      latency   : target=0, window=0, percentile=100.00%, depth=64
> 
> Run status group 0 (all jobs):
>    READ: io=6633.8GB, aggrb=11322MB/s, minb=11322MB/s, maxb=11322MB/s,
> mint=600005msec, maxt=600005msec
>   WRITE: io=6631.1GB, aggrb=11318MB/s, minb=11318MB/s, maxb=11318MB/s,
> mint=600005msec, maxt=600005msec
> 
> Disk stats (read/write):
>   nullb0: ios=410911387/410974086, merge=337127604/337396176,
> ticks=12482050/12662790, in_queue=1780, util=0.27%
> 
> 
> 2. Unixbench
> 
> Second I rand Unixbench to check general performance.
> I think there is no difference before and after porting the patches.
> Unixbench might not be suitable to check the performance improvement
> of the block layer.
> If you inform me which tools is suitable, I will try it on my system.
> 
> 2.1 Following is the result before porting.
> 
>    BYTE UNIX Benchmarks (Version 5.1.3)
> 
>    System: ib1: GNU/Linux
>    OS: GNU/Linux -- 4.14.48-1-pserver --
> #4.14.48-1.1+feature+daily+update+20180607.0857+1bbde0b~deb8 SMP
>    Machine: x86_64 (unknown)
>    Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")
>    CPU 0: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 1: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 2: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 3: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 4: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 5: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 6: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 7: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    05:00:01 up 3 days, 16:20,  2 users,  load average: 0.00, 0.11,
> 1.11; runlevel 2018-06-07
> 
> ------------------------------------------------------------------------
> Benchmark Run: Mon Jun 11 2018 05:00:01 - 05:28:54
> 8 CPUs in system; running 1 parallel copy of tests
> 
> Dhrystone 2 using register variables       47158867.7 lps   (10.0 s, 7 samples)
> Double-Precision Whetstone                     3878.8 MWIPS (15.2 s, 7 samples)
> Execl Throughput                               9203.9 lps   (30.0 s, 2 samples)
> File Copy 1024 bufsize 2000 maxblocks       1490834.8 KBps  (30.0 s, 2 samples)
> File Copy 256 bufsize 500 maxblocks          388784.2 KBps  (30.0 s, 2 samples)
> File Copy 4096 bufsize 8000 maxblocks       3744780.2 KBps  (30.0 s, 2 samples)
> Pipe Throughput                             2682620.1 lps   (10.0 s, 7 samples)
> Pipe-based Context Switching                 263786.5 lps   (10.0 s, 7 samples)
> Process Creation                              19674.0 lps   (30.0 s, 2 samples)
> Shell Scripts (1 concurrent)                  16121.5 lpm   (60.0 s, 2 samples)
> Shell Scripts (8 concurrent)                   5623.5 lpm   (60.0 s, 2 samples)
> System Call Overhead                        4068991.3 lps   (10.0 s, 7 samples)
> 
> System Benchmarks Index Values               BASELINE       RESULT    INDEX
> Dhrystone 2 using register variables         116700.0   47158867.7   4041.0
> Double-Precision Whetstone                       55.0       3878.8    705.2
> Execl Throughput                                 43.0       9203.9   2140.4
> File Copy 1024 bufsize 2000 maxblocks          3960.0    1490834.8   3764.7
> File Copy 256 bufsize 500 maxblocks            1655.0     388784.2   2349.1
> File Copy 4096 bufsize 8000 maxblocks          5800.0    3744780.2   6456.5
> Pipe Throughput                               12440.0    2682620.1   2156.4
> Pipe-based Context Switching                   4000.0     263786.5    659.5
> Process Creation                                126.0      19674.0   1561.4
> Shell Scripts (1 concurrent)                     42.4      16121.5   3802.2
> Shell Scripts (8 concurrent)                      6.0       5623.5   9372.5
> System Call Overhead                          15000.0    4068991.3   2712.7
>                                                                    ========
> System Benchmarks Index Score                                        2547.7
> 
> ------------------------------------------------------------------------
> Benchmark Run: Mon Jun 11 2018 05:28:54 - 05:57:07
> 8 CPUs in system; running 8 parallel copies of tests
> 
> Dhrystone 2 using register variables      234727639.9 lps   (10.0 s, 7 samples)
> Double-Precision Whetstone                    35350.9 MWIPS (10.7 s, 7 samples)
> Execl Throughput                              43811.3 lps   (30.0 s, 2 samples)
> File Copy 1024 bufsize 2000 maxblocks       1401373.1 KBps  (30.0 s, 2 samples)
> File Copy 256 bufsize 500 maxblocks          366033.9 KBps  (30.0 s, 2 samples)
> File Copy 4096 bufsize 8000 maxblocks       4360829.6 KBps  (30.0 s, 2 samples)
> Pipe Throughput                            12875165.6 lps   (10.0 s, 7 samples)
> Pipe-based Context Switching                2431725.6 lps   (10.0 s, 7 samples)
> Process Creation                              97360.8 lps   (30.0 s, 2 samples)
> Shell Scripts (1 concurrent)                  58879.6 lpm   (60.0 s, 2 samples)
> Shell Scripts (8 concurrent)                   9232.5 lpm   (60.0 s, 2 samples)
> System Call Overhead                        9497958.7 lps   (10.0 s, 7 samples)
> 
> System Benchmarks Index Values               BASELINE       RESULT    INDEX
> Dhrystone 2 using register variables         116700.0  234727639.9  20113.8
> Double-Precision Whetstone                       55.0      35350.9   6427.4
> Execl Throughput                                 43.0      43811.3  10188.7
> File Copy 1024 bufsize 2000 maxblocks          3960.0    1401373.1   3538.8
> File Copy 256 bufsize 500 maxblocks            1655.0     366033.9   2211.7
> File Copy 4096 bufsize 8000 maxblocks          5800.0    4360829.6   7518.7
> Pipe Throughput                               12440.0   12875165.6  10349.8
> Pipe-based Context Switching                   4000.0    2431725.6   6079.3
> Process Creation                                126.0      97360.8   7727.0
> Shell Scripts (1 concurrent)                     42.4      58879.6  13886.7
> Shell Scripts (8 concurrent)                      6.0       9232.5  15387.5
> System Call Overhead                          15000.0    9497958.7   6332.0
>                                                                    ========
> System Benchmarks Index Score                                        7803.5
> 
> 
> 2.2 Following is the result after porting.
> 
>    BYTE UNIX Benchmarks (Version 5.1.3)
> 
>    System: ib1: GNU/Linux
>    OS: GNU/Linux -- 4.14.48-1-pserver-mpbvec+ -- #12 SMP Fri Jun 15
> 12:21:36 CEST 2018
>    Machine: x86_64 (unknown)
>    Language: en_US.utf8 (charmap="UTF-8", collate="UTF-8")
>    CPU 0: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 1: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 2: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 3: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 4: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 5: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 6: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    CPU 7: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
>           Hyper-Threading, x86-64, MMX, Physical Address Ext,
> SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
>    13:16:11 up 50 min,  1 user,  load average: 0.00, 1.40, 3.46;
> runlevel 2018-06-15
> 
> ------------------------------------------------------------------------
> Benchmark Run: Fri Jun 15 2018 13:16:11 - 13:45:04
> 8 CPUs in system; running 1 parallel copy of tests
> 
> Dhrystone 2 using register variables       47103754.6 lps   (10.0 s, 7 samples)
> Double-Precision Whetstone                     3886.3 MWIPS (15.1 s, 7 samples)
> Execl Throughput                               8965.0 lps   (30.0 s, 2 samples)
> File Copy 1024 bufsize 2000 maxblocks       1510285.9 KBps  (30.0 s, 2 samples)
> File Copy 256 bufsize 500 maxblocks          395196.9 KBps  (30.0 s, 2 samples)
> File Copy 4096 bufsize 8000 maxblocks       3802788.0 KBps  (30.0 s, 2 samples)
> Pipe Throughput                             2670169.1 lps   (10.0 s, 7 samples)
> Pipe-based Context Switching                 275093.8 lps   (10.0 s, 7 samples)
> Process Creation                              19707.1 lps   (30.0 s, 2 samples)
> Shell Scripts (1 concurrent)                  16046.8 lpm   (60.0 s, 2 samples)
> Shell Scripts (8 concurrent)                   5600.8 lpm   (60.0 s, 2 samples)
> System Call Overhead                        4104142.0 lps   (10.0 s, 7 samples)
> 
> System Benchmarks Index Values               BASELINE       RESULT    INDEX
> Dhrystone 2 using register variables         116700.0   47103754.6   4036.3
> Double-Precision Whetstone                       55.0       3886.3    706.6
> Execl Throughput                                 43.0       8965.0   2084.9
> File Copy 1024 bufsize 2000 maxblocks          3960.0    1510285.9   3813.9
> File Copy 256 bufsize 500 maxblocks            1655.0     395196.9   2387.9
> File Copy 4096 bufsize 8000 maxblocks          5800.0    3802788.0   6556.5
> Pipe Throughput                               12440.0    2670169.1   2146.4
> Pipe-based Context Switching                   4000.0     275093.8    687.7
> Process Creation                                126.0      19707.1   1564.1
> Shell Scripts (1 concurrent)                     42.4      16046.8   3784.6
> Shell Scripts (8 concurrent)                      6.0       5600.8   9334.6
> System Call Overhead                          15000.0    4104142.0   2736.1
>                                                                    ========
> System Benchmarks Index Score                                        2560.0
> 
> ------------------------------------------------------------------------
> Benchmark Run: Fri Jun 15 2018 13:45:04 - 14:13:17
> 8 CPUs in system; running 8 parallel copies of tests
> 
> Dhrystone 2 using register variables      237271982.6 lps   (10.0 s, 7 samples)
> Double-Precision Whetstone                    35186.8 MWIPS (10.7 s, 7 samples)
> Execl Throughput                              42557.8 lps   (30.0 s, 2 samples)
> File Copy 1024 bufsize 2000 maxblocks       1403922.0 KBps  (30.0 s, 2 samples)
> File Copy 256 bufsize 500 maxblocks          367436.5 KBps  (30.0 s, 2 samples)
> File Copy 4096 bufsize 8000 maxblocks       4380468.3 KBps  (30.0 s, 2 samples)
> Pipe Throughput                            12872664.6 lps   (10.0 s, 7 samples)
> Pipe-based Context Switching                2451404.5 lps   (10.0 s, 7 samples)
> Process Creation                              97788.2 lps   (30.0 s, 2 samples)
> Shell Scripts (1 concurrent)                  58505.9 lpm   (60.0 s, 2 samples)
> Shell Scripts (8 concurrent)                   9195.4 lpm   (60.0 s, 2 samples)
> System Call Overhead                        9467372.2 lps   (10.0 s, 7 samples)
> 
> System Benchmarks Index Values               BASELINE       RESULT    INDEX
> Dhrystone 2 using register variables         116700.0  237271982.6  20331.8
> Double-Precision Whetstone                       55.0      35186.8   6397.6
> Execl Throughput                                 43.0      42557.8   9897.2
> File Copy 1024 bufsize 2000 maxblocks          3960.0    1403922.0   3545.3
> File Copy 256 bufsize 500 maxblocks            1655.0     367436.5   2220.2
> File Copy 4096 bufsize 8000 maxblocks          5800.0    4380468.3   7552.5
> Pipe Throughput                               12440.0   12872664.6  10347.8
> Pipe-based Context Switching                   4000.0    2451404.5   6128.5
> Process Creation                                126.0      97788.2   7761.0
> Shell Scripts (1 concurrent)                     42.4      58505.9  13798.6
> Shell Scripts (8 concurrent)                      6.0       9195.4  15325.6
> System Call Overhead                          15000.0    9467372.2   6311.6
>                                                                    ========
> System Benchmarks Index Score                                        7794.3

At least now, BIO_MAX_PAGES can be fixed as 256 in case of CONFIG_THP_SWAP,
otherwise 2 pages may be allocated for holding the bvec table, so tests
in case of THP_SWAP may be improved.

Also filesystem may support IO to/from THP, and multipage bvec should
improve this case too.

Long term, there is opportunity to improve fs code by only allocating
'nr_segment' of bvec table, instead of 'nr_page' of bvec table because
physically contiguous pages are often allocated from mm for same
process.

So this patchset is just a start, and at the current stage, I am
focusing on making it stable since it is the correct approach to
only store the multipage segment instead of each pages.

Thanks again for your test.

Thanks,
Ming
