Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A6CCB6B002B
	for <linux-mm@kvack.org>; Sun, 29 May 2011 14:28:54 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2020421qwa.14
        for <linux-mm@kvack.org>; Sun, 29 May 2011 11:28:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTimDtpVeLYisfon7g_=H80D0XXgkGQ@mail.gmail.com>
References: <BANLkTinptn4-+u+jgOr2vf2iuiVS3mmYXA@mail.gmail.com>
	<BANLkTimDtpVeLYisfon7g_=H80D0XXgkGQ@mail.gmail.com>
Date: Mon, 30 May 2011 03:28:50 +0900
Message-ID: <BANLkTim8ngH8ASTk9js-G9DxySWVb7VL3A@mail.gmail.com>
Subject: Re: Easy portable testcase! (Re: Kernel falls apart under light
 memory pressure (i.e. linking vmlinux))
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=0015175cdc0ca2d75804a46e57c9
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>, mgorman@suse.de, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: aarcange@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, riel@redhat.com

--0015175cdc0ca2d75804a46e57c9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Fri, May 27, 2011 at 8:58 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Thu, May 26, 2011 at 5:17 AM, Andrew Lutomirski <luto@mit.edu> wrote:
>> On Tue, May 24, 2011 at 8:43 PM, KOSAKI Motohiro
>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>>
>>> Unfortnately, this log don't tell us why DM don't issue any swap io. ;-=
)
>>> I doubt it's DM issue. Can you please try to make swap on out of DM?
>>>
>>>
>>
>> I can do one better: I can tell you how to reproduce the OOM in the
>> comfort of your own VM without using dm_crypt or a Sandy Bridge
>> laptop. =C2=A0This is on Fedora 15, but it really ought to work on any
>> x86_64 distribution that has kvm. =C2=A0You'll probably want at least 6G=
B
>> on your host machine because the VM wants 4GB ram.
>>
>> Here's how:
>>
>> Step 1: Clone git://gitorious.org/linux-test-utils/reproduce-annoying-mm=
-bug.git
>>
>> (You can browse here:)
>> https://gitorious.org/linux-test-utils/reproduce-annoying-mm-bug
>>
>> Instructions to reproduce the mm bug:
>>
>> Step 2: Build Linux v2.6.38.6 with config-2.6.38.6 and the patch
>> 0001-Minchan-patch-for-testing-23-05-2011.patch (both files are in the
>> git repo)
>>
>> Step 3: cd back to reproduce-annoying-mm-bug
>>
>> Step 4: Type this.
>>
>> $ make
>> $ qemu-kvm -m 4G -smp 2 -kernel <linux_dir>/arch/x86/boot/bzImage
>> -initrd initramfs.gz
>>
>> Step 5: Wait for the VM to boot (it's really fast) and then run ./repro_=
bug.sh.
>>
>> Step 6: Wait a bit and watch the fireworks. =C2=A0Note that it can take =
a
>> couple minutes to reproduce the bug.
>>
>> Tested on my Sandy Bridge laptop and on a Xeon W3520.
>>
>> For whatever reason, on my laptop without the VM I can hit the bug
>> almost instantaneously. =C2=A0Maybe it's because I'm using dm-crypt on m=
y
>> laptop.
>>
>> --Andy
>>
>> P.S. =C2=A0I think that the mk_trivial_initramfs.sh script is cute, and
>
> That's cool. :)
>
>> maybe I'll try to flesh it out and turn it into a real project some
>> day.
>>
>
> Thanks for good test environment.
> Yesterday, I tried to reproduce your problem in my system(4G DRAM) but
> unfortunately got failed. I tried various setting but I can't reach.
> Maybe I need 8G system or sandy-bridge. =C2=A0:(
>
> Hi mm folks, It's next round.
> Andrew Lutomirski's first problem, kswapd hang problem was solved by
> recent Mel's series(!pgdat_balanced bug and shrink_slab cond_resched)
> which is key for James, Collins problem.
>
> Andrew's next problem is a early OOM kill.
>
> [ =C2=A0 60.627550] cryptsetup invoked oom-killer: gfp_mask=3D0x201da,
> order=3D0, oom_adj=3D0, oom_score_adj=3D0
> [ =C2=A0 60.627553] cryptsetup cpuset=3D/ mems_allowed=3D0
> [ =C2=A0 60.627555] Pid: 1910, comm: cryptsetup Not tainted 2.6.38.6-no-f=
pu+ #47
> [ =C2=A0 60.627556] Call Trace:
> [ =C2=A0 60.627563] =C2=A0[<ffffffff8107f9c5>] ? cpuset_print_task_mems_a=
llowed+0x91/0x9c
> [ =C2=A0 60.627567] =C2=A0[<ffffffff810b3ef1>] ? dump_header+0x7f/0x1ba
> [ =C2=A0 60.627570] =C2=A0[<ffffffff8109e4d6>] ? trace_hardirqs_on+0x9/0x=
20
> [ =C2=A0 60.627572] =C2=A0[<ffffffff810b42ba>] ? oom_kill_process+0x50/0x=
24e
> [ =C2=A0 60.627574] =C2=A0[<ffffffff810b4961>] ? out_of_memory+0x2e4/0x35=
9
> [ =C2=A0 60.627576] =C2=A0[<ffffffff810b879e>] ? __alloc_pages_nodemask+0=
x5f3/0x775
> [ =C2=A0 60.627579] =C2=A0[<ffffffff810e127e>] ? alloc_pages_current+0xbe=
/0xd8
> [ =C2=A0 60.627581] =C2=A0[<ffffffff810b2126>] ? __page_cache_alloc+0x77/=
0x7e
> [ =C2=A0 60.627585] =C2=A0[<ffffffff8135d009>] ? dm_table_unplug_all+0x52=
/0xed
> [ =C2=A0 60.627587] =C2=A0[<ffffffff810b9f74>] ? __do_page_cache_readahea=
d+0x98/0x1a4
> [ =C2=A0 60.627589] =C2=A0[<ffffffff810ba321>] ? ra_submit+0x21/0x25
> [ =C2=A0 60.627590] =C2=A0[<ffffffff810ba4ee>] ? ondemand_readahead+0x1c9=
/0x1d8
> [ =C2=A0 60.627592] =C2=A0[<ffffffff810ba5dd>] ? page_cache_sync_readahea=
d+0x3d/0x40
> [ =C2=A0 60.627594] =C2=A0[<ffffffff810b342d>] ? filemap_fault+0x119/0x36=
c
> [ =C2=A0 60.627597] =C2=A0[<ffffffff810caf5f>] ? __do_fault+0x56/0x342
> [ =C2=A0 60.627600] =C2=A0[<ffffffff810f5630>] ? lookup_page_cgroup+0x32/=
0x48
> [ =C2=A0 60.627602] =C2=A0[<ffffffff810cd437>] ? handle_pte_fault+0x29f/0=
x765
> [ =C2=A0 60.627604] =C2=A0[<ffffffff810ba75e>] ? add_page_to_lru_list+0x6=
e/0x73
> [ =C2=A0 60.627606] =C2=A0[<ffffffff810be487>] ? page_evictable+0x1b/0x8d
> [ =C2=A0 60.627607] =C2=A0[<ffffffff810bae36>] ? put_page+0x24/0x35
> [ =C2=A0 60.627610] =C2=A0[<ffffffff810cdbfc>] ? handle_mm_fault+0x18e/0x=
1a1
> [ =C2=A0 60.627612] =C2=A0[<ffffffff810cded2>] ? __get_user_pages+0x2c3/0=
x3ed
> [ =C2=A0 60.627614] =C2=A0[<ffffffff810cfb4b>] ? __mlock_vma_pages_range+=
0x67/0x6b
> [ =C2=A0 60.627616] =C2=A0[<ffffffff810cfc01>] ? do_mlock_pages+0xb2/0x11=
a
> [ =C2=A0 60.627618] =C2=A0[<ffffffff810d0448>] ? sys_mlockall+0x111/0x11c
> [ =C2=A0 60.627621] =C2=A0[<ffffffff81002a3b>] ? system_call_fastpath+0x1=
6/0x1b
> [ =C2=A0 60.627623] Mem-Info:
> [ =C2=A0 60.627624] Node 0 DMA per-cpu:
> [ =C2=A0 60.627626] CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 =
1 usd: =C2=A0 0
> [ =C2=A0 60.627627] CPU =C2=A0 =C2=A01: hi: =C2=A0 =C2=A00, btch: =C2=A0 =
1 usd: =C2=A0 0
> [ =C2=A0 60.627628] CPU =C2=A0 =C2=A02: hi: =C2=A0 =C2=A00, btch: =C2=A0 =
1 usd: =C2=A0 0
> [ =C2=A0 60.627629] CPU =C2=A0 =C2=A03: hi: =C2=A0 =C2=A00, btch: =C2=A0 =
1 usd: =C2=A0 0
> [ =C2=A0 60.627630] Node 0 DMA32 per-cpu:
> [ =C2=A0 60.627631] CPU =C2=A0 =C2=A00: hi: =C2=A0186, btch: =C2=A031 usd=
: =C2=A0 0
> [ =C2=A0 60.627633] CPU =C2=A0 =C2=A01: hi: =C2=A0186, btch: =C2=A031 usd=
: =C2=A0 0
> [ =C2=A0 60.627634] CPU =C2=A0 =C2=A02: hi: =C2=A0186, btch: =C2=A031 usd=
: =C2=A0 0
> [ =C2=A0 60.627635] CPU =C2=A0 =C2=A03: hi: =C2=A0186, btch: =C2=A031 usd=
: =C2=A0 0
> [ =C2=A0 60.627638] active_anon:51586 inactive_anon:17384 isolated_anon:0
> [ =C2=A0 60.627639] =C2=A0active_file:0 inactive_file:226 isolated_file:0
> [ =C2=A0 60.627639] =C2=A0unevictable:395661 dirty:0 writeback:3 unstable=
:0
> [ =C2=A0 60.627640] =C2=A0free:13258 slab_reclaimable:3979 slab_unreclaim=
able:9755
> [ =C2=A0 60.627640] =C2=A0mapped:11910 shmem:24046 pagetables:5062 bounce=
:0
> [ =C2=A0 60.627642] Node 0 DMA free:8352kB min:340kB low:424kB high:508kB
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:952kB
> unevictable:6580kB isolated(anon):0kB isolated(file):0kB
> present:15676kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB
> shmem:0kB slab_reclaimable:16kB slab_unreclaimable:0kB
> kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:1645 all_unreclaimable? yes
> [ =C2=A0 60.627649] lowmem_reserve[]: 0 2004 2004 2004
> [ =C2=A0 60.627651] Node 0 DMA32 free:44680kB min:44712kB low:55888kB
> high:67068kB active_anon:206344kB inactive_anon:69536kB
> active_file:0kB inactive_file:0kB unevictable:1576064kB
> isolated(anon):0kB isolated(file):0kB present:2052320kB
> mlocked:47540kB dirty:0kB writeback:12kB mapped:47640kB shmem:96184kB
> slab_reclaimable:15900kB slab_unreclaimable:39020kB
> kernel_stack:2424kB pagetables:20248kB unstable:0kB bounce:0kB
> writeback_tmp:0kB pages_scanned:499225 all_unreclaimable? yes
> [ =C2=A0 60.627658] lowmem_reserve[]: 0 0 0 0
> [ =C2=A0 60.627660] Node 0 DMA: 0*4kB 0*8kB 2*16kB 2*32kB 1*64kB 2*128kB
> 1*256kB 1*512kB 1*1024kB 3*2048kB 0*4096kB =3D 8352kB
> [ =C2=A0 60.627665] Node 0 DMA32: 959*4kB 2071*8kB 682*16kB 165*32kB
> 27*64kB 4*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 1*4096kB =3D 44980kB
> [ =C2=A0 60.627670] 419957 total pagecache pages
> [ =C2=A0 60.627671] 0 pages in swap cache
> [ =C2=A0 60.627672] Swap cache stats: add 137, delete 137, find 0/0
> [ =C2=A0 60.627673] Free swap =C2=A0=3D 6290904kB
> [ =C2=A0 60.627674] Total swap =3D 6291452kB
> [ =C2=A0 60.632560] 524272 pages RAM
> [ =C2=A0 60.632562] 9451 pages reserved
> [ =C2=A0 60.632563] 45558 pages shared
> [ =C2=A0 60.632564] 469944 pages non-shared
>
>
> There are about 270M anon =C2=A0and lots of free swap space in system.
> Nonetheless, he saw the OOM. I think it doesn't make sense.
> As I look above log, he used swap as crypted device mapper and used 1.4G =
ramfs.
> Andy, Right?
>
> The thing I doubt firstly was a big ramfs.
> I think in reclaim, shrink_page_list will start to cull mlocked page.
> If there are so many ramfs pages and working set pages in LRU,
> reclaimer can't reclaim any page until It meet non-unevictable pages
> or non-working set page(!PG_referenced and !pte_young). His workload
> had lots of anon pages and ramfs pages. ramfs pages is unevictable
> page so that it would cull and anon pages are promoted very easily so
> that we can't reclaim it easily.
> It means zone->pages_scanned would be very high so after all,
> zone->all_unreclaimable would set.
> As I look above log, the number of lru in =C2=A0DMA32 zone is 68970.
> The number of unevictable page is 394016.
>
> 394016 + working set page(I don't know) is almost equal to =C2=A0(68970 *=
 6
> =3D 413820).
> So it's possible that zone->all_unreclaimable is set.
> I wanted to test below patch by private but it doesn't solve his problem.
> But I think we need below patch, still. It can happen if we had lots
> of LRU order successive mlocked page in LRU.
>
> =3D=3D=3D
>
> From e37f150328aedeea9a88b6190ab2b6e6c1067163 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Wed, 25 May 2011 07:09:17 +0900
> Subject: [PATCH 3/3] vmscan: decrease pages_scanned on unevictable page
>
> If there are many unevictable pages on evictable LRU list(ex, big ramfs),
> shrink_page_list will move it into unevictable and can't reclaim pages.
> But we already increased zone->pages_scanned.
> If the situation is repeated, the number of evictable lru pages is decrea=
sed
> while zone->pages_scanned is increased without reclaim any pages.
> It could turn on zone->all_unreclaimable but it's totally false alram.
>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =C2=A0mm/vmscan.c | =C2=A0 22 +++++++++++++++++++---
> =C2=A01 files changed, 19 insertions(+), 3 deletions(-)
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 08d3077..a7df813 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -700,7 +700,8 @@ static noinline_for_stack void
> free_page_list(struct list_head *free_pages)
> =C2=A0static unsigned long shrink_page_list(struct list_head *page_list,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct zone *zon=
e,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct scan_cont=
rol *sc,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *dirt=
y_pages)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *dirt=
y_pages,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unsigned long *unev=
ictable_pages)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(ret_pages);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0LIST_HEAD(free_pages);
> @@ -708,6 +709,7 @@ static unsigned long shrink_page_list(struct
> list_head *page_list,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_dirty =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_congested =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D 0;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr_unevictable =3D 0;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0cond_resched();
>
> @@ -908,6 +910,7 @@ cull_mlocked:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0try_to_free_swap(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0putback_lru_page(p=
age);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_unevictable++;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0continue;
>
> =C2=A0activate_locked:
> @@ -936,6 +939,7 @@ keep_lumpy:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_set_flag(zone=
, ZONE_CONGESTED);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0*dirty_pages =3D nr_dirty;
> + =C2=A0 =C2=A0 =C2=A0 *unevictable_pages =3D nr_unevictable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0free_page_list(&free_pages);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0list_splice(&ret_pages, page_list);
> @@ -1372,6 +1376,7 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_scanned;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_reclaimed =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_dirty;
> + =C2=A0 =C2=A0 =C2=A0 unsigned long nr_unevictable;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_taken;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_anon;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_file;
> @@ -1425,7 +1430,7 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock_irq(&zone->lru_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0reclaim_mode =3D sc->reclaim_mode;
> - =C2=A0 =C2=A0 =C2=A0 nr_reclaimed =3D shrink_page_list(&page_list, zone=
, sc, &nr_dirty);
> + =C2=A0 =C2=A0 =C2=A0 nr_reclaimed =3D shrink_page_list(&page_list, zone=
, sc, &nr_dirty,
> &nr_unevictable);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Check if we should syncronously wait for wr=
iteback */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((nr_dirty && !(reclaim_mode & RECLAIM_MODE=
_SINGLE) &&
> @@ -1434,7 +1439,8 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long nr_a=
ctive =3D clear_active_flags(&page_list, NULL);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0count_vm_events(PG=
DEACTIVATE, nr_active);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0set_reclaim_mode(p=
riority, sc, true);
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_reclaimed +=3D shri=
nk_page_list(&page_list, zone, sc, &nr_dirty);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nr_reclaimed +=3D shri=
nk_page_list(&page_list, zone, sc,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 &nr_dirty, &nr_unevictable);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0local_irq_disable();
> @@ -1442,6 +1448,16 @@ shrink_inactive_list(unsigned long nr_to_scan,
> struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_vm_events(=
KSWAPD_STEAL, nr_reclaimed);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0__count_zone_vm_events(PGSTEAL, zone, nr_recla=
imed);
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Too many unevictalbe pages on evictable LR=
U list(ex, big ramfs)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* can make high zone->pages_scanned and redu=
ce the number of lru page
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* on evictable lru as reclaim is going on.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* It could turn on all_unreclaimable which i=
s false alarm.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&zone->lru_lock);
> + =C2=A0 =C2=A0 =C2=A0 if (zone->pages_scanned >=3D nr_unevictable)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned -=
=3D nr_unevictable;
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 zone->pages_scanned =
=3D 0;
> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&zone->lru_lock);
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0putback_lru_pages(zone, sc, nr_anon, nr_file, =
&page_list);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0trace_mm_vmscan_lru_shrink_inactive(zone->zone=
_pgdat->node_id,
> --
> 1.7.1
>
> =3D=3D=3D
>
> Then, what I doubt secondly is zone_set_flag(zone, ZONE_CONGESTED).
> He used swap as crypted device mapper.
> Device mapper could make IO slow for his work. It means we are likely
> to meet ZONE_CONGESTED higher than normal swap.
>
> Let's think about it.
> Swap device is very congested so shrink_page_list would set the zone
> as CONGESTED.
> Who is clear ZONE_CONGESTED? There are two place in =C2=A0kswapd.
> One work in only order > 0. So maybe, it's no-op in Andy's
> workload.(ie, it's mostly order-0 allocation)
> One remained is below.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * If a zone reaches its high waterma=
rk,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * consider it to be no longer conges=
ted. It's
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * possible there are dirty pages bac=
ked by
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * congested BDIs but as pressure is =
relieved,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * spectulatively avoid congestion wa=
its
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0zone_clear_flag(zone, ZONE_CONGESTED)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (i <=3D *classzone_idx)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0balanced =
+=3D zone->present_pages;
>
> It works only if the zone meets high watermark. If allocation is
> faster than reclaim(ie, it's true for slow swap device), the zone
> would remain congested.
> It means swapout would block.
> As we see the OOM log, we can know that DMA32 zone can't meet high waterm=
ark.
>
> Does my guessing make sense?

Hi Andrew.
I got failed your scenario in my machine so could you be willing to
test this patch for proving my above scenario?
The patch is just revert patch of 0e093d99[do not sleep on the
congestion queue...] for 2.6.38.6.
I would like to test it for proving my above zone congestion scenario.

I did it based on 2.6.38.6 for your easy apply so you must apply it
cleanly on vanilla v2.6.38.6.
And you have to add !pgdat_balanced and shrink_slab patch.

Thanks, Andrew.

--=20
Kind regards,
Minchan Kim

--0015175cdc0ca2d75804a46e57c9
Content-Type: text/x-patch; charset=US-ASCII;
	name="0001-Revert-writeback-do-not-sleep-on-the-congestion-queu.patch"
Content-Disposition: attachment;
	filename="0001-Revert-writeback-do-not-sleep-on-the-congestion-queu.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_goabp12r0

RnJvbSAyNDRlMzdmMWYzOTc4ZmYxODJiNWUzM2I3N2IzMjdlNGY0OGJiNDM4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBNaW5jaGFuIEtpbSA8bWluY2hhbi5raW1AZ21haWwuY29tPgpE
YXRlOiBNb24sIDMwIE1heSAyMDExIDAyOjIzOjQ5ICswOTAwClN1YmplY3Q6IFtQQVRDSF0gUmV2
ZXJ0ICJ3cml0ZWJhY2s6IGRvIG5vdCBzbGVlcCBvbiB0aGUgY29uZ2VzdGlvbiBxdWV1ZSBpZiB0
aGVyZSBhcmUgbm8gY29uZ2VzdGVkIEJESXMgb3IgaWYgc2lnbmlmaWNhbnQgY29uZ2VzdGlvbiBp
cyBub3QgYmVpbmcgZW5jb3VudGVyZWQgaW4gdGhlIGN1cnJlbnQgem9uZSIKClRoaXMgcmV2ZXJ0
cyBjb21taXQgMGUwOTNkOTk3NjNlYjRjZWEwOWY4Y2E0ZjFkMDFmMzRlMTIxZDEwYi4KCkNvbmZs
aWN0czoKCgltbS92bXNjYW4uYwoKU2lnbmVkLW9mZi1ieTogTWluY2hhbiBLaW0gPG1pbmNoYW4u
a2ltQGdtYWlsLmNvbT4KLS0tCiBpbmNsdWRlL2xpbnV4L2JhY2tpbmctZGV2LmggICAgICB8ICAg
IDIgKy0KIGluY2x1ZGUvbGludXgvbW16b25lLmggICAgICAgICAgIHwgICAgOCAtLS0tLQogaW5j
bHVkZS90cmFjZS9ldmVudHMvd3JpdGViYWNrLmggfCAgICA3IC0tLS0KIG1tL2JhY2tpbmctZGV2
LmMgICAgICAgICAgICAgICAgIHwgICA2MSArLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tCiBtbS9wYWdlX2FsbG9jLmMgICAgICAgICAgICAgICAgICB8ICAgIDQgKy0KIG1tL3Zt
c2Nhbi5jICAgICAgICAgICAgICAgICAgICAgIHwgICA0MSArKy0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tCiA2IGZpbGVzIGNoYW5nZWQsIDkgaW5zZXJ0aW9ucygrKSwgMTE0IGRlbGV0aW9ucygtKQoK
ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvYmFja2luZy1kZXYuaCBiL2luY2x1ZGUvbGludXgv
YmFja2luZy1kZXYuaAppbmRleCA0Y2UzNGZhLi44YjBhZThiIDEwMDY0NAotLS0gYS9pbmNsdWRl
L2xpbnV4L2JhY2tpbmctZGV2LmgKKysrIGIvaW5jbHVkZS9saW51eC9iYWNraW5nLWRldi5oCkBA
IC0yODYsNyArMjg2LDcgQEAgZW51bSB7CiB2b2lkIGNsZWFyX2JkaV9jb25nZXN0ZWQoc3RydWN0
IGJhY2tpbmdfZGV2X2luZm8gKmJkaSwgaW50IHN5bmMpOwogdm9pZCBzZXRfYmRpX2Nvbmdlc3Rl
ZChzdHJ1Y3QgYmFja2luZ19kZXZfaW5mbyAqYmRpLCBpbnQgc3luYyk7CiBsb25nIGNvbmdlc3Rp
b25fd2FpdChpbnQgc3luYywgbG9uZyB0aW1lb3V0KTsKLWxvbmcgd2FpdF9pZmZfY29uZ2VzdGVk
KHN0cnVjdCB6b25lICp6b25lLCBpbnQgc3luYywgbG9uZyB0aW1lb3V0KTsKKwogCiBzdGF0aWMg
aW5saW5lIGJvb2wgYmRpX2NhcF93cml0ZWJhY2tfZGlydHkoc3RydWN0IGJhY2tpbmdfZGV2X2lu
Zm8gKmJkaSkKIHsKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbW16b25lLmggYi9pbmNsdWRl
L2xpbnV4L21tem9uZS5oCmluZGV4IDAyZWNiMDEuLmUxYjE2YWEgMTAwNjQ0Ci0tLSBhL2luY2x1
ZGUvbGludXgvbW16b25lLmgKKysrIGIvaW5jbHVkZS9saW51eC9tbXpvbmUuaApAQCAtNDI0LDkg
KzQyNCw2IEBAIHN0cnVjdCB6b25lIHsKIHR5cGVkZWYgZW51bSB7CiAJWk9ORV9SRUNMQUlNX0xP
Q0tFRCwJCS8qIHByZXZlbnRzIGNvbmN1cnJlbnQgcmVjbGFpbSAqLwogCVpPTkVfT09NX0xPQ0tF
RCwJCS8qIHpvbmUgaXMgaW4gT09NIGtpbGxlciB6b25lbGlzdCAqLwotCVpPTkVfQ09OR0VTVEVE
LAkJCS8qIHpvbmUgaGFzIG1hbnkgZGlydHkgcGFnZXMgYmFja2VkIGJ5Ci0JCQkJCSAqIGEgY29u
Z2VzdGVkIEJESQotCQkJCQkgKi8KIH0gem9uZV9mbGFnc190OwogCiBzdGF0aWMgaW5saW5lIHZv
aWQgem9uZV9zZXRfZmxhZyhzdHJ1Y3Qgem9uZSAqem9uZSwgem9uZV9mbGFnc190IGZsYWcpCkBA
IC00NDQsMTEgKzQ0MSw2IEBAIHN0YXRpYyBpbmxpbmUgdm9pZCB6b25lX2NsZWFyX2ZsYWcoc3Ry
dWN0IHpvbmUgKnpvbmUsIHpvbmVfZmxhZ3NfdCBmbGFnKQogCWNsZWFyX2JpdChmbGFnLCAmem9u
ZS0+ZmxhZ3MpOwogfQogCi1zdGF0aWMgaW5saW5lIGludCB6b25lX2lzX3JlY2xhaW1fY29uZ2Vz
dGVkKGNvbnN0IHN0cnVjdCB6b25lICp6b25lKQotewotCXJldHVybiB0ZXN0X2JpdChaT05FX0NP
TkdFU1RFRCwgJnpvbmUtPmZsYWdzKTsKLX0KLQogc3RhdGljIGlubGluZSBpbnQgem9uZV9pc19y
ZWNsYWltX2xvY2tlZChjb25zdCBzdHJ1Y3Qgem9uZSAqem9uZSkKIHsKIAlyZXR1cm4gdGVzdF9i
aXQoWk9ORV9SRUNMQUlNX0xPQ0tFRCwgJnpvbmUtPmZsYWdzKTsKZGlmZiAtLWdpdCBhL2luY2x1
ZGUvdHJhY2UvZXZlbnRzL3dyaXRlYmFjay5oIGIvaW5jbHVkZS90cmFjZS9ldmVudHMvd3JpdGVi
YWNrLmgKaW5kZXggNGUyNDliOS4uZmMyYjNhMCAxMDA2NDQKLS0tIGEvaW5jbHVkZS90cmFjZS9l
dmVudHMvd3JpdGViYWNrLmgKKysrIGIvaW5jbHVkZS90cmFjZS9ldmVudHMvd3JpdGViYWNrLmgK
QEAgLTE4MCwxMyArMTgwLDYgQEAgREVGSU5FX0VWRU5UKHdyaXRlYmFja19jb25nZXN0X3dhaXRl
ZF90ZW1wbGF0ZSwgd3JpdGViYWNrX2Nvbmdlc3Rpb25fd2FpdCwKIAlUUF9BUkdTKHVzZWNfdGlt
ZW91dCwgdXNlY19kZWxheWVkKQogKTsKIAotREVGSU5FX0VWRU5UKHdyaXRlYmFja19jb25nZXN0
X3dhaXRlZF90ZW1wbGF0ZSwgd3JpdGViYWNrX3dhaXRfaWZmX2Nvbmdlc3RlZCwKLQotCVRQX1BS
T1RPKHVuc2lnbmVkIGludCB1c2VjX3RpbWVvdXQsIHVuc2lnbmVkIGludCB1c2VjX2RlbGF5ZWQp
LAotCi0JVFBfQVJHUyh1c2VjX3RpbWVvdXQsIHVzZWNfZGVsYXllZCkKLSk7Ci0KICNlbmRpZiAv
KiBfVFJBQ0VfV1JJVEVCQUNLX0ggKi8KIAogLyogVGhpcyBwYXJ0IG11c3QgYmUgb3V0c2lkZSBw
cm90ZWN0aW9uICovCmRpZmYgLS1naXQgYS9tbS9iYWNraW5nLWRldi5jIGIvbW0vYmFja2luZy1k
ZXYuYwppbmRleCA4ZTRlZDg4Li5jOWU1OWRlIDEwMDY0NAotLS0gYS9tbS9iYWNraW5nLWRldi5j
CisrKyBiL21tL2JhY2tpbmctZGV2LmMKQEAgLTcyOSw3ICs3MjksNiBAQCBzdGF0aWMgd2FpdF9x
dWV1ZV9oZWFkX3QgY29uZ2VzdGlvbl93cWhbMl0gPSB7CiAJCV9fV0FJVF9RVUVVRV9IRUFEX0lO
SVRJQUxJWkVSKGNvbmdlc3Rpb25fd3FoWzBdKSwKIAkJX19XQUlUX1FVRVVFX0hFQURfSU5JVElB
TElaRVIoY29uZ2VzdGlvbl93cWhbMV0pCiAJfTsKLXN0YXRpYyBhdG9taWNfdCBucl9iZGlfY29u
Z2VzdGVkWzJdOwogCiB2b2lkIGNsZWFyX2JkaV9jb25nZXN0ZWQoc3RydWN0IGJhY2tpbmdfZGV2
X2luZm8gKmJkaSwgaW50IHN5bmMpCiB7CkBAIC03MzcsOCArNzM2LDcgQEAgdm9pZCBjbGVhcl9i
ZGlfY29uZ2VzdGVkKHN0cnVjdCBiYWNraW5nX2Rldl9pbmZvICpiZGksIGludCBzeW5jKQogCXdh
aXRfcXVldWVfaGVhZF90ICp3cWggPSAmY29uZ2VzdGlvbl93cWhbc3luY107CiAKIAliaXQgPSBz
eW5jID8gQkRJX3N5bmNfY29uZ2VzdGVkIDogQkRJX2FzeW5jX2Nvbmdlc3RlZDsKLQlpZiAodGVz
dF9hbmRfY2xlYXJfYml0KGJpdCwgJmJkaS0+c3RhdGUpKQotCQlhdG9taWNfZGVjKCZucl9iZGlf
Y29uZ2VzdGVkW3N5bmNdKTsKKwljbGVhcl9iaXQoYml0LCAmYmRpLT5zdGF0ZSk7CiAJc21wX21i
X19hZnRlcl9jbGVhcl9iaXQoKTsKIAlpZiAod2FpdHF1ZXVlX2FjdGl2ZSh3cWgpKQogCQl3YWtl
X3VwKHdxaCk7CkBAIC03NTAsOCArNzQ4LDcgQEAgdm9pZCBzZXRfYmRpX2Nvbmdlc3RlZChzdHJ1
Y3QgYmFja2luZ19kZXZfaW5mbyAqYmRpLCBpbnQgc3luYykKIAllbnVtIGJkaV9zdGF0ZSBiaXQ7
CiAKIAliaXQgPSBzeW5jID8gQkRJX3N5bmNfY29uZ2VzdGVkIDogQkRJX2FzeW5jX2Nvbmdlc3Rl
ZDsKLQlpZiAoIXRlc3RfYW5kX3NldF9iaXQoYml0LCAmYmRpLT5zdGF0ZSkpCi0JCWF0b21pY19p
bmMoJm5yX2JkaV9jb25nZXN0ZWRbc3luY10pOworCXNldF9iaXQoYml0LCAmYmRpLT5zdGF0ZSk7
CiB9CiBFWFBPUlRfU1lNQk9MKHNldF9iZGlfY29uZ2VzdGVkKTsKIApAQCAtNzgyLDU3ICs3Nzks
MyBAQCBsb25nIGNvbmdlc3Rpb25fd2FpdChpbnQgc3luYywgbG9uZyB0aW1lb3V0KQogfQogRVhQ
T1JUX1NZTUJPTChjb25nZXN0aW9uX3dhaXQpOwogCi0vKioKLSAqIHdhaXRfaWZmX2Nvbmdlc3Rl
ZCAtIENvbmRpdGlvbmFsbHkgd2FpdCBmb3IgYSBiYWNraW5nX2RldiB0byBiZWNvbWUgdW5jb25n
ZXN0ZWQgb3IgYSB6b25lIHRvIGNvbXBsZXRlIHdyaXRlcwotICogQHpvbmU6IEEgem9uZSB0byBj
aGVjayBpZiBpdCBpcyBoZWF2aWx5IGNvbmdlc3RlZAotICogQHN5bmM6IFNZTkMgb3IgQVNZTkMg
SU8KLSAqIEB0aW1lb3V0OiB0aW1lb3V0IGluIGppZmZpZXMKLSAqCi0gKiBJbiB0aGUgZXZlbnQg
b2YgYSBjb25nZXN0ZWQgYmFja2luZ19kZXYgKGFueSBiYWNraW5nX2RldikgYW5kIHRoZSBnaXZl
bgotICogQHpvbmUgaGFzIGV4cGVyaWVuY2VkIHJlY2VudCBjb25nZXN0aW9uLCB0aGlzIHdhaXRz
IGZvciB1cCB0byBAdGltZW91dAotICogamlmZmllcyBmb3IgZWl0aGVyIGEgQkRJIHRvIGV4aXQg
Y29uZ2VzdGlvbiBvZiB0aGUgZ2l2ZW4gQHN5bmMgcXVldWUKLSAqIG9yIGEgd3JpdGUgdG8gY29t
cGxldGUuCi0gKgotICogSW4gdGhlIGFic2Vuc2Ugb2Ygem9uZSBjb25nZXN0aW9uLCBjb25kX3Jl
c2NoZWQoKSBpcyBjYWxsZWQgdG8geWllbGQKLSAqIHRoZSBwcm9jZXNzb3IgaWYgbmVjZXNzYXJ5
IGJ1dCBvdGhlcndpc2UgZG9lcyBub3Qgc2xlZXAuCi0gKgotICogVGhlIHJldHVybiB2YWx1ZSBp
cyAwIGlmIHRoZSBzbGVlcCBpcyBmb3IgdGhlIGZ1bGwgdGltZW91dC4gT3RoZXJ3aXNlLAotICog
aXQgaXMgdGhlIG51bWJlciBvZiBqaWZmaWVzIHRoYXQgd2VyZSBzdGlsbCByZW1haW5pbmcgd2hl
biB0aGUgZnVuY3Rpb24KLSAqIHJldHVybmVkLiByZXR1cm5fdmFsdWUgPT0gdGltZW91dCBpbXBs
aWVzIHRoZSBmdW5jdGlvbiBkaWQgbm90IHNsZWVwLgotICovCi1sb25nIHdhaXRfaWZmX2Nvbmdl
c3RlZChzdHJ1Y3Qgem9uZSAqem9uZSwgaW50IHN5bmMsIGxvbmcgdGltZW91dCkKLXsKLQlsb25n
IHJldDsKLQl1bnNpZ25lZCBsb25nIHN0YXJ0ID0gamlmZmllczsKLQlERUZJTkVfV0FJVCh3YWl0
KTsKLQl3YWl0X3F1ZXVlX2hlYWRfdCAqd3FoID0gJmNvbmdlc3Rpb25fd3FoW3N5bmNdOwotCi0J
LyoKLQkgKiBJZiB0aGVyZSBpcyBubyBjb25nZXN0aW9uLCBvciBoZWF2eSBjb25nZXN0aW9uIGlz
IG5vdCBiZWluZwotCSAqIGVuY291bnRlcmVkIGluIHRoZSBjdXJyZW50IHpvbmUsIHlpZWxkIGlm
IG5lY2Vzc2FyeSBpbnN0ZWFkCi0JICogb2Ygc2xlZXBpbmcgb24gdGhlIGNvbmdlc3Rpb24gcXVl
dWUKLQkgKi8KLQlpZiAoYXRvbWljX3JlYWQoJm5yX2JkaV9jb25nZXN0ZWRbc3luY10pID09IDAg
fHwKLQkJCSF6b25lX2lzX3JlY2xhaW1fY29uZ2VzdGVkKHpvbmUpKSB7Ci0JCWNvbmRfcmVzY2hl
ZCgpOwotCi0JCS8qIEluIGNhc2Ugd2Ugc2NoZWR1bGVkLCB3b3JrIG91dCB0aW1lIHJlbWFpbmlu
ZyAqLwotCQlyZXQgPSB0aW1lb3V0IC0gKGppZmZpZXMgLSBzdGFydCk7Ci0JCWlmIChyZXQgPCAw
KQotCQkJcmV0ID0gMDsKLQotCQlnb3RvIG91dDsKLQl9Ci0KLQkvKiBTbGVlcCB1bnRpbCB1bmNv
bmdlc3RlZCBvciBhIHdyaXRlIGhhcHBlbnMgKi8KLQlwcmVwYXJlX3RvX3dhaXQod3FoLCAmd2Fp
dCwgVEFTS19VTklOVEVSUlVQVElCTEUpOwotCXJldCA9IGlvX3NjaGVkdWxlX3RpbWVvdXQodGlt
ZW91dCk7Ci0JZmluaXNoX3dhaXQod3FoLCAmd2FpdCk7Ci0KLW91dDoKLQl0cmFjZV93cml0ZWJh
Y2tfd2FpdF9pZmZfY29uZ2VzdGVkKGppZmZpZXNfdG9fdXNlY3ModGltZW91dCksCi0JCQkJCWpp
ZmZpZXNfdG9fdXNlY3MoamlmZmllcyAtIHN0YXJ0KSk7Ci0KLQlyZXR1cm4gcmV0OwotfQotRVhQ
T1JUX1NZTUJPTCh3YWl0X2lmZl9jb25nZXN0ZWQpOwpkaWZmIC0tZ2l0IGEvbW0vcGFnZV9hbGxv
Yy5jIGIvbW0vcGFnZV9hbGxvYy5jCmluZGV4IDI4MjgwMzcuLjcxZTk4NDIgMTAwNjQ0Ci0tLSBh
L21tL3BhZ2VfYWxsb2MuYworKysgYi9tbS9wYWdlX2FsbG9jLmMKQEAgLTE5MjksNyArMTkyOSw3
IEBAIF9fYWxsb2NfcGFnZXNfaGlnaF9wcmlvcml0eShnZnBfdCBnZnBfbWFzaywgdW5zaWduZWQg
aW50IG9yZGVyLAogCQkJcHJlZmVycmVkX3pvbmUsIG1pZ3JhdGV0eXBlKTsKIAogCQlpZiAoIXBh
Z2UgJiYgZ2ZwX21hc2sgJiBfX0dGUF9OT0ZBSUwpCi0JCQl3YWl0X2lmZl9jb25nZXN0ZWQocHJl
ZmVycmVkX3pvbmUsIEJMS19SV19BU1lOQywgSFovNTApOworCQkJY29uZ2VzdGlvbl93YWl0KEJM
S19SV19BU1lOQywgSFovNTApOwogCX0gd2hpbGUgKCFwYWdlICYmIChnZnBfbWFzayAmIF9fR0ZQ
X05PRkFJTCkpOwogCiAJcmV0dXJuIHBhZ2U7CkBAIC0yMTM3LDcgKzIxMzcsNyBAQCByZWJhbGFu
Y2U6CiAJcGFnZXNfcmVjbGFpbWVkICs9IGRpZF9zb21lX3Byb2dyZXNzOwogCWlmIChzaG91bGRf
YWxsb2NfcmV0cnkoZ2ZwX21hc2ssIG9yZGVyLCBwYWdlc19yZWNsYWltZWQpKSB7CiAJCS8qIFdh
aXQgZm9yIHNvbWUgd3JpdGUgcmVxdWVzdHMgdG8gY29tcGxldGUgdGhlbiByZXRyeSAqLwotCQl3
YWl0X2lmZl9jb25nZXN0ZWQocHJlZmVycmVkX3pvbmUsIEJMS19SV19BU1lOQywgSFovNTApOwor
CQljb25nZXN0aW9uX3dhaXQoQkxLX1JXX0FTWU5DLCBIWi81MCk7CiAJCWdvdG8gcmViYWxhbmNl
OwogCX0gZWxzZSB7CiAJCS8qCmRpZmYgLS1naXQgYS9tbS92bXNjYW4uYyBiL21tL3Ztc2Nhbi5j
CmluZGV4IDA2NjU1MjAuLjU5ZGU0MjcgMTAwNjQ0Ci0tLSBhL21tL3Ztc2Nhbi5jCisrKyBiL21t
L3Ztc2Nhbi5jCkBAIC03MDMsMTQgKzcwMywxMSBAQCBzdGF0aWMgbm9pbmxpbmVfZm9yX3N0YWNr
IHZvaWQgZnJlZV9wYWdlX2xpc3Qoc3RydWN0IGxpc3RfaGVhZCAqZnJlZV9wYWdlcykKICAqIHNo
cmlua19wYWdlX2xpc3QoKSByZXR1cm5zIHRoZSBudW1iZXIgb2YgcmVjbGFpbWVkIHBhZ2VzCiAg
Ki8KIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlua19wYWdlX2xpc3Qoc3RydWN0IGxpc3RfaGVh
ZCAqcGFnZV9saXN0LAotCQkJCSAgICAgIHN0cnVjdCB6b25lICp6b25lLAogCQkJCSAgICAgIHN0
cnVjdCBzY2FuX2NvbnRyb2wgKnNjKQogewogCUxJU1RfSEVBRChyZXRfcGFnZXMpOwogCUxJU1Rf
SEVBRChmcmVlX3BhZ2VzKTsKIAlpbnQgcGdhY3RpdmF0ZSA9IDA7Ci0JdW5zaWduZWQgbG9uZyBu
cl9kaXJ0eSA9IDA7Ci0JdW5zaWduZWQgbG9uZyBucl9jb25nZXN0ZWQgPSAwOwogCXVuc2lnbmVk
IGxvbmcgbnJfcmVjbGFpbWVkID0gMDsKIAogCWNvbmRfcmVzY2hlZCgpOwpAQCAtNzMwLDcgKzcy
Nyw2IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlua19wYWdlX2xpc3Qoc3RydWN0IGxpc3Rf
aGVhZCAqcGFnZV9saXN0LAogCQkJZ290byBrZWVwOwogCiAJCVZNX0JVR19PTihQYWdlQWN0aXZl
KHBhZ2UpKTsKLQkJVk1fQlVHX09OKHBhZ2Vfem9uZShwYWdlKSAhPSB6b25lKTsKIAogCQlzYy0+
bnJfc2Nhbm5lZCsrOwogCkBAIC04MDgsOCArODA0LDYgQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcg
c2hyaW5rX3BhZ2VfbGlzdChzdHJ1Y3QgbGlzdF9oZWFkICpwYWdlX2xpc3QsCiAJCX0KIAogCQlp
ZiAoUGFnZURpcnR5KHBhZ2UpKSB7Ci0JCQlucl9kaXJ0eSsrOwotCiAJCQlpZiAocmVmZXJlbmNl
cyA9PSBQQUdFUkVGX1JFQ0xBSU1fQ0xFQU4pCiAJCQkJZ290byBrZWVwX2xvY2tlZDsKIAkJCWlm
ICghbWF5X2VudGVyX2ZzKQpAQCAtODIwLDcgKzgxNCw2IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25n
IHNocmlua19wYWdlX2xpc3Qoc3RydWN0IGxpc3RfaGVhZCAqcGFnZV9saXN0LAogCQkJLyogUGFn
ZSBpcyBkaXJ0eSwgdHJ5IHRvIHdyaXRlIGl0IG91dCBoZXJlICovCiAJCQlzd2l0Y2ggKHBhZ2Vv
dXQocGFnZSwgbWFwcGluZywgc2MpKSB7CiAJCQljYXNlIFBBR0VfS0VFUDoKLQkJCQlucl9jb25n
ZXN0ZWQrKzsKIAkJCQlnb3RvIGtlZXBfbG9ja2VkOwogCQkJY2FzZSBQQUdFX0FDVElWQVRFOgog
CQkJCWdvdG8gYWN0aXZhdGVfbG9ja2VkOwpAQCAtOTMxLDE1ICs5MjQsNiBAQCBrZWVwX2x1bXB5
OgogCQlWTV9CVUdfT04oUGFnZUxSVShwYWdlKSB8fCBQYWdlVW5ldmljdGFibGUocGFnZSkpOwog
CX0KIAotCS8qCi0JICogVGFnIGEgem9uZSBhcyBjb25nZXN0ZWQgaWYgYWxsIHRoZSBkaXJ0eSBw
YWdlcyBlbmNvdW50ZXJlZCB3ZXJlCi0JICogYmFja2VkIGJ5IGEgY29uZ2VzdGVkIEJESS4gSW4g
dGhpcyBjYXNlLCByZWNsYWltZXJzIHNob3VsZCBqdXN0Ci0JICogYmFjayBvZmYgYW5kIHdhaXQg
Zm9yIGNvbmdlc3Rpb24gdG8gY2xlYXIgYmVjYXVzZSBmdXJ0aGVyIHJlY2xhaW0KLQkgKiB3aWxs
IGVuY291bnRlciB0aGUgc2FtZSBwcm9ibGVtCi0JICovCi0JaWYgKG5yX2RpcnR5ID09IG5yX2Nv
bmdlc3RlZCAmJiBucl9kaXJ0eSAhPSAwKQotCQl6b25lX3NldF9mbGFnKHpvbmUsIFpPTkVfQ09O
R0VTVEVEKTsKLQogCWZyZWVfcGFnZV9saXN0KCZmcmVlX3BhZ2VzKTsKIAogCWxpc3Rfc3BsaWNl
KCZyZXRfcGFnZXMsIHBhZ2VfbGlzdCk7CkBAIC0xNDI2LDEyICsxNDEwLDEyIEBAIHNocmlua19p
bmFjdGl2ZV9saXN0KHVuc2lnbmVkIGxvbmcgbnJfdG9fc2Nhbiwgc3RydWN0IHpvbmUgKnpvbmUs
CiAKIAlzcGluX3VubG9ja19pcnEoJnpvbmUtPmxydV9sb2NrKTsKIAotCW5yX3JlY2xhaW1lZCA9
IHNocmlua19wYWdlX2xpc3QoJnBhZ2VfbGlzdCwgem9uZSwgc2MpOworCW5yX3JlY2xhaW1lZCA9
IHNocmlua19wYWdlX2xpc3QoJnBhZ2VfbGlzdCwgc2MpOwogCiAJLyogQ2hlY2sgaWYgd2Ugc2hv
dWxkIHN5bmNyb25vdXNseSB3YWl0IGZvciB3cml0ZWJhY2sgKi8KIAlpZiAoc2hvdWxkX3JlY2xh
aW1fc3RhbGwobnJfdGFrZW4sIG5yX3JlY2xhaW1lZCwgcHJpb3JpdHksIHNjKSkgewogCQlzZXRf
cmVjbGFpbV9tb2RlKHByaW9yaXR5LCBzYywgdHJ1ZSk7Ci0JCW5yX3JlY2xhaW1lZCArPSBzaHJp
bmtfcGFnZV9saXN0KCZwYWdlX2xpc3QsIHpvbmUsIHNjKTsKKwkJbnJfcmVjbGFpbWVkICs9IHNo
cmlua19wYWdlX2xpc3QoJnBhZ2VfbGlzdCwgc2MpOwogCX0KIAogCWxvY2FsX2lycV9kaXNhYmxl
KCk7CkBAIC0yMDg1LDE0ICsyMDY5LDggQEAgc3RhdGljIHVuc2lnbmVkIGxvbmcgZG9fdHJ5X3Rv
X2ZyZWVfcGFnZXMoc3RydWN0IHpvbmVsaXN0ICp6b25lbGlzdCwKIAogCQkvKiBUYWtlIGEgbmFw
LCB3YWl0IGZvciBzb21lIHdyaXRlYmFjayB0byBjb21wbGV0ZSAqLwogCQlpZiAoIXNjLT5oaWJl
cm5hdGlvbl9tb2RlICYmIHNjLT5ucl9zY2FubmVkICYmCi0JCSAgICBwcmlvcml0eSA8IERFRl9Q
UklPUklUWSAtIDIpIHsKLQkJCXN0cnVjdCB6b25lICpwcmVmZXJyZWRfem9uZTsKLQotCQkJZmly
c3Rfem9uZXNfem9uZWxpc3Qoem9uZWxpc3QsIGdmcF96b25lKHNjLT5nZnBfbWFzayksCi0JCQkJ
CQkmY3B1c2V0X2N1cnJlbnRfbWVtc19hbGxvd2VkLAotCQkJCQkJJnByZWZlcnJlZF96b25lKTsK
LQkJCXdhaXRfaWZmX2Nvbmdlc3RlZChwcmVmZXJyZWRfem9uZSwgQkxLX1JXX0FTWU5DLCBIWi8x
MCk7Ci0JCX0KKwkJICAgIHByaW9yaXR5IDwgREVGX1BSSU9SSVRZIC0gMikKKwkJCWNvbmdlc3Rp
b25fd2FpdChCTEtfUldfQVNZTkMsIEhaLzEwKTsKIAl9CiAKIG91dDoKQEAgLTI0NTUsMTQgKzI0
MzMsNiBAQCBsb29wX2FnYWluOgogCQkJCQkgICAgbWluX3dtYXJrX3BhZ2VzKHpvbmUpLCBlbmRf
em9uZSwgMCkpCiAJCQkJCWhhc191bmRlcl9taW5fd2F0ZXJtYXJrX3pvbmUgPSAxOwogCQkJfSBl
bHNlIHsKLQkJCQkvKgotCQkJCSAqIElmIGEgem9uZSByZWFjaGVzIGl0cyBoaWdoIHdhdGVybWFy
aywKLQkJCQkgKiBjb25zaWRlciBpdCB0byBiZSBubyBsb25nZXIgY29uZ2VzdGVkLiBJdCdzCi0J
CQkJICogcG9zc2libGUgdGhlcmUgYXJlIGRpcnR5IHBhZ2VzIGJhY2tlZCBieQotCQkJCSAqIGNv
bmdlc3RlZCBCRElzIGJ1dCBhcyBwcmVzc3VyZSBpcyByZWxpZXZlZCwKLQkJCQkgKiBzcGVjdHVs
YXRpdmVseSBhdm9pZCBjb25nZXN0aW9uIHdhaXRzCi0JCQkJICovCi0JCQkJem9uZV9jbGVhcl9m
bGFnKHpvbmUsIFpPTkVfQ09OR0VTVEVEKTsKIAkJCQlpZiAoaSA8PSAqY2xhc3N6b25lX2lkeCkK
IAkJCQkJYmFsYW5jZWQgKz0gem9uZS0+cHJlc2VudF9wYWdlczsKIAkJCX0KQEAgLTI1NDYsOSAr
MjUxNiw2IEBAIG91dDoKIAkJCQlvcmRlciA9IHNjLm9yZGVyID0gMDsKIAkJCQlnb3RvIGxvb3Bf
YWdhaW47CiAJCQl9Ci0KLQkJCS8qIElmIGJhbGFuY2VkLCBjbGVhciB0aGUgY29uZ2VzdGVkIGZs
YWcgKi8KLQkJCXpvbmVfY2xlYXJfZmxhZyh6b25lLCBaT05FX0NPTkdFU1RFRCk7CiAJCX0KIAl9
CiAKLS0gCjEuNy4wLjQKCg==
--0015175cdc0ca2d75804a46e57c9--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
