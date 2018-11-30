Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3CE6B55CE
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 21:21:50 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p3so3026554plk.9
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 18:21:50 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id h10si3556363pgi.562.2018.11.29.18.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 18:21:48 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
 <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
 <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
 <c1ba07d6-ebfa-ddb9-c25e-e5c1bfbecf74@nvidia.com>
 <15e4a0c0-cadd-e549-962f-8d9aa9fc033a@talpey.com>
 <313bf82d-cdeb-8c75-3772-7a124ecdfbd5@nvidia.com>
 <2aa422df-d5df-5ddb-a2e4-c5e5283653b5@talpey.com>
 <7a68b7fc-ff9d-381e-2444-909c9c2f6679@nvidia.com>
 <1939f47a-eaec-3f2c-4ae7-f92d9fba7693@talpey.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <0f093af1-dee9-51b6-0795-2c073a951fed@nvidia.com>
Date: Thu, 29 Nov 2018 18:21:47 -0800
MIME-Version: 1.0
In-Reply-To: <1939f47a-eaec-3f2c-4ae7-f92d9fba7693@talpey.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Talpey <tom@talpey.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/29/18 6:18 PM, Tom Talpey wrote:
> On 11/29/2018 8:39 PM, John Hubbard wrote:
>> On 11/28/18 5:59 AM, Tom Talpey wrote:
>>> On 11/27/2018 9:52 PM, John Hubbard wrote:
>>>> On 11/27/18 5:21 PM, Tom Talpey wrote:
>>>>> On 11/21/2018 5:06 PM, John Hubbard wrote:
>>>>>> On 11/21/18 8:49 AM, Tom Talpey wrote:
>>>>>>> On 11/21/2018 1:09 AM, John Hubbard wrote:
>>>>>>>> On 11/19/18 10:57 AM, Tom Talpey wrote:
>>>> [...]
>>>>> I'm super-limited here this week hardware-wise and have not been able
>>>>> to try testing with the patched kernel.
>>>>>
>>>>> I was able to compare my earlier quick test with a Bionic 4.15 kernel
>>>>> (400K IOPS) against a similar 4.20rc3 kernel, and the rate dropped to
>>>>> ~_375K_ IOPS. Which I found perhaps troubling. But it was only a quic=
k
>>>>> test, and without your change.
>>>>>
>>>>
>>>> So just to double check (again): you are running fio with these parame=
ters,
>>>> right?
>>>>
>>>> [reader]
>>>> direct=3D1
>>>> ioengine=3Dlibaio
>>>> blocksize=3D4096
>>>> size=3D1g
>>>> numjobs=3D1
>>>> rw=3Dread
>>>> iodepth=3D64
>>>
>>> Correct, I copy/pasted these directly. I also ran with size=3D10g becau=
se
>>> the 1g provides a really small sample set.
>>>
>>> There was one other difference, your results indicated fio 3.3 was used=
.
>>> My Bionic install has fio 3.1. I don't find that relevant because our
>>> goal is to compare before/after, which I haven't done yet.
>>>
>>
>> OK, the 50 MB/s was due to my particular .config. I had some expensive d=
ebug options
>> set in mm, fs and locking subsystems. Turning those off, I'm back up to =
the rated
>> speed of the Samsung NVMe device, so now we should have a clearer pictur=
e of the
>> performance that real users will see.
>=20
> Oh, good! I'm especially glad because I was having a heck of a time
> reconfiguring the one machine I have available for this.
>=20
>> Continuing on, then: running a before and after test, I don't see any si=
gnificant
>> difference in the fio results:
>=20
> Excerpting from below:
>=20
>> Baseline 4.20.0-rc3 (commit f2ce1065e767), as before:
>>=C2=A0=C2=A0=C2=A0=C2=A0 read: IOPS=3D193k, BW=3D753MiB/s (790MB/s)(1024M=
iB/1360msec)
>>=C2=A0=C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 : usr=3D16.26%, sys=3D48.05%, ctx=3D251258, majf=3D0, minf=3D73
>=20
> vs
>=20
>> With patches applied:
>>=C2=A0=C2=A0=C2=A0=C2=A0 read: IOPS=3D193k, BW=3D753MiB/s (790MB/s)(1024M=
iB/1360msec)
>>=C2=A0=C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0 : usr=3D16.26%, sys=3D48.05%, ctx=3D251258, majf=3D0, minf=3D73
>=20
> Perfect results, not CPU limited, and full IOPS.
>=20
> Curiously identical, so I trust you've checked that you measured
> both targets, but if so, I say it's good.
>=20

Argh, copy-paste error in the email. The real "before" is ever so slightly
better, at 194K IOPS and 759 MB/s:

 $ fio ./experimental-fio.conf
reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096=
B-4096B, ioengine=3Dlibaio, iodepth=3D64
fio-3.3
Starting 1 process
Jobs: 1 (f=3D1)
reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D1715: Thu Nov 29 17:07:09 =
2018
   read: IOPS=3D194k, BW=3D759MiB/s (795MB/s)(1024MiB/1350msec)
    slat (nsec): min=3D1245, max=3D2812.7k, avg=3D1538.03, stdev=3D5519.61
    clat (usec): min=3D148, max=3D755, avg=3D326.85, stdev=3D18.13
     lat (usec): min=3D150, max=3D3483, avg=3D328.41, stdev=3D19.53
    clat percentiles (usec):
     |  1.00th=3D[  322],  5.00th=3D[  326], 10.00th=3D[  326], 20.00th=3D[=
  326],
     | 30.00th=3D[  326], 40.00th=3D[  326], 50.00th=3D[  326], 60.00th=3D[=
  326],
     | 70.00th=3D[  326], 80.00th=3D[  326], 90.00th=3D[  326], 95.00th=3D[=
  326],
     | 99.00th=3D[  355], 99.50th=3D[  537], 99.90th=3D[  553], 99.95th=3D[=
  553],
     | 99.99th=3D[  619]
   bw (  KiB/s): min=3D767816, max=3D783096, per=3D99.84%, avg=3D775456.00,=
 stdev=3D10804.59, samples=3D2
   iops        : min=3D191954, max=3D195774, avg=3D193864.00, stdev=3D2701.=
15, samples=3D2
  lat (usec)   : 250=3D0.09%, 500=3D99.30%, 750=3D0.61%, 1000=3D0.01%
  cpu          : usr=3D18.24%, sys=3D44.77%, ctx=3D251527, majf=3D0, minf=
=3D73
  IO depths    : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%, 8=3D0.1%, 16=3D0.1%, 32=3D0.=
1%, >=3D64=3D100.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.1%, >=3D64=3D0.0%
     issued rwts: total=3D262144,0,0,0 short=3D0,0,0,0 dropped=3D0,0,0,0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D64

Run status group 0 (all jobs):
   READ: bw=3D759MiB/s (795MB/s), 759MiB/s-759MiB/s (795MB/s-795MB/s), io=
=3D1024MiB (1074MB), run=3D1350-1350msec

Disk stats (read/write):
  nvme0n1: ios=3D222853/0, merge=3D0/0, ticks=3D71410/0, in_queue=3D71935, =
util=3D100.00%

thanks,
--=20
John Hubbard
NVIDIA
>=20
>>
>> fio.conf:
>>
>> [reader]
>> direct=3D1
>> ioengine=3Dlibaio
>> blocksize=3D4096
>> size=3D1g
>> numjobs=3D1
>> rw=3Dread
>> iodepth=3D64
>>
>> ---------------------------------------------------------
>> Baseline 4.20.0-rc3 (commit f2ce1065e767), as before:
>>
[deleted with prejudice. See the correction above, instead] --jhubbard
>>
>> ---------------------------------------------------------
>> With patches applied:
>>
>> <redforge> fast_256GB $ fio ./experimental-fio.conf
>> reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4=
096B-4096B, ioengine=3Dlibaio, iodepth=3D64
>> fio-3.3
>> Starting 1 process
>> Jobs: 1 (f=3D1)
>> reader: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D1738: Thu Nov 29 17:20:=
07 2018
>> =C2=A0=C2=A0=C2=A0 read: IOPS=3D193k, BW=3D753MiB/s (790MB/s)(1024MiB/13=
60msec)
>> =C2=A0=C2=A0=C2=A0=C2=A0 slat (nsec): min=3D1381, max=3D46469, avg=3D164=
9.48, stdev=3D594.46
>> =C2=A0=C2=A0=C2=A0=C2=A0 clat (usec): min=3D162, max=3D12247, avg=3D330.=
00, stdev=3D185.55
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lat (usec): min=3D165, max=3D12253, avg=
=3D331.68, stdev=3D185.69
>> =C2=A0=C2=A0=C2=A0=C2=A0 clat percentiles (usec):
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 |=C2=A0 1.00th=3D[=C2=A0 322],=C2=A0 5.00=
th=3D[=C2=A0 326], 10.00th=3D[=C2=A0 326], 20.00th=3D[=C2=A0 326],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 30.00th=3D[=C2=A0 326], 40.00th=3D[=C2=
=A0 326], 50.00th=3D[=C2=A0 326], 60.00th=3D[=C2=A0 326],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 70.00th=3D[=C2=A0 326], 80.00th=3D[=C2=
=A0 326], 90.00th=3D[=C2=A0 326], 95.00th=3D[=C2=A0 326],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 99.00th=3D[=C2=A0 379], 99.50th=3D[=C2=
=A0 594], 99.90th=3D[=C2=A0 603], 99.95th=3D[=C2=A0 611],
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 | 99.99th=3D[12125]
>> =C2=A0=C2=A0=C2=A0 bw (=C2=A0 KiB/s): min=3D751640, max=3D782912, per=3D=
99.52%, avg=3D767276.00, stdev=3D22112.64, samples=3D2
>> =C2=A0=C2=A0=C2=A0 iops=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 : min=
=3D187910, max=3D195728, avg=3D191819.00, stdev=3D5528.16, samples=3D2
>> =C2=A0=C2=A0 lat (usec)=C2=A0=C2=A0 : 250=3D0.08%, 500=3D99.30%, 750=3D0=
.59%
>> =C2=A0=C2=A0 lat (msec)=C2=A0=C2=A0 : 20=3D0.02%
>> =C2=A0=C2=A0 cpu=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 :=
 usr=3D16.26%, sys=3D48.05%, ctx=3D251258, majf=3D0, minf=3D73
>> =C2=A0=C2=A0 IO depths=C2=A0=C2=A0=C2=A0 : 1=3D0.1%, 2=3D0.1%, 4=3D0.1%,=
 8=3D0.1%, 16=3D0.1%, 32=3D0.1%, >=3D64=3D100.0%
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 submit=C2=A0=C2=A0=C2=A0 : 0=3D0.0%, 4=3D=
100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=3D0.0%, >=3D64=3D0.0%
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 complete=C2=A0 : 0=3D0.0%, 4=3D100.0%, 8=
=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=3D0.1%, >=3D64=3D0.0%
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 issued rwts: total=3D262144,0,0,0 short=
=3D0,0,0,0 dropped=3D0,0,0,0
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 latency=C2=A0=C2=A0 : target=3D0, window=
=3D0, percentile=3D100.00%, depth=3D64
>>
>> Run status group 0 (all jobs):
>> =C2=A0=C2=A0=C2=A0 READ: bw=3D753MiB/s (790MB/s), 753MiB/s-753MiB/s (790=
MB/s-790MB/s), io=3D1024MiB (1074MB), run=3D1360-1360msec
>>
>> Disk stats (read/write):
>> =C2=A0=C2=A0 nvme0n1: ios=3D220798/0, merge=3D0/0, ticks=3D71481/0, in_q=
ueue=3D71966, util=3D100.00%
>>
>>
>> thanks,
>>
>=20
