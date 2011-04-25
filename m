Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E5ADA8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:17:18 -0400 (EDT)
Date: Mon, 25 Apr 2011 11:17:05 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425111705.786ef0c5@neptune.home>
In-Reply-To: <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 25 April 2011 Mike Frysinger wrote:
> On Sun, Apr 24, 2011 at 22:42, KOSAKI Motohiro wrote:
> >> On Sun, 24 April 2011 Bruno Pr=C3=A9mont wrote:
> >> > On an older system I've been running Gentoo's revdep-rebuild to check
> >> > for system linking/*.la consistency and after doing most of the work=
 the
> >> > system starved more or less, just complaining about stuck tasks now =
and
> >> > then.
> >> > Memory usage graph as seen from userspace showed sudden quick increa=
se of
> >> > memory usage though only a very few MB were swapped out (c.f. attach=
ed RRD
> >> > graph).
> >>
> >> Seems I've hit it once again (though detected before system was fully
> >> stalled by trying to reclaim memory without success).
> >>
> >> This time it was during simple compiling...
> >> Gathered info below:
> >>
> >> /proc/meminfo:
> >> MemTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A0 480660 kB
> >> MemFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 64948 kB
> >> Buffers: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 10304 kB
> >> Cached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 6924 kB
> >> SwapCached: =C2=A0 =C2=A0 =C2=A0 =C2=A0 4220 kB
> >> Active: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A011100 kB
> >> Inactive: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A015732 kB
> >> Active(anon): =C2=A0 =C2=A0 =C2=A0 4732 kB
> >> Inactive(anon): =C2=A0 =C2=A0 4876 kB
> >> Active(file): =C2=A0 =C2=A0 =C2=A0 6368 kB
> >> Inactive(file): =C2=A0 =C2=A010856 kB
> >> Unevictable: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A032 kB
> >> Mlocked: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A032 kB
> >> SwapTotal: =C2=A0 =C2=A0 =C2=A0 =C2=A0524284 kB
> >> SwapFree: =C2=A0 =C2=A0 =C2=A0 =C2=A0 456432 kB
> >> Dirty: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A080 kB
> >> Writeback: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 kB
> >> AnonPages: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A06268 kB
> >> Mapped: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2604 kB
> >> Shmem: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 4 kB
> >> Slab: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 250632 kB
> >> SReclaimable: =C2=A0 =C2=A0 =C2=A051144 kB
> >> SUnreclaim: =C2=A0 =C2=A0 =C2=A0 199488 kB =C2=A0 <--- look big as wel=
l...
> >> KernelStack: =C2=A0 =C2=A0 =C2=A0131032 kB =C2=A0 <--- what???
> >
> > KernelStack is used 8K bytes per thread. then, your system should have
> > 16000 threads. but your ps only showed about 80 processes.
> > Hmm... stack leak?
>=20
> i might have a similar report for 2.6.39-rc4 (seems to be working fine
> in 2.6.38.4), but for embedded Blackfin systems running gdbserver
> processes over and over (so lots of short lived forks)
>=20
> i wonder if you have a lot of zombies or otherwise unclaimed resources
> ?  does `ps aux` show anything unusual ?

I've not seen anything special (no big amount of threads behind my about 80
processes, even after kernel oom-killed nearly all processes the hogged
memory has not been freed. And no, there are no zombies around).

Here it seems to happened when I run 2 intensive tasks in parallel, e.g.
(re)emerging gimp and running revdep-rebuild -pi in another terminal.
This produces a fork rate of about 100-300 per second.

Suddenly kmalloc-128 slabs stop being freed and things degrade.

Trying to trace some of the kmalloc-128 slab allocations I end up seeing
lots of allocations like this:

[ 1338.554429] TRACE kmalloc-128 alloc 0xc294ff00 inuse=3D30 fp=3D0xc294ff00
[ 1338.554434] Pid: 1573, comm: collectd Tainted: G        W   2.6.39-rc4-j=
upiter-00187-g686c4cb #1
[ 1338.554437] Call Trace:
[ 1338.554442]  [<c10aef47>] trace+0x57/0xa0
[ 1338.554447]  [<c10b07b3>] alloc_debug_processing+0xf3/0x140
[ 1338.554452]  [<c10b0972>] T.999+0x172/0x1a0
[ 1338.554455]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.554459]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.554464]  [<c10b0a52>] kmem_cache_alloc+0xb2/0x100
[ 1338.554468]  [<c10c08b5>] ? path_put+0x15/0x20
[ 1338.554472]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.554476]  [<c10b95d8>] get_empty_filp+0x58/0xc0
[ 1338.554481]  [<c10c323f>] path_openat+0x1f/0x320
[ 1338.554485]  [<c10a0a4e>] ? __access_remote_vm+0x19e/0x1d0
[ 1338.554490]  [<c10c3620>] do_filp_open+0x30/0x80
[ 1338.554495]  [<c10b0a30>] ? kmem_cache_alloc+0x90/0x100
[ 1338.554500]  [<c10c16f8>] ? getname_flags+0x28/0xe0
[ 1338.554505]  [<c10cd522>] ? alloc_fd+0x62/0xe0
[ 1338.554509]  [<c10c1731>] ? getname_flags+0x61/0xe0
[ 1338.554514]  [<c10b781d>] do_sys_open+0xed/0x1e0
[ 1338.554519]  [<c10b7979>] sys_open+0x29/0x40
[ 1338.554524]  [<c1391390>] sysenter_do_call+0x12/0x26
[ 1338.556764] TRACE kmalloc-128 alloc 0xc294ff80 inuse=3D31 fp=3D0xc294ff80
[ 1338.556774] Pid: 1332, comm: bash Tainted: G        W   2.6.39-rc4-jupit=
er-00187-g686c4cb #1
[ 1338.556779] Call Trace:
[ 1338.556794]  [<c10aef47>] trace+0x57/0xa0
[ 1338.556802]  [<c10b07b3>] alloc_debug_processing+0xf3/0x140
[ 1338.556807]  [<c10b0972>] T.999+0x172/0x1a0
[ 1338.556812]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.556817]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.556821]  [<c10b0a52>] kmem_cache_alloc+0xb2/0x100
[ 1338.556826]  [<c10b95d8>] ? get_empty_filp+0x58/0xc0
[ 1338.556830]  [<c10b95d8>] get_empty_filp+0x58/0xc0
[ 1338.556841]  [<c121fca8>] ? tty_ldisc_deref+0x8/0x10
[ 1338.556849]  [<c10c323f>] path_openat+0x1f/0x320
[ 1338.556857]  [<c11e2b3e>] ? fbcon_cursor+0xfe/0x180
[ 1338.556863]  [<c10c3620>] do_filp_open+0x30/0x80
[ 1338.556868]  [<c10b0a30>] ? kmem_cache_alloc+0x90/0x100
[ 1338.556873]  [<c10c5e8e>] ? do_vfs_ioctl+0x7e/0x580
[ 1338.556878]  [<c10c16f8>] ? getname_flags+0x28/0xe0
[ 1338.556886]  [<c10cd522>] ? alloc_fd+0x62/0xe0
[ 1338.556891]  [<c10c1731>] ? getname_flags+0x61/0xe0
[ 1338.556898]  [<c10b781d>] do_sys_open+0xed/0x1e0
[ 1338.556903]  [<c10b7979>] sys_open+0x29/0x40
[ 1338.556913]  [<c1391390>] sysenter_do_call+0x12/0x26

Collectd is system monitoring daemon that counts processes, memory
usage an much more, reading lots of files under /proc every 10
seconds.
Maybe it opens a process related file at a racy moment and thus
prevents the 128 slabs and kernel stacks from being released?

Replaying the scenario I'm at:
Slab:              43112 kB
SReclaimable:      25396 kB
SUnreclaim:        17716 kB
KernelStack:       16432 kB
PageTables:         1320 kB

with=20
kmalloc-256           55     64    256   16    1 : tunables    0    0    0 =
: slabdata      4      4      0
kmalloc-128        66656  66656    128   32    1 : tunables    0    0    0 =
: slabdata   2083   2083      0
kmalloc-64          3902   3904     64   64    1 : tunables    0    0    0 =
: slabdata     61     61      0

(and compiling process tree now SIGSTOPped in order to have system
not starve immediately so I can look around for information)

If I resume one of the compiling process trees both KernelStack and
slab (kmalloc-128) usage increase quite quickly (and seems to never
get down anymore) - probably at same rate as processes get born (no
matter when they end).

Bruno

> -mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
