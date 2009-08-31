Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id AC9316B005C
	for <linux-mm@kvack.org>; Mon, 31 Aug 2009 06:08:19 -0400 (EDT)
Received: by bwz24 with SMTP id 24so1866957bwz.38
        for <linux-mm@kvack.org>; Mon, 31 Aug 2009 03:08:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090831074842.GA28091@linux-sh.org>
References: <20090831074842.GA28091@linux-sh.org>
Date: Mon, 31 Aug 2009 13:08:19 +0300
Message-ID: <84144f020908310308i48790f78g5a7d73a60ea854f8@mail.gmail.com>
Subject: Re: page allocator regression on nommu
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Paul Mundt <lethal@linux-sh.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

On Mon, Aug 31, 2009 at 10:48 AM, Paul Mundt<lethal@linux-sh.org> wrote:
> It seems we've managed to trigger a fairly interesting conflict between
> the anti-fragmentation disabling code and the nommu region rbtree. I've
> bisected it down to:
>
> commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> Author: Mel Gorman <mel@csn.ul.ie>
> Date: =A0 Tue Jun 16 15:31:58 2009 -0700
>
> =A0 =A0page allocator: move check for disabled anti-fragmentation out of =
fastpath
>
> =A0 =A0On low-memory systems, anti-fragmentation gets disabled as there i=
s
> =A0 =A0nothing it can do and it would just incur overhead shuffling pages=
 between
> =A0 =A0lists constantly. =A0Currently the check is made in the free page =
fast path
> =A0 =A0for every page. =A0This patch moves it to a slow path. =A0On machi=
nes with low
> =A0 =A0memory, there will be small amount of additional overhead as pages=
 get
> =A0 =A0shuffled between lists but it should quickly settle.
>
> which causes death on unpacking initramfs on my nommu board. With this
> reverted, everything works as expected. Note that this blows up with all =
of
> SLOB/SLUB/SLAB.
>
> I'll continue debugging it, and can post my .config if it will be helpful=
, but
> hopefully you have some suggestions on what to try :-)
>
> ---
>
> modprobe: page allocation failure. order:7, mode:0xd0

OK, so we have order 7 page allocation here...

> Stack: (0x0c909d2c to 0x0c90a000)
> 9d20: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00c0387d2 000=
00000 00000000 0c107fcc 00000000
> 9d40: 00000000 0c107fcc 0c2f8960 00000000 00000010 00000000 00000000 0002=
00d0
> 9d60: 00000000 0c041614 0c9f8cf4 00000000 0c9f8d1c 00000000 00000004 0000=
0000
> 9d80: 00000007 0c01a582 0c2f8cd0 00000000 00000000 00049000 00000049 0004=
8fff
> 9da0: 00049fff 00049000 00000007 0c06633a 00000001 0c909f30 0003e950 0c0b=
ad00
> 9dc0: 0000984a 0c2f8ea0 ffffe000 00000002 00000000 0c065314 0c2f8ea0 0c07=
7f60
> 9de0: 00049000 0000673c 00000050 000369a0 000019cf 00000004 00004e20 0003=
e950
> 9e00: 000481aa 00000001 00004eaa 000049a0 00007fb0 000369a0 00000000 0000=
0000
> 9e20: 0c909e50 00000000 00000000 0c066790 00000000 0c909f30 00000000 0000=
0000
> 9e40: 0c2f8ea0 0c909f30 0c909e50 00004eaa 00000000 00000000 00000000 0000=
0000
> 9e60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9e80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9ec0: 0c0482ee 00000000 fffffff8 0c2f8ea0 0c104ff8 0c04884e 0c0feb64 0000=
0001
> 9ee0: 0c048570 ffffe000 0c2f8ea0 00000000 00000000 0c813eb8 0c909f30 0c00=
2e68
> 9f00: 00000000 00000000 00000000 0c0feb64 0c813eb8 0c909f30 0c960000 0c00=
7972
> 9f20: ffffff0f 00000071 00000100 0c002e38 0000000b ffffff0f 00000001 0000=
000b
> 9f40: 0c0fea64 0c813eb8 0c0feb64 0c2f898c 00000000 ffffe000 0c9f8990 0000=
0000
> 9f60: 00000000 00000000 00000000 0c909f8c 0c0050ca 0c01e874 40000001 0000=
0000
> 9f80: 00000000 4795ce40 0000004c 0c002cca 00000000 00000000 00000000 0000=
0000
> 9fa0: 00000000 00000000 00000000 00000000 00000000 0c9f8990 0c01e7a4 0000=
0000
> 9fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9fe0: 0c909f9c 0c002cc4 00000000 40000000 00000000 00000000 00000000 0000=
0000
>
> Call trace:
> =A0[<0c041614>] do_mmap_pgoff+0x638/0xa68
> =A0[<0c01a582>] flush_itimer_signals+0x36/0x60
> =A0[<0c06633a>] load_flat_file+0x32a/0x738
> =A0[<0c0bad00>] down_write+0x0/0xc
> =A0[<0c065314>] load_elf_fdpic_binary+0x44/0xa8c
> =A0[<0c077f60>] memset+0x0/0x60
> =A0[<0c066790>] load_flat_binary+0x48/0x2fc
> =A0[<0c0482ee>] search_binary_handler+0x4a/0x1fc
> =A0[<0c04884e>] do_execve+0x156/0x2bc
> =A0[<0c048570>] copy_strings+0x0/0x150
> =A0[<0c002e68>] sys_execve+0x30/0x5c
> =A0[<0c007972>] syscall_call+0xc/0x10
> =A0[<0c002e38>] sys_execve+0x0/0x5c
> =A0[<0c0050ca>] kernel_execve+0x6/0xc
> =A0[<0c01e874>] ____call_usermodehelper+0xd0/0xfc
> =A0[<0c002cca>] kernel_thread_helper+0x6/0x10
> =A0[<0c01e7a4>] ____call_usermodehelper+0x0/0xfc
> =A0[<0c002cc4>] kernel_thread_helper+0x0/0x10
>
> Mem-Info:
> Normal per-cpu:
> CPU =A0 =A00: hi: =A0 =A00, btch: =A0 1 usd: =A0 0
> Active_anon:0 active_file:0 inactive_anon:0
> =A0inactive_file:0 unevictable:323 dirty:0 writeback:0 unstable:0
> =A0free:2967 slab:0 mapped:0 pagetables:0 bounce:0
> Normal free:11868kB min:0kB low:0kB high:0kB active_anon:0kB inactive_ano=
n:0kB active_file:0kB inactive_file:0kB unevictable:1292kB present:16256kB =
pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0
> Normal: 267*4kB 268*8kB 251*16kB 145*32kB 0*64kB 0*128kB 0*256kB 0*512kB =
0*1024kB 0*2048kB 0*4096kB 0*8192kB 0*16384kB 0*32768kB =3D 11868kB

...but we seem to be all out of order > 3 pages. I'm not sure why
commit 49255c619fbd482d704289b5eb2795f8e3b7ff2e changes any of this,
though.

> 323 total pagecache pages
> ------------[ cut here ]------------
> kernel BUG at mm/nommu.c:598!
> Kernel BUG: 003e [#1]
> Modules linked in:
>
> Pid : 51, Comm: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 modprobe
> CPU : 0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Not tainted =A0(2.6.31-rc7 #2835)
>
> PC is at __put_nommu_region+0xe/0xb0
> PR is at do_mmap_pgoff+0x8dc/0xa68

This looks to be a bug in nommu do_mmap_pgoff() error handling. I
guess we shouldn't call __put_nommu_region() if add_nommu_region()
hasn't been called?

> PC =A0: 0c040e7a SP =A0: 0c909d7c SR =A0: 40000001
> R0 =A0: 0000001d R1 =A0: 00000000 R2 =A0: 00000000 R3 =A0: 0000000d
> R4 =A0: 0c9f8cf4 R5 =A0: 000017de R6 =A0: ffffffff R7 =A0: 00000035
> R8 =A0: 0c9f8cf4 R9 =A0: 00000000 R10 : 00000000 R11 : fffffff4
> R12 : 0c9f8d1c R13 : 00000000 R14 : 0c9f8cf4
> MACH: 0000017e MACL: baf11680 GBR : 00000000 PR =A0: 0c0418b8
>
> Call trace:
> =A0[<0c0418b8>] do_mmap_pgoff+0x8dc/0xa68
> =A0[<0c01a582>] flush_itimer_signals+0x36/0x60
> =A0[<0c06633a>] load_flat_file+0x32a/0x738
> =A0[<0c0bad00>] down_write+0x0/0xc
> =A0[<0c065314>] load_elf_fdpic_binary+0x44/0xa8c
> =A0[<0c077f60>] memset+0x0/0x60
> =A0[<0c066790>] load_flat_binary+0x48/0x2fc
> =A0[<0c0482ee>] search_binary_handler+0x4a/0x1fc
> =A0[<0c04884e>] do_execve+0x156/0x2bc
> =A0[<0c048570>] copy_strings+0x0/0x150
> =A0[<0c002e68>] sys_execve+0x30/0x5c
> =A0[<0c007972>] syscall_call+0xc/0x10
> =A0[<0c002e38>] sys_execve+0x0/0x5c
> =A0[<0c0050ca>] kernel_execve+0x6/0xc
> =A0[<0c01e874>] ____call_usermodehelper+0xd0/0xfc
> =A0[<0c002cca>] kernel_thread_helper+0x6/0x10
> =A0[<0c01e7a4>] ____call_usermodehelper+0x0/0xfc
> =A0[<0c002cc4>] kernel_thread_helper+0x0/0x10
>
> Code:
> =A00c040e74: =A0tst =A0 =A0 =A0 r1, r1
> =A00c040e76: =A0bf.s =A0 =A0 =A00c040e7c
> =A00c040e78: =A0mov =A0 =A0 =A0 r4, r8
> ->0c040e7a: =A0trapa =A0 =A0 #62
> =A00c040e7c: =A0stc =A0 =A0 =A0 sr, r1
> =A00c040e7e: =A0mov =A0 =A0 =A0 r1, r0
> =A00c040e80: =A0or =A0 =A0 =A0 =A0#-16, r0
> =A00c040e82: =A0ldc =A0 =A0 =A0 r0, sr
> =A00c040e84: =A0mov =A0 =A0 =A0 r1, r0
>
> Process: modprobe (pid: 51, stack limit =3D 0c908001)
> Stack: (0x0c909d7c to 0x0c90a000)
> 9d60: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A00c0418b8
> 9d80: 00000007 0c01a582 0c2f8cd0 00000000 00000000 00049000 00000049 0004=
8fff
> 9da0: 00049fff 00049000 00000007 0c06633a 00000001 0c909f30 0003e950 0c0b=
ad00
> 9dc0: 0000984a 0c2f8ea0 ffffe000 00000002 00000000 0c065314 0c2f8ea0 0c07=
7f60
> 9de0: 00049000 0000673c 00000050 000369a0 000019cf 00000004 00004e20 0003=
e950
> 9e00: 000481aa 00000001 00004eaa 000049a0 00007fb0 000369a0 00000000 0000=
0000
> 9e20: 0c909e50 00000000 00000000 0c066790 00000000 0c909f30 00000000 0000=
0000
> 9e40: 0c2f8ea0 0c909f30 0c909e50 00004eaa 00000000 00000000 00000000 0000=
0000
> 9e60: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9e80: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9ea0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9ec0: 0c0482ee 00000000 fffffff8 0c2f8ea0 0c104ff8 0c04884e 0c0feb64 0000=
0001
> 9ee0: 0c048570 ffffe000 0c2f8ea0 00000000 00000000 0c813eb8 0c909f30 0c00=
2e68
> 9f00: 00000000 00000000 00000000 0c0feb64 0c813eb8 0c909f30 0c960000 0c00=
7972
> 9f20: ffffff0f 00000071 00000100 0c002e38 0000000b ffffff0f 00000001 0000=
000b
> 9f40: 0c0fea64 0c813eb8 0c0feb64 0c2f898c 00000000 ffffe000 0c9f8990 0000=
0000
> 9f60: 00000000 00000000 00000000 0c909f8c 0c0050ca 0c01e874 40000001 0000=
0000
> 9f80: 00000000 4795ce40 0000004c 0c002cca 00000000 00000000 00000000 0000=
0000
> 9fa0: 00000000 00000000 00000000 00000000 00000000 0c9f8990 0c01e7a4 0000=
0000
> 9fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 0000=
0000
> 9fe0: 0c909f9c 0c002cc4 00000000 40000000 00000000 00000000 00000000 0000=
0000
> ---[ end trace 139ce121c98e96c9 ]---
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
