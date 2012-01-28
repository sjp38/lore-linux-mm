Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 429656B005D
	for <linux-mm@kvack.org>; Sat, 28 Jan 2012 09:44:31 -0500 (EST)
From: "Wu, Fengguang" <fengguang.wu@intel.com>
Subject: RE: [Bug 12309] Large I/O operations result in poor interactive
 performance and high iowait times
Date: Sat, 28 Jan 2012 14:44:24 +0000
Message-ID: <AAFC850A73EC0C40804D40FD09800642101AEA51@SHSMSX102.ccr.corp.intel.com>
References: <bug-12309-27@https.bugzilla.kernel.org/>
	<201201201611.q0KGBPf6029256@bugzilla.kernel.org>,<20120120144513.f457a58d.akpm@linux-foundation.org>
In-Reply-To: <20120120144513.f457a58d.akpm@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "fengguang.wu@gmail.com" <fengguang.wu@gmail.com>

[replying from webmail and CC my gmail account]=0A=
=0A=
>> https://bugzilla.kernel.org/show_bug.cgi?id=3D12309=0A=
=0A=
> We've had some recent updates to the world's largest bug report.=0A=
> Apparently our large-writer-paralyses-the-machine problems have=0A=
> worsened in recent kernels.=0A=
=0A=
Yeah I can reproduce the interactive problem on 3.3-rc1, and the main stall=
s seem to happen when loading the task and allocating memory.=0A=
=0A=
My test case is to start a small 1MB dd when there are 10 long running dd t=
asks=0A=
each writing to one JBOD disk.=0A=
=0A=
[long running dd tasks]=0A=
root      5232 28.6  0.0   8316   632 ?        D    21:19   0:36 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdc1/zero-1=0A=
root      5235 27.4  0.0   8316   632 ?        D    21:19   0:34 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdd1/zero-1=0A=
root      5238 30.5  0.0   8316   632 ?        R    21:19   0:38 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sde1/zero-1=0A=
root      5241 29.7  0.0   8316   628 ?        R    21:19   0:37 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdf1/zero-1=0A=
root      5244 25.8  0.0   8316   628 ?        D    21:19   0:32 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdg1/zero-1=0A=
root      5247 23.4  0.0   8316   632 ?        D    21:19   0:29 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdh1/zero-1=0A=
root      5250 23.4  0.0   8316   632 ?        R    21:19   0:29 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdi1/zero-1=0A=
root      5253 23.7  0.0   8316   632 ?        D    21:19   0:30 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdj1/zero-1=0A=
root      5256 22.3  0.0   8316   632 ?        D    21:19   0:28 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdk1/zero-1=0A=
root      5259 23.7  0.0   8316   628 ?        D    21:19   0:30 dd bs=3D4k=
 if=3D/dev/zero of=3D/fs/sdl1/zero-1=0A=
=0A=
[short 1MB dd command which is repeated for many times]=0A=
	wfg@lkp-nex04 /fs/sdj1% sudo dd if=3D/dev/zero of=3Dzero2 bs=3D1M count=3D=
1=0A=
=0A=
The long running dd is progressing at 60-70MB/s, however the small 1MB dd i=
s=0A=
rather slow in all but one invocations:=0A=
=0A=
	1048576 bytes (1.0 MB) copied, 0.2296 s,   4.6 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.366903 s, 2.9 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.47013 s,  2.2 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.257523 s, 4.1 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.36692 s,  2.9 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.473319 s, 2.2 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.50198 s,  2.1 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.018758 s, 55.9 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.341166 s, 3.1 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.348311 s, 3.0 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.418185 s, 2.5 MB/s=0A=
	1048576 bytes (1.0 MB) copied, 0.444071 s, 2.4 MB/s=0A=
=0A=
And the 10MB dd can achieve much better throughput:=0A=
=0A=
	wfg@lkp-nex04 /fs/sdj1% sudo dd if=3D/dev/zero of=3Dzero2 bs=3D1M count=3D=
10=0A=
=0A=
	10485760 bytes (10 MB) copied, 0.417411 s, 25.1 MB/s=0A=
	10485760 bytes (10 MB) copied, 0.468597 s, 22.4 MB/s=0A=
=0A=
Below is the balance_dirty_pages trace events for the small 1MB/10MB dd tas=
ks=0A=
(dd-5253 is the long running dd task on bdi 8:144).=0A=
=0A=
              dd-5563  [025] ....   165.504338: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950856 bdi_setpoint=3D83005 =
bdi_dirty=3D81032 dirty_ratelimit=3D63408 task_ratelimit=3D63592 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5563  [025] ....   165.504703: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950942 bdi_setpoint=3D83005 =
bdi_dirty=3D81088 dirty_ratelimit=3D63408 task_ratelimit=3D63528 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294824915 period=3D2 think=3D429=
4824917=0A=
              dd-5563  [025] ....   165.505039: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951051 bdi_setpoint=3D83005 =
bdi_dirty=3D81088 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5563  [025] ....   165.505469: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950754 bdi_setpoint=3D82981 =
bdi_dirty=3D81200 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5563  [025] ....   165.505971: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950845 bdi_setpoint=3D82973 =
bdi_dirty=3D81200 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5563  [025] ....   165.506398: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950999 bdi_setpoint=3D82973 =
bdi_dirty=3D81312 dirty_ratelimit=3D63408 task_ratelimit=3D63408 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
=0A=
The traces show that balance_dirty_pages is trying to throttle the short li=
ved=0A=
dd tasks at around task_ratelimit=3D63592 KB/s, which is the right thing to=
 do.=0A=
=0A=
Judging from the timestamps and the pause=3DX fields, we can tell that=0A=
=0A=
- the short lived dd tasks spend very little time in balance_dirty_pages()=
=0A=
=0A=
For dd-5563, pause=3D0,-4294824915,0,0,0,7 which adds up to 7ms.=0A=
=0A=
- 99% block time should occur in loading the dd process and allocating the =
memory=0A=
=0A=
Because the dd-5563 balance_dirty_pages events start at 165.504338 and ends=
 at=0A=
165.506398 which only takes 2ms in between.=0A=
=0A=
Thanks,=0A=
Fengguang=0A=
---=0A=
wfg@bee /export/writeback/lkp-nex04/JBOD-10HDD-thresh=3D4G/ext4-1dd-1-3.3.0=
-rc1% bzgrep 8:144: trace.bz2 |g -v dd-5253|g dd=0A=
              dd-5563  [025] ....   165.504338: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950856 bdi_setpoint=3D83005 =
bdi_dirty=3D81032 dirty_ratelimit=3D63408 task_ratelimit=3D63592 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5563  [025] ....   165.504703: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950942 bdi_setpoint=3D83005 =
bdi_dirty=3D81088 dirty_ratelimit=3D63408 task_ratelimit=3D63528 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294824915 period=3D2 think=3D429=
4824917=0A=
              dd-5563  [025] ....   165.505039: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951051 bdi_setpoint=3D83005 =
bdi_dirty=3D81088 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5563  [025] ....   165.505469: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950754 bdi_setpoint=3D82981 =
bdi_dirty=3D81200 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5563  [025] ....   165.505971: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950845 bdi_setpoint=3D82973 =
bdi_dirty=3D81200 dirty_ratelimit=3D63408 task_ratelimit=3D63468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5563  [025] ....   165.506398: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950999 bdi_setpoint=3D82973 =
bdi_dirty=3D81312 dirty_ratelimit=3D63408 task_ratelimit=3D63408 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5572  [041] ....   167.463729: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950826 bdi_setpoint=3D82916 =
bdi_dirty=3D83720 dirty_ratelimit=3D63400 task_ratelimit=3D61788 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5572  [041] ....   167.464038: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950760 bdi_setpoint=3D82910 =
bdi_dirty=3D83720 dirty_ratelimit=3D63400 task_ratelimit=3D61788 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294826878 period=3D2 think=3D429=
4826880=0A=
              dd-5572  [041] ....   167.464323: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950737 bdi_setpoint=3D82910 =
bdi_dirty=3D83720 dirty_ratelimit=3D63400 task_ratelimit=3D61788 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5572  [041] ....   167.464645: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950667 bdi_setpoint=3D82898 =
bdi_dirty=3D83776 dirty_ratelimit=3D63400 task_ratelimit=3D61728 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5572  [041] ....   167.464964: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950804 bdi_setpoint=3D82898 =
bdi_dirty=3D83832 dirty_ratelimit=3D63400 task_ratelimit=3D61728 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5572  [041] ....   167.465286: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950903 bdi_setpoint=3D82891 =
bdi_dirty=3D83832 dirty_ratelimit=3D63400 task_ratelimit=3D61728 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5581  [051] ....   169.594955: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955229 bdi_setpoint=3D83567 =
bdi_dirty=3D84000 dirty_ratelimit=3D63400 task_ratelimit=3D61540 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5581  [051] ....   169.595226: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955141 bdi_setpoint=3D83563 =
bdi_dirty=3D84000 dirty_ratelimit=3D63400 task_ratelimit=3D61540 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294829013 period=3D2 think=3D429=
4829015=0A=
              dd-5581  [051] ....   169.595486: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955174 bdi_setpoint=3D83563 =
bdi_dirty=3D84056 dirty_ratelimit=3D63400 task_ratelimit=3D61480 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5581  [051] ....   169.595752: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955196 bdi_setpoint=3D83563 =
bdi_dirty=3D84112 dirty_ratelimit=3D63400 task_ratelimit=3D61480 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5581  [051] ....   169.596042: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955262 bdi_setpoint=3D83563 =
bdi_dirty=3D84112 dirty_ratelimit=3D63400 task_ratelimit=3D61480 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5581  [051] ....   169.596334: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955196 bdi_setpoint=3D83558 =
bdi_dirty=3D84168 dirty_ratelimit=3D63400 task_ratelimit=3D61416 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5592  [049] ....   171.845210: bdi_dirty_ratelimit: bdi 8:=
144: write_bw=3D64504 awrite_bw=3D63908 dirty_rate=3D22072 dirty_ratelimit=
=3D63400 task_ratelimit=3D63960 balanced_dirty_ratelimit=3D63908=0A=
              dd-5592  [049] ....   171.845211: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953514 bdi_setpoint=3D84104 =
bdi_dirty=3D81032 dirty_ratelimit=3D63400 task_ratelimit=3D63956 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5592  [049] ....   171.845603: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953504 bdi_setpoint=3D84096 =
bdi_dirty=3D81088 dirty_ratelimit=3D63400 task_ratelimit=3D63892 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294831268 period=3D2 think=3D429=
4831270=0A=
              dd-5592  [049] ....   171.846095: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953608 bdi_setpoint=3D84096 =
bdi_dirty=3D81144 dirty_ratelimit=3D63400 task_ratelimit=3D63832 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5592  [049] ....   171.846484: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953723 bdi_setpoint=3D84096 =
bdi_dirty=3D81256 dirty_ratelimit=3D63400 task_ratelimit=3D63768 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5592  [049] ....   171.846899: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953871 bdi_setpoint=3D84096 =
bdi_dirty=3D81312 dirty_ratelimit=3D63400 task_ratelimit=3D63768 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5592  [049] ....   171.847315: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953890 bdi_setpoint=3D84088 =
bdi_dirty=3D81368 dirty_ratelimit=3D63400 task_ratelimit=3D63708 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5601  [049] ....   173.794360: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955596 bdi_setpoint=3D84205 =
bdi_dirty=3D84504 dirty_ratelimit=3D63400 task_ratelimit=3D61604 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5601  [049] ....   173.794888: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955651 bdi_setpoint=3D84205 =
bdi_dirty=3D84560 dirty_ratelimit=3D63400 task_ratelimit=3D61540 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294833221 period=3D2 think=3D429=
4833223=0A=
              dd-5601  [049] ....   173.795259: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955410 bdi_setpoint=3D84187 =
bdi_dirty=3D84560 dirty_ratelimit=3D63400 task_ratelimit=3D61604 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5601  [049] ....   173.795634: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955375 bdi_setpoint=3D84187 =
bdi_dirty=3D84616 dirty_ratelimit=3D63400 task_ratelimit=3D61540 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5601  [049] ....   173.796186: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955480 bdi_setpoint=3D84187 =
bdi_dirty=3D84616 dirty_ratelimit=3D63400 task_ratelimit=3D61540 dirtied=3D=
32 dirtied_pause=3D32 paused=3D1 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5601  [049] ....   173.796807: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955461 bdi_setpoint=3D84248 =
bdi_dirty=3D84560 dirty_ratelimit=3D63400 task_ratelimit=3D61604 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5610  [041] ....   176.710294: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D958022 bdi_setpoint=3D82789 =
bdi_dirty=3D85736 dirty_ratelimit=3D63400 task_ratelimit=3D59620 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5610  [041] ....   176.710729: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957956 bdi_setpoint=3D82781 =
bdi_dirty=3D85736 dirty_ratelimit=3D63400 task_ratelimit=3D59620 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294836143 period=3D2 think=3D429=
4836145=0A=
              dd-5610  [041] ....   176.711224: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D958077 bdi_setpoint=3D82781 =
bdi_dirty=3D85848 dirty_ratelimit=3D63400 task_ratelimit=3D59560 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5610  [041] ....   176.711747: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D958187 bdi_setpoint=3D82772 =
bdi_dirty=3D85904 dirty_ratelimit=3D63400 task_ratelimit=3D59496 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5610  [041] ....   176.712235: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D958152 bdi_setpoint=3D82762 =
bdi_dirty=3D85960 dirty_ratelimit=3D63400 task_ratelimit=3D59436 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5610  [041] ....   176.712732: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D958343 bdi_setpoint=3D82762 =
bdi_dirty=3D86072 dirty_ratelimit=3D63400 task_ratelimit=3D59372 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5641  [049] ....   190.728161: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955683 bdi_setpoint=3D80839 =
bdi_dirty=3D86408 dirty_ratelimit=3D63168 task_ratelimit=3D57924 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5641  [049] ....   190.728460: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955767 bdi_setpoint=3D80839 =
bdi_dirty=3D86408 dirty_ratelimit=3D63168 task_ratelimit=3D57924 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294850188 period=3D2 think=3D429=
4850190=0A=
              dd-5641  [049] ....   190.728773: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955894 bdi_setpoint=3D80839 =
bdi_dirty=3D86408 dirty_ratelimit=3D63168 task_ratelimit=3D57924 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5641  [049] ....   190.729086: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955889 bdi_setpoint=3D80833 =
bdi_dirty=3D86464 dirty_ratelimit=3D63168 task_ratelimit=3D57860 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5641  [049] ....   190.729380: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955997 bdi_setpoint=3D80833 =
bdi_dirty=3D86464 dirty_ratelimit=3D63168 task_ratelimit=3D57860 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5641  [049] ....   190.729687: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956072 bdi_setpoint=3D80833 =
bdi_dirty=3D86520 dirty_ratelimit=3D63168 task_ratelimit=3D57860 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5668  [057] ....   206.594016: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957370 bdi_setpoint=3D84074 =
bdi_dirty=3D83944 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
1 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D0 think=3D0=0A=
              dd-5668  [057] ....   206.594029: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957379 bdi_setpoint=3D84074 =
bdi_dirty=3D83944 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5668  [057] ....   206.594041: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957379 bdi_setpoint=3D84074 =
bdi_dirty=3D83944 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294866085 period=3D2 think=3D429=
4866087=0A=
              dd-5668  [057] ....   206.594051: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957379 bdi_setpoint=3D84074 =
bdi_dirty=3D83944 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5668  [057] ....   206.594315: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957456 bdi_setpoint=3D84074 =
bdi_dirty=3D83944 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5668  [057] ....   206.594651: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957475 bdi_setpoint=3D84166 =
bdi_dirty=3D83832 dirty_ratelimit=3D63072 task_ratelimit=3D61468 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5668  [057] ....   206.595011: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957579 bdi_setpoint=3D84166 =
bdi_dirty=3D83888 dirty_ratelimit=3D63072 task_ratelimit=3D61344 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5668  [057] ....   206.602945: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D957726 bdi_setpoint=3D84063 =
bdi_dirty=3D84112 dirty_ratelimit=3D63072 task_ratelimit=3D61160 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5677  [057] ....   212.243213: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941736 bdi_setpoint=3D84089 =
bdi_dirty=3D85232 dirty_ratelimit=3D63072 task_ratelimit=3D61900 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5677  [057] ....   212.243532: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941813 bdi_setpoint=3D84089 =
bdi_dirty=3D85288 dirty_ratelimit=3D63072 task_ratelimit=3D61840 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294871746 period=3D2 think=3D429=
4871748=0A=
              dd-5677  [057] ....   212.243853: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941615 bdi_setpoint=3D84069 =
bdi_dirty=3D85288 dirty_ratelimit=3D63072 task_ratelimit=3D61840 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5677  [057] ....   212.244175: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941648 bdi_setpoint=3D84069 =
bdi_dirty=3D85344 dirty_ratelimit=3D63072 task_ratelimit=3D61776 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5677  [057] ....   212.244500: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941755 bdi_setpoint=3D84069 =
bdi_dirty=3D85344 dirty_ratelimit=3D63072 task_ratelimit=3D61776 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5677  [057] ....   212.244824: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D941840 bdi_setpoint=3D84069 =
bdi_dirty=3D85400 dirty_ratelimit=3D63072 task_ratelimit=3D61776 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5686  [058] ....   218.734557: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952833 bdi_setpoint=3D83354 =
bdi_dirty=3D85792 dirty_ratelimit=3D63072 task_ratelimit=3D60236 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5686  [058] ....   218.734893: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952973 bdi_setpoint=3D83354 =
bdi_dirty=3D85792 dirty_ratelimit=3D63072 task_ratelimit=3D60176 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294878250 period=3D2 think=3D429=
4878252=0A=
              dd-5686  [058] ....   218.735281: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953120 bdi_setpoint=3D83354 =
bdi_dirty=3D85848 dirty_ratelimit=3D63072 task_ratelimit=3D60176 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5686  [058] ....   218.735630: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953293 bdi_setpoint=3D83354 =
bdi_dirty=3D85848 dirty_ratelimit=3D63072 task_ratelimit=3D60176 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5686  [058] ....   218.735978: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953455 bdi_setpoint=3D83354 =
bdi_dirty=3D85904 dirty_ratelimit=3D63072 task_ratelimit=3D60112 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5686  [058] ....   218.736332: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953595 bdi_setpoint=3D83354 =
bdi_dirty=3D85904 dirty_ratelimit=3D63072 task_ratelimit=3D60052 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5695  [041] ....   227.307415: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955590 bdi_setpoint=3D83450 =
bdi_dirty=3D84336 dirty_ratelimit=3D62952 task_ratelimit=3D60800 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5695  [041] ....   227.307810: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955642 bdi_setpoint=3D83443 =
bdi_dirty=3D84336 dirty_ratelimit=3D62952 task_ratelimit=3D60800 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294886840 period=3D2 think=3D429=
4886842=0A=
              dd-5695  [041] ....   227.308235: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955772 bdi_setpoint=3D83443 =
bdi_dirty=3D84448 dirty_ratelimit=3D62952 task_ratelimit=3D60676 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5695  [041] ....   227.308845: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955756 bdi_setpoint=3D83437 =
bdi_dirty=3D84504 dirty_ratelimit=3D62952 task_ratelimit=3D60676 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5695  [041] ....   227.309538: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955708 bdi_setpoint=3D83430 =
bdi_dirty=3D84560 dirty_ratelimit=3D62952 task_ratelimit=3D60612 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5695  [041] ....   227.310120: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955741 bdi_setpoint=3D83430 =
bdi_dirty=3D84616 dirty_ratelimit=3D62952 task_ratelimit=3D60552 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5695  [041] ....   227.310631: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955622 bdi_setpoint=3D83417 =
bdi_dirty=3D84616 dirty_ratelimit=3D62952 task_ratelimit=3D60612 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5717  [057] ....   277.024811: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956666 bdi_setpoint=3D83572 =
bdi_dirty=3D83496 dirty_ratelimit=3D62744 task_ratelimit=3D61088 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5717  [057] ....   277.025137: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956776 bdi_setpoint=3D83572 =
bdi_dirty=3D83496 dirty_ratelimit=3D62744 task_ratelimit=3D61028 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294936656 period=3D2 think=3D429=
4936658=0A=
              dd-5717  [057] ....   277.025605: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956609 bdi_setpoint=3D83622 =
bdi_dirty=3D83440 dirty_ratelimit=3D62744 task_ratelimit=3D61148 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5717  [057] ....   277.026232: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956541 bdi_setpoint=3D83616 =
bdi_dirty=3D83440 dirty_ratelimit=3D62744 task_ratelimit=3D61148 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5717  [057] ....   277.026938: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956522 bdi_setpoint=3D83611 =
bdi_dirty=3D83496 dirty_ratelimit=3D62744 task_ratelimit=3D61148 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-2=0A=
              dd-5717  [057] ....   277.027526: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956653 bdi_setpoint=3D83611 =
bdi_dirty=3D83496 dirty_ratelimit=3D62744 task_ratelimit=3D61148 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5717  [057] ....   277.028148: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D956770 bdi_setpoint=3D83605 =
bdi_dirty=3D83552 dirty_ratelimit=3D62744 task_ratelimit=3D61028 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D7 period=3D2 think=3D-5=0A=
              dd-5726  [041] ....   285.898859: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954043 bdi_setpoint=3D81632 =
bdi_dirty=3D86856 dirty_ratelimit=3D62704 task_ratelimit=3D57988 dirtied=3D=
1 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D0 think=3D0=0A=
              dd-5726  [041] ....   285.899181: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954098 bdi_setpoint=3D81632 =
bdi_dirty=3D86856 dirty_ratelimit=3D62704 task_ratelimit=3D57988 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5726  [041] ....   285.899502: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954153 bdi_setpoint=3D81632 =
bdi_dirty=3D86856 dirty_ratelimit=3D62704 task_ratelimit=3D57924 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294945548 period=3D2 think=3D429=
4945550=0A=
              dd-5726  [009] ....   285.899890: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954072 bdi_setpoint=3D81624 =
bdi_dirty=3D86912 dirty_ratelimit=3D62704 task_ratelimit=3D57924 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5726  [009] ....   285.900243: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954066 bdi_setpoint=3D81617 =
bdi_dirty=3D87024 dirty_ratelimit=3D62704 task_ratelimit=3D57864 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5726  [009] ....   285.900599: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953930 bdi_setpoint=3D81601 =
bdi_dirty=3D87024 dirty_ratelimit=3D62704 task_ratelimit=3D57864 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5726  [009] ....   285.901007: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D953867 bdi_setpoint=3D81593 =
bdi_dirty=3D87136 dirty_ratelimit=3D62704 task_ratelimit=3D57804 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D6 period=3D2 think=3D-4=0A=
              dd-5726  [018] ....   285.908755: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954143 bdi_setpoint=3D81603 =
bdi_dirty=3D87192 dirty_ratelimit=3D62704 task_ratelimit=3D57680 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5726  [019] ....   285.918580: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954457 bdi_setpoint=3D81692 =
bdi_dirty=3D87192 dirty_ratelimit=3D62704 task_ratelimit=3D57744 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [019] ....   285.928517: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954717 bdi_setpoint=3D81678 =
bdi_dirty=3D87416 dirty_ratelimit=3D62704 task_ratelimit=3D57560 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [020] ....   285.939941: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D954777 bdi_setpoint=3D81641 =
bdi_dirty=3D87584 dirty_ratelimit=3D62704 task_ratelimit=3D57436 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D7 period=3D10 think=3D3=0A=
              dd-5726  [021] ....   285.948496: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955090 bdi_setpoint=3D81643 =
bdi_dirty=3D87808 dirty_ratelimit=3D62704 task_ratelimit=3D57252 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [021] ....   285.958924: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955120 bdi_setpoint=3D81614 =
bdi_dirty=3D87976 dirty_ratelimit=3D62704 task_ratelimit=3D57128 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5726  [022] ....   285.968287: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955009 bdi_setpoint=3D81672 =
bdi_dirty=3D88088 dirty_ratelimit=3D62704 task_ratelimit=3D57128 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [022] ....   285.978468: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955194 bdi_setpoint=3D81658 =
bdi_dirty=3D88200 dirty_ratelimit=3D62704 task_ratelimit=3D56944 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [023] ....   285.988475: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955302 bdi_setpoint=3D81629 =
bdi_dirty=3D88424 dirty_ratelimit=3D62704 task_ratelimit=3D56824 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [023] ....   285.998281: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955190 bdi_setpoint=3D81608 =
bdi_dirty=3D88648 dirty_ratelimit=3D62704 task_ratelimit=3D56640 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [016] ....   286.008352: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955498 bdi_setpoint=3D81602 =
bdi_dirty=3D88760 dirty_ratelimit=3D62704 task_ratelimit=3D56580 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [016] ....   286.018027: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955419 bdi_setpoint=3D81660 =
bdi_dirty=3D88816 dirty_ratelimit=3D62704 task_ratelimit=3D56580 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [017] ....   286.028230: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955365 bdi_setpoint=3D81631 =
bdi_dirty=3D89040 dirty_ratelimit=3D62704 task_ratelimit=3D56396 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5726  [049] ....   286.038490: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955468 bdi_setpoint=3D81610 =
bdi_dirty=3D89096 dirty_ratelimit=3D62704 task_ratelimit=3D56396 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5726  [049] ....   286.048435: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D955739 bdi_setpoint=3D81682 =
bdi_dirty=3D89208 dirty_ratelimit=3D62704 task_ratelimit=3D56272 dirtied=3D=
153 dirtied_pause=3D153 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [041] ....   294.267435: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950852 bdi_setpoint=3D82067 =
bdi_dirty=3D84616 dirty_ratelimit=3D62664 task_ratelimit=3D59968 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D0=0A=
              dd-5735  [041] ....   294.267765: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950970 bdi_setpoint=3D82067 =
bdi_dirty=3D84616 dirty_ratelimit=3D62664 task_ratelimit=3D59968 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D-4294953933 period=3D2 think=3D429=
4953935=0A=
              dd-5735  [041] ....   294.268098: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951017 bdi_setpoint=3D82060 =
bdi_dirty=3D84672 dirty_ratelimit=3D62664 task_ratelimit=3D59908 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D1=0A=
              dd-5735  [041] ....   294.268424: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951029 bdi_setpoint=3D82060 =
bdi_dirty=3D84672 dirty_ratelimit=3D62664 task_ratelimit=3D59908 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-1=0A=
              dd-5735  [041] ....   294.268742: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951095 bdi_setpoint=3D82060 =
bdi_dirty=3D84728 dirty_ratelimit=3D62664 task_ratelimit=3D59848 dirtied=3D=
32 dirtied_pause=3D32 paused=3D0 pause=3D0 period=3D2 think=3D-3=0A=
              dd-5735  [041] ....   294.269061: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950833 bdi_setpoint=3D82042 =
bdi_dirty=3D84728 dirty_ratelimit=3D62664 task_ratelimit=3D59848 dirtied=3D=
32 dirtied_pause=3D32 paused=3D1 pause=3D7 period=3D2 think=3D-4=0A=
              dd-5735  [041] ....   294.277895: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951014 bdi_setpoint=3D82044 =
bdi_dirty=3D84896 dirty_ratelimit=3D62664 task_ratelimit=3D59784 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [010] ....   294.287018: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D950953 bdi_setpoint=3D82027 =
bdi_dirty=3D85120 dirty_ratelimit=3D62664 task_ratelimit=3D59604 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5735  [010] ....   294.297275: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951081 bdi_setpoint=3D82070 =
bdi_dirty=3D85120 dirty_ratelimit=3D62664 task_ratelimit=3D59604 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [011] ....   294.307161: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951125 bdi_setpoint=3D81988 =
bdi_dirty=3D85456 dirty_ratelimit=3D62664 task_ratelimit=3D59296 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [012] ....   294.316854: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951369 bdi_setpoint=3D82043 =
bdi_dirty=3D85568 dirty_ratelimit=3D62664 task_ratelimit=3D59296 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5735  [013] ....   294.327260: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951431 bdi_setpoint=3D82026 =
bdi_dirty=3D85736 dirty_ratelimit=3D62664 task_ratelimit=3D59172 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [014] ....   294.337097: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D951718 bdi_setpoint=3D82022 =
bdi_dirty=3D85904 dirty_ratelimit=3D62664 task_ratelimit=3D59052 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [015] ....   294.346927: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952048 bdi_setpoint=3D82017 =
bdi_dirty=3D86128 dirty_ratelimit=3D62664 task_ratelimit=3D58868 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5735  [008] ....   294.357367: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952092 bdi_setpoint=3D82060 =
bdi_dirty=3D86184 dirty_ratelimit=3D62664 task_ratelimit=3D58868 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [009] ....   294.366817: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952000 bdi_setpoint=3D82044 =
bdi_dirty=3D86408 dirty_ratelimit=3D62664 task_ratelimit=3D58684 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5735  [010] ....   294.376936: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952338 bdi_setpoint=3D82098 =
bdi_dirty=3D86464 dirty_ratelimit=3D62664 task_ratelimit=3D58624 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [011] ....   294.386956: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952088 bdi_setpoint=3D82070 =
bdi_dirty=3D86632 dirty_ratelimit=3D62664 task_ratelimit=3D58560 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [012] ....   294.396998: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952441 bdi_setpoint=3D82066 =
bdi_dirty=3D86744 dirty_ratelimit=3D62664 task_ratelimit=3D58440 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D8 period=3D10 think=3D2=0A=
              dd-5735  [013] ....   294.406820: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952484 bdi_setpoint=3D82115 =
bdi_dirty=3D86800 dirty_ratelimit=3D62664 task_ratelimit=3D58440 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=
              dd-5735  [014] ....   294.416669: balance_dirty_pages: bdi 8:=
144: limit=3D1048576 setpoint=3D917504 dirty=3D952273 bdi_setpoint=3D82092 =
bdi_dirty=3D86912 dirty_ratelimit=3D62664 task_ratelimit=3D58380 dirtied=3D=
152 dirtied_pause=3D152 paused=3D0 pause=3D9 period=3D10 think=3D1=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
