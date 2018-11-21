Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A28BE6B27D0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 17:06:37 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id x7so10518276pll.23
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 14:06:37 -0800 (PST)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id c6si26873943plr.414.2018.11.21.14.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 14:06:36 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
 <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
 <97934904-2754-77e0-5fcb-83f2311362ee@nvidia.com>
 <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c1ba07d6-ebfa-ddb9-c25e-e5c1bfbecf74@nvidia.com>
Date: Wed, 21 Nov 2018 14:06:34 -0800
MIME-Version: 1.0
In-Reply-To: <5159e02f-17f8-df8b-600c-1b09356e46a9@talpey.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Talpey <tom@talpey.com>, john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org

On 11/21/18 8:49 AM, Tom Talpey wrote:
> On 11/21/2018 1:09 AM, John Hubbard wrote:
>> On 11/19/18 10:57 AM, Tom Talpey wrote:
>>> ~14000 4KB read IOPS is really, really low for an NVMe disk.
>>
>> Yes, but Jan Kara's original config file for fio is *intended* to highli=
ght
>> the get_user_pages/put_user_pages changes. It was *not* intended to get =
max
>> performance,=C2=A0 as you can see by the numjobs and direct IO parameter=
s:
>>
>> cat fio.conf
>> [reader]
>> direct=3D1
>> ioengine=3Dlibaio
>> blocksize=3D4096
>> size=3D1g
>> numjobs=3D1
>> rw=3Dread
>> iodepth=3D64
>=20
> To be clear - I used those identical parameters, on my lower-spec
> machine, and got 400,000 4KB read IOPS. Those results are nearly 30x
> higher than yours!

OK, then something really is wrong here...

>=20
>> So I'm thinking that this is not a "tainted" test, but rather, we're con=
straining
>> things a lot with these choices. It's hard to find a good test config to=
 run that
>> allows decisions, but so far, I'm not really seeing anything that says "=
this
>> is so bad that we can't afford to fix the brokenness." I think.
>=20
> I'm not suggesting we tune the benchmark, I'm suggesting the results
> on your system are not meaningful since they are orders of magnitude
> low. And without meaningful data it's impossible to see the performance
> impact of the change...
>=20
>>> Can you confirm what type of hardware you're running this test on?
>>> CPU, memory speed and capacity, and NVMe device especially?
>>>
>>> Tom.
>>
>> Yes, it's a nice new system, I don't expect any strange perf problems:
>>
>> CPU: Intel(R) Core(TM) i7-7800X CPU @ 3.50GHz
>> =C2=A0=C2=A0=C2=A0=C2=A0 (Intel X299 chipset)
>> Block device: nvme-Samsung_SSD_970_EVO_250GB
>> DRAM: 32 GB
>=20
> The Samsung Evo 970 250GB is speced to yield 200,000 random read IOPS
> with a 4KB QD32 workload:
>=20
>=20
> https://www.samsung.com/us/computing/memory-storage/solid-state-drives/ss=
d-970-evo-nvme-m-2-250gb-mz-v7e250bw/#specs
>=20
> And the I7-7800X is a 6-core processor (12 hyperthreads).
>=20
>> So, here's a comparison using 20 threads, direct IO, for the baseline vs=
.
>> patched kernel (below). Highlights:
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0-- IOPS are similar, around 60k.
>> =C2=A0=C2=A0=C2=A0=C2=A0-- BW gets worse, dropping from 290 to 220 MB/s.
>> =C2=A0=C2=A0=C2=A0=C2=A0-- CPU is well under 100%.
>> =C2=A0=C2=A0=C2=A0=C2=A0-- latency is incredibly long, but...20 threads.
>>
>> Baseline:
>>
>> $ ./run.sh
>> fio configuration:
>> [reader]
>> ioengine=3Dlibaio
>> blocksize=3D4096
>> size=3D1g
>> rw=3Dread
>> group_reporting
>> iodepth=3D256
>> direct=3D1
>> numjobs=3D20
>=20
> Ouch - 20 threads issuing 256 io's each!? Of course latency skyrockets.
> That's going to cause tremendous queuing, and context switching, far
> outside of the get_user_pages() change.
>=20
> But even so, it only brings IOPS to 74.2K, which is still far short of
> the device's 200K spec.
>=20
> Comparing anyway:
>=20
>=20
>> Patched:
>>
>> -------- Running fio:
>> reader: (g=3D0): rw=3Dread, bs=3D(R) 4096B-4096B, (W) 4096B-4096B, (T) 4=
096B-4096B, ioengine=3Dlibaio, iodepth=3D256
>> ...
>> fio-3.3
>> Starting 20 processes
>> Jobs: 13 (f=3D8): [_(1),R(1),_(1),f(1),R(2),_(1),f(2),_(1),R(1),f(1),R(1=
),f(1),R(1),_(2),R(1),_(1),R(1)][97.9%][r=3D229MiB/s,w=3D0KiB/s][r=3D58.5k,=
w=3D0 IOPS][eta 00m:02s]
>> reader: (groupid=3D0, jobs=3D20): err=3D 0: pid=3D2104: Tue Nov 20 22:01=
:58 2018
>> =C2=A0=C2=A0=C2=A0 read: IOPS=3D56.8k, BW=3D222MiB/s (232MB/s)(20.0GiB/9=
2385msec)
>> ...
>> Thoughts?
>=20
> Concern - the 74.2K IOPS unpatched drops to 56.8K patched!

ACK. :)

>=20
> What I'd really like to see is to go back to the original fio parameters
> (1 thread, 64 iodepth) and try to get a result that gets at least close
> to the speced 200K IOPS of the NVMe device. There seems to be something
> wrong with yours, currently.

I'll dig into what has gone wrong with the test. I see fio putting data fil=
es
in the right place, so the obvious "using the wrong drive" is (probably)
not it. Even though it really feels like that sort of thing. We'll see.=20

>=20
> Then of course, the result with the patched get_user_pages, and
> compare whichever of IOPS or CPU% changes, and how much.
>=20
> If these are within a few percent, I agree it's good to go. If it's
> roughly 25% like the result just above, that's a rocky road.
>=20
> I can try this after the holiday on some basic hardware and might
> be able to scrounge up better. Can you post that github link?
>=20

Here:

   git@github.com:johnhubbard/linux (branch: gup_dma_testing)


--=20
thanks,
John Hubbard
NVIDIA
