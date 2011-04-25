Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2448D8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:25:14 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so774233gwa.14
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 02:25:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110425111705.786ef0c5@neptune.home>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
Date: Mon, 25 Apr 2011 12:25:12 +0300
Message-ID: <BANLkTi=2DK+iq-5NEFKexe0QhpW8G0RL8Q@mail.gmail.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>

On Mon, Apr 25, 2011 at 12:17 PM, Bruno Pr=E9mont
<bonbons@linux-vserver.org> wrote:
> On Mon, 25 April 2011 Mike Frysinger wrote:
>> On Sun, Apr 24, 2011 at 22:42, KOSAKI Motohiro wrote:
>> >> On Sun, 24 April 2011 Bruno Pr=E9mont wrote:
>> >> > On an older system I've been running Gentoo's revdep-rebuild to che=
ck
>> >> > for system linking/*.la consistency and after doing most of the wor=
k the
>> >> > system starved more or less, just complaining about stuck tasks now=
 and
>> >> > then.
>> >> > Memory usage graph as seen from userspace showed sudden quick incre=
ase of
>> >> > memory usage though only a very few MB were swapped out (c.f. attac=
hed RRD
>> >> > graph).
>> >>
>> >> Seems I've hit it once again (though detected before system was fully
>> >> stalled by trying to reclaim memory without success).
>> >>
>> >> This time it was during simple compiling...
>> >> Gathered info below:
>> >>
>> >> /proc/meminfo:
>> >> MemTotal: =A0 =A0 =A0 =A0 480660 kB
>> >> MemFree: =A0 =A0 =A0 =A0 =A0 64948 kB
>> >> Buffers: =A0 =A0 =A0 =A0 =A0 10304 kB
>> >> Cached: =A0 =A0 =A0 =A0 =A0 =A0 6924 kB
>> >> SwapCached: =A0 =A0 =A0 =A0 4220 kB
>> >> Active: =A0 =A0 =A0 =A0 =A0 =A011100 kB
>> >> Inactive: =A0 =A0 =A0 =A0 =A015732 kB
>> >> Active(anon): =A0 =A0 =A0 4732 kB
>> >> Inactive(anon): =A0 =A0 4876 kB
>> >> Active(file): =A0 =A0 =A0 6368 kB
>> >> Inactive(file): =A0 =A010856 kB
>> >> Unevictable: =A0 =A0 =A0 =A0 =A032 kB
>> >> Mlocked: =A0 =A0 =A0 =A0 =A0 =A0 =A032 kB
>> >> SwapTotal: =A0 =A0 =A0 =A0524284 kB
>> >> SwapFree: =A0 =A0 =A0 =A0 456432 kB
>> >> Dirty: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A080 kB
>> >> Writeback: =A0 =A0 =A0 =A0 =A0 =A0 0 kB
>> >> AnonPages: =A0 =A0 =A0 =A0 =A06268 kB
>> >> Mapped: =A0 =A0 =A0 =A0 =A0 =A0 2604 kB
>> >> Shmem: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 4 kB
>> >> Slab: =A0 =A0 =A0 =A0 =A0 =A0 250632 kB
>> >> SReclaimable: =A0 =A0 =A051144 kB
>> >> SUnreclaim: =A0 =A0 =A0 199488 kB =A0 <--- look big as well...
>> >> KernelStack: =A0 =A0 =A0131032 kB =A0 <--- what???
>> >
>> > KernelStack is used 8K bytes per thread. then, your system should have
>> > 16000 threads. but your ps only showed about 80 processes.
>> > Hmm... stack leak?
>>
>> i might have a similar report for 2.6.39-rc4 (seems to be working fine
>> in 2.6.38.4), but for embedded Blackfin systems running gdbserver
>> processes over and over (so lots of short lived forks)
>>
>> i wonder if you have a lot of zombies or otherwise unclaimed resources
>> ? =A0does `ps aux` show anything unusual ?
>
> I've not seen anything special (no big amount of threads behind my about =
80
> processes, even after kernel oom-killed nearly all processes the hogged
> memory has not been freed. And no, there are no zombies around).
>
> Here it seems to happened when I run 2 intensive tasks in parallel, e.g.
> (re)emerging gimp and running revdep-rebuild -pi in another terminal.
> This produces a fork rate of about 100-300 per second.
>
> Suddenly kmalloc-128 slabs stop being freed and things degrade.
>
> Trying to trace some of the kmalloc-128 slab allocations I end up seeing
> lots of allocations like this:
>
> [ 1338.554429] TRACE kmalloc-128 alloc 0xc294ff00 inuse=3D30 fp=3D0xc294f=
f00
> [ 1338.554434] Pid: 1573, comm: collectd Tainted: G =A0 =A0 =A0 =A0W =A0 =
2.6.39-rc4-jupiter-00187-g686c4cb #1
> [ 1338.554437] Call Trace:
> [ 1338.554442] =A0[<c10aef47>] trace+0x57/0xa0
> [ 1338.554447] =A0[<c10b07b3>] alloc_debug_processing+0xf3/0x140
> [ 1338.554452] =A0[<c10b0972>] T.999+0x172/0x1a0
> [ 1338.554455] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.554459] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.554464] =A0[<c10b0a52>] kmem_cache_alloc+0xb2/0x100
> [ 1338.554468] =A0[<c10c08b5>] ? path_put+0x15/0x20
> [ 1338.554472] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.554476] =A0[<c10b95d8>] get_empty_filp+0x58/0xc0
> [ 1338.554481] =A0[<c10c323f>] path_openat+0x1f/0x320
> [ 1338.554485] =A0[<c10a0a4e>] ? __access_remote_vm+0x19e/0x1d0
> [ 1338.554490] =A0[<c10c3620>] do_filp_open+0x30/0x80
> [ 1338.554495] =A0[<c10b0a30>] ? kmem_cache_alloc+0x90/0x100
> [ 1338.554500] =A0[<c10c16f8>] ? getname_flags+0x28/0xe0
> [ 1338.554505] =A0[<c10cd522>] ? alloc_fd+0x62/0xe0
> [ 1338.554509] =A0[<c10c1731>] ? getname_flags+0x61/0xe0
> [ 1338.554514] =A0[<c10b781d>] do_sys_open+0xed/0x1e0
> [ 1338.554519] =A0[<c10b7979>] sys_open+0x29/0x40
> [ 1338.554524] =A0[<c1391390>] sysenter_do_call+0x12/0x26
> [ 1338.556764] TRACE kmalloc-128 alloc 0xc294ff80 inuse=3D31 fp=3D0xc294f=
f80
> [ 1338.556774] Pid: 1332, comm: bash Tainted: G =A0 =A0 =A0 =A0W =A0 2.6.=
39-rc4-jupiter-00187-g686c4cb #1
> [ 1338.556779] Call Trace:
> [ 1338.556794] =A0[<c10aef47>] trace+0x57/0xa0
> [ 1338.556802] =A0[<c10b07b3>] alloc_debug_processing+0xf3/0x140
> [ 1338.556807] =A0[<c10b0972>] T.999+0x172/0x1a0
> [ 1338.556812] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.556817] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.556821] =A0[<c10b0a52>] kmem_cache_alloc+0xb2/0x100
> [ 1338.556826] =A0[<c10b95d8>] ? get_empty_filp+0x58/0xc0
> [ 1338.556830] =A0[<c10b95d8>] get_empty_filp+0x58/0xc0
> [ 1338.556841] =A0[<c121fca8>] ? tty_ldisc_deref+0x8/0x10
> [ 1338.556849] =A0[<c10c323f>] path_openat+0x1f/0x320
> [ 1338.556857] =A0[<c11e2b3e>] ? fbcon_cursor+0xfe/0x180
> [ 1338.556863] =A0[<c10c3620>] do_filp_open+0x30/0x80
> [ 1338.556868] =A0[<c10b0a30>] ? kmem_cache_alloc+0x90/0x100
> [ 1338.556873] =A0[<c10c5e8e>] ? do_vfs_ioctl+0x7e/0x580
> [ 1338.556878] =A0[<c10c16f8>] ? getname_flags+0x28/0xe0
> [ 1338.556886] =A0[<c10cd522>] ? alloc_fd+0x62/0xe0
> [ 1338.556891] =A0[<c10c1731>] ? getname_flags+0x61/0xe0
> [ 1338.556898] =A0[<c10b781d>] do_sys_open+0xed/0x1e0
> [ 1338.556903] =A0[<c10b7979>] sys_open+0x29/0x40
> [ 1338.556913] =A0[<c1391390>] sysenter_do_call+0x12/0x26
>
> Collectd is system monitoring daemon that counts processes, memory
> usage an much more, reading lots of files under /proc every 10
> seconds.
> Maybe it opens a process related file at a racy moment and thus
> prevents the 128 slabs and kernel stacks from being released?
>
> Replaying the scenario I'm at:
> Slab: =A0 =A0 =A0 =A0 =A0 =A0 =A043112 kB
> SReclaimable: =A0 =A0 =A025396 kB
> SUnreclaim: =A0 =A0 =A0 =A017716 kB
> KernelStack: =A0 =A0 =A0 16432 kB
> PageTables: =A0 =A0 =A0 =A0 1320 kB
>
> with
> kmalloc-256 =A0 =A0 =A0 =A0 =A0 55 =A0 =A0 64 =A0 =A0256 =A0 16 =A0 =A01 =
: tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 =A04 =A0 =A0 =A04 =
=A0 =A0 =A00
> kmalloc-128 =A0 =A0 =A0 =A066656 =A066656 =A0 =A0128 =A0 32 =A0 =A01 : tu=
nables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 2083 =A0 2083 =A0 =A0 =A00
> kmalloc-64 =A0 =A0 =A0 =A0 =A03902 =A0 3904 =A0 =A0 64 =A0 64 =A0 =A01 : =
tunables =A0 =A00 =A0 =A00 =A0 =A00 : slabdata =A0 =A0 61 =A0 =A0 61 =A0 =
=A0 =A00
>
> (and compiling process tree now SIGSTOPped in order to have system
> not starve immediately so I can look around for information)
>
> If I resume one of the compiling process trees both KernelStack and
> slab (kmalloc-128) usage increase quite quickly (and seems to never
> get down anymore) - probably at same rate as processes get born (no
> matter when they end).

Looks like it might be a leak in VFS. You could try kmemleak to narrow
it down some more. See Documentation/kmemleak.txt for details.

                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
