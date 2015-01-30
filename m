Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C66006B0038
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 19:20:15 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so44980265pac.13
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 16:20:15 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id bp4si11799854pdb.100.2015.01.29.16.20.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 16:20:14 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so45052217pad.10
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 16:20:14 -0800 (PST)
Date: Fri, 30 Jan 2015 09:20:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150130002011.GA1529@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
 <20150129022241.GA2555@swordfish>
 <20150129052827.GB25462@blaptop>
 <20150129060604.GC2555@swordfish>
 <20150129063505.GA32331@blaptop>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <20150129063505.GA32331@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On (01/29/15 15:35), Minchan Kim wrote:
> 
> I tested it with multiple dd processes.
> 

Hello,

fio test (http://manpages.ubuntu.com/manpages/natty/man1/fio.1.html) configs are attached,
so we can run fio on different h/w (works against zram with fs mounted at /mnt/)

	for i in ./test-fio-*; do fio ./$i; rm bg*; done

in short

randread
BASE   READ: io=1600.0MB, aggrb=3747.8MB/s, minb=959250KB/s, maxb=982.82MB/s, mint=407msec, maxt=427msec
SRCU   READ: io=1600.0MB, aggrb=3782.6MB/s, minb=968321KB/s, maxb=977.11MB/s, mint=409msec, maxt=423msec

random read/write
BASE   READ: io=820304KB, aggrb=1296.3MB/s, minb=331838KB/s, maxb=333456KB/s, mint=615msec, maxt=618msec
SRCU   READ: io=820304KB, aggrb=1261.6MB/s, minb=322954KB/s, maxb=335639KB/s, mint=611msec, maxt=635msec
BASE  WRITE: io=818096KB, aggrb=1292.8MB/s, minb=330944KB/s, maxb=332559KB/s, mint=615msec, maxt=618msec
SRCU  WRITE: io=818096KB, aggrb=1258.2MB/s, minb=322085KB/s, maxb=334736KB/s, mint=611msec, maxt=635msec

random write
BASE  WRITE: io=1600.0MB, aggrb=692184KB/s, minb=173046KB/s, maxb=174669KB/s, mint=2345msec, maxt=2367msec
SRCU  WRITE: io=1600.0MB, aggrb=672577KB/s, minb=168144KB/s, maxb=174149KB/s, mint=2352msec, maxt=2436msec


detailed per-process metrics:

************* BASE *************

$ for i in ./test-fio-*; do fio ./$i; rm bg*; done
bgreader: (g=0): rw=randread, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)

bgreader: (groupid=0, jobs=1): err= 0: pid=10792: Thu Jan 29 19:43:30 2015
  read : io=409600KB, bw=959251KB/s, iops=239812, runt=   427msec
    slat (usec): min=2, max=28, avg= 2.43, stdev= 0.62
    clat (usec): min=1, max=151, avg=122.97, stdev= 4.99
     lat (usec): min=4, max=174, avg=125.52, stdev= 5.08
    clat percentiles (usec):
     |  1.00th=[  106],  5.00th=[  116], 10.00th=[  121], 20.00th=[  122],
     | 30.00th=[  122], 40.00th=[  123], 50.00th=[  123], 60.00th=[  124],
     | 70.00th=[  124], 80.00th=[  124], 90.00th=[  125], 95.00th=[  127],
     | 99.00th=[  143], 99.50th=[  143], 99.90th=[  145], 99.95th=[  145],
     | 99.99th=[  147]
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.97%
  cpu          : usr=39.11%, sys=55.04%, ctx=82, majf=0, minf=38
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=10793: Thu Jan 29 19:43:30 2015
  read : io=409600KB, bw=982254KB/s, iops=245563, runt=   417msec
    slat (usec): min=2, max=60, avg= 2.42, stdev= 0.56
    clat (usec): min=1, max=187, avg=123.17, stdev= 4.02
     lat (usec): min=3, max=189, avg=125.71, stdev= 4.09
    clat percentiles (usec):
     |  1.00th=[  105],  5.00th=[  121], 10.00th=[  121], 20.00th=[  122],
     | 30.00th=[  122], 40.00th=[  123], 50.00th=[  123], 60.00th=[  124],
     | 70.00th=[  124], 80.00th=[  125], 90.00th=[  126], 95.00th=[  127],
     | 99.00th=[  133], 99.50th=[  135], 99.90th=[  141], 99.95th=[  175],
     | 99.99th=[  187]
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.97%
  cpu          : usr=40.53%, sys=55.88%, ctx=43, majf=0, minf=39
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=10794: Thu Jan 29 19:43:30 2015
  read : io=409600KB, bw=982.82MB/s, iops=251597, runt=   407msec
    slat (usec): min=2, max=50, avg= 2.43, stdev= 0.58
    clat (usec): min=2, max=174, avg=123.07, stdev= 3.97
     lat (usec): min=5, max=197, avg=125.62, stdev= 4.02
    clat percentiles (usec):
     |  1.00th=[  106],  5.00th=[  120], 10.00th=[  121], 20.00th=[  122],
     | 30.00th=[  122], 40.00th=[  123], 50.00th=[  123], 60.00th=[  123],
     | 70.00th=[  124], 80.00th=[  125], 90.00th=[  126], 95.00th=[  129],
     | 99.00th=[  135], 99.50th=[  137], 99.90th=[  145], 99.95th=[  153],
     | 99.99th=[  169]
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.98%
  cpu          : usr=41.03%, sys=57.74%, ctx=42, majf=0, minf=37
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=10795: Thu Jan 29 19:43:30 2015
  read : io=409600KB, bw=980.41MB/s, iops=250980, runt=   408msec
    slat (usec): min=2, max=357, avg= 2.45, stdev= 1.32
    clat (usec): min=1, max=498, avg=124.23, stdev=12.09
     lat (usec): min=4, max=501, avg=126.80, stdev=12.33
    clat percentiles (usec):
     |  1.00th=[  108],  5.00th=[  121], 10.00th=[  122], 20.00th=[  122],
     | 30.00th=[  123], 40.00th=[  123], 50.00th=[  124], 60.00th=[  124],
     | 70.00th=[  124], 80.00th=[  125], 90.00th=[  126], 95.00th=[  127],
     | 99.00th=[  139], 99.50th=[  141], 99.90th=[  274], 99.95th=[  350],
     | 99.99th=[  498]
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.61%, 500=0.37%
  cpu          : usr=41.18%, sys=58.09%, ctx=86, majf=0, minf=38
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: io=1600.0MB, aggrb=3747.8MB/s, minb=959250KB/s, maxb=982.82MB/s, mint=407msec, maxt=427msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%
bgupdater: (g=0): rw=randrw, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)

bgupdater: (groupid=0, jobs=1): err= 0: pid=10803: Thu Jan 29 19:43:33 2015
  read : io=205076KB, bw=332916KB/s, iops=83228, runt=   616msec
    slat (usec): min=2, max=38, avg= 2.53, stdev= 0.71
    clat (usec): min=18, max=912, avg=187.23, stdev=18.71
     lat (usec): min=22, max=915, avg=189.88, stdev=18.74
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  183], 50.00th=[  187], 60.00th=[  191],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  203], 95.00th=[  209],
     | 99.00th=[  223], 99.50th=[  233], 99.90th=[  258], 99.95th=[  290],
     | 99.99th=[  908]
    bw (KB  /s): min=332504, max=332504, per=25.05%, avg=332504.00, stdev= 0.00
  write: io=204524KB, bw=332019KB/s, iops=83004, runt=   616msec
    slat (usec): min=4, max=731, avg= 6.21, stdev= 3.42
    clat (usec): min=1, max=910, avg=187.36, stdev=17.80
     lat (usec): min=8, max=918, avg=193.71, stdev=18.16
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  185], 50.00th=[  187], 60.00th=[  191],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  203], 95.00th=[  209],
     | 99.00th=[  223], 99.50th=[  231], 99.90th=[  258], 99.95th=[  282],
     | 99.99th=[  908]
    bw (KB  /s): min=332544, max=332544, per=25.12%, avg=332544.00, stdev= 0.00
    lat (usec) : 2=0.01%, 20=0.01%, 50=0.01%, 100=0.01%, 250=99.80%
    lat (usec) : 500=0.15%, 1000=0.03%
  cpu          : usr=30.36%, sys=68.99%, ctx=185, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=10804: Thu Jan 29 19:43:33 2015
  read : io=205076KB, bw=331838KB/s, iops=82959, runt=   618msec
    slat (usec): min=2, max=99, avg= 2.54, stdev= 0.88
    clat (usec): min=13, max=4676, avg=187.64, stdev=78.01
     lat (usec): min=16, max=4678, avg=190.29, stdev=78.01
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  221], 99.50th=[  239], 99.90th=[  342], 99.95th=[  462],
     | 99.99th=[ 4704]
    bw (KB  /s): min=330248, max=330248, per=24.88%, avg=330248.00, stdev= 0.00
  write: io=204524KB, bw=330945KB/s, iops=82736, runt=   618msec
    slat (usec): min=4, max=4458, avg= 6.24, stdev=19.77
    clat (usec): min=2, max=4673, avg=187.90, stdev=80.44
     lat (usec): min=6, max=4680, avg=194.28, stdev=82.87
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  219], 99.50th=[  233], 99.90th=[  342], 99.95th=[  462],
     | 99.99th=[ 4640]
    bw (KB  /s): min=330328, max=330328, per=24.95%, avg=330328.00, stdev= 0.00
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.67%, 500=0.28%
    lat (msec) : 10=0.03%
  cpu          : usr=30.10%, sys=68.45%, ctx=67, majf=0, minf=10
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=10805: Thu Jan 29 19:43:33 2015
  read : io=205076KB, bw=332916KB/s, iops=83228, runt=   616msec
    slat (usec): min=2, max=4810, avg= 2.63, stdev=21.50
    clat (usec): min=14, max=5018, avg=187.75, stdev=99.05
     lat (usec): min=16, max=5020, avg=190.49, stdev=101.38
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  185], 60.00th=[  189],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  219], 99.50th=[  229], 99.90th=[  262], 99.95th=[  956],
     | 99.99th=[ 5024]
    bw (KB  /s): min=331056, max=331056, per=24.94%, avg=331056.00, stdev= 0.00
  write: io=204524KB, bw=332019KB/s, iops=83004, runt=   616msec
    slat (usec): min=4, max=49, avg= 6.11, stdev= 1.01
    clat (usec): min=2, max=5018, avg=186.97, stdev=70.14
     lat (usec): min=6, max=5024, avg=193.22, stdev=70.15
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  195], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  217], 99.50th=[  227], 99.90th=[  255], 99.95th=[  948],
     | 99.99th=[ 5024]
    bw (KB  /s): min=331320, max=331320, per=25.03%, avg=331320.00, stdev= 0.00
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.83%, 500=0.09%, 1000=0.03%
    lat (msec) : 10=0.03%
  cpu          : usr=30.52%, sys=68.34%, ctx=70, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=10806: Thu Jan 29 19:43:33 2015
  read : io=205076KB, bw=333457KB/s, iops=83364, runt=   615msec
    slat (usec): min=2, max=40, avg= 2.53, stdev= 0.69
    clat (usec): min=18, max=287, avg=186.73, stdev=12.94
     lat (usec): min=21, max=289, avg=189.38, stdev=12.98
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  203], 95.00th=[  207],
     | 99.00th=[  221], 99.50th=[  229], 99.90th=[  258], 99.95th=[  270],
     | 99.99th=[  286]
    bw (KB  /s): min=332680, max=332680, per=25.06%, avg=332680.00, stdev= 0.00
  write: io=204524KB, bw=332559KB/s, iops=83139, runt=   615msec
    slat (usec): min=4, max=28, avg= 6.17, stdev= 1.02
    clat (usec): min=2, max=285, avg=186.95, stdev=12.80
     lat (usec): min=8, max=294, avg=193.26, stdev=12.89
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  185], 50.00th=[  187], 60.00th=[  191],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  203], 95.00th=[  209],
     | 99.00th=[  221], 99.50th=[  227], 99.90th=[  251], 99.95th=[  262],
     | 99.99th=[  274]
    bw (KB  /s): min=332672, max=332672, per=25.13%, avg=332672.00, stdev= 0.00
    lat (usec) : 4=0.01%, 20=0.01%, 50=0.01%, 100=0.01%, 250=99.85%
    lat (usec) : 500=0.14%
  cpu          : usr=30.73%, sys=69.11%, ctx=63, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: io=820304KB, aggrb=1296.3MB/s, minb=331838KB/s, maxb=333456KB/s, mint=615msec, maxt=618msec
  WRITE: io=818096KB, aggrb=1292.8MB/s, minb=330944KB/s, maxb=332559KB/s, mint=615msec, maxt=618msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%
bgwriter: (g=0): rw=randwrite, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
Jobs: 4 (f=4)
bgwriter: (groupid=0, jobs=1): err= 0: pid=10814: Thu Jan 29 19:43:35 2015
  write: io=409600KB, bw=174150KB/s, iops=43537, runt=  2352msec
    slat (usec): min=11, max=3866, avg=20.72, stdev=14.58
    clat (usec): min=2, max=5074, avg=712.72, stdev=92.15
     lat (usec): min=20, max=5094, avg=733.63, stdev=93.77
    clat percentiles (usec):
     |  1.00th=[  612],  5.00th=[  676], 10.00th=[  684], 20.00th=[  700],
     | 30.00th=[  700], 40.00th=[  708], 50.00th=[  708], 60.00th=[  716],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  732], 95.00th=[  740],
     | 99.00th=[  820], 99.50th=[ 1004], 99.90th=[ 1640], 99.95th=[ 2128],
     | 99.99th=[ 5088]
    bw (KB  /s): min=170904, max=174808, per=24.97%, avg=172816.00, stdev=1847.92
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.24%
    lat (usec) : 750=96.28%, 1000=2.94%
    lat (msec) : 2=0.46%, 4=0.03%, 10=0.03%
  cpu          : usr=10.67%, sys=88.52%, ctx=267, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=10815: Thu Jan 29 19:43:35 2015
  write: io=409600KB, bw=173046KB/s, iops=43261, runt=  2367msec
    slat (usec): min=12, max=1459, avg=20.87, stdev=10.16
    clat (usec): min=2, max=2804, avg=717.25, stdev=69.33
     lat (usec): min=22, max=2825, avg=738.31, stdev=70.84
    clat percentiles (usec):
     |  1.00th=[  628],  5.00th=[  676], 10.00th=[  692], 20.00th=[  700],
     | 30.00th=[  708], 40.00th=[  708], 50.00th=[  716], 60.00th=[  716],
     | 70.00th=[  724], 80.00th=[  732], 90.00th=[  740], 95.00th=[  748],
     | 99.00th=[  812], 99.50th=[ 1080], 99.90th=[ 1800], 99.95th=[ 1992],
     | 99.99th=[ 2640]
    bw (KB  /s): min=171160, max=172768, per=24.82%, avg=171786.00, stdev=761.48
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.11%
    lat (usec) : 750=95.99%, 1000=3.25%
    lat (msec) : 2=0.60%, 4=0.04%
  cpu          : usr=10.65%, sys=88.64%, ctx=502, majf=0, minf=9
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=10816: Thu Jan 29 19:43:35 2015
  write: io=409600KB, bw=174224KB/s, iops=43555, runt=  2351msec
    slat (usec): min=12, max=280, avg=20.67, stdev= 2.58
    clat (usec): min=2, max=1116, avg=712.42, stdev=31.10
     lat (usec): min=20, max=1145, avg=733.30, stdev=31.89
    clat percentiles (usec):
     |  1.00th=[  628],  5.00th=[  676], 10.00th=[  684], 20.00th=[  700],
     | 30.00th=[  708], 40.00th=[  708], 50.00th=[  716], 60.00th=[  716],
     | 70.00th=[  724], 80.00th=[  724], 90.00th=[  740], 95.00th=[  748],
     | 99.00th=[  772], 99.50th=[  788], 99.90th=[ 1020], 99.95th=[ 1048],
     | 99.99th=[ 1080]
    bw (KB  /s): min=171632, max=174888, per=25.00%, avg=173026.00, stdev=1359.10
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.11%
    lat (usec) : 750=94.50%, 1000=5.19%
    lat (msec) : 2=0.19%
  cpu          : usr=10.85%, sys=88.77%, ctx=472, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=10817: Thu Jan 29 19:43:35 2015
  write: io=409600KB, bw=174670KB/s, iops=43667, runt=  2345msec
    slat (usec): min=11, max=6296, avg=20.66, stdev=24.99
    clat (usec): min=2, max=5509, avg=708.98, stdev=90.54
     lat (usec): min=22, max=7099, avg=729.83, stdev=94.22
    clat percentiles (usec):
     |  1.00th=[  604],  5.00th=[  676], 10.00th=[  684], 20.00th=[  700],
     | 30.00th=[  700], 40.00th=[  708], 50.00th=[  708], 60.00th=[  716],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  732], 95.00th=[  740],
     | 99.00th=[  756], 99.50th=[  772], 99.90th=[  940], 99.95th=[ 1912],
     | 99.99th=[ 5536]
    bw (KB  /s): min=170792, max=176064, per=25.05%, avg=173360.00, stdev=2157.10
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.32%
    lat (usec) : 750=97.68%, 1000=1.92%
    lat (msec) : 2=0.03%, 10=0.03%
  cpu          : usr=10.79%, sys=88.53%, ctx=252, majf=0, minf=6
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
  WRITE: io=1600.0MB, aggrb=692184KB/s, minb=173046KB/s, maxb=174669KB/s, mint=2345msec, maxt=2367msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%



==========================================================================================================



************* SRCU *************

$ for i in ./test-fio-*; do fio ./$i; rm bg*; done
bgreader: (g=0): rw=randread, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)
bgreader: Laying out IO file(s) (1 file(s) / 400MB)

bgreader: (groupid=0, jobs=1): err= 0: pid=11578: Thu Jan 29 19:45:01 2015
  read : io=409600KB, bw=986988KB/s, iops=246746, runt=   415msec
    slat (usec): min=2, max=708, avg= 2.48, stdev= 2.29
    clat (usec): min=2, max=839, avg=124.69, stdev=16.01
     lat (usec): min=4, max=842, avg=127.29, stdev=16.29
    clat percentiles (usec):
     |  1.00th=[  121],  5.00th=[  122], 10.00th=[  122], 20.00th=[  122],
     | 30.00th=[  123], 40.00th=[  123], 50.00th=[  123], 60.00th=[  123],
     | 70.00th=[  124], 80.00th=[  124], 90.00th=[  125], 95.00th=[  131],
     | 99.00th=[  139], 99.50th=[  223], 99.90th=[  243], 99.95th=[  282],
     | 99.99th=[  836]
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.90%, 500=0.05%, 1000=0.03%
  cpu          : usr=40.48%, sys=57.11%, ctx=46, majf=0, minf=39
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=11579: Thu Jan 29 19:45:01 2015
  read : io=409600KB, bw=968322KB/s, iops=242080, runt=   423msec
    slat (usec): min=2, max=88, avg= 2.45, stdev= 0.67
    clat (usec): min=1, max=213, avg=123.41, stdev= 4.23
     lat (usec): min=3, max=216, avg=125.97, stdev= 4.30
    clat percentiles (usec):
     |  1.00th=[  108],  5.00th=[  121], 10.00th=[  122], 20.00th=[  122],
     | 30.00th=[  123], 40.00th=[  123], 50.00th=[  123], 60.00th=[  124],
     | 70.00th=[  124], 80.00th=[  124], 90.00th=[  125], 95.00th=[  126],
     | 99.00th=[  139], 99.50th=[  139], 99.90th=[  145], 99.95th=[  195],
     | 99.99th=[  213]
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.97%
  cpu          : usr=39.24%, sys=55.79%, ctx=85, majf=0, minf=39
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=11580: Thu Jan 29 19:45:01 2015
  read : io=409600KB, bw=984615KB/s, iops=246153, runt=   416msec
    slat (usec): min=2, max=51, avg= 2.42, stdev= 0.63
    clat (usec): min=2, max=171, avg=123.01, stdev= 3.46
     lat (usec): min=4, max=174, avg=125.55, stdev= 3.50
    clat percentiles (usec):
     |  1.00th=[  120],  5.00th=[  121], 10.00th=[  121], 20.00th=[  122],
     | 30.00th=[  122], 40.00th=[  122], 50.00th=[  122], 60.00th=[  123],
     | 70.00th=[  123], 80.00th=[  123], 90.00th=[  124], 95.00th=[  126],
     | 99.00th=[  141], 99.50th=[  143], 99.90th=[  145], 99.95th=[  155],
     | 99.99th=[  171]
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.97%
  cpu          : usr=40.38%, sys=56.25%, ctx=82, majf=0, minf=37
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgreader: (groupid=0, jobs=1): err= 0: pid=11581: Thu Jan 29 19:45:01 2015
  read : io=409600KB, bw=977.11MB/s, iops=250366, runt=   409msec
    slat (usec): min=2, max=236, avg= 2.46, stdev= 0.98
    clat (usec): min=1, max=370, avg=124.55, stdev=11.16
     lat (usec): min=4, max=372, avg=127.12, stdev=11.37
    clat percentiles (usec):
     |  1.00th=[  107],  5.00th=[  121], 10.00th=[  122], 20.00th=[  122],
     | 30.00th=[  123], 40.00th=[  123], 50.00th=[  124], 60.00th=[  124],
     | 70.00th=[  124], 80.00th=[  125], 90.00th=[  125], 95.00th=[  126],
     | 99.00th=[  175], 99.50th=[  223], 99.90th=[  225], 99.95th=[  278],
     | 99.99th=[  370]
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.92%, 500=0.06%
  cpu          : usr=41.56%, sys=57.95%, ctx=48, majf=0, minf=38
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=102400/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: io=1600.0MB, aggrb=3782.6MB/s, minb=968321KB/s, maxb=977.11MB/s, mint=409msec, maxt=423msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%
bgupdater: (g=0): rw=randrw, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)
bgupdater: Laying out IO file(s) (1 file(s) / 400MB)

bgupdater: (groupid=0, jobs=1): err= 0: pid=11592: Thu Jan 29 19:45:04 2015
  read : io=205076KB, bw=334545KB/s, iops=83636, runt=   613msec
    slat (usec): min=2, max=73, avg= 2.56, stdev= 0.73
    clat (usec): min=19, max=310, avg=186.14, stdev=13.49
     lat (usec): min=22, max=312, avg=188.81, stdev=13.55
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  229], 99.50th=[  251], 99.90th=[  266], 99.95th=[  274],
     | 99.99th=[  298]
    bw (KB  /s): min=333496, max=333496, per=25.82%, avg=333496.00, stdev= 0.00
  write: io=204524KB, bw=333644KB/s, iops=83411, runt=   613msec
    slat (usec): min=4, max=30, avg= 6.10, stdev= 1.01
    clat (usec): min=2, max=307, avg=186.32, stdev=13.35
     lat (usec): min=8, max=313, avg=192.56, stdev=13.47
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  177],
     | 30.00th=[  181], 40.00th=[  183], 50.00th=[  187], 60.00th=[  189],
     | 70.00th=[  193], 80.00th=[  197], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  227], 99.50th=[  249], 99.90th=[  266], 99.95th=[  274],
     | 99.99th=[  298]
    bw (KB  /s): min=333368, max=333368, per=25.88%, avg=333368.00, stdev= 0.00
    lat (usec) : 4=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=99.47%, 500=0.51%
  cpu          : usr=30.51%, sys=69.00%, ctx=68, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=11593: Thu Jan 29 19:45:04 2015
  read : io=205076KB, bw=334545KB/s, iops=83636, runt=   613msec
    slat (usec): min=2, max=40, avg= 2.53, stdev= 0.65
    clat (usec): min=53, max=3694, avg=186.31, stdev=65.12
     lat (usec): min=55, max=3697, avg=188.96, stdev=65.13
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  181], 50.00th=[  185], 60.00th=[  187],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  201], 95.00th=[  207],
     | 99.00th=[  231], 99.50th=[  249], 99.90th=[  266], 99.95th=[  342],
     | 99.99th=[ 3696]
    bw (KB  /s): min=335528, max=335528, per=25.97%, avg=335528.00, stdev= 0.00
  write: io=204524KB, bw=333644KB/s, iops=83411, runt=   613msec
    slat (usec): min=4, max=160, avg= 6.08, stdev= 1.22
    clat (usec): min=2, max=3693, avg=186.31, stdev=59.38
     lat (usec): min=44, max=3699, avg=192.54, stdev=59.41
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  185], 60.00th=[  189],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  201], 95.00th=[  205],
     | 99.00th=[  225], 99.50th=[  247], 99.90th=[  262], 99.95th=[  346],
     | 99.99th=[ 3696]
    bw (KB  /s): min=335376, max=335376, per=26.03%, avg=335376.00, stdev= 0.00
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=99.55%, 500=0.41%
    lat (msec) : 4=0.03%
  cpu          : usr=30.34%, sys=68.68%, ctx=64, majf=0, minf=9
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=11594: Thu Jan 29 19:45:04 2015
  read : io=205076KB, bw=322954KB/s, iops=80738, runt=   635msec
    slat (usec): min=2, max=9087, avg= 2.75, stdev=41.31
    clat (usec): min=13, max=9287, avg=193.88, stdev=237.09
     lat (usec): min=15, max=9293, avg=196.75, stdev=240.69
    clat percentiles (usec):
     |  1.00th=[  143],  5.00th=[  163], 10.00th=[  169], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  181], 50.00th=[  185], 60.00th=[  189],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  201], 95.00th=[  209],
     | 99.00th=[  255], 99.50th=[  350], 99.90th=[ 3536], 99.95th=[ 8256],
     | 99.99th=[ 9280]
    bw (KB  /s): min=324248, max=324248, per=25.10%, avg=324248.00, stdev= 0.00
  write: io=204524KB, bw=322085KB/s, iops=80521, runt=   635msec
    slat (usec): min=3, max=3360, avg= 6.20, stdev=15.91
    clat (usec): min=1, max=9286, avg=192.34, stdev=210.71
     lat (usec): min=6, max=9293, avg=198.68, stdev=211.36
    clat percentiles (usec):
     |  1.00th=[  145],  5.00th=[  163], 10.00th=[  169], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  185], 60.00th=[  189],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  203], 95.00th=[  209],
     | 99.00th=[  253], 99.50th=[  346], 99.90th=[ 1032], 99.95th=[ 8256],
     | 99.99th=[ 9280]
    bw (KB  /s): min=324656, max=324656, per=25.20%, avg=324656.00, stdev= 0.00
    lat (usec) : 2=0.01%, 10=0.01%, 20=0.01%, 50=0.01%, 100=0.01%
    lat (usec) : 250=98.84%, 500=0.93%, 750=0.05%
    lat (msec) : 2=0.03%, 4=0.06%, 10=0.06%
  cpu          : usr=29.29%, sys=66.14%, ctx=91, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgupdater: (groupid=0, jobs=1): err= 0: pid=11595: Thu Jan 29 19:45:04 2015
  read : io=205076KB, bw=335640KB/s, iops=83909, runt=   611msec
    slat (usec): min=2, max=58, avg= 2.56, stdev= 0.82
    clat (usec): min=17, max=470, avg=185.51, stdev=15.09
     lat (usec): min=20, max=472, avg=188.18, stdev=15.16
    clat percentiles (usec):
     |  1.00th=[  157],  5.00th=[  167], 10.00th=[  171], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  181], 50.00th=[  185], 60.00th=[  187],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  201], 95.00th=[  209],
     | 99.00th=[  233], 99.50th=[  251], 99.90th=[  270], 99.95th=[  330],
     | 99.99th=[  462]
    bw (KB  /s): min=334544, max=334544, per=25.90%, avg=334544.00, stdev= 0.00
  write: io=204524KB, bw=334736KB/s, iops=83684, runt=   611msec
    slat (usec): min=4, max=90, avg= 6.07, stdev= 1.19
    clat (usec): min=2, max=468, avg=185.70, stdev=14.68
     lat (usec): min=8, max=474, avg=191.91, stdev=14.84
    clat percentiles (usec):
     |  1.00th=[  159],  5.00th=[  167], 10.00th=[  171], 20.00th=[  175],
     | 30.00th=[  179], 40.00th=[  183], 50.00th=[  185], 60.00th=[  189],
     | 70.00th=[  191], 80.00th=[  195], 90.00th=[  203], 95.00th=[  209],
     | 99.00th=[  231], 99.50th=[  249], 99.90th=[  266], 99.95th=[  274],
     | 99.99th=[  462]
    bw (KB  /s): min=334440, max=334440, per=25.96%, avg=334440.00, stdev= 0.00
    lat (usec) : 4=0.01%, 20=0.01%, 50=0.01%, 100=0.01%, 250=99.48%
    lat (usec) : 500=0.51%
  cpu          : usr=30.44%, sys=68.58%, ctx=188, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=51269/w=51131/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
   READ: io=820304KB, aggrb=1261.6MB/s, minb=322954KB/s, maxb=335639KB/s, mint=611msec, maxt=635msec
  WRITE: io=818096KB, aggrb=1258.2MB/s, minb=322085KB/s, maxb=334736KB/s, mint=611msec, maxt=635msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%
bgwriter: (g=0): rw=randwrite, bs=4K-4K/4K-4K/4K-4K, ioengine=libaio, iodepth=32
...
fio-2.2.5
Starting 4 processes
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
bgwriter: Laying out IO file(s) (1 file(s) / 400MB)
Jobs: 4 (f=4)
bgwriter: (groupid=0, jobs=1): err= 0: pid=11605: Thu Jan 29 19:45:06 2015
  write: io=409600KB, bw=168144KB/s, iops=42036, runt=  2436msec
    slat (usec): min=10, max=5615, avg=21.50, stdev=37.53
    clat (usec): min=2, max=9808, avg=738.51, stdev=364.25
     lat (usec): min=40, max=9827, avg=760.22, stdev=371.10
    clat percentiles (usec):
     |  1.00th=[  612],  5.00th=[  668], 10.00th=[  684], 20.00th=[  692],
     | 30.00th=[  700], 40.00th=[  700], 50.00th=[  708], 60.00th=[  708],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  732], 95.00th=[  756],
     | 99.00th=[ 1576], 99.50th=[ 3056], 99.90th=[ 6816], 99.95th=[ 9408],
     | 99.99th=[ 9792]
    bw (KB  /s): min=157408, max=176360, per=24.65%, avg=165770.00, stdev=8401.50
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.20%
    lat (usec) : 750=94.24%, 1000=4.14%
    lat (msec) : 2=0.63%, 4=0.45%, 10=0.33%
  cpu          : usr=10.26%, sys=85.22%, ctx=982, majf=0, minf=7
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=11606: Thu Jan 29 19:45:06 2015
  write: io=409600KB, bw=173928KB/s, iops=43481, runt=  2355msec
    slat (usec): min=12, max=1173, avg=20.76, stdev= 7.22
    clat (usec): min=2, max=2247, avg=713.64, stdev=49.05
     lat (usec): min=22, max=2270, avg=734.58, stdev=50.26
    clat percentiles (usec):
     |  1.00th=[  620],  5.00th=[  668], 10.00th=[  684], 20.00th=[  692],
     | 30.00th=[  700], 40.00th=[  708], 50.00th=[  708], 60.00th=[  716],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  740], 95.00th=[  756],
     | 99.00th=[  868], 99.50th=[  924], 99.90th=[ 1368], 99.95th=[ 1608],
     | 99.99th=[ 2192]
    bw (KB  /s): min=170448, max=175504, per=25.63%, avg=172406.00, stdev=2166.56
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.13%
    lat (usec) : 750=92.77%, 1000=6.92%
    lat (msec) : 2=0.17%, 4=0.01%
  cpu          : usr=10.66%, sys=88.66%, ctx=528, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=11607: Thu Jan 29 19:45:06 2015
  write: io=409600KB, bw=172900KB/s, iops=43224, runt=  2369msec
    slat (usec): min=9, max=3458, avg=20.88, stdev=19.13
    clat (usec): min=2, max=4190, avg=718.03, stdev=114.69
     lat (usec): min=22, max=4210, avg=739.09, stdev=116.47
    clat percentiles (usec):
     |  1.00th=[  620],  5.00th=[  668], 10.00th=[  684], 20.00th=[  692],
     | 30.00th=[  700], 40.00th=[  700], 50.00th=[  708], 60.00th=[  708],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  732], 95.00th=[  756],
     | 99.00th=[ 1064], 99.50th=[ 1080], 99.90th=[ 2024], 99.95th=[ 3952],
     | 99.99th=[ 4192]
    bw (KB  /s): min=168600, max=173752, per=25.49%, avg=171458.00, stdev=2129.26
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.14%
    lat (usec) : 750=94.29%, 1000=2.69%
    lat (msec) : 2=2.74%, 4=0.09%, 10=0.03%
  cpu          : usr=10.55%, sys=87.38%, ctx=373, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32
bgwriter: (groupid=0, jobs=1): err= 0: pid=11608: Thu Jan 29 19:45:06 2015
  write: io=409600KB, bw=174150KB/s, iops=43537, runt=  2352msec
    slat (usec): min=9, max=5199, avg=20.79, stdev=26.32
    clat (usec): min=2, max=5915, avg=712.94, stdev=149.06
     lat (usec): min=20, max=5936, avg=733.91, stdev=151.50
    clat percentiles (usec):
     |  1.00th=[  628],  5.00th=[  668], 10.00th=[  684], 20.00th=[  692],
     | 30.00th=[  700], 40.00th=[  708], 50.00th=[  708], 60.00th=[  716],
     | 70.00th=[  716], 80.00th=[  724], 90.00th=[  732], 95.00th=[  740],
     | 99.00th=[  780], 99.50th=[  836], 99.90th=[ 2512], 99.95th=[ 5536],
     | 99.99th=[ 5920]
    bw (KB  /s): min=170872, max=174024, per=25.68%, avg=172714.00, stdev=1386.45
    lat (usec) : 4=0.01%, 50=0.01%, 100=0.01%, 250=0.01%, 500=0.10%
    lat (usec) : 750=97.10%, 1000=2.55%
    lat (msec) : 2=0.08%, 4=0.07%, 10=0.09%
  cpu          : usr=10.50%, sys=88.56%, ctx=260, majf=0, minf=6
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=100.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.1%, 64=0.0%, >=64=0.0%
     issued    : total=r=0/w=102400/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=32

Run status group 0 (all jobs):
  WRITE: io=1600.0MB, aggrb=672577KB/s, minb=168144KB/s, maxb=174149KB/s, mint=2352msec, maxt=2436msec

Disk stats (read/write):
  zram0: ios=0/0, merge=0/0, ticks=0/0, in_queue=0, util=0.00%



	-ss

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=test-fio-randread

[global]
size=400m
directory=/mnt/
ioengine=libaio
iodepth=32
direct=1
invalidate=1
numjobs=4
loops=4

[bgreader]
rw=randread

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=test-fio-randrw

[global]
size=400m
directory=/mnt/
ioengine=libaio
iodepth=32
direct=1
invalidate=1
numjobs=4
loops=5

[bgupdater]
rw=randrw

--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=test-fio-randwrite

[global]
size=400m
directory=/mnt/
ioengine=libaio
iodepth=32
direct=1
invalidate=1
numjobs=4
loops=5

[bgwriter]
rw=randwrite

--BOKacYhQ+x31HxR3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
