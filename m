Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0A36B0011
	for <linux-mm@kvack.org>; Thu, 26 May 2011 19:58:54 -0400 (EDT)
Received: by qwa26 with SMTP id 26so888326qwa.14
        for <linux-mm@kvack.org>; Thu, 26 May 2011 16:58:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
References: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
Date: Fri, 27 May 2011 08:58:51 +0900
Message-ID: <BANLkTimDtpVeLYisfon7g_=H80D0XXgkGQ@mail.gmail.com>
Subject: Re: Easy portable testcase! (Re: Kernel falls apart under light
 memory pressure (i.e. linking vmlinux))
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>, mgorman@suse.de, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@redhat.com

On Thu, May 26, 2011 at 5:17 AM, Andrew Lutomirski <luto@mit.edu> wrote:
> On Tue, May 24, 2011 at 8:43 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> Unfortnately, this log don't tell us why DM don't issue any swap io. ;-)
>> I doubt it's DM issue. Can you please try to make swap on out of DM?
>>
>>
>
> I can do one better: I can tell you how to reproduce the OOM in the
> comfort of your own VM without using dm_crypt or a Sandy Bridge
> laptop. =C2=A0This is on Fedora 15, but it really ought to work on any
> x86_64 distribution that has kvm. =C2=A0You'll probably want at least 6GB
> on your host machine because the VM wants 4GB ram.
>
> Here's how:
>
> Step 1: Clone git://gitorious.org/linux-test-utils/reproduce-annoying-mm-=
bug.git
>
> (You can browse here:)
> https://gitorious.org/linux-test-utils/reproduce-annoying-mm-bug
>
> Instructions to reproduce the mm bug:
>
> Step 2: Build Linux v2.6.38.6 with config-2.6.38.6 and the patch
> 0001-Minchan-patch-for-testing-23-05-2011.patch (both files are in the
> git repo)
>
> Step 3: cd back to reproduce-annoying-mm-bug
>
> Step 4: Type this.
>
> $ make
> $ qemu-kvm -m 4G -smp 2 -kernel <linux_dir>/arch/x86/boot/bzImage
> -initrd initramfs.gz
>
> Step 5: Wait for the VM to boot (it's really fast) and then run ./repro_b=
ug.sh.
>
> Step 6: Wait a bit and watch the fireworks. =C2=A0Note that it can take a
> couple minutes to reproduce the bug.
>
> Tested on my Sandy Bridge laptop and on a Xeon W3520.
>
> For whatever reason, on my laptop without the VM I can hit the bug
> almost instantaneously. =C2=A0Maybe it's because I'm using dm-crypt on my
> laptop.
>
> --Andy
>
> P.S. =C2=A0I think that the mk_trivial_initramfs.sh script is cute, and

That's cool. :)

> maybe I'll try to flesh it out and turn it into a real project some
> day.
>

Thanks for good test environment.
Yesterday, I tried to reproduce your problem in my system(4G DRAM) but
unfortunately got failed. I tried various setting but I can't reach.
Maybe I need 8G system or sandy-bridge.  :(

Hi mm folks, It's next round.
Andrew Lutomirski's first problem, kswapd hang problem was solved by
recent Mel's series(!pgdat_balanced bug and shrink_slab cond_resched)
which is key for James, Collins problem.

Andrew's next problem is a early OOM kill.

[   60.627550] cryptsetup invoked oom-killer: gfp_mask=3D0x201da,
order=3D0, oom_adj=3D0, oom_score_adj=3D0
[   60.627553] cryptsetup cpuset=3D/ mems_allowed=3D0
[   60.627555] Pid: 1910, comm: cryptsetup Not tainted 2.6.38.6-no-fpu+ #47
[   60.627556] Call Trace:
[   60.627563]  [<ffffffff8107f9c5>] ? cpuset_print_task_mems_allowed+0x91/=
0x9c
[   60.627567]  [<ffffffff810b3ef1>] ? dump_header+0x7f/0x1ba
[   60.627570]  [<ffffffff8109e4d6>] ? trace_hardirqs_on+0x9/0x20
[   60.627572]  [<ffffffff810b42ba>] ? oom_kill_process+0x50/0x24e
[   60.627574]  [<ffffffff810b4961>] ? out_of_memory+0x2e4/0x359
[   60.627576]  [<ffffffff810b879e>] ? __alloc_pages_nodemask+0x5f3/0x775
[   60.627579]  [<ffffffff810e127e>] ? alloc_pages_current+0xbe/0xd8
[   60.627581]  [<ffffffff810b2126>] ? __page_cache_alloc+0x77/0x7e
[   60.627585]  [<ffffffff8135d009>] ? dm_table_unplug_all+0x52/0xed
[   60.627587]  [<ffffffff810b9f74>] ? __do_page_cache_readahead+0x98/0x1a4
[   60.627589]  [<ffffffff810ba321>] ? ra_submit+0x21/0x25
[   60.627590]  [<ffffffff810ba4ee>] ? ondemand_readahead+0x1c9/0x1d8
[   60.627592]  [<ffffffff810ba5dd>] ? page_cache_sync_readahead+0x3d/0x40
[   60.627594]  [<ffffffff810b342d>] ? filemap_fault+0x119/0x36c
[   60.627597]  [<ffffffff810caf5f>] ? __do_fault+0x56/0x342
[   60.627600]  [<ffffffff810f5630>] ? lookup_page_cgroup+0x32/0x48
[   60.627602]  [<ffffffff810cd437>] ? handle_pte_fault+0x29f/0x765
[   60.627604]  [<ffffffff810ba75e>] ? add_page_to_lru_list+0x6e/0x73
[   60.627606]  [<ffffffff810be487>] ? page_evictable+0x1b/0x8d
[   60.627607]  [<ffffffff810bae36>] ? put_page+0x24/0x35
[   60.627610]  [<ffffffff810cdbfc>] ? handle_mm_fault+0x18e/0x1a1
[   60.627612]  [<ffffffff810cded2>] ? __get_user_pages+0x2c3/0x3ed
[   60.627614]  [<ffffffff810cfb4b>] ? __mlock_vma_pages_range+0x67/0x6b
[   60.627616]  [<ffffffff810cfc01>] ? do_mlock_pages+0xb2/0x11a
[   60.627618]  [<ffffffff810d0448>] ? sys_mlockall+0x111/0x11c
[   60.627621]  [<ffffffff81002a3b>] ? system_call_fastpath+0x16/0x1b
[   60.627623] Mem-Info:
[   60.627624] Node 0 DMA per-cpu:
[   60.627626] CPU    0: hi:    0, btch:   1 usd:   0
[   60.627627] CPU    1: hi:    0, btch:   1 usd:   0
[   60.627628] CPU    2: hi:    0, btch:   1 usd:   0
[   60.627629] CPU    3: hi:    0, btch:   1 usd:   0
[   60.627630] Node 0 DMA32 per-cpu:
[   60.627631] CPU    0: hi:  186, btch:  31 usd:   0
[   60.627633] CPU    1: hi:  186, btch:  31 usd:   0
[   60.627634] CPU    2: hi:  186, btch:  31 usd:   0
[   60.627635] CPU    3: hi:  186, btch:  31 usd:   0
[   60.627638] active_anon:51586 inactive_anon:17384 isolated_anon:0
[   60.627639]  active_file:0 inactive_file:226 isolated_file:0
[   60.627639]  unevictable:395661 dirty:0 writeback:3 unstable:0
[   60.627640]  free:13258 slab_reclaimable:3979 slab_unreclaimable:9755
[   60.627640]  mapped:11910 shmem:24046 pagetables:5062 bounce:0
[   60.627642] Node 0 DMA free:8352kB min:340kB low:424kB high:508kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:952kB
unevictable:6580kB isolated(anon):0kB isolated(file):0kB
present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB
shmem:0kB slab_reclaimable:16kB slab_unreclaimable:0kB
kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:1645 all_unreclaimable? yes
[   60.627649] lowmem_reserve[]: 0 2004 2004 2004
[   60.627651] Node 0 DMA32 free:44680kB min:44712kB low:55888kB
high:67068kB active_anon:206344kB inactive_anon:69536kB
active_file:0kB inactive_file:0kB unevictable:1576064kB
isolated(anon):0kB isolated(file):0kB present:2052320kB
mlocked:47540kB dirty:0kB writeback:12kB mapped:47640kB shmem:96184kB
slab_reclaimable:15900kB slab_unreclaimable:39020kB
kernel_stack:2424kB pagetables:20248kB unstable:0kB bounce:0kB
writeback_tmp:0kB pages_scanned:499225 all_unreclaimable? yes
[   60.627658] lowmem_reserve[]: 0 0 0 0
[   60.627660] Node 0 DMA: 0*4kB 0*8kB 2*16kB 2*32kB 1*64kB 2*128kB
1*256kB 1*512kB 1*1024kB 3*2048kB 0*4096kB =3D 8352kB
[   60.627665] Node 0 DMA32: 959*4kB 2071*8kB 682*16kB 165*32kB
27*64kB 4*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 1*4096kB =3D 44980kB
[   60.627670] 419957 total pagecache pages
[   60.627671] 0 pages in swap cache
[   60.627672] Swap cache stats: add 137, delete 137, find 0/0
[   60.627673] Free swap  =3D 6290904kB
[   60.627674] Total swap =3D 6291452kB
[   60.632560] 524272 pages RAM
[   60.632562] 9451 pages reserved
[   60.632563] 45558 pages shared
[   60.632564] 469944 pages non-shared


There are about 270M anon  and lots of free swap space in system.
Nonetheless, he saw the OOM. I think it doesn't make sense.
As I look above log, he used swap as crypted device mapper and used 1.4G ra=
mfs.
Andy, Right?

The thing I doubt firstly was a big ramfs.
I think in reclaim, shrink_page_list will start to cull mlocked page.
If there are so many ramfs pages and working set pages in LRU,
reclaimer can't reclaim any page until It meet non-unevictable pages
or non-working set page(!PG_referenced and !pte_young). His workload
had lots of anon pages and ramfs pages. ramfs pages is unevictable
page so that it would cull and anon pages are promoted very easily so
that we can't reclaim it easily.
It means zone->pages_scanned would be very high so after all,
zone->all_unreclaimable would set.
As I look above log, the number of lru in  DMA32 zone is 68970.
The number of unevictable page is 394016.

394016 + working set page(I don't know) is almost equal to  (68970 * 6
=3D 413820).
So it's possible that zone->all_unreclaimable is set.
I wanted to test below patch by private but it doesn't solve his problem.
But I think we need below patch, still. It can happen if we had lots
of LRU order successive mlocked page in LRU.

=3D=3D=3D
