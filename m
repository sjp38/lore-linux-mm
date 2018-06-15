Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 510EE6B0006
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 08:59:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id v5-v6so1243759wmh.6
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 05:59:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g9-v6sor3792947edp.56.2018.06.15.05.59.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Jun 2018 05:59:56 -0700 (PDT)
MIME-Version: 1.0
References: <20180609123014.8861-1-ming.lei@redhat.com>
In-Reply-To: <20180609123014.8861-1-ming.lei@redhat.com>
From: Gi-Oh Kim <gi-oh.kim@profitbricks.com>
Date: Fri, 15 Jun 2018 14:59:19 +0200
Message-ID: <CAJX1YtaRtCGt7f8H0VEDrDkcOYusB0JoL-CNB_E--MYGhcvbow@mail.gmail.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ming.lei@redhat.com
Cc: Jens Axboe <axboe@fb.com>, hch@infradead.org, Al Viro <viro@zeniv.linux.org.uk>, kent.overstreet@gmail.com, dsterba@suse.cz, ying.huang@intel.com, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, tytso@mit.edu, darrick.wong@oracle.com, colyli@suse.de, fdmanana@gmail.com, rdunlap@infradead.org

>
> - bio size can be increased and it should improve some high-bandwidth IO
> case in theory[4].
>

Hi,

I would like to report your patch set works well on my system based on v4.1=
4.48.
I thought the multipage bvec could improve the performance of my system.
(FYI, my system has v4.14.48 and provides KVM-base virtualization service.)

So I did back-porting your patches to v4.14.48.
It has done without any serious problem.
I only needed to cherry-pick "blk-merge: compute
bio->bi_seg_front_size efficiently" and
"block: move bio_alloc_pages() to bcache" patches before back-porting
to prevent conflicts.
And I ran my own test-suit for checking features of md and RAID1 layer.
There was no problem. All test cases passed.
(If you want, I will send you the back-ported patches.)

Then I did two performance test as following.
To say the conclusion first, I failed to show performance improvement
of the patch set.
Of course, my test cases would not be suitable to test your patch set.
Or maybe I did test wrong.
Please inform me which tools are suitable, then I will try them.

1. fio

First I ran fio with null device to check the performance of the block-laye=
r.
I am not sure those test is suitable to show the performance
improvement or degradation.
Nevertheless there was a little (-6%) performance degradation.

If it is not much trouble to you, please review my options for fio and
inform me if I used wrong or incorrect options.
Then I will run the test again.

1.1 Following is my options for fio.

gkim@ib1:~/pb-ltp/benchmark/fio$ cat go_local.sh
#!/bin/bash
echo "fio start   : $(date)"
echo "kernel info : $(uname -a)"
echo "fio version : $(fio --version)"

# set "none" io-scheduler
modprobe -r null_blk
modprobe null_blk
echo "none" > /sys/block/nullb0/queue/scheduler

FIO_OPTION=3D"--direct=3D1 --rw=3Drandrw:2 --time_based=3D1 --group_reporti=
ng \
            --ioengine=3Dlibaio --iodepth=3D64 --name=3Dfiotest --numjobs=
=3D8 \
            --bssplit=3D512/20:1k/16:2k/9:4k/12:8k/19:16k/10:32k/8:64k/4 \
            --fadvise_hint=3D0 --iodepth_batch_submit=3D64
--iodepth_batch_complete=3D64"
# fio test null_blk device, so it is not necessary to run long.
fio $FIO_OPTION --filename=3D/dev/nullb0 --runtime=3D600

1.2 Following is the result before porting.

fio start   : Mon Jun 11 04:30:01 CEST 2018
kernel info : Linux ib1 4.14.48-1-pserver
#4.14.48-1.1+feature+daily+update+20180607.0857+1bbde0b~deb8 SMP
x86_64 GNU/Linux
fio version : fio-2.2.10
fiotest: (g=3D0): rw=3Drandrw, bs=3D512-64K/512-64K/512-64K,
ioengine=3Dlibaio, iodepth=3D64
...
fio-2.2.10
Starting 8 processes

fiotest: (groupid=3D0, jobs=3D8): err=3D 0: pid=3D1655: Mon Jun 11 04:40:02=
 2018
  read : io=3D7133.2GB, bw=3D12174MB/s, iops=3D1342.1K, runt=3D600001msec
    slat (usec): min=3D1, max=3D15750, avg=3D123.78, stdev=3D153.79
    clat (usec): min=3D0, max=3D15758, avg=3D24.70, stdev=3D77.93
     lat (usec): min=3D2, max=3D15782, avg=3D148.49, stdev=3D167.54
    clat percentiles (usec):
     |  1.00th=3D[    0],  5.00th=3D[    1], 10.00th=3D[    1], 20.00th=3D[=
    1],
     | 30.00th=3D[    2], 40.00th=3D[    2], 50.00th=3D[    2], 60.00th=3D[=
    6],
     | 70.00th=3D[   22], 80.00th=3D[   36], 90.00th=3D[   72], 95.00th=3D[=
  107],
     | 99.00th=3D[  173], 99.50th=3D[  203], 99.90th=3D[  932], 99.95th=3D[=
 1416],
     | 99.99th=3D[ 2960]
    bw (MB  /s): min=3D 1096, max=3D 2147, per=3D12.51%, avg=3D1522.69, std=
ev=3D253.89
  write: io=3D7131.3GB, bw=3D12171MB/s, iops=3D1343.6K, runt=3D600001msec
    slat (usec): min=3D1, max=3D15751, avg=3D124.73, stdev=3D154.11
    clat (usec): min=3D0, max=3D15758, avg=3D24.69, stdev=3D77.84
     lat (usec): min=3D2, max=3D15780, avg=3D149.43, stdev=3D167.82
    clat percentiles (usec):
     |  1.00th=3D[    0],  5.00th=3D[    1], 10.00th=3D[    1], 20.00th=3D[=
    1],
     | 30.00th=3D[    2], 40.00th=3D[    2], 50.00th=3D[    2], 60.00th=3D[=
    6],
     | 70.00th=3D[   22], 80.00th=3D[   36], 90.00th=3D[   72], 95.00th=3D[=
  107],
     | 99.00th=3D[  173], 99.50th=3D[  203], 99.90th=3D[  932], 99.95th=3D[=
 1416],
     | 99.99th=3D[ 2960]
    bw (MB  /s): min=3D 1080, max=3D 2121, per=3D12.51%, avg=3D1522.33, std=
ev=3D253.96
    lat (usec) : 2=3D21.63%, 4=3D37.80%, 10=3D2.12%, 20=3D6.43%, 50=3D16.70=
%
    lat (usec) : 100=3D8.86%, 250=3D6.07%, 500=3D0.17%, 750=3D0.08%, 1000=
=3D0.05%
    lat (msec) : 2=3D0.06%, 4=3D0.02%, 10=3D0.01%, 20=3D0.01%
  cpu          : usr=3D22.39%, sys=3D64.19%, ctx=3D15425825, majf=3D0, minf=
=3D97
  IO depths    : 1=3D1.8%, 2=3D1.8%, 4=3D8.8%, 8=3D14.4%, 16=3D12.3%, 32=3D=
41.7%, >=3D64=3D19.3%
     submit    : 0=3D0.0%, 4=3D5.8%, 8=3D9.7%, 16=3D15.0%, 32=3D18.0%, 64=
=3D51.5%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D0.1%, 8=3D0.0%, 16=3D0.1%, 32=3D0.1%, 64=3D1=
00.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D805764385/w=3D806127393/d=3D0, short=3Dr=3D0/w=
=3D0/d=3D0,
drop=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D64

Run status group 0 (all jobs):
   READ: io=3D7133.2GB, aggrb=3D12174MB/s, minb=3D12174MB/s, maxb=3D12174MB=
/s,
mint=3D600001msec, maxt=3D600001msec
  WRITE: io=3D7131.3GB, aggrb=3D12171MB/s, minb=3D12171MB/s, maxb=3D12171MB=
/s,
mint=3D600001msec, maxt=3D600001msec

Disk stats (read/write):
  nullb0: ios=3D442461761/442546060, merge=3D363197836/363473703,
ticks=3D12280990/12452480, in_queue=3D2740, util=3D0.43%

1.3 Following is the result after porting.

fio start   : Fri Jun 15 12:42:47 CEST 2018
kernel info : Linux ib1 4.14.48-1-pserver-mpbvec+ #12 SMP Fri Jun 15
12:21:36 CEST 2018 x86_64 GNU/Linux
fio version : fio-2.2.10
fiotest: (g=3D0): rw=3Drandrw, bs=3D512-64K/512-64K/512-64K,
ioengine=3Dlibaio, iodepth=3D64
...
fio-2.2.10
Starting 8 processes
Jobs: 4 (f=3D0): [m(1),_(2),m(1),_(1),m(2),_(1)] [100.0% done]
[8430MB/8444MB/0KB /s] [961K/963K/0 iops] [eta 00m:00s]
fiotest: (groupid=3D0, jobs=3D8): err=3D 0: pid=3D14096: Fri Jun 15 12:52:4=
8 2018
  read : io=3D6633.8GB, bw=3D11322MB/s, iops=3D1246.9K, runt=3D600005msec
    slat (usec): min=3D1, max=3D16939, avg=3D135.34, stdev=3D156.23
    clat (usec): min=3D0, max=3D16947, avg=3D26.10, stdev=3D78.50
     lat (usec): min=3D2, max=3D16957, avg=3D161.45, stdev=3D168.88
    clat percentiles (usec):
     |  1.00th=3D[    0],  5.00th=3D[    1], 10.00th=3D[    1], 20.00th=3D[=
    1],
     | 30.00th=3D[    2], 40.00th=3D[    2], 50.00th=3D[    2], 60.00th=3D[=
    5],
     | 70.00th=3D[   23], 80.00th=3D[   37], 90.00th=3D[   79], 95.00th=3D[=
  115],
     | 99.00th=3D[  181], 99.50th=3D[  211], 99.90th=3D[  948], 99.95th=3D[=
 1416],
     | 99.99th=3D[ 2864]
    bw (MB  /s): min=3D 1106, max=3D 2031, per=3D12.51%, avg=3D1416.05, std=
ev=3D201.81
  write: io=3D6631.1GB, bw=3D11318MB/s, iops=3D1247.5K, runt=3D600005msec
    slat (usec): min=3D1, max=3D16938, avg=3D136.48, stdev=3D156.54
    clat (usec): min=3D0, max=3D16947, avg=3D26.08, stdev=3D78.43
     lat (usec): min=3D2, max=3D16957, avg=3D162.58, stdev=3D169.15
    clat percentiles (usec):
     |  1.00th=3D[    0],  5.00th=3D[    1], 10.00th=3D[    1], 20.00th=3D[=
    1],
     | 30.00th=3D[    2], 40.00th=3D[    2], 50.00th=3D[    2], 60.00th=3D[=
    5],
     | 70.00th=3D[   23], 80.00th=3D[   37], 90.00th=3D[   79], 95.00th=3D[=
  115],
     | 99.00th=3D[  181], 99.50th=3D[  211], 99.90th=3D[  948], 99.95th=3D[=
 1416],
     | 99.99th=3D[ 2864]
    bw (MB  /s): min=3D 1084, max=3D 2044, per=3D12.51%, avg=3D1415.67, std=
ev=3D201.93
    lat (usec) : 2=3D20.98%, 4=3D38.82%, 10=3D2.15%, 20=3D5.08%, 50=3D16.91=
%
    lat (usec) : 100=3D8.75%, 250=3D6.91%, 500=3D0.19%, 750=3D0.09%, 1000=
=3D0.05%
    lat (msec) : 2=3D0.07%, 4=3D0.02%, 10=3D0.01%, 20=3D0.01%
  cpu          : usr=3D21.02%, sys=3D65.53%, ctx=3D15321661, majf=3D0, minf=
=3D78
  IO depths    : 1=3D1.9%, 2=3D1.9%, 4=3D9.5%, 8=3D13.6%, 16=3D11.2%, 32=3D=
42.1%, >=3D64=3D19.9%
     submit    : 0=3D0.0%, 4=3D6.3%, 8=3D10.1%, 16=3D14.1%, 32=3D18.2%,
64=3D51.3%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D0.1%, 8=3D0.0%, 16=3D0.1%, 32=3D0.1%, 64=3D1=
00.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D748120019/w=3D748454509/d=3D0, short=3Dr=3D0/w=
=3D0/d=3D0,
drop=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D64

Run status group 0 (all jobs):
   READ: io=3D6633.8GB, aggrb=3D11322MB/s, minb=3D11322MB/s, maxb=3D11322MB=
/s,
mint=3D600005msec, maxt=3D600005msec
  WRITE: io=3D6631.1GB, aggrb=3D11318MB/s, minb=3D11318MB/s, maxb=3D11318MB=
/s,
mint=3D600005msec, maxt=3D600005msec

Disk stats (read/write):
  nullb0: ios=3D410911387/410974086, merge=3D337127604/337396176,
ticks=3D12482050/12662790, in_queue=3D1780, util=3D0.27%


2. Unixbench

Second I rand Unixbench to check general performance.
I think there is no difference before and after porting the patches.
Unixbench might not be suitable to check the performance improvement
of the block layer.
If you inform me which tools is suitable, I will try it on my system.

2.1 Following is the result before porting.

   BYTE UNIX Benchmarks (Version 5.1.3)

   System: ib1: GNU/Linux
   OS: GNU/Linux -- 4.14.48-1-pserver --
#4.14.48-1.1+feature+daily+update+20180607.0857+1bbde0b~deb8 SMP
   Machine: x86_64 (unknown)
   Language: en_US.utf8 (charmap=3D"UTF-8", collate=3D"UTF-8")
   CPU 0: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 1: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 2: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 3: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 4: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 5: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 6: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 7: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   05:00:01 up 3 days, 16:20,  2 users,  load average: 0.00, 0.11,
1.11; runlevel 2018-06-07

------------------------------------------------------------------------
Benchmark Run: Mon Jun 11 2018 05:00:01 - 05:28:54
8 CPUs in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       47158867.7 lps   (10.0 s, 7 samp=
les)
Double-Precision Whetstone                     3878.8 MWIPS (15.2 s, 7 samp=
les)
Execl Throughput                               9203.9 lps   (30.0 s, 2 samp=
les)
File Copy 1024 bufsize 2000 maxblocks       1490834.8 KBps  (30.0 s, 2 samp=
les)
File Copy 256 bufsize 500 maxblocks          388784.2 KBps  (30.0 s, 2 samp=
les)
File Copy 4096 bufsize 8000 maxblocks       3744780.2 KBps  (30.0 s, 2 samp=
les)
Pipe Throughput                             2682620.1 lps   (10.0 s, 7 samp=
les)
Pipe-based Context Switching                 263786.5 lps   (10.0 s, 7 samp=
les)
Process Creation                              19674.0 lps   (30.0 s, 2 samp=
les)
Shell Scripts (1 concurrent)                  16121.5 lpm   (60.0 s, 2 samp=
les)
Shell Scripts (8 concurrent)                   5623.5 lpm   (60.0 s, 2 samp=
les)
System Call Overhead                        4068991.3 lps   (10.0 s, 7 samp=
les)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   47158867.7   4041.0
Double-Precision Whetstone                       55.0       3878.8    705.2
Execl Throughput                                 43.0       9203.9   2140.4
File Copy 1024 bufsize 2000 maxblocks          3960.0    1490834.8   3764.7
File Copy 256 bufsize 500 maxblocks            1655.0     388784.2   2349.1
File Copy 4096 bufsize 8000 maxblocks          5800.0    3744780.2   6456.5
Pipe Throughput                               12440.0    2682620.1   2156.4
Pipe-based Context Switching                   4000.0     263786.5    659.5
Process Creation                                126.0      19674.0   1561.4
Shell Scripts (1 concurrent)                     42.4      16121.5   3802.2
Shell Scripts (8 concurrent)                      6.0       5623.5   9372.5
System Call Overhead                          15000.0    4068991.3   2712.7
                                                                   =3D=3D=
=3D=3D=3D=3D=3D=3D
System Benchmarks Index Score                                        2547.7

------------------------------------------------------------------------
Benchmark Run: Mon Jun 11 2018 05:28:54 - 05:57:07
8 CPUs in system; running 8 parallel copies of tests

Dhrystone 2 using register variables      234727639.9 lps   (10.0 s, 7 samp=
les)
Double-Precision Whetstone                    35350.9 MWIPS (10.7 s, 7 samp=
les)
Execl Throughput                              43811.3 lps   (30.0 s, 2 samp=
les)
File Copy 1024 bufsize 2000 maxblocks       1401373.1 KBps  (30.0 s, 2 samp=
les)
File Copy 256 bufsize 500 maxblocks          366033.9 KBps  (30.0 s, 2 samp=
les)
File Copy 4096 bufsize 8000 maxblocks       4360829.6 KBps  (30.0 s, 2 samp=
les)
Pipe Throughput                            12875165.6 lps   (10.0 s, 7 samp=
les)
Pipe-based Context Switching                2431725.6 lps   (10.0 s, 7 samp=
les)
Process Creation                              97360.8 lps   (30.0 s, 2 samp=
les)
Shell Scripts (1 concurrent)                  58879.6 lpm   (60.0 s, 2 samp=
les)
Shell Scripts (8 concurrent)                   9232.5 lpm   (60.0 s, 2 samp=
les)
System Call Overhead                        9497958.7 lps   (10.0 s, 7 samp=
les)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0  234727639.9  20113.8
Double-Precision Whetstone                       55.0      35350.9   6427.4
Execl Throughput                                 43.0      43811.3  10188.7
File Copy 1024 bufsize 2000 maxblocks          3960.0    1401373.1   3538.8
File Copy 256 bufsize 500 maxblocks            1655.0     366033.9   2211.7
File Copy 4096 bufsize 8000 maxblocks          5800.0    4360829.6   7518.7
Pipe Throughput                               12440.0   12875165.6  10349.8
Pipe-based Context Switching                   4000.0    2431725.6   6079.3
Process Creation                                126.0      97360.8   7727.0
Shell Scripts (1 concurrent)                     42.4      58879.6  13886.7
Shell Scripts (8 concurrent)                      6.0       9232.5  15387.5
System Call Overhead                          15000.0    9497958.7   6332.0
                                                                   =3D=3D=
=3D=3D=3D=3D=3D=3D
System Benchmarks Index Score                                        7803.5


2.2 Following is the result after porting.

   BYTE UNIX Benchmarks (Version 5.1.3)

   System: ib1: GNU/Linux
   OS: GNU/Linux -- 4.14.48-1-pserver-mpbvec+ -- #12 SMP Fri Jun 15
12:21:36 CEST 2018
   Machine: x86_64 (unknown)
   Language: en_US.utf8 (charmap=3D"UTF-8", collate=3D"UTF-8")
   CPU 0: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 1: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 2: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 3: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 4: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 5: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 6: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   CPU 7: Intel(R) Xeon(R) CPU E3-1245 v5 @ 3.50GHz (7008.0 bogomips)
          Hyper-Threading, x86-64, MMX, Physical Address Ext,
SYSENTER/SYSEXIT, SYSCALL/SYSRET, Intel virtualization
   13:16:11 up 50 min,  1 user,  load average: 0.00, 1.40, 3.46;
runlevel 2018-06-15

------------------------------------------------------------------------
Benchmark Run: Fri Jun 15 2018 13:16:11 - 13:45:04
8 CPUs in system; running 1 parallel copy of tests

Dhrystone 2 using register variables       47103754.6 lps   (10.0 s, 7 samp=
les)
Double-Precision Whetstone                     3886.3 MWIPS (15.1 s, 7 samp=
les)
Execl Throughput                               8965.0 lps   (30.0 s, 2 samp=
les)
File Copy 1024 bufsize 2000 maxblocks       1510285.9 KBps  (30.0 s, 2 samp=
les)
File Copy 256 bufsize 500 maxblocks          395196.9 KBps  (30.0 s, 2 samp=
les)
File Copy 4096 bufsize 8000 maxblocks       3802788.0 KBps  (30.0 s, 2 samp=
les)
Pipe Throughput                             2670169.1 lps   (10.0 s, 7 samp=
les)
Pipe-based Context Switching                 275093.8 lps   (10.0 s, 7 samp=
les)
Process Creation                              19707.1 lps   (30.0 s, 2 samp=
les)
Shell Scripts (1 concurrent)                  16046.8 lpm   (60.0 s, 2 samp=
les)
Shell Scripts (8 concurrent)                   5600.8 lpm   (60.0 s, 2 samp=
les)
System Call Overhead                        4104142.0 lps   (10.0 s, 7 samp=
les)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0   47103754.6   4036.3
Double-Precision Whetstone                       55.0       3886.3    706.6
Execl Throughput                                 43.0       8965.0   2084.9
File Copy 1024 bufsize 2000 maxblocks          3960.0    1510285.9   3813.9
File Copy 256 bufsize 500 maxblocks            1655.0     395196.9   2387.9
File Copy 4096 bufsize 8000 maxblocks          5800.0    3802788.0   6556.5
Pipe Throughput                               12440.0    2670169.1   2146.4
Pipe-based Context Switching                   4000.0     275093.8    687.7
Process Creation                                126.0      19707.1   1564.1
Shell Scripts (1 concurrent)                     42.4      16046.8   3784.6
Shell Scripts (8 concurrent)                      6.0       5600.8   9334.6
System Call Overhead                          15000.0    4104142.0   2736.1
                                                                   =3D=3D=
=3D=3D=3D=3D=3D=3D
System Benchmarks Index Score                                        2560.0

------------------------------------------------------------------------
Benchmark Run: Fri Jun 15 2018 13:45:04 - 14:13:17
8 CPUs in system; running 8 parallel copies of tests

Dhrystone 2 using register variables      237271982.6 lps   (10.0 s, 7 samp=
les)
Double-Precision Whetstone                    35186.8 MWIPS (10.7 s, 7 samp=
les)
Execl Throughput                              42557.8 lps   (30.0 s, 2 samp=
les)
File Copy 1024 bufsize 2000 maxblocks       1403922.0 KBps  (30.0 s, 2 samp=
les)
File Copy 256 bufsize 500 maxblocks          367436.5 KBps  (30.0 s, 2 samp=
les)
File Copy 4096 bufsize 8000 maxblocks       4380468.3 KBps  (30.0 s, 2 samp=
les)
Pipe Throughput                            12872664.6 lps   (10.0 s, 7 samp=
les)
Pipe-based Context Switching                2451404.5 lps   (10.0 s, 7 samp=
les)
Process Creation                              97788.2 lps   (30.0 s, 2 samp=
les)
Shell Scripts (1 concurrent)                  58505.9 lpm   (60.0 s, 2 samp=
les)
Shell Scripts (8 concurrent)                   9195.4 lpm   (60.0 s, 2 samp=
les)
System Call Overhead                        9467372.2 lps   (10.0 s, 7 samp=
les)

System Benchmarks Index Values               BASELINE       RESULT    INDEX
Dhrystone 2 using register variables         116700.0  237271982.6  20331.8
Double-Precision Whetstone                       55.0      35186.8   6397.6
Execl Throughput                                 43.0      42557.8   9897.2
File Copy 1024 bufsize 2000 maxblocks          3960.0    1403922.0   3545.3
File Copy 256 bufsize 500 maxblocks            1655.0     367436.5   2220.2
File Copy 4096 bufsize 8000 maxblocks          5800.0    4380468.3   7552.5
Pipe Throughput                               12440.0   12872664.6  10347.8
Pipe-based Context Switching                   4000.0    2451404.5   6128.5
Process Creation                                126.0      97788.2   7761.0
Shell Scripts (1 concurrent)                     42.4      58505.9  13798.6
Shell Scripts (8 concurrent)                      6.0       9195.4  15325.6
System Call Overhead                          15000.0    9467372.2   6311.6
                                                                   =3D=3D=
=3D=3D=3D=3D=3D=3D
System Benchmarks Index Score                                        7794.3


--=20
GIOH KIM
Linux Kernel Entwickler

ProfitBricks GmbH
Greifswalder Str. 207
D - 10405 Berlin

Tel:       +49 176 2697 8962
Fax:      +49 30 577 008 299
Email:    gi-oh.kim@profitbricks.com
URL:      https://www.profitbricks.de

Sitz der Gesellschaft: Berlin
Registergericht: Amtsgericht Charlottenburg, HRB 125506 B
Gesch=C3=A4ftsf=C3=BChrer: Achim Weiss, Matthias Steinberg, Christoph Steff=
ens
