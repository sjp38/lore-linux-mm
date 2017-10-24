Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 59D9C6B0253
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 15:30:37 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b16so5736273lfb.21
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 12:30:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r29sor213188ljb.46.2017.10.24.12.30.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 12:30:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
References: <CABXGCsPEkwzKUU9OPRDOMue7TpWa4axTWg0FbXZAq+JZmoubGw@mail.gmail.com>
 <20171019035641.GB23773@intel.com> <CABXGCsPL0pUHo_M-KxB3mabfdGMSHPC0uchLBBt0JCzF2BYBww@mail.gmail.com>
 <20171020064305.GA13688@intel.com> <20171020091239.cfwapdkx5g7afyp7@dhcp22.suse.cz>
From: =?UTF-8?B?0JzQuNGF0LDQuNC7INCT0LDQstGA0LjQu9C+0LI=?= <mikhail.v.gavrilov@gmail.com>
Date: Wed, 25 Oct 2017 00:30:18 +0500
Message-ID: <CABXGCsMZ0hFFJyPU2cu+JDLHZ+5eO5i=8FOv71biwpY5neyofA@mail.gmail.com>
Subject: Re: swapper/0: page allocation failure: order:0, mode:0x1204010(GFP_NOWAIT|__GFP_COMP|__GFP_RECLAIMABLE|__GFP_NOTRACK),
 nodemask=(null)
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Du, Changbin" <changbin.du@intel.com>, linux-mm@kvack.org

On 20 October 2017 at 14:12, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 20-10-17 14:43:06, Du, Changbin wrote:
>> On Thu, Oct 19, 2017 at 11:52:49PM +0500, =D0=9C=D0=B8=D1=85=D0=B0=D0=B8=
=D0=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
>> > On 19 October 2017 at 08:56, Du, Changbin <changbin.du@intel.com> wrot=
e:
>> > > On Thu, Oct 19, 2017 at 01:16:48AM +0500, =D0=9C=D0=B8=D1=85=D0=B0=
=D0=B8=D0=BB =D0=93=D0=B0=D0=B2=D1=80=D0=B8=D0=BB=D0=BE=D0=B2 wrote:
>> > > I am curious about this, how can slub try to alloc compound page but=
 the order
>> > > is 0? This is wrong.
>> >
>> > Nobody seems to know how this could happen. Can any logs shed light on=
 this?
>> >
>> After checking the code, kernel can handle such case. So please ignore m=
y last
>> comment.
>>
>> The warning is reporting OOM, first you need confirm if you have enough =
free
>> memory? If that is true, then it is not a programmer error.
>
> The kernel is not OOM. It just failed to allocate for GFP_NOWAIT which
> means that no memory reclaim could be used to free up potentially unused
> page cache. This means that kswapd is not able to free up memory in the
> pace it is allocated. Such an allocation failure shouldn't be critical
> and the caller should have means to fall back to a regular allocation or
> retry later. You can play with min_free_kbytes and increase it to kick
> the background reclaim sooner.

Michal, thanks for clarification.
It means if any application allocate for GFP_NOWAIT and we not having
enough free memory (RAM) we will got this warning.
For example:
$ free -ht
              total        used        free      shared  buff/cache   avail=
able
Mem:            30G         27G        277M        1,6G        2,8G        =
593M
Swap:           59G         21G         38G
Total:          89G         48G         38G
I see that computer have total free 38G, but only 277M available free RAM.
So if we try allocate now more than 277M we get this warning again, right?

I try reproduce it with kernel 4.13.8, but get another warning:

[ 3551.169126] chrome: page allocation stalls for 11542ms, order:0,
mode:0x14280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=3D(null)
[ 3551.169161] chrome cpuset=3D/ mems_allowed=3D0
[ 3551.169366] CPU: 6 PID: 4224 Comm: chrome Not tainted
4.13.8-300.fc27.x86_64+debug #1
[ 3551.169369] Hardware name: Gigabyte Technology Co., Ltd.
Z87M-D3H/Z87M-D3H, BIOS F11 08/12/2014
[ 3551.169371] Call Trace:
[ 3551.169378]  dump_stack+0x8e/0xd6
[ 3551.169383]  warn_alloc+0x114/0x1c0
[ 3551.169397]  __alloc_pages_slowpath+0x90f/0x1100
[ 3551.169425]  __alloc_pages_nodemask+0x351/0x3e0
[ 3551.169437]  alloc_pages_vma+0x88/0x200
[ 3551.169444]  __handle_mm_fault+0x80c/0x10c0
[ 3551.169460]  handle_mm_fault+0x14d/0x310
[ 3551.169468]  __do_page_fault+0x27c/0x520
[ 3551.169479]  do_page_fault+0x30/0x80
[ 3551.169485]  page_fault+0x28/0x30
[ 3551.169489] RIP: 0033:0x559c78814df8
[ 3551.169491] RSP: 002b:00007ffdeccc2230 EFLAGS: 00010206
[ 3551.169495] RAX: 0000003800000000 RBX: 00001f4aabb14ff9 RCX: 00000000000=
00001
[ 3551.169497] RDX: 0000000000000038 RSI: 00001f4aabb14ff8 RDI: 00002dd7e2a=
27020
[ 3551.169499] RBP: 0000000000000001 R08: 00002dd7e2ac6070 R09: 00000000000=
00280
[ 3551.169501] R10: 0000000000000004 R11: 0000000000000028 R12: 00000000000=
00038
[ 3551.169504] R13: 0000000000000038 R14: 0000000000000038 R15: 00001f4aabb=
14ff8
[ 3551.169590] Mem-Info:
[ 3551.169595] active_anon:6904352 inactive_anon:520427 isolated_anon:0
                active_file:55480 inactive_file:38890 isolated_file:0
                unevictable:1836 dirty:556 writeback:0 unstable:0
                slab_reclaimable:67559 slab_unreclaimable:95967
                mapped:353547 shmem:480723 pagetables:89161 bounce:0
                free:49404 free_pcp:1474 free_cma:0
[ 3551.169599] Node 0 active_anon:27617408kB inactive_anon:2081708kB
active_file:221920kB inactive_file:155560kB unevictable:7344kB
isolated(anon):0kB isolated(file):0kB mapped:1414188kB dirty:2224kB
writeback:0kB shmem:1922892kB shmem_thp: 0kB shmem_pmdmapped: 0kB
anon_thp: 2101248kB writeback_tmp:0kB unstable:0kB all_unreclaimable?
no
[ 3551.169602] Node 0 DMA free:15864kB min:32kB low:44kB high:56kB
active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
unevictable:0kB writepending:0kB present:15988kB managed:15896kB
mlocked:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB
local_pcp:0kB free_cma:0kB
[ 3551.169608] lowmem_reserve[]: 0 2371 30994 30994 30994
[ 3551.169621] Node 0 DMA32 free:119372kB min:5168kB low:7596kB
high:10024kB active_anon:2228640kB inactive_anon:17660kB
active_file:876kB inactive_file:4040kB unevictable:896kB
writepending:416kB present:2514388kB managed:2448676kB mlocked:896kB
kernel_stack:1040kB pagetables:14084kB bounce:0kB free_pcp:1624kB
local_pcp:116kB free_cma:0kB
[ 3551.169627] lowmem_reserve[]: 0 0 28622 28622 28622
[ 3551.169640] Node 0 Normal free:62380kB min:62380kB low:91688kB
high:120996kB active_anon:25388752kB inactive_anon:2064048kB
active_file:220752kB inactive_file:151860kB unevictable:6448kB
writepending:740kB present:29874176kB managed:29314960kB
mlocked:6448kB kernel_stack:53936kB pagetables:342560kB bounce:0kB
free_pcp:4272kB local_pcp:464kB free_cma:0kB
[ 3551.169646] lowmem_reserve[]: 0 0 0 0 0
[ 3551.169659] Node 0 DMA: 2*4kB (U) 2*8kB (U) 0*16kB 1*32kB (U)
3*64kB (U) 2*128kB (U) 0*256kB 0*512kB 1*1024kB (U) 1*2048kB (M)
3*4096kB (M) =3D 15864kB
[ 3551.169702] Node 0 DMA32: 613*4kB (UME) 2123*8kB (UME) 1986*16kB
(UME) 990*32kB (UME) 386*64kB (UME) 64*128kB (UME) 10*256kB (ME)
2*512kB (ME) 0*1024kB 0*2048kB 0*4096kB =3D 119372kB
[ 3551.169745] Node 0 Normal: 1782*4kB (UMEH) 914*8kB (UMEH) 383*16kB
(UMEH) 338*32kB (UMEH) 100*64kB (UMEH) 67*128kB (UME) 19*256kB (ME)
6*512kB (UME) 8*1024kB (E) 0*2048kB 0*4096kB =3D 62488kB
[ 3551.169790] Node 0 hugepages_total=3D0 hugepages_free=3D0
hugepages_surp=3D0 hugepages_size=3D1048576kB
[ 3551.169793] Node 0 hugepages_total=3D0 hugepages_free=3D0
hugepages_surp=3D0 hugepages_size=3D2048kB
[ 3551.169795] 625241 total pagecache pages
[ 3551.169806] 50231 pages in swap cache
[ 3551.169808] Swap cache stats: add 1086858, delete 1036658, find 115058/1=
73977
[ 3551.169811] Free swap  =3D 58996476kB
[ 3551.169813] Total swap =3D 62494716kB
[ 3551.169895] 8101138 pages RAM
[ 3551.169897] 0 pages HighMem/MovableOnly
[ 3551.169899] 156255 pages reserved
[ 3551.169901] 0 pages cma reserved
[ 3551.169903] 0 pages hwpoisoned

it's same problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
