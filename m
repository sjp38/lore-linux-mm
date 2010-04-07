Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B9BF56B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 04:39:56 -0400 (EDT)
Received: by pzk30 with SMTP id 30so736157pzk.12
        for <linux-mm@kvack.org>; Wed, 07 Apr 2010 01:39:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100407070050.GA10527@localhost>
References: <20100404221349.GA18036@rhlx01.hs-esslingen.de>
	 <20100405105319.GA16528@rhlx01.hs-esslingen.de>
	 <20100407070050.GA10527@localhost>
Date: Wed, 7 Apr 2010 17:39:53 +0900
Message-ID: <h2h28c262361004070139r7a729959od486bb2a022afd4b@mail.gmail.com>
Subject: Re: 32GB SSD on USB1.1 P3/700 == ___HELL___ (2.6.34-rc3)
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 7, 2010 at 4:00 PM, Wu Fengguang <fengguang.wu@intel.com> wrote=
:
> Andreas,
>
> On Mon, Apr 05, 2010 at 06:53:20PM +0800, Andreas Mohr wrote:
>> On Mon, Apr 05, 2010 at 12:13:49AM +0200, Andreas Mohr wrote:
>> > Having an attempt at writing a 300M /dev/zero file to the SSD's filesy=
stem
>> > was even worse (again tons of unresponsiveness), combined with multipl=
e
>> > OOM conditions flying by (I/O to the main HDD was minimal, its LED was
>> > almost always _off_, yet everything stuck to an absolute standstill).
>> >
>> > Clearly there's a very, very important limiter somewhere in bio layer
>> > missing or broken, a 300M dd /dev/zero should never manage to put
>> > such an onerous penalty on a system, IMHO.
>>
>> Seems this issue is a variation of the usual "ext3 sync" problem,
>> but in overly critical and unexpected ways (full lockup of almost everyt=
hing,
>> and multiple OOMs).
>>
>> I retried writing the 300M file with a freshly booted system, and there
>> were _no_ suspicious issues to be observed (free memory went all down to
>> 5M, not too problematic), well, that is, until I launched Firefox
>> (the famous sync-happy beast).
>> After Firefox startup, I had these long freezes again when trying to
>> do transfers with the _UNRELATED_ main HDD of the system
>> (plus some OOMs, again)
>>
>> Setup: USB SSD ext4 non-journal, system HDD ext3, SSD unused except for
>> this one ext4 partition (no swap partition activated there).
>>
>> Of course I can understand and tolerate the existing "ext3 sync" issue,
>> but what's special about this case is that large numbers of bio to
>> a _separate_ _non_-ext3 device seem to put so much memory and I/O pressu=
re
>> on a system that the existing _lightly_ loaded ext3 device gets complete=
ly
>> stuck for much longer than I'd usually naively expect an ext3 sync to an=
 isolated
>> device to take - not to mention the OOMs (which are probably causing
>> swap partition handling on the main HDD to contribute to the contention)=
.
>>
>> IOW, we seem to still have too much ugly lock contention interaction
>> between expectedly isolated parts of the system.
>>
>> OTOH the main problem likely still is overly large pressure induced by a
>> thoroughly unthrottled dd 300M, resulting in sync-challenged ext3 and sw=
ap
>> activity (this time on the same device!) to break completely, and also O=
OMs to occur.
>>
>> Probably overly global ext3 sync handling manages to grab a couple
>> more global system locks (bdi, swapping, page handling, ...)
>> before being contended, causing other, non-ext3-challenged
>> parts of the system (e.g. the swap partition on the _same_ device)
>> to not make any progress in the meantime.
>>
>> per-bdi writeback patches (see
>> http://www.serverphorums.com/read.php?12,32355,33238,page=3D2 ) might
>> have handled a related issue.
>>
>>
>> Following is a SysRq-W trace (plus OOM traces) at a problematic moment d=
uring 300M copy
>> after firefox - and thus sync invocation - launch (there's a backtrace o=
f an "ls" that
>> got stuck for perhaps half a minute on the main, _unaffected_, ext3
>> HDD - and almost all other traces here are ext3-bound as well).
>>
>>
>> SysRq : HELP : loglevel(0-9) reBoot Crash show-all-locks(D) terminate-al=
l-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) sa=
K show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show=
-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W)
>> ata1: clearing spurious IRQ
>> ata1: clearing spurious IRQ
>> Xorg invoked oom-killer: gfp_mask=3D0xd0, order=3D0, oom_adj=3D0
>
> This is GFP_KERNEL.
>
>> Pid: 2924, comm: Xorg Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A02.6.=
34-rc3 #8
>> Call Trace:
>> =C2=A0[<c105d881>] T.382+0x44/0x110
>> =C2=A0[<c105d978>] T.381+0x2b/0xe1
>> =C2=A0[<c105db2e>] __out_of_memory+0x100/0x112
>> =C2=A0[<c105dbb4>] out_of_memory+0x74/0x9c
>> =C2=A0[<c105fd41>] __alloc_pages_nodemask+0x3c5/0x493
>> =C2=A0[<c105fe1e>] __get_free_pages+0xf/0x2c
>> =C2=A0[<c1086400>] __pollwait+0x4c/0xa4
>> =C2=A0[<c120130e>] unix_poll+0x1a/0x93
>> =C2=A0[<c11a6a77>] sock_poll+0x12/0x15
>> =C2=A0[<c1085d21>] do_select+0x336/0x53a
>> =C2=A0[<c10ec5c4>] ? cfq_set_request+0x1d8/0x2ec
>> =C2=A0[<c10863b4>] ? __pollwait+0x0/0xa4
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c1086458>] ? pollwake+0x0/0x60
>> =C2=A0[<c10f46c9>] ? _copy_from_user+0x42/0x127
>> =C2=A0[<c10860cc>] core_sys_select+0x1a7/0x291
>> =C2=A0[<c1214063>] ? _raw_spin_unlock_irq+0x1d/0x21
>> =C2=A0[<c1026b7f>] ? do_setitimer+0x160/0x18c
>> =C2=A0[<c103b066>] ? ktime_get_ts+0xba/0xc4
>> =C2=A0[<c108635e>] sys_select+0x68/0x84
>> =C2=A0[<c1002690>] sysenter_do_call+0x12/0x31
>> Mem-Info:
>> DMA per-cpu:
>> CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0 0
>> Normal per-cpu:
>> CPU =C2=A0 =C2=A00: hi: =C2=A0186, btch: =C2=A031 usd: =C2=A046
>> active_anon:34886 inactive_anon:41460 isolated_anon:1
>> =C2=A0active_file:13576 inactive_file:27884 isolated_file:65
>> =C2=A0unevictable:0 dirty:4788 writeback:5675 unstable:0
>> =C2=A0free:1198 slab_reclaimable:1952 slab_unreclaimable:2594
>> =C2=A0mapped:10152 shmem:56 pagetables:742 bounce:0
>> DMA free:2052kB min:84kB low:104kB high:124kB active_anon:940kB inactive=
_anon:3876kB active_file:212kB inactive_file:8224kB unevictable:0kB isolate=
d(anon):0kB isolated(file):0kB present:15804kB mlocked:0kB dirty:3448kB wri=
teback:752kB mapped:80kB shmem:0kB slab_reclaimable:160kB slab_unreclaimabl=
e:124kB kernel_stack:40kB pagetables:48kB unstable:0kB bounce:0kB writeback=
_tmp:0kB pages_scanned:20096 all_unreclaimable? yes
>> lowmem_reserve[]: 0 492 492
>> Normal free:2740kB min:2792kB low:3488kB high:4188kB active_anon:138604k=
B inactive_anon:161964kB active_file:54092kB inactive_file:103312kB unevict=
able:0kB isolated(anon):4kB isolated(file):260kB present:503848kB mlocked:0=
kB dirty:15704kB writeback:21948kB mapped:40528kB shmem:224kB slab_reclaima=
ble:7648kB slab_unreclaimable:10252kB kernel_stack:1632kB pagetables:2920kB=
 unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:73056 all_unreclai=
mable? no
>> lowmem_reserve[]: 0 0 0
>> DMA: 513*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB=
 0*2048kB 0*4096kB =3D 2052kB
>> Normal: 685*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*102=
4kB 0*2048kB 0*4096kB =3D 2740kB
>> 56122 total pagecache pages
>> 14542 pages in swap cache
>> Swap cache stats: add 36404, delete 21862, find 8669/10118
>> Free swap =C2=A0=3D 671696kB
>> Total swap =3D 755048kB
>> 131034 pages RAM
>> 3214 pages reserved
>> 94233 pages shared
>> 80751 pages non-shared
>> Out of memory: kill process 3462 (kdeinit4) score 95144 or a child
>
> shmem=3D56 is ignorable, and
> active_file+inactive_file=3D13576+27884=3D41460 < 56122 total pagecache p=
ages.
>
> Where are the 14606 file pages gone?

swapcache?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
