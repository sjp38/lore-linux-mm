Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB9796B2475
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:09:09 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x7so5865346pll.23
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:09:09 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id o195si22426177pfg.106.2018.11.20.22.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 22:09:08 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
Date: Tue, 20 Nov 2018 22:09:06 -0800
MIME-Version: 1.0
In-Reply-To: <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Talpey <tom@talpey.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/19/18 10:57 AM, Tom Talpey wrote:
> John, thanks for the discussion at LPC. One of the concerns we
> raised however was the performance test. The numbers below are
> rather obviously tainted. I think we need to get a better baseline
> before concluding anything...
>=20
> Here's my main concern:
>=20

Hi Tom,

Thanks again for looking at this!


> On 11/10/2018 3:50 AM, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>> ...
>> ------------------------------------------------------
>> WITHOUT the patch:
>> ------------------------------------------------------
>> reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4=
096B-4096B, ioengine=3Dlibaio, iodepth=3D64
>> fio-3.3
>> Starting 1 process
>> Jobs: 1 (f=3D1): [R(1)][100.0%][r=3D55.5MiB/s,w=3D0KiB/s][r=3D14.2k,w=3D=
0 IOPS][eta 00m:00s]
>> reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D1750: Tue Nov=C2=A0 6 2=
0:18:06 2018
>> =C2=A0=C2=A0=C2=A0 read: IOPS=3D13.9k, BW=3D54.4MiB/s (57.0MB/s)(1024MiB=
/18826msec)
>=20
> ~14000 4KB read IOPS is really, really low for an NVMe disk.

Yes, but Jan Kara's original config file for fio is *intended* to highlight
the get_user_pages/put_user_pages changes. It was *not* intended to get max
performance,  as you can see by the numjobs and direct IO parameters:

cat fio.conf=20
[reader]
direct=3D1
ioengine=3Dlibaio
blocksize=3D4096
size=3D1g
numjobs=3D1
rw=3Dread
iodepth=3D64


So I'm thinking that this is not a "tainted" test, but rather, we're constr=
aining
things a lot with these choices. It's hard to find a good test config to ru=
n that
allows decisions, but so far, I'm not really seeing anything that says "thi=
s
is so bad that we can't afford to fix the brokenness." I think.

After talking with you and reading this email, I did a bunch more test runs=
,=20
varying the following fio parameters:

	-- direct
	-- numjobs
	-- iodepth

...with both the baseline 4.20-rc3 kernel, and with my patches applied. (bt=
w, if
anyone cares, I'll post a github link that has a complete, testable patchse=
t--not
ready for submission as such, but it works cleanly and will allow others to=
=20
attempt to reproduce my results).

What I'm seeing is that I can get 10x or better improvements in IOPS and BW=
,
just by going to 10 threads and turning off direct IO--as expected. So in t=
he end,
I increased the number of threads, and also increased iodepth a bit.=20


Test results below...


>=20
>> =C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :=
 usr=3D2.39%, sys=3D95.30%, ctx=3D669, majf=3D0, minf=3D72
>=20
> CPU is obviously the limiting factor. At these IOPS, it should be far
> less.
>> ------------------------------------------------------
>> OR, here's a better run WITH the patch applied, and you can see that thi=
s is nearly as good
>> as the "without" case:
>> ------------------------------------------------------
>>
>> reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4=
096B-4096B, ioengine=3Dlibaio, iodepth=3D64
>> fio-3.3
>> Starting 1 process
>> Jobs: 1 (f=3D1): [R(1)][100.0%][r=3D53.2MiB/s,w=3D0KiB/s][r=3D13.6k,w=3D=
0 IOPS][eta 00m:00s]
>> reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D2521: Tue Nov=C2=A0 6 2=
0:01:33 2018
>> =C2=A0=C2=A0=C2=A0 read: IOPS=3D13.4k, BW=3D52.5MiB/s (55.1MB/s)(1024MiB=
/19499msec)
>=20
> Similar low IOPS.
>=20
>> =C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :=
 usr=3D3.47%, sys=3D94.61%, ctx=3D370, majf=3D0, minf=3D73
>=20
> Similar CPU saturation.
>=20
>>
>=20
> I get nearly 400,000 4KB IOPS on my tiny desktop, which has a 25W
> i7-7500 and a Samsung PM961 128GB NVMe (stock Bionic 4.15 kernel
> and fio version 3.1). Even then, the CPU saturates, so it's not
> necessarily a perfect test. I'd like to see your runs both get to
> "max" IOPS, i.e. CPU < 100%, and compare the CPU numbers. This would
> give the best comparison for making a decision.

I can get to CPU < 100% by increasing to 10 or 20 threads, although it
makes latency ever so much worse.

>=20
> Can you confirm what type of hardware you're running this test on?
> CPU, memory speed and capacity, and NVMe device especially?
>=20
> Tom.

Yes, it's a nice new system, I don't expect any strange perf problems:

CPU: Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz
    (Intel X299 chipset)
Block device: nvme-Samsung_SSD_970_EVO_250GB
DRAM: 32 GB

So, here's a comparison using 20 threads, direct IO, for the baseline vs.=20
patched kernel (below). Highlights:

	-- IOPS are similar, around 60k.=20
	-- BW gets worse, dropping from 290 to 220 MB/s.
	-- CPU is well under 100%.
	-- latency is incredibly long, but...20 threads.

Baseline:

$ ./run.sh
fio configuration:
[reader]
ioengine=3Dlibaio
blocksize=3D4096
size=3D1g
rw=3Dread
group_reporting
iodepth=3D256
direct=3D1
numjobs=3D20
-------- Running fio:
reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096=
B-4096B, ioengine=3Dlibaio, iodepth=3D256
...
fio-3.3
Starting 20 processes
Jobs: 4 (f=3D4): [_(8),R(2),_(2),R(1),_(1),R(1),_(5)][95.9%][r=3D244MiB/s,w=
=3D0KiB/s][r=3D62.5k,w=3D0 IOPS][eta 00m:03s]
reader: (groupid=3D0, jobs=3D20): err=3D 0: pid=3D14499: Tue Nov 20 16:20:3=
5 2018
   read: IOPS=3D74.2k, BW=3D290MiB/s (304MB/s)(20.0GiB/70644msec)
    slat (usec): min=3D26, max=3D48167, avg=3D249.27, stdev=3D1200.02
    clat (usec): min=3D42, max=3D147792, avg=3D67108.56, stdev=3D18062.46
     lat (usec): min=3D103, max=3D147943, avg=3D67358.10, stdev=3D18109.75
    clat percentiles (msec):
     |  1.00th=3D[   21],  5.00th=3D[   40], 10.00th=3D[   41], 20.00th=3D[=
   47],
     | 30.00th=3D[   58], 40.00th=3D[   65], 50.00th=3D[   70], 60.00th=3D[=
   75],
     | 70.00th=3D[   79], 80.00th=3D[   83], 90.00th=3D[   89], 95.00th=3D[=
   93],
     | 99.00th=3D[  104], 99.50th=3D[  109], 99.90th=3D[  121], 99.95th=3D[=
  125],
     | 99.99th=3D[  134]
   bw (  KiB/s): min=3D 9712, max=3D46362, per=3D5.11%, avg=3D15164.99, std=
ev=3D2242.15, samples=3D2742
   iops        : min=3D 2428, max=3D11590, avg=3D3790.94, stdev=3D560.53, s=
amples=3D2742
  lat (usec)   : 50=3D0.01%, 250=3D0.01%, 500=3D0.01%, 750=3D0.01%, 1000=3D=
0.01%
  lat (msec)   : 2=3D0.01%, 4=3D0.01%, 10=3D0.02%, 20=3D0.98%, 50=3D20.44%
  lat (msec)   : 100=3D76.95%, 250=3D1.61%
  cpu          : usr=3D1.00%, sys=3D57.65%, ctx=3D158367, majf=3D0, minf=3D=
5284
  IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, 32=3D0.=
1%, >=3D64=3D100.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.1%
     issued rwts: total=3D5242880,0,0,0 short=3D0,0,0,0 dropped=3D0,0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D256

Run status group 0 (all jobs):
   READ: bw=3D290MiB/s (304MB/s), 290MiB/s-290MiB/s (304MB/s-304MB/s), io=
=3D20.0GiB (21.5GB), run=3D70644-70644msec

Disk stats (read/write):
  nvme0n1: ios=3D5240738/7, merge=3D0/7, ticks=3D1457727/5, in_queue=3D1547=
139, util=3D100.00%

--------------------------------------------------------------
Patched:

<redforge> fast_256GB $ ./run.sh=20
fio configuration:
[reader]
ioengine=3Dlibaio
blocksize=3D4096
size=3D1g
rw=3Dread
group_reporting
iodepth=3D256
direct=3D1
numjobs=3D20
-------- Running fio:
reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096=
B-4096B, ioengine=3Dlibaio, iodepth=3D256
...
fio-3.3
Starting 20 processes
Jobs: 13 (f=3D8): [_(1),R(1),_(1),f(1),R(2),_(1),f(2),_(1),R(1),f(1),R(1),f=
(1),R(1),_(2),R(1),_(1),R(1)][97.9%][r=3D229MiB/s,w=3D0KiB/s][r=3D58.5k,w=
=3D0 IOPS][eta 00m:02s]
reader: (groupid=3D0, jobs=3D20): err=3D 0: pid=3D2104: Tue Nov 20 22:01:58=
 2018
   read: IOPS=3D56.8k, BW=3D222MiB/s (232MB/s)(20.0GiB/92385msec)
    slat (usec): min=3D26, max=3D50436, avg=3D337.21, stdev=3D1405.14
    clat (usec): min=3D43, max=3D178839, avg=3D88963.96, stdev=3D21745.31
     lat (usec): min=3D106, max=3D179041, avg=3D89301.43, stdev=3D21800.43
    clat percentiles (msec):
     |  1.00th=3D[   50],  5.00th=3D[   53], 10.00th=3D[   55], 20.00th=3D[=
   68],
     | 30.00th=3D[   79], 40.00th=3D[   86], 50.00th=3D[   93], 60.00th=3D[=
   99],
     | 70.00th=3D[  103], 80.00th=3D[  108], 90.00th=3D[  114], 95.00th=3D[=
  121],
     | 99.00th=3D[  134], 99.50th=3D[  140], 99.90th=3D[  150], 99.95th=3D[=
  155],
     | 99.99th=3D[  163]
   bw (  KiB/s): min=3D 4920, max=3D39733, per=3D5.07%, avg=3D11506.18, std=
ev=3D1540.18, samples=3D3650
   iops        : min=3D 1230, max=3D 9933, avg=3D2876.20, stdev=3D385.05, s=
amples=3D3650
  lat (usec)   : 50=3D0.01%, 100=3D0.01%, 250=3D0.01%, 500=3D0.01%, 750=3D0=
.01%
  lat (usec)   : 1000=3D0.01%
  lat (msec)   : 2=3D0.01%, 4=3D0.01%, 10=3D0.01%, 20=3D0.23%, 50=3D1.13%
  lat (msec)   : 100=3D63.04%, 250=3D35.57%
  cpu          : usr=3D0.65%, sys=3D58.07%, ctx=3D188963, majf=3D0, minf=3D=
5303
  IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, 32=3D0.=
1%, >=3D64=3D100.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.1%
     issued rwts: total=3D5242880,0,0,0 short=3D0,0,0,0 dropped=3D0,0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D256

Run status group 0 (all jobs):
   READ: bw=3D222MiB/s (232MB/s), 222MiB/s-222MiB/s (232MB/s-232MB/s), io=
=3D20.0GiB (21.5GB), run=3D92385-92385msec

Disk stats (read/write):
  nvme0n1: ios=3D5240550/7, merge=3D0/7, ticks=3D1513681/4, in_queue=3D1636=
411, util=3D100.00%


Thoughts?


thanks,
--=20
John Hubbard
NVIDIA
