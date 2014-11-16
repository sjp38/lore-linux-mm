Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBA06B008A
	for <linux-mm@kvack.org>; Sun, 16 Nov 2014 12:42:01 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so3859443wgg.0
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 09:42:01 -0800 (PST)
Received: from mail-wg0-x22e.google.com (mail-wg0-x22e.google.com. [2a00:1450:400c:c00::22e])
        by mx.google.com with ESMTPS id j16si12582518wic.43.2014.11.16.09.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Nov 2014 09:42:00 -0800 (PST)
Received: by mail-wg0-f46.google.com with SMTP id x13so23255181wgg.33
        for <linux-mm@kvack.org>; Sun, 16 Nov 2014 09:42:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <trinity-6ca93e77-f228-44f6-8e0b-6e490ec08dd6-1416158789512@3capp-gmx-bs30>
References: <loom.20141116T150953-370@post.gmane.org>
	<CALYGNiM+ubswA8qn3aaiBHCnwvjb=99x+n_Bb3=vN12abRuRGA@mail.gmail.com>
	<trinity-6ca93e77-f228-44f6-8e0b-6e490ec08dd6-1416158789512@3capp-gmx-bs30>
Date: Sun, 16 Nov 2014 21:42:00 +0400
Message-ID: <CALYGNiObf7yx3uoJJQMJ9r+t2VdpkEYvP8RDKz4ftxsVTYoCXg@mail.gmail.com>
Subject: Re: Re: How to interpret this OOM situation?
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marki <mro2@gmx.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Nov 16, 2014 at 8:26 PM,  <mro2@gmx.net> wrote:
>
> When I manually drop caches, it looks like this:
>
> # grep -i dirty /proc/meminfo ; free; sync ; sync ; sync ; echo 3 >
> /proc/sys/vm/drop_caches ; free ; grep -i dirty /proc/meminfo
> Dirty:              2224 kB
>              total       used       free     shared    buffers     cached
> Mem:       3926016    3690288     235728          0      85628    1376996
> -/+ buffers/cache:    2227664    1698352
> Swap:      5244924     323872    4921052
>              total       used       free     shared    buffers     cached
> Mem:       3926016    2604568    1321448          0        132     407696
> -/+ buffers/cache:    2196740    1729276
> Swap:      5244924     323580    4921344
> Dirty:                 8 kB
>
>
> However, during backup times (usually when the OOM happens) the page cach=
e
> is not (automatically) emptied before OOMing.
>
>
> Right now I tried finding out using fincore what exactly is in the page
> cache, only to get allocation failures:

You may try tool from kernel sources:  tools/vm/page-types.c
since 3.15 (or so) it can dump file page-cache (key -f) recursively for a t=
ree.

>
>
> Nov 16 18:04:31 fs kernel: [554283.989323] fincore: page allocation failu=
re: order:4, mode:0xd0
> Nov 16 18:04:31 fs kernel: [554283.989331] Pid: 17921, comm: fincore Tain=
ted: G           E X 3.0.101-0.35-default #1
> Nov 16 18:04:31 fs kernel: [554283.989333] Call Trace:
> Nov 16 18:04:31 fs kernel: [554283.989345]  [<ffffffff81004935>] dump_tra=
ce+0x75/0x310
> Nov 16 18:04:31 fs kernel: [554283.989352]  [<ffffffff8145f2f3>] dump_sta=
ck+0x69/0x6f
> Nov 16 18:04:31 fs kernel: [554283.989357]  [<ffffffff81100a46>] warn_all=
oc_failed+0xc6/0x170
> Nov 16 18:04:31 fs kernel: [554283.989361]  [<ffffffff81102631>] __alloc_=
pages_slowpath+0x541/0x7d0
> Nov 16 18:04:31 fs kernel: [554283.989364]  [<ffffffff81102aa9>] __alloc_=
pages_nodemask+0x1e9/0x200
> Nov 16 18:04:31 fs kernel: [554283.989368]  [<ffffffff811439c3>] kmem_get=
pages+0x53/0x180
> Nov 16 18:04:31 fs kernel: [554283.989372]  [<ffffffff811447c6>] fallback=
_alloc+0x196/0x270
> Nov 16 18:04:31 fs kernel: [554283.989375]  [<ffffffff81145117>] kmem_cac=
he_alloc_trace+0x207/0x2a0
> Nov 16 18:04:31 fs kernel: [554283.989380]  [<ffffffff810dc466>] __tracin=
g_open+0x66/0x330
> Nov 16 18:04:31 fs kernel: [554283.989384]  [<ffffffff810dc783>] tracing_=
open+0x53/0xb0
> Nov 16 18:04:31 fs kernel: [554283.989388]  [<ffffffff81158f68>] __dentry=
_open+0x198/0x310
> Nov 16 18:04:31 fs kernel: [554283.989393]  [<ffffffff81168572>] do_last+=
0x1f2/0x800
> Nov 16 18:04:31 fs kernel: [554283.989397]  [<ffffffff811697e9>] path_ope=
nat+0xd9/0x420
> Nov 16 18:04:31 fs kernel: [554283.989400]  [<ffffffff81169c6c>] do_filp_=
open+0x4c/0xc0
> Nov 16 18:04:31 fs kernel: [554283.989403]  [<ffffffff8115a90f>] do_sys_o=
pen+0x17f/0x250
> Nov 16 18:04:31 fs kernel: [554283.989409]  [<ffffffff8146a012>] system_c=
all_fastpath+0x16/0x1b
> Nov 16 18:04:31 fs kernel: [554283.989453]  [<00007ff2d2b05fd0>] 0x7ff2d2=
b05fcf
> Nov 16 18:04:31 fs kernel: [554283.989454] Mem-Info:
> Nov 16 18:04:31 fs kernel: [554283.989455] Node 0 DMA per-cpu:
> Nov 16 18:04:31 fs kernel: [554283.989457] CPU    0: hi:    0, btch:   1 =
usd:   0
> Nov 16 18:04:31 fs kernel: [554283.989459] CPU    1: hi:    0, btch:   1 =
usd:   0
> Nov 16 18:04:31 fs kernel: [554283.989460] Node 0 DMA32 per-cpu:
> Nov 16 18:04:31 fs kernel: [554283.989461] CPU    0: hi:  186, btch:  31 =
usd:   0
> Nov 16 18:04:31 fs kernel: [554283.989463] CPU    1: hi:  186, btch:  31 =
usd: 185
> Nov 16 18:04:31 fs kernel: [554283.989464] Node 0 Normal per-cpu:
> Nov 16 18:04:31 fs kernel: [554283.989465] CPU    0: hi:  186, btch:  31 =
usd:   0
> Nov 16 18:04:31 fs kernel: [554283.989466] CPU    1: hi:  186, btch:  31 =
usd:  57
> Nov 16 18:04:31 fs kernel: [554283.989469] active_anon:50701 inactive_ano=
n:27212 isolated_anon:0
> Nov 16 18:04:31 fs kernel: [554283.989470]  active_file:82852 inactive_fi=
le:268841 isolated_file:0
> Nov 16 18:04:31 fs kernel: [554283.989471]  unevictable:7301 dirty:63 wri=
teback:0 unstable:0
> Nov 16 18:04:31 fs kernel: [554283.989471]  free:42190 slab_reclaimable:8=
4053 slab_unreclaimable:239021
> Nov 16 18:04:31 fs kernel: [554283.989472]  mapped:7031 shmem:29 pagetabl=
es:2934 bounce:0
> Nov 16 18:04:31 fs kernel: [554283.989474] Node 0 DMA free:15880kB min:25=
6kB low:320kB high:384kB active_anon:0kB inactive_anon:0kB active_file:0kB =
inactive_file:0kB unevictable:0kB isolated(anon):0kB isolate d(file):0kB pr=
esent:15688kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab=
_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB uns=
table:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? y=
es
> Nov 16 18:04:31 fs kernel: [554283.989480] lowmem_reserve[]: 0 3000 4010 =
4010
> Nov 16 18:04:31 fs kernel: [554283.989482] Node 0 DMA32 free:131040kB min=
:50368kB low:62960kB high:75552kB active_anon:172872kB inactive_anon:57708k=
B active_file:301912kB inactive_file:900636kB unevictable:22 688kB isolated=
(anon):0kB isolated(file):0kB present:3072160kB mlocked:22688kB dirty:12kB =
writeback:0kB mapped:19944kB shmem:56kB slab_reclaimable:259512kB slab_unre=
claimable:763412kB kernel_stack:1280kB pagetables: 3560kB unstable:0kB boun=
ce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> Nov 16 18:04:31 fs kernel: [554283.989489] lowmem_reserve[]: 0 0 1010 101=
0
> Nov 16 18:04:31 fs kernel: [554283.989492] Node 0 Normal free:21840kB
> min:16956kB low:21192kB high:25432kB active_anon:29932kB
> inactive_anon:51140kB active_file:29496kB inactive_file:174728kB
> unevictable:6516
> kB isolated(anon):0kB isolated(file):0kB present:1034240kB mlocked:6516kB
> dirty:240kB writeback:0kB mapped:8180kB shmem:60kB slab_reclaimable:76700=
kB
> slab_unreclaimable:192672kB kernel_stack:3072kB pagetables:8176k
> B unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:21
> all_unreclaimable? no
> Nov 16 18:04:31 fs kernel: [554283.989499] lowmem_reserve[]: 0 0 0 0
> Nov 16 18:04:31 fs kernel: [554283.989501] Node 0 DMA: 0*4kB 1*8kB 0*16kB=
 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB =3D 15880=
kB
> Nov 16 18:04:31 fs kernel: [554283.989506] Node 0 DMA32: 1896*4kB 14924*8=
kB 0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB =
=3D 131040kB
> Nov 16 18:04:31 fs kernel: [554283.989512] Node 0 Normal: 4826*4kB 61*8kB=
 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB =
=3D 21840kB
> Nov 16 18:04:31 fs kernel: [554283.989518] 197543 total pagecache pages
> Nov 16 18:04:31 fs kernel: [554283.989519] 8325 pages in swap cache
> Nov 16 18:04:31 fs kernel: [554283.989520] Swap cache stats: add 227787, =
delete 219462, find 1899386/1918583
> Nov 16 18:04:31 fs kernel: [554283.989521] Free swap  =3D 4921412kB
> Nov 16 18:04:31 fs kernel: [554283.989522] Total swap =3D 5244924kB
> Nov 16 18:04:31 fs kernel: [554283.989523] 1030522 pages RAM
>
>
> Note that tmpfs is empty.
>
>
> BTW this is a Novell fileserver with their NSS filesystem. They just say =
"give it more RAM" (duh)

Heh, you have out of tree filesystem kernel module? This's much more
suspicious than cifs.

>
>
>> Swap can be used only for anon pages or for tmpfs. You have a lot of
>> file page cache.
>> I guess this is leak of pages' reference counter in some filesystem,
>> more likely in cifs.
>>
>> Try to isolate which part of workload causes this leak, for example
>> switch to another filesystem.
>>
>> On Sun, Nov 16, 2014 at 5:11 PM, Marki <mro2@gmx.net> wrote:
>> >
>> > Hey there,
>> >
>> > I wouldn't know where to turn anymore, maybe you guys can help me debu=
g this
>> > OOM.
>> >
>> > Questions aside from "why in the end is this happening":
>> > - GFP mask lower byte 0xa indicates a request for a free page in highm=
em.
>> > This is a 64-bit system and therefore has no highmem zone. So what's g=
oing on?
>> > - Swap is almost not used: why not use it before OOMing?
>> > - Pagecache is high: why not empty it before OOMing? (almost no dirty =
pages)
>> >
>> > Oh and it's a machine with 4G of RAM on kernel 3.0.101 (SLES11 SP3).
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
